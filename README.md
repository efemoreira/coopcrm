# CoopCRM

Sistema de gestao para cooperativas - aplicativo mobile/web em Flutter com backend Supabase.

## Sobre o Produto

CoopCRM e um SaaS multi-tenant para cooperativas brasileiras. Cooperados visualizam e se candidatam
a oportunidades, recebem comunicados internos, acompanham cotas e perfil.

**Stack:** Flutter 3.27+ (iOS/Android/Web) + Supabase (PostgreSQL 15 + Realtime + Edge Functions) + Firebase FCM

---

## Funcionalidades do MVP

- **Login** - Autenticacao email/senha com sessao persistida
- **Feed de Oportunidades** - Lista em tempo real com filtros por status
- **Candidatura** - Candidatar-se em ate 2 toques
- **Comunicados** - Feed interno com badge de nao-lido
- **Cotas** - Historico de pagamentos com resumo financeiro
- **Notificacoes** - Historico de pushes recebidos
- **Perfil** - Dados pessoais + logout
- **Admin** - Criar oportunidades + listar cooperados

---

## Pre-requisitos

- [Flutter 3.27+](https://flutter.dev)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- Conta no [Supabase](https://app.supabase.com)

---

## Instalacao

### 1. Configurar variaveis de ambiente

```bash
cp .env.example .env
# Editar .env com credenciais do Supabase
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Gerar codigo (injectable + envied + l10n)

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

### 4. Configurar banco de dados

```bash
supabase db push --project-ref <PROJECT_REF>
supabase functions deploy notify-nova-oportunidade --project-ref <PROJECT_REF>
supabase functions deploy atribuir-automatico --project-ref <PROJECT_REF>
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<value> --project-ref <PROJECT_REF>
```

### 5. Criar cooperativa e admin no SQL Editor

```sql
INSERT INTO cooperativas (nome, cnpj, plano)
VALUES ('Minha Cooperativa', '00.000.000/0001-00', 'starter');

INSERT INTO cooperados (cooperative_id, user_id, nome, cpf, email, is_admin, num_cota)
VALUES ('<uuid-cooperativa>', '<uuid-auth-user>', 'Admin', '000.000.000-00', 'admin@cooperativa.com', true, 1);
```

### 6. Rodar o app

```bash
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

---

## Estrutura do Projeto

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── di/           # Injecao de dependencias (get_it + injectable)
│   ├── env/          # Variaveis de ambiente (@Envied)
│   ├── error/        # sealed Failure (fpdart Either<Failure, T>)
│   ├── router/       # Navegacao declarativa (go_router + ShellRoute)
│   ├── theme/        # Design system - Material 3, verde #00796B
│   └── utils/
├── shared/
│   ├── extensions/
│   └── widgets/      # AppScaffold, StatusChip, LoadingOverlay...
└── features/
    ├── auth/
    ├── oportunidades/
    ├── comunicados/
    ├── cotas/
    ├── cooperados/
    ├── notificacoes/
    └── perfil/

supabase/
├── migrations/       # 10 migrations PostgreSQL
├── functions/        # Edge Functions Deno/TypeScript
└── seed.sql
```

---

## Arquitetura

Clean Architecture por feature - `domain/data/presentation`:
- `domain/` - entidades puras, repositorios abstratos, use cases
- `data/` - modelos Supabase, datasources, repositorios concretos
- `presentation/` - BLoC/Cubit, paginas, widgets

Multi-tenancy via RLS - todas as tabelas filtradas por `cooperative_id`.

---

## Tecnologias

| Tecnologia | Uso |
|-----------|-----|
| Flutter 3.27+ | Mobile + Web |
| Supabase 2.x | Backend-as-a-Service (DB + Auth + Realtime) |
| flutter_bloc | Estado (BLoC para auth/feed, Cubit para demais) |
| go_router | Navegacao com auth redirect |
| get_it + injectable | Injecao de dependencias com code gen |
| fpdart | Either<Failure, T> para tratamento de erros |
| envied | Variaveis de ambiente obfuscadas |
