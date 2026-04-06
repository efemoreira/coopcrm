// Hierarquia de falhas do domínio.
// Toda operação assíncrona de repositório retorna `Either<Failure, T>`.
import 'package:equatable/equatable.dart';

/// Classe base para todas as falhas de domínio.
/// Use as subclasses concretas para comunicar o tipo de erro à camada de apresentação.
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
