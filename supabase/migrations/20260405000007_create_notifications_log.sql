-- Migration: Log de notificações push enviadas

create table if not exists notifications_log (
  id              uuid primary key default gen_random_uuid(),
  cooperative_id  uuid not null references cooperativas(id) on delete cascade,
  user_id         uuid not null references auth.users(id) on delete cascade,
  titulo          text not null,
  mensagem        text,
  tipo            text not null default 'geral',
  referencia_id   uuid,            -- ID da oportunidade ou comunicado referenciado
  referencia_tipo text,            -- 'oportunidade' | 'comunicado' | 'cota'
  lida            boolean not null default false,
  enviada_at      timestamptz not null default now(),
  lida_at         timestamptz,
  created_at      timestamptz not null default now()
);

create index notifications_user_idx on notifications_log(user_id, enviada_at desc);
create index notifications_cooperative_idx on notifications_log(cooperative_id);

comment on table notifications_log is 'Histórico de pushes enviados. Exibidos na tela de notificações do app.';
