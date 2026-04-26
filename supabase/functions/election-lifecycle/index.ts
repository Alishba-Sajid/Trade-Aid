// @ts-nocheck
/// <reference lib="deno.ns" />

import { serve } from "std/http/server.ts";
import { createClient } from "@supabase/supabase-js";

type Json = Record<string, unknown>;

function jsonResponse(body: Json, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

serve(async (req: Request) => {
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceKey) {
    return jsonResponse({ error: "Missing Supabase env vars" }, 500);
  }

  // Service role is required because `run_election_lifecycle()` is granted to service_role only.
  const sb = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });

  const { error } = await sb.rpc("run_election_lifecycle");
  if (error) {
    return jsonResponse({ ok: false, error: error.message, details: error }, 500);
  }

  return jsonResponse({ ok: true });
});

