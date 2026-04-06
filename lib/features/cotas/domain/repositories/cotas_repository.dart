import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/cota_entity.dart';

/// Contrato de gestão de cotas mensais dos cooperados.
abstract class CotasRepository {
  Future<Either<Failure, List<CotaEntity>>> getByCooperado(String cooperadoId);

  Future<Either<Failure, List<CotaEntity>>> getByCooperativa(String cooperativaId);

  Future<Either<Failure, CotaEntity>> lancarPagamento(LancarPagamentoParams params);
}

class LancarPagamentoParams {
  final String cooperadoId;
  final String cooperativaId;
  final String competencia;
  final double valorDevido;
  final double? valorPago;
  final String status;
  final DateTime? dataPagamento;

  const LancarPagamentoParams({
    required this.cooperadoId,
    required this.cooperativaId,
    required this.competencia,
    required this.valorDevido,
    this.valorPago,
    this.status = 'pendente',
    this.dataPagamento,
  });
}
