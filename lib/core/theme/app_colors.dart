import 'package:flutter/material.dart';

/// Paleta de cores centralizada do CoopCRM.
/// Baseada em Material 3 com verde-escuro como cor primária.
/// Os status de oportunidade possuem cores semânticas próprias.
class AppColors {
  AppColors._();

  static const primary        = Color(0xFF00796B);
  static const onPrimary      = Color(0xFFFFFFFF);
  static const secondary      = Color(0xFF004D40);
  static const accent         = Color(0xFFF59E0B);
  static const background     = Color(0xFFF5F7FA);
  static const surface        = Color(0xFFFFFFFF);
  static const error          = Color(0xFFDC2626);
  static const onError        = Color(0xFFFFFFFF);
  static const textPrimary    = Color(0xFF111827);
  static const textSecondary  = Color(0xFF6B7280);
  static const divider        = Color(0xFFE5E7EB);

  static const statusRascunho      = Color(0xFFD97706);
  static const statusAberta        = Color(0xFF16A34A);
  static const statusEmCandidatura = Color(0xFF7C3AED);
  static const statusAtribuida     = Color(0xFF2563EB);
  static const statusEmExecucao    = Color(0xFF0891B2);
  static const statusConcluida     = Color(0xFF6B7280);
  static const statusCancelada     = Color(0xFFDC2626);
}
