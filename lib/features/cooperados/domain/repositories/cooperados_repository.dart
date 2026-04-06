import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/cooperado_entity.dart';

/// Contrato de gestão de cooperados (CRUD + mudança de status).
abstract class CooperadosRepository {
  Future<Either<Failure, List<CooperadoEntity>>> getAll(String cooperativeId);

  Future<Either<Failure, CooperadoEntity>> criar(CriarCooperadoParams params);

  Future<Either<Failure, Unit>> updateStatus({
    required String cooperadoId,
    required String status,
  });

  Future<Either<Failure, Unit>> editar(EditarCooperadoParams params);

  Future<Either<Failure, Unit>> deletar(String cooperadoId);
}

class CriarCooperadoParams {
  final String cooperativeId;
  final String nome;
  final String cpf;
  final String email;
  final String? password;
  final String? telefone;
  final List<String> especialidades;
  final DateTime? dataAdmissao;

  const CriarCooperadoParams({
    required this.cooperativeId,
    required this.nome,
    required this.cpf,
    required this.email,
    this.password,
    this.telefone,
    this.especialidades = const [],
    this.dataAdmissao,
  });
}

class EditarCooperadoParams {
  final String cooperadoId;
  final String nome;
  final String? telefone;
  final List<String> especialidades;

  const EditarCooperadoParams({
    required this.cooperadoId,
    required this.nome,
    this.telefone,
    this.especialidades = const [],
  });
}
