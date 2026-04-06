import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/cooperados_cubit.dart';
import '../../domain/repositories/cooperados_repository.dart';

class CriarCooperadoPage extends StatefulWidget {
  const CriarCooperadoPage({super.key});

  @override
  State<CriarCooperadoPage> createState() => _CriarCooperadoPageState();
}

class _CriarCooperadoPageState extends State<CriarCooperadoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CooperadosCubit, CooperadosState>(
      listener: (context, state) {
        if (state is CooperadosMutated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
          Navigator.pop(context);
        } else if (state is CooperadosError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        } else if (state is CooperadosLoading) {
          setState(() => _loading = true);
        } else {
          setState(() => _loading = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo Cooperado')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _nomeCtrl,
                  label: 'Nome completo *',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _cpfCtrl,
                  label: 'CPF *',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o CPF';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length != 11) return 'CPF deve ter 11 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'E-mail *',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _telefoneCtrl,
                  label: 'Telefone',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Cadastrar Cooperado'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    final cooperativeId =
        authState is AuthAuthenticated ? authState.user.cooperativeId ?? '' : '';
    context.read<CooperadosCubit>().criar(
          CriarCooperadoParams(
            cooperativeId: cooperativeId,
            nome: _nomeCtrl.text.trim(),
            cpf: _cpfCtrl.text.replaceAll(RegExp(r'\D'), ''),
            email: _emailCtrl.text.trim(),
            telefone: _telefoneCtrl.text.isNotEmpty ? _telefoneCtrl.text.trim() : null,
          ),
        );
  }
}
