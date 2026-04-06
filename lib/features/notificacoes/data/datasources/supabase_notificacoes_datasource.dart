import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notificacao_model.dart';

/// Fonte de dados das notificações persistidas via Supabase.
/// Lê as últimas 50 notificações do `notifications_log` em ordem decrescente.
@injectable
class SupabaseNotificacoesDatasource {
  final SupabaseClient _client;
  SupabaseNotificacoesDatasource(@Named('supabase') this._client);

  Future<List<NotificacaoModel>> getByUser(String userId) async {
    final data = await _client
        .from('notifications_log')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return data.map(NotificacaoModel.fromJson).toList();
  }
}
