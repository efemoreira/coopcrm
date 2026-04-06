// CA-04-3 / CA-07-1 / CA-07-2: Edge Function — notifica todos os cooperados ativos
// quando uma oportunidade é publicada (INSERT ou UPDATE com status='aberta').
//
// Acionado via Supabase Database Webhook na tabela `oportunidades`.
//
// CA-07-2: o corpo do push inclui título, valor estimado e prazo de candidatura.
// CA-07-3: o payload FCM inclui `oportunidade_id` para deep link ao detalhe.
// Exige: FCM_SERVER_KEY configurado em Supabase > Edge Functions > Secrets.
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: {
    id: string;
    cooperative_id: string;
    titulo: string;
    tipo: string;
    status: string;
    valor_estimado: number | null;
    prazo_candidata: string | null;
  };
}

serve(async (req: Request) => {
  const payload: WebhookPayload = await req.json();

  // Notificar quando oportunidade for publicada diretamente (INSERT com status='aberta')
  // ou quando rascunho for promovido a aberta (UPDATE com status='aberta')
  const isNewPublished = payload.type === "INSERT" && payload.record.status === "aberta";
  const isChangedToPublished = payload.type === "UPDATE" && payload.record.status === "aberta";
  if (!isNewPublished && !isChangedToPublished) {
    return new Response(JSON.stringify({ skipped: true }), { status: 200 });
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  // Buscar todos os cooperados ativos da cooperativa
  const { data: cooperados } = await supabase
    .from("cooperados")
    .select("user_id, nome, fcm_token")
    .eq("cooperative_id", payload.record.cooperative_id)
    .eq("status", "ativo");

  if (!cooperados?.length) {
    return new Response(JSON.stringify({ notified: 0 }), { status: 200 });
  }

  // CA-07-2: formata valor e prazo para exibir no push
  const valor = payload.record.valor_estimado
    ? `R$ ${payload.record.valor_estimado.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`
    : 'A combinar';
  const prazo = payload.record.prazo_candidata
    ? new Date(payload.record.prazo_candidata).toLocaleDateString('pt-BR')
    : '';
  const pushBody = prazo
    ? `${payload.record.titulo} · ${valor} · Prazo: ${prazo}`
    : `${payload.record.titulo} · ${valor}`;

  // Registrar notificações no log
  const notifications = cooperados.map((c) => ({
    cooperative_id: payload.record.cooperative_id,
    user_id: c.user_id,
    titulo: "Nova Oportunidade Disponível",
    mensagem: pushBody,
    tipo: "oportunidade",
    referencia_id: payload.record.id,
    referencia_tipo: "oportunidade",
  }));

  const { error } = await supabase
    .from("notifications_log")
    .insert(notifications);

  if (error) {
    console.error("Erro ao inserir notifications_log:", error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  // CA-07-1: Envio de push via FCM Legacy API
  const fcmKey = Deno.env.get("FCM_SERVER_KEY");
  if (fcmKey) {
    const tokensComFcm = (cooperados ?? []).filter((c: any) => c.fcm_token);
    for (const c of tokensComFcm) {
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
              title: "Nova Oportunidade Disponível",
              body: pushBody,
            },
            data: {
              oportunidade_id: payload.record.id,
              tipo: "oportunidade",
            },
          }),
        });
        if (!res.ok) {
          console.error("FCM error for token", c.fcm_token, await res.text());
        }
      } catch (err) {
        console.error("FCM send error:", err);
      }
    }
  } else {
    console.warn("FCM_SERVER_KEY not set — push não enviado");
  }

  return new Response(
    JSON.stringify({ notified: cooperados.length }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
