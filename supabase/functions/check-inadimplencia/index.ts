// CA-10-3: Edge Function — marca como inadimplente cooperados com cota vencida > 30 dias
// Deve ser chamada diariamente via pg_cron ou Supabase Scheduled Functions.
//
// SQL para agendar via pg_cron (rodar no Supabase SQL Editor):
//   select cron.schedule('check-inadimplencia-diario', '0 3 * * *',
//     $$select net.http_post(
//       url := current_setting('app.supabase_url') || '/functions/v1/check-inadimplencia',
//       headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '"}',
//       body := '{}'
//     )$$
//   );
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (_req: Request) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 1. Marcar como 'inadimplente' cooperados com cota vencida há mais de 30 dias
  //    (status in_atraso e data_vencimento <= hoje - 30 dias)
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - 30);
  const cutoffStr = cutoff.toISOString().split("T")[0]; // YYYY-MM-DD

  // Busca IDs de cooperados com cotas em atraso há > 30 dias
  const { data: cotasAtrasadas, error: cotasErr } = await supabase
    .from("cotas_pagamentos")
    .select("cooperado_id")
    .eq("status", "em_atraso")
    .lte("data_vencimento", cutoffStr);

  if (cotasErr) {
    console.error("Erro ao buscar cotas em atraso:", cotasErr);
    return new Response(JSON.stringify({ error: cotasErr.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  const idsAtraso = [...new Set((cotasAtrasadas ?? []).map((c: any) => c.cooperado_id as string))];

  let marcadosInadimplentes = 0;
  if (idsAtraso.length > 0) {
    const { error: updateErr } = await supabase
      .from("cooperados")
      .update({ status: "inadimplente" })
      .in("id", idsAtraso)
      .in("status", ["ativo"]); // só muda quem está ativo; não sobrescreve suspenso/inativo

    if (updateErr) {
      console.error("Erro ao marcar inadimplentes:", updateErr);
    } else {
      marcadosInadimplentes = idsAtraso.length;
    }
  }

  // 2. Reativar cooperados que antes estavam inadimplentes mas já regularizaram
  //    (têm todas as cotas pagas ou o último lançamento está em dia)
  const { data: cotasRegularizadas, error: regErr } = await supabase
    .from("cooperados")
    .select("id")
    .eq("status", "inadimplente");

  let reativados = 0;
  if (!regErr && cotasRegularizadas && cotasRegularizadas.length > 0) {
    for (const coop of cotasRegularizadas) {
      // Verifica se ainda tem alguma cota em atraso
      const { count } = await supabase
        .from("cotas_pagamentos")
        .select("id", { count: "exact", head: true })
        .eq("cooperado_id", coop.id)
        .eq("status", "em_atraso");

      if (count === 0) {
        await supabase
          .from("cooperados")
          .update({ status: "ativo" })
          .eq("id", coop.id);
        reativados++;
      }
    }
  }

  console.log(`check-inadimplencia: marcados=${marcadosInadimplentes}, reativados=${reativados}`);

  return new Response(
    JSON.stringify({ ok: true, marcadosInadimplentes, reativados }),
    { headers: { "Content-Type": "application/json" } }
  );
});
