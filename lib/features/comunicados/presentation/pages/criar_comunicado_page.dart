import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/cooperados/domain/repositories/cooperados_repository.dart';
import '../../../../features/cooperados/domain/entities/cooperado_entity.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/comunicados_cubit.dart';
import '../../domain/repositories/comunicados_repository.dart';

class CriarComunicadoPage extends StatefulWidget {
  const CriarComunicadoPage({super.key});

  @override
  State<CriarComunicadoPage> createState() => _CriarComunicadoPageState();
}

class _CriarComunicadoPageState extends State<CriarComunicadoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _conteudoCtrl = TextEditingController();
  final _anexoUrlCtrl = TextEditingController();
  String _tipo = 'aviso';
  bool _pinned = false;
  bool _loading = false;
  // CA-11-2: destinatários — 'todos' ou 'especificos'
  String _destinatarios = 'todos';
  List<String> _selectedCooperadoIds = [];
  List<CooperadoEntity> _allCooperados = [];
  bool _loadingCooperados = false;

  @override
  void initState() {
    super.initState();
    _loadCooperados();
  }

  Future<void> _loadCooperados() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final cooperativeId = authState.user.cooperativeId ?? '';
    if (cooperativeId.isEmpty) return;
    setState(() => _loadingCooperados = true);
    final result = await getIt<CooperadosRepository>().getAll(cooperativeId);
    result.fold(
      (_) {},
      (list) {
        if (mounted) {
          setState(() => _allCooperados = list.where((c) => c.status == 'ativo').toList());
        }
      },
    );
    if (mounted) setState(() => _loadingCooperados = false);
  }
  @override
  void dispose() {
    _tituloCtrl.dispose();
    _conteudoCtrl.dispose();
    _anexoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComunicadosCubit, ComunicadosState>(
      listener: (context, state) {
        if (state is ComunicadosMutated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
          Navigator.pop(context);
        } else if (state is ComunicadosError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo Comunicado')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _tituloCtrl,
                  label: 'Título *',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conteudoCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo *',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o conteúdo' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'aviso', child: Text('Aviso')),
                    DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                    DropdownMenuItem(value: 'informativo', child: Text('Informativo')),
                  ],
                  onChanged: (v) => setState(() => _tipo = v ?? 'aviso'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _pinned,
                  onChanged: (v) => setState(() => _pinned = v),
                  title: const Text('Fixar no topo'),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _anexoUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Link do anexo (opcional)',
                    prefixIcon: Icon(Icons.attach_file_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
                // CA-11-2: Seleção de destinatários
                Text(
                  'Destinatários',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Todos os cooperados ativos'),
                  value: 'todos',
                  groupValue: _destinatarios,
                  onChanged: (v) => setState(() {
                    _destinatarios = v!;
                    _selectedCooperadoIds = [];
                  }),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Selecionar cooperados específicos'),
                  value: 'especificos',
                  groupValue: _destinatarios,
                  onChanged: (v) => setState(() => _destinatarios = v!),
                ),
                if (_destinatarios == 'especificos') ...[
                  const SizedBox(height: 8),
                  if (_loadingCooperados)
                    const Center(child: CircularProgressIndicator())
                  else if (_allCooperados.isEmpty)
                    Text('Nenhum cooperado ativo encontrado.', style: TextStyle(color: AppColors.textSecondary))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _allCooperados.map((c) {
                        final selected = _selectedCooperadoIds.contains(c.id);
                        return FilterChip(
                          label: Text(c.nome),
                          selected: selected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.primary,
                          onSelected: (v) => setState(() {
                            if (v) {
                              _selectedCooperadoIds.add(c.id);
                            } else {
                              _selectedCooperadoIds.remove(c.id);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  if (_destinatarios == 'especificos' && _selectedCooperadoIds.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Selecione ao menos um cooperado.',
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                ],
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: const Icon(Icons.send_outlined),
                  label: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Publicar Comunicado'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
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
    if (_destinatarios == 'especificos' && _selectedCooperadoIds.isEmpty) return;
    setState(() => _loading = true);
    final authState = context.read<AuthBloc>().state;
    final cooperativeId =
        authState is AuthAuthenticated ? authState.user.cooperativeId ?? '' : '';
    final autorId =
        authState is AuthAuthenticated ? authState.user.id : '';

    context.read<ComunicadosCubit>().criar(CriarComunicadoParams(
      cooperativeId: cooperativeId,
      titulo: _tituloCtrl.text.trim(),
      conteudo: _conteudoCtrl.text.trim(),
      tipo: _tipo,
      pinned: _pinned,
      autorId: autorId,
      anexoUrl: _anexoUrlCtrl.text.trim().isEmpty ? null : _anexoUrlCtrl.text.trim(),
      destinatarioIds: _destinatarios == 'todos' ? null : List.of(_selectedCooperadoIds),
    ));
  }
}
