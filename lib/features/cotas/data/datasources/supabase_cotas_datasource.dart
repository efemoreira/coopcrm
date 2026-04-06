import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cota_model.dart';

/// Fonte de dados de cotas mensais via Supabase.
/// Acessa a tabela `cotas_pagamentos` para leituras e lançamentos.
@injectable
class SupabaseCotasDatasource {
  final SupabaseClient _client;
  SupabaseCotasDatasource(@Named('supabase') this._client);

  Future<List<CotaModel>> getByCooperado(String cooperadoId) async {
    final data = await _client
        .from('cotas_pagamentos')
        .select()
        .eq('cooperado_id', cooperadoId)
        .order('competencia', ascending: false);
    return data.map(CotaModel.fromJson).toList();
  }

  Future<List<CotaModel>> getByCooperativa(String cooperativaId) async {
    final data = await _client
        .from('cotas_pagamentos')
        .select()
        .eq('cooperativa_id', cooperativaId)
        .order('cooperado_id')
        .order('competencia', ascending: false);
    return data.map(CotaModel.fromJson).toList();
  }

  Future<CotaModel> lancarPagamento(Map<String, dynamic> data) async {
    final result = await _client
        .from('cotas_pagamentos')
        .insert(data)
        .select()
        .single();
    return CotaModel.fromJson(result);
  }
}
