#!/usr/bin/env python3
"""Script de geração dos arquivos Flutter para o CoopCRM."""
import os

BASE = "/Users/felipemoreira/development/opensquads/agentcode/opensquad/squads/software-factory/output/2026-04-05-223053/coopcrm/lib"

def write(rel_path, content):
    full = os.path.join(BASE, rel_path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content)
    print(f"OK: {rel_path}")

# ========================================================
# BATCH 1 — CORE FILES
# ========================================================

write("app.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = getIt<AppRouter>().router;
          return MaterialApp.router(
            title: 'CoopCRM',
            theme: AppTheme.light,
            routerConfig: router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'),
              Locale('en'),
              Locale('es'),
            ],
          );
        },
      ),
    );
  }
}
""")

write("core/env/env.dart", """import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _Env.supabaseAnonKey;
}
""")

write("core/error/failures.dart", """import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Registro não encontrado.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Erro inesperado. Tente novamente.']);
}
""")

write("core/theme/app_colors.dart", """import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary        = Color(0xFF00796B);
  static const onPrimary      = Color(0xFFFFFFFF);
  static const secondary      = Color(0xFF004D40);
  static const accent         = Color(0xFFF59E0B);
  static const background     = Color(0xFFF5F7FA);
  static const surface        = Color(0xFFFFFFFF);
  static const error          = Color(0xFFDC2626);
  static const onError        = Color(0xFFFFFFFF);
  static const textPrimary    = Color(0xFF111827);
  static const textSecondary  = Color(0xFF6B7280);
  static const divider        = Color(0xFFE5E7EB);

  static const statusRascunho      = Color(0xFFD97706);
  static const statusAberta        = Color(0xFF16A34A);
  static const statusEmCandidatura = Color(0xFF7C3AED);
  static const statusAtribuida     = Color(0xFF2563EB);
  static const statusEmExecucao    = Color(0xFF0891B2);
  static const statusConcluida     = Color(0xFF6B7280);
  static const statusCancelada     = Color(0xFFDC2626);
}
""")

write("core/theme/app_theme.dart", """import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: Color(0xFFB2DFDB),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    ),
  );
}
""")

write("core/router/app_routes.dart", """class AppRoutes {
  AppRoutes._();

  static const login        = '/login';
  static const feed         = '/feed';
  static const comunicados  = '/comunicados';
  static const cotas        = '/cotas';
  static const perfil       = '/perfil';
  static const cooperados   = '/perfil/cooperados';
  static const notificacoes = '/notificacoes';
}
""")

write("core/router/app_router.dart", """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/oportunidades/presentation/pages/feed_page.dart';
import '../../features/oportunidades/presentation/pages/oportunidade_detail_page.dart';
import '../../features/oportunidades/presentation/pages/criar_oportunidade_page.dart';
import '../../features/comunicados/presentation/pages/comunicados_page.dart';
import '../../features/cotas/presentation/pages/cotas_page.dart';
import '../../features/perfil/presentation/pages/perfil_page.dart';
import '../../features/cooperados/presentation/pages/cooperados_page.dart';
import '../../features/notificacoes/presentation/pages/notificacoes_page.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'app_routes.dart';

@singleton
class AppRouter {
  final AuthBloc _authBloc;
  AppRouter(this._authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.feed,
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      if (!isAuthenticated && !isLoginRoute) return AppRoutes.login;
      if (isAuthenticated && isLoginRoute) return AppRoutes.feed;
      return null;
    },
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (_, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.feed,
            builder: (_, __) => const FeedPage(),
            routes: [
              GoRoute(
                path: 'criar',
                builder: (_, __) => const CriarOportunidadePage(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => OportunidadeDetailPage(
                  id: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.comunicados,
            builder: (_, __) => const ComunicadosPage(),
          ),
          GoRoute(
            path: AppRoutes.cotas,
            builder: (_, __) => const CotasPage(),
          ),
          GoRoute(
            path: AppRoutes.perfil,
            builder: (_, __) => const PerfilPage(),
            routes: [
              GoRoute(
                path: 'cooperados',
                builder: (_, __) => const CooperadosPage(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.notificacoes,
            builder: (_, __) => const NotificacoesPage(),
          ),
        ],
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  final dynamic _subscription;
  _GoRouterRefreshStream(Stream stream)
      : _subscription = stream.asBroadcastStream().listen((_) {}) {
    notifyListeners();
    (_subscription as dynamic).onData((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
""")

write("core/di/injection.dart", """import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class AppModule {
  @Named('supabase')
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
""")

write("core/utils/validators.dart", """class Validators {
  Validators._();

  static String? required(String? value, {String label = 'Campo'}) {
    if (value == null || value.trim().isEmpty) return '\$label é obrigatório';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
    if (!RegExp(r'^[\\w.-]+@[\\w.-]+\\.[a-z]{2,}\$').hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  static String? cpf(String? value) {
    if (value == null || value.trim().isEmpty) return 'CPF é obrigatório';
    if (value.replaceAll(RegExp(r'\\D'), '').length != 11) return 'CPF inválido';
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) return 'Mínimo de \$min caracteres';
    return null;
  }
}
""")

write("core/utils/date_utils.dart", """import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(date);

  static String formatMonth(DateTime date) {
    final s = DateFormat('MMMM/yyyy', 'pt_BR').format(date);
    return s[0].toUpperCase() + s.substring(1);
  }

  static String timeAgo(DateTime date) =>
      timeago.format(date, locale: 'pt_BR', allowFromNow: true);

  static bool isExpired(DateTime prazo) => prazo.isBefore(DateTime.now());
}
""")

write("shared/extensions/context_extensions.dart", """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isWide => screenSize.width >= 768;
  void goTo(String path) => go(path);
  void pushTo(String path) => push(path);
}
""")

write("shared/extensions/string_extensions.dart", """extension StringX on String {
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  String get formatCPF {
    final d = replaceAll(RegExp(r'\\D'), '');
    if (d.length != 11) return this;
    return '\${d.substring(0, 3)}.\${d.substring(3, 6)}.\${d.substring(6, 9)}-\${d.substring(9)}';
  }

  String get formatPhone {
    final d = replaceAll(RegExp(r'\\D'), '');
    if (d.length == 11) {
      return '(\${d.substring(0, 2)}) \${d.substring(2, 7)}-\${d.substring(7)}';
    }
    return this;
  }
}
""")

print("BATCH 1 DONE")
