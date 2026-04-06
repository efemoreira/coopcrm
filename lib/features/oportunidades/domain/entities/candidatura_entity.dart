import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa a candidatura de um cooperado a uma oportunidade.
/// [status]: `pendente` | `selecionado` | `rejeitado` | `desistiu` | `confirmado`.
/// Campos opcionais são populados quando buscados com join (ex: nome do cooperado).
class CandidaturaEntity extends Equatable {
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

  const CandidaturaEntity({
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

  @override
  List<Object?> get props => [id, status, cooperadoId];
}
