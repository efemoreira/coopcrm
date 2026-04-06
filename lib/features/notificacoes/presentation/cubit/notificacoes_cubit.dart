// Cubit de notificações persistidas.
// Exibe o histórico das notificações push geradas para o usuário.
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/notificacao_entity.dart';
import '../../domain/repositories/notificacoes_repository.dart';

sealed class NotificacoesState extends Equatable {
  const NotificacoesState();
  @override List<Object?> get props => [];
}
final class NotificacoesInitial extends NotificacoesState { const NotificacoesInitial(); }
final class NotificacoesLoading extends NotificacoesState { const NotificacoesLoading(); }
final class NotificacoesLoaded extends NotificacoesState {
  final List<NotificacaoEntity> items;
  const NotificacoesLoaded(this.items);
  @override List<Object?> get props => [items];
}
final class NotificacoesError extends NotificacoesState {
  final String message;
  const NotificacoesError(this.message);
  @override List<Object?> get props => [message];
}

/// Cubit de notificações. Instância por tela.
@injectable
class NotificacoesCubit extends Cubit<NotificacoesState> {
  final NotificacoesRepository _repository;
  NotificacoesCubit(this._repository) : super(const NotificacoesInitial());

  Future<void> load(String userId) async {
    emit(const NotificacoesLoading());
    final result = await _repository.getByUser(userId);
    result.fold(
      (f) => emit(NotificacoesError(f.message)),
      (items) => emit(NotificacoesLoaded(items)),
    );
  }
}
