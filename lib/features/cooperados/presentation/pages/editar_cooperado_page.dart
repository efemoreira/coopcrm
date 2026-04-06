import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/cooperados_cubit.dart';
import '../../domain/entities/cooperado_entity.dart';
import '../../domain/repositories/cooperados_repository.dart';

class EditarCooperadoPage extends StatefulWidget {
  final CooperadoEntity cooperado;
  const EditarCooperadoPage({required this.cooperado, super.key});

  @override
  State<EditarCooperadoPage> createState() => _EditarCooperadoPageState();
}

class _EditarCooperadoPageState extends State<EditarCooperadoPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeCtrl = TextEditingController(text: widget.cooperado.nome);
  late final _telefoneCtrl = TextEditingController(text: widget.cooperado.telefone ?? '');
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
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
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Editar cooperado')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _nomeCtrl,
                  label: 'Nome completo',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _telefoneCtrl,
                  label: 'Telefone (opcional)',
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
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Salvar alterações'),
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
    setState(() => _loading = true);
    context.read<CooperadosCubit>().editar(
          EditarCooperadoParams(
            cooperadoId: widget.cooperado.id,
            nome: _nomeCtrl.text.trim(),
            telefone: _telefoneCtrl.text.trim().isNotEmpty
                ? _telefoneCtrl.text.trim()
                : null,
            especialidades: widget.cooperado.especialidades,
          ),
        );
  }
}
