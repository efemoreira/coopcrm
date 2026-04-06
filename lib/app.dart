import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

/// Raiz da árvore de widgets do CoopCRM.
/// Fornece o [AuthBloc] globalmente e configura Material 3,
/// roteamento declarativo (go_router) e localização pt-BR.
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
