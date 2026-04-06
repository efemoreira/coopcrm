import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/oportunidade_model.dart';
import '../models/candidatura_model.dart';
import '../../domain/repositories/oportunidades_repository.dart';

/// Fonte de dados de oportunidades e candidaturas via Supabase.
/// Utiliza Realtime (`.stream()`) para o feed ao vivo e consultas REST para os demais.
@injectable
class SupabaseOportunidadesDatasource {
  final SupabaseClient _client;
  SupabaseOportunidadesDatasource(@Named('supabase') this._client);

  // CA-02-1: feed exibe apenas oportunidades com status 'aberta'
  Stream<List<OportunidadeModel>> watchFeed(String cooperativeId) {
    return _client
        .from('oportunidades')
        .stream(primaryKey: ['id'])
        .eq('cooperative_id', cooperativeId)
        .order('created_at', ascending: false)
        .limit(100)
        .map((rows) => rows
            .where((r) => r['status'] == 'aberta')
            .map(OportunidadeModel.fromJson)
            .toList());
  }

  Future<OportunidadeModel> getById(String id) async {
    final response = await _client
        .from('oportunidades')
        .select('''*, criado_por:cooperados!oportunidades_criado_por_fkey(nome, foto_url)''')
        .eq('id', id)
        .single();
    return OportunidadeModel.fromJson(response);
  }

  Future<List<CandidaturaModel>> getCandidatos(String oportunidadeId) async {
    final response = await _client
        .from('candidaturas')
        .select('*, cooperado:cooperados(nome, foto_url, especialidades)')
        .eq('oportunidade_id', oportunidadeId)
        .order('created_at', ascending: true);
    return response.map(CandidaturaModel.fromJson).toList();
  }

  /// CA-03-3: IDs de oportunidades às quais o cooperado já se candidatou
  Future<Set<String>> getMinhaCandidaturaOportunidadeIds(String cooperadoId) async {
    final rows = await _client
        .from('candidaturas')
        .select('oportunidade_id')
        .eq('cooperado_id', cooperadoId);
    return rows.map((r) => r['oportunidade_id'] as String).toSet();
  }

  Future<List<OportunidadeModel>> getMeuHistorico(String cooperadoId) async {
    final atribuicoes = await _client
        .from('atribuicoes')
        .select('oportunidade_id')
        .eq('cooperado_id', cooperadoId);
    final ids = atribuicoes.map((a) => a['oportunidade_id'] as String).toList();
    if (ids.isEmpty) return [];
    final response = await _client
        .from('oportunidades')
        .select()
        .inFilter('id', ids)
        .order('created_at', ascending: false);
    return response.map(OportunidadeModel.fromJson).toList();
  }

  Future<void> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  }) async {
    await _client.from('candidaturas').insert({
      'oportunidade_id': oportunidadeId,
      'cooperado_id': cooperadoId,
      if (mensagem != null) 'mensagem': mensagem,
    });
  }

  /// CA-06-2: marca como 'desistiu' e recoloca o próximo candidato na fila ('aguardando')
  Future<void> desistir(String candidaturaId) async {
    // Buscar a candidatura para obter oportunidade_id e cooperado_id
    final cand = await _client
        .from('candidaturas')
        .select('oportunidade_id, cooperado_id')
        .eq('id', candidaturaId)
        .single();
    final oportunidadeId = cand['oportunidade_id'] as String;

    // Marcar como desistiu
    await _client
        .from('candidaturas')
        .update({'status': 'desistiu'})
        .eq('id', candidaturaId);

    // Reatribuir oportunidade para status 'aberta' (aguardando nova atribuicao)
    await _client
        .from('oportunidades')
        .update({'status': 'aberta'})
        .eq('id', oportunidadeId);

    // Atribuicao correspondente — marcar como cancelada se existir
    await _client
        .from('atribuicoes')
        .update({'status': 'cancelada'})
        .eq('oportunidade_id', oportunidadeId)
        .eq('cooperado_id', cand['cooperado_id'] as String);
  }

  Future<OportunidadeModel> criar(CriarOportunidadeParams params) async {
    final response = await _client.from('oportunidades').insert({
      'cooperative_id': params.cooperativeId,
      'criado_por': params.criadorId,
      'titulo': params.titulo,
      'tipo': params.tipo,
      if (params.descricao != null) 'descricao': params.descricao,
      'prazo_candidatura': params.prazoCandidata.toIso8601String(),
      if (params.dataExecucao != null) 'data_execucao': params.dataExecucao!.toIso8601String(),
      if (params.local != null) 'local': params.local,
      if (params.valorEstimado != null) 'valor_estimado': params.valorEstimado,
      'num_vagas': params.numVagas,
      if (params.requisitos != null) 'requisitos': params.requisitos,
      'criterio_selecao': params.criterioSelecao,
      'status': params.status,
    }).select().single();
    return OportunidadeModel.fromJson(response);
  }

  Future<void> atribuirManual({
    required String oportunidadeId,
    required List<String> candidaturaIds,
    required String atribuidoPor,
  }) async {
    // Marcar selecionados
    for (final id in candidaturaIds) {
      await _client
          .from('candidaturas')
          .update({'status': 'selecionado'})
          .eq('id', id);
    }
    // Marcar demais como não selecionados
    await _client
        .from('candidaturas')
        .update({'status': 'nao_selecionado'})
        .eq('oportunidade_id', oportunidadeId)
        .not('id', 'in', candidaturaIds);
    // CA-05-5: muda status para 'atribuida' (cooperado ainda precisa confirmar)
    await _client
        .from('oportunidades')
        .update({'status': 'atribuida'})
        .eq('id', oportunidadeId);
    // Registra atribuições
    for (final id in candidaturaIds) {
      final cand = await _client
          .from('candidaturas')
          .select('cooperado_id')
          .eq('id', id)
          .single();
      await _client.from('atribuicoes').upsert({
        'oportunidade_id': oportunidadeId,
        'cooperado_id': cand['cooperado_id'],
        'atribuido_por': atribuidoPor,
      }, onConflict: 'oportunidade_id,cooperado_id');
    }
    // CA-05-3: dispara push para selecionados e não-selecionados via Edge Function
    try {
      final op = await _client
          .from('oportunidades')
          .select('titulo')
          .eq('id', oportunidadeId)
          .single();
      final naoSelecionadosResponse = await _client
          .from('candidaturas')
          .select('id')
          .eq('oportunidade_id', oportunidadeId)
          .eq('status', 'nao_selecionado');
      final naoSelecionadosIds = (naoSelecionadosResponse as List)
          .map((c) => c['id'] as String)
          .toList();
      await _client.functions.invoke('notify-atribuicao', body: {
        'oportunidade_id': oportunidadeId,
        'titulo': op['titulo'] as String,
        'selecionados_ids': candidaturaIds,
        'nao_selecionados_ids': naoSelecionadosIds,
      });
    } catch (_) {
      // push é best-effort — não bloqueia o fluxo principal
    }
  }

  Future<void> atualizarStatus({
    required String oportunidadeId,
    required String novoStatus,
    String? motivo,
  }) async {
    await _client.from('oportunidades').update({
      'status': novoStatus,
      if (motivo != null) 'motivo_cancelamento': motivo,
    }).eq('id', oportunidadeId);

    // CA-06-5: ao concluir, registra valor e data na atribuição
    if (novoStatus == 'concluida') {
      final op = await _client
          .from('oportunidades')
          .select('valor_estimado, data_execucao')
          .eq('id', oportunidadeId)
          .single();
      await _client
          .from('atribuicoes')
          .update({
            'data_conclusao': DateTime.now().toIso8601String(),
            if (op['valor_estimado'] != null)
              'valor_final': op['valor_estimado'],
          })
          .eq('oportunidade_id', oportunidadeId);
    }
  }

  Future<void> avaliar({
    required String oportunidadeId,
    required String cooperadoId,
    required int nota,
    String? comentario,
  }) async {
    await _client.from('avaliacoes').upsert({
      'oportunidade_id': oportunidadeId,
      'cooperado_id': cooperadoId,
      'nota': nota,
      if (comentario != null) 'comentario': comentario,
    }, onConflict: 'oportunidade_id,cooperado_id');
  }

  Future<List<Map<String, dynamic>>> getCandidaturasByCooperado(String cooperadoId) async {
    final response = await _client
        .from('candidaturas')
        .select('*, oportunidade:oportunidades(titulo, tipo, status, prazo_candidatura, data_execucao, valor_estimado)')
        .eq('cooperado_id', cooperadoId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<double> getAvaliacaoMedia(String cooperadoId) async {
    final response = await _client
        .from('avaliacoes')
        .select('nota')
        .eq('cooperado_id', cooperadoId);
    if (response.isEmpty) return 0.0;
    final total = response.fold<double>(0, (s, r) => s + ((r['nota'] as num?)?.toDouble() ?? 0));
    return total / response.length;
  }
}
