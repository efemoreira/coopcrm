import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';
import '../cubit/cooperados_cubit.dart';
import 'criar_cooperado_page.dart';
import 'editar_cooperado_page.dart';

class CooperadosPage extends StatelessWidget {
  const CooperadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final cooperativeId = authState is AuthAuthenticated
        ? authState.user.cooperativeId ?? ''
        : '';
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;

    return BlocProvider(
      create: (_) => getIt<CooperadosCubit>()..load(cooperativeId),
      child: _CooperadosView(isAdmin: isAdmin),
    );
  }
}

class _CooperadosView extends StatefulWidget {
  final bool isAdmin;
  const _CooperadosView({required this.isAdmin});
  @override State<_CooperadosView> createState() => _CooperadosViewState();
}

class _CooperadosViewState extends State<_CooperadosView> {
  String _search = '';
  String? _filtroStatus; // null = todos

  static const _statusOptions = [
    ('ativo', 'Ativo'),
    ('inativo', 'Inativo'),
    ('suspenso', 'Suspenso'),
    ('inadimplente', 'Inadimplente'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CooperadosCubit, CooperadosState>(
      listener: (context, state) {
        if (state is CooperadosMutated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
        } else if (state is CooperadosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cooperados')),
          floatingActionButton: widget.isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CooperadosCubit>(),
                        child: const CriarCooperadoPage(),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Novo'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                )
              : null,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CooperadosState state) {
    if (state is CooperadosLoading) return const Center(child: CircularProgressIndicator());
    if (state is CooperadosError) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () {
          final authState = context.read<AuthBloc>().state;
          final cooperativeId =
              authState is AuthAuthenticated ? authState.user.cooperativeId ?? '' : '';
          context.read<CooperadosCubit>().load(cooperativeId);
        },
      );
    }
    if (state is! CooperadosLoaded) return const SizedBox.shrink();

    final filtered = state.items
        .where((c) =>
            (_search.isEmpty ||
            c.nome.toLowerCase().contains(_search.toLowerCase()) ||
            c.cpf.contains(_search)) &&
            (_filtroStatus == null || c.status == _filtroStatus))
        .toList();

    return Column(
      children: [
        // Busca por nome/CPF
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por nome ou CPF...',
              prefixIcon: Icon(Icons.search_outlined),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        // CA-09-4: Filtro por status
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _statusOptions.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isAll = i == 0;
              final status = isAll ? null : _statusOptions[i - 1].$1;
              final label = isAll ? 'Todos' : _statusOptions[i - 1].$2;
              final selected = _filtroStatus == status;
              return FilterChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (_) => setState(() => _filtroStatus = status),
                selectedColor: AppColors.primary.withOpacity(0.12),
                checkmarkColor: AppColors.primary,
              );
            },
          ),
        ),
        if (filtered.isEmpty)
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
                final statusColor = _statusColor(c.status);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    backgroundImage: c.fotoUrl != null ? NetworkImage(c.fotoUrl!) : null,
                    child: c.fotoUrl == null ? Text(c.nome[0].toUpperCase()) : null,
                  ),
                  title: Text(c.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(c.email),
                  trailing: widget.isAdmin
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _showStatusModal(context, c.id, c.status),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _statusLabel(c.status),
                                      style: TextStyle(fontSize: 11, color: statusColor),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down, size: 14, color: statusColor),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                              onSelected: (val) {
                                if (val == 'editar') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<CooperadosCubit>(),
                                        child: EditarCooperadoPage(cooperado: c),
                                      ),
                                    ),
                                  );
                                } else if (val == 'deletar') {
                                  _showDeleteDialog(context, c.id, c.nome);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')])),
                                const PopupMenuItem(value: 'deletar', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Remover', style: TextStyle(color: AppColors.error))])),
                              ],
                            ),
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _statusLabel(c.status),
                            style: TextStyle(fontSize: 11, color: statusColor),
                          ),
                        ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showStatusModal(BuildContext context, String cooperadoId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CooperadosCubit>(),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Alterar status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ..._statusOptions.map((opt) => ListTile(
                    title: Text(opt.$2),
                    trailing: currentStatus == opt.$1
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (opt.$1 != currentStatus) {
                        context.read<CooperadosCubit>().updateStatus(
                              cooperadoId: cooperadoId,
                              status: opt.$1,
                            );
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'ativo' => AppColors.statusConcluida,
        'inadimplente' => AppColors.error,
        'suspenso' => AppColors.accent,
        _ => AppColors.textSecondary,
      };

  String _statusLabel(String status) => switch (status) {
        'ativo' => 'Ativo',
        'inativo' => 'Inativo',
        'suspenso' => 'Suspenso',
        'inadimplente' => 'Inadimplente',
        _ => status,
      };

  void _showDeleteDialog(BuildContext context, String cooperadoId, String nome) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover cooperado'),
        content: Text('Tem certeza que deseja remover "$nome"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CooperadosCubit>().deletar(cooperadoId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
