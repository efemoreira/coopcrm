-- Migration: Funções auxiliares e dados de seed para dev

-- Função: obter estatísticas da cooperativa (dashboard admin)
create or replace function get_cooperative_stats(p_cooperative_id uuid)
returns json language plpgsql security definer as $$
declare
  v_total_cooperados int;
  v_total_oportunidades int;
  v_oportunidades_abertas int;
  v_cotas_pendentes int;
begin
  select count(*) into v_total_cooperados
  from cooperados where cooperative_id = p_cooperative_id and status = 'ativo';

  select count(*) into v_total_oportunidades
  from oportunidades where cooperative_id = p_cooperative_id;

  select count(*) into v_oportunidades_abertas
  from oportunidades where cooperative_id = p_cooperative_id and status = 'aberta';

  select count(*) into v_cotas_pendentes
  from cotas_pagamentos where cooperative_id = p_cooperative_id and status in ('pendente','em_atraso');

  return json_build_object(
    'total_cooperados', v_total_cooperados,
    'total_oportunidades', v_total_oportunidades,
    'oportunidades_abertas', v_oportunidades_abertas,
    'cotas_pendentes', v_cotas_pendentes
  );
end;
$$;

-- Função: gerar cotas mensais para todos os cooperados de uma cooperativa
create or replace function gerar_cotas_mensais(
  p_cooperative_id uuid,
  p_competencia text,      -- formato 'YYYY-MM'
  p_valor_padrao numeric,
  p_data_vencimento date
) returns int language plpgsql security definer as $$
declare
  v_count int := 0;
  v_cooperado record;
begin
  for v_cooperado in
    select id from cooperados
    where cooperative_id = p_cooperative_id and status = 'ativo'
  loop
    insert into cotas_pagamentos (
      cooperative_id, cooperado_id, competencia, valor_devido, data_vencimento
    ) values (
      p_cooperative_id, v_cooperado.id, p_competencia, p_valor_padrao, p_data_vencimento
    ) on conflict (cooperative_id, cooperado_id, competencia) do nothing;
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;

comment on function gerar_cotas_mensais is 'Gera registros de cota para cada cooperado ativo. Idempotente por competencia.';
