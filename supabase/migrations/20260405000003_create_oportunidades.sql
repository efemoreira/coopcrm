-- Migration: Cria a tabela de oportunidades de trabalho
create type oportunidade_status as enum (
  'rascunho','aberta','em_candidatura','atribuida','em_execucao','concluida','cancelada'
);
create type criterio_selecao as enum ('manual','fifo','rodizio');

create table if not exists oportunidades (
  id                  uuid primary key default gen_random_uuid(),
  cooperative_id      uuid not null references cooperativas(id) on delete cascade,
  criado_por          uuid not null references cooperados(id),
  titulo              text not null,
  tipo                text not null,
  descricao           text,
  status              oportunidade_status not null default 'rascunho',
  prazo_candidatura   timestamptz not null,
  data_execucao       timestamptz,
  local               text,
  valor_estimado      numeric(10,2),
  num_vagas           int not null default 1 check (num_vagas >= 1),
  requisitos          text,
  criterio_selecao    criterio_selecao not null default 'manual',
  motivo_cancelamento text,
  metadata            jsonb not null default '{}',
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index oportunidades_cooperative_idx on oportunidades(cooperative_id);
create index oportunidades_status_idx on oportunidades(status);
create index oportunidades_prazo_idx on oportunidades(prazo_candidatura);

create trigger oportunidades_updated_at
  before update on oportunidades
  for each row execute function update_updated_at();

-- Trigger: auto-expirar oportunidades quando prazo passa
create or replace function expire_oportunidades()
returns void language plpgsql as $$
begin
  update oportunidades
  set status = 'cancelada', motivo_cancelamento = 'Prazo expirado automaticamente'
  where status in ('aberta','em_candidatura')
    and prazo_candidatura < now();
end;
$$;

comment on table oportunidades is 'Oportunidades de trabalho publicadas pela cooperativa.';
