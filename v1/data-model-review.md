# Data Modeling Review — CoopCRM

> **Revisor:** Mateus Modelagem (auto-validação Step 08)  
> **Data:** 2026-04-05 | **Status:** ✅ APROVADO — aguardando confirmação do usuário

---

## Checklist de Validação

### ✅ 1. Cobertura — Entidades vs User Stories

| US | Funcionalidade | Tabelas cobertas |
|----|---------------|-----------------|
| US-01 | Login cooperado | `cooperados` (user_id → auth.users) |
| US-02 | Feed de oportunidades | `oportunidades` |
| US-03 | Candidatura a oportunidade | `candidaturas` |
| US-04 | Criação de oportunidade (admin) | `oportunidades` |
| US-05 | Atribuição (FIFO / Rodízio / Manual) | `atribuicoes`, `candidaturas.status` |
| US-06 | Ciclo de execução e conclusão | `oportunidades.status` (machine state + trigger) |
| US-07 | Push notification nova oportunidade | `notifications_log`, `cooperados.fcm_token` |
| US-08 | Notificações in-app | `notifications_log` |
| US-09 | Cadastro de cooperados (admin) | `cooperados` |
| US-10 | Controle de cotas | `cotas_pagamentos` |
| US-11 | Comunicados e avisos | `comunicados`, `comunicado_leituras` |
| US-12 | Meu Perfil e Produção | `cooperados`, `atribuicoes`, `candidaturas` |
| US-13 | Relatórios admin | queries sobre todas as tabelas (sem tabela dedicada no MVP) |
| US-14 | Configuração da cooperativa | `cooperativas.cor_primaria`, `criterio_padrao`, `tipo_oport_label` |
| US-15 | Check-in / Check-out geolocalizado | `atribuicoes.checkin_at`, `atribuicoes.checkout_at` |
| US-16 | Convite por e-mail | Edge Function + `cooperados` (sem tabela extra — MVP) |

**Resultado:** ✅ Todas as 16 User Stories cobertas. Zero entidades faltando.

---

### ✅ 2. Consistência — Data Model vs Architecture

| Aspecto | Status | Observação |
|---------|--------|-----------|
| 8 tabelas da arquitetura presentes | ✅ | + `comunicado_leituras` adicionada (necessária para US-11) |
| Multi-tenancy via `cooperative_id` + RLS | ✅ | Todas as tabelas com `cooperative_id` têm política RLS |
| Helper functions `current_cooperative_id()` e `current_is_admin()` | ✅ | `SECURITY DEFINER` correto |
| FKs para `auth.users` via `cooperados.user_id` | ✅ | Pattern Supabase correto |
| Machine state `oportunidades.status` com trigger de validação | ✅ | 9 transições válidas definidas |
| Índices para queries críticas do feed | ✅ | `cooperative_id + status + prazo_candidatura` |
| Único por `(oportunidade_id, cooperado_id)` em candidaturas | ✅ | Previne candidatura duplicada |

**Resultado:** ✅ Consistência total com `architecture.md`.

---

### ✅ 3. Brownfield — Migrations Não-Destrutivas

> Projeto é **greenfield** — não se aplica restrição de additive-only.  
> Porém, política definida para futuras versões: migrations serão **sempre additive only** (`ALTER TABLE ADD COLUMN`).  
> Estratégia de migration com 10 arquivos sequenciais definida.

**Resultado:** ✅ Estratégia adequada.

---

### ✅ 4. Cache Strategy — TTLs Definidos

| Entidade | TTL | Invalidação |
|---------|-----|-------------|
| Feed oportunidades | Realtime (sem cache local) | Push notification |
| Minhas candidaturas | 5 min | Push de atribuição |
| Perfil do cooperado | 30 min | Atualização de dados |
| Comunicados | 1h | Abertura do app |
| Config da cooperativa | 24h | Login |

**Resultado:** ✅ TTLs definidos para todas as entidades de leitura frequente.

---

## Correções Aplicadas

Nenhuma correção necessária — modelo entregue pelo Step 07 está completo e consistente.

### Nota Adicional

A tabela `comunicado_leituras` foi incluída no modelo final (não estava no resumo inicial da arquitetura). É necessária para rastrear leitura por cooperado (US-11: "contador de lidas pelo admin").

---

## Schema Final Confirmado

**9 tabelas:**
1. `cooperativas` — tenant root
2. `cooperados` — membros vinculados ao Supabase Auth
3. `oportunidades` — core do produto, machine state com trigger
4. `candidaturas` — candidaturas com UNIQUE constraint por cooperado/oportunidade
5. `atribuicoes` — seleções com confirmação, check-in/out e avaliação
6. `comunicados` — mensagens broadcast da cooperativa
7. `comunicado_leituras` — rastreamento de leitura por cooperado
8. `cotas_pagamentos` — controle financeiro mensal
9. `notifications_log` — registro de pushes enviados e lidos

**Funções:**
- `update_updated_at()` — trigger para `oportunidades.updated_at`
- `validate_oport_status_transition()` — machine state com 9 transições válidas
- `current_cooperative_id()` — helper RLS (SECURITY DEFINER)
- `current_cooperado_id()` — helper RLS (SECURITY DEFINER)
- `current_is_admin()` — helper RLS (SECURITY DEFINER)

---

## Aguardando Aprovação do Usuário

Para avançar para os Steps 09/10 (Stack Assimilation Front/Backend), confirme:

**✅ Sim, modelo aprovado — avançar para implementação**  
❌ Ajustar antes de prosseguir
