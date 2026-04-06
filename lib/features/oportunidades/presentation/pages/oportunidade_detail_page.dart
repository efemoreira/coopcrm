import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../domain/entities/candidatura_entity.dart';
import '../bloc/oportunidade_detail_cubit.dart';

class OportunidadeDetailPage extends StatelessWidget {
  final String id;
  const OportunidadeDetailPage({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final cooperadoId = authState is AuthAuthenticated ? authState.user.cooperadoId : null;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    final isInadimplente = authState is AuthAuthenticated && authState.user.isInadimplente;

    return BlocProvider(
      create: (_) => getIt<OportunidadeDetailCubit>()..load(id, cooperadoId: cooperadoId),
      child: _OportunidadeDetailView(cooperadoId: cooperadoId, isAdmin: isAdmin, userId: userId, isInadimplente: isInadimplente),
    );
  }
}

class _OportunidadeDetailView extends StatefulWidget {
  final String? cooperadoId;
  final bool isAdmin;
  final String userId;
  final bool isInadimplente;
  const _OportunidadeDetailView({this.cooperadoId, required this.isAdmin, required this.userId, this.isInadimplente = false});

  @override
  State<_OportunidadeDetailView> createState() => _OportunidadeDetailViewState();
}

class _OportunidadeDetailViewState extends State<_OportunidadeDetailView> {
  final _mensagemCtrl = TextEditingController();
  final Set<String> _selectedCandidaturaIds = {};
  /// CA-05-2: modo de atribuição (manual / fifo / rodizio)
  String _modoAtribuicao = 'manual';

  @override
  void dispose() {
    _mensagemCtrl.dispose();
    super.dispose();
  }

  /// CA-05-2: auto-seleciona candidatos conforme o modo
  void _autoSelecionarCandidatos(
    String modo,
    List<CandidaturaEntity> candidatos,
    Map<String, int> servicosPorCoop,
    int numVagas,
  ) {
    if (modo == 'manual') {
      setState(() => _selectedCandidaturaIds.clear());
      return;
    }
    final sorted = switch (modo) {
      'fifo' => ([...candidatos]..sort((a, b) => a.createdAt.compareTo(b.createdAt))),
      'rodizio' => ([...candidatos]..sort((a, b) =>
          (servicosPorCoop[a.cooperadoId] ?? 0)
              .compareTo(servicosPorCoop[b.cooperadoId] ?? 0))),
      _ => <CandidaturaEntity>[],
    };
    setState(() {
      _selectedCandidaturaIds
        ..clear()
        ..addAll(sorted.take(numVagas).map((c) => c.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OportunidadeDetailCubit, OportunidadeDetailState>(
      listener: (context, state) {
        if (state is CandidaturaSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidatura registrada! Aguarde o resultado.'),
              backgroundColor: AppColors.statusAberta,
            ),
          );
          context.read<OportunidadeDetailCubit>().reload();
        } else if (state is AtribuicaoSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidatos atribuídos com sucesso!'),
              backgroundColor: AppColors.primary,
            ),
          );
          setState(() => _selectedCandidaturaIds.clear());
        } else if (state is AcaoSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
        } else if (state is OportunidadeDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is OportunidadeDetailLoading;
        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes')),
          body: switch (state) {
            OportunidadeDetailLoading() => const Center(child: CircularProgressIndicator()),
            OportunidadeDetailError(:final message) => ErrorDisplay(
                message: message,
                onRetry: () => context.read<OportunidadeDetailCubit>().load(
                  '',
                  cooperadoId: widget.cooperadoId,
                ),
              ),
            OportunidadeDetailLoaded(
              :final oportunidade,
              :final candidatos,
              :final jaSeCandidata,
              :final minhaCandidaturaId,
              :final minhaCandidaturaStatus,
              :final servicosPorCooperado,
              :final avaliacaoMediaPorCooperado,
            ) =>
              LoadingOverlay(
                isLoading: isLoading,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              oportunidade.titulo,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          StatusChip(oportunidade.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.category_outlined, text: oportunidade.tipo),
                      if (oportunidade.local != null)
                        _InfoRow(icon: Icons.location_on_outlined, text: oportunidade.local!),
                      _InfoRow(
                        icon: Icons.schedule_outlined,
                        text: 'Prazo: ${AppDateUtils.formatDateTime(oportunidade.prazoCandidata)}',
                      ),
                      if (oportunidade.dataExecucao != null)
                        _InfoRow(
                          icon: Icons.event_outlined,
                          text: 'Execução: ${AppDateUtils.formatDateTime(oportunidade.dataExecucao!)}',
                        ),
                      _InfoRow(
                        icon: Icons.group_outlined,
                        text: '${oportunidade.numVagas} vaga${oportunidade.numVagas > 1 ? "s" : ""}',
                      ),
                      if (oportunidade.valorEstimado != null)
                        _InfoRow(
                          icon: Icons.attach_money_outlined,
                          text: 'R\$ ${oportunidade.valorEstimado!.toStringAsFixed(2)}',
                          bold: true,
                          color: AppColors.primary,
                        ),
                      if (oportunidade.descricao != null) ...[
                        const SizedBox(height: 16),
                        Text('Descrição', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(oportunidade.descricao!, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                      if (oportunidade.requisitos != null) ...[
                        const SizedBox(height: 16),
                        Text('Requisitos', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(oportunidade.requisitos!, style: Theme.of(context).textTheme.bodyLarge),
                      ],

                      // ── COOPERADO: Candidatar-me ──────────────────────────
                      if (!widget.isAdmin &&
                          widget.cooperadoId != null &&
                          oportunidade.status == 'aberta' &&
                          !oportunidade.isExpired) ...[
                        const SizedBox(height: 24),
                        if (widget.isInadimplente)
                          _StatusBanner(
                            icon: Icons.block_outlined,
                            color: AppColors.error,
                            text: 'Regularize sua situação para se candidatar',
                          )
                        else if (!jaSeCandidata) ...[
                          TextFormField(
                            controller: _mensagemCtrl,
                            maxLines: 3,
                            maxLength: 500,
                            decoration: const InputDecoration(
                              labelText: 'Mensagem (opcional)',
                              hintText: 'Por que você quer esta oportunidade?',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.read<OportunidadeDetailCubit>().candidatar(
                              oportunidadeId: oportunidade.id,
                              cooperadoId: widget.cooperadoId!,
                              mensagem: _mensagemCtrl.text.isNotEmpty ? _mensagemCtrl.text : null,
                            ),
                            icon: const Icon(Icons.send_outlined),
                            label: const Text('Candidatar-me'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ] else
                          _StatusBanner(
                            icon: Icons.check_circle_outline,
                            color: AppColors.statusAberta,
                            text: 'Você já se candidatou',
                          ),
                      ],

                      // ── COOPERADO: Prazo encerrado ────────────────────────
                      if (!widget.isAdmin &&
                          widget.cooperadoId != null &&
                          oportunidade.status == 'aberta' &&
                          oportunidade.isExpired)
                        _StatusBanner(
                          icon: Icons.timer_off_outlined,
                          color: AppColors.textSecondary,
                          text: 'Prazo encerrado',
                        ),

                      // ── COOPERADO SELECIONADO: Confirmar / Declinar ───────
                      if (!widget.isAdmin && minhaCandidaturaStatus == 'selecionado') ...[
                        const SizedBox(height: 24),
                        _StatusBanner(
                          icon: Icons.star_outline,
                          color: AppColors.statusAberta,
                          text: '🎉 Você foi selecionado para esta oportunidade!',
                          subtitle: 'Confirme ou decline sua participação.',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showDeclinarDialog(context, minhaCandidaturaId!),
                                icon: const Icon(Icons.close, color: AppColors.error),
                                label: const Text('Declinar', style: TextStyle(color: AppColors.error)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.error),
                                  minimumSize: const Size.fromHeight(52),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context
                                    .read<OportunidadeDetailCubit>()
                                    .confirmarSelecionado(oportunidade.id),
                                icon: const Icon(Icons.check),
                                label: const Text('Confirmar'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  backgroundColor: AppColors.statusAberta,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ── ADMIN: Concluir ───────────────────────────────────
                      if (widget.isAdmin && oportunidade.status == 'em_execucao') ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showConcluirDialog(context, oportunidade.id),
                          icon: const Icon(Icons.task_alt),
                          label: const Text('Marcar como Concluída'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],

                      // ── ADMIN: Avaliar cooperados (CA-06-6) ───────────────
                      if (widget.isAdmin &&
                          oportunidade.status == 'concluida' &&
                          candidatos.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Avaliar cooperados',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        ...candidatos
                            .where((c) =>
                                c.status == 'selecionado' ||
                                c.status == 'em_execucao' ||
                                c.status == 'concluido')
                            .map((c) => Card(
                                  child: ListTile(
                                    leading: CircleAvatar(child: Text(c.cooperadoNome?[0] ?? '?')),
                                    title: Text(c.cooperadoNome ?? 'Cooperado'),
                                    subtitle: Row(
                                      children: [
                                        if (avaliacaoMediaPorCooperado.containsKey(c.cooperadoId)) ...[
                                          const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                                          const SizedBox(width: 2),
                                          Text(
                                            avaliacaoMediaPorCooperado[c.cooperadoId]!.toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ] else
                                          const Text('Sem avaliação', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.star_outline, color: Color(0xFFF59E0B)),
                                      tooltip: 'Avaliar ${c.cooperadoNome}',
                                      onPressed: () => _showAvaliarDialog(
                                        context,
                                        oportunidade.id,
                                        c.cooperadoId,
                                        cooperadoNome: c.cooperadoNome,
                                      ),
                                    ),
                                  ),
                                )),
                      ],

                      // ── LISTA DE CANDIDATOS ───────────────────────────────
                      if (candidatos.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              'Candidatos (${candidatos.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        // CA-05-2: seletor de modo quando admin pode atribuir
                        if (widget.isAdmin &&
                            (oportunidade.status == 'aberta' ||
                                oportunidade.status == 'em_candidatura')) ...[
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'manual',
                                label: Text('Manual'),
                                icon: Icon(Icons.touch_app_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'fifo',
                                label: Text('FIFO'),
                                icon: Icon(Icons.sort_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'rodizio',
                                label: Text('Rodízio'),
                                icon: Icon(Icons.rotate_right_outlined, size: 16),
                              ),
                            ],
                            selected: {_modoAtribuicao},
                            onSelectionChanged: (sel) {
                              setState(() => _modoAtribuicao = sel.first);
                              _autoSelecionarCandidatos(
                                sel.first,
                                candidatos,
                                servicosPorCooperado,
                                oportunidade.numVagas,
                              );
                            },
                            style: const ButtonStyle(
                              visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                            ),
                          ),
                          if (_modoAtribuicao == 'fifo')
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'FIFO: os ${oportunidade.numVagas} primeiros a se candidatar serão selecionados automaticamente.',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            )
                          else if (_modoAtribuicao == 'rodizio')
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Rodízio: cooperados com menos serviços têm prioridade.',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                        ],
                        const SizedBox(height: 8),
                        ...candidatos.map(
                          (c) => CheckboxListTile(
                            value: widget.isAdmin
                                ? _selectedCandidaturaIds.contains(c.id)
                                : null,
                            onChanged: widget.isAdmin &&
                                    (oportunidade.status == 'aberta' ||
                                        oportunidade.status == 'em_candidatura')
                                ? (val) => setState(() {
                                      if (val == true) {
                                        if (_selectedCandidaturaIds.length < oportunidade.numVagas) {
                                          _selectedCandidaturaIds.add(c.id);
                                        }
                                      } else {
                                        _selectedCandidaturaIds.remove(c.id);
                                      }
                                    })
                                : null,
                            secondary: CircleAvatar(child: Text(c.cooperadoNome?[0] ?? '?')),
                            title: Text(c.cooperadoNome ?? 'Sem nome'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(AppDateUtils.timeAgo(c.createdAt))),
                                    StatusChip(c.status),
                                  ],
                                ),
                                // CA-05-1: nº serviços + avaliação média
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.work_outline, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${servicosPorCooperado[c.cooperadoId] ?? 0} serviços',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      if (avaliacaoMediaPorCooperado.containsKey(c.cooperadoId)) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 3),
                                        Text(
                                          avaliacaoMediaPorCooperado[c.cooperadoId]!.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],

                      // ── ADMIN: Atribuir ───────────────────────────────────
                      if (widget.isAdmin &&
                          (oportunidade.status == 'aberta' ||
                              oportunidade.status == 'em_candidatura') &&
                          candidatos.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        if (_selectedCandidaturaIds.isEmpty)
                          Text(
                            'Selecione ${oportunidade.numVagas} candidato${oportunidade.numVagas > 1 ? "s" : ""} acima para atribuir',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        if (_selectedCandidaturaIds.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: _selectedCandidaturaIds.length == oportunidade.numVagas
                                ? () => _showAtribuirDialog(context, oportunidade.id, widget.userId)
                                : null,
                            icon: const Icon(Icons.assignment_turned_in_outlined),
                            label: Text(
                              'Atribuir (${_selectedCandidaturaIds.length}/${oportunidade.numVagas})',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }

  void _showAtribuirDialog(BuildContext context, String oportunidadeId, String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Atribuição'),
        content: Text(
          'Atribuir esta oportunidade para ${_selectedCandidaturaIds.length} candidato(s) selecionado(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OportunidadeDetailCubit>().atribuir(
                oportunidadeId: oportunidadeId,
                candidaturaIds: _selectedCandidaturaIds.toList(),
                atribuidoPor: userId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Atribuir'),
          ),
        ],
      ),
    );
  }

  void _showDeclinarDialog(BuildContext context, String candidaturaId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Declinar participação'),
        content: const Text(
          'Tem certeza? O próximo candidato na fila será notificado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OportunidadeDetailCubit>().declinarSelecionado(candidaturaId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Declinar'),
          ),
        ],
      ),
    );
  }

  void _showConcluirDialog(BuildContext context, String oportunidadeId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Marcar como Concluída'),
        content: const Text('Confirma que a oportunidade foi executada e concluída?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OportunidadeDetailCubit>().concluir(oportunidadeId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showAvaliarDialog(BuildContext context, String oportunidadeId, String cooperadoId, {String? cooperadoNome}) {
    int _nota = 5;
    final _comentarioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(cooperadoNome != null ? 'Avaliar $cooperadoNome' : 'Avaliar cooperado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Qual nota você dá para o desempenho deste cooperado?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    onPressed: () => setDialogState(() => _nota = star),
                    icon: Icon(
                      star <= _nota ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _comentarioCtrl,
                maxLines: 2,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Comentário (opcional)',
                  hintText: 'Como foi sua experiência?',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<OportunidadeDetailCubit>().avaliarCooperado(
                  oportunidadeId: oportunidadeId,
                  cooperadoId: cooperadoId,
                  nota: _nota,
                  comentario: _comentarioCtrl.text.isNotEmpty ? _comentarioCtrl.text : null,
                );
              },
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar avaliação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? subtitle;
  const _StatusBanner({required this.icon, required this.color, required this.text, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;
  final Color? color;
  const _InfoRow({required this.icon, required this.text, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: bold ? FontWeight.w700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

