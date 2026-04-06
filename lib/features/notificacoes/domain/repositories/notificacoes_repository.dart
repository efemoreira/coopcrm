import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/notificacao_entity.dart';

/// Contrato de acesso ao histórico de notificações persistidas do usuário.
abstract class NotificacoesRepository {
  Future<Either<Failure, List<NotificacaoEntity>>> getByUser(String userId);
}
