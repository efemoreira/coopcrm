-- Migration: Comunicados internos da cooperativa

create table if not exists comunicados (
  id              uuid primary key default gen_random_uuid(),
  cooperative_id  uuid not null references cooperativas(id) on delete cascade,
  criado_por      uuid not null references cooperados(id),
  titulo          text not null,
  conteudo        text not null,
  tipo            text not null default 'geral' check (tipo in ('geral','urgente','informativo','financeiro')),
  pinned          boolean not null default false,
  created_at      timestamptz not null default now()
);

create index comunicados_cooperative_idx on comunicados(cooperative_id);
create index comunicados_pinned_idx on comunicados(pinned, created_at desc);

-- Tabela de leituras (para badge de não-lido)
create table if not exists comunicado_leituras (
  comunicado_id  uuid not null references comunicados(id) on delete cascade,
  cooperado_id   uuid not null references cooperados(id) on delete cascade,
  lido_at        timestamptz not null default now(),
  primary key (comunicado_id, cooperado_id)
);

comment on table comunicados is 'Feed de comunicados internos da cooperativa, com suporte a fixar no topo.';
