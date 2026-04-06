import 'dart:math' show max;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/cooperados/domain/repositories/cooperados_repository.dart';
import '../../../../features/cotas/domain/repositories/cotas_repository.dart';
import '../../../../features/oportunidades/domain/repositories/oportunidades_repository.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final cooperativaId = auth is AuthAuthenticated ? auth.user.cooperativeId ?? '' : '';
    final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;

    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Acesso restrito a administradores.')));
    }
    return _RelatoriosView(cooperativaId: cooperativaId);
  }
}

class _CoopStats {
  final String cooperadoId;
  final String nome;
  final int numServicos;
  final double valorTotal;
  final double avaliacaoMedia;
  const _CoopStats({
    required this.cooperadoId,
    required this.nome,
    required this.numServicos,
    required this.valorTotal,
    required this.avaliacaoMedia,
  });
}

/// CA-13-4: dados de inadimplência por cooperado
class _InadimpData {
  final String cooperadoId;
  final String nome;
  final int maxDiasAtraso;
  const _InadimpData({
    required this.cooperadoId,
    required this.nome,
    required this.maxDiasAtraso,
  });
}

class _RelatorioData {
  final int totalCooperados;
  final int totalAtivos;
  final int totalInadimplentes;
  final int oportunidadesConcluidas;
  final double valorTotalPago;
  final double valorTotalDevido;
  final List<_CoopStats> statsPorCooperado;
  /// CA-13-4: lista de inadimplentes com dias de atraso
  final List<_InadimpData> inadimplentesDetalhes;
  const _RelatorioData({
    required this.totalCooperados,
    required this.totalAtivos,
    required this.totalInadimplentes,
    required this.oportunidadesConcluidas,
    required this.valorTotalPago,
    required this.valorTotalDevido,
    required this.statsPorCooperado,
    this.inadimplentesDetalhes = const [],
  });
}

class _RelatoriosView extends StatefulWidget {
  final String cooperativaId;
  const _RelatoriosView({required this.cooperativaId});
  @override
  State<_RelatoriosView> createState() => _RelatoriosViewState();
}

class _RelatoriosViewState extends State<_RelatoriosView> {
  late Future<_RelatorioData> _future;
  String _periodo = 'todos';

  static const _periodos = [
    ('mes_atual', 'Mês atual'),
    ('trimestre', 'Trimestre'),
    ('ano', 'Ano'),
    ('todos', 'Todos'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _buildRelatorio();
    });
  }

  Future<_RelatorioData> _buildRelatorio() async {
    final cooperados = await getIt<CooperadosRepository>().getAll(widget.cooperativaId);
    final cotas = await getIt<CotasRepository>().getByCooperativa(widget.cooperativaId);

    final cList = cooperados.fold((_) => [], (list) => list);
    final cotaList = cotas.fold((_) => [], (list) => list);

    final totalCooperados = cList.length;
    final totalAtivos = cList.where((c) => c.status == 'ativo').length;
    final totalInadimplentes = cList.where((c) => c.status == 'inadimplente').length;

    final valorPago = cotaList.where((c) => c.isPago).fold<double>(0, (s, c) => s + (c.valorPago ?? 0));
    final valorDevido = cotaList.where((c) => !c.isPago).fold<double>(0, (s, c) => s + c.valorDevido);

    final now = DateTime.now();
    DateTime? since;
    if (_periodo == 'mes_atual') {
      since = DateTime(now.year, now.month, 1);
    } else if (_periodo == 'trimestre') {
      since = now.subtract(const Duration(days: 90));
    } else if (_periodo == 'ano') {
      since = DateTime(now.year, 1, 1);
    }

    int oportunidadesConcluidas = 0;
    final List<_CoopStats> statsPorCooperado = [];
    final oportunidadesRepo = getIt<OportunidadesRepository>();

    await Future.wait(cList.map((c) async {
      final hist = await oportunidadesRepo.getMeuHistorico(c.id);
      final avgResult = await oportunidadesRepo.getAvaliacaoMedia(c.id);
      final avg = avgResult.fold((_) => 0.0, (v) => v);
      hist.fold((_) {}, (list) {
        final filtered = since == null
            ? list.where((o) => o.status == 'concluida').toList()
            : list.where((o) => o.status == 'concluida' && o.dataExecucao != null && o.dataExecucao!.isAfter(since!)).toList();
        oportunidadesConcluidas += filtered.length;
        final valor = filtered.fold<double>(0, (s, o) => s + (o.valorEstimado ?? 0));
        statsPorCooperado.add(_CoopStats(
          cooperadoId: c.id,
          nome: c.nome,
          numServicos: filtered.length,
          valorTotal: valor,
          avaliacaoMedia: avg,
        ));
      });
    }));

    statsPorCooperado.sort((a, b) => b.numServicos.compareTo(a.numServicos));

    // CA-13-4: calcular inadimplência detalhada com dias de atraso
    final inadimplentesDetalhes = <_InadimpData>[];
    final cotasByCooperado = <String, List<dynamic>>{};
    for (final c in cotaList) {
      cotasByCooperado.putIfAbsent(c.cooperadoId, () => []).add(c);
    }
    for (final coop in cList) {
      final cotasAtraso = (cotasByCooperado[coop.id] ?? [])
          .where((c) => c.isEmAtraso)
          .toList();
      if (cotasAtraso.isEmpty) continue;
      // Calcula dias de atraso para cada cota em atraso
      int maxDias = 0;
      for (final cota in cotasAtraso) {
        try {
          final parts = cota.competencia.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          // Data de vencimento = último dia do mês de competência
          final vencimento = DateTime(year, month + 1, 0);
          final dias = DateTime.now().difference(vencimento).inDays;
          if (dias > maxDias) maxDias = dias;
        } catch (_) {}
      }
      if (maxDias > 0) {
        inadimplentesDetalhes.add(
          _InadimpData(
            cooperadoId: coop.id,
            nome: coop.nome,
            maxDiasAtraso: maxDias,
          ),
        );
      }
    }
    inadimplentesDetalhes.sort((a, b) => b.maxDiasAtraso.compareTo(a.maxDiasAtraso));

    return _RelatorioData(
      totalCooperados: totalCooperados,
      totalAtivos: totalAtivos,
      totalInadimplentes: totalInadimplentes,
      oportunidadesConcluidas: oportunidadesConcluidas,
      valorTotalPago: valorPago,
      valorTotalDevido: valorDevido,
      statsPorCooperado: statsPorCooperado,
      inadimplentesDetalhes: inadimplentesDetalhes,
    );
  }

  Future<void> _exportarCsv(_RelatorioData data) async {
    final buf = StringBuffer();
    buf.writeln('Cooperado,N\u00ba Servi\u00e7os,Valor Total (R\$),Avalia\u00e7\u00e3o M\u00e9dia');
    for (final s in data.statsPorCooperado) {
      buf.writeln('${s.nome},${s.numServicos},${s.valorTotal.toStringAsFixed(2)},${s.avaliacaoMedia.toStringAsFixed(1)}');
    }
    final bytes = Uint8List.fromList(buf.toString().codeUnits);
    final xFile = XFile.fromData(bytes, mimeType: 'text/csv', name: 'relatorio_coopcrm.csv');
    await Share.shareXFiles([xFile], subject: 'Relat\u00f3rio CoopCRM');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _load),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: _periodos.map((p) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(p.$2),
                  selected: _periodo == p.$1,
                  onSelected: (_) => setState(() {
                    _periodo = p.$1;
                    _load();
                  }),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                ),
              )).toList(),
            ),
          ),
        ),
      ),
      body: FutureBuilder<_RelatorioData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(child: Text('Erro ao carregar relatórios: ${snap.error}'));
          }
          final data = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Cooperados'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _KpiCard(label: 'Total', value: '${data.totalCooperados}', icon: Icons.group_outlined, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _KpiCard(label: 'Ativos', value: '${data.totalAtivos}', icon: Icons.check_circle_outline, color: AppColors.statusConcluida)),
                    const SizedBox(width: 12),
                    Expanded(child: _KpiCard(label: 'Inadimplentes', value: '${data.totalInadimplentes}', icon: Icons.warning_amber_outlined, color: AppColors.error)),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle('Produção'),
                const SizedBox(height: 12),
                _KpiRow(label: 'Serviços concluídos (histórico)', value: '${data.oportunidadesConcluidas}', icon: Icons.task_alt_outlined),
                const SizedBox(height: 24),
                _SectionTitle('Financeiro — Cotas'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _KpiCard(label: 'Total arrecadado', value: 'R\$ ${data.valorTotalPago.toStringAsFixed(2)}', icon: Icons.attach_money_outlined, color: AppColors.statusConcluida)),
                    const SizedBox(width: 12),
                    Expanded(child: _KpiCard(label: 'Em aberto', value: 'R\$ ${data.valorTotalDevido.toStringAsFixed(2)}', icon: Icons.money_off_outlined, color: AppColors.error)),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle('Inadimplência'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: data.totalInadimplentes == 0
                        ? AppColors.statusConcluida.withValues(alpha: 0.08)
                        : AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: data.totalInadimplentes == 0
                          ? AppColors.statusConcluida.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        data.totalInadimplentes == 0 ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                        color: data.totalInadimplentes == 0 ? AppColors.statusConcluida : AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        data.totalInadimplentes == 0
                            ? 'Nenhum cooperado inadimplente'
                            : '${data.totalInadimplentes} cooperado(s) com cotas em atraso',
                        style: TextStyle(
                          color: data.totalInadimplentes == 0 ? AppColors.statusConcluida : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _SectionTitle('Por Cooperado'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Desempenho individual', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    TextButton.icon(
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Exportar CSV'),
                      onPressed: () => _exportarCsv(data),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.statsPorCooperado.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum serviço encontrado no período.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.07)),
                      columns: const [
                        DataColumn(label: Text('Cooperado', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Serviços', style: TextStyle(fontWeight: FontWeight.w700)), numeric: true),
                        DataColumn(label: Text('Valor (R\$)', style: TextStyle(fontWeight: FontWeight.w700)), numeric: true),
                        DataColumn(label: Text('Avaliação', style: TextStyle(fontWeight: FontWeight.w700)), numeric: true),
                      ],
                      rows: data.statsPorCooperado.map((s) => DataRow(cells: [
                        DataCell(Text(s.nome)),
                        DataCell(Text('${s.numServicos}')),
                        DataCell(Text(s.valorTotal.toStringAsFixed(2))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(s.avaliacaoMedia > 0 ? s.avaliacaoMedia.toStringAsFixed(1) : '-'),
                          ],
                        )),
                      ])).toList(),
                    ),
                  ),
                // CA-13-3: gráfico de barras — distribuição de serviços
                if (data.statsPorCooperado.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle('Distribuição de Serviços'),
                  const SizedBox(height: 8),
                  _BarChart(data: data.statsPorCooperado),
                ],

                // CA-13-4: lista de inadimplência com dias de atraso
                if (data.inadimplentesDetalhes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle('Inadimplência Detalhada'),
                  const SizedBox(height: 8),
                  ...data.inadimplentesDetalhes.map(
                    (d) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFCDD2),
                          child: Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 18),
                        ),
                        title: Text(d.nome),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${d.maxDiasAtraso} dia${d.maxDiasAtraso == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// CA-13-3: gráfico de barras horizontal simples
class _BarChart extends StatelessWidget {
  final List<_CoopStats> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final visible = data.take(8).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final maxVal = visible.map((d) => d.numServicos).reduce(max).toDouble();
    if (maxVal == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: visible.map((d) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  d.nome,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) => Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: constraints.maxWidth * (d.numServicos / maxVal),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  '${d.numServicos}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _KpiRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }
}
