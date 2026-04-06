import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/repositories/oportunidades_repository.dart';
import '../../../../core/di/injection.dart';

class CriarOportunidadePage extends StatefulWidget {
  const CriarOportunidadePage({super.key});

  @override
  State<CriarOportunidadePage> createState() => _CriarOportunidadePageState();
}

class _CriarOportunidadePageState extends State<CriarOportunidadePage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _requisitosCtrl = TextEditingController();
  int _numVagas = 1;
  double? _valorEstimado;
  DateTime _prazo = DateTime.now().add(const Duration(days: 7));
  String _criterio = 'manual';
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _tipoCtrl.dispose();
    _descricaoCtrl.dispose();
    _localCtrl.dispose();
    _requisitosCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit({required String status}) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;

    setState(() => _isLoading = true);
    final repo = getIt<OportunidadesRepository>();
    final result = await repo.criar(CriarOportunidadeParams(
      cooperativeId: auth.user.cooperativeId ?? '',
      criadorId: auth.user.cooperadoId ?? '',
      titulo: _tituloCtrl.text.trim(),
      tipo: _tipoCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim().isNotEmpty ? _descricaoCtrl.text.trim() : null,
      prazoCandidata: _prazo,
      local: _localCtrl.text.trim().isNotEmpty ? _localCtrl.text.trim() : null,
      valorEstimado: _valorEstimado,
      numVagas: _numVagas,
      requisitos: _requisitosCtrl.text.trim().isNotEmpty ? _requisitosCtrl.text.trim() : null,
      criterioSelecao: _criterio,
      status: status,
    ));
    setState(() => _isLoading = false);

    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message), backgroundColor: AppColors.error),
      ),
      (oport) {
        final msg = status == 'aberta' ? 'Oportunidade publicada!' : 'Rascunho salvo!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.statusAberta),
        );
        // CA-04-5: ir direto para a oportunidade criada ao publicar
        if (status == 'aberta') {
          context.go('/feed/${oport.id}');
        } else {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Oportunidade')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Título *',
                controller: _tituloCtrl,
                validator: (v) => Validators.required(v, label: 'Título'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Tipo *',
                hint: 'Ex: Serviço de saúde, Transporte…',
                controller: _tipoCtrl,
                validator: (v) => Validators.required(v, label: 'Tipo'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descrição',
                controller: _descricaoCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Local',
                controller: _localCtrl,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vagas *', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() => _numVagas = (_numVagas - 1).clamp(1, 99)),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('\$_numVagas', style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              onPressed: () => setState(() => _numVagas = (_numVagas + 1).clamp(1, 99)),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Critério', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _criterio,
                          onChanged: (v) => setState(() => _criterio = v ?? 'manual'),
                          items: const [
                            DropdownMenuItem(value: 'manual', child: Text('Manual')),
                            DropdownMenuItem(value: 'fifo', child: Text('FIFO')),
                            DropdownMenuItem(value: 'rodizio', child: Text('Rodízio')),
                          ],
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Prazo para candidatura *', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _prazo,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _prazo = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text("${_prazo.day.toString().padLeft(2, '0')}/${_prazo.month.toString().padLeft(2, '0')}/${_prazo.year}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () => _submit(status: 'rascunho'),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar rascunho'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _submit(status: 'aberta'),
                      icon: _isLoading
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.publish_outlined),
                      label: const Text('Publicar agora'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
