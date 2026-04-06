# Backend Summary — CoopCRM

> **Autor:** Bruno Backend | **Step 12** | **Data:** 2026-04-05  
> Supabase (PostgreSQL 15 + Auth + Realtime + Edge Functions)

---

## Visão Geral

Backend 100% Supabase — sem servidor dedicado. Toda a lógica de negócio está distribuída entre:
1. **PostgreSQL** — schema, RLS, triggers, helper functions
2. **Supabase Edge Functions** — lógica que requer orquestração (notificações, atribuição automática)
3. **PostgREST** — REST API auto-gerada com RLS aplicado automaticamente

---

## Schema de Banco — 9 Tabelas

| Tabela | Descrição | RLS |
|--------|-----------|-----|
| `cooperativas` | Tenants (multi-tenancy root) | ✅ |
| `cooperados` | Membros + vínculo auth.users | ✅ |
| `oportunidades` | Oportunidades de trabalho + machine state | ✅ |
| `candidaturas` | Candidaturas únicas por cooperado | ✅ |
| `atribuicoes` | Resultado da seleção | ✅ |
| `comunicados` | Feed interno da cooperativa | ✅ |
| `comunicado_leituras` | Controle badge não-lido | ✅ |
| `cotas_pagamentos` | Cotas mensais por cooperado | ✅ |
| `notifications_log` | Histórico de pushes enviados | ✅ |

---

## Migrations (10 arquivos)

| Arquivo | Conteúdo |
|---------|----------|
| `000001_create_cooperativas.sql` | Tabela cooperativas + trigger updated_at |
| `000002_create_cooperados.sql` | Tabela cooperados + índices |
| `000003_create_oportunidades.sql` | Tabela + enums + trigger expire + trigger updated_at |
| `000004_create_candidaturas_atribuicoes.sql` | Candidaturas + Atribuições + trigger on_atribuicao_created |
| `000005_create_comunicados.sql` | Comunicados + comunicado_leituras |
| `000006_create_cotas.sql` | Cotas + enum cota_status |
| `000007_create_notifications_log.sql` | Log de notificações push |
| `000008_enable_rls_all_tables.sql` | ALTER TABLE ... ENABLE ROW LEVEL SECURITY |
| `000009_rls_policies.sql` | 15 políticas RLS + helpers `current_cooperative_id()` e `is_admin()` |
| `000010_helper_functions.sql` | `get_cooperative_stats()` + `gerar_cotas_mensais()` |

---

## Políticas RLS Implementadas

### Padrões aplicados
- Cooperados **só veem dados da própria cooperativa** (via `current_cooperative_id()`)
- Cooperados só acessam **seus próprios** dados sensíveis (cotas, perfil, candidaturas)
- Admin (is_admin = true) tem acesso expandido para gestão

### Helpers PostgreSQL
```sql
-- Retorna cooperative_id do usuário logado
current_cooperative_id() → uuid

-- Verifica se o usuário logado é admin
is_admin() → boolean
```

---

## Edge Functions

### `notify-nova-oportunidade/index.ts`
- **Trigger:** Webhook quando oportunidade.status → 'aberta'
- **Ação:** Insere `notifications_log` para todos os cooperados ativos da cooperativa
- **TODO pós-MVP:** Integrar Firebase Admin SDK para envio de push FCM real

### `atribuir-automatico/index.ts`
- **Input:** `{ oportunidade_id, atribuido_por }`
- **Lógica:**
  - FIFO → seleciona candidatos por `created_at ASC`
  - Rodízio → seleciona por `num_cota ASC` (menos atribuições históricas)
  - Manual → não usa esta function (admin escolhe via UI)
- **Saída:** Cria `atribuicoes` + atualiza status das `candidaturas`

---

## Realtime

- Publicação automática via Supabase Realtime (CDC do PostgreSQL)
- Flutter usa `.stream(primaryKey: ['id'])` no feed de oportunidades
- Configuração: nenhuma — Supabase Realtime é auto-habilitado para tabelas com RLS

---

## Autenticação

| Tipo de usuário | Método |
|-----------------|--------|
| Cooperado | Email + senha (UI de login no app) |
| Admin | Email + senha (mesmo login) |
| Convite | Magic Link via Supabase Auth (pós-MVP) |

---

## Storage

- Buckets planejados: `avatars` (public), `anexos` (private)
- Não configurados neste MVP (campo `foto_url` armazena URL externa)

---

## Variáveis de Ambiente necessárias

| Variável | Onde usar |
|----------|-----------|
| `SUPABASE_URL` | App Flutter (`.env`) |
| `SUPABASE_ANON_KEY` | App Flutter (`.env`) |
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Functions (Supabase CLI secrets) |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Edge Functions (pós-MVP para FCM) |

---

## Deploy

```bash
# Aplicar migrations para o projeto na nuvem
supabase db push --project-ref <PROJECT_REF>

# Deploy das Edge Functions
supabase functions deploy notify-nova-oportunidade --project-ref <PROJECT_REF>
supabase functions deploy atribuir-automatico --project-ref <PROJECT_REF>

# Configurar secrets das Edge Functions
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<value> --project-ref <PROJECT_REF>
```

---

## Pendências (pós-MVP)

- Configurar webhook no Supabase Dashboard para `notify-nova-oportunidade`
- Integrar Firebase Admin SDK na Edge Function (envio push real)
- Configurar buckets de Storage com políticas de acesso
- Implementar Magic Link para convite de novos cooperados
- Automatizar geração de cotas mensais via `pg_cron`
