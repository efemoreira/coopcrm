import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cooperado_entity.dart';
import '../../domain/repositories/cooperados_repository.dart';
import '../datasources/supabase_cooperados_datasource.dart';

/// Implementação concreta de [CooperadosRepository] usando Supabase.
@Injectable(as: CooperadosRepository)
class CooperadosRepositoryImpl implements CooperadosRepository {
  final SupabaseCooperadosDatasource _ds;
  CooperadosRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<CooperadoEntity>>> getAll(String cooperativeId) async {
    try {
      final models = await _ds.getAll(cooperativeId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CooperadoEntity>> criar(CriarCooperadoParams params) async {
    try {
      final model = await _ds.criar({
        'cooperative_id': params.cooperativeId,
        'nome': params.nome,
        'cpf': params.cpf,
        'email': params.email,
        if (params.telefone != null) 'telefone': params.telefone,
        'especialidades': params.especialidades,
        if (params.dataAdmissao != null)
          'data_admissao': params.dataAdmissao!.toIso8601String(),
        'status': 'ativo',
        'num_cota': 1,
      });
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStatus({
    required String cooperadoId,
    required String status,
  }) async {
    try {
      await _ds.updateStatus(cooperadoId: cooperadoId, status: status);
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> editar(EditarCooperadoParams params) async {
    try {
      await _ds.editar(
        cooperadoId: params.cooperadoId,
        nome: params.nome,
        telefone: params.telefone,
        especialidades: params.especialidades,
      );
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletar(String cooperadoId) async {
    try {
      await _ds.deletar(cooperadoId);
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
