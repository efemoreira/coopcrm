// Cubit de comunicados internos da cooperativa.
// Gerencia lista, marcar como lido e criação de novos comunicados (admin).
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/comunicado_entity.dart';
import '../../domain/repositories/comunicados_repository.dart';

sealed class ComunicadosState extends Equatable {
  const ComunicadosState();
  @override List<Object?> get props => [];
}
final class ComunicadosInitial extends ComunicadosState { const ComunicadosInitial(); }
final class ComunicadosLoading extends ComunicadosState { const ComunicadosLoading(); }
final class ComunicadosLoaded extends ComunicadosState {
  final List<ComunicadoEntity> items;
  const ComunicadosLoaded(this.items);
  @override List<Object?> get props => [items];
}
final class ComunicadosError extends ComunicadosState {
  final String message;
  const ComunicadosError(this.message);
  @override List<Object?> get props => [message];
}
final class ComunicadosMutated extends ComunicadosState {
  final String message;
  const ComunicadosMutated(this.message);
  @override List<Object?> get props => [message];
}

/// Cubit de comunicados. Instância por tela.
@injectable
class ComunicadosCubit extends Cubit<ComunicadosState> {
  final ComunicadosRepository _repository;
  String _cooperativeId = '';
  String? _cooperadoId;
  ComunicadosCubit(this._repository) : super(const ComunicadosInitial());

  Future<void> load(String cooperativeId, {String? cooperadoId}) async {
    _cooperativeId = cooperativeId;
    _cooperadoId = cooperadoId;
    emit(const ComunicadosLoading());
    final result = await _repository.getAll(
      cooperativeId: cooperativeId,
      cooperadoId: cooperadoId,
    );
    result.fold(
      (f) => emit(ComunicadosError(f.message)),
      (items) => emit(ComunicadosLoaded(items)),
    );
  }

  Future<void> marcarLido(String comunicadoId, String cooperadoId) async {
    await _repository.marcarLido(
      comunicadoId: comunicadoId,
      cooperadoId: cooperadoId,
    );
  }

  Future<void> criar(CriarComunicadoParams params) async {
    final result = await _repository.criar(params);
    result.fold(
      (f) => emit(ComunicadosError(f.message)),
      (_) async {
        emit(const ComunicadosMutated('Comunicado publicado com sucesso!'));
        await load(_cooperativeId, cooperadoId: _cooperadoId);
      },
    );
  }
}
