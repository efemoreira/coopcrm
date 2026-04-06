import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Fonte de dados de autenticação via Supabase Auth.
/// Após o login, busca os dados do cooperado na tabela `cooperados`
/// para compor o [UserModel] com papel (isAdmin) e status de adimplência.
@injectable
class SupabaseAuthDatasource {
  final SupabaseClient _client;
  SupabaseAuthDatasource(@Named('supabase') this._client);

  Future<UserModel> signIn({required String email, required String password}) async {
    debugPrint('[AuthDS] ── signIn chamado com input: "$email"');

    // Se o input for um CPF (11 dígitos, com ou sem máscara), resolve o email real pelo CPF
    final resolvedEmail = await _resolveEmail(email);
    debugPrint('[AuthDS] ── email resolvido: "$resolvedEmail"');

    try {
      debugPrint('[AuthDS] ── chamando Supabase signInWithPassword...');
      final response = await _client.auth.signInWithPassword(
        email: resolvedEmail,
        password: password,
      );
      debugPrint('[AuthDS] ── resposta recebida — user: ${response.user?.id}');

      final user = response.user;
      if (user == null) throw const AuthException('Falha ao autenticar');

      debugPrint('[AuthDS] ── buscando dados do cooperado para userId: ${user.id}');
      final cooperado = await _fetchCooperado(user.id);
      debugPrint('[AuthDS] ── cooperado encontrado: ${cooperado != null ? cooperado['nome'] : 'NÃO ENCONTRADO'}');

      return UserModel.fromSupabase(id: user.id, email: user.email ?? resolvedEmail, cooperadoData: cooperado);
    } on AuthException catch (e) {
      debugPrint('[AuthDS] ✗ AuthException: ${e.message} (statusCode: ${e.statusCode})');
      rethrow;
    } catch (e, st) {
      debugPrint('[AuthDS] ✗ Erro inesperado: $e');
      debugPrint('[AuthDS]   StackTrace: $st');
      throw AuthException(e.toString());
    }
  }

  /// Se o input parecer um CPF (11 dígitos numéricos, com ou sem máscara),
  /// chama a RPC `get_email_by_cpf` (SECURITY DEFINER, bypassa RLS)
  /// para obter o email real antes do signInWithPassword.
  Future<String> _resolveEmail(String input) async {
    final stripped = input.replaceAll(RegExp(r'\D'), '');
    debugPrint('[AuthDS] ── _resolveEmail: input="$input" stripped="$stripped" isCpf=${stripped.length == 11}');

    if (stripped.length != 11) return input.trim();

    try {
      debugPrint('[AuthDS] ── chamando RPC get_email_by_cpf("$stripped")');
      final result = await _client.rpc(
        'get_email_by_cpf',
        params: {'p_cpf': stripped},
      );
      debugPrint('[AuthDS] ── resultado RPC: $result');
      if (result != null && result is String && result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      debugPrint('[AuthDS] ✗ Erro ao chamar RPC get_email_by_cpf: $e');
    }

    debugPrint('[AuthDS] ✗ CPF não encontrado na tabela cooperados');
    return '$stripped@cpf.nao.encontrado';
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final cooperado = await _fetchCooperado(user.id);
    return UserModel.fromSupabase(
      id: user.id,
      email: user.email ?? '',
      cooperadoData: cooperado,
    );
  }

  /// Busca os dados do cooperado vinculado ao [userId] do Supabase Auth.
  Future<Map<String, dynamic>?> _fetchCooperado(String userId) async {
    try {
      final response = await _client
          .from('cooperados')
          .select('id, cooperative_id, is_admin, nome, foto_url, status')
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
