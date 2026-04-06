import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/oportunidade_entity.dart';
import '../entities/candidatura_entity.dart';

/// Contrato do repositório de oportunidades e candidaturas.
/// Centraliza toda a lógica de negócio relacionada ao ciclo de vida de uma oportunidade.
abstract class OportunidadesRepository {
  Stream<List<OportunidadeEntity>> watchFeed({required String cooperativeId});

  Future<Either<Failure, OportunidadeEntity>> getById(String id);

  Future<Either<Failure, List<CandidaturaEntity>>> getCandidatos(String oportunidadeId);

  Future<Either<Failure, List<OportunidadeEntity>>> getMeuHistorico(String cooperadoId);

  Future<Either<Failure, Unit>> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  });

  Future<Either<Failure, Unit>> desistir(String candidaturaId);

  Future<Either<Failure, OportunidadeEntity>> criar(CriarOportunidadeParams params);

  Future<Either<Failure, Unit>> atribuirManual({
    required String oportunidadeId,
    required List<String> candidaturaIds,
    required String atribuidoPor,
  });

  Future<Either<Failure, Unit>> atualizarStatus({
    required String oportunidadeId,
    required String novoStatus,
    String? motivo,
  });

  Future<Either<Failure, Unit>> avaliar({
    required String oportunidadeId,
    required String cooperadoId,
    required int nota,
    String? comentario,
  });

  Future<Either<Failure, List<CandidaturaEntity>>> getCandidaturasByCooperado(String cooperadoId);

  /// CA-03-3: IDs de oportunidades às quais o cooperado já se candidatou
  Future<Either<Failure, Set<String>>> getMinhaCandidaturaOportunidadeIds(String cooperadoId);

  /// CA-05-1 / CA-12-1: retorna avaliação média (0.0 se sem avaliações)
  Future<Either<Failure, double>> getAvaliacaoMedia(String cooperadoId);
}

class CriarOportunidadeParams {
  final String cooperativeId;
  final String criadorId;
  final String titulo;
  final String tipo;
  final String? descricao;
  final DateTime prazoCandidata;
  final DateTime? dataExecucao;
  final String? local;
  final double? valorEstimado;
  final int numVagas;
  final String? requisitos;
  final String criterioSelecao;
  /// 'rascunho' ou 'aberta'
  final String status;

  const CriarOportunidadeParams({
    required this.cooperativeId,
    required this.criadorId,
    required this.titulo,
    required this.tipo,
    this.descricao,
    required this.prazoCandidata,
    this.dataExecucao,
    this.local,
    this.valorEstimado,
    required this.numVagas,
    this.requisitos,
    required this.criterioSelecao,
    this.status = 'rascunho',
  });
}
