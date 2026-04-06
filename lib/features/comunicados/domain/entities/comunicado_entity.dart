import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um comunicado interno da cooperativa.
/// [tipo]: `aviso` | `urgente` | `geral`. [pinned] fixa no topo da lista.
/// [lido] é calculado por cooperado — não é um campo global da tabela.
class ComunicadoEntity extends Equatable {
  final String id;
  final String cooperativeId;
  final String titulo;
  final String conteudo;
  final String tipo;
  final bool pinned;
  final bool lido;
  final String? autorNome;
  final String? autorFoto;
  // CA-11-1: link do anexo opcional (imagem ou PDF)
  final String? anexoUrl;
  final DateTime createdAt;

  const ComunicadoEntity({
    required this.id,
    required this.cooperativeId,
    required this.titulo,
    required this.conteudo,
    required this.tipo,
    required this.pinned,
    required this.lido,
    this.autorNome,
    this.autorFoto,
    this.anexoUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, lido, pinned];
}
