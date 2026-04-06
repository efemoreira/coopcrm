import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa o usuário autenticado.
/// Combina dados do Supabase Auth com os dados da tabela `cooperados`.
/// [isAdmin] diferencia administrador de cooperado comum.
/// [isInadimplente] bloqueia candidaturas enquanto `status == 'inadimplente'`.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String nome;
  final String? fotoUrl;
  final String? cooperadoId;
  final String? cooperativeId;
  final bool isAdmin;
  /// 'ativo' | 'inadimplente' | 'suspenso' | 'inativo'
  final String status;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nome,
    this.fotoUrl,
    this.cooperadoId,
    this.cooperativeId,
    this.isAdmin = false,
    this.status = 'ativo',
  });

  bool get isInadimplente => status == 'inadimplente';

  @override
  List<Object?> get props => [id, email, nome, cooperadoId, cooperativeId, isAdmin, status];
}
