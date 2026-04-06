import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cooperado_model.dart';

/// Fonte de dados de cooperados via Supabase.
/// Realiza CRUD completo na tabela `cooperados` e update de status de adimplência.
@injectable
class SupabaseCooperadosDatasource {
  final SupabaseClient _client;
  SupabaseCooperadosDatasource(@Named('supabase') this._client);

  Future<List<CooperadoModel>> getAll(String cooperativeId) async {
    final data = await _client
        .from('cooperados')
        .select()
        .eq('cooperative_id', cooperativeId)
        .order('nome');
    return data.map(CooperadoModel.fromJson).toList();
  }

  Future<CooperadoModel> criar(Map<String, dynamic> data) async {
    // Chama a Edge Function `criar-cooperado` que cria o auth user + cooperado
    // via service_role, garantindo integridade e rollback automático.
    final response = await _client.functions.invoke(
      'criar-cooperado',
      body: data,
    );

    if (response.status != 201) {
      final msg = (response.data as Map<String, dynamic>?)?['error'] ?? 'Erro ao criar cooperado';
      throw Exception(msg);
    }

    final cooperado = (response.data as Map<String, dynamic>)['cooperado'] as Map<String, dynamic>;
    return CooperadoModel.fromJson(cooperado);
  }

  Future<void> updateStatus({required String cooperadoId, required String status}) async {
    await _client
        .from('cooperados')
        .update({'status': status})
        .eq('id', cooperadoId);
  }

  Future<void> editar({
    required String cooperadoId,
    required String nome,
    String? telefone,
    required List<String> especialidades,
  }) async {
    await _client.from('cooperados').update({
      'nome': nome,
      if (telefone != null) 'telefone': telefone,
      'especialidades': especialidades,
    }).eq('id', cooperadoId);
  }

  Future<void> deletar(String cooperadoId) async {
    await _client.from('cooperados').delete().eq('id', cooperadoId);
  }
}
