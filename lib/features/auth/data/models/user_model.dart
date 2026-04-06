import '../../domain/entities/user_entity.dart';

/// DTO (Data Transfer Object) de usuário para a camada de dados.
/// Converte os dados brutos de Supabase Auth + tabela `cooperados` para [UserEntity].
class UserModel {
  final String id;
  final String email;
  final String nome;
  final String? fotoUrl;
  final String? cooperadoId;
  final String? cooperativeId;
  final bool isAdmin;
  final String status;

  const UserModel({
    required this.id,
    required this.email,
    required this.nome,
    this.fotoUrl,
    this.cooperadoId,
    this.cooperativeId,
    this.isAdmin = false,
    this.status = 'ativo',
  });

  /// Constrói um [UserModel] a partir dos dados do Supabase Auth e do join com `cooperados`.
  factory UserModel.fromSupabase({
    required String id,
    required String email,
    Map<String, dynamic>? cooperadoData,
  }) {
    return UserModel(
      id: id,
      email: email,
      nome: cooperadoData?['nome'] as String? ?? email.split('@').first,
      fotoUrl: cooperadoData?['foto_url'] as String?,
      cooperadoId: cooperadoData?['id'] as String?,
      cooperativeId: cooperadoData?['cooperative_id'] as String?,
      isAdmin: cooperadoData?['is_admin'] as bool? ?? false,
      status: cooperadoData?['status'] as String? ?? 'ativo',
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    nome: nome,
    fotoUrl: fotoUrl,
    cooperadoId: cooperadoId,
    cooperativeId: cooperativeId,
    isAdmin: isAdmin,
    status: status,
  );
}
