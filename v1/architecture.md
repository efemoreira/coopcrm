# Arquitetura do Sistema — CoopCRM

> **Criado por:** Arquiteto  
> **Data:** 2026-04-05 | **Versão:** 1.0  
> **Status:** AGUARDANDO APROVAÇÃO DO USUÁRIO (Step 06 — Checkpoint)

---

## Modo

**Greenfield** — aplicação nova sem codebase existente. Desenvolvedor solo (Felipe Moreira), budget MVP R$500 para infraestrutura, mercado brasileiro, plataformas obrigatórias: iOS + Android (app cooperado) + Web admin (gestor).

---

## Análise de Restrições

| Restrição | Impacto na Arquitetura |
|-----------|----------------------|
| Solo developer | Evitar dois codebases separados; preferir máximo reuso de código |
| Budget R$500 | Infra free tier no MVP; zero custo de servidor próprio |
| iOS + Android + Web admin | Cross-platform obrigatório |
| Multi-tenancy | BaaS com RLS nativo é vantagem decisiva |
| Push notifications | FCM é nativo e gratuito; precisa de integração no framework |
| Realtime (candidaturas, status) | BaaS com realtime nativo elimina WebSocket custom |
| pt-BR, CPF, moeda R$ | Ecossistema com bom suporte a i18n e localização brasileira |
| Tempo de entrega: ~8 semanas | Scaffold automático, BaaS out-of-box > backend custom |

---

## Opções de Stack Analisadas

### Opção A — Flutter + Supabase (Full-Flutter)

| Camada | Tecnologia |
|--------|-----------|
| Mobile (cooperado) | Flutter 3.x — iOS + Android |
| Web admin | Flutter Web |
| BaaS | Supabase (Postgres + Auth + Realtime + Storage + Edge Functions) |
| Push | Firebase Cloud Messaging (FCM) |
| Deploy | Supabase Free/Pro + Firebase Free + Vercel/Firebase Hosting |

**✅ Vantagens:**
- **Codebase único:** mesma linguagem (Dart), mesmos widgets, mesma lógica de negócio — mobile e web com ~80% de compartilhamento
- **Supabase** cobre auth, banco relacional, realtime, storage e edge functions — zero servidor custom
- `supabase_flutter` é o pacote oficial e bem mantido
- Clean Architecture em Flutter está extremamente consolidada no mercado — referências abundantes no GitHub
- RLS nativo no Supabase = multi-tenancy out-of-the-box por `cooperative_id`
- Realtime de candidaturas via `supabase.from('oportunidades').stream()` — nativo, sem WebSocket custom
- Felipe tem stack validada pelo próprio plano de produto (risco baixo, já pensou os trade-offs)

**❌ Desvantagens:**
- **Flutter Web para admin** não é tão maduro quanto React/Next.js para interfaces de dashboard (performance em navegadores, SEO negligenciável para painel interno)
- Dart tem ecosistema menor que TypeScript — menos bibliotecas de nicho
- Curva de aprendizado se Felipe não tiver experiência com Flutter
- Testes de Flutter Web ainda têm limitações em alguns cenários

---

### Opção B — Expo (React Native) + Next.js + Supabase

| Camada | Tecnologia |
|--------|-----------|
| Mobile (cooperado) | Expo (React Native) — iOS + Android |
| Web admin | Next.js 15 (App Router) + TypeScript + Tailwind |
| BaaS | Supabase |
| Push | Expo Push Notifications (via FCM/APNs) |
| Deploy | Supabase + Expo EAS (build mobile) + Vercel (admin web) |

**✅ Vantagens:**
- TypeScript em tudo — Felipe já tem experiência (waclient, projetos web)
- Next.js admin é muito mais maduro para dashboards complexos (tabelas, gráficos, filtros)
- Expo simplifica build iOS/Android sem Mac obrigatório (via EAS Cloud)
- Ecossistema React Native tem mais bibliotecas de componentes UI (ex: React Native Paper, Nativewind)
- `@supabase/supabase-js` é o SDK mais maduro e documentado

**❌ Desvantagens:**
- **Dois codebases** (Expo + Next.js) — duplicação de lógica de negócio, tipos, validações
- Expo Push Notifications adiciona intermediário (Expo servidor) em vez de FCM direto
- Gerenciar duas estruturas de projeto aumenta overhead para desenvolvedor solo
- EAS Build tem custo a partir do terceiro build por mês no plano gratuito

---

### Opção C — React Native (Bare) + Next.js + Supabase

Mesma que B, mas sem Expo managed — React Native CLI puro.

**✅ Vantagens:** Controle total do código nativo, acesso a FCM diretamente.  
**❌ Desvantagens:** Mais setup inicial (Android SDK, Xcode configs), setup de ambiente mais complexo para solo dev. **Descartada** — complexidade desnecessária para MVP.

---

## Stack Recomendada — Opção A: Flutter + Supabase

**Fundamento da escolha:** A restrição de solo developer é decisiva. Com Flutter, um único codebase cobre iOS, Android e Web Admin. O custo operacional (Supabase Free + Firebase Free) é zero até o primeiro cliente pagante. A Clean Architecture em Flutter tem referências abundantes e o ecossistema já tem os pacotes necessários para todos os requisitos.

| Camada | Tecnologia | Versão | Justificativa |
|--------|-----------|--------|---------------|
| **Mobile App** | Flutter (iOS + Android) | 3.27+ | Cross-platform nativo, hot reload, excelente DX |
| **Web Admin** | Flutter Web | 3.27+ | Mesmo codebase; painel interno (sem SEO), responsivo |
| **BaaS — DB** | Supabase PostgreSQL | 15 | Relacional, RLS nativo, migrações via CLI |
| **BaaS — Auth** | Supabase Auth | — | JWT + refresh token, convite por e-mail, OAuth |
| **BaaS — Realtime** | Supabase Realtime | — | WebSocket gerenciado, oportunidades em tempo real |
| **BaaS — Storage** | Supabase Storage | — | Logos, fotos de cooperados, anexos de comunicados |
| **BaaS — Edge Functions** | Supabase Edge Functions (Deno) | — | Push FCM, lógica de inadimplência, webhooks |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | v1 API | Gratuito, iOS + Android, chamdas via Edge Function |
| **State Management** | flutter_bloc | 8.x | BLoC pattern, testável, padrão do mercado Flutter |
| **Navegação** | go_router | 14.x | Declarativo, suporte a deep links e push notification routing |
| **Localização** | intl | 0.19+ | pt-BR nativo, formatação de data/moeda/CPF |
| **Deploy — BaaS** | Supabase Cloud | Free/Pro | Free tier: 500MB DB, 50MB bandwidth/dia — suficiente para MVP |
| **Deploy — Web admin** | Vercel | Free | CDN global, deploy automático via Git |
| **Deploy — Mobile** | Apple Store + Google Play | — | App Store ($99/ano), Play ($25 único) |
| **CI/CD** | GitHub Actions | — | Build + test gratuito para repos públicos/privados |

---

## Arquitetura de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                    COOPERADO (Flutter Mobile)                     │
│  [Login] → [Feed Oportunidades] → [Candidatura] → [Perfil]      │
└──────────────────────┬──────────────────────────────────────────┘
                       │ supabase_flutter SDK (HTTPS + WebSocket)
┌──────────────────────▼──────────────────────────────────────────┐
│                    SUPABASE (BaaS)                                │
│                                                                   │
│  ┌─────────────┐  ┌───────────┐  ┌──────────┐  ┌────────────┐ │
│  │  PostgreSQL  │  │   Auth    │  │ Realtime  │  │  Storage   │ │
│  │  (8 tabelas) │  │ (JWT+RLS) │  │ WebSocket │  │  (logos)   │ │
│  └─────────────┘  └───────────┘  └──────────┘  └────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │               Edge Functions (Deno/TypeScript)            │    │
│  │  notify-nova-oportunidade | notify-atribuicao             │    │
│  │  check-inadimplencia | notify-cota-vencida                │    │
│  └─────────────────────────┬───────────────────────────────┘    │
└────────────────────────────┼────────────────────────────────────┘
                             │ FCM API
┌────────────────────────────▼────────────────────────────────────┐
│               FIREBASE CLOUD MESSAGING (FCM)                      │
│         Push para iOS + Android (mesmo com app fechado)          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    ADMIN (Flutter Web — Vercel)                    │
│  [Dashboard] → [Quadro] → [Cooperados] → [Relatórios]           │
└──────────────────────┬──────────────────────────────────────────┘
                       │ supabase_flutter SDK (HTTPS)
```

---

## Estrutura de Diretórios (Clean Architecture por Feature)

```
coopcrm/
├── lib/
│   ├── main.dart                          # entry point
│   ├── app.dart                           # MaterialApp + GoRouter
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # strings globais, timeouts
│   │   │   └── status_constants.dart      # enums de status
│   │   ├── errors/
│   │   │   ├── failures.dart              # sealed classes de falha
│   │   │   └── exceptions.dart            # exceções do data layer
│   │   ├── extensions/
│   │   │   ├── datetime_ext.dart          # formatação pt-BR
│   │   │   └── string_ext.dart            # CPF mask, validação
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter — todas as rotas
│   │   ├── services/
│   │   │   ├── supabase_service.dart      # inicialização Supabase
│   │   │   └── notification_service.dart  # FCM setup, foreground handler
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # ThemeData com tokens
│   │   │   ├── app_colors.dart            # todos os tokens de cor
│   │   │   └── app_typography.dart        # todos os tokens de tipografia
│   │   └── widgets/
│   │       ├── status_badge.dart          # StatusBadge component
│   │       ├── primary_button.dart        # PrimeiroCTA component
│   │       ├── empty_state.dart           # EmptyStateFeed
│   │       └── loading_overlay.dart       # loading full-screen
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_supabase_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── app_user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in.dart
│   │   │   │       ├── sign_out.dart
│   │   │   │       └── reset_password.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── login_screen.dart
│   │   │       └── bloc/
│   │   │           ├── auth_bloc.dart
│   │   │           ├── auth_event.dart
│   │   │           └── auth_state.dart
│   │   │
│   │   ├── oportunidades/              # CORE FEATURE
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── oportunidade_supabase_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── oportunidade_model.dart
│   │   │   │   │   └── candidatura_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── oportunidade_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── oportunidade.dart
│   │   │   │   │   └── candidatura.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── oportunidade_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── listar_oportunidades.dart
│   │   │   │       ├── criar_oportunidade.dart
│   │   │   │       ├── candidatar_se.dart
│   │   │   │       ├── atribuir_oportunidade.dart
│   │   │   │       └── concluir_oportunidade.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── oportunidades_feed_screen.dart
│   │   │       │   ├── oportunidade_detalhe_screen.dart
│   │   │       │   └── nova_oportunidade_screen.dart  # admin
│   │   │       ├── widgets/
│   │   │       │   ├── oportunidade_card.dart
│   │   │       │   └── candidatos_list.dart
│   │   │       └── bloc/
│   │   │           ├── oportunidades_bloc.dart
│   │   │           ├── oportunidades_event.dart
│   │   │           └── oportunidades_state.dart
│   │   │
│   │   ├── candidaturas/
│   │   ├── cooperados/
│   │   ├── comunicados/
│   │   ├── cotas/
│   │   ├── relatorios/
│   │   └── config/
│   │
│   └── l10n/
│       ├── app_pt.arb                 # strings pt-BR
│       ├── app_en.arb                 # strings en-US
│       └── app_es.arb                 # strings es-ES
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_create_tables.sql      # todas as 8 tabelas
│   │   └── 002_rls_policies.sql       # todas as políticas RLS
│   └── functions/
│       ├── notify-nova-oportunidade/
│       │   └── index.ts
│       ├── notify-atribuicao/
│       │   └── index.ts
│       └── notify-cota-vencida/
│           └── index.ts
│
├── test/
│   ├── unit/                          # testes de usecases e entities
│   ├── widget/                        # testes de componentes Flutter
│   └── integration/                   # testes de fluxo completo
│
├── pubspec.yaml
├── firebase.json
├── .github/
│   └── workflows/
│       └── ci.yml                     # lint + test no PR
└── README.md
```

---

## Padrões de Desenvolvimento

### Nomenclatura

| Artefato | Padrão | Exemplo |
|---------|--------|---------|
| Arquivos Dart | `snake_case.dart` | `oportunidade_card.dart` |
| Classes | `PascalCase` | `OportunidadeCard` |
| Variáveis/funções | `camelCase` | `listarOportunidades` |
| Constantes | `kCamelCase` | `kSupabaseUrl` |
| Enums | `PascalCase` + valores `camelCase` | `StatusOportunidade.aberta` |
| BLoC events | `PascalCase + Event` | `CarregarOportunidadesEvent` |
| BLoC states | `PascalCase + State` + variantes | `OportunidadesLoaded`, `OportunidadesError` |
| Tabelas Supabase | `snake_case` PT-BR | `oportunidades`, `candidaturas` |
| Colunas | `snake_case` | `cooperative_id`, `criado_por` |
| Branches Git | `feat/`, `fix/`, `chore/` + kebab | `feat/quadro-oportunidades` |

### Fluxo de Dados (Clean Architecture)

```
Presentation (BLoC) → Domain (UseCase) → Domain (Repository interface) 
→ Data (RepositoryImpl) → Data (Datasource) → Supabase SDK → PostgreSQL
```

- **Domain layer:** zero dependências de framework Flutter ou Supabase. Apenas Dart puro.
- **Data layer:** mapeia `Model` → `Entity` (e vice-versa). Handles de exceção aqui.
- **Presentation layer:** escuta BLoC states, emite eventos. Sem lógica de negócio aqui.
- **Injeção de dependência:** `get_it` - registro em `service_locator.dart` na inicialização.

### Autenticação e Roles

```
Supabase Auth → auth.users → raw_app_meta_data.role
  'admin'    → redireciona para painel web (routes admin-only)
  'cooperado' → redireciona para app mobile (routes cooperado-only)
```

- Roles definidos no `raw_app_meta_data` via Service Role Key (somente backend/edge function)
- Admin criado manualmente no Supabase Studio ou via CLI no onboarding
- Cooperado criado pelo admin no painel, recebe convite por e-mail via `supabase.auth.admin.inviteUserByEmail`
- Guard de rota no GoRouter verifica `appUser.role` antes de renderizar qualquer tela

### Multi-Tenancy (RLS Strategy)

```sql
-- Função helper — usada em todas as policies
CREATE FUNCTION current_cooperative_id()
RETURNS UUID AS $$
  SELECT cooperative_id FROM cooperados WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- Toda SELECT em tabelas sensíveis filtra automaticamente:
WHERE cooperative_id = current_cooperative_id()
```

- **Nenhuma query** no app pode omitir o filtro de `cooperative_id` — o RLS garante isso no nível do banco
- Admin e cooperado são da mesma cooperativa — `current_cooperative_id()` retorna o mesmo valor para ambos
- Testado sempre via: "logar como cooperado_A e tentar buscar dados de cooperative_B → deve retornar array vazio"

### Tratamento de Erros

```
Supabase SDK Exception
    ↓ Datasource captura → lança typed Exception (ex: DuplicateCandidaturaException)
    ↓ RepositoryImpl captura → retorna Either<Failure, T> (using dartz or fpdart)
    ↓ UseCase propaga Either
    ↓ BLoC mapeia para ErrorState com mensagem do UX Content (i18n key)
    ↓ UI exibe SnackBar ou ErrorWidget com texto humanizado
```

**Nunca** exibir mensagens de erro técnicas ao usuário (ex: `PGRST116`, `null check operator`).

### Push Notifications — Fluxo

```
Admin publica oportunidade
   ↓ INSERT em oportunidades (Supabase)
   ↓ Trigger PostgreSQL → chama Edge Function notify-nova-oportunidade
   ↓ Edge Function busca fcm_tokens de cooperados ativos (status = 'ativo')
   ↓ Chama FCM v1 API com tokens em batch
   ↓ Registra resultado em notifications_log
   ↓ Cooperado recebe push (mesmo com app fechado)
   ↓ Toque → DeepLink via go_router → tela de detalhe
```

- **Token refresh:** `firebase_messaging.getToken()` chamado no login e armazenado em `cooperados.fcm_token`
- **Token expirado:** quando FCM retorna `UNREGISTERED`, Edge Function remove o token do cooperado
- **Foreground:** `flutter_local_notifications` exibe banner nativo quando o app está aberto

### Versionamento de Migrations

As migrations Supabase são versionadas: `001_`, `002_` etc. em `supabase/migrations/`. Rodar via:
```bash
supabase db push  # aplica migrations pendentes
supabase db diff  # gera migration a partir de mudanças no schema
```

### Commits

Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`  
Exemplo: `feat(oportunidades): implementar candidatura com validação de inadimplente`

---

## Modelo de Dados (Tabelas Supabase)

*(Baseado no plano de produto — validado pelo Arquiteto. Sem alterações necessárias.)*

```sql
cooperativas      -- tenant root (multi-tenant)
cooperados        -- membros, roles admin/cooperado
oportunidades     -- CORE: o quadro de oportunidades
candidaturas      -- UNIQUE(oportunidade_id, cooperado_id)
atribuicoes       -- confirmação, check-in/out, avaliação
comunicados       -- avisos da cooperativa
cotas_pagamentos  -- controle de inadimplência
notifications_log -- auditoria de pushes enviados
```

Diagrama ER resumido:
```
cooperativas 1──N cooperados
cooperativas 1──N oportunidades
oportunidades 1──N candidaturas
oportunidades 1──N atribuicoes
candidaturas ──── atribuicoes (foreign key)
cooperados 1──N candidaturas
cooperados 1──N atribuicoes
cooperativas 1──N comunicados
cooperados 1──N cotas_pagamentos
```

---

## Decisões Técnicas e Trade-offs

| Decisão | Alternativa Descartada | Motivo da Escolha |
|---------|----------------------|------------------|
| **Flutter Full-Stack** (mobile + web) | Expo (mobile) + Next.js (web) | Codebase único para dev solo — relação custo/benefício melhor. Flutter Web suficiente para admin painel interno |
| **Supabase BaaS** | Backend custom Node.js/NestJS | Elimina server management, RLS nativo = multi-tenancy gratuito, auth + realtime + storage out-of-box |
| **flutter_bloc** | Riverpod, GetX, Provider | BLoC é o padrão mais testável e escalável para apps Flutter complexos; documentação abundante |
| **go_router** | auto_route, Navigator 2.0 manual | Declarativo, deep links nativos, suporte a push notification routing; padrão oficial do Flutter team |
| **FCM via Edge Function** | Supabase Push (alpha) / WhatsApp API | FCM é gratuito, maduro, sem intermediários. Edge Function dá controle total sobre batching e retry |
| **Either<Failure, T>** (fpdart) | Exceptions propagadas no BLoC | Tratamento de erros explícito, sem try-catch espalhados. Domain layer puro sem depender de exceções de framework |
| **RLS como multi-tenancy** | Schema separation / Database per tenant | Escala para 50+ cooperativas em uma única instância — custo fixo de infra não cresce com clientes |
| **Sem rodízio automático v1** | Algoritmo por menor produção | Simplifica a lógica de atribuição; admin tem controle explícito; evita edge cases de algoritmo não testado em produção |
| **Relatórios como tela web (sem PDF)** | Geração de PDF no cliente | PDF em Flutter Web é limitado; tela responsiva + exportação CSV cobre 100% do caso de uso da AGO |

---

## Risks e Débitos Técnicos Conhecidos

| Item | Tipo | Descrição | Resolução Planejada |
|------|------|-----------|---------------------|
| Flutter Web performance em tabelas grandes | Técnico | Listas longas no admin podem ter lag no browser | Implementar paginação desde v1 (≤ 20 rows/page) |
| FCM iOS em modo killed | Técnico | iOS pode bloquear push em modo killed com DND ativo | Adicionar e-mail como fallback no onboarding (configurável) |
| Apple Developer Program | Custo | R$519/ano antes de publicar no iOS | Adiar publicação iOS até 1º cliente pagante (Path A: PWA primeiro) |
| Token refresh race condition | Técnico | Token FCM pode mudar entre logins | Reatualizar token em `onTokenRefresh()` callback |
| Supabase Free tier bandwidth | Infra | 50MB bandwidth/dia — esgota com 5+ clientes ativos | Migrar para Pro (R$143/mês) ao atingir 80%; coberto por 2 clientes pagantes |

---

## Package Summary (pubspec.yaml — pendente aprovação)

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.4          # BaaS client oficial
  firebase_messaging: ^15.1.5        # FCM push notifications
  flutter_local_notifications: ^18.0 # Notificação foreground
  flutter_bloc: ^8.1.6              # State management
  go_router: ^14.6.2                # Navegação declarativa
  fpdart: ^1.1.0                    # Either/Option para error handling
  get_it: ^8.0.3                    # Dependency injection
  intl: ^0.20.1                     # Localização pt-BR, formatação
  google_fonts: ^6.2.1              # Inter font
  image_picker: ^1.1.2              # Upload de foto/logo
  cached_network_image: ^3.4.1      # Cache de imagens
  fl_chart: ^0.69.0                 # Gráficos de relatório
  flutter_masked_text2: ^0.9.0      # Máscara de CPF e telefone
  csv: ^6.0.0                       # Exportação CSV
  equatable: ^2.0.7                 # Comparação de entities em BLoC

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0
```

---

## Custos de Infraestrutura (por fase)

| Fase | Supabase | FCM | Apple Dev | Google Play | Vercel | Total/mês |
|------|---------|-----|-----------|-------------|--------|-----------|
| MVP (0–3 clientes) | R$0 (Free) | R$0 | R$0* | R$0 | R$0 | **R$0** |
| 3–10 clientes | R$143 (Pro) | R$0 | R$43/mês | R$11/mês | R$0 | **R$197** |
| 10–30 clientes | R$143 | R$0 | R$43/mês | R$11/mês | R$0 | **R$197** |

*Apple Developer Program: R$519/ano — pagar somente ao publicar na App Store.

---

> ✅ **APROVADO** — 2026-04-05. Arquitetura aprovada pelo usuário. Pipeline liberado para implementação.
