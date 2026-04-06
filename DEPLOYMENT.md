# CoopCRM — Deployment Guide

## Architecture Overview

```
Flutter App (iOS / Android / Web)
        |
        v
  Supabase Cloud
  ├── PostgreSQL 15 (RLS multi-tenant)
  ├── Auth (email/password)
  ├── Realtime (oportunidades feed)
  ├── Storage (file uploads — future)
  └── Edge Functions (Deno)
        ├── notify-nova-oportunidade
        └── atribuir-automatico
```

---

## 1. Supabase Cloud Setup

### 1.1 Create project

1. Go to https://app.supabase.com
2. **New project** → choose org, name: `coopcrm-prod`, region: `sa-east-1` (São Paulo)
3. Save the **database password** securely (you'll need it later)

### 1.2 Collect credentials

From **Project Settings → API**:

```
SUPABASE_URL=https://<ref>.supabase.co
SUPABASE_ANON_KEY=<anon_key>
SUPABASE_SERVICE_ROLE_KEY=<service_role_key>   # keep secret, server-side only
```

### 1.3 Apply migrations

```bash
# Link local project to remote
supabase link --project-ref <PROJECT_REF>

# Push all 10 migrations
supabase db push --project-ref <PROJECT_REF>
```

### 1.4 Deploy Edge Functions

```bash
# Set server-side secrets first
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<value> --project-ref <PROJECT_REF>

# Deploy functions
supabase functions deploy notify-nova-oportunidade --project-ref <PROJECT_REF>
supabase functions deploy atribuir-automatico --project-ref <PROJECT_REF>
```

### 1.5 Verify

- Dashboard → **Table Editor** — all 9 tables present
- Dashboard → **Authentication → Policies** — RLS enabled on all tables
- Dashboard → **Edge Functions** — both functions deployed and active

---

## 2. First Manual Deploy

### 2.1 Configure env vars

Create `.env` with production Supabase credentials:

```env
SUPABASE_URL=https://<ref>.supabase.co
SUPABASE_ANON_KEY=<anon_public_key>
```

### 2.2 Regenerate code with production values

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2.3 Build

```bash
# Android (AAB for Play Store)
flutter build appbundle --release

# iOS (archive via Xcode)
flutter build ios --release
open ios/Runner.xcworkspace  # then Archive in Xcode

# Web
flutter build web --release
```

---

## 3. CI/CD — GitHub Actions

The workflow file at `.github/workflows/ci.yml` runs on every push to `main`:

1. **Lint** — `flutter analyze`
2. **Test** — `flutter test`
3. **Build** — `flutter build web --release`
4. **Deploy web** — Firebase Hosting (or Vercel, configure below)

### 3.1 Add GitHub Secrets

Go to **Repo → Settings → Secrets and Variables → Actions** and add:

| Secret | Value |
|--------|-------|
| `SUPABASE_URL` | `https://<ref>.supabase.co` |
| `SUPABASE_ANON_KEY` | `<anon_key>` |

### 3.2 Web deploy — Firebase Hosting

```bash
# One-time setup
npm install -g firebase-tools
firebase login
firebase init hosting   # select build/web as public dir
```

Add to GitHub Secrets:
- `FIREBASE_TOKEN` — from `firebase login:ci`

### 3.3 Web deploy — Vercel (alternative)

```bash
npm install -g vercel
vercel --prod build/web
```

Add to GitHub Secrets:
- `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`

---

## 4. GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  FLUTTER_VERSION: "3.27.3"

jobs:
  quality:
    name: Lint & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: |
          flutter gen-l10n
          dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test

  build-web:
    name: Build & Deploy Web
    runs-on: ubuntu-latest
    needs: quality
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: |
          flutter gen-l10n
          dart run build_runner build --delete-conflicting-outputs

      - name: Build web
        run: flutter build web --release

      # Uncomment to deploy to Firebase Hosting:
      # - name: Deploy to Firebase
      #   uses: FirebaseExtended/action-hosting-deploy@v0
      #   with:
      #     repoToken: ${{ secrets.GITHUB_TOKEN }}
      #     firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
      #     channelId: live
      #     projectId: <firebase-project-id>
```

---

## 5. Mobile Distribution

### 5.1 Android — Google Play

```bash
# Create keystore (one-time)
keytool -genkey -v -keystore ~/coopcrm-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias coopcrm

# Build signed AAB
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

Upload to **Google Play Console → Internal Testing** first, then promote.

### 5.2 iOS — App Store Connect

1. `flutter build ios --release`
2. Open `ios/Runner.xcworkspace` in Xcode
3. **Product → Archive**
4. **Window → Organizer → Distribute App → App Store Connect**

---

## 6. Environment Promotion

| Environment | Branch | Supabase Project | Notes |
|-------------|--------|-----------------|-------|
| Development | local | local Docker | `supabase start` |
| Staging | `develop` | `coopcrm-staging` | manual deploy |
| Production | `main` | `coopcrm-prod` | CI/CD auto-deploy |

---

## 7. Rollback

### Database rollback

```bash
# List applied migrations
supabase migration list --project-ref <PROJECT_REF>

# Revert last migration (write a down migration)
supabase db diff --schema public > supabase/migrations/<timestamp>_rollback.sql
# Edit the file to reverse changes, then push
supabase db push --project-ref <PROJECT_REF>
```

### App rollback

```bash
# Via git — revert to previous release tag
git revert HEAD
git push origin main
# CI/CD will redeploy automatically
```

For mobile: use Google Play / App Store rollback to previous release in their consoles.

---

## 8. Monitoring

| What | Tool | Location |
|------|------|----------|
| API errors | Supabase Dashboard | Logs → API |
| Edge Function logs | Supabase Dashboard | Functions → Logs |
| Auth events | Supabase Dashboard | Authentication → Logs |
| App crashes | Firebase Crashlytics | Firebase Console |
| Analytics | Firebase Analytics | Firebase Console |

### Key SQL queries for health check

```sql
-- Active cooperados in last 7 days
SELECT COUNT(DISTINCT user_id) FROM auth.sessions
WHERE created_at >= NOW() - INTERVAL '7 days';

-- Open oportunidades
SELECT COUNT(*) FROM oportunidades WHERE status = 'aberta';

-- Candidaturas today
SELECT COUNT(*) FROM candidaturas
WHERE created_at >= CURRENT_DATE;
```

---

## 9. Secrets Management

- Never commit `.env` to git (it is gitignored)
- Supabase `service_role` key is **server-side only** — never expose in Flutter app
- Rotate keys via: Supabase Dashboard → Project Settings → API → Reset keys
- GitHub Actions secrets are encrypted and never exposed in logs
