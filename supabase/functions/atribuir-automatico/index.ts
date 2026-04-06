// Edge Function — atribuição automática de candidatos a uma oportunidade.
//
// Payload esperado (POST body):
//   { oportunidade_id: string, atribuido_por: string }
//
// Algoritmos suportados (campo `criterio_selecao` da oportunidade):
//   - "fifo": seleciona pelos mais antigos (created_at ASC)
//   - "rodizio": seleciona pelos que têm menos atribuições (num_cota ASC)
//
// Retorna: { atribuidos: number, rejeitados: number }
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req: Request) => {
  const { oportunidade_id, atribuido_por } = await req.json();

  if (!oportunidade_id || !atribuido_por) {
    return new Response(
      JSON.stringify({ error: "oportunidade_id e atribuido_por são obrigatórios" }),
      { status: 400 }
    );
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  // Buscar oportunidade
  const { data: oport } = await supabase
    .from("oportunidades")
    .select("id, num_vagas, criterio_selecao, cooperative_id")
    .eq("id", oportunidade_id)
    .single();

  if (!oport) {
    return new Response(JSON.stringify({ error: "Oportunidade não encontrada" }), { status: 404 });
  }

  // Buscar candidatos pendentes
  const query = supabase
    .from("candidaturas")
    .select("id, cooperado_id, cooperado:cooperados(num_cota)")
    .eq("oportunidade_id", oportunidade_id)
    .eq("status", "pendente");

  // FIFO: ordem de cadastro, Rodízio: menor num_cota (menos atribuições)
  const orderBy = oport.criterio_selecao === "rodizio"
    ? query.order("cooperado->num_cota", { ascending: true })
    : query.order("created_at", { ascending: true });

  const { data: candidatos } = await orderBy;

  if (!candidatos?.length) {
    return new Response(JSON.stringify({ error: "Nenhum candidato pendente" }), { status: 422 });
  }

  const selecionados = candidatos.slice(0, oport.num_vagas);

  // Criar atribuições e atualizar status das candidaturas selecionadas
  for (const candidato of selecionados) {
    await supabase.from("atribuicoes").insert({
      oportunidade_id,
      cooperado_id: candidato.cooperado_id,
      candidatura_id: candidato.id,
      atribuido_por,
    });
    await supabase
      .from("candidaturas")
      .update({ status: "selecionada" })
      .eq("id", candidato.id);
  }

  // Rejeitar candidatos não selecionados
  const rejeitados = candidatos.slice(oport.num_vagas);
  for (const rej of rejeitados) {
    await supabase
      .from("candidaturas")
      .update({ status: "rejeitada" })
      .eq("id", rej.id);
  }

  return new Response(
    JSON.stringify({ atribuidos: selecionados.length, rejeitados: rejeitados.length }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
