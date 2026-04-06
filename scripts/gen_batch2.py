#!/usr/bin/env python3
"""Batch 2 — Shared Widgets + Auth Feature."""
import os

BASE = "/Users/felipemoreira/development/opensquads/agentcode/opensquad/squads/software-factory/output/2026-04-05-223053/coopcrm/lib"

def write(rel_path, content):
    full = os.path.join(BASE, rel_path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content)
    print(f"OK: {rel_path}")

# ========================================================
# BATCH 2 — SHARED WIDGETS
# ========================================================

write("shared/widgets/loading_overlay.dart", """import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
""")

write("shared/widgets/status_chip.dart", """import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  static const _colors = {
    'rascunho':       AppColors.statusRascunho,
    'aberta':         AppColors.statusAberta,
    'em_candidatura': AppColors.statusEmCandidatura,
    'atribuida':      AppColors.statusAtribuida,
    'em_execucao':    AppColors.statusEmExecucao,
    'concluida':      AppColors.statusConcluida,
    'cancelada':      AppColors.statusCancelada,
  };

  static const _labels = {
    'rascunho':       'Rascunho',
    'aberta':         'Aberta',
    'em_candidatura': 'Em candidatura',
    'atribuida':      'Atribuída',
    'em_execucao':    'Em execução',
    'concluida':      'Concluída',
    'cancelada':      'Cancelada',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? Colors.grey;
    final label = _labels[status] ?? status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}
""")

write("shared/widgets/app_text_field.dart", """import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final bool enabled;

  const AppTextField({
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon, prefixIcon: prefixIcon),
        ),
      ],
    );
  }
}
""")

write("shared/widgets/empty_state.dart", """import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
""")

write("shared/widgets/app_scaffold.dart", """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({required this.child, super.key});

  static const _destinations = [
    _NavItem(icon: Icons.work_outline, activeIcon: Icons.work, label: 'Oportunidades', route: AppRoutes.feed),
    _NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign, label: 'Comunicados', route: AppRoutes.comunicados),
    _NavItem(icon: Icons.payment_outlined, activeIcon: Icons.payment, label: 'Cotas', route: AppRoutes.cotas),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil', route: AppRoutes.perfil),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _destinations.indexWhere((d) => location.startsWith(d.route));
    final index = currentIndex < 0 ? 0 : currentIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_destinations[i].route),
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.route});
}
""")

write("shared/widgets/error_display.dart", """import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorDisplay({required this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
""")

# ========================================================
# BATCH 2 — AUTH FEATURE
# ========================================================

write("features/auth/domain/entities/user_entity.dart", """import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? cooperadoId;
  final String? cooperativeId;
  final bool isAdmin;

  const UserEntity({
    required this.id,
    required this.email,
    this.cooperadoId,
    this.cooperativeId,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [id, email, cooperadoId, cooperativeId, isAdmin];
}
""")

write("features/auth/domain/repositories/auth_repository.dart", """import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
""")

write("features/auth/domain/usecases/sign_in_usecase.dart", """import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
}

@injectable
class SignInUseCase {
  final AuthRepository _repository;
  SignInUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(SignInParams params) =>
      _repository.signIn(email: params.email, password: params.password);
}
""")

write("features/auth/domain/usecases/sign_out_usecase.dart", """import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignOutUseCase {
  final AuthRepository _repository;
  SignOutUseCase(this._repository);

  Future<Either<Failure, Unit>> call() => _repository.signOut();
}
""")

write("features/auth/data/models/user_model.dart", """import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String? cooperadoId;
  final String? cooperativeId;
  final bool isAdmin;

  const UserModel({
    required this.id,
    required this.email,
    this.cooperadoId,
    this.cooperativeId,
    this.isAdmin = false,
  });

  factory UserModel.fromSupabase({
    required String id,
    required String email,
    Map<String, dynamic>? cooperadoData,
  }) {
    return UserModel(
      id: id,
      email: email,
      cooperadoId: cooperadoData?['id'] as String?,
      cooperativeId: cooperadoData?['cooperative_id'] as String?,
      isAdmin: cooperadoData?['is_admin'] as bool? ?? false,
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    cooperadoId: cooperadoId,
    cooperativeId: cooperativeId,
    isAdmin: isAdmin,
  );
}
""")

write("features/auth/data/datasources/supabase_auth_datasource.dart", """import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

@injectable
class SupabaseAuthDatasource {
  final SupabaseClient _client;
  SupabaseAuthDatasource(@Named('supabase') this._client);

  Future<UserModel> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw const AuthException('Falha ao autenticar');
    final cooperado = await _fetchCooperado(user.id);
    return UserModel.fromSupabase(id: user.id, email: user.email ?? email, cooperadoData: cooperado);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final cooperado = await _fetchCooperado(user.id);
    return UserModel.fromSupabase(
      id: user.id,
      email: user.email ?? '',
      cooperadoData: cooperado,
    );
  }

  Future<Map<String, dynamic>?> _fetchCooperado(String userId) async {
    try {
      final response = await _client
          .from('cooperados')
          .select('id, cooperative_id, is_admin, nome')
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
""")

write("features/auth/data/repositories/auth_repository_impl.dart", """import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDatasource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _ds.signIn(email: email, password: password);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _ds.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final model = await _ds.getCurrentUser();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
""")

write("features/auth/presentation/bloc/auth_bloc.dart", """import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

// EVENTS
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object> get props => [];
}
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
final class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
  @override List<Object> get props => [email, password];
}
final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

// STATES
sealed class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}
final class AuthInitial extends AuthState {
  const AuthInitial();
}
final class AuthLoading extends AuthState {
  const AuthLoading();
}
final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override List<Object> get props => [user];
}
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object> get props => [message];
}

// BLOC
@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;
  final AuthRepository _authRepo;

  AuthBloc(this._signIn, this._signOut, this._authRepo) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheck(AuthCheckRequested _, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepo.getCurrentUser();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signIn(SignInParams(email: event.email, password: event.password));
    result.fold(
      (f) => emit(AuthError(f.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(AuthSignOutRequested _, Emitter<AuthState> emit) async {
    await _signOut();
    emit(const AuthUnauthenticated());
  }
}
""")

write("features/auth/presentation/pages/login_page.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return LoadingOverlay(
          isLoading: state is AuthLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo / App illustration
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.handshake_outlined, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'CoopCRM',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestão cooperativa simplificada',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entrar',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.email,
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  validator: (v) => Validators.minLength(v, 6),
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: state is AuthLoading ? null : _submit,
                                  child: state is AuthLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Entrar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
""")

print("BATCH 2 DONE")
