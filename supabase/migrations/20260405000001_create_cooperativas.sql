-- Migration: Cria a tabela de cooperativas (tenant root)
create extension if not exists "pgcrypto";

create table if not exists cooperativas (
  id            uuid primary key default gen_random_uuid(),
  nome          text not null,
  cnpj          text unique not null,
  logo_url      text,
  plano         text not null default 'starter' check (plano in ('starter','growth','enterprise')),
  status        text not null default 'ativo' check (status in ('ativo','suspenso','cancelado')),
  settings      jsonb not null default '{}',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Trigger updated_at
create or replace function update_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger cooperativas_updated_at
  before update on cooperativas
  for each row execute function update_updated_at();

comment on table cooperativas is 'Tenants: uma cooperative por cliente. Multi-tenancy via cooperative_id em todas as outras tabelas.';
