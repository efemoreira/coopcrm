import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/cotas/domain/entities/cota_entity.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubit/cotas_cubit.dart';
import 'lancar_cota_page.dart';

class CotasPage extends StatelessWidget {
  const CotasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final cooperadoId = auth is AuthAuthenticated ? auth.user.cooperadoId ?? '' : '';
    final cooperativaId = auth is AuthAuthenticated ? auth.user.cooperativeId ?? '' : '';
    final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;

    return BlocProvider(
      create: (_) {
        final cubit = getIt<CotasCubit>();
        if (isAdmin) {
          cubit.loadAdmin(cooperativaId);
        } else {
          cubit.load(cooperadoId);
        }
        return cubit;
      },
      child: _CotasView(isAdmin: isAdmin, cooperativaId: cooperativaId),
    );
  }
}

class _CotasView extends StatelessWidget {
  final bool isAdmin;
  final String cooperativaId;
  const _CotasView({required this.isAdmin, required this.cooperativaId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CotasCubit, CotasState>(
      listener: (context, state) {
        if (state is CotasMutated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
        } else if (state is CotasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cotas')),
          floatingActionButton: isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CotasCubit>(),
                        child: const LancarCotaPage(),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Lançar'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                )
              : null,
          body: Builder(builder: (context) {
            if (state is CotasLoading) return const Center(child: CircularProgressIndicator());
            if (state is CotasError) return Center(child: Text(state.message));

            // ── ADMIN: Dashboard consolidado ───────────────────────
            if (state is CotasAdminLoaded) {
              final byCooperado = <String, List<CotaEntity>>{};
              for (final c in state.todasCotas) {
                byCooperado.putIfAbsent(c.cooperadoId, () => []).add(c);
              }
              return Column(
                children: [
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total arrecadado', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(
                                    'R\$ ${state.totalPagoCooperativa.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Em aberto', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(
                                    'R\$ ${state.totalDevidoCooperativa.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFFFFCDD2), fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Inadimplentes', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  Text(
                                    '${state.totalInadimplentes}',
                                    style: const TextStyle(color: Color(0xFFFFCDD2), fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Adimplentes', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  Text(
                                    '${state.totalAdimplentes}',
                                    style: const TextStyle(color: Color(0xFFB9F6CA), fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('A vencer', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  Text(
                                    '${state.totalAVencer}',
                                    style: const TextStyle(color: Color(0xFFFFF9C4), fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (byCooperado.isEmpty)
                    const Expanded(child: EmptyState(icon: Icons.receipt_long_outlined, title: 'Nenhuma cota', subtitle: ''))
                  else
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: byCooperado.entries.map((entry) {
                          final coopId = entry.key;
                          final cotas = entry.value;
                          final temAtraso = cotas.any((c) => c.isEmAtraso);
                          final totalDevido = cotas.where((c) => !c.isPago).fold<double>(0, (s, c) => s + c.valorDevido);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: temAtraso ? AppColors.error.withOpacity(0.1) : AppColors.statusConcluida.withOpacity(0.1),
                                child: Icon(temAtraso ? Icons.warning_amber_outlined : Icons.check_circle_outline,
                                    color: temAtraso ? AppColors.error : AppColors.statusConcluida),
                              ),
                              title: Text(coopId, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                              subtitle: Text('${cotas.length} lançamentos'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (totalDevido > 0)
                                    Text('R\$ ${totalDevido.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text(temAtraso ? 'Em atraso' : 'Em dia', style: TextStyle(fontSize: 11, color: temAtraso ? AppColors.error : AppColors.statusConcluida)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            }

            // ── COOPERADO: Visão pessoal ───────────────────────────
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
          }),
        );
      },
    );
  }
}
