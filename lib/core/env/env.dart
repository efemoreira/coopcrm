// Variáveis de ambiente carregadas do arquivo `.env` via `envied`.
// Os valores são ofuscados no binário de produção (`obfuscate: true`).
// Gere o arquivo `.env.g.dart` com: `flutter pub run build_runner build`
import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _Env.supabaseAnonKey;
}
