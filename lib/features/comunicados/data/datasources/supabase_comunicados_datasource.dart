import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comunicado_model.dart';

/// Fonte de dados de comunicados via Supabase.
/// Busca comunicados com join em `comunicado_leituras` para determinar
/// quais já foram lidos pelo cooperado atual.
@injectable
class SupabaseComunicadosDatasource {
  final SupabaseClient _client;
  SupabaseComunicadosDatasource(@Named('supabase') this._client);

  Future<List<ComunicadoModel>> getAll({
    required String cooperativeId,
    String? cooperadoId,
  }) async {
    final data = await _client
        .from('comunicados')
        .select('*')
        .eq('cooperative_id', cooperativeId)
        .order('pinned', ascending: false)
        .order('created_at', ascending: false);

    Set<String> lidos = {};
    if (cooperadoId != null) {
      final leituras = await _client
          .from('comunicado_leituras')
          .select('comunicado_id')
          .eq('cooperado_id', cooperadoId);
      lidos = leituras.map((l) => l['comunicado_id'] as String).toSet();
    }

    return data
        .map((json) => ComunicadoModel.fromJson(json, lido: lidos.contains(json['id'] as String)))
        .toList();
  }

  Future<void> marcarLido({required String comunicadoId, required String cooperadoId}) async {
    await _client.from('comunicado_leituras').upsert({
      'comunicado_id': comunicadoId,
      'cooperado_id': cooperadoId,
    }, ignoreDuplicates: true);
  }

  Future<ComunicadoModel> criar(Map<String, dynamic> data) async {
    final result = await _client
        .from('comunicados')
        .insert(data)
        .select()
        .single();
    // CA-11-3: dispara push para destinatários via Edge Function
    try {
      await _client.functions.invoke('notify-comunicado', body: {
        'comunicado_id': result['id'],
        'cooperative_id': result['cooperative_id'],
        'titulo': result['titulo'],
        if (data['destinatario_ids'] != null)
          'destinatario_ids': data['destinatario_ids'],
      });
    } catch (_) {
      // push é best-effort — não bloqueia o fluxo principal
    }
    return ComunicadoModel.fromJson(result, lido: false);
  }
}
