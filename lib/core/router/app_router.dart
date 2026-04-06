import 'package:flutter/material.dart';
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
import '../../features/candidaturas/presentation/pages/candidaturas_page.dart';
import '../../features/relatorios/presentation/pages/relatorios_page.dart';
import '../../features/configuracoes/presentation/pages/configuracoes_page.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'app_routes.dart';

/// Roteador declarativo da aplicação usando go_router.
/// Gerencia redirecionamento baseado no estado de autenticação ([AuthBloc])
/// e suporta deep links de push notifications via [pendingDeepLink].
@singleton
class AppRouter {
  final AuthBloc _authBloc;
  /// Deep link pendente gravado antes do `runApp()` quando o app estava fechado.
  String? pendingDeepLink;
  AppRouter(this._authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.feed,
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      if (!isAuthenticated && !isLoginRoute) return AppRoutes.login;
      if (isAuthenticated && isLoginRoute) {
        final pending = pendingDeepLink;
        if (pending != null) {
          pendingDeepLink = null;
          return pending;
        }
        return AppRoutes.feed;
      }
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
          GoRoute(
            path: AppRoutes.candidaturas,
            builder: (_, __) => const CandidaturasPage(),
          ),
          GoRoute(
            path: AppRoutes.relatorios,
            builder: (_, __) => const RelatoriosPage(),
          ),
          GoRoute(
            path: AppRoutes.configuracoes,
            builder: (_, __) => const ConfiguracoesPage(),
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
