# Frontend Summary — CoopCRM

> **Autor:** Fernanda Frontend | **Step 11** | **Data:** 2026-04-05  
> Sprint único — Greenfield Flutter

---

## Visão Geral

Aplicativo Flutter multiplataforma (iOS + Android + Web) desenvolvido em Clean Architecture. Cobertura completa dos 12 User Stories do MVP com autenticação via Supabase, estado gerenciado com flutter_bloc e navegação com go_router.

---

## Telas Implementadas

### Auth (US-01)
| Tela | Arquivo | Status |
|------|---------|--------|
| Login (email + senha) | `features/auth/presentation/pages/login_page.dart` | ✅ |

### Oportunidades (US-02 — US-08)
| Tela | Arquivo | Status |
|------|---------|--------|
| Feed com stream realtime + filtros | `features/oportunidades/presentation/pages/feed_page.dart` | ✅ |
| Detalhe + candidatura em ≤2 toques | `features/oportunidades/presentation/pages/oportunidade_detail_page.dart` | ✅ |
| Criar oportunidade (admin) | `features/oportunidades/presentation/pages/criar_oportunidade_page.dart` | ✅ |

### Comunicados (US-11)
| Tela | Arquivo | Status |
|------|---------|--------|
| Feed de comunicados + badge não-lido | `features/comunicados/presentation/pages/comunicados_page.dart` | ✅ |

### Cotas (US-10)
| Tela | Arquivo | Status |
|------|---------|--------|
| Histórico de cotas + resumo financeiro | `features/cotas/presentation/pages/cotas_page.dart` | ✅ |

### Cooperados (US-09, US-12 — admin)
| Tela | Arquivo | Status |
|------|---------|--------|
| Listagem de cooperados com busca | `features/cooperados/presentation/pages/cooperados_page.dart` | ✅ |

### Notificações (US-07, US-08)
| Tela | Arquivo | Status |
|------|---------|--------|
| Histórico de pushes recebidos | `features/notificacoes/presentation/pages/notificacoes_page.dart` | ✅ |

### Perfil (US-12)
| Tela | Arquivo | Status |
|------|---------|--------|
| Perfil + logout + ações | `features/perfil/presentation/pages/perfil_page.dart` | ✅ |

---

## Arquitetura (Clean Architecture)

```
lib/
├── core/
│   ├── di/         — get_it + injectable (código gerado)
│   ├── env/        — @Envied, SUPABASE_URL + ANON_KEY
│   ├── error/      — sealed class Failure (5 tipos)
│   ├── router/     — GoRouter ShellRoute + auth redirect
│   ├── theme/      — Material 3, design tokens, AppColors
│   └── utils/      — validators, date_utils
├── shared/
│   ├── extensions/ — context_extensions, string_extensions
│   └── widgets/    — 6 widgets compartilhados (AppScaffold, StatusChip, etc.)
├── features/
│   ├── auth/       — Clean Architecture completa (domain/data/presentation)
│   ├── oportunidades/ — idem + Realtime stream
│   ├── comunicados/ — Cubit com badge de não-lido
│   ├── cotas/      — Cubit com resumo financeiro
│   ├── cooperados/ — Listagem admin
│   ├── notificacoes/ — Histórico de pushes
│   └── perfil/     — Perfil + logout
└── l10n/           — ARB pt_BR (70+ strings)
```

---

## Estado / Gerenciamento

| Feature | Padrão | Razão |
|---------|--------|-------|
| Auth | BLoC (sealed events/states) | Complexo — múltiplos estados |
| Feed de oportunidades | BLoC + Stream | Realtime subscription |
| Detalhe oportunidade | Cubit | Estado simples de load/candidatura |
| Comunicados | Cubit | Load + marcar lido |
| Cotas | Cubit | Load com agregação |

---

## Integrações

- **Supabase Auth:** email/senha via `supabase_flutter` SDK
- **Supabase Realtime:** feed de oportunidades com `.stream(primaryKey: ['id'])`
- **Supabase Storage:** campo foto_url pronto, upload não implementado neste MVP
- **Firebase FCM:** `firebase_messaging` instalado; recepção de payload do `notifications_log`

---

## Localização

- `l10n.yaml` configurado
- `lib/l10n/app_pt_BR.arb` — 70+ strings em pt-BR
- `lib/l10n/app_pt.arb` — fallback locale

---

## Análise Estática

- **Erros:** 0
- **Warnings:** 0  
- **Infos (deprecações):** 30 (todos `withOpacity` → `withValues` — não-bloqueante)
- `flutter analyze` exitcode: 0

---

## Dependências Novas (não previstas na arquitetura)
Nenhuma — todas as dependências foram do planejamento original.

---

## Pendências (pós-MVP)

- Upload de foto/avatar (campo pronto, UI não implementada)
- Tela de criação de comunicado (admin)
- Tela de editar oportunidade
- Integração FCM completa (envio de push do app — está na Edge Function)
- Dashboard admin com `get_cooperative_stats()`
