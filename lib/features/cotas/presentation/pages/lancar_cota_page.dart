import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/cotas_cubit.dart';
import '../../domain/repositories/cotas_repository.dart';

class LancarCotaPage extends StatefulWidget {
  const LancarCotaPage({super.key});

  @override
  State<LancarCotaPage> createState() => _LancarCotaPageState();
}

class _LancarCotaPageState extends State<LancarCotaPage> {
  final _formKey = GlobalKey<FormState>();
  final _cooperadoIdCtrl = TextEditingController();
  final _competenciaCtrl = TextEditingController();
  final _valorDevidoCtrl = TextEditingController();
  final _valorPagoCtrl = TextEditingController();
  String _status = 'pago';
  // CA-10-1: data real do pagamento (permite registros retroativos)
  DateTime? _dataPagamento;
  bool _loading = false;

  @override
  void dispose() {
    _cooperadoIdCtrl.dispose();
    _competenciaCtrl.dispose();
    _valorDevidoCtrl.dispose();
    _valorPagoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CotasCubit, CotasState>(
      listener: (context, state) {
        if (state is CotasMutated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
          Navigator.pop(context);
        } else if (state is CotasError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        } else {
          if (state is CotasLoading) setState(() => _loading = true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Lançar Pagamento de Cota')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _cooperadoIdCtrl,
                  label: 'ID do Cooperado *',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o ID do cooperado' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _competenciaCtrl,
                  label: 'Competência (AAAA-MM) *',
                  keyboardType: TextInputType.datetime,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe a competência';
                    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(v.trim())) {
                      return 'Use o formato AAAA-MM';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _valorDevidoCtrl,
                  label: 'Valor devido (R\$) *',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o valor';
                    if (double.tryParse(v.replaceAll(',', '.')) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'pago', child: Text('Pago')),
                    DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                    DropdownMenuItem(value: 'em_atraso', child: Text('Em atraso')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'pago'),
                ),
                if (_status == 'pago') ...[
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _valorPagoCtrl,
                    label: 'Valor pago (R\$)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  // CA-10-1: DatePicker para data real do pagamento
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dataPagamento ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        locale: const Locale('pt', 'BR'),
                      );
                      if (picked != null) setState(() => _dataPagamento = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data do pagamento *',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dataPagamento != null
                            ? '${_dataPagamento!.day.toString().padLeft(2, '0')}/${_dataPagamento!.month.toString().padLeft(2, '0')}/${_dataPagamento!.year}'
                            : 'Selecione a data',
                        style: TextStyle(
                          color: _dataPagamento != null ? null : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
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
                      : const Text('Lançar Pagamento'),
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
    // CA-10-1: validar que data de pagamento foi preenchida
    if (_status == 'pago' && _dataPagamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a data do pagamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final authState = context.read<AuthBloc>().state;
    final cooperativaId =
        authState is AuthAuthenticated ? authState.user.cooperativeId ?? '' : '';
    final valorDevido =
        double.tryParse(_valorDevidoCtrl.text.replaceAll(',', '.')) ?? 0;
    final valorPago = _valorPagoCtrl.text.isNotEmpty
        ? double.tryParse(_valorPagoCtrl.text.replaceAll(',', '.'))
        : null;

    context.read<CotasCubit>().lancarPagamento(LancarPagamentoParams(
      cooperadoId: _cooperadoIdCtrl.text.trim(),
      cooperativaId: cooperativaId,
      competencia: _competenciaCtrl.text.trim(),
      valorDevido: valorDevido,
      valorPago: valorPago,
      status: _status,
      dataPagamento: _dataPagamento,
    ));
  }
}
