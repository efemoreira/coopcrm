// CA-05-3 / CA-05-4: Edge Function — notifica cooperados após atribuição manual.
//
// Payload esperado (POST body):
//   { oportunidade_id, titulo, selecionados_ids: string[], nao_selecionados_ids: string[] }
//
// Comportamento:
//   - Envia push "Parabéns! Você foi selecionado" para cada ID em selecionados_ids.
//   - Envia push "Oportunidade atribuída" para cada ID em nao_selecionados_ids.
//   - Registra todas as notificações em `notifications_log`.
//   - Exige a variável de ambiente FCM_SERVER_KEY no painel Supabase.
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  try {
    const { oportunidade_id, titulo, selecionados_ids, nao_selecionados_ids } =
      await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const fcmKey = Deno.env.get("FCM_SERVER_KEY");

    const selecionados = await getCandidaturaCooperados(supabase, selecionados_ids ?? []);
    const naoSelecionados = await getCandidaturaCooperados(supabase, nao_selecionados_ids ?? []);

    await Promise.all([
      sendPush(
        selecionados,
        {
          title: "Parabéns! Você foi selecionado",
          body: `Você foi selecionado para a oportunidade: ${titulo}`,
        },
        fcmKey,
        supabase,
        oportunidade_id,
        "atribuicao_selecionado"
      ),
      sendPush(
        naoSelecionados,
        {
          title: "Oportunidade atribuída",
          body: `A oportunidade "${titulo}" foi atribuída a outros cooperados`,
        },
        fcmKey,
        supabase,
        oportunidade_id,
        "atribuicao_nao_selecionado"
      ),
    ]);

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("notify-atribuicao error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

async function getCandidaturaCooperados(
  supabase: ReturnType<typeof createClient>,
  candidaturaIds: string[]
): Promise<{ cooperadoId: string; fcmToken: string }[]> {
  if (!candidaturaIds || candidaturaIds.length === 0) return [];

  const { data } = await supabase
    .from("candidaturas")
    .select("cooperado_id, cooperados(fcm_token)")
    .in("id", candidaturaIds);

  return (data ?? [])
    .filter((c: any) => c.cooperados?.fcm_token)
    .map((c: any) => ({
      cooperadoId: c.cooperado_id as string,
      fcmToken: c.cooperados.fcm_token as string,
    }));
}

async function sendPush(
  recipients: { cooperadoId: string; fcmToken: string }[],
  notification: { title: string; body: string },
  fcmKey: string | undefined,
  supabase: ReturnType<typeof createClient>,
  oportunidadeId: string,
  tipo: string
): Promise<void> {
  if (!fcmKey) {
    console.warn("FCM_SERVER_KEY not set — skipping push");
    return;
  }

  for (const r of recipients) {
    try {
      const res = await fetch("https://fcm.googleapis.com/fcm/send", {
        method: "POST",
        headers: {
          Authorization: `key=${fcmKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          to: r.fcmToken,
          notification,
          data: { oportunidade_id: oportunidadeId, tipo },
        }),
      });

      await supabase.from("notifications_log").insert({
        cooperado_id: r.cooperadoId,
        tipo,
        payload: { oportunidade_id: oportunidadeId, ...notification },
        status: res.ok ? "sent" : "failed",
      });

      if (!res.ok) {
        console.error("FCM error for token", r.fcmToken, await res.text());
      }
    } catch (err) {
      console.error("sendPush error:", err);
    }
  }
}
