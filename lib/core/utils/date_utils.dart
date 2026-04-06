import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Utilitários de formatação e cálculo de datas localizadas em pt-BR.
class AppDateUtils {
  AppDateUtils._();

  /// Formata como `dd/MM/yyyy`.
  static String formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(date);

  /// Formata como `dd/MM/yyyy HH:mm`.
  static String formatDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(date);

  /// Formata como `Mês/Ano` com inicial maiúscula (ex: `Abril/2026`).
  static String formatMonth(DateTime date) {
    final s = DateFormat('MMMM/yyyy', 'pt_BR').format(date);
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Retorna tempo relativo legível (ex: `há 3 horas`, `em 2 dias`).
  static String timeAgo(DateTime date) =>
      timeago.format(date, locale: 'pt_BR', allowFromNow: true);

  /// Retorna `true` se o prazo já passou em relação ao instante atual.
  static bool isExpired(DateTime prazo) => prazo.isBefore(DateTime.now());
}
