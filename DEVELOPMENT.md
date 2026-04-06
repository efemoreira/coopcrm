# CoopCRM — Development Guide

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter | 3.27+ | https://flutter.dev/docs/get-started/install |
| Dart | 3.6+ | bundled with Flutter |
| Supabase CLI | latest | `brew install supabase/tap/supabase` |
| Node.js | 20+ | https://nodejs.org (required by Supabase CLI) |

### Verify installs

```bash
flutter --version
supabase --version
```

---

## 1. Clone & Setup

```bash
git clone <REPO_URL>
cd coopcrm
```

### Environment variables

```bash
cp .env.example .env
```

Edit `.env` with your Supabase project credentials:

```env
SUPABASE_URL=https://<PROJECT_REF>.supabase.co
SUPABASE_ANON_KEY=<YOUR_ANON_KEY>
```

> Get these values from: Supabase Dashboard -> Project Settings -> API

---

## 2. Install Flutter dependencies

```bash
flutter pub get
```

---

## 3. Generate code

Run both generators (order matters):

```bash
# 1. Localization strings
flutter gen-l10n

# 2. DI + env var code generation
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `lib/core/di/injection.config.dart` — injectable registry
- `lib/core/env/env.g.dart` — obfuscated env vars
- `lib/l10n/app_localizations*.dart` — l10n classes

---

## 4. Set up local Supabase database

```bash
# Start local Supabase stack (Docker required)
supabase start

# Apply all migrations
supabase db push

# Seed dev data
supabase db seed
```

This creates tables, RLS policies, Edge Functions and seed data locally.

Local Supabase URLs will be printed — update your `.env`:

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=<printed_anon_key>
```

---

## 5. Run the app

```bash
# Android emulator
flutter run -d android

# iOS simulator
flutter run -d ios

# Web (Chrome)
flutter run -d chrome

# List available devices
flutter devices
```

---

## 6. Run tests

```bash
# All tests
flutter test

# Specific file
flutter test test/features/auth/auth_bloc_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 7. Static analysis

```bash
flutter analyze
```

Expected output: 0 errors, 0 warnings.

---

## 8. Hot reload & debug

| Shortcut | Action |
|----------|--------|
| `r` | Hot reload |
| `R` | Hot restart |
| `d` | Detach (keep running) |
| `q` | Quit |

---

## 9. Code generation workflow

Whenever you add/modify `@injectable`, `@lazySingleton`, `@Envied` or `.arb` files:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

---

## 10. Project structure

```
lib/
├── core/           # DI, router, theme, env, errors, utils
├── shared/         # Reusable widgets and extensions
└── features/
    ├── auth/
    ├── oportunidades/
    ├── comunicados/
    ├── cotas/
    ├── cooperados/
    ├── notificacoes/
    └── perfil/

supabase/
├── migrations/     # PostgreSQL migrations (ordered 000001 ... 000010)
├── functions/      # Edge Functions (Deno/TypeScript)
└── seed.sql

test/
└── features/       # Unit and widget tests per feature
```

---

## 11. Create the first admin user (local dev)

1. Open Supabase Studio: http://127.0.0.1:54323
2. Go to **Authentication > Users** → Create user (email/password)
3. Copy the user UUID
4. Open **SQL Editor** and run:

```sql
-- 1. Create cooperativa
INSERT INTO cooperativas (nome, cnpj, plano)
VALUES ('Cooperativa Dev', '00.000.000/0001-00', 'starter')
RETURNING id;

-- 2. Create cooperado admin (replace <cooperative_id> and <user_id>)
INSERT INTO cooperados (cooperative_id, user_id, nome, cpf, email, is_admin, num_cota)
VALUES (
  '<cooperative_id>',
  '<user_id>',
  'Admin Dev',
  '000.000.000-00',
  'admin@dev.com',
  true,
  1
);
```

---

## 12. Troubleshooting

| Problem | Solution |
|---------|----------|
| `build_runner` fails | Check for Dart syntax errors first — `flutter analyze` |
| `env.g.dart` not found | Run `dart run build_runner build` again |
| Supabase auth error | Verify `.env` values match your Supabase project |
| `injection.config.dart` out of date | Run `dart run build_runner build --delete-conflicting-outputs` |
| iOS build fails | Run `cd ios && pod install && cd ..` |
| Android build fails | Run `flutter clean && flutter pub get` |
