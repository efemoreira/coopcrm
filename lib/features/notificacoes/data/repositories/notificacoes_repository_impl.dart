import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notificacao_entity.dart';
import '../../domain/repositories/notificacoes_repository.dart';
import '../datasources/supabase_notificacoes_datasource.dart';

/// Implementação concreta de [NotificacoesRepository] usando Supabase.
@Injectable(as: NotificacoesRepository)
class NotificacoesRepositoryImpl implements NotificacoesRepository {
  final SupabaseNotificacoesDatasource _ds;
  NotificacoesRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<NotificacaoEntity>>> getByUser(String userId) async {
    try {
      final models = await _ds.getByUser(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
