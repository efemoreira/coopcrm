import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/oportunidades/domain/entities/candidatura_entity.dart';
import '../../../../features/oportunidades/domain/repositories/oportunidades_repository.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';

class CandidaturasPage extends StatelessWidget {
  const CandidaturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final cooperadoId = auth is AuthAuthenticated ? auth.user.cooperadoId : null;
    if (cooperadoId == null) {
      return const Scaffold(body: Center(child: Text('Apenas cooperados podem ver candidaturas.')));
    }
    return _CandidaturasView(cooperadoId: cooperadoId);
  }
}

class _CandidaturasView extends StatefulWidget {
  final String cooperadoId;
  const _CandidaturasView({required this.cooperadoId});
  @override
  State<_CandidaturasView> createState() => _CandidaturasViewState();
}

class _CandidaturasViewState extends State<_CandidaturasView> {
  late Future<List<CandidaturaEntity>> _future;
  String? _filtroStatus;
  String _filtroPeriodo = 'todos'; // 'mes_atual' | 'tres_meses' | 'todos'

  static const _statusFiltros = [
    (null, 'Todos'),
    ('aguardando', 'Aguardando'),
    ('selecionado', 'Selecionado'),
    ('em_execucao', 'Em execução'),
    ('concluido', 'Concluído'),
    ('nao_selecionado', 'Não selecionado'),
  ];

  static const _periodoFiltros = [
    ('mes_atual', 'Este mês'),
    ('tres_meses', 'Últimos 3 meses'),
    ('todos', 'Todos'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = getIt<OportunidadesRepository>()
          .getCandidaturasByCooperado(widget.cooperadoId)
          .then((res) => res.fold((_) => [], (list) => list));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Candidaturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de status
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _statusFiltros.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (status, label) = _statusFiltros[i];
                final selected = _filtroStatus == status;
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _filtroStatus = status),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : null,
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                );
              },
            ),
          ),
          // CA-08-3: Filtro por período
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _periodoFiltros.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (periodo, label) = _periodoFiltros[i];
                final selected = _filtroPeriodo == periodo;
                return FilterChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => setState(() => _filtroPeriodo = periodo),
                  selectedColor: AppColors.accent.withOpacity(0.15),
                  checkmarkColor: AppColors.accent,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.accent : null,
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CandidaturaEntity>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return ErrorDisplay(
                    message: snap.error.toString(),
                    onRetry: _load,
                  );
                }
                final all = snap.data ?? [];
                final now = DateTime.now();
                final porPeriodo = _filtroPeriodo == 'mes_atual'
                    ? all.where((c) => c.createdAt.year == now.year && c.createdAt.month == now.month).toList()
                    : _filtroPeriodo == 'tres_meses'
                        ? all.where((c) => c.createdAt.isAfter(now.subtract(const Duration(days: 90)))).toList()
                        : all;
                final filtered = _filtroStatus == null
                    ? porPeriodo
                    : porPeriodo.where((c) => c.status == _filtroStatus).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Nenhuma candidatura',
                    subtitle: 'Suas candidaturas aparecerão aqui.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final c = filtered[i];
                    return _CandidaturaCard(
                      candidatura: c,
                      onTap: () => context.push('${AppRoutes.feed}/${c.oportunidadeId}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidaturaCard extends StatelessWidget {
  final CandidaturaEntity candidatura;
  final VoidCallback onTap;
  const _CandidaturaCard({required this.candidatura, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(candidatura.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      candidatura.oportunidadeTitulo ?? '—',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // CA-08-2: ícone check verde para status concluido
                        if (candidatura.status == 'concluido') ...[
                          const Icon(Icons.check_circle, size: 13, color: Color(0xFF22C55E)),
                          const SizedBox(width: 3),
                        ],
                        Text(
                          _statusLabel(candidatura.status),
                          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (candidatura.oportunidadeTipo != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      candidatura.oportunidadeTipo!,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Candidatado ${AppDateUtils.timeAgo(candidatura.createdAt)}',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'aguardando' => const Color(0xFF3B82F6),
        'selecionado' => AppColors.statusAberta,
        'em_execucao' => const Color(0xFFF97316),
        'concluido' => AppColors.statusConcluida,
        'nao_selecionado' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  String _statusLabel(String status) => switch (status) {
        'aguardando' => 'Aguardando',
        'selecionado' => '⭐ Selecionado',
        'em_execucao' => 'Em execução',
        'concluido' => '✔ Concluído',
        'nao_selecionado' => 'Não selecionado',
        _ => status,
      };
}
