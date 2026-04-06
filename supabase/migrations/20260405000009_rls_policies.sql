-- Migration: Políticas RLS para acesso seguro por tenant

-- Helper: retorna o cooperative_id do cooperado logado
create or replace function current_cooperative_id()
returns uuid language sql stable as $$
  select cooperative_id from cooperados
  where user_id = auth.uid() limit 1;
$$;

-- Helper: verifica se o cooperado logado é admin
create or replace function is_admin()
returns boolean language sql stable as $$
  select coalesce((
    select is_admin from cooperados
    where user_id = auth.uid() limit 1
  ), false);
$$;

-- ── Cooperativas ──
create policy "cooperado_le_propria_cooperativa"
  on cooperativas for select
  using (id = current_cooperative_id());

-- ── Cooperados ──
create policy "cooperado_le_membros_da_cooperativa"
  on cooperados for select
  using (cooperative_id = current_cooperative_id());

create policy "cooperado_atualiza_proprio_perfil"
  on cooperados for update
  using (user_id = auth.uid());

create policy "admin_insere_cooperado"
  on cooperados for insert
  with check (cooperative_id = current_cooperative_id() and is_admin());

-- ── Oportunidades ──
create policy "cooperado_le_oportunidades_da_cooperativa"
  on oportunidades for select
  using (cooperative_id = current_cooperative_id());

create policy "admin_insere_oportunidade"
  on oportunidades for insert
  with check (cooperative_id = current_cooperative_id() and is_admin());

create policy "admin_atualiza_oportunidade"
  on oportunidades for update
  using (cooperative_id = current_cooperative_id() and is_admin());

-- ── Candidaturas ──
create policy "cooperado_le_candidaturas_da_oportunidade"
  on candidaturas for select
  using (
    exists (
      select 1 from oportunidades o
      where o.id = oportunidade_id
        and o.cooperative_id = current_cooperative_id()
    )
  );

create policy "cooperado_insere_propria_candidatura"
  on candidaturas for insert
  with check (
    cooperado_id = (select id from cooperados where user_id = auth.uid() limit 1)
    and not exists (
      select 1 from oportunidades o
      where o.id = oportunidade_id
        and o.status not in ('aberta','em_candidatura')
    )
  );

create policy "cooperado_desiste_propria_candidatura"
  on candidaturas for update
  using (cooperado_id = (select id from cooperados where user_id = auth.uid() limit 1));

-- ── Atribuições ──
create policy "cooperado_le_proprias_atribuicoes"
  on atribuicoes for select
  using (
    cooperado_id = (select id from cooperados where user_id = auth.uid() limit 1)
    or is_admin()
  );

create policy "admin_insere_atribuicao"
  on atribuicoes for insert
  with check (is_admin());

-- ── Comunicados ──
create policy "cooperado_le_comunicados_da_cooperativa"
  on comunicados for select
  using (cooperative_id = current_cooperative_id());

create policy "admin_insere_comunicado"
  on comunicados for insert
  with check (cooperative_id = current_cooperative_id() and is_admin());

-- ── Leituras de comunicados ──
create policy "cooperado_le_proprias_leituras"
  on comunicado_leituras for select
  using (cooperado_id = (select id from cooperados where user_id = auth.uid() limit 1));

create policy "cooperado_insere_propria_leitura"
  on comunicado_leituras for insert
  with check (cooperado_id = (select id from cooperados where user_id = auth.uid() limit 1));

-- ── Cotas ──
create policy "cooperado_le_proprias_cotas"
  on cotas_pagamentos for select
  using (
    cooperado_id = (select id from cooperados where user_id = auth.uid() limit 1)
    or is_admin()
  );

create policy "admin_gerencia_cotas"
  on cotas_pagamentos for all
  using (cooperative_id = current_cooperative_id() and is_admin());

-- ── Notificações ──
create policy "cooperado_le_proprias_notificacoes"
  on notifications_log for select
  using (user_id = auth.uid());
