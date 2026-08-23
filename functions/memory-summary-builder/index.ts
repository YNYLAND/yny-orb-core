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

async function backfillMissingEmbeddings(limit = 50) {
  const { data: blocks, error } = await supabase
    .from("session_summary_blocks")
    .select("id, title, tags, summary")
    .is("embedding", null)
    .order("created_at", { ascending: true })
    .limit(limit);

  if (error || !blocks?.length) {
    return { found: blocks?.length || 0, embedded: 0, failed: error ? 1 : 0 };
  }

  let embedded = 0;
  let failed = 0;

  for (const block of blocks) {
    const tags = Array.isArray(block.tags) ? block.tags : [];
    const input = [
      block.title ? `Title: ${block.title}` : "",
      tags.length ? `Tags: ${tags.join(", ")}` : "",
      `Summary: ${block.summary}`,
    ].filter(Boolean).join("\n");

    const embedding = await createEmbedding(input);
    if (!embedding) {
      failed++;
      continue;
    }

    const { error: updateError } = await supabase
      .from("session_summary_blocks")
      .update({ embedding })
      .eq("id", block.id);

    if (updateError) failed++;
    else embedded++;
  }

  return { found: blocks.length, embedded, failed };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("POST only", { status: 405 });
  if (!(await authorize(req))) return new Response("unauthorized", { status: 401 });

  try {
    let body: any = {};
    try { body = await req.json(); } catch (_) {}

    const embeddingBackfill = await backfillMissingEmbeddings(
      Math.min(100, Math.max(0, Number(body.embedding_backfill_limit ?? 50))),
    );

    const targetSessionId = body.session_id || null;
    const minMessages = Math.max(2, Number(body.min_messages || 8));
    const maxMessagesToAnalyze = Math.min(80, Math.max(8, Number(body.max_messages_to_analyze || 60)));
    const force = body.force === true;

    let sessionIds: string[] = [];
    if (targetSessionId) {
      sessionIds = [String(targetSessionId)];
    } else {
      const { data, error } = await supabase.from("conversation_messages")
        .select("session_id").not("session_id", "is", null).limit(2000);
      if (error) throw error;
      sessionIds = [...new Set((data || []).map((m: any) => String(m.session_id)))];
    }

    const results: any[] = [];

    for (const sessionId of sessionIds) {
      const { data: allMessages, error: messagesError } = await supabase
        .from("conversation_messages")
        .select("id, role, message, mode, created_at")
        .eq("session_id", sessionId)
        .order("created_at", { ascending: true })
        .order("id", { ascending: true });

      if (messagesError) { results.push({ session_id: sessionId, ok: false, error: messagesError.message }); continue; }
      if (!allMessages?.length) { results.push({ session_id: sessionId, ok: true, message: "no messages" }); continue; }

      const { data: lastBlock } = await supabase.from("session_summary_blocks")
        .select("block_index, message_to")
        .eq("session_id", sessionId)
        .order("block_index", { ascending: false })
        .limit(1).maybeSingle();

      const alreadySummarizedTo = Number(lastBlock?.message_to || 0);
      let nextBlockIndex = Number(lastBlock?.block_index || 0) + 1;
      const unsummarized = allMessages.slice(alreadySummarizedTo);

      if (!force && unsummarized.length < minMessages) {
        results.push({ session_id: sessionId, ok: true, message: "not enough new messages", unsummarized: unsummarized.length });
        continue;
      }

      const messagesToAnalyze = unsummarized.slice(0, maxMessagesToAnalyze);
      const messageFrom = alreadySummarizedTo + 1;
      const messageTo = messageFrom + messagesToAnalyze.length - 1;
      const dialogueText = messagesToAnalyze.map((m: any, i: number) => {
        const n = messageFrom + i;
        return `${n}. [${m.mode || "system"}] ${m.role === "orb" ? "Orb" : "User"}: ${m.message}`;
      }).join("\n\n");

      if (!OPENAI_API_KEY) {
        results.push({ session_id: sessionId, ok: false, error: "OPENAI_API_KEY missing" });
        continue;
      }

      const summaryRes = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: { Authorization: `Bearer ${OPENAI_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          model: "gpt-5.4",
          messages: [
            { role: "system", content: `Ты ассистент памяти Орба. Раздели фрагмент диалога на смысловые блоки. Один блок = одна тема, поворот или законченный смысл. Не дели механически, не выдумывай факты, не сохраняй пустой технический шум. Верни СТРОГО JSON: {"blocks":[{"title":"...","message_from":1,"message_to":5,"mode":"system","tags":["..."],"summary":"..."}]}. message_from/message_to должны быть номерами из входного текста.` },
            { role: "user", content: dialogueText },
          ],
        }),
      });

      const summaryData = await summaryRes.json();
      if (!summaryRes.ok) { results.push({ session_id: sessionId, ok: false, error: summaryData }); continue; }

      let parsed: any;
      try { parsed = extractJson(summaryData.choices?.[0]?.message?.content || ""); }
      catch (e) { results.push({ session_id: sessionId, ok: false, error: String(e) }); continue; }

      const blocks = (Array.isArray(parsed.blocks) ? parsed.blocks : [])
        .map((b: any) => ({ ...b, message_from: Number(b.message_from), message_to: Number(b.message_to) }))
        .filter((b: any) => b.summary && b.message_from >= messageFrom && b.message_to <= messageTo && b.message_to >= b.message_from)
        .sort((a: any, b: any) => a.message_from - b.message_from);

      const inserted: any[] = [];
      for (const block of blocks) {
        const tags = Array.isArray(block.tags) ? block.tags : [];
        const embeddingInput = [block.title ? `Title: ${block.title}` : "", tags.length ? `Tags: ${tags.join(", ")}` : "", `Summary: ${block.summary}`].filter(Boolean).join("\n");
        const embedding = await createEmbedding(embeddingInput);
        const { error } = await supabase.from("session_summary_blocks").insert({
          session_id: sessionId,
          block_index: nextBlockIndex,
          message_from: block.message_from,
          message_to: block.message_to,
          title: block.title || null,
          tags,
          mode: block.mode || null,
          summary: block.summary,
          embedding,
        });
        if (error) inserted.push({ ok: false, error: error.message });
        else inserted.push({ ok: true, block_index: nextBlockIndex, message_from: block.message_from, message_to: block.message_to, embedded: !!embedding });
        if (!error) nextBlockIndex++;
      }

      results.push({ session_id: sessionId, ok: true, semantic_blocks: inserted });
    }

    return new Response(JSON.stringify({ ok: true, embedding_backfill: embeddingBackfill, processed_sessions: results.length, results }), { headers: { "Content-Type": "application/json" } });
  } catch (err) {
    console.error("memory-summary-builder error:", err);
    return new Response(JSON.stringify({ ok: false, error: String(err) }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});
