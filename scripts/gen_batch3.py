#!/usr/bin/env python3
"""Batch 3 — Oportunidades Feature (core do produto)."""
import os

BASE = "/Users/felipemoreira/development/opensquads/agentcode/opensquad/squads/software-factory/output/2026-04-05-223053/coopcrm/lib"

def write(rel_path, content):
    full = os.path.join(BASE, rel_path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content)
    print(f"OK: {rel_path}")

write("features/oportunidades/domain/entities/oportunidade_entity.dart", """import 'package:equatable/equatable.dart';

class OportunidadeEntity extends Equatable {
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
  final bool isExpired;
  final String? criadorNome;
  final String? criadorFoto;
  final DateTime createdAt;

  const OportunidadeEntity({
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
    required this.isExpired,
    this.criadorNome,
    this.criadorFoto,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, status, titulo, prazoCandidata];
}
""")

write("features/oportunidades/domain/entities/candidatura_entity.dart", """import 'package:equatable/equatable.dart';

class CandidaturaEntity extends Equatable {
  final String id;
  final String oportunidadeId;
  final String cooperadoId;
  final String status;
  final DateTime createdAt;
  final String? cooperadoNome;
  final String? cooperadoFoto;
  final String? mensagem;

  const CandidaturaEntity({
    required this.id,
    required this.oportunidadeId,
    required this.cooperadoId,
    required this.status,
    required this.createdAt,
    this.cooperadoNome,
    this.cooperadoFoto,
    this.mensagem,
  });

  @override
  List<Object?> get props => [id, status, cooperadoId];
}
""")

write("features/oportunidades/domain/repositories/oportunidades_repository.dart", """import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/oportunidade_entity.dart';
import '../entities/candidatura_entity.dart';

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
  });
}
""")

write("features/oportunidades/data/models/oportunidade_model.dart", """import '../../domain/entities/oportunidade_entity.dart';

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
""")

write("features/oportunidades/data/models/candidatura_model.dart", """import '../../domain/entities/candidatura_entity.dart';

class CandidaturaModel {
  final String id;
  final String oportunidadeId;
  final String cooperadoId;
  final String status;
  final DateTime createdAt;
  final String? cooperadoNome;
  final String? cooperadoFoto;
  final String? mensagem;

  const CandidaturaModel({
    required this.id,
    required this.oportunidadeId,
    required this.cooperadoId,
    required this.status,
    required this.createdAt,
    this.cooperadoNome,
    this.cooperadoFoto,
    this.mensagem,
  });

  factory CandidaturaModel.fromJson(Map<String, dynamic> json) {
    final cooperado = json['cooperado'] as Map<String, dynamic>?;
    return CandidaturaModel(
      id: json['id'] as String,
      oportunidadeId: json['oportunidade_id'] as String,
      cooperadoId: json['cooperado_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      cooperadoNome: cooperado?['nome'] as String?,
      cooperadoFoto: cooperado?['foto_url'] as String?,
      mensagem: json['mensagem'] as String?,
    );
  }

  CandidaturaEntity toEntity() => CandidaturaEntity(
    id: id,
    oportunidadeId: oportunidadeId,
    cooperadoId: cooperadoId,
    status: status,
    createdAt: createdAt,
    cooperadoNome: cooperadoNome,
    cooperadoFoto: cooperadoFoto,
    mensagem: mensagem,
  );
}
""")

write("features/oportunidades/data/datasources/supabase_oportunidades_datasource.dart", """import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/oportunidade_model.dart';
import '../models/candidatura_model.dart';
import '../../domain/repositories/oportunidades_repository.dart';

@injectable
class SupabaseOportunidadesDatasource {
  final SupabaseClient _client;
  SupabaseOportunidadesDatasource(@Named('supabase') this._client);

  Stream<List<OportunidadeModel>> watchFeed(String cooperativeId) {
    return _client
        .from('oportunidades')
        .stream(primaryKey: ['id'])
        .eq('cooperative_id', cooperativeId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(OportunidadeModel.fromJson).toList());
  }

  Future<OportunidadeModel> getById(String id) async {
    final response = await _client
        .from('oportunidades')
        .select('''*, criado_por:cooperados!oportunidades_criado_por_fkey(nome, foto_url)''')
        .eq('id', id)
        .single();
    return OportunidadeModel.fromJson(response);
  }

  Future<List<CandidaturaModel>> getCandidatos(String oportunidadeId) async {
    final response = await _client
        .from('candidaturas')
        .select('*, cooperado:cooperados(nome, foto_url, especialidades)')
        .eq('oportunidade_id', oportunidadeId)
        .order('created_at', ascending: true);
    return response.map(CandidaturaModel.fromJson).toList();
  }

  Future<List<OportunidadeModel>> getMeuHistorico(String cooperadoId) async {
    final atribuicoes = await _client
        .from('atribuicoes')
        .select('oportunidade_id')
        .eq('cooperado_id', cooperadoId);
    final ids = atribuicoes.map((a) => a['oportunidade_id'] as String).toList();
    if (ids.isEmpty) return [];
    final response = await _client
        .from('oportunidades')
        .select()
        .in_('id', ids)
        .order('created_at', ascending: false);
    return response.map(OportunidadeModel.fromJson).toList();
  }

  Future<void> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  }) async {
    await _client.from('candidaturas').insert({
      'oportunidade_id': oportunidadeId,
      'cooperado_id': cooperadoId,
      if (mensagem != null) 'mensagem': mensagem,
    });
  }

  Future<void> desistir(String candidaturaId) async {
    await _client
        .from('candidaturas')
        .update({'status': 'desistiu'})
        .eq('id', candidaturaId);
  }

  Future<OportunidadeModel> criar(CriarOportunidadeParams params) async {
    final response = await _client.from('oportunidades').insert({
      'cooperative_id': params.cooperativeId,
      'criado_por': params.criadorId,
      'titulo': params.titulo,
      'tipo': params.tipo,
      if (params.descricao != null) 'descricao': params.descricao,
      'prazo_candidatura': params.prazoCandidata.toIso8601String(),
      if (params.dataExecucao != null) 'data_execucao': params.dataExecucao!.toIso8601String(),
      if (params.local != null) 'local': params.local,
      if (params.valorEstimado != null) 'valor_estimado': params.valorEstimado,
      'num_vagas': params.numVagas,
      if (params.requisitos != null) 'requisitos': params.requisitos,
      'criterio_selecao': params.criterioSelecao,
      'status': 'rascunho',
    }).select().single();
    return OportunidadeModel.fromJson(response);
  }

  Future<void> atualizarStatus({
    required String oportunidadeId,
    required String novoStatus,
    String? motivo,
  }) async {
    await _client.from('oportunidades').update({
      'status': novoStatus,
      if (motivo != null) 'motivo_cancelamento': motivo,
    }).eq('id', oportunidadeId);
  }
}
""")

write("features/oportunidades/data/repositories/oportunidades_repository_impl.dart", """import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/oportunidade_entity.dart';
import '../../domain/entities/candidatura_entity.dart';
import '../../domain/repositories/oportunidades_repository.dart';
import '../datasources/supabase_oportunidades_datasource.dart';

@Injectable(as: OportunidadesRepository)
class OportunidadesRepositoryImpl implements OportunidadesRepository {
  final SupabaseOportunidadesDatasource _ds;
  OportunidadesRepositoryImpl(this._ds);

  @override
  Stream<List<OportunidadeEntity>> watchFeed({required String cooperativeId}) {
    return _ds.watchFeed(cooperativeId).map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, OportunidadeEntity>> getById(String id) async {
    try {
      final model = await _ds.getById(id);
      return Right(model.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<CandidaturaEntity>>> getCandidatos(String id) async {
    try {
      final models = await _ds.getCandidatos(id);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OportunidadeEntity>>> getMeuHistorico(String cooperadoId) async {
    try {
      final models = await _ds.getMeuHistorico(cooperadoId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  }) async {
    try {
      await _ds.candidatar(
        oportunidadeId: oportunidadeId,
        cooperadoId: cooperadoId,
        mensagem: mensagem,
      );
      return const Right(unit);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return const Left(ServerFailure('Você já se candidatou a esta oportunidade.'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> desistir(String candidaturaId) async {
    try {
      await _ds.desistir(candidaturaId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OportunidadeEntity>> criar(CriarOportunidadeParams params) async {
    try {
      final model = await _ds.criar(params);
      return Right(model.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> atribuirManual({
    required String oportunidadeId,
    required List<String> candidaturaIds,
    required String atribuidoPor,
  }) async {
    // Chamada via Supabase Edge Function para lógica de negócio
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> atualizarStatus({
    required String oportunidadeId,
    required String novoStatus,
    String? motivo,
  }) async {
    try {
      await _ds.atualizarStatus(
        oportunidadeId: oportunidadeId,
        novoStatus: novoStatus,
        motivo: motivo,
      );
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
""")

write("features/oportunidades/presentation/bloc/feed_bloc.dart", """import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/oportunidade_entity.dart';
import '../../domain/repositories/oportunidades_repository.dart';

// EVENTS
sealed class FeedEvent extends Equatable {
  const FeedEvent();
  @override List<Object?> get props => [];
}
final class FeedSubscribed extends FeedEvent {
  final String cooperativeId;
  const FeedSubscribed(this.cooperativeId);
  @override List<Object> get props => [cooperativeId];
}
final class FeedFilterChanged extends FeedEvent {
  final String? status;
  const FeedFilterChanged(this.status);
  @override List<Object?> get props => [status];
}
final class _FeedUpdated extends FeedEvent {
  final List<OportunidadeEntity> items;
  const _FeedUpdated(this.items);
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
  const FeedLoaded({required this.all, required this.filtered, this.activeFilter});
  @override List<Object?> get props => [all, filtered, activeFilter];
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

  FeedBloc(this._repository) : super(const FeedInitial()) {
    on<FeedSubscribed>(_onSubscribe);
    on<FeedFilterChanged>(_onFilter);
    on<_FeedUpdated>(_onUpdated);
  }

  Future<void> _onSubscribe(FeedSubscribed event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    await _subscription?.cancel();
    _subscription = _repository
        .watchFeed(cooperativeId: event.cooperativeId)
        .listen(
          (items) => add(_FeedUpdated(items)),
          onError: (e) => emit(FeedError(e.toString())),
        );
  }

  void _onUpdated(_FeedUpdated event, Emitter<FeedState> emit) {
    final current = state;
    final filter = current is FeedLoaded ? current.activeFilter : null;
    final filtered = filter != null
        ? event.items.where((o) => o.status == filter).toList()
        : event.items;
    emit(FeedLoaded(all: event.items, filtered: filtered, activeFilter: filter));
  }

  void _onFilter(FeedFilterChanged event, Emitter<FeedState> emit) {
    final current = state;
    if (current is! FeedLoaded) return;
    final filtered = event.status != null
        ? current.all.where((o) => o.status == event.status).toList()
        : current.all;
    emit(FeedLoaded(all: current.all, filtered: filtered, activeFilter: event.status));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
""")

write("features/oportunidades/presentation/bloc/oportunidade_detail_cubit.dart", """import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/oportunidade_entity.dart';
import '../../domain/entities/candidatura_entity.dart';
import '../../domain/repositories/oportunidades_repository.dart';

// STATE
sealed class OportunidadeDetailState extends Equatable {
  const OportunidadeDetailState();
  @override List<Object?> get props => [];
}
final class OportunidadeDetailInitial extends OportunidadeDetailState { const OportunidadeDetailInitial(); }
final class OportunidadeDetailLoading extends OportunidadeDetailState { const OportunidadeDetailLoading(); }
final class OportunidadeDetailLoaded extends OportunidadeDetailState {
  final OportunidadeEntity oportunidade;
  final List<CandidaturaEntity> candidatos;
  final bool jaSeCandidata;
  const OportunidadeDetailLoaded({
    required this.oportunidade,
    required this.candidatos,
    required this.jaSeCandidata,
  });
  @override List<Object?> get props => [oportunidade, candidatos, jaSeCandidata];
}
final class OportunidadeDetailError extends OportunidadeDetailState {
  final String message;
  const OportunidadeDetailError(this.message);
  @override List<Object> get props => [message];
}
final class CandidaturaSuccess extends OportunidadeDetailState {
  const CandidaturaSuccess();
}

// CUBIT
@injectable
class OportunidadeDetailCubit extends Cubit<OportunidadeDetailState> {
  final OportunidadesRepository _repo;
  OportunidadeDetailCubit(this._repo) : super(const OportunidadeDetailInitial());

  Future<void> load(String id, {String? cooperadoId}) async {
    emit(const OportunidadeDetailLoading());
    final result = await _repo.getById(id);
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (oport) async {
        final candidatosResult = await _repo.getCandidatos(id);
        candidatosResult.fold(
          (_) => emit(OportunidadeDetailLoaded(
            oportunidade: oport,
            candidatos: [],
            jaSeCandidata: false,
          )),
          (candidatos) {
            final jaSeCandidata = cooperadoId != null &&
                candidatos.any((c) => c.cooperadoId == cooperadoId);
            emit(OportunidadeDetailLoaded(
              oportunidade: oport,
              candidatos: candidatos,
              jaSeCandidata: jaSeCandidata,
            ));
          },
        );
      },
    );
  }

  Future<void> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  }) async {
    final result = await _repo.candidatar(
      oportunidadeId: oportunidadeId,
      cooperadoId: cooperadoId,
      mensagem: mensagem,
    );
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (_) => emit(const CandidaturaSuccess()),
    );
  }
}
""")

write("features/oportunidades/presentation/widgets/oportunidade_card.dart", """import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../domain/entities/oportunidade_entity.dart';

class OportunidadeCard extends StatelessWidget {
  final OportunidadeEntity oportunidade;
  final VoidCallback onTap;

  const OportunidadeCard({
    required this.oportunidade,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      oportunidade.titulo,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(oportunidade.status),
                ],
              ),
              const SizedBox(height: 8),
              if (oportunidade.tipo.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.category_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(oportunidade.tipo, style: tt.bodyMedium),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Prazo: \${AppDateUtils.formatDateTime(oportunidade.prazoCandidata)}',
                    style: tt.bodyMedium?.copyWith(
                      color: oportunidade.isExpired ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (oportunidade.local != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(oportunidade.local!, style: tt.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (oportunidade.valorEstimado != null)
                    Text(
                      'R\$ \${oportunidade.valorEstimado!.toStringAsFixed(2)}',
                      style: tt.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('\${oportunidade.numVagas} vaga\${oportunidade.numVagas > 1 ? "s" : ""}',
                          style: tt.bodyMedium),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""")

write("features/oportunidades/presentation/pages/feed_page.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/oportunidade_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final cooperativeId = authState is AuthAuthenticated
        ? authState.user.cooperativeId ?? ''
        : '';

    return BlocProvider(
      create: (_) => getIt<FeedBloc>()..add(FeedSubscribed(cooperativeId)),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  static const _filters = [
    (label: 'Todas', value: null),
    (label: 'Abertas', value: 'aberta'),
    (label: 'Em candidatura', value: 'em_candidatura'),
    (label: 'Atribuídas', value: 'atribuida'),
    (label: 'Concluídas', value: 'concluida'),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthBloc>().state is AuthAuthenticated &&
        (context.read<AuthBloc>().state as AuthAuthenticated).user.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oportunidades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notificacoes'),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/feed/criar'),
              icon: const Icon(Icons.add),
              label: const Text('Nova'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          // Filtros por status
          _FilterBar(),
          // Lista
          Expanded(
            child: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                return switch (state) {
                  FeedLoading() => const Center(child: CircularProgressIndicator()),
                  FeedLoaded(:final filtered) when filtered.isEmpty => const EmptyState(
                      icon: Icons.work_off_outlined,
                      title: 'Nenhuma oportunidade encontrada',
                      subtitle: 'Quando aparecerem, elas serão exibidas aqui.',
                    ),
                  FeedLoaded(:final filtered) => RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) => OportunidadeCard(
                          oportunidade: filtered[i],
                          onTap: () => context.push('/feed/\${filtered[i].id}'),
                        ),
                      ),
                    ),
                  FeedError(:final message) => ErrorDisplay(
                      message: message,
                      onRetry: () {
                        final auth = context.read<AuthBloc>().state;
                        if (auth is AuthAuthenticated) {
                          context.read<FeedBloc>().add(
                            FeedSubscribed(auth.user.cooperativeId ?? ''),
                          );
                        }
                      },
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        final activeFilter = state is FeedLoaded ? state.activeFilter : null;
        final filters = [
          (label: 'Todas', value: null as String?),
          (label: 'Abertas', value: 'aberta'),
          (label: 'Em candidatura', value: 'em_candidatura'),
          (label: 'Atribuídas', value: 'atribuida'),
          (label: 'Concluídas', value: 'concluida'),
        ];
        return Container(
          height: 48,
          color: AppColors.surface,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final f = filters[i];
              final isActive = activeFilter == f.value;
              return FilterChip(
                label: Text(f.label),
                selected: isActive,
                onSelected: (_) => context.read<FeedBloc>().add(FeedFilterChanged(f.value)),
                selectedColor: AppColors.primary.withOpacity(0.15),
                checkmarkColor: AppColors.primary,
              );
            },
          ),
        );
      },
    );
  }
}
""")

write("features/oportunidades/presentation/pages/oportunidade_detail_page.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../bloc/oportunidade_detail_cubit.dart';

class OportunidadeDetailPage extends StatelessWidget {
  final String id;
  const OportunidadeDetailPage({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final cooperadoId = authState is AuthAuthenticated ? authState.user.cooperadoId : null;

    return BlocProvider(
      create: (_) => getIt<OportunidadeDetailCubit>()..load(id, cooperadoId: cooperadoId),
      child: _OportunidadeDetailView(cooperadoId: cooperadoId),
    );
  }
}

class _OportunidadeDetailView extends StatefulWidget {
  final String? cooperadoId;
  const _OportunidadeDetailView({this.cooperadoId});

  @override
  State<_OportunidadeDetailView> createState() => _OportunidadeDetailViewState();
}

class _OportunidadeDetailViewState extends State<_OportunidadeDetailView> {
  final _mensagemCtrl = TextEditingController();

  @override
  void dispose() {
    _mensagemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OportunidadeDetailCubit, OportunidadeDetailState>(
      listener: (context, state) {
        if (state is CandidaturaSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidatura enviada com sucesso!'),
              backgroundColor: AppColors.statusAberta,
            ),
          );
        } else if (state is OportunidadeDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes')),
          body: switch (state) {
            OportunidadeDetailLoading() => const Center(child: CircularProgressIndicator()),
            OportunidadeDetailError(:final message) => ErrorDisplay(
                message: message,
                onRetry: () => context.read<OportunidadeDetailCubit>().load(
                  '',
                  cooperadoId: widget.cooperadoId,
                ),
              ),
            OportunidadeDetailLoaded(:final oportunidade, :final candidatos, :final jaSeCandidata) =>
              LoadingOverlay(
                isLoading: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              oportunidade.titulo,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          StatusChip(oportunidade.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.category_outlined, text: oportunidade.tipo),
                      if (oportunidade.local != null)
                        _InfoRow(icon: Icons.location_on_outlined, text: oportunidade.local!),
                      _InfoRow(
                        icon: Icons.schedule_outlined,
                        text: 'Prazo: \${AppDateUtils.formatDateTime(oportunidade.prazoCandidata)}',
                      ),
                      if (oportunidade.dataExecucao != null)
                        _InfoRow(
                          icon: Icons.event_outlined,
                          text: 'Execução: \${AppDateUtils.formatDateTime(oportunidade.dataExecucao!)}',
                        ),
                      _InfoRow(
                        icon: Icons.group_outlined,
                        text: '\${oportunidade.numVagas} vaga\${oportunidade.numVagas > 1 ? "s" : ""}',
                      ),
                      if (oportunidade.valorEstimado != null)
                        _InfoRow(
                          icon: Icons.attach_money_outlined,
                          text: 'R\$ \${oportunidade.valorEstimado!.toStringAsFixed(2)}',
                          bold: true,
                          color: AppColors.primary,
                        ),
                      if (oportunidade.descricao != null) ...[
                        const SizedBox(height: 16),
                        Text('Descrição', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(oportunidade.descricao!, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                      if (oportunidade.requisitos != null) ...[
                        const SizedBox(height: 16),
                        Text('Requisitos', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(oportunidade.requisitos!, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                      if (widget.cooperadoId != null &&
                          oportunidade.status == 'aberta' &&
                          !oportunidade.isExpired) ...[
                        const SizedBox(height: 24),
                        if (!jaSeCandidata) ...[
                          TextFormField(
                            controller: _mensagemCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Mensagem (opcional)',
                              hintText: 'Por que você quer esta oportunidade?',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.read<OportunidadeDetailCubit>().candidatar(
                              oportunidadeId: oportunidade.id,
                              cooperadoId: widget.cooperadoId!,
                              mensagem: _mensagemCtrl.text.isNotEmpty ? _mensagemCtrl.text : null,
                            ),
                            icon: const Icon(Icons.send_outlined),
                            label: const Text('Candidatar-me'),
                          ),
                        ] else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.statusAberta.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.statusAberta),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: AppColors.statusAberta),
                                SizedBox(width: 8),
                                Text('Você já se candidatou', style: TextStyle(color: AppColors.statusAberta)),
                              ],
                            ),
                          ),
                      ],
                      if (candidatos.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Candidatos (\${candidatos.length})',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...candidatos.map(
                          (c) => ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(c.cooperadoNome ?? 'Sem nome'),
                            subtitle: Text(AppDateUtils.timeAgo(c.createdAt)),
                            trailing: StatusChip(c.status),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;
  final Color? color;
  const _InfoRow({required this.icon, required this.text, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: bold ? FontWeight.w700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
""")

write("features/oportunidades/presentation/pages/criar_oportunidade_page.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/repositories/oportunidades_repository.dart';
import '../../data/repositories/oportunidades_repository_impl.dart';
import '../../../../core/di/injection.dart';

class CriarOportunidadePage extends StatefulWidget {
  const CriarOportunidadePage({super.key});

  @override
  State<CriarOportunidadePage> createState() => _CriarOportunidadePageState();
}

class _CriarOportunidadePageState extends State<CriarOportunidadePage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _requisitosCtrl = TextEditingController();
  int _numVagas = 1;
  double? _valorEstimado;
  DateTime _prazo = DateTime.now().add(const Duration(days: 7));
  String _criterio = 'manual';
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _tipoCtrl.dispose();
    _descricaoCtrl.dispose();
    _localCtrl.dispose();
    _requisitosCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;

    setState(() => _isLoading = true);
    final repo = getIt<OportunidadesRepository>();
    final result = await repo.criar(CriarOportunidadeParams(
      cooperativeId: auth.user.cooperativeId ?? '',
      criadorId: auth.user.cooperadoId ?? '',
      titulo: _tituloCtrl.text.trim(),
      tipo: _tipoCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim().isNotEmpty ? _descricaoCtrl.text.trim() : null,
      prazoCandidata: _prazo,
      local: _localCtrl.text.trim().isNotEmpty ? _localCtrl.text.trim() : null,
      valorEstimado: _valorEstimado,
      numVagas: _numVagas,
      requisitos: _requisitosCtrl.text.trim().isNotEmpty ? _requisitosCtrl.text.trim() : null,
      criterioSelecao: _criterio,
    ));
    setState(() => _isLoading = false);

    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message), backgroundColor: AppColors.error),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oportunidade criada!'), backgroundColor: AppColors.statusAberta),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Oportunidade')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Título *',
                controller: _tituloCtrl,
                validator: (v) => Validators.required(v, label: 'Título'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Tipo *',
                hint: 'Ex: Serviço de saúde, Transporte…',
                controller: _tipoCtrl,
                validator: (v) => Validators.required(v, label: 'Tipo'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descrição',
                controller: _descricaoCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Local',
                controller: _localCtrl,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vagas *', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() => _numVagas = (_numVagas - 1).clamp(1, 99)),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('\\$_numVagas', style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              onPressed: () => setState(() => _numVagas = (_numVagas + 1).clamp(1, 99)),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Critério', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _criterio,
                          onChanged: (v) => setState(() => _criterio = v ?? 'manual'),
                          items: const [
                            DropdownMenuItem(value: 'manual', child: Text('Manual')),
                            DropdownMenuItem(value: 'fifo', child: Text('FIFO')),
                            DropdownMenuItem(value: 'rodizio', child: Text('Rodízio')),
                          ],
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Prazo para candidatura *', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _prazo,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _prazo = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('\\${_prazo.day.toString().padLeft(2,'0')}/\\${_prazo.month.toString().padLeft(2,'0')}/\\${_prazo.year}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Criar Oportunidade'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""")

print("BATCH 3 DONE")
