# Playbook Frontend — CoopCRM

> **Autor:** Felipe Front | **Step 09** | **Data:** 2026-04-05  
> ⚠️ Documento interno — insumo para Step 11 (implement-frontend)

---

## Stack

| Tecnologia | Versão | Função |
|-----------|--------|--------|
| Flutter | 3.27+ (Dart 3.6+) | Framework UI — iOS, Android, Web |
| supabase_flutter | ^2.8.0 | BaaS client (Auth + DB + Realtime + Storage) |
| flutter_bloc | ^8.1.5 | State management (BLoC + Cubit patterns) |
| go_router | ^14.2.0 | Declarative navigation com guards |
| get_it | ^8.0.0 | Service locator / Dependency Injection |
| fpdart | ^1.1.0 | Either<Failure, T> — functional error handling |
| injectable | ^2.4.4 | Code gen para get_it (anotações) |
| equatable | ^2.0.5 | Value equality for BLoC states/events |
| freezed | ^2.5.2 | Immutable models + union types (code gen) |
| json_annotation | ^4.9.0 | JSON serialization (code gen) |
| intl | ^0.19.0 | i18n + ARB files |
| cached_network_image | ^3.4.1 | Cache de imagens remotas |
| image_picker | ^1.1.2 | Foto de perfil |
| permission_handler | ^11.3.1 | Permissões de câmera/notificação |
| firebase_core | ^3.6.0 | Firebase inicialização para FCM |
| firebase_messaging | ^15.1.3 | Push notifications (FCM) |
| flutter_local_notifications | ^18.0.0 | Notificações locais (foreground) |
| shared_preferences | ^2.3.2 | Cache local simples (prefs, tokens) |
| envied | ^0.5.4 | Env vars seguras (não expor Supabase keys no código) |
| shimmer | ^3.0.0 | Loading skeleton |
| timeago | ^3.7.0 | "há 5 minutos" formatado |

---

## Scaffold do Projeto (Greenfield)

```bash
# Criar o projeto Flutter
flutter create coopcrm --org br.coop.crm --platforms ios,android,web

# Entrar no diretório
cd coopcrm

# Instalar dependências
flutter pub add \
  supabase_flutter \
  flutter_bloc \
  go_router \
  get_it \
  injectable \
  fpdart \
  equatable \
  freezed_annotation \
  json_annotation \
  intl \
  cached_network_image \
  image_picker \
  permission_handler \
  firebase_core \
  firebase_messaging \
  flutter_local_notifications \
  shared_preferences \
  envied \
  shimmer \
  timeago

flutter pub add --dev \
  build_runner \
  freezed \
  json_serializable \
  injectable_generator \
  envied_generator \
  flutter_gen_runner

# Gerar código
dart run build_runner build --delete-conflicting-outputs
```

---

## Estrutura de Pastas

```
lib/
├── main.dart                         # Entrypoint — inicializa Supabase, Firebase, GetIt
├── app.dart                          # MaterialApp.router + go_router setup
├── core/
│   ├── di/
│   │   └── injection.dart            # GetIt + Injectable setup
│   ├── env/
│   │   └── env.dart                  # @Envied — Supabase URL/Key (não expor)
│   ├── error/
│   │   ├── failures.dart             # Sealed class Failure (ServerFailure, NetworkFailure, etc.)
│   │   └── exceptions.dart           # AppException classes
│   ├── network/
│   │   └── supabase_client.dart      # SupabaseClient singleton via GetIt
│   ├── router/
│   │   ├── app_router.dart           # GoRouter configuration
│   │   └── app_routes.dart           # Constantes de rotas ('/feed', '/perfil', etc.)
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData — tokens do design-system.md
│   │   └── app_colors.dart           # Color constants (primary: #00796B, accent: #F59E0B)
│   └── utils/
│       ├── date_utils.dart           # Helpers de data (timeago, formatted)
│       └── validators.dart           # CPF, telefone, etc.
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart   # abstract
│   │   │   └── usecases/
│   │   │       ├── sign_in_usecase.dart
│   │   │       └── sign_out_usecase.dart
│   │   ├── data/
│   │   │   ├── datasources/supabase_auth_datasource.dart
│   │   │   ├── models/user_model.dart               # @JsonSerializable + @freezed
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/auth_bloc.dart                  # ou auth_cubit.dart
│   │       ├── pages/login_page.dart
│   │       └── widgets/login_form.dart
│   │
│   ├── oportunidades/
│   │   ├── domain/
│   │   │   ├── entities/oportunidade_entity.dart
│   │   │   ├── repositories/oportunidades_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_feed_usecase.dart
│   │   │       ├── candidatar_usecase.dart
│   │   │       ├── criar_oportunidade_usecase.dart
│   │   │       └── atribuir_oportunidade_usecase.dart
│   │   ├── data/
│   │   │   ├── datasources/supabase_oportunidades_datasource.dart
│   │   │   ├── models/oportunidade_model.dart
│   │   │   └── repositories/oportunidades_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/feed_bloc.dart
│   │       ├── bloc/oportunidade_detail_cubit.dart
│   │       ├── pages/
│   │       │   ├── feed_page.dart
│   │       │   ├── oportunidade_detail_page.dart
│   │       │   └── criar_oportunidade_page.dart     # admin only
│   │       └── widgets/
│   │           ├── oportunidade_card.dart
│   │           ├── status_badge.dart
│   │           └── candidatos_list.dart
│   │
│   ├── comunicados/
│   │   ├── domain/...
│   │   ├── data/...
│   │   └── presentation/...
│   │
│   ├── cotas/
│   │   ├── domain/...
│   │   ├── data/...
│   │   └── presentation/...
│   │
│   ├── cooperados/
│   │   ├── domain/...
│   │   ├── data/...
│   │   └── presentation/...              # admin: lista, cadastro, detalhes
│   │
│   ├── notificacoes/
│   │   ├── domain/...
│   │   ├── data/...
│   │   └── presentation/
│   │       └── pages/notificacoes_page.dart
│   │
│   └── perfil/
│       ├── domain/...
│       ├── data/...
│       └── presentation/
│           └── pages/perfil_page.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart             # PrimaryButton, SecondaryButton, DangerButton
│   │   ├── app_text_field.dart
│   │   ├── app_scaffold.dart           # Scaffold com BottomNavigationBar
│   │   ├── status_chip.dart            # StatusBadge (cores do design-system)
│   │   ├── loading_overlay.dart        # Overlay escurecido + spinner
│   │   ├── empty_state.dart            # Empty states padrão
│   │   └── error_widget.dart
│   └── extensions/
│       ├── context_extensions.dart     # BuildContext shortcuts (theme, l10n, etc.)
│       └── string_extensions.dart      # capitalize, formatCPF, etc.
│
└── l10n/
    ├── app_pt_BR.arb                   # strings pt-BR (geradas do ux-content.md)
    ├── app_en.arb
    └── app_es.arb
```

---

## Nomenclatura

| Item | Padrão | Exemplo |
|------|--------|---------|
| Classes / Widgets | PascalCase | `OportunidadeCard`, `FeedBloc` |
| Arquivos | snake_case | `oportunidade_card.dart`, `feed_bloc.dart` |
| Métodos / variáveis | camelCase | `fetchFeed()`, `isLoading` |
| Constantes | camelCase (ou SCREAMING_SNAKE para globais) | `kPrimaryColor` |
| Pastas de feature | snake_case | `oportunidades/`, `cotas/` |
| Rotas (strings) | kebab-case | `/oportunidades/:id` |
| Entidades | `*Entity` | `OportunidadeEntity` |
| Models (data layer) | `*Model` | `OportunidadeModel` |
| BLoC | `*Bloc` / `*Cubit` | `FeedBloc`, `AuthCubit` |
| UseCases | `*UseCase` | `CandidatarUseCase` |
| Repositories (abstract) | `*Repository` | `OportunidadesRepository` |
| Repository impl | `*RepositoryImpl` | `OportunidadesRepositoryImpl` |

---

## Clean Architecture — Camadas

### Domain Layer (puro — sem Flutter/Supabase)
```dart
// entities/oportunidade_entity.dart
class OportunidadeEntity extends Equatable {
  final String id;
  final String cooperativeId;
  final String titulo;
  final String status; // 'aberta', 'atribuida', etc.
  final DateTime prazo;
  final int numVagas;
  final double? valorEstimado;

  const OportunidadeEntity({...});

  @override
  List<Object?> get props => [id, status, titulo];
}

// repositories/oportunidades_repository.dart
abstract class OportunidadesRepository {
  Future<Either<Failure, List<OportunidadeEntity>>> getFeed({
    required String cooperativeId,
    String? statusFilter,
  });
  Future<Either<Failure, Unit>> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  });
}

// usecases/get_feed_usecase.dart
class GetFeedUseCase {
  final OportunidadesRepository _repository;
  GetFeedUseCase(this._repository);

  Future<Either<Failure, List<OportunidadeEntity>>> call(GetFeedParams params) {
    return _repository.getFeed(cooperativeId: params.cooperativeId);
  }
}
```

### Data Layer (Supabase implementation)
```dart
// models/oportunidade_model.dart
@JsonSerializable()
@freezed
class OportunidadeModel with _$OportunidadeModel {
  const factory OportunidadeModel({
    required String id,
    @JsonKey(name: 'cooperative_id') required String cooperativeId,
    required String titulo,
    required String status,
    @JsonKey(name: 'prazo_candidatura') required DateTime prazo,
    @JsonKey(name: 'num_vagas') required int numVagas,
    @JsonKey(name: 'valor_estimado') double? valorEstimado,
  }) = _OportunidadeModel;

  factory OportunidadeModel.fromJson(Map<String, dynamic> json) =>
      _$OportunidadeModelFromJson(json);

  // Mapeamento para entidade de domínio
  OportunidadeEntity toEntity() => OportunidadeEntity(
    id: id, cooperativeId: cooperativeId, titulo: titulo,
    status: status, prazo: prazo, numVagas: numVagas,
    valorEstimado: valorEstimado,
  );
}

// repositories/oportunidades_repository_impl.dart
@Injectable(as: OportunidadesRepository)
class OportunidadesRepositoryImpl implements OportunidadesRepository {
  final SupabaseOportunidadesDatasource _ds;
  OportunidadesRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<OportunidadeEntity>>> getFeed({
    required String cooperativeId, String? statusFilter,
  }) async {
    try {
      final models = await _ds.getFeed(
        cooperativeId: cooperativeId, statusFilter: statusFilter,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
```

### Datasource (Supabase queries diretas)
```dart
// datasources/supabase_oportunidades_datasource.dart
@Injectable()
class SupabaseOportunidadesDatasource {
  final SupabaseClient _client;
  SupabaseOportunidadesDatasource(@Named('supabase') this._client);

  Future<List<OportunidadeModel>> getFeed({
    required String cooperativeId,
    String? statusFilter,
  }) async {
    var query = _client
        .from('oportunidades')
        .select()
        .eq('cooperative_id', cooperativeId)
        .order('created_at', ascending: false);

    if (statusFilter != null) {
      query = query.eq('status', statusFilter);
    }

    final response = await query;
    return response.map((json) => OportunidadeModel.fromJson(json)).toList();
  }
}
```

---

## Gerenciamento de Estado — flutter_bloc

### Quando usar
- **BLoC** (`Bloc<Event, State>`): features complexas com múltiplos eventos e estados (Feed, Auth)
- **Cubit** (`Cubit<State>`): operações simples com menos eventos (Detalhe, Perfil)

### Padrão de BLoC — Feed
```dart
// feed_bloc.dart

// --- EVENTS ---
sealed class FeedEvent {}
final class FeedLoadRequested extends FeedEvent {}
final class FeedRefreshRequested extends FeedEvent {}
final class FeedFilterChanged extends FeedEvent {
  final String? status;
  FeedFilterChanged(this.status);
}

// --- STATES ---
sealed class FeedState extends Equatable {
  @override List<Object?> get props => [];
}
final class FeedInitial extends FeedState {}
final class FeedLoading extends FeedState {}
final class FeedLoaded extends FeedState {
  final List<OportunidadeEntity> oportunidades;
  final String? activeFilter;
  FeedLoaded(this.oportunidades, {this.activeFilter});
  @override List<Object?> get props => [oportunidades, activeFilter];
}
final class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}

// --- BLOC ---
@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedUseCase _getFeed;
  FeedBloc(this._getFeed) : super(FeedInitial()) {
    on<FeedLoadRequested>(_onLoad);
    on<FeedFilterChanged>(_onFilter);
  }

  Future<void> _onLoad(FeedLoadRequested event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    final result = await _getFeed(GetFeedParams());
    result.fold(
      (failure) => emit(FeedError(failure.message)),
      (items) => emit(FeedLoaded(items)),
    );
  }
}
```

### Injeção de BLoC na UI
```dart
// feed_page.dart
class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedBloc>()..add(FeedLoadRequested()),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        return switch (state) {
          FeedLoading() => const FeedSkeletonLoading(),
          FeedLoaded(:final oportunidades) => OportunidadesList(oportunidades),
          FeedError(:final message) => ErrorView(message: message),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
```

---

## Roteamento — go_router

```dart
// core/router/app_router.dart
@singleton
class AppRouter {
  final AuthBloc _authBloc;
  AppRouter(this._authBloc);

  late final router = GoRouter(
    initialLocation: AppRoutes.feed,
    redirect: (context, state) {
      final isAuth = _authBloc.state is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      if (!isAuth && !isLoginRoute) return AppRoutes.login;
      if (isAuth && isLoginRoute) return AppRoutes.feed;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.feed,
            builder: (_, __) => const FeedPage(),
          ),
          GoRoute(
            path: '${AppRoutes.oportunidades}/:id',
            builder: (_, state) => OportunidadeDetailPage(
              id: state.pathParameters['id']!,
            ),
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
          ),
        ],
      ),
    ],
  );
}

// core/router/app_routes.dart
class AppRoutes {
  static const login = '/login';
  static const feed = '/feed';
  static const oportunidades = '/oportunidades';
  static const comunicados = '/comunicados';
  static const cotas = '/cotas';
  static const perfil = '/perfil';
}
```

---

## Chamadas Supabase — Padrões

### Auth
```dart
// Supabase Auth (email/senha para admin; magic link para cooperados)
await Supabase.instance.client.auth.signInWithPassword(
  email: email, password: password,
);

// Listener de sessão no AuthBloc
Supabase.instance.client.auth.onAuthStateChange.listen((event) {
  if (event.event == AuthChangeEvent.signedIn) {
    add(AuthUserChanged(event.session?.user));
  }
});
```

### Realtime — Feed de Oportunidades
```dart
// Subscribing to realtime changes (sem cache local)
final subscription = _client
    .from('oportunidades')
    .stream(primaryKey: ['id'])
    .eq('cooperative_id', cooperativeId)
    .eq('status', 'aberta')
    .order('created_at', ascending: false)
    .listen((data) {
      add(FeedRealtimeUpdated(data));
    });

// Cancelar no close() do BLoC
@override
Future<void> close() {
  subscription.cancel();
  return super.close();
}
```

### Storage — Upload de Foto
```dart
final file = await ImagePicker().pickImage(source: ImageSource.gallery);
if (file == null) return;

final bytes = await file.readAsBytes();
final fileName = 'cooperados/$cooperadoId/avatar.jpg';
await _client.storage.from('avatars').uploadBinary(
  fileName, bytes,
  fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
);
final url = _client.storage.from('avatars').getPublicUrl(fileName);
```

---

## Dependency Injection — get_it + injectable

```dart
// core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';  // gerado pelo build_runner

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  await Firebase.initializeApp();
  configureDependencies();
  runApp(const App());
}

// Registrar SupabaseClient
@module
abstract class AppModule {
  @Named('supabase')
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
```

---

## Env Vars — envied (seguro, sem hardcode)

```dart
// lib/core/env/env.dart
import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;
}
```

`.env` (gitignored):
```
SUPABASE_URL=https://xxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

---

## Error Handling — fpdart (Either)

```dart
// core/error/failures.dart
sealed class Failure {
  final String message;
  const Failure(this.message);
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
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

// Uso no BLoC:
final result = await _useCase(params);
result.fold(
  (failure) => emit(ErrorState(failure.message)),
  (data) => emit(LoadedState(data)),
);
```

---

## Push Notifications — FCM + Supabase Edge Functions

```dart
// Fluxo:
// 1. App inicializa → solicita permissão → obtém FCM token
// 2. Token salvo no campo cooperados.fcm_token via Supabase
// 3. Supabase Edge Function dispara quando oportunidade é publicada → chama FCM API

// notificacoes_service.dart
@singleton
class NotificacoesService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize({required String cooperadoId}) async {
    // Permissão (iOS)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // FCM Token
    final token = await _messaging.getToken();
    if (token != null) await _salvarToken(token, cooperadoId);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // Background tap (app aberto via notificação)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
  }

  void _handleForeground(RemoteMessage message) {
    FlutterLocalNotificationsPlugin().show(
      0, message.notification?.title, message.notification?.body,
      const NotificationDetails(/* channel setup */),
    );
  }

  void _handleTap(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null) getIt<AppRouter>().router.push(route);
  }
}
```

---

## Theme — Design System Tokens

```dart
// core/theme/app_colors.dart
class AppColors {
  static const primary    = Color(0xFF00796B);   // Teal 700
  static const onPrimary  = Color(0xFFFFFFFF);
  static const secondary  = Color(0xFF004D40);   // Teal 900
  static const accent     = Color(0xFFF59E0B);   // Amber 400
  static const background = Color(0xFFF5F7FA);
  static const surface    = Color(0xFFFFFFFF);
  static const error      = Color(0xFFDC2626);

  // Status badges
  static const statusAberta      = Color(0xFF16A34A);
  static const statusAtribuida   = Color(0xFF2563EB);
  static const statusConcluida   = Color(0xFF6B7280);
  static const statusCancelada   = Color(0xFFDC2626);
  static const statusRascunho    = Color(0xFFD97706);
}

// core/theme/app_theme.dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
```

---

## Shared Widgets — Padrões

### LoadingOverlay — Regra crítica: sempre feedback visual
```dart
// shared/widgets/loading_overlay.dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay({required this.isLoading, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
```

### StatusBadge
```dart
// shared/widgets/status_chip.dart
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  static const _colors = {
    'aberta':      AppColors.statusAberta,
    'atribuida':   AppColors.statusAtribuida,
    'concluida':   AppColors.statusConcluida,
    'cancelada':   AppColors.statusCancelada,
    'rascunho':    AppColors.statusRascunho,
    'em_candidatura': Color(0xFF7C3AED),
    'em_execucao':    Color(0xFF0891B2),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
```

---

## i18n — intl + ARB

```yaml
# pubspec.yaml — adicionar:
flutter:
  generate: true

# l10n.yaml (raiz do projeto):
arb-dir: lib/l10n
template-arb-file: app_pt_BR.arb
output-localization-file: app_localizations.dart
```

```dart
// Uso nas pages:
Text(AppLocalizations.of(context)!.feedTitle)

// Acesso curto via extension:
extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
// Uso: context.l10n.feedTitle
```

---

## Bottom Navigation — AppScaffold

```dart
// shared/widgets/app_scaffold.dart
class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({required this.child, super.key});

  static const _destinations = [
    (icon: Icons.work_outline, label: 'Oportunidades', route: AppRoutes.feed),
    (icon: Icons.campaign_outlined, label: 'Comunicados', route: AppRoutes.comunicados),
    (icon: Icons.payment_outlined, label: 'Cotas', route: AppRoutes.cotas),
    (icon: Icons.person_outline, label: 'Perfil', route: AppRoutes.perfil),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _destinations.indexWhere(
      (d) => location.startsWith(d.route),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (i) => context.go(_destinations[i].route),
        destinations: _destinations.map((d) => NavigationDestination(
          icon: Icon(d.icon), label: d.label,
        )).toList(),
      ),
    );
  }
}
```

---

## Checklist de Assimilação

- [x] Flutter 3.27 + Dart 3.6 (null-safe, sealed classes, pattern matching)
- [x] supabase_flutter v2.8+ — Auth, PostgrestClient, RealtimeChannel, Storage
- [x] flutter_bloc v8 — BLoC + Cubit, BlocProvider/BlocBuilder, sealed states
- [x] go_router v14 — ShellRoute, redirect guards, GoRouterState
- [x] fpdart — Either<Failure, T>, Right/Left, fold(), Unit
- [x] get_it + injectable — @injectable, @singleton, @module, build_runner codegen
- [x] freezed — @freezed, @JsonSerializable, sealed classes, copyWith
- [x] envied — obfuscate: true para Supabase keys
- [x] FCM + flutter_local_notifications — foreground/background/tap handling
- [x] Design System tokens → AppTheme + AppColors
