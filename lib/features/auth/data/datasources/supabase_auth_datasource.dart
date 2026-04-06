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
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw const AuthException('Falha ao autenticar');
    final cooperado = await _fetchCooperado(user.id);
    return UserModel.fromSupabase(id: user.id, email: user.email ?? email, cooperadoData: cooperado);
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
  /// Retorna `null` se o usuário não tiver registro na tabela `cooperados`.
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
