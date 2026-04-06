# Analytics Plan — CoopCRM

## North Star Metric

**Candidaturas Ativas por Mês** (CAM)  
`COUNT(candidaturas WHERE created_at >= início_do_mês AND status IN ('pendente','atribuida'))`

Justificativa: Representa a saúde do produto — cooperados engajados + oportunidades sendo preenchidas. Cresce se o app é útil e confiável.

---

## AARRR Funnel

| Etapa | Definição | Métrica-chave |
|-------|----------|---------------|
| **Acquisition** | Cooperado criado no sistema | `cooperados.created_at` diário |
| **Activation** | Primeiro login com sessão persistida | `auth.sessions` first_session_at |
| **Retention** | Retorno ao app em 7 e 30 dias | DAU/WAU rolling window |
| **Revenue** | Cooperativa em plano pago (`plano != 'free'`) | `cooperativas.plano` |
| **Referral** | Nova cooperativa criada via indicação (pós-MVP) | parâmetro UTM na landing |

---

## Eventos Firebase Analytics

### Auth

| Evento | Quando | Propriedades |
|--------|--------|-------------|
| `login_success` | Após autenticação bem-sucedida | `cooperative_id` |
| `logout` | Ao pressionar "Sair" | `cooperative_id` |
| `login_error` | Falha de autenticação | `error_code` |

### Feed de Oportunidades

| Evento | Quando | Propriedades |
|--------|--------|-------------|
| `feed_viewed` | Ao abrir a tela Feed | `cooperative_id` |
| `feed_filtered` | Ao selecionar um chip de filtro | `filter_status`, `cooperative_id` |
| `oportunidade_viewed` | Ao abrir detalhe de uma oportunidade | `oportunidade_id`, `status`, `cooperative_id` |
| `candidatura_submitted` | Ao confirmar candidatura | `oportunidade_id`, `cooperative_id` |
| `oportunidade_created` | Admin cria nova oportunidade | `oportunidade_id`, `cooperative_id` |

### Comunicados

| Evento | Quando | Propriedades |
|--------|--------|-------------|
| `comunicado_viewed` | Ao abrir detalhe | `comunicado_id`, `lido_before` |
| `comunicado_marked_read` | Ao fechar após leitura | `comunicado_id` |

### Cotas

| Evento | Quando | Propriedades |
|--------|--------|-------------|
| `cotas_viewed` | Ao abrir tela de Cotas | `cooperative_id` |

### Notificações

| Evento | Quando | Propriedades |
|--------|--------|-------------|
| `push_received` | Ao receber push (foreground) | `notification_type` |
| `push_tapped` | Ao tocar na notificação | `notification_type`, `deep_link_target` |

---

## Implementação Técnica

### Flutter — firebase_analytics

```dart
// Em oportunidade_detail_page.dart (candidatura)
FirebaseAnalytics.instance.logEvent(
  name: 'candidatura_submitted',
  parameters: {
    'oportunidade_id': widget.oportunidade.id,
    'cooperative_id': context.read<AuthBloc>().state.user!.cooperativeId,
  },
);
```

### Dashboard Supabase (SQL)

```sql
-- Candidaturas por semana
SELECT
  date_trunc('week', created_at) AS semana,
  COUNT(*) AS candidaturas
FROM candidaturas
GROUP BY 1
ORDER BY 1 DESC;

-- Taxa de atribuição (candidatura → atribuição)
SELECT
  COUNT(*) FILTER (WHERE status = 'atribuida') * 100.0 / COUNT(*) AS taxa_atribuicao
FROM candidaturas
WHERE created_at >= NOW() - INTERVAL '30 days';

-- Retenção: cooperados com login nos últimos 7 dias
SELECT COUNT(DISTINCT user_id)
FROM auth.sessions
WHERE created_at >= NOW() - INTERVAL '7 days';
```

---

## Metas para Validação do MVP (primeiros 30 dias)

| Métrica | Meta |
|---------|------|
| Cooperados ativos (DAU) | ≥ 60% da base cadastrada |
| Taxa de candidatura por oportunidade | ≥ 3 candidaturas/oportunidade |
| Taxa de atribuição | ≥ 80% das candidaturas resultam em atribuição |
| Comunicados lidos | ≥ 70% lidos em 24h |
| Retorno semanal (WAU/MAU) | ≥ 50% |

---

## Ferramentas

| Ferramenta | Uso |
|-----------|-----|
| Firebase Analytics | Eventos de UI (cliente Flutter) |
| Supabase Dashboard | SQL direto nas tabelas de negócio |
| Google Looker Studio | Visualização de funil (integra com Supabase via PostgreSQL connector) |

---

## Pós-MVP: Eventos a Adicionar

- `atribuicao_received` — push + evento ao ser atribuído
- `cooperativa_onboarded` — primeira oportunidade criada por admin
- `comunicado_created` — admin envia comunicado
- `cota_pagamento_viewed` — detalhe de parcela aberta
