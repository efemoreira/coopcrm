import '../../domain/entities/comunicado_entity.dart';

/// DTO de comunicado interno.
/// O campo [lido] não vem diretamente da tabela `comunicados` —
/// é calculado pelo datasource via join com `leituras_comunicados`.
class ComunicadoModel {
  final String id;
  final String cooperativeId;
  final String titulo;
  final String conteudo;
  final String tipo;
  final bool pinned;
  final bool lido;
  // CA-11-1: link do anexo opcional
  final String? anexoUrl;
  final DateTime createdAt;

  const ComunicadoModel({
    required this.id,
    required this.cooperativeId,
    required this.titulo,
    required this.conteudo,
    required this.tipo,
    required this.pinned,
    required this.lido,
    this.anexoUrl,
    required this.createdAt,
  });

  factory ComunicadoModel.fromJson(Map<String, dynamic> json, {bool lido = false}) {
    return ComunicadoModel(
      id: json['id'] as String,
      cooperativeId: json['cooperative_id'] as String,
      titulo: json['titulo'] as String,
      conteudo: json['conteudo'] as String,
      tipo: json['tipo'] as String? ?? 'geral',
      pinned: json['pinned'] as bool? ?? false,
      lido: lido,
      anexoUrl: json['anexo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ComunicadoEntity toEntity() => ComunicadoEntity(
    id: id,
    cooperativeId: cooperativeId,
    titulo: titulo,
    conteudo: conteudo,
    tipo: tipo,
    pinned: pinned,
    lido: lido,
    anexoUrl: anexoUrl,
    createdAt: createdAt,
  );
}
