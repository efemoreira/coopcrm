import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Determina se o campo é CPF (só dígitos, 11 chars) e converte para email@cpf
  /// Supabase não tem login por CPF nativamente — usamos email fictício derivado do CPF
  /// OU podemos buscar o email pelo CPF antes; usamos a abordagem simples de email com cpf.
  String _resolveLogin(String input) {
    final stripped = input.replaceAll(RegExp(r'\D'), '');
    if (stripped.length == 11) {
      // CPF → email derivado: cpf@coopcrm.local (padrão de cadastro)
      return '$stripped@coopcrm.local';
    }
    return input.trim();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _resolveLogin(_loginCtrl.text.trim());
    context.read<AuthBloc>().add(AuthSignInRequested(
      email: email,
      password: _passwordCtrl.text,
    ));
  }

  void _showEsqueciSenha() {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite seu e-mail para receber o link de redefinição.'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = ctrl.text.trim();
              if (email.contains('@')) {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(AuthResetPasswordRequested(email));
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('CPF/e-mail ou senha incorretos'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AuthResetPasswordSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link de redefinição enviado para seu e-mail.'),
              backgroundColor: AppColors.statusAberta,
            ),
          );
        }
      },
      builder: (context, state) {
        return LoadingOverlay(
          isLoading: state is AuthLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.handshake_outlined, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'CoopCRM',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestão cooperativa simplificada',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entrar',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _loginCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail ou CPF';
                                    final stripped = v.replaceAll(RegExp(r'\D'), '');
                                    if (stripped.length == 11) return null; // CPF válido
                                    if (v.contains('@')) return null; // email
                                    return 'E-mail inválido ou CPF com 11 dígitos';
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail ou CPF',
                                    prefixIcon: Icon(Icons.person_outlined),
                                    hintText: 'usuario@email.com ou 00000000000',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  validator: (v) => Validators.minLength(v, 6),
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: state is AuthLoading ? null : _showEsqueciSenha,
                                    child: const Text('Esqueci minha senha'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: state is AuthLoading ? null : _submit,
                                  child: state is AuthLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Entrar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

