import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cota_entity.dart';
import '../../domain/repositories/cotas_repository.dart';
import '../datasources/supabase_cotas_datasource.dart';

/// Implementação concreta de [CotasRepository] usando Supabase.
@Injectable(as: CotasRepository)
class CotasRepositoryImpl implements CotasRepository {
  final SupabaseCotasDatasource _ds;
  CotasRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<CotaEntity>>> getByCooperado(String cooperadoId) async {
    try {
      final models = await _ds.getByCooperado(cooperadoId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CotaEntity>>> getByCooperativa(String cooperativaId) async {
    try {
      final models = await _ds.getByCooperativa(cooperativaId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CotaEntity>> lancarPagamento(LancarPagamentoParams params) async {
    try {
      final model = await _ds.lancarPagamento({
        'cooperado_id': params.cooperadoId,
        'cooperativa_id': params.cooperativaId,
        'competencia': params.competencia,
        'valor_devido': params.valorDevido,
        if (params.valorPago != null) 'valor_pago': params.valorPago,
        'status': params.status,
        if (params.dataPagamento != null)
          'data_pagamento': params.dataPagamento!.toIso8601String(),
      });
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
