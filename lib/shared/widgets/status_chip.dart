import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Chip colorido que representa semanticamente o status de uma oportunidade.
/// A cor e o label são mapeados por [_colors] e [_labels] internamente.
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  static const _colors = {
    'rascunho':       AppColors.statusRascunho,
    'aberta':         AppColors.statusAberta,
    'em_candidatura': AppColors.statusEmCandidatura,
    'atribuida':      AppColors.statusAtribuida,
    'em_execucao':    AppColors.statusEmExecucao,
    'concluida':      AppColors.statusConcluida,
    'cancelada':      AppColors.statusCancelada,
  };

  static const _labels = {
    'rascunho':       'Rascunho',
    'aberta':         'Aberta',
    'em_candidatura': 'Em candidatura',
    'atribuida':      'Atribuída',
    'em_execucao':    'Em execução',
    'concluida':      'Concluída',
    'cancelada':      'Cancelada',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? Colors.grey;
    final label = _labels[status] ?? status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}
