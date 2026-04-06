import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/comunicado_entity.dart';

/// Contrato de comunicação interna: listagem, marcar como lido e criação.
abstract class ComunicadosRepository {
  Future<Either<Failure, List<ComunicadoEntity>>> getAll({
    required String cooperativeId,
    String? cooperadoId,
  });

  Future<Either<Failure, Unit>> marcarLido({
    required String comunicadoId,
    required String cooperadoId,
  });

  Future<Either<Failure, ComunicadoEntity>> criar(CriarComunicadoParams params);
}

class CriarComunicadoParams {
  final String cooperativeId;
  final String titulo;
  final String conteudo;
  final String tipo;
  final bool pinned;
  final String autorId;
  final String? anexoUrl;
  /// CA-11-2: null = todos os cooperados; lista de IDs = subgrupo específico
  final List<String>? destinatarioIds;

  const CriarComunicadoParams({
    required this.cooperativeId,
    required this.titulo,
    required this.conteudo,
    this.tipo = 'aviso',
    this.pinned = false,
    required this.autorId,
    this.anexoUrl,
    this.destinatarioIds,
  });
}
