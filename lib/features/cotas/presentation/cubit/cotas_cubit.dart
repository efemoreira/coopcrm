// Cubit de cotas mensais.
// Serve tanto para a visão do cooperado (minhas cotas) quanto para
// o dashboard administrativo (todas as cotas com totais adimplentes/inadimplentes).
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/cota_entity.dart';
import '../../domain/repositories/cotas_repository.dart';

sealed class CotasState extends Equatable {
  const CotasState();
  @override List<Object?> get props => [];
}
final class CotasInitial extends CotasState { const CotasInitial(); }
final class CotasLoading extends CotasState { const CotasLoading(); }
final class CotasLoaded extends CotasState {
  final List<CotaEntity> cotas;
  final double totalDevido;
  final double totalPago;
  const CotasLoaded({required this.cotas, required this.totalDevido, required this.totalPago});
  @override List<Object?> get props => [cotas, totalDevido, totalPago];
}
final class CotasAdminLoaded extends CotasState {
  final List<CotaEntity> todasCotas;
  final double totalPagoCooperativa;
  final double totalDevidoCooperativa;
  final int totalInadimplentes;
  /// CA-10-2: cooperados totalmente em dia
  final int totalAdimplentes;
  /// CA-10-2: cotas pendentes mas ainda não em atraso
  final int totalAVencer;
  const CotasAdminLoaded({
    required this.todasCotas,
    required this.totalPagoCooperativa,
    required this.totalDevidoCooperativa,
    required this.totalInadimplentes,
    this.totalAdimplentes = 0,
    this.totalAVencer = 0,
  });
  @override List<Object?> get props => [todasCotas, totalPagoCooperativa, totalDevidoCooperativa, totalInadimplentes, totalAdimplentes, totalAVencer];
}
final class CotasError extends CotasState {
  final String message;
  const CotasError(this.message);
  @override List<Object?> get props => [message];
}
final class CotasMutated extends CotasState {
  final String message;
  const CotasMutated(this.message);
  @override List<Object?> get props => [message];
}

/// Cubit de cotas. Instância por tela.
@injectable
class CotasCubit extends Cubit<CotasState> {
  final CotasRepository _repository;
  String _cooperadoId = '';
  CotasCubit(this._repository) : super(const CotasInitial());

  Future<void> load(String cooperadoId) async {
    _cooperadoId = cooperadoId;
    emit(const CotasLoading());
    final result = await _repository.getByCooperado(cooperadoId);
    result.fold(
      (f) => emit(CotasError(f.message)),
      (cotas) {
        final totalDevido = cotas
            .where((c) => c.status != 'pago')
            .fold<double>(0, (sum, c) => sum + c.valorDevido);
        final totalPago = cotas
            .where((c) => c.isPago)
            .fold<double>(0, (sum, c) => sum + (c.valorPago ?? 0));
        emit(CotasLoaded(cotas: cotas, totalDevido: totalDevido, totalPago: totalPago));
      },
    );
  }

  Future<void> loadAdmin(String cooperativaId) async {
    emit(const CotasLoading());
    final result = await _repository.getByCooperativa(cooperativaId);
    result.fold(
      (f) => emit(CotasError(f.message)),
      (cotas) {
        final totalPago = cotas.where((c) => c.isPago).fold<double>(0, (s, c) => s + (c.valorPago ?? 0));
        final totalDevido = cotas.where((c) => !c.isPago).fold<double>(0, (s, c) => s + c.valorDevido);
        // Agrupa por cooperado para calcular status de adimplência
        final byCooperado = <String, List<CotaEntity>>{};
        for (final c in cotas) {
          byCooperado.putIfAbsent(c.cooperadoId, () => []).add(c);
        }
        final inadimplentes = byCooperado.entries
            .where((e) => e.value.any((c) => c.isEmAtraso))
            .length;
        // CA-10-2: adimplentes = cooperados sem nenhuma cota em atraso
        final adimplentes = byCooperado.entries
            .where((e) => !e.value.any((c) => c.isEmAtraso))
            .length;
        // CA-10-2: a vencer = cotas pendentes (não pagas e não em atraso)
        final aVencer = cotas.where((c) => !c.isPago && !c.isEmAtraso).length;
        emit(CotasAdminLoaded(
          todasCotas: cotas,
          totalPagoCooperativa: totalPago,
          totalDevidoCooperativa: totalDevido,
          totalInadimplentes: inadimplentes,
          totalAdimplentes: adimplentes,
          totalAVencer: aVencer,
        ));
      },
    );
  }

  Future<void> lancarPagamento(LancarPagamentoParams params) async {
    final result = await _repository.lancarPagamento(params);
    result.fold(
      (f) => emit(CotasError(f.message)),
      (_) async {
        emit(const CotasMutated('Pagamento lançado com sucesso!'));
        await load(_cooperadoId);
      },
    );
  }
}
