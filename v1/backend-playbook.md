# Playbook Backend — CoopCRM

> **Autor:** Bruno Backend | **Step 10** | **Data:** 2026-04-05  
> ⚠️ Documento interno — insumo para Step 12 (implement-backend)

---

## Stack

| Tecnologia | Versão | Função |
|-----------|--------|--------|
| Supabase | Cloud / CLI 1.x | BaaS — PostgreSQL, Auth, Storage, Realtime |
| PostgreSQL | 15 | Banco relacional — RLS, triggers, functions |
| Supabase Edge Functions | Deno 1.x (TypeScript) | Lógica server-side serverless |
| Supabase Auth | — | Autenticação (email/senha + magic link) |
| PostgREST | Auto (Supabase) | REST API auto-gerada pelo schema |
| Supabase Realtime | Auto | WebSocket push via Postgres CDC |
| Supabase Storage | Auto | Upload de avatars, anexos |
| Firebase Admin SDK | npm 12.x (Deno-compatible) | Envio de pushes via FCM (dentro de Edge Fn) |
| Supabase CLI | 1.x | Migrações, dev local, deploy edge functions |

> **Nota arquitetural:** Este projeto **não tem servidor Express/NestJS/etc.** Todo o backend vive em:  
> 1. PostgreSQL (schema, RLS, triggers, helper functions)  
> 2. Supabase Edge Functions (lógica que não pode ficar no Postgres)  
> 
> O Flutter app chama diretamente o `supabase_flutter` SDK — o PostgREST expõe o schema como REST automaticamente, com RLS aplicado.

---

## Scaffold do Projeto

```bash
# Instalação do Supabase CLI (se não tiver)
npm install -g supabase

# Inicializar pasta supabase/ na raiz do projeto Flutter
supabase init

# Estrutura criada:
# supabase/
# ├── config.toml
# ├── migrations/
# └── functions/

# Dev local
supabase start          # sobe PostgreSQL + GoTrue + PostgREST + Realtime local
supabase status         # vê URLs e tokens do ambiente local

# Criar uma Edge Function
supabase functions new notify-nova-oportunidade

# Deploy de migrations
supabase db push        # aplica migrations para o projeto cloud

# Deploy de funções
supabase functions deploy notify-nova-oportunidade
```

---

## Estrutura de Pastas (supabase/)

```
supabase/
├── config.toml                         # Configuração do projeto local
│
├── migrations/
│   ├── 20260405000001_create_cooperativas.sql
│   ├── 20260405000002_create_cooperados.sql
│   ├── 20260405000003_create_oportunidades.sql
│   ├── 20260405000004_create_candidaturas_atribuicoes.sql
│   ├── 20260405000005_create_comunicados.sql
│   ├── 20260405000006_create_cotas.sql
│   ├── 20260405000007_create_notifications_log.sql
│   ├── 20260405000008_enable_rls_all_tables.sql
│   ├── 20260405000009_rls_policies.sql
│   └── 20260405000010_helper_functions.sql
│
└── functions/
    ├── _shared/
    │   ├── cors.ts                     # Headers CORS compartilhados
    │   └── supabase-admin.ts           # Supabase Admin Client (service_role)
    │
    ├── notify-nova-oportunidade/
    │   └── index.ts                    # Acionado via DB Webhook quando oport. é publicada
    │
    ├── notify-atribuicao/
    │   └── index.ts                    # Notifica cooperado selecionado
    │
    ├── atribuir-automatico/
    │   └── index.ts                    # Lógica FIFO/Rodízio (chamado pelo app admin)
    │
    ├── invite-cooperado/
    │   └── index.ts                    # Envia convite por e-mail (Supabase auth.signUp invitation)
    │
    └── send-push/
        └── index.ts                    # Helper genérico — envia FCM push
```

---

## Sistema de Migrações

### Regras
- **Sempre additive only** (sem DROP COLUMN, DROP TABLE, ALTER TYPE)
- Nomear com timestamp ISO: `YYYYMMDDHHMMSS_descricao_curta.sql`
- Testar localmente com `supabase db reset && supabase db push` antes do cloud
- Nunca editar migration existente já aplicada — criar nova migration de correção

### Padrão de migration
```sql
-- 20260405000001_create_cooperativas.sql
-- Descrição: Cria tabela base cooperativas (tenant root)

CREATE TABLE IF NOT EXISTS cooperativas (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome             TEXT NOT NULL,
  -- ... (schema completo em data-model.md)
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Rollback (apenas para dev local se necessário):
-- DROP TABLE IF EXISTS cooperativas;
```

### Sequência de migrations para CoopCRM (v1)
```
001_create_cooperativas          → tabela root, sem FK
002_create_cooperados            → FK → cooperativas + auth.users
003_create_oportunidades         → FK → cooperativas, cooperados; trigger updated_at
004_create_candidaturas_atrib    → FK → oportunidades, cooperados; machine state trigger
005_create_comunicados           → FK → cooperativas, cooperados; + comunicado_leituras
006_create_cotas                 → FK → cooperados, cooperativas
007_create_notifications_log     → FK → cooperativas, cooperados
008_enable_rls                   → ALTER TABLE ... ENABLE ROW LEVEL SECURITY
009_rls_policies                 → TODAS as políticas (cooperativas, cooperados, oport, etc.)
010_helper_functions             → current_cooperative_id(), current_cooperado_id(), current_is_admin()
```

---

## PostgREST — API Auto-Gerada

O Supabase expõe automaticamente todos os schemas com RLS aplicado. O Flutter app usa o `SupabaseClient` que chama o PostgREST internamente. Não é necessário escrever endpoints REST manualmente.

### Queries principais via PostgREST (chamadas pelo Flutter SDK)

```typescript
// Equivalências das queries Flutter → PostgREST SQL gerado

// Feed de oportunidades (Flutter):
// supabase.from('oportunidades').select().eq('status', 'aberta').order(...)
// PostgREST: GET /rest/v1/oportunidades?status=eq.aberta&order=created_at.desc

// Candidatura (Flutter):
// supabase.from('candidaturas').insert({oportunidade_id, cooperado_id})
// PostgREST: POST /rest/v1/candidaturas

// Atribuição manual (Flutter admin):
// supabase.from('atribuicoes').insert({...})
// PostgREST: POST /rest/v1/atribuicoes
```

### Joins com related tables (PostgREST syntax no Flutter)
```dart
// Flutter: oportunidade com criador
await supabase
    .from('oportunidades')
    .select('''
      *,
      criado_por:cooperados!oportunidades_criado_por_fkey(nome, foto_url)
    ''')
    .eq('status', 'aberta');

// Flutter: candidaturas com dados do cooperado
await supabase
    .from('candidaturas')
    .select('*, cooperado:cooperados(nome, foto_url, especialidades)')
    .eq('oportunidade_id', id);
```

---

## Edge Functions — Padrões

### Template base de Edge Function
```typescript
// supabase/functions/send-push/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface RequestPayload {
  cooperado_id: string
  titulo: string
  corpo: string
  referencia_id?: string
  tipo: string
}

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!   // service_role: bypass RLS
    )

    const payload: RequestPayload = await req.json()

    // Buscar FCM token do cooperado
    const { data: cooperado, error } = await supabase
      .from('cooperados')
      .select('fcm_token, nome')
      .eq('id', payload.cooperado_id)
      .single()

    if (error || !cooperado?.fcm_token) {
      return new Response(
        JSON.stringify({ error: 'FCM token não encontrado' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Enviar via FCM HTTP v1 API
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${Deno.env.get('FIREBASE_PROJECT_ID')}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${await getAccessToken()}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: cooperado.fcm_token,
            notification: { title: payload.titulo, body: payload.corpo },
            data: { tipo: payload.tipo, referencia_id: payload.referencia_id ?? '' },
          },
        }),
      }
    )

    // Log no banco
    await supabase.from('notifications_log').insert({
      cooperado_id: payload.cooperado_id,
      tipo: payload.tipo,
      titulo: payload.titulo,
      corpo: payload.corpo,
      referencia_id: payload.referencia_id,
      enviado: fcmResponse.ok,
      enviado_em: new Date().toISOString(),
    })

    return new Response(
      JSON.stringify({ success: fcmResponse.ok }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
```

### _shared/cors.ts
```typescript
// supabase/functions/_shared/cors.ts
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',   // Em prod: restringir ao domínio do app
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```

### _shared/supabase-admin.ts
```typescript
// supabase/functions/_shared/supabase-admin.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

export const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)
```

---

## Edge Function: notify-nova-oportunidade

Acionada via **Database Webhook** quando `oportunidades.status` muda de `'rascunho'` para `'aberta'`.

```typescript
// supabase/functions/notify-nova-oportunidade/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { supabaseAdmin } from '../_shared/supabase-admin.ts'
import { corsHeaders } from '../_shared/cors.ts'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const { record } = await req.json()  // new record from DB Webhook
  const oportunidade = record

  // Buscar todos cooperados ativos da cooperativa
  const { data: cooperados } = await supabaseAdmin
    .from('cooperados')
    .select('id, fcm_token')
    .eq('cooperative_id', oportunidade.cooperative_id)
    .eq('status', 'ativo')
    .not('fcm_token', 'is', null)

  if (!cooperados?.length) {
    return new Response(JSON.stringify({ sent: 0 }), { headers: corsHeaders })
  }

  // Disparar send-push para cada cooperado (em paralelo)
  const results = await Promise.allSettled(
    cooperados.map((c) =>
      fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/send-push`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
        },
        body: JSON.stringify({
          cooperado_id: c.id,
          titulo: `Nova oportunidade: ${oportunidade.titulo}`,
          corpo: oportunidade.tipo,
          referencia_id: oportunidade.id,
          tipo: 'nova_oportunidade',
        }),
      })
    )
  )

  const sent = results.filter((r) => r.status === 'fulfilled').length
  return new Response(JSON.stringify({ sent }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  })
})
```

### Configurar o Database Webhook (Supabase Dashboard)
```
Tabela: oportunidades
Evento: UPDATE
Condição: NEW.status = 'aberta' AND OLD.status = 'rascunho'
URL: https://{project}.supabase.co/functions/v1/notify-nova-oportunidade
```

---

## Edge Function: atribuir-automatico (FIFO / Rodízio)

Chamada pelo app admin quando seleciona o modo automático.

```typescript
// supabase/functions/atribuir-automatico/index.ts

type Criterio = 'fifo' | 'rodizio'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const { oportunidade_id, criterio, atribuido_por }: {
    oportunidade_id: string
    criterio: Criterio
    atribuido_por: string
  } = await req.json()

  // Buscar candidatos aguardando
  const { data: candidatos } = await supabaseAdmin
    .from('candidaturas')
    .select('id, cooperado_id, created_at')
    .eq('oportunidade_id', oportunidade_id)
    .eq('status', 'aguardando')
    .order('created_at', { ascending: true })  // FIFO por padrão

  if (!candidatos?.length) {
    return new Response(JSON.stringify({ error: 'Nenhum candidato' }), { status: 400 })
  }

  // Buscar vagas disponíveis
  const { data: oportunidade } = await supabaseAdmin
    .from('oportunidades')
    .select('num_vagas, cooperative_id')
    .eq('id', oportunidade_id)
    .single()

  const numVagas = oportunidade!.num_vagas

  let selecionados: typeof candidatos

  if (criterio === 'fifo') {
    // Primeiros a se candidatar ganham as vagas
    selecionados = candidatos.slice(0, numVagas)
  } else {
    // Rodízio: selecionar cooperados com menor nº de atribuições recentes
    const { data: historico } = await supabaseAdmin
      .from('atribuicoes')
      .select('cooperado_id')
      .eq('oportunidade_id', oportunidade_id)      // Este campo não existe — usar cooperative_id
      // Na prática: contar últimas 30 atribuições por cooperado

    // Ordenar candidatos por score de rodízio (menor hist = prioridade)
    selecionados = candidatos.slice(0, numVagas)   // simplificado; lógica completa no impl
  }

  // Criar atribuições em batch
  const atribuicoes = selecionados.map((c) => ({
    oportunidade_id,
    cooperado_id: c.cooperado_id,
    candidatura_id: c.id,
    atribuido_por,
  }))

  await supabaseAdmin.from('atribuicoes').insert(atribuicoes)

  // Atualizar status das candidaturas
  const idsSelecionados = selecionados.map((c) => c.id)
  await supabaseAdmin
    .from('candidaturas')
    .update({ status: 'selecionado' })
    .in('id', idsSelecionados)

  const idsNaoSelecionados = candidatos
    .filter((c) => !idsSelecionados.includes(c.id))
    .map((c) => c.id)

  if (idsNaoSelecionados.length > 0) {
    await supabaseAdmin
      .from('candidaturas')
      .update({ status: 'nao_selecionado' })
      .in('id', idsNaoSelecionados)
  }

  // Atualizar status da oportunidade
  await supabaseAdmin
    .from('oportunidades')
    .update({ status: 'atribuida' })
    .eq('id', oportunidade_id)

  return new Response(
    JSON.stringify({ atribuidos: selecionados.length }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
})
```

---

## RLS — Padrões de Segurança

### Princípios
1. **Default DENY** — RLS habilitado em todas as tabelas; sem política = sem acesso
2. **Helper functions SECURITY DEFINER** — evitam recursão infinita ao consultar `cooperados`
3. **Service Role Key apenas em Edge Functions** — nunca expor no cliente Flutter
4. **Anon Key no Flutter** — JWT é inspecionado pelo PostgREST; RLS filtra automaticamente

### Auditoria de Segurança
```sql
-- Verificar que RLS está ativo em todas as tabelas
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
-- Todas devem ter rowsecurity = true

-- Listar todas as políticas
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;
```

### Proteção contra SQL Injection
- PostgREST usa sempre **parameterized queries** automaticamente
- Edge Functions usam o SDK `@supabase/supabase-js` que parametriza queries
- Validação de inputs: verificar tipos no TypeScript antes de chamar o DB

---

## Auth — Supabase Auth estratégia

```
Admin da cooperativa:
  → Criado via Supabase Dashboard ou Edge Function (invite-cooperado)
  → Email/Senha
  → cooperados.is_admin = TRUE

Cooperado comum:
  → Convite por e-mail gerado pelo admin
  → Magic Link (email OTP) — mais simples, sem precisar lembrar senha
  → cooperados.is_admin = FALSE

Fluxo de conviite:
  1. Admin chama Edge Function invite-cooperado com { email, nome, cpf }
  2. Edge Function: auth.admin.inviteUserByEmail(email, { data: { cooperative_id, nome, cpf } })
  3. Supabase envia e-mail pré-formatado com link de aceitação
  4. Ao aceitar: Supabase chama DB Trigger → insere em cooperados com user_id
```

### DB Trigger — Criar cooperado após auth.users (convite)
```sql
-- Trigger que cria cooperado na tabela cooperados quando usuário aceita convite
CREATE OR REPLACE FUNCTION handle_new_user_from_invite()
RETURNS TRIGGER AS $$
BEGIN
  -- Só age se o usuário foi criado via convite com raw_app_meta_data
  IF NEW.raw_user_meta_data->>'cooperative_id' IS NOT NULL THEN
    INSERT INTO cooperados (user_id, cooperative_id, nome, email, cpf, status)
    VALUES (
      NEW.id,
      (NEW.raw_user_meta_data->>'cooperative_id')::UUID,
      NEW.raw_user_meta_data->>'nome',
      NEW.email,
      NEW.raw_user_meta_data->>'cpf',
      'ativo'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user_from_invite();
```

---

## Variáveis de Ambiente — Edge Functions

```bash
# Configurar secrets no projeto Supabase Cloud
supabase secrets set FIREBASE_PROJECT_ID=coopcrm-xyz
supabase secrets set FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account",...}'

# Variáveis automáticas (Supabase injeta automaticamente):
# SUPABASE_URL
# SUPABASE_ANON_KEY
# SUPABASE_SERVICE_ROLE_KEY
```

`.env.local` para desenvolvimento (gitignored):
```
SUPABASE_URL=http://localhost:54321
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...  # do supabase status
FIREBASE_PROJECT_ID=coopcrm-xyz
```

---

## Storage — Buckets e Políticas

```sql
-- Criar buckets via SQL migration
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('avatars', 'avatars', true),       -- fotos de perfil são públicas
  ('comunicados', 'comunicados', false); -- anexos privados

-- Policy: cooperado pode fazer upload apenas na sua pasta
CREATE POLICY "avatar_upload_own" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = 'cooperados' AND
    (storage.foldername(name))[2] = auth.uid()::text
  );

-- Policy: qualquer um autenticado pode ler avatars públicos
CREATE POLICY "avatar_read_public" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

-- Policy: apenas admin da coop pode fazer upload de anexos de comunicado
CREATE POLICY "comunicado_upload_admin" ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'comunicados' AND current_is_admin());
```

---

## Realtime — Configuração

```sql
-- Habilitar Realtime nas tabelas de alta frequência
-- (via Supabase Dashboard > Database > Replication OU via SQL)
ALTER PUBLICATION supabase_realtime ADD TABLE oportunidades;
ALTER PUBLICATION supabase_realtime ADD TABLE candidaturas;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications_log;
ALTER PUBLICATION supabase_realtime ADD TABLE comunicados;
```

> **Nota de performance:** Não habilitar Realtime em tabelas de baixa utilização (cooperativas, cooperados, cotas_pagamentos) para não gerar tráfego desnecessário.

---

## Padrão de Resposta de Edge Function

### Sucesso
```json
{ "success": true, "data": { ... } }
```

### Erro
```json
{ "success": false, "error": "Mensagem legível pelo log" }
```

### HTTP Status Codes
| Situação | Status |
|---------|--------|
| Sucesso | 200 |
| Criado | 201 |
| Bad Request (input inválido) | 400 |
| Não autenticado | 401 |
| Não autorizado (RLS) | 403 |
| Não encontrado | 404 |
| Erro interno | 500 |

---

## Deploy Pipeline

```bash
# 1. Rodar migrations no ambiente local
supabase db reset    # reseta o banco local com todas as migrations
supabase db push     # aplica migrations no projeto cloud

# 2. Deploy de uma function específica
supabase functions deploy notify-nova-oportunidade --no-verify-jwt
# --no-verify-jwt apenas para webhooks do próprio Supabase

# 3. Deploy de todas as functions
supabase functions deploy

# 4. Verificar logs de uma function
supabase functions inspect notify-nova-oportunidade --tail
```

---

## Checklist de Assimilação

- [x] Supabase CLI — `supabase init`, `start`, `db push`, `functions deploy`
- [x] PostgREST — queries, joins com foreign key hints, filters
- [x] RLS — ENABLE ROW LEVEL SECURITY, políticas por role, SECURITY DEFINER functions
- [x] Edge Functions — Deno TypeScript, serve(), req.json(), corsHeaders, env vars
- [x] Supabase Auth — email/senha, magic link, admin.inviteUserByEmail()
- [x] DB Triggers — AFTER INSERT/UPDATE, validação de machine state
- [x] Database Webhooks — trigger functions via HTTP (notify-nova-oportunidade)
- [x] Storage — buckets, policies por folder/auth.uid()
- [x] Realtime — supabase_realtime publication, stream() no Flutter
- [x] FCM via Edge Function — HTTP v1 API, access token, notifications_log
- [x] Service Role Key — apenas em Edge Functions, nunca no cliente
