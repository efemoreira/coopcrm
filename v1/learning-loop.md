## Aprendizados — CoopCRM (Flutter + Supabase) — 2026-04-05

- **Geracao de muitos arquivos Dart:** Nunca usar heredoc de shell para gerar arquivos com acentos/emojis ou interpolacao `${}` — usar exclusivamente Python `create_file` com script dedicado. Heredocs com caracteres especiais corrompem o output silenciosamente
- **`${}` em arquivos Dart gerados via Python:** Quando o script Python usa f-strings, `${expr}` vira `\${expr}` no output. Solucao: usar raw strings `r"..."` ou escapar apenas a parte Python e deixar o `${}` do Dart intocado. Alternativa: rodar `fix_escapes.py` pos-geracao com regex `(?<!R)\\\${` → `${`
- **Supabase Flutter 2.x:** `.in_()` foi renomeado para `.inFilter()` — atualizar todos os queries que filtram arrays
- **Flutter 3.27+:** `CardTheme` → `CardThemeData` na declaracao do ThemeData
- **`flutter_localizations`:** Dependencia deve ser declarada explicitamente mesmo sendo SDK — `flutter_localizations: sdk: flutter` no pubspec.yaml
- **`build_runner` + `injectable`:** Rodar obrigatoriamente APOS corrigir todos os erros de sintaxe — uma aspa errada interrompe todo o build
- **String date em Dart dentro de SingleQuote:** Usar double quotes para strings que contem `.padLeft(2, '0')` — evita parse error do Dart
- **`.cast<T>()` em retornos Supabase:** `select()` retorna `List<dynamic>` — sempre adicionar `.cast<EntityType>()` ao converter para lista tipada no Cubit
- **`flutter analyze` + `build_runner` sao obrigatorios antes de Step 13:** 0 errors, 0 warnings e sucesso no build_runner sao pre-requisitos do Code Review
- **RLS + multi-tenancy:** Definir `current_cooperative_id()` e `is_admin()` como funcoes SQL helper que leem `auth.uid()` — mantem as policies DRY e auditaveis
- **Sequencia de migrations importa:** FK constraints exigem ordem — cooperativas → cooperados → oportunidades → candidaturas → comunicados → cotas → notifications_log → RLS → policies → helpers
- **Edge Functions Supabase:** Usar `Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')` e criar client com service_role para bypass do RLS dentro das funcoes — nunca usar anon key em funcoes server-side privilegiadas
- **Flutter Realtime + BLoC:** Assinar canal de Realtime no `on(LoadFeedEvent)` e cancelar a subscription no `close()` do BLoC — sem isso da memory leak
- **Supabase seed.sql:** Incluir dado de cooperativa de teste + cooperado admin para facilitar onboarding em novo ambiente de dev
- **Output dir CoopCRM:** `squads/software-factory/output/2026-04-05-223053/coopcrm/` — docs em `v1/`
