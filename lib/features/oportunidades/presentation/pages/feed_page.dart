import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../domain/repositories/oportunidades_repository.dart';
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
    // CA-03-3: cooperadoId para carregar candidaturas pré-existentes no FeedBloc
    final cooperadoId = authState is AuthAuthenticated && !authState.user.isAdmin
        ? authState.user.cooperadoId
        : null;

    return BlocProvider(
      create: (_) => getIt<FeedBloc>()..add(FeedSubscribed(cooperativeId, cooperadoId: cooperadoId)),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
    final cooperativeId = authState is AuthAuthenticated
        ? authState.user.cooperativeId ?? ''
        : '';
    // CA-03-1: ID do cooperado para candidatura direta no card
    final cooperadoId = authState is AuthAuthenticated && !isAdmin
        ? authState.user.cooperadoId
        : null;
    final isInadimplente = authState is AuthAuthenticated && authState.user.isInadimplente;

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
          _FilterBar(),
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
                  FeedLoaded(:final filtered, :final hasMore, :final candidataIds) => RefreshIndicator(
                      onRefresh: () async {
                        context.read<FeedBloc>().add(FeedSubscribed(cooperativeId, cooperadoId: cooperadoId));
                      },
                      child: Column(
                        children: [
                          // RNF Offline: banner quando exibindo dados do cache
                          if (state.isCached)
                            Container(
                              width: double.infinity,
                              color: const Color(0xFFFEF3C7),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: const [
                                  Icon(Icons.wifi_off, size: 16, color: Color(0xFFB45309)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sem conexão — exibindo dados salvos',
                                    style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                        // RNF: +1 para o botão "Carregar mais" quando hasMore
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: filtered.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          // Botão de carregar mais no final da lista
                          if (i == filtered.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.expand_more),
                                  label: const Text('Carregar mais'),
                                  onPressed: () => context.read<FeedBloc>().add(const FeedLoadMore()),
                                ),
                              ),
                            );
                          }
                          final op = filtered[i];
                          // CA-03-1: só oferece candidatura direta quando cooperado e oportunidade aberta
                          // CA-03-3: bloqueia botão se cooperado já se candidatou
                          final canCandidatar = cooperadoId != null &&
                              !isInadimplente &&
                              op.status == 'aberta' &&
                              !candidataIds.contains(op.id);
                          return OportunidadeCard(
                            oportunidade: op,
                            onTap: () => context.push('/feed/${op.id}'),
                            onCandidatar: canCandidatar
                                ? () async {
                                    final repo = getIt<OportunidadesRepository>();
                                    final result = await repo.candidatar(
                                      oportunidadeId: op.id,
                                      cooperadoId: cooperadoId,
                                    );
                                    if (context.mounted) {
                                      result.fold(
                                        (f) => ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(f.message),
                                            backgroundColor: AppColors.error,
                                          ),
                                        ),
                                        (_) {
                                          // CA-03-3: atualiza estado imediatamente para desabilitar o botão
                                          context.read<FeedBloc>().add(FeedCandidaturaAdded(op.id));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Candidatura registrada! Aguarde o resultado.'),
                                              backgroundColor: AppColors.statusAberta,
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
                  FeedError(:final message) => ErrorDisplay(
                      message: _friendlyError(message),
                      onRetry: () {
                        context.read<FeedBloc>().add(FeedSubscribed(cooperativeId));
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

String _friendlyError(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('socket') ||
      lower.contains('network') ||
      lower.contains('connection') ||
      lower.contains('internet') ||
      lower.contains('connectionreset') ||
      lower.contains('host lookup')) {
    return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
  }
  return message;
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
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
              );
            },
          ),
        );
      },
    );
  }
}
