#!/usr/bin/env python3
"""Gerar migrations SQL do CoopCRM e Edge Functions."""
import os

BASE = "/Users/felipemoreira/development/opensquads/agentcode/opensquad/squads/software-factory/output/2026-04-05-223053/coopcrm"
MIGS = os.path.join(BASE, "supabase/migrations")
FUNS = os.path.join(BASE, "supabase/functions")
os.makedirs(MIGS, exist_ok=True)
os.makedirs(FUNS, exist_ok=True)

def write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content)
    print(f"OK: {os.path.relpath(path, BASE)}")

# ─── MIGRATIONS ───────────────────────────────────────────────────────────────

write(f"{MIGS}/20260405000001_create_cooperativas.sql", """-- Migration: Cria a tabela de cooperativas (tenant root)
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
""")

write(f"{MIGS}/20260405000002_create_cooperados.sql", """-- Migration: Cria a tabela de cooperados (membros da cooperativa)
create table if not exists cooperados (
  id              uuid primary key default gen_random_uuid(),
  cooperative_id  uuid not null references cooperativas(id) on delete cascade,
  user_id         uuid not null references auth.users(id) on delete cascade,
  nome            text not null,
  cpf             text not null,
  email           text not null,
  telefone        text,
  foto_url        text,
  status          text not null default 'ativo' check (status in ('ativo','suspenso','inativo')),
  num_cota        int not null default 1,
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
""")

write(f"{MIGS}/20260405000003_create_oportunidades.sql", """-- Migration: Cria a tabela de oportunidades de trabalho
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
""")

write(f"{MIGS}/20260405000004_create_candidaturas_atribuicoes.sql", """-- Migration: Candidaturas a oportunidades + atribuições finais

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
""")

write(f"{MIGS}/20260405000005_create_comunicados.sql", """-- Migration: Comunicados internos da cooperativa

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
""")

write(f"{MIGS}/20260405000006_create_cotas.sql", """-- Migration: Cotas e pagamentos mensais dos cooperados

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
""")

write(f"{MIGS}/20260405000007_create_notifications_log.sql", """-- Migration: Log de notificações push enviadas

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
""")

write(f"{MIGS}/20260405000008_enable_rls_all_tables.sql", """-- Migration: Habilitar RLS em todas as tabelas de dados
alter table cooperativas       enable row level security;
alter table cooperados         enable row level security;
alter table oportunidades      enable row level security;
alter table candidaturas        enable row level security;
alter table atribuicoes         enable row level security;
alter table comunicados         enable row level security;
alter table comunicado_leituras enable row level security;
alter table cotas_pagamentos    enable row level security;
alter table notifications_log   enable row level security;

comment on table cooperativas is 'RLS habilitado — acesso via políticas abaixo.';
""")

write(f"{MIGS}/20260405000009_rls_policies.sql", """-- Migration: Políticas RLS para acesso seguro por tenant

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
""")

write(f"{MIGS}/20260405000010_helper_functions.sql", """-- Migration: Funções auxiliares e dados de seed para dev

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
""")

# ─── EDGE FUNCTIONS ──────────────────────────────────────────────────────────

fns_path = f"{FUNS}/notify-nova-oportunidade"
os.makedirs(fns_path, exist_ok=True)

write(f"{fns_path}/index.ts", """import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: {
    id: string;
    cooperative_id: string;
    titulo: string;
    tipo: string;
    status: string;
  };
}

serve(async (req: Request) => {
  const payload: WebhookPayload = await req.json();

  // Somente notificar quando oportunidade for publicada (rascunho -> aberta)
  if (payload.type !== "UPDATE" || payload.record.status !== "aberta") {
    return new Response(JSON.stringify({ skipped: true }), { status: 200 });
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  // Buscar todos os cooperados ativos da cooperativa
  const { data: cooperados } = await supabase
    .from("cooperados")
    .select("user_id, nome")
    .eq("cooperative_id", payload.record.cooperative_id)
    .eq("status", "ativo");

  if (!cooperados?.length) {
    return new Response(JSON.stringify({ notified: 0 }), { status: 200 });
  }

  // Registrar notificações no log
  const notifications = cooperados.map((c) => ({
    cooperative_id: payload.record.cooperative_id,
    user_id: c.user_id,
    titulo: "Nova Oportunidade Disponível",
    mensagem: `${payload.record.titulo} — Candidate-se agora!`,
    tipo: "oportunidade",
    referencia_id: payload.record.id,
    referencia_tipo: "oportunidade",
  }));

  const { error } = await supabase
    .from("notifications_log")
    .insert(notifications);

  if (error) {
    console.error("Erro ao inserir notifications_log:", error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  // TODO: Integrar Firebase Admin SDK para envio de push real
  // const messaging = getMessaging();
  // await messaging.sendEachForMulticast({ tokens, notification: {...} });

  return new Response(
    JSON.stringify({ notified: cooperados.length }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
""")

fns_path2 = f"{FUNS}/atribuir-automatico"
os.makedirs(fns_path2, exist_ok=True)

write(f"{fns_path2}/index.ts", """import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req: Request) => {
  const { oportunidade_id, atribuido_por } = await req.json();

  if (!oportunidade_id || !atribuido_por) {
    return new Response(
      JSON.stringify({ error: "oportunidade_id e atribuido_por são obrigatórios" }),
      { status: 400 }
    );
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  // Buscar oportunidade
  const { data: oport } = await supabase
    .from("oportunidades")
    .select("id, num_vagas, criterio_selecao, cooperative_id")
    .eq("id", oportunidade_id)
    .single();

  if (!oport) {
    return new Response(JSON.stringify({ error: "Oportunidade não encontrada" }), { status: 404 });
  }

  // Buscar candidatos pendentes
  const query = supabase
    .from("candidaturas")
    .select("id, cooperado_id, cooperado:cooperados(num_cota)")
    .eq("oportunidade_id", oportunidade_id)
    .eq("status", "pendente");

  // FIFO: ordem de cadastro, Rodízio: menor num_cota (menos atribuições)
  const orderBy = oport.criterio_selecao === "rodizio"
    ? query.order("cooperado->num_cota", { ascending: true })
    : query.order("created_at", { ascending: true });

  const { data: candidatos } = await orderBy;

  if (!candidatos?.length) {
    return new Response(JSON.stringify({ error: "Nenhum candidato pendente" }), { status: 422 });
  }

  const selecionados = candidatos.slice(0, oport.num_vagas);

  // Criar atribuições e atualizar status das candidaturas selecionadas
  for (const candidato of selecionados) {
    await supabase.from("atribuicoes").insert({
      oportunidade_id,
      cooperado_id: candidato.cooperado_id,
      candidatura_id: candidato.id,
      atribuido_por,
    });
    await supabase
      .from("candidaturas")
      .update({ status: "selecionada" })
      .eq("id", candidato.id);
  }

  // Rejeitar candidatos não selecionados
  const rejeitados = candidatos.slice(oport.num_vagas);
  for (const rej of rejeitados) {
    await supabase
      .from("candidaturas")
      .update({ status: "rejeitada" })
      .eq("id", rej.id);
  }

  return new Response(
    JSON.stringify({ atribuidos: selecionados.length, rejeitados: rejeitados.length }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
""")

write(f"{FUNS}/.gitignore", """# Edge function secrets
.env
""")

# ─── CONFIGURAÇÕES EXTRAS ─────────────────────────────────────────────────────

write(f"{BASE}/supabase/seed.sql", """-- Seed para desenvolvimento local
-- Insere uma cooperativa de teste e um admin

do $$
declare
  v_cooperative_id uuid := gen_random_uuid();
  v_user_id        uuid := gen_random_uuid();
begin
  -- Cooperativa teste
  insert into cooperativas (id, nome, cnpj, plano)
  values (v_cooperative_id, 'CoopTech Regional', '12.345.678/0001-99', 'growth');

  -- Usuário admin será criado via Supabase Auth no dashboard
  -- Após criar o user no dashboard, execute:
  -- insert into cooperados (cooperative_id, user_id, nome, cpf, email, is_admin, num_cota)
  -- values ('<cooperative_id>', '<auth_user_id>', 'Admin CoopTech', '000.000.000-00', 'admin@cooptech.com', true, 1);
  raise notice 'Seed cooperativa: %', v_cooperative_id;
end;
$$;
""")

print("BATCH BACKEND DONE")
