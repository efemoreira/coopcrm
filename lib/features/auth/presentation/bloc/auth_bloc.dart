// Gerenciamento de estado de autenticação da aplicação.
//
// Eventos: [AuthCheckRequested], [AuthSignInRequested], [AuthSignOutRequested], [AuthResetPasswordRequested]
// Estados: [AuthInitial] → [AuthLoading] → [AuthAuthenticated] | [AuthUnauthenticated] | [AuthError]
//
// O [AppRouter] escuta o stream deste bloc para redirecionar
// entre `/login` e `/feed` automaticamente.
import 'package:equatable/equatable.dart';
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
final class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  const AuthResetPasswordRequested(this.email);
  @override List<Object> get props => [email];
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
final class AuthResetPasswordSent extends AuthState {
  const AuthResetPasswordSent();
}

// BLOC
/// BLoC singleton de autenticação. Usado pelo [AppRouter] e por toda
/// a árvore de widgets para derivar o usuário atual via [AuthAuthenticated.user].
@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;
  final AuthRepository _authRepo;

  AuthBloc(this._signIn, this._signOut, this._authRepo) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthResetPasswordRequested>(_onResetPassword);
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

  Future<void> _onResetPassword(AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepo.resetPassword(event.email);
    result.fold(
      (f) => emit(AuthError(f.message)),
      (_) => emit(const AuthResetPasswordSent()),
    );
  }
}
