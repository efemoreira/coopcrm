// Configuração de injeção de dependências com get_it + injectable.
// Execute `flutter pub run build_runner build` para regenerar `injection.config.dart`.
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection.config.dart';

/// Instância global do service locator.
final getIt = GetIt.instance;

/// Registra todos os serviços gerados pelo `injectable`.
/// Deve ser chamado em `main()` antes de `runApp()`.
@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class AppModule {
  @Named('supabase')
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
