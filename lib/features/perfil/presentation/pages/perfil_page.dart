import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/oportunidades/domain/repositories/oportunidades_repository.dart';

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
                if (user != null && !user.isAdmin) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (user.isInadimplente ? AppColors.error : AppColors.statusAberta).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isInadimplente ? Icons.warning_amber_outlined : Icons.check_circle_outline,
                          size: 14,
                          color: user.isInadimplente ? AppColors.error : AppColors.statusAberta,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isInadimplente ? 'Inadimplente' : 'Adimplente',
                          style: TextStyle(
                            color: user.isInadimplente ? AppColors.error : AppColors.statusAberta,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Métricas de produção (apenas cooperados)
                if (user != null && !user.isAdmin && user.cooperadoId != null)
                  _MetricasSection(cooperadoId: user.cooperadoId!),
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
                    if (user != null && user.cooperadoId != null)
                      _ActionItem(
                        icon: Icons.payment_outlined,
                        label: 'Minhas cotas',
                        onTap: () => context.push(AppRoutes.cotas),
                      ),
                    if (user != null && user.cooperadoId != null)
                      _ActionItem(
                        icon: Icons.inbox_outlined,
                        label: 'Minhas candidaturas',
                        onTap: () => context.push(AppRoutes.candidaturas),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Seção admin
                if (user?.isAdmin == true)
                  _Section(
                    items: [
                      _ActionItem(
                        icon: Icons.group_outlined,
                        label: 'Cooperados',
                        onTap: () => context.push(AppRoutes.cooperados),
                      ),
                      _ActionItem(
                        icon: Icons.bar_chart_outlined,
                        label: 'Relatórios',
                        onTap: () => context.push(AppRoutes.relatorios),
                      ),
                      _ActionItem(
                        icon: Icons.settings_outlined,
                        label: 'Configurações da cooperativa',
                        onTap: () => context.push(AppRoutes.configuracoes),
                      ),
                    ],
                  ),
                if (user?.isAdmin == true) const SizedBox(height: 16),
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

class _MetricasSection extends StatefulWidget {
  final String cooperadoId;
  const _MetricasSection({required this.cooperadoId});

  @override
  State<_MetricasSection> createState() => _MetricasSectionState();
}

class _MetricasSectionState extends State<_MetricasSection> {
  late final Future<_MetricasData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadMetricas();
  }

  Future<_MetricasData> _loadMetricas() async {
    final result = await getIt<OportunidadesRepository>().getMeuHistorico(widget.cooperadoId);

    // CA-12-1: avaliação média via Supabase
    double avaliacaoMedia = 0.0;
    try {
      final avs = await getIt<SupabaseClient>(instanceName: 'supabase')
          .from('avaliacoes')
          .select('nota')
          .eq('cooperado_id', widget.cooperadoId);
      if (avs.isNotEmpty) {
        final total = avs.fold<double>(0, (s, r) => s + ((r['nota'] as num?)?.toDouble() ?? 0));
        avaliacaoMedia = total / avs.length;
      }
    } catch (_) {}

    return result.fold(
      (_) => _MetricasData(totalMes: 0, valorMes: 0, totalGeral: 0, avaliacaoMedia: avaliacaoMedia),
      (list) {
        final now = DateTime.now();
        final doMes = list.where((o) =>
            o.status == 'concluida' &&
            o.dataExecucao != null &&
            o.dataExecucao!.year == now.year &&
            o.dataExecucao!.month == now.month);
        final totalGeral = list.where((o) => o.status == 'concluida').length;
        return _MetricasData(
          totalMes: doMes.length,
          valorMes: doMes.fold(0.0, (sum, o) => sum + (o.valorEstimado ?? 0)),
          totalGeral: totalGeral,
          avaliacaoMedia: avaliacaoMedia,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              'Produção',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          FutureBuilder<_MetricasData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ));
              }
              final data = snapshot.data ?? const _MetricasData(totalMes: 0, valorMes: 0, totalGeral: 0);
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricaCard(
                          icon: Icons.work_outline,
                          label: 'Serviços este mês',
                          value: '${data.totalMes}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricaCard(
                          icon: Icons.attach_money,
                          label: 'Valor este mês',
                          value: 'R\$ ${data.valorMes.toStringAsFixed(2)}',
                          color: AppColors.statusAberta,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricaCard(
                          icon: Icons.check_circle_outline,
                          label: 'Total concluídos',
                          value: '${data.totalGeral}',
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  // CA-12-1: Avaliação média
                  if (data.avaliacaoMedia > 0) ...[
                    const SizedBox(height: 12),
                    _MetricaCard(
                      icon: Icons.star_outline,
                      label: 'Avaliação média',
                      value: '${data.avaliacaoMedia.toStringAsFixed(1)} ★',
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MetricasData {
  final int totalMes;
  final double valorMes;
  final int totalGeral;
  final double avaliacaoMedia;
  const _MetricasData({
    required this.totalMes,
    required this.valorMes,
    required this.totalGeral,
    this.avaliacaoMedia = 0.0,
  });
}

class _MetricaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MetricaCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
