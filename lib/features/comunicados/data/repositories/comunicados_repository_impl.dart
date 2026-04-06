import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/comunicado_entity.dart';
import '../../domain/repositories/comunicados_repository.dart';
import '../datasources/supabase_comunicados_datasource.dart';

/// Implementação concreta de [ComunicadosRepository] usando Supabase.
@Injectable(as: ComunicadosRepository)
class ComunicadosRepositoryImpl implements ComunicadosRepository {
  final SupabaseComunicadosDatasource _ds;
  ComunicadosRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<ComunicadoEntity>>> getAll({
    required String cooperativeId,
    String? cooperadoId,
  }) async {
    try {
      final models = await _ds.getAll(
        cooperativeId: cooperativeId,
        cooperadoId: cooperadoId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> marcarLido({
    required String comunicadoId,
    required String cooperadoId,
  }) async {
    try {
      await _ds.marcarLido(comunicadoId: comunicadoId, cooperadoId: cooperadoId);
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ComunicadoEntity>> criar(CriarComunicadoParams params) async {
    try {
      final model = await _ds.criar({
        'cooperative_id': params.cooperativeId,
        'titulo': params.titulo,
        'conteudo': params.conteudo,
        'tipo': params.tipo,
        'pinned': params.pinned,
        'autor_id': params.autorId,
        if (params.anexoUrl != null && params.anexoUrl!.isNotEmpty)
          'anexo_url': params.anexoUrl,
        // CA-11-2: destinatarios específicos (null = todos)
        if (params.destinatarioIds != null && params.destinatarioIds!.isNotEmpty)
          'destinatario_ids': params.destinatarioIds,
      });
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
