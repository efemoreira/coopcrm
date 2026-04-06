import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um lançamento de cota mensal.
/// [competencia]: formato `YYYY-MM` (ex: `2026-04`).
/// [status]: `pendente` | `pago` | `em_atraso`.
class CotaEntity extends Equatable {
  final String id;
  final String cooperadoId;
  final String? cooperadoNome;
  final String cooperativaId;
  final String competencia;
  final double valorDevido;
  final double? valorPago;
  final String status;
  final DateTime? dataPagamento;
  final String? comprovanteUrl;
  final DateTime createdAt;

  const CotaEntity({
    required this.id,
    required this.cooperadoId,
    this.cooperadoNome,
    required this.cooperativaId,
    required this.competencia,
    required this.valorDevido,
    this.valorPago,
    required this.status,
    this.dataPagamento,
    this.comprovanteUrl,
    required this.createdAt,
  });

  bool get isPago => status == 'pago';
  bool get isEmAtraso => status == 'em_atraso';

  @override
  List<Object?> get props => [id, status, competencia, cooperadoNome];
}
