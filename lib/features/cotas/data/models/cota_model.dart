import '../../domain/entities/cota_entity.dart';

/// DTO de cota mensal.
/// Mapeia a tabela `cotas_pagamentos` do Supabase para [CotaEntity].
class CotaModel {
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

  const CotaModel({
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

  factory CotaModel.fromJson(Map<String, dynamic> json) {
    final cooperadoMap = json['cooperado'] as Map<String, dynamic>?;
    return CotaModel(
      id: json['id'] as String,
      cooperadoId: json['cooperado_id'] as String,
      cooperadoNome: cooperadoMap?['nome'] as String?,
      cooperativaId: json['cooperative_id'] as String,
      competencia: json['competencia'] as String,
      valorDevido: (json['valor_devido'] as num).toDouble(),
      valorPago: (json['valor_pago'] as num?)?.toDouble(),
      status: json['status'] as String,
      dataPagamento: json['data_pagamento'] != null
          ? DateTime.parse(json['data_pagamento'] as String)
          : null,
      comprovanteUrl: json['comprovante_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CotaEntity toEntity() => CotaEntity(
    id: id,
    cooperadoId: cooperadoId,
    cooperadoNome: cooperadoNome,
    cooperativaId: cooperativaId,
    competencia: competencia,
    valorDevido: valorDevido,
    valorPago: valorPago,
    status: status,
    dataPagamento: dataPagamento,
    comprovanteUrl: comprovanteUrl,
    createdAt: createdAt,
  );
}
