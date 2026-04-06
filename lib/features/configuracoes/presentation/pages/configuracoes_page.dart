import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/app_text_field.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final cooperativaId = auth is AuthAuthenticated ? auth.user.cooperativeId : null;
    final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;

    if (!isAdmin || cooperativaId == null) {
      return const Scaffold(body: Center(child: Text('Acesso restrito a administradores.')));
    }
    return _ConfiguracoesView(cooperativaId: cooperativaId);
  }
}

class _ConfiguracoesView extends StatefulWidget {
  final String cooperativaId;
  const _ConfiguracoesView({required this.cooperativaId});
  @override
  State<_ConfiguracoesView> createState() => _ConfiguracoesViewState();
}

class _ConfiguracoesViewState extends State<_ConfiguracoesView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  final _criterioCtrl = TextEditingController();
  // CA-14-1: URL da logo da cooperativa
  final _logoUrlCtrl = TextEditingController();
  String? _tipo;
  String? _periodoApuracao;
  bool _loading = false;
  bool _saving = false;
  String? _erro;

  static const _tiposCooperativa = [
    ('trabalho', 'Trabalho'),
    ('saude', 'Saúde'),
    ('transporte', 'Transporte'),
    ('educacao', 'Educação'),
    ('agro', 'Agro'),
  ];

  static const _periodosApuracao = [
    ('mensal', 'Mensal'),
    ('trimestral', 'Trimestral'),
    ('anual', 'Anual'),
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _labelCtrl.dispose();
    _criterioCtrl.dispose();
    _logoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    try {
      final client = getIt<SupabaseClient>(instanceName: 'supabase');
      final data = await client
          .from('cooperativas')
          .select('nome, tipo, label_oportunidade, criterio_selecao_padrao, periodo_apuracao, logo_url')
          .eq('id', widget.cooperativaId)
          .maybeSingle();
      if (data != null) {
        _nomeCtrl.text = data['nome'] ?? '';
        _labelCtrl.text = data['label_oportunidade'] ?? '';
        _criterioCtrl.text = data['criterio_selecao_padrao'] ?? '';
        _tipo = data['tipo'] as String?;
        _periodoApuracao = data['periodo_apuracao'] as String?;
        _logoUrlCtrl.text = data['logo_url'] ?? '';
      }
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _erro = null;
    });
    try {
      final client = getIt<SupabaseClient>(instanceName: 'supabase');
      await client.from('cooperativas').update({
        'nome': _nomeCtrl.text.trim(),
        if (_labelCtrl.text.trim().isNotEmpty) 'label_oportunidade': _labelCtrl.text.trim(),
        if (_criterioCtrl.text.trim().isNotEmpty) 'criterio_selecao_padrao': _criterioCtrl.text.trim(),
        if (_tipo != null) 'tipo': _tipo,
        if (_periodoApuracao != null) 'periodo_apuracao': _periodoApuracao,
        if (_logoUrlCtrl.text.trim().isNotEmpty) 'logo_url': _logoUrlCtrl.text.trim(),
      }).eq('id', widget.cooperativaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas!'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      setState(() => _erro = 'Erro ao salvar: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações da cooperativa')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações da cooperativa',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    // CA-14-1: URL da logo configurável
                    AppTextField(
                      controller: _logoUrlCtrl,
                      label: 'URL da logo da cooperativa (opcional)',
                      hint: 'https://exemplo.com/logo.png',
                      prefixIcon: const Icon(Icons.image_outlined),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _nomeCtrl,
                      label: 'Nome da cooperativa',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _labelCtrl,
                      label: 'Label para "Oportunidade" (ex: Serviço, Trabalho)',
                      hint: 'Oportunidade',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: ['fifo', 'rodizio', 'manual'].contains(_criterioCtrl.text.trim())
                          ? _criterioCtrl.text.trim()
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Critério de seleção padrão',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'fifo', child: Text('FIFO (primeiro a se candidatar)')),
                        DropdownMenuItem(value: 'rodizio', child: Text('Rodízio (menor produção)')),
                        DropdownMenuItem(value: 'manual', child: Text('Manual (admin escolhe)')),
                      ],
                      onChanged: (v) => setState(() => _criterioCtrl.text = v ?? 'manual'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo da cooperativa',
                        border: OutlineInputBorder(),
                      ),
                      items: _tiposCooperativa
                          .map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)))
                          .toList(),
                      onChanged: (v) => setState(() => _tipo = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _periodoApuracao,
                      decoration: const InputDecoration(
                        labelText: 'Período de apuração',
                        border: OutlineInputBorder(),
                      ),
                      items: _periodosApuracao
                          .map((p) => DropdownMenuItem(value: p.$1, child: Text(p.$2)))
                          .toList(),
                      onChanged: (v) => setState(() => _periodoApuracao = v),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 12),
                      Text(_erro!, style: const TextStyle(color: AppColors.error)),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Salvar configurações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
