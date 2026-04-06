#!/usr/bin/env python3
"""Batch 4 — Comunicados, Cotas, Cooperados, Notificações, Perfil."""
import os

BASE = "/Users/felipemoreira/development/opensquads/agentcode/opensquad/squads/software-factory/output/2026-04-05-223053/coopcrm/lib"

def write(rel_path, content):
    full = os.path.join(BASE, rel_path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content)
    print(f"OK: {rel_path}")

# ─── COMUNICADOS ──────────────────────────────────────────────────────────────

write("features/comunicados/domain/entities/comunicado_entity.dart", """import 'package:equatable/equatable.dart';

class ComunicadoEntity extends Equatable {
  final String id;
  final String cooperativeId;
  final String titulo;
  final String conteudo;
  final String tipo;
  final bool pinned;
  final bool lido;
  final String? autorNome;
  final String? autorFoto;
  final DateTime createdAt;

  const ComunicadoEntity({
    required this.id,
    required this.cooperativeId,
    required this.titulo,
    required this.conteudo,
    required this.tipo,
    required this.pinned,
    required this.lido,
    this.autorNome,
    this.autorFoto,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, lido, pinned];
}
""")

write("features/comunicados/data/models/comunicado_model.dart", """import '../../domain/entities/comunicado_entity.dart';

class ComunicadoModel {
  final String id;
  final String cooperativeId;
  final String titulo;
  final String conteudo;
  final String tipo;
  final bool pinned;
  final bool lido;
  final String? autorNome;
  final String? autorFoto;
  final DateTime createdAt;

  const ComunicadoModel({
    required this.id,
    required this.cooperativeId,
    required this.titulo,
    required this.conteudo,
    required this.tipo,
    required this.pinned,
    required this.lido,
    this.autorNome,
    this.autorFoto,
    required this.createdAt,
  });

  factory ComunicadoModel.fromJson(Map<String, dynamic> json, {bool lido = false}) {
    final autor = json['criado_por'] as Map<String, dynamic>?;
    return ComunicadoModel(
      id: json['id'] as String,
      cooperativeId: json['cooperative_id'] as String,
      titulo: json['titulo'] as String,
      conteudo: json['conteudo'] as String,
      tipo: json['tipo'] as String? ?? 'geral',
      pinned: json['pinned'] as bool? ?? false,
      lido: lido,
      autorNome: autor?['nome'] as String?,
      autorFoto: autor?['foto_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ComunicadoEntity toEntity() => ComunicadoEntity(
    id: id,
    cooperativeId: cooperativeId,
    titulo: titulo,
    conteudo: conteudo,
    tipo: tipo,
    pinned: pinned,
    lido: lido,
    autorNome: autorNome,
    autorFoto: autorFoto,
    createdAt: createdAt,
  );
}
""")

write("features/comunicados/presentation/cubit/comunicados_cubit.dart", """import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/comunicado_entity.dart';

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
}

@injectable
class ComunicadosCubit extends Cubit<ComunicadosState> {
  final SupabaseClient _client;
  ComunicadosCubit(@Named('supabase') this._client) : super(const ComunicadosInitial());

  Future<void> load(String cooperativeId, {String? cooperadoId}) async {
    emit(const ComunicadosLoading());
    try {
      final data = await _client
          .from('comunicados')
          .select('*')
          .eq('cooperative_id', cooperativeId)
          .order('pinned', ascending: false)
          .order('created_at', ascending: false);

      Set<String> lidos = {};
      if (cooperadoId != null) {
        final leituras = await _client
            .from('comunicado_leituras')
            .select('comunicado_id')
            .eq('cooperado_id', cooperadoId);
        lidos = leituras.map((l) => l['comunicado_id'] as String).toSet();
      }

      final items = data.map((json) {
        final lido = lidos.contains(json['id'] as String);
        return _fromJson(json, lido: lido).toEntity();
      }).toList();

      emit(ComunicadosLoaded(items));
    } catch (e) {
      emit(ComunicadosError(e.toString()));
    }
  }

  Future<void> marcarLido(String comunicadoId, String cooperadoId) async {
    await _client.from('comunicado_leituras').upsert({
      'comunicado_id': comunicadoId,
      'cooperado_id': cooperadoId,
    });
  }

  dynamic _fromJson(Map<String, dynamic> json, {bool lido = false}) {
    return _ComunicadoModelInline(
      id: json['id'] as String,
      cooperativeId: json['cooperative_id'] as String,
      titulo: json['titulo'] as String,
      conteudo: json['conteudo'] as String,
      tipo: json['tipo'] as String? ?? 'geral',
      pinned: json['pinned'] as bool? ?? false,
      lido: lido,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class _ComunicadoModelInline {
  final String id, cooperativeId, titulo, conteudo, tipo;
  final bool pinned, lido;
  final DateTime createdAt;
  _ComunicadoModelInline({
    required this.id, required this.cooperativeId, required this.titulo,
    required this.conteudo, required this.tipo, required this.pinned,
    required this.lido, required this.createdAt,
  });
  ComunicadoEntity toEntity() => ComunicadoEntity(
    id: id, cooperativeId: cooperativeId, titulo: titulo, conteudo: conteudo,
    tipo: tipo, pinned: pinned, lido: lido, createdAt: createdAt,
  );
}
""")

write("features/comunicados/presentation/pages/comunicados_page.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubit/comunicados_cubit.dart';

class ComunicadosPage extends StatelessWidget {
  const ComunicadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final cooperativeId = auth is AuthAuthenticated ? auth.user.cooperativeId ?? '' : '';
    final cooperadoId = auth is AuthAuthenticated ? auth.user.cooperadoId : null;

    return BlocProvider(
      create: (_) => getIt<ComunicadosCubit>()
        ..load(cooperativeId, cooperadoId: cooperadoId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Comunicados')),
        body: BlocBuilder<ComunicadosCubit, ComunicadosState>(
          builder: (context, state) {
            if (state is ComunicadosLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ComunicadosError) {
              return Center(child: Text(state.message));
            }
            if (state is ComunicadosLoaded) {
              if (state.items.isEmpty) {
                return const EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'Nenhum comunicado',
                  subtitle: 'Novidades serão exibidas aqui.',
                );
              }
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, i) {
                  final c = state.items[i];
                  return Card(
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: c.pinned
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.surface,
                            child: Icon(
                              c.pinned ? Icons.push_pin_outlined : Icons.campaign_outlined,
                              color: c.pinned ? AppColors.accent : AppColors.primary,
                            ),
                          ),
                          if (!c.lido)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        c.titulo,
                        style: TextStyle(
                          fontWeight: c.lido ? FontWeight.w400 : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(AppDateUtils.timeAgo(c.createdAt)),
                      onTap: () {
                        final auth = context.read<AuthBloc>().state;
                        if (auth is AuthAuthenticated && auth.user.cooperadoId != null) {
                          context.read<ComunicadosCubit>().marcarLido(
                            c.id,
                            auth.user.cooperadoId!,
                          );
                        }
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => DraggableScrollableSheet(
                            expand: false,
                            builder: (_, ctrl) => SingleChildScrollView(
                              controller: ctrl,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.titulo, style: Theme.of(context).textTheme.headlineSmall),
                                  const SizedBox(height: 8),
                                  Text(AppDateUtils.formatDateTime(c.createdAt),
                                      style: const TextStyle(color: AppColors.textSecondary)),
                                  const Divider(height: 24),
                                  Text(c.conteudo, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
""")

# ─── COTAS ────────────────────────────────────────────────────────────────────

write("features/cotas/domain/entities/cota_entity.dart", """import 'package:equatable/equatable.dart';

class CotaEntity extends Equatable {
  final String id;
  final String cooperadoId;
  final String cooperativaId;
  final String competencia;
  final double valorDevido;
  final double? valorPago;
  final String status;
  final DateTime? dataPagamento;
  final String? comprovanteUrl;
  final DateTime createdAt;

  const CotaEntity({
    required this.id,
    required this.cooperadoId,
    required this.cooperativaId,
    required this.competencia,
    required this.valorDevido,
    this.valorPago,
    required this.status,
    this.dataPagamento,
    this.comprovanteUrl,
    required this.createdAt,
  });

  bool get isPago => status == 'pago';
  bool get isEmAtraso => status == 'em_atraso';

  @override
  List<Object?> get props => [id, status, competencia];
}
""")

write("features/cotas/presentation/cubit/cotas_cubit.dart", """import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/cota_entity.dart';

sealed class CotasState extends Equatable {
  const CotasState();
  @override List<Object?> get props => [];
}
final class CotasInitial extends CotasState { const CotasInitial(); }
final class CotasLoading extends CotasState { const CotasLoading(); }
final class CotasLoaded extends CotasState {
  final List<CotaEntity> cotas;
  final double totalDevido;
  final double totalPago;
  const CotasLoaded({required this.cotas, required this.totalDevido, required this.totalPago});
  @override List<Object?> get props => [cotas, totalDevido, totalPago];
}
final class CotasError extends CotasState {
  final String message;
  const CotasError(this.message);
}

@injectable
class CotasCubit extends Cubit<CotasState> {
  final SupabaseClient _client;
  CotasCubit(@Named('supabase') this._client) : super(const CotasInitial());

  Future<void> load(String cooperadoId) async {
    emit(const CotasLoading());
    try {
      final data = await _client
          .from('cotas_pagamentos')
          .select()
          .eq('cooperado_id', cooperadoId)
          .order('competencia', ascending: false);

      final cotas = data.map((json) => CotaEntity(
        id: json['id'] as String,
        cooperadoId: json['cooperado_id'] as String,
        cooperativaId: json['cooperative_id'] as String,
        competencia: json['competencia'] as String,
        valorDevido: (json['valor_devido'] as num).toDouble(),
        valorPago: (json['valor_pago'] as num?)?.toDouble(),
        status: json['status'] as String,
        dataPagamento: json['data_pagamento'] != null
            ? DateTime.parse(json['data_pagamento'] as String) : null,
        comprovanteUrl: json['comprovante_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      )).toList();

      final totalDevido = cotas
          .where((c) => c.status != 'pago')
          .fold<double>(0, (sum, c) => sum + c.valorDevido);
      final totalPago = cotas
          .where((c) => c.isPago)
          .fold<double>(0, (sum, c) => sum + (c.valorPago ?? 0));

      emit(CotasLoaded(cotas: cotas, totalDevido: totalDevido, totalPago: totalPago));
    } catch (e) {
      emit(CotasError(e.toString()));
    }
  }
}
""")

write("features/cotas/presentation/pages/cotas_page.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubit/cotas_cubit.dart';

class CotasPage extends StatelessWidget {
  const CotasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final cooperadoId = auth is AuthAuthenticated ? auth.user.cooperadoId ?? '' : '';

    return BlocProvider(
      create: (_) => getIt<CotasCubit>()..load(cooperadoId),
      child: const _CotasView(),
    );
  }
}

class _CotasView extends StatelessWidget {
  const _CotasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Cotas')),
      body: BlocBuilder<CotasCubit, CotasState>(
        builder: (context, state) {
          if (state is CotasLoading) return const Center(child: CircularProgressIndicator());
          if (state is CotasError) return Center(child: Text(state.message));
          if (state is CotasLoaded) {
            return Column(
              children: [
                // Resumo financeiro
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF00A896)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Pago', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              'R\$ ${state.totalPago.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      if (state.totalDevido > 0)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Em aberto', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(
                                'R\$ ${state.totalDevido.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFFFFCDD2), fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Lista
                if (state.cotas.isEmpty)
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Nenhuma cota encontrada',
                      subtitle: 'O histórico de cotas será exibido aqui.',
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.cotas.length,
                      itemBuilder: (context, i) {
                        final c = state.cotas[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: c.isPago
                                ? AppColors.statusConcluida.withOpacity(0.15)
                                : c.isEmAtraso
                                    ? AppColors.error.withOpacity(0.15)
                                    : AppColors.accent.withOpacity(0.15),
                            child: Icon(
                              c.isPago ? Icons.check_circle_outline : Icons.pending_outlined,
                              color: c.isPago
                                  ? AppColors.statusConcluida
                                  : c.isEmAtraso ? AppColors.error : AppColors.accent,
                            ),
                          ),
                          title: Text(c.competencia),
                          subtitle: Text(
                            c.isPago && c.dataPagamento != null
                                ? 'Pago em ${AppDateUtils.formatDate(c.dataPagamento!)}'
                                : 'Vence: ${c.competencia}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'R\$ ${c.valorDevido.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: c.isPago ? AppColors.statusConcluida : AppColors.error,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.isPago
                                      ? AppColors.statusConcluida.withOpacity(0.1)
                                      : AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  c.isPago ? 'Pago' : c.status.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: c.isPago ? AppColors.statusConcluida : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
""")

# ─── NOTIFICAÇÕES ──────────────────────────────────────────────────────────────

write("features/notificacoes/presentation/pages/notificacoes_page.dart", """import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/empty_state.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});
  @override State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final client = getIt<SupabaseClient>();
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final data = await client
        .from('notifications_log')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    if (mounted) setState(() { _notifs = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (_notifs.isNotEmpty)
            TextButton(
              onPressed: _load,
              child: const Text('Atualizar'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifs.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Nenhuma notificação',
                  subtitle: 'Você será notificado sobre oportunidades e comunicados.',
                )
              : ListView.separated(
                  itemCount: _notifs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final n = _notifs[i];
                    final createdAt = DateTime.tryParse(n['created_at'] as String? ?? '');
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.notifications_outlined, color: AppColors.primary),
                      ),
                      title: Text(
                        n['titulo'] as String? ?? 'Notificação',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (n['mensagem'] != null)
                            Text(n['mensagem'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (createdAt != null)
                            Text(AppDateUtils.timeAgo(createdAt),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                      isThreeLine: n['mensagem'] != null,
                    );
                  },
                ),
    );
  }
}
""")

# ─── PERFIL ────────────────────────────────────────────────────────────────────

write("features/perfil/presentation/pages/perfil_page.dart", """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go('/login');
      },
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Meu Perfil')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        backgroundImage: user?.fotoUrl != null
                            ? NetworkImage(user!.fotoUrl!)
                            : null,
                        child: user?.fotoUrl == null
                            ? Text(
                                user?.nome.isNotEmpty == true
                                    ? user!.nome[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 40, color: AppColors.primary),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.nome ?? '—',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                if (user?.isAdmin == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Administrador', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(height: 32),
                // Seção de ações
                _Section(
                  items: [
                    _ActionItem(
                      icon: Icons.person_outline,
                      label: 'Dados pessoais',
                      onTap: () {},
                    ),
                    _ActionItem(
                      icon: Icons.lock_outline,
                      label: 'Alterar senha',
                      onTap: () {},
                    ),
                    _ActionItem(
                      icon: Icons.notifications_outlined,
                      label: 'Preferências de notificação',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  items: [
                    _ActionItem(
                      icon: Icons.help_outline,
                      label: 'Ajuda e suporte',
                      onTap: () {},
                    ),
                    _ActionItem(
                      icon: Icons.info_outline,
                      label: 'Sobre o app',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Sair', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final List<_ActionItem> items;
  const _Section({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.label),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: item.onTap,
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionItem({required this.icon, required this.label, required this.onTap});
}
""")

# ─── COOPERADOS (admin) ──────────────────────────────────────────────────────

write("features/cooperados/domain/entities/cooperado_entity.dart", """import 'package:equatable/equatable.dart';

class CooperadoEntity extends Equatable {
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

  const CooperadoEntity({
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

  bool get isAtivo => status == 'ativo';

  @override
  List<Object?> get props => [id, status, nome];
}
""")

write("features/cooperados/presentation/pages/cooperados_page.dart", """import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/cooperado_entity.dart';

class CooperadosPage extends StatefulWidget {
  const CooperadosPage({super.key});
  @override State<CooperadosPage> createState() => _CooperadosPageState();
}

class _CooperadosPageState extends State<CooperadosPage> {
  List<CooperadoEntity> _cooperados = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final client = getIt<SupabaseClient>();
    final cooperativeId = client.auth.currentSession?.user.userMetadata?['cooperative_id'] as String?;
    if (cooperativeId == null) {
      setState(() => _loading = false);
      return;
    }
    final data = await client
        .from('cooperados')
        .select()
        .eq('cooperative_id', cooperativeId)
        .order('nome');

    final list = data.map((json) => CooperadoEntity(
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
          ? DateTime.tryParse(json['data_admissao'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    )).toList();

    if (mounted) setState(() { _cooperados = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _cooperados.where((c) =>
      _search.isEmpty || c.nome.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cooperados')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar cooperado...',
                prefixIcon: Icon(Icons.search_outlined),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (filtered.isEmpty)
            const Expanded(
              child: EmptyState(
                icon: Icons.group_outlined,
                title: 'Nenhum cooperado encontrado',
                subtitle: 'Adicione cooperados para que apareçam aqui.',
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final c = filtered[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      backgroundImage: c.fotoUrl != null ? NetworkImage(c.fotoUrl!) : null,
                      child: c.fotoUrl == null ? Text(c.nome[0].toUpperCase()) : null,
                    ),
                    title: Text(c.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.email),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.isAtivo
                            ? AppColors.statusConcluida.withOpacity(0.1)
                            : AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        c.isAtivo ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          fontSize: 11,
                          color: c.isAtivo ? AppColors.statusConcluida : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
""")

print("BATCH 4 DONE")
