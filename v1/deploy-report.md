# Deploy Report — CoopCRM

**Data:** 2026-04-06  
**Agente:** Roberto Release (devops)  
**Run ID:** 2026-04-05-223053  
**Autorização:** ✅ AUTORIZADO — `v1/deploy-authorization.md`

---

## Status Geral

| Etapa | Status | Notas |
|-------|--------|-------|
| Verificação de autorização | ✅ | deploy-authorization.md com status AUTORIZADO |
| Backend — Migrations | ✅ PRONTO | 10 arquivos SQL em `supabase/migrations/` |
| Backend — Edge Functions | ✅ PRONTO | 2 funções em `supabase/functions/` |
| Frontend — Código | ✅ PRONTO | 0 errors, 0 warnings no flutter analyze |
| CI/CD — Workflow | ✅ PRONTO | `.github/workflows/ci.yml` criado |
| Documentação | ✅ PRONTO | README + DEVELOPMENT + DEPLOYMENT |

---

## Repositório

**URL:** https://github.com/efemoreira/coopcrm  
**Branch de deploy:** `main`  
**Ambiente:** Produção

---

## Instruções de Deploy — Passo a Passo

### Etapa 1 — Push do código

```bash
cd coopcrm
git init
git remote add origin https://github.com/efemoreira/coopcrm.git
git add .
git commit -m "feat: CoopCRM MVP inicial"
git push -u origin main
```

### Etapa 2 — Supabase Cloud

```bash
# Criar projeto em https://app.supabase.com (região sa-east-1)
# Depois linkar e subir:
supabase link --project-ref <PROJECT_REF>
supabase db push --project-ref <PROJECT_REF>

# Deploy Edge Functions
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<value> --project-ref <PROJECT_REF>
supabase functions deploy notify-nova-oportunidade --project-ref <PROJECT_REF>
supabase functions deploy atribuir-automatico --project-ref <PROJECT_REF>
```

### Etapa 3 — GitHub Secrets

No repositório https://github.com/efemoreira/coopcrm → Settings → Secrets:

| Secret | Valor |
|--------|-------|
| `SUPABASE_URL` | URL do projeto Supabase Cloud |
| `SUPABASE_ANON_KEY` | Anon Key do projeto Supabase Cloud |

### Etapa 4 — Ativar CI/CD

Com o push para `main`, o GitHub Actions executa automaticamente:
1. `flutter analyze` — lint
2. `flutter test` — testes
3. `flutter build web --release` — build web

---

## Pipeline CI/CD

**Arquivo:** `.github/workflows/ci.yml`  
**Triggers:** push para `main`, pull requests para `main`  
**Jobs:**
- `quality` — lint + test (todas as branches)
- `build-web` — build web release (apenas `main`)

**Para ativar o deploy automático na web:**  
Descomentar o step `FirebaseExtended/action-hosting-deploy@v0` no `ci.yml` e configurar o Firebase project ID.

---

## Variáveis de Ambiente Verificadas

| Variável | Presente no .env.example | Presente no GitHub Secrets |
|----------|-------------------------|---------------------------|
| `SUPABASE_URL` | ✅ | A configurar |
| `SUPABASE_ANON_KEY` | ✅ | A configurar |

> `SUPABASE_SERVICE_ROLE_KEY` — configurado via `supabase secrets set` (nunca no repositório)

---

## Entregáveis Finais

| Arquivo | Descrição |
|---------|-----------|
| `README.md` | Visão geral + instalação rápida |
| `DEVELOPMENT.md` | Setup local detalhado |
| `DEPLOYMENT.md` | Deploy, CI/CD, rollback, monitoramento |
| `.github/workflows/ci.yml` | Pipeline GitHub Actions pronto |
| `supabase/migrations/` | 10 migrations PostgreSQL |
| `supabase/functions/` | 2 Edge Functions Deno |
| `v1/deploy-authorization.md` | Autorização formal de deploy |
| `v1/analytics-plan.md` | North Star Metric + eventos Firebase |
| `v1/learning-loop.md` | Aprendizados do projeto |

---

## Rollback

**Banco:** Criar migration reversa + `supabase db push`  
**App:** `git revert HEAD && git push origin main` → CI/CD redeploy automático  
**Mobile:** Rollback na Google Play Console / App Store Connect

---

## Próximos Passos (Pós-MVP)

1. Criar conta em https://app.supabase.com e criar projeto `coopcrm-prod`
2. Executar as etapas 1-4 acima para o primeiro deploy
3. Criar primeiro cooperado admin via SQL Editor (ver `DEVELOPMENT.md` §11)
4. Configurar Firebase para push notifications (FCM Admin SDK na Edge Function)
5. Implementar UI admin para criação de comunicados e atribuição manual

---

**Deploy Report gerado por:** Roberto Release  
**Status:** ✅ PRONTO PARA DEPLOY
