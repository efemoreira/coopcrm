-- Migration: Candidaturas a oportunidades + atribuições finais

create type candidatura_status as enum ('pendente','retirada','selecionada','rejeitada','desistiu');

create table if not exists candidaturas (
  id              uuid primary key default gen_random_uuid(),
  oportunidade_id uuid not null references oportunidades(id) on delete cascade,
  cooperado_id    uuid not null references cooperados(id) on delete cascade,
  status          candidatura_status not null default 'pendente',
  mensagem        text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (oportunidade_id, cooperado_id)  -- um cooperado só pode se candidatar uma vez
);

create index candidaturas_oportunidade_idx on candidaturas(oportunidade_id);
create index candidaturas_cooperado_idx on candidaturas(cooperado_id);

create trigger candidaturas_updated_at
  before update on candidaturas
  for each row execute function update_updated_at();

-- Atribuições: resultado da seleção
create table if not exists atribuicoes (
  id              uuid primary key default gen_random_uuid(),
  oportunidade_id uuid not null references oportunidades(id) on delete cascade,
  cooperado_id    uuid not null references cooperados(id) on delete cascade,
  candidatura_id  uuid references candidaturas(id),
  atribuido_por   uuid not null references cooperados(id),
  created_at      timestamptz not null default now(),
  unique (oportunidade_id, cooperado_id)
);

create index atribuicoes_oportunidade_idx on atribuicoes(oportunidade_id);
create index atribuicoes_cooperado_idx on atribuicoes(cooperado_id);

-- Trigger: quando atribuição é criada, atualizar status da oportunidade
create or replace function on_atribuicao_created()
returns trigger language plpgsql as $$
declare
  v_num_vagas int;
  v_atribuidas int;
begin
  select num_vagas into v_num_vagas from oportunidades where id = new.oportunidade_id;
  select count(*) into v_atribuidas from atribuicoes where oportunidade_id = new.oportunidade_id;
  if v_atribuidas >= v_num_vagas then
    update oportunidades set status = 'atribuida' where id = new.oportunidade_id;
  end if;
  return new;
end;
$$;

create trigger atribuicao_created
  after insert on atribuicoes
  for each row execute function on_atribuicao_created();
