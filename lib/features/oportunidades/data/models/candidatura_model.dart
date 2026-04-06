import '../../domain/entities/candidatura_entity.dart';

/// DTO de candidatura.
/// `fromJson` suporta join com `cooperados` e `oportunidades` para exibir
/// nome/foto/título sem queries adicionais.
class CandidaturaModel {
  final String id;
  final String oportunidadeId;
  final String cooperadoId;
  final String status;
  final DateTime createdAt;
  final String? cooperadoNome;
  final String? cooperadoFoto;
  final String? mensagem;
  final String? oportunidadeTitulo;
  final String? oportunidadeStatus;
  final String? oportunidadeTipo;

  const CandidaturaModel({
    required this.id,
    required this.oportunidadeId,
    required this.cooperadoId,
    required this.status,
    required this.createdAt,
    this.cooperadoNome,
    this.cooperadoFoto,
    this.mensagem,
    this.oportunidadeTitulo,
    this.oportunidadeStatus,
    this.oportunidadeTipo,
  });

  factory CandidaturaModel.fromJson(Map<String, dynamic> json) {
    final cooperado = json['cooperado'] as Map<String, dynamic>?;
    final oport = json['oportunidade'] as Map<String, dynamic>?;
    return CandidaturaModel(
      id: json['id'] as String,
      oportunidadeId: json['oportunidade_id'] as String,
      cooperadoId: json['cooperado_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      cooperadoNome: cooperado?['nome'] as String?,
      cooperadoFoto: cooperado?['foto_url'] as String?,
      mensagem: json['mensagem'] as String?,
      oportunidadeTitulo: oport?['titulo'] as String?,
      oportunidadeStatus: oport?['status'] as String?,
      oportunidadeTipo: oport?['tipo'] as String?,
    );
  }

  CandidaturaEntity toEntity() => CandidaturaEntity(
    id: id,
    oportunidadeId: oportunidadeId,
    cooperadoId: cooperadoId,
    status: status,
    createdAt: createdAt,
    cooperadoNome: cooperadoNome,
    cooperadoFoto: cooperadoFoto,
    mensagem: mensagem,
    oportunidadeTitulo: oportunidadeTitulo,
    oportunidadeStatus: oportunidadeStatus,
    oportunidadeTipo: oportunidadeTipo,
  );
}
