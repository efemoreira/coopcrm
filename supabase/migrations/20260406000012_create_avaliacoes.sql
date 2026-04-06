-- Tabela de avaliações de cooperados em oportunidades concluídas.
-- Cada cooperado pode ser avaliado uma vez por oportunidade.
create table if not exists avaliacoes (
  id               uuid primary key default gen_random_uuid(),
  oportunidade_id  uuid not null references oportunidades(id) on delete cascade,
  cooperado_id     uuid not null references cooperados(id) on delete cascade,
  nota             smallint not null check (nota between 1 and 5),
  comentario       text,
  created_at       timestamptz not null default now(),
  unique (oportunidade_id, cooperado_id)
);

create index avaliacoes_cooperado_idx on avaliacoes(cooperado_id);
create index avaliacoes_oportunidade_idx on avaliacoes(oportunidade_id);

-- RLS
alter table avaliacoes enable row level security;

-- Admin pode ver todas as avaliações da cooperativa
create policy "admin_le_avaliacoes"
  on avaliacoes for select
  using (
    exists (
      select 1 from oportunidades o
      where o.id = avaliacoes.oportunidade_id
        and o.cooperative_id = (
          select cooperative_id from cooperados where user_id = auth.uid() limit 1
        )
    )
    or
    exists (
      select 1 from cooperados where user_id = auth.uid() and is_admin = true limit 1
    )
  );

-- Cooperado vê avaliações que recebeu
create policy "cooperado_le_proprias_avaliacoes"
  on avaliacoes for select
  using (cooperado_id = (select id from cooperados where user_id = auth.uid() limit 1));

-- Admin insere/atualiza avaliações
create policy "admin_gerencia_avaliacoes"
  on avaliacoes for all
  using (
    exists (
      select 1 from cooperados where user_id = auth.uid() and is_admin = true limit 1
    )
  )
  with check (
    exists (
      select 1 from cooperados where user_id = auth.uid() and is_admin = true limit 1
    )
  );
