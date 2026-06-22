import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GoogleAuth } from "https://esm.sh/google-auth-library@9";

serve(async (req: Request) => {
  console.log("🚀 FUNCTION TRIGGERED");

  try {
    const { community_id, title, body, sender_id } = await req.json();

    // ---------------- Supabase ----------------
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const projectId = Deno.env.get("FIREBASE_PROJECT_ID")!;

    // ---------------- Service Account ----------------
    const serviceAccountRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

    if (!serviceAccountRaw) {
      throw new Error("Missing FIREBASE_SERVICE_ACCOUNT env variable");
    }

    const serviceAccount = JSON.parse(serviceAccountRaw);

    console.log("✅ Service account loaded");
    console.log("📌 Project ID:", projectId);

    // ---------------- Google Auth ----------------
    const auth = new GoogleAuth({
      credentials: serviceAccount,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });

    const client = await auth.getClient();
    const accessTokenObj = await client.getAccessToken();
    const accessToken = accessTokenObj.token;

    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    // ---------------- Get Community Members ----------------
    const { data: members, error: mError } = await supabase
      .from("community_members")
      .select("user_id")
      .eq("community_id", community_id);

    if (mError) throw mError;

    let userIds = members?.map((m) => m.user_id) || [];

    // ❌ Remove sender
    if (sender_id) {
      userIds = userIds.filter((id) => id !== sender_id);
    }

    console.log("👥 Users to notify:", userIds.length);

    if (userIds.length === 0) {
      return new Response(JSON.stringify({ message: "No users to notify" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // ---------------- Get Tokens ----------------
    const { data: tokensData, error: tError } = await supabase
      .from("user_tokens")
      .select("fcm_token")
      .in("user_id", userIds);

    if (tError) throw tError;

    if (!tokensData || tokensData.length === 0) {
      return new Response(JSON.stringify({ message: "No tokens found" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // ---------------- REMOVE DUPLICATES ----------------
    const uniqueTokens = [
      ...new Set(tokensData.map((t) => t.fcm_token).filter(Boolean)),
    ];

    console.log("📱 Total tokens:", tokensData.length);
    console.log("✨ Unique tokens:", uniqueTokens.length);

    // ---------------- Send Notifications ----------------
    const results = [];

    for (const token of uniqueTokens) {
      try {
        const res = await fetch(url, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: token,
              notification: {
                title: title,
                body: body,
              },
            },
          }),
        });

        const data = await res.json();
        results.push(data);
      } catch (err) {
        console.error("❌ Error sending to token:", token, err);
      }
    }

    console.log("✅ Notifications sent:", results.length);

    return new Response(
      JSON.stringify({
        success: true,
        sent: results.length,
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error: unknown) {
    const err = error as Error;

    console.error("🔥 FUNCTION ERROR:", err.message);

    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
    });
  }
});