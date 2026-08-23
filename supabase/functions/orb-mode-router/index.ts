import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
    },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ ok: false, error: "POST required" }, 405);
  }

  try {
    const body = await req.json();
    const modeKey = String(body?.mode_key || "system").toLowerCase();
    const message = String(body?.message || "");

    const { data, error } = await supabase.rpc("orb_mode_route_v1", {
      p_mode_key: modeKey,
      p_message: message,
      // The standalone router does not trust client-supplied entitlement flags.
      // Runtime orb-api will call the same RPC with server-derived actor access.
      p_has_ynychat: false,
      p_has_corp: false,
    });

    if (error) {
      throw error;
    }

    return json({ ok: true, route: data });
  } catch (error) {
    return json({
      ok: false,
      error: error instanceof Error ? error.message : String(error),
    }, 500);
  }
});
