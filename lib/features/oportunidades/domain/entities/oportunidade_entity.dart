import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa uma oportunidade de serviço.
/// [status]: `rascunho` | `aberta` | `em_candidatura` | `atribuida` | `em_execucao` | `concluida` | `cancelada`.
/// [isExpired]: calculado no modelo — indica se o prazo de candidatura já passou.
class OportunidadeEntity extends Equatable {
  final String id;
  final String cooperativeId;
  final String titulo;
  final String tipo;
  final String? descricao;
  final String status;
  final DateTime prazoCandidata;
  final DateTime? dataExecucao;
  final String? local;
  final double? valorEstimado;
  final int numVagas;
  final String? requisitos;
  final String criterioSelecao;
  final bool isExpired;
  final String? criadorNome;
  final String? criadorFoto;
  final DateTime createdAt;

  const OportunidadeEntity({
    required this.id,
    required this.cooperativeId,
    required this.titulo,
    required this.tipo,
    this.descricao,
    required this.status,
    required this.prazoCandidata,
    this.dataExecucao,
    this.local,
    this.valorEstimado,
    required this.numVagas,
    this.requisitos,
    required this.criterioSelecao,
    required this.isExpired,
    this.criadorNome,
    this.criadorFoto,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, status, titulo, prazoCandidata];
}
