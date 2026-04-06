import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/oportunidade_entity.dart';
import '../../domain/entities/candidatura_entity.dart';
import '../../domain/repositories/oportunidades_repository.dart';
import '../datasources/supabase_oportunidades_datasource.dart';

/// Implementação concreta de [OportunidadesRepository] usando Supabase.
/// Delega às operações do [SupabaseOportunidadesDatasource] e converte
/// exceções em [Failure] para manter o domínio desacoplado do Supabase.
@Injectable(as: OportunidadesRepository)
class OportunidadesRepositoryImpl implements OportunidadesRepository {
  final SupabaseOportunidadesDatasource _ds;
  OportunidadesRepositoryImpl(this._ds);

  @override
  Stream<List<OportunidadeEntity>> watchFeed({required String cooperativeId}) {
    return _ds.watchFeed(cooperativeId).map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, OportunidadeEntity>> getById(String id) async {
    try {
      final model = await _ds.getById(id);
      return Right(model.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<CandidaturaEntity>>> getCandidatos(String id) async {
    try {
      final models = await _ds.getCandidatos(id);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getMinhaCandidaturaOportunidadeIds(String cooperadoId) async {
    try {
      return Right(await _ds.getMinhaCandidaturaOportunidadeIds(cooperadoId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OportunidadeEntity>>> getMeuHistorico(String cooperadoId) async {
    try {
      final models = await _ds.getMeuHistorico(cooperadoId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  }) async {
    try {
      await _ds.candidatar(
        oportunidadeId: oportunidadeId,
        cooperadoId: cooperadoId,
        mensagem: mensagem,
      );
      return const Right(unit);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return const Left(ServerFailure('Você já se candidatou a esta oportunidade.'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> desistir(String candidaturaId) async {
    try {
      await _ds.desistir(candidaturaId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OportunidadeEntity>> criar(CriarOportunidadeParams params) async {
    try {
      final model = await _ds.criar(params);
      return Right(model.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> atribuirManual({
    required String oportunidadeId,
    required List<String> candidaturaIds,
    required String atribuidoPor,
  }) async {
    try {
      await _ds.atribuirManual(
        oportunidadeId: oportunidadeId,
        candidaturaIds: candidaturaIds,
        atribuidoPor: atribuidoPor,
      );
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> atualizarStatus({
    required String oportunidadeId,
    required String novoStatus,
    String? motivo,
  }) async {
    try {
      await _ds.atualizarStatus(
        oportunidadeId: oportunidadeId,
        novoStatus: novoStatus,
        motivo: motivo,
      );
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> avaliar({
    required String oportunidadeId,
    required String cooperadoId,
    required int nota,
    String? comentario,
  }) async {
    try {
      await _ds.avaliar(
        oportunidadeId: oportunidadeId,
        cooperadoId: cooperadoId,
        nota: nota,
        comentario: comentario,
      );
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<CandidaturaEntity>>> getCandidaturasByCooperado(String cooperadoId) async {
    try {
      final rows = await _ds.getCandidaturasByCooperado(cooperadoId);
      return Right(rows.map(_candidaturaFromRow).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  CandidaturaEntity _candidaturaFromRow(Map<String, dynamic> row) {
    final oport = row['oportunidade'] as Map<String, dynamic>?;
    return CandidaturaEntity(
      id: row['id'] as String,
      oportunidadeId: row['oportunidade_id'] as String,
      cooperadoId: row['cooperado_id'] as String,
      status: row['status'] as String? ?? 'aguardando',
      createdAt: DateTime.parse(row['created_at'] as String),
      oportunidadeTitulo: oport?['titulo'] as String?,
      oportunidadeStatus: oport?['status'] as String?,
      oportunidadeTipo: oport?['tipo'] as String?,
    );
  }

  @override
  Future<Either<Failure, double>> getAvaliacaoMedia(String cooperadoId) async {
    try {
      final media = await _ds.getAvaliacaoMedia(cooperadoId);
      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
