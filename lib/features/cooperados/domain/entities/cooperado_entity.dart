import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um membro da cooperativa.
/// [status]: `ativo` | `suspenso` | `inativo` | `inadimplente`.
/// [isAtivo] pode ser usado para filtros rápidos de listas.
class CooperadoEntity extends Equatable {
  final String id;
  final String cooperativeId;
  final String userId;
  final String nome;
  final String cpf;
  final String email;
  final String? telefone;
  final String? fotoUrl;
  final String status;
  final int numCota;
  final List<String> especialidades;
  final DateTime? dataAdmissao;
  final DateTime createdAt;

  const CooperadoEntity({
    required this.id,
    required this.cooperativeId,
    required this.userId,
    required this.nome,
    required this.cpf,
    required this.email,
    this.telefone,
    this.fotoUrl,
    required this.status,
    required this.numCota,
    required this.especialidades,
    this.dataAdmissao,
    required this.createdAt,
  });

  bool get isAtivo => status == 'ativo';

  @override
  List<Object?> get props => [id, status, nome];
}
