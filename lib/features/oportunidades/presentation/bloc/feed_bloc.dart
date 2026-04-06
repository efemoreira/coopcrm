// BLoC do feed de oportunidades.
//
// Responsabilidades:
//  - Inscrever-se no stream Realtime de oportunidades abertas da cooperativa.
//  - Cache offline via SharedPreferences (RNF).
//  - Controlar filtragem e paginação lazy (pageSize).
//  - CA-03-3: manter `candidataIds` para desabilitar botões de oportunidades já candidatadas.
import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/oportunidade_entity.dart';
import '../../domain/repositories/oportunidades_repository.dart';
import '../../data/models/oportunidade_model.dart';

// EVENTS
sealed class FeedEvent extends Equatable {
  const FeedEvent();
  @override List<Object?> get props => [];
}
final class FeedSubscribed extends FeedEvent {
  final String cooperativeId;
  // CA-03-3: cooperadoId para carregar quais oportunidades já foram candidatadas
  final String? cooperadoId;
  const FeedSubscribed(this.cooperativeId, {this.cooperadoId});
  @override List<Object?> get props => [cooperativeId, cooperadoId];
}

/// CA-03-3: disparo após candidatura com sucesso no card do feed
final class FeedCandidaturaAdded extends FeedEvent {
  final String oportunidadeId;
  const FeedCandidaturaAdded(this.oportunidadeId);
  @override List<Object> get props => [oportunidadeId];
}
final class _FeedError extends FeedEvent {
  final String message;
  const _FeedError(this.message);
  @override List<Object> get props => [message];
}
final class FeedFilterChanged extends FeedEvent {
  final String? status;
  const FeedFilterChanged(this.status);
  @override List<Object?> get props => [status];
}
/// RNF Paginação: carrega mais 20 itens
final class FeedLoadMore extends FeedEvent {
  const FeedLoadMore();
}
final class _FeedUpdated extends FeedEvent {
  final List<OportunidadeEntity> items;
  final bool fromCache;
  const _FeedUpdated(this.items, {this.fromCache = false});
}

// STATES
sealed class FeedState extends Equatable {
  const FeedState();
  @override List<Object?> get props => [];
}
final class FeedInitial extends FeedState { const FeedInitial(); }
final class FeedLoading extends FeedState { const FeedLoading(); }
final class FeedLoaded extends FeedState {
  final List<OportunidadeEntity> all;
  final List<OportunidadeEntity> filtered;
  final String? activeFilter;
  /// RNF: quantos itens exibir (lazy load)
  final int pageSize;
  final bool hasMore;
  /// RNF Offline: true quando exibindo dados do cache local
  final bool isCached;
  /// CA-03-3: oportunidade IDs nos quais o cooperado atual já se candidatou
  final Set<String> candidataIds;
  const FeedLoaded({
    required this.all,
    required this.filtered,
    this.activeFilter,
    this.pageSize = 20,
    this.hasMore = false,
    this.isCached = false,
    this.candidataIds = const {},
  });
  @override List<Object?> get props => [all, filtered, activeFilter, pageSize, isCached, candidataIds];
}
final class FeedError extends FeedState {
  final String message;
  const FeedError(this.message);
  @override List<Object> get props => [message];
}

// BLOC
@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final OportunidadesRepository _repository;
  StreamSubscription<List<OportunidadeEntity>>? _subscription;

  static const _cacheKey = 'feed_cache_v1';

  FeedBloc(this._repository) : super(const FeedInitial()) {
    on<FeedSubscribed>(_onSubscribe);
    on<FeedFilterChanged>(_onFilter);
    on<_FeedUpdated>(_onUpdated);
    on<_FeedError>(_onFeedError);
    on<FeedLoadMore>(_onLoadMore);
    on<FeedCandidaturaAdded>(_onCandidaturaAdded);
  }

  Future<void> _onSubscribe(FeedSubscribed event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    await _subscription?.cancel();
    // CA-03-3: carrega IDs de candidaturas do cooperado para bloquear botão no card
    Set<String> candidataIds = const {};
    if (event.cooperadoId != null) {
      final result = await _repository.getMinhaCandidaturaOportunidadeIds(event.cooperadoId!);
      candidataIds = result.getOrElse((_) => const {});
    }
    // Armazena para preservar nos updates seguintes via _currentCandidataIds
    _candidataIds = candidataIds;
    _subscription = _repository
        .watchFeed(cooperativeId: event.cooperativeId)
        .listen(
          (items) => add(_FeedUpdated(items)),
          onError: (e) async {
            // RNF Offline: ao falhar, tenta carregar cache local
            final cached = await _loadCache();
            if (cached != null) {
              add(_FeedUpdated(cached, fromCache: true));
            } else {
              add(_FeedError(e.toString()));
            }
          },
        );
  }

  // CA-03-3: set de IDs mantido na instância do BLoC
  Set<String> _candidataIds = const {};

  void _onCandidaturaAdded(FeedCandidaturaAdded event, Emitter<FeedState> emit) {
    _candidataIds = {..._candidataIds, event.oportunidadeId};
    final current = state;
    if (current is FeedLoaded) {
      emit(FeedLoaded(
        all: current.all,
        filtered: current.filtered,
        activeFilter: current.activeFilter,
        pageSize: current.pageSize,
        hasMore: current.hasMore,
        isCached: current.isCached,
        candidataIds: _candidataIds,
      ));
    }
  }

  void _onFeedError(_FeedError event, Emitter<FeedState> emit) {
    emit(FeedError(event.message));
  }

  /// RNF Offline: salva feed no SharedPreferences
  Future<void> _saveCache(List<OportunidadeEntity> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items
          .map((e) => jsonEncode(OportunidadeModel(
                id: e.id,
                cooperativeId: e.cooperativeId,
                titulo: e.titulo,
                tipo: e.tipo,
                descricao: e.descricao,
                status: e.status,
                prazoCandidata: e.prazoCandidata,
                dataExecucao: e.dataExecucao,
                local: e.local,
                valorEstimado: e.valorEstimado,
                numVagas: e.numVagas,
                requisitos: e.requisitos,
                criterioSelecao: e.criterioSelecao,
                criadorNome: e.criadorNome,
                criadorFoto: e.criadorFoto,
                createdAt: e.createdAt,
              ).toJson()))
          .toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// RNF Offline: carrega feed do cache local
  Future<List<OportunidadeEntity>?> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final jsonList = (jsonDecode(raw) as List).cast<String>();
      return jsonList
          .map((s) => OportunidadeModel.fromJson(jsonDecode(s) as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return null;
    }
  }

  void _onUpdated(_FeedUpdated event, Emitter<FeedState> emit) {
    final current = state;
    // CA-02-1: default filter is 'aberta' — feed only shows ABERTA by default
    final filter = current is FeedLoaded ? current.activeFilter : 'aberta';
    final pageSize = current is FeedLoaded ? current.pageSize : 20;
    final allFiltered = filter != null
        ? event.items.where((o) => o.status == filter).toList()
        : event.items;
    final visible = allFiltered.take(pageSize).toList();
    // RNF Offline: salva cache em background (não bloqueia a UI)
    if (!event.fromCache) _saveCache(event.items);
    emit(FeedLoaded(
      all: event.items,
      filtered: visible,
      activeFilter: filter,
      pageSize: pageSize,
      hasMore: allFiltered.length > pageSize,
      isCached: event.fromCache,
      candidataIds: _candidataIds,
    ));
  }

  void _onFilter(FeedFilterChanged event, Emitter<FeedState> emit) {
    final current = state;
    if (current is! FeedLoaded) return;
    final allFiltered = event.status != null
        ? current.all.where((o) => o.status == event.status).toList()
        : current.all;
    // RNF: reset page on filter change
    final visible = allFiltered.take(20).toList();
    emit(FeedLoaded(
      all: current.all,
      filtered: visible,
      activeFilter: event.status,
      pageSize: 20,
      hasMore: allFiltered.length > 20,
      candidataIds: _candidataIds,
    ));
  }

  void _onLoadMore(FeedLoadMore event, Emitter<FeedState> emit) {
    final current = state;
    if (current is! FeedLoaded) return;
    final newPageSize = current.pageSize + 20;
    final allFiltered = current.activeFilter != null
        ? current.all.where((o) => o.status == current.activeFilter).toList()
        : current.all;
    final visible = allFiltered.take(newPageSize).toList();
    emit(FeedLoaded(
      all: current.all,
      filtered: visible,
      activeFilter: current.activeFilter,
      pageSize: newPageSize,
      hasMore: allFiltered.length > newPageSize,
      candidataIds: _candidataIds,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
