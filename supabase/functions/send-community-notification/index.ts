import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GoogleAuth } from "https://esm.sh/google-auth-library@9";

serve(async (req: Request) => {

  console.log("FUNCTION TRIGGERED");
  try {
    const { community_id, title, body, sender_id } = await req.json();

    // ---------------- Supabase ----------------
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const projectId = Deno.env.get("FIREBASE_PROJECT_ID")!;

    // ---------------- FIXED SERVICE ACCOUNT ----------------
    const serviceAccountRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

    if (!serviceAccountRaw) {
      throw new Error("Missing FIREBASE_SERVICE_ACCOUNT env variable");
    }

    const serviceAccount = JSON.parse(serviceAccountRaw);

    console.log("SERVICE ACCOUNT LOADED:", !!serviceAccount);
    console.log("PROJECT ID:", projectId);

    // ---------------- Google Auth ----------------
    const auth = new GoogleAuth({
      credentials: serviceAccount,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });

    const client = await auth.getClient();
    const accessTokenObj = await client.getAccessToken();
    const accessToken = accessTokenObj.token;

    const url =
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    // ---------------- Get members ----------------
    const { data: members, error: mError } = await supabase
      .from("community_members")
      .select("user_id")
      .eq("community_id", community_id);

    if (mError) throw mError;

    let userIds = members?.map((m) => m.user_id) || [];

    if (sender_id) {
      userIds = userIds.filter((id) => id !== sender_id);
    }

    // ---------------- Get tokens ----------------
    const { data: tokens, error: tError } = await supabase
      .from("user_tokens")
      .select("fcm_token")
      .in("user_id", userIds);

    if (tError) throw tError;

    // ---------------- Send notifications ----------------
    for (const t of tokens || []) {
      await fetch(url, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: t.fcm_token,
            notification: { title, body },
          },
        }),
      });
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (error: unknown) {
    const err = error as Error;
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
    });
  }
});