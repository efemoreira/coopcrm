import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../domain/entities/oportunidade_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OportunidadeCard extends StatelessWidget {
  final OportunidadeEntity oportunidade;
  final VoidCallback onTap;
  /// CA-03-1: callback para candidatura direta do card (opcional)
  final VoidCallback? onCandidatar;

  const OportunidadeCard({
    required this.oportunidade,
    required this.onTap,
    this.onCandidatar,
    super.key,
  });

  bool get _isNovo =>
      DateTime.now().difference(oportunidade.createdAt).inHours < 24;

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
                  if (_isNovo)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.statusAberta,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NOVO',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
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
                    'Prazo: ${AppDateUtils.formatDateTime(oportunidade.prazoCandidata)}',
                    style: tt.bodyMedium?.copyWith(
                      color: oportunidade.isExpired ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (oportunidade.dataExecucao != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Execução: ${AppDateUtils.formatDateTime(oportunidade.dataExecucao!)}',
                      style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
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
                      'R\$ ${oportunidade.valorEstimado!.toStringAsFixed(2)}',
                      style: tt.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${oportunidade.numVagas} vaga${oportunidade.numVagas > 1 ? "s" : ""}',
                          style: tt.bodyMedium),
                    ],
                  ),
                ],
              ),
              // Botão Tenho Interesse (CA-03-1) — visível para cooperados em oportunidades abertas
              Builder(builder: (ctx) {
                final auth = ctx.read<AuthBloc>().state;
                final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;
                final isInadimplente = auth is AuthAuthenticated && auth.user.isInadimplente;
                if (isAdmin || oportunidade.status != 'aberta' || oportunidade.isExpired) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isInadimplente ? null : (onCandidatar ?? onTap),
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: Text(isInadimplente ? 'Regularize sua situação' : 'Tenho Interesse'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isInadimplente ? AppColors.textSecondary : AppColors.primary),
                        foregroundColor: isInadimplente ? AppColors.textSecondary : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
