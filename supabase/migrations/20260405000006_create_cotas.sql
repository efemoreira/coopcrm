-- Migration: Cotas e pagamentos mensais dos cooperados

create type cota_status as enum ('pendente','pago','em_atraso','isento','cancelado');

create table if not exists cotas_pagamentos (
  id              uuid primary key default gen_random_uuid(),
  cooperative_id  uuid not null references cooperativas(id) on delete cascade,
  cooperado_id    uuid not null references cooperados(id) on delete cascade,
  competencia     text not null,  -- 'YYYY-MM'
  valor_devido    numeric(10,2) not null,
  valor_pago      numeric(10,2),
  status          cota_status not null default 'pendente',
  data_vencimento date not null,
  data_pagamento  timestamptz,
  comprovante_url text,
  observacoes     text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (cooperative_id, cooperado_id, competencia)
);

create index cotas_cooperative_idx on cotas_pagamentos(cooperative_id);
create index cotas_cooperado_idx on cotas_pagamentos(cooperado_id);
create index cotas_status_idx on cotas_pagamentos(status);

create trigger cotas_updated_at
  before update on cotas_pagamentos
  for each row execute function update_updated_at();

comment on table cotas_pagamentos is 'Controle de cotas mensais. Competencia no formato YYYY-MM.';
