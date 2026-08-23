import { createClient } from "npm:@supabase/supabase-js@2";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

function extractJson(text: string) {
  const cleaned = text.replace(/```json/g, "").replace(/```/g, "").trim();
  const start = cleaned.indexOf("{");
  const end = cleaned.lastIndexOf("}");
  if (start === -1 || end === -1) throw new Error("No JSON object found");
  return JSON.parse(cleaned.slice(start, end + 1));
}

async function authorize(req: Request) {
  const secret = req.headers.get("x-orb-memory-secret") || "";
  if (!secret) return false;
  const { data, error } = await supabase.rpc("verify_orb_memory_secret", { p_secret: secret });
  return !error && data === true;
}

async function createEmbedding(input: string) {
  if (!OPENAI_API_KEY) return null;
  const res = await fetch("https://api.openai.com/v1/embeddings", {
    method: "POST",
    headers: { Authorization: `Bearer ${OPENAI_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ model: "text-embedding-3-small", input }),
  });
  if (!res.ok) return null;
  const data = await res.json();
  return data.data?.[0]?.embedding || null;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("POST only", { status: 405 });
  if (!(await authorize(req))) return new Response("unauthorized", { status: 401 });

  try {
    let body: any = {};
    try { body = await req.json(); } catch (_) {}

    const targetProfileId = body.profile_id || null;
    const limit = Math.min(50, Math.max(1, Number(body.limit || 20)));

    let query = supabase.from("memory_events")
      .select("id, profile_id, session_id, mode, title, summary, memory_type, importance, tags, created_at")
      .not("profile_id", "is", null)
      .is("durable_memory_processed_at", null)
      .order("created_at", { ascending: true })
      .limit(limit);
    if (targetProfileId) query = query.eq("profile_id", targetProfileId);

    const { data: events, error: eventsError } = await query;
    if (eventsError) throw eventsError;
    if (!events?.length) return new Response(JSON.stringify({ ok: true, message: "No pending memory_events." }), { headers: { "Content-Type": "application/json" } });

    const groups = new Map<string, any[]>();
    for (const event of events) {
      const key = String(event.profile_id);
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(event);
    }

    const results: any[] = [];

    for (const [profileId, profileEvents] of groups) {
      const { data: currentMemories } = await supabase.from("profile_memory")
        .select("memory_type, title, content, importance, source_type, created_at")
        .eq("profile_id", profileId)
        .eq("is_active", true)
        .neq("source_type", "memory_event_direct")
        .order("created_at", { ascending: false })
        .limit(30);

      if (!OPENAI_API_KEY) {
        await supabase.from("memory_events").update({ durable_memory_last_error: "OPENAI_API_KEY missing" }).in("id", profileEvents.map((e:any)=>e.id));
        results.push({ profile_id: profileId, ok: false, error: "OPENAI_API_KEY missing" });
        continue;
      }

      const eventText = profileEvents.map((e: any) => `EVENT ${e.id}\nTitle: ${e.title || ""}\nSummary: ${e.summary || ""}\nType: ${e.memory_type || ""}\nImportance: ${e.importance || "normal"}\nTags: ${(e.tags || []).join(", ")}\nMode: ${e.mode || "system"}`).join("\n\n");
      const existingText = (currentMemories || []).map((m: any) => `[${m.memory_type || "context"} / ${m.importance || "normal"}] ${m.title || ""}\n${m.content}`).join("\n\n");

      const res = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: { Authorization: `Bearer ${OPENAI_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          model: "gpt-5.4",
          messages: [
            { role: "system", content: `Ты библиотекарь долговременной памяти Орба. Классифицируй КАЖДЫЙ pending event: либо преврати его в устойчивую profile memory, либо явно пометь как discard/redundant. Явные договорённости с Орбом, постоянные правила поведения, "не делай так", предпочтения, решения, цели, проекты и устойчивые рабочие соглашения считаются важными и должны сохраняться, пока пользователь их не изменит. Временный технический шум и одноразовые задачи можно discard. Если смысл уже полностью представлен в EXISTING DURABLE MEMORY, его можно discard как redundant. На один source_event_id максимум одна memory. Допустимые memory_type: project, goal, preference, decision, architecture, workflow, context, interest, identity, skill. Верни СТРОГО JSON: {"memories":[{"source_event_id":"uuid","memory_type":"preference","title":"...","content":"...","importance":"high","confidence":0.9,"tags":["..."]}],"discard_event_ids":["uuid"]}. Каждый входной EVENT id должен оказаться либо в memories, либо в discard_event_ids. Ничего не выдумывай.` },
            { role: "user", content: `EXISTING DURABLE MEMORY:\n${existingText || "none"}\n\nPENDING EVENTS:\n${eventText}` },
          ],
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        const err = JSON.stringify(data).slice(0, 1000);
        await supabase.from("memory_events").update({ durable_memory_last_error: err }).in("id", profileEvents.map((e:any)=>e.id));
        results.push({ profile_id: profileId, ok: false, error: data });
        continue;
      }

      let parsed: any;
      try { parsed = extractJson(data.choices?.[0]?.message?.content || ""); }
      catch (e) {
        const err = String(e);
        await supabase.from("memory_events").update({ durable_memory_last_error: err }).in("id", profileEvents.map((e:any)=>e.id));
        results.push({ profile_id: profileId, ok: false, error: err });
        continue;
      }

      const eventById = new Map(profileEvents.map((e: any) => [String(e.id), e]));
      const memories = Array.isArray(parsed.memories) ? parsed.memories : [];
      const discardIds = new Set((Array.isArray(parsed.discard_event_ids) ? parsed.discard_event_ids : []).map((x:any)=>String(x)));
      const classified = new Set<string>();
      const durableIds = new Set<string>();

      for (const memory of memories) {
        const sourceEventId = String(memory.source_event_id || "");
        const event = eventById.get(sourceEventId);
        if (!event || !memory.content || classified.has(sourceEventId)) continue;
        classified.add(sourceEventId);

        const embedding = await createEmbedding(String(memory.content));
        const { data: directRow } = await supabase.from("profile_memory")
          .select("id")
          .eq("source_id", sourceEventId)
          .in("source_type", ["memory_event_direct", "memory_event"])
          .limit(1).maybeSingle();

        let ok = false;
        if (directRow?.id) {
          const { error } = await supabase.from("profile_memory").update({
            memory_type: memory.memory_type || "context",
            title: memory.title || event.title || null,
            content: memory.content,
            importance: memory.importance || event.importance || "normal",
            confidence: Number(memory.confidence || 0.85),
            tags: Array.isArray(memory.tags) ? memory.tags : (event.tags || []),
            source_type: "memory_event",
            embedding,
            is_active: true,
            updated_at: new Date().toISOString(),
          }).eq("id", directRow.id);
          ok = !error;
        } else {
          const { error } = await supabase.from("profile_memory").insert({
            profile_id: profileId,
            memory_type: memory.memory_type || "context",
            title: memory.title || event.title || null,
            content: memory.content,
            importance: memory.importance || event.importance || "normal",
            confidence: Number(memory.confidence || 0.85),
            tags: Array.isArray(memory.tags) ? memory.tags : (event.tags || []),
            source_type: "memory_event",
            source_id: sourceEventId,
            source_session_id: event.session_id,
            embedding,
            is_active: true,
          });
          ok = !error;
        }
        if (ok) durableIds.add(sourceEventId);
        else classified.delete(sourceEventId);
      }

      for (const id of discardIds) {
        if (!eventById.has(id) || classified.has(id)) continue;
        classified.add(id);
        await supabase.from("profile_memory")
          .update({ is_active: false, updated_at: new Date().toISOString() })
          .eq("source_id", id)
          .eq("source_type", "memory_event_direct");
      }

      for (const event of profileEvents) {
        const id = String(event.id);
        if (classified.has(id)) {
          await supabase.from("memory_events").update({
            durable_memory_processed_at: new Date().toISOString(),
            durable_memory_count: durableIds.has(id) ? 1 : 0,
            durable_memory_last_error: null,
          }).eq("id", id);
        } else {
          await supabase.from("memory_events").update({
            durable_memory_last_error: "Builder did not classify this event; direct memory preserved for retry."
          }).eq("id", id);
        }
      }

      results.push({ profile_id: profileId, ok: true, processed_events: classified.size, durable_memories: durableIds.size, pending_retry: profileEvents.length - classified.size });
    }

    return new Response(JSON.stringify({ ok: true, results }), { headers: { "Content-Type": "application/json" } });
  } catch (err) {
    console.error("profile-memory-builder error:", err);
    return new Response(JSON.stringify({ ok: false, error: String(err) }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});
