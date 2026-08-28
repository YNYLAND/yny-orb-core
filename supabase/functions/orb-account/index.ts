import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.112.4";

const encoder = new TextEncoder();
const TELEGRAM_MAX_AGE_SECONDS = 15 * 60;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type AccountBody = {
  action?: unknown;
  display_name?: unknown;
  telegram_init_data?: unknown;
  session_token?: unknown;
};

type VerifiedIdentity = {
  sourceType: "supabase_auth" | "telegram";
  externalUserId: string;
};

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
  });
}

function cleanDisplayName(value: unknown): string | null {
  if (value == null) return null;
  if (typeof value !== "string") throw new Error("display_name_invalid");
  const normalized = value.trim().replace(/\s+/g, " ");
  if (!normalized) return null;
  if (normalized.length > 100) throw new Error("display_name_too_long");
  return normalized;
}

function bytesToHex(bytes: Uint8Array): string {
  return Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("");
}

function timingSafeEqualHex(expected: string, actual: string): boolean {
  if (expected.length !== actual.length) return false;
  let difference = 0;
  for (let index = 0; index < expected.length; index += 1) {
    difference |= expected.charCodeAt(index) ^ actual.charCodeAt(index);
  }
  return difference === 0;
}

async function sha256Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", encoder.encode(value));
  return bytesToHex(new Uint8Array(digest));
}

async function hmacSha256(key: Uint8Array, message: string): Promise<Uint8Array> {
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    key,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("HMAC", cryptoKey, encoder.encode(message));
  return new Uint8Array(signature);
}

async function verifyTelegramInitData(rawInitData: string, botToken: string): Promise<VerifiedIdentity> {
  const params = new URLSearchParams(rawInitData);
  const suppliedHash = params.get("hash")?.toLowerCase() ?? "";
  if (!/^[a-f0-9]{64}$/.test(suppliedHash)) throw new Error("telegram_hash_missing");

  params.delete("hash");
  params.delete("signature");
  const dataCheckString = Array.from(params.entries())
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([key, value]) => `${key}=${value}`)
    .join("\n");

  const secretKey = await hmacSha256(encoder.encode("WebAppData"), botToken);
  const expectedHash = bytesToHex(await hmacSha256(secretKey, dataCheckString));
  if (!timingSafeEqualHex(expectedHash, suppliedHash)) throw new Error("telegram_signature_invalid");

  const authDate = Number(params.get("auth_date"));
  const nowSeconds = Math.floor(Date.now() / 1000);
  if (!Number.isInteger(authDate) || authDate > nowSeconds + 60 || nowSeconds - authDate > TELEGRAM_MAX_AGE_SECONDS) {
    throw new Error("telegram_init_data_expired");
  }

  const rawUser = params.get("user");
  if (!rawUser) throw new Error("telegram_user_missing");

  let user: Record<string, unknown>;
  try {
    user = JSON.parse(rawUser);
  } catch {
    throw new Error("telegram_user_invalid");
  }

  const telegramId = user.id;
  if ((typeof telegramId !== "number" && typeof telegramId !== "string") || !/^\d+$/.test(String(telegramId))) {
    throw new Error("telegram_user_invalid");
  }

  return { sourceType: "telegram", externalUserId: String(telegramId) };
}

async function verifySupabaseUser(
  authorization: string,
  supabaseUrl: string,
  anonKey: string,
): Promise<VerifiedIdentity> {
  const token = authorization.replace(/^Bearer\s+/i, "").trim();
  if (!token) throw new Error("authorization_invalid");

  const authClient = createClient(supabaseUrl, anonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
    global: { headers: { Authorization: `Bearer ${token}` } },
  });

  const { data, error } = await authClient.auth.getUser(token);
  if (error || !data.user) throw new Error("authorization_invalid");

  return { sourceType: "supabase_auth", externalUserId: data.user.id };
}

async function verifyOrbSessionToken(
  rawToken: string,
  adminClient: ReturnType<typeof createClient>,
): Promise<string> {
  const token = rawToken.trim();
  if (!token) throw new Error("orb_session_invalid");

  const tokenHash = await sha256Hex(token);
  const { data, error } = await adminClient
    .from("orb_sessions")
    .select("profile_id,expires_at,revoked_at")
    .eq("token_hash", tokenHash)
    .maybeSingle();

  if (error) {
    console.error("orb session lookup failed", error.code);
    throw new Error("orb_session_unavailable");
  }
  if (!data?.profile_id) throw new Error("orb_session_invalid");
  if (data.revoked_at) throw new Error("orb_session_revoked");

  const expiresAt = new Date(String(data.expires_at ?? "")).getTime();
  if (!Number.isFinite(expiresAt) || expiresAt <= Date.now()) {
    throw new Error("orb_session_expired");
  }

  return String(data.profile_id);
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) return json(500, { error: "server_not_configured" });

  let body: AccountBody;
  try {
    body = await request.json();
  } catch {
    return json(400, { error: "invalid_json" });
  }

  const action = typeof body.action === "string" ? body.action.trim().toLowerCase() : "quote";
  if (action !== "quote" && action !== "create") return json(422, { error: "unsupported_action" });

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  let profileId: string | null = null;
  let identity: VerifiedIdentity | null = null;

  try {
    const authorization = request.headers.get("Authorization") ?? "";
    if (/^Bearer\s+\S+/i.test(authorization)) {
      identity = await verifySupabaseUser(authorization, supabaseUrl, anonKey);
    } else if (typeof body.telegram_init_data === "string" && body.telegram_init_data.trim()) {
      const botToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
      if (!botToken) return json(503, { error: "telegram_account_not_configured" });
      identity = await verifyTelegramInitData(body.telegram_init_data, botToken);
    } else if (typeof body.session_token === "string" && body.session_token.trim()) {
      profileId = await verifyOrbSessionToken(body.session_token, adminClient);
    } else {
      return json(401, { error: "verified_identity_required" });
    }
  } catch (error) {
    const code = error instanceof Error ? error.message : "identity_verification_failed";
    if (code === "orb_session_unavailable") return json(503, { error: code });
    const publicCodes = new Set([
      "authorization_invalid",
      "telegram_hash_missing",
      "telegram_signature_invalid",
      "telegram_init_data_expired",
      "telegram_user_missing",
      "telegram_user_invalid",
      "orb_session_invalid",
      "orb_session_revoked",
      "orb_session_expired",
    ]);
    return json(401, { error: publicCodes.has(code) ? code : "identity_verification_failed" });
  }

  let displayName: string | null = null;
  if (action === "create") {
    try {
      displayName = cleanDisplayName(body.display_name);
    } catch (error) {
      const code = error instanceof Error ? error.message : "display_name_invalid";
      return json(422, { error: code });
    }
  }

  if (!profileId && identity) {
    const { data: link, error: linkError } = await adminClient
      .from("profile_links")
      .select("profile_id")
      .eq("source_type", identity.sourceType)
      .eq("external_user_id", identity.externalUserId)
      .maybeSingle();

    if (linkError) {
      console.error("profile link lookup failed", linkError.code);
      return json(500, { error: "profile_lookup_failed" });
    }
    profileId = link?.profile_id ? String(link.profile_id) : null;
  }

  if (!profileId) return json(404, { error: "profile_not_found", next: "create_profile" });

  const rpcName = action === "quote" ? "get_profile_account_quote_v1" : "purchase_profile_account_v1";
  const params = action === "quote"
    ? { p_profile_id: profileId }
    : { p_profile_id: profileId, p_display_name: displayName };

  const { data, error } = await adminClient.rpc(rpcName, params);
  if (error || !data || typeof data !== "object") {
    console.error(`${rpcName} failed`, error?.code ?? "empty_result");
    return json(500, { error: "account_operation_failed" });
  }

  const result = data as Record<string, unknown>;
  if (result.ok !== true) {
    const code = typeof result.code === "string" ? result.code : "account_operation_failed";
    if (code === "insufficient_balance") return json(402, result);
    if (code === "profile_not_found" || code === "profile_not_found_or_inactive") return json(404, result);
    if (code === "offer_not_available") return json(409, result);
    return json(422, result);
  }

  if (action === "create" && result.already_created !== true) return json(201, result);
  return json(200, result);
});
