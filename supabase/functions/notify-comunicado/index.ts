// CA-11-3: Edge Function — notifica cooperados sobre novo comunicado interno.
//
// Payload esperado (POST body):
//   { comunicado_id, cooperative_id, titulo, destinatario_ids?: string[] }
//
// Comportamento:
//   - Se destinatario_ids é `null` ou vazio: envia para TODOS os cooperados ativos.
//   - Se destinatario_ids tem valores: envia apenas para esse subgrupo.
//   - Registra resultado (sent/failed) em `notifications_log`.
//   - Se FCM_SERVER_KEY não estiver configurado, aborta silenciosamente.
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  try {
    const { comunicado_id, cooperative_id, titulo, destinatario_ids } =
      await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Buscar tokens FCM — todos ativos ou somente os destinatários especificados
    let query = supabase
      .from("cooperados")
      .select("id, fcm_token")
      .eq("cooperative_id", cooperative_id)
      .eq("status", "ativo")
      .not("fcm_token", "is", null);

    if (destinatario_ids && destinatario_ids.length > 0) {
      query = query.in("id", destinatario_ids);
    }

    const { data: cooperados } = await query;

    const fcmKey = Deno.env.get("FCM_SERVER_KEY");
    if (!fcmKey) {
      console.warn("FCM_SERVER_KEY not set — skipping push");
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    for (const c of cooperados ?? []) {
      if (!c.fcm_token) continue;
      try {
        const res = await fetch("https://fcm.googleapis.com/fcm/send", {
          method: "POST",
          headers: {
            Authorization: `key=${fcmKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            to: c.fcm_token,
            notification: {
              title: "Novo comunicado",
              body: titulo,
            },
            data: { comunicado_id, tipo: "comunicado" },
          }),
        });

        await supabase.from("notifications_log").insert({
          cooperado_id: c.id,
          tipo: "comunicado",
          payload: { comunicado_id, titulo },
          status: res.ok ? "sent" : "failed",
        });

        if (!res.ok) {
          console.error("FCM error for token", c.fcm_token, await res.text());
        }
      } catch (err) {
        console.error("notify-comunicado push error:", err);
      }
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("notify-comunicado error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
