-- Migration: Cria a tabela de cooperados (membros da cooperativa)
create table if not exists cooperados (
  id              uuid primary key default gen_random_uuid(),
  cooperative_id  uuid not null references cooperativas(id) on delete cascade,
  user_id         uuid not null references auth.users(id) on delete cascade,
  nome            text not null,
  cpf             text not null,
  email           text not null,
  telefone        text,
  foto_url        text,
  status          text not null default 'ativo' check (status in ('ativo','suspenso','inativo','inadimplente')),
  num_cota        int not null default 1,
  fcm_token       text,
  especialidades  text[] not null default '{}',
  data_admissao   date,
  is_admin        boolean not null default false,
  metadata        jsonb not null default '{}',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (cooperative_id, cpf),
  unique (cooperative_id, email),
  unique (cooperative_id, user_id)
);

create index cooperados_cooperative_idx on cooperados(cooperative_id);
create index cooperados_user_idx on cooperados(user_id);

create trigger cooperados_updated_at
  before update on cooperados
  for each row execute function update_updated_at();

comment on table cooperados is 'Membros de cada cooperativa. Cada cooperado tem um user_id vinculado ao Supabase Auth.';
