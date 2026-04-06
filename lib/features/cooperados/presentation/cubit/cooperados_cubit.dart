// Cubit de gestão de cooperados.
// Exposto para as telas de listagem, criação e edição de cooperados (admin).
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/cooperado_entity.dart';
import '../../domain/repositories/cooperados_repository.dart';

sealed class CooperadosState extends Equatable {
  const CooperadosState();
  @override List<Object?> get props => [];
}
final class CooperadosInitial extends CooperadosState { const CooperadosInitial(); }
final class CooperadosLoading extends CooperadosState { const CooperadosLoading(); }
final class CooperadosLoaded extends CooperadosState {
  final List<CooperadoEntity> items;
  const CooperadosLoaded(this.items);
  @override List<Object?> get props => [items];
}
final class CooperadosError extends CooperadosState {
  final String message;
  const CooperadosError(this.message);
  @override List<Object?> get props => [message];
}
final class CooperadosMutated extends CooperadosState {
  final String message;
  const CooperadosMutated(this.message);
  @override List<Object?> get props => [message];
}

/// Cubit de gerenciamento de cooperados. Instância por sessão (não singleton).
@injectable
class CooperadosCubit extends Cubit<CooperadosState> {
  final CooperadosRepository _repository;
  String _cooperativeId = '';
  CooperadosCubit(this._repository) : super(const CooperadosInitial());

  Future<void> load(String cooperativeId) async {
    _cooperativeId = cooperativeId;
    emit(const CooperadosLoading());
    final result = await _repository.getAll(cooperativeId);
    result.fold(
      (f) => emit(CooperadosError(f.message)),
      (items) => emit(CooperadosLoaded(items)),
    );
  }

  Future<void> criar(CriarCooperadoParams params) async {
    final result = await _repository.criar(params);
    result.fold(
      (f) => emit(CooperadosError(f.message)),
      (_) async {
        emit(const CooperadosMutated('Cooperado criado com sucesso!'));
        await load(_cooperativeId);
      },
    );
  }

  Future<void> updateStatus({required String cooperadoId, required String status}) async {
    final result = await _repository.updateStatus(
      cooperadoId: cooperadoId,
      status: status,
    );
    result.fold(
      (f) => emit(CooperadosError(f.message)),
      (_) async {
        emit(CooperadosMutated('Status atualizado!'));
        await load(_cooperativeId);
      },
    );
  }

  Future<void> editar(EditarCooperadoParams params) async {
    final result = await _repository.editar(params);
    result.fold(
      (f) => emit(CooperadosError(f.message)),
      (_) async {
        emit(const CooperadosMutated('Cooperado atualizado!'));
        await load(_cooperativeId);
      },
    );
  }

  Future<void> deletar(String cooperadoId) async {
    final result = await _repository.deletar(cooperadoId);
    result.fold(
      (f) => emit(CooperadosError(f.message)),
      (_) async {
        emit(const CooperadosMutated('Cooperado removido.'));
        await load(_cooperativeId);
      },
    );
  }
}
