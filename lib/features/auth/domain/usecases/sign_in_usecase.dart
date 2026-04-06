import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Parâmetros de entrada para o caso de uso de login.
class SignInParams {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
}

/// Caso de uso: autentica o usuário com e-mail e senha via Supabase Auth.
/// Retorna [UserEntity] com dados do cooperado vinculado.
@injectable
class SignInUseCase {
  final AuthRepository _repository;
  SignInUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(SignInParams params) =>
      _repository.signIn(email: params.email, password: params.password);
}
