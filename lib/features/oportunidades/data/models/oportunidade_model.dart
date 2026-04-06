import '../../domain/entities/oportunidade_entity.dart';

/// DTO de oportunidade de serviço.
/// `fromJson` mapeia os dados da tabela `oportunidades` (com join `criado_por`).
/// `toJson` serializa para cache local offline.
class OportunidadeModel {
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
  final String? criadorNome;
  final String? criadorFoto;
  final DateTime createdAt;

  const OportunidadeModel({
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
    this.criadorNome,
    this.criadorFoto,
    required this.createdAt,
  });

  factory OportunidadeModel.fromJson(Map<String, dynamic> json) {
    final criador = json['criado_por'] as Map<String, dynamic>?;
    return OportunidadeModel(
      id: json['id'] as String,
      cooperativeId: json['cooperative_id'] as String,
      titulo: json['titulo'] as String,
      tipo: json['tipo'] as String,
      descricao: json['descricao'] as String?,
      status: json['status'] as String,
      prazoCandidata: DateTime.parse(json['prazo_candidatura'] as String),
      dataExecucao: json['data_execucao'] != null
          ? DateTime.parse(json['data_execucao'] as String)
          : null,
      local: json['local'] as String?,
      valorEstimado: (json['valor_estimado'] as num?)?.toDouble(),
      numVagas: json['num_vagas'] as int,
      requisitos: json['requisitos'] as String?,
      criterioSelecao: json['criterio_selecao'] as String,
      criadorNome: criador?['nome'] as String?,
      criadorFoto: criador?['foto_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// RNF Offline: serializa para cache local
  Map<String, dynamic> toJson() => {
        'id': id,
        'cooperative_id': cooperativeId,
        'titulo': titulo,
        'tipo': tipo,
        'descricao': descricao,
        'status': status,
        'prazo_candidatura': prazoCandidata.toIso8601String(),
        'data_execucao': dataExecucao?.toIso8601String(),
        'local': local,
        'valor_estimado': valorEstimado,
        'num_vagas': numVagas,
        'requisitos': requisitos,
        'criterio_selecao': criterioSelecao,
        'criado_por': criadorNome != null
            ? {'nome': criadorNome, 'foto_url': criadorFoto}
            : null,
        'created_at': createdAt.toIso8601String(),
      };

  OportunidadeEntity toEntity() => OportunidadeEntity(
    id: id,
    cooperativeId: cooperativeId,
    titulo: titulo,
    tipo: tipo,
    descricao: descricao,
    status: status,
    prazoCandidata: prazoCandidata,
    dataExecucao: dataExecucao,
    local: local,
    valorEstimado: valorEstimado,
    numVagas: numVagas,
    requisitos: requisitos,
    criterioSelecao: criterioSelecao,
    isExpired: prazoCandidata.isBefore(DateTime.now()),
    criadorNome: criadorNome,
    criadorFoto: criadorFoto,
    createdAt: createdAt,
  );
}
