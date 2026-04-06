import '../../domain/entities/cooperado_entity.dart';

/// DTO de cooperado.
/// Mapeia a tabela `cooperados` do Supabase para [CooperadoEntity].
/// `especialidades` vem como `List<dynamic>` do JSON e é convertido para `List<String>`.
class CooperadoModel {
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

  const CooperadoModel({
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

  factory CooperadoModel.fromJson(Map<String, dynamic> json) {
    return CooperadoModel(
      id: json['id'] as String,
      cooperativeId: json['cooperative_id'] as String,
      userId: json['user_id'] as String,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String?,
      fotoUrl: json['foto_url'] as String?,
      status: json['status'] as String? ?? 'ativo',
      numCota: json['num_cota'] as int? ?? 0,
      especialidades: (json['especialidades'] as List<dynamic>? ?? []).cast<String>(),
      dataAdmissao: json['data_admissao'] != null
          ? DateTime.tryParse(json['data_admissao'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CooperadoEntity toEntity() => CooperadoEntity(
    id: id,
    cooperativeId: cooperativeId,
    userId: userId,
    nome: nome,
    cpf: cpf,
    email: email,
    telefone: telefone,
    fotoUrl: fotoUrl,
    status: status,
    numCota: numCota,
    especialidades: especialidades,
    dataAdmissao: dataAdmissao,
    createdAt: createdAt,
  );
}
