// Cubit da tela de detalhe de oportunidade.
//
// Gerencia o ciclo completo de interação com uma oportunidade:
// candidatura, confirmação/declínio da seleção, atribuição manual,
// conclusão e avaliação de cooperados.
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/oportunidade_entity.dart';
import '../../domain/entities/candidatura_entity.dart';
import '../../domain/repositories/oportunidades_repository.dart';

// STATE
sealed class OportunidadeDetailState extends Equatable {
  const OportunidadeDetailState();
  @override List<Object?> get props => [];
}
final class OportunidadeDetailInitial extends OportunidadeDetailState { const OportunidadeDetailInitial(); }
final class OportunidadeDetailLoading extends OportunidadeDetailState { const OportunidadeDetailLoading(); }
final class OportunidadeDetailLoaded extends OportunidadeDetailState {
  final OportunidadeEntity oportunidade;
  final List<CandidaturaEntity> candidatos;
  final bool jaSeCandidata;
  final String? minhaCandidaturaId;
  final String? minhaCandidaturaStatus;
  /// CA-05-1: nº serviços concluídos por cooperado (chave = cooperadoId)
  final Map<String, int> servicosPorCooperado;
  /// CA-05-1 + CA-12-1: avaliação média por cooperado
  final Map<String, double> avaliacaoMediaPorCooperado;
  const OportunidadeDetailLoaded({
    required this.oportunidade,
    required this.candidatos,
    required this.jaSeCandidata,
    this.minhaCandidaturaId,
    this.minhaCandidaturaStatus,
    this.servicosPorCooperado = const {},
    this.avaliacaoMediaPorCooperado = const {},
  });
  @override List<Object?> get props => [oportunidade, candidatos, jaSeCandidata, minhaCandidaturaStatus];
}
final class OportunidadeDetailError extends OportunidadeDetailState {
  final String message;
  const OportunidadeDetailError(this.message);
  @override List<Object> get props => [message];
}
final class CandidaturaSuccess extends OportunidadeDetailState {
  const CandidaturaSuccess();
}
final class AtribuicaoSuccess extends OportunidadeDetailState {
  const AtribuicaoSuccess();
}
final class AcaoSuccess extends OportunidadeDetailState {
  final String message;
  const AcaoSuccess(this.message);
  @override List<Object> get props => [message];
}

// CUBIT
/// Cubit de detalhe de oportunidade. É instanciado por tela (não é singleton).
@injectable
class OportunidadeDetailCubit extends Cubit<OportunidadeDetailState> {
  final OportunidadesRepository _repo;
  String _currentId = '';
  String? _currentCooperadoId;

  OportunidadeDetailCubit(this._repo) : super(const OportunidadeDetailInitial());

  Future<void> load(String id, {String? cooperadoId}) async {
    _currentId = id;
    _currentCooperadoId = cooperadoId;
    emit(const OportunidadeDetailLoading());
    final result = await _repo.getById(id);
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (oport) async {
        final candidatosResult = await _repo.getCandidatos(id);
        candidatosResult.fold(
          (_) => emit(OportunidadeDetailLoaded(
            oportunidade: oport,
            candidatos: [],
            jaSeCandidata: false,
          )),
          (candidatos) async {
            final minha = cooperadoId != null
                ? candidatos.where((c) => c.cooperadoId == cooperadoId).firstOrNull
                : null;

            // CA-05-1: carregar nº serviços e avaliação média por candidato
            final servicosMap = <String, int>{};
            final avaliacaoMap = <String, double>{};
            await Future.wait(candidatos.map((c) async {
              final hist = await _repo.getMeuHistorico(c.cooperadoId);
              hist.fold((_) {}, (list) {
                servicosMap[c.cooperadoId] =
                    list.where((o) => o.status == 'concluida').length;
              });
              final av = await _repo.getAvaliacaoMedia(c.cooperadoId);
              av.fold((_) {}, (media) {
                if (media > 0) avaliacaoMap[c.cooperadoId] = media;
              });
            }));

            emit(OportunidadeDetailLoaded(
              oportunidade: oport,
              candidatos: candidatos,
              jaSeCandidata: minha != null,
              minhaCandidaturaId: minha?.id,
              minhaCandidaturaStatus: minha?.status,
              servicosPorCooperado: servicosMap,
              avaliacaoMediaPorCooperado: avaliacaoMap,
            ));
          },
        );
      },
    );
  }

  Future<void> candidatar({
    required String oportunidadeId,
    required String cooperadoId,
    String? mensagem,
  }) async {
    final result = await _repo.candidatar(
      oportunidadeId: oportunidadeId,
      cooperadoId: cooperadoId,
      mensagem: mensagem,
    );
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (_) => emit(const CandidaturaSuccess()),
    );
  }

  Future<void> atribuir({
    required String oportunidadeId,
    required List<String> candidaturaIds,
    required String atribuidoPor,
  }) async {
    final result = await _repo.atribuirManual(
      oportunidadeId: oportunidadeId,
      candidaturaIds: candidaturaIds,
      atribuidoPor: atribuidoPor,
    );
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (_) async {
        emit(const AtribuicaoSuccess());
        await load(oportunidadeId, cooperadoId: _currentCooperadoId);
      },
    );
  }

  Future<void> confirmarSelecionado(String oportunidadeId) async {
    final result = await _repo.atualizarStatus(
      oportunidadeId: oportunidadeId,
      novoStatus: 'em_execucao',
    );
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (_) async {
        emit(const AcaoSuccess('Participação confirmada! Boa sorte.'));
        await load(oportunidadeId, cooperadoId: _currentCooperadoId);
      },
    );
  }

  Future<void> declinarSelecionado(String candidaturaId) async {
    final result = await _repo.desistir(candidaturaId);
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (_) async {
        emit(const AcaoSuccess('Participação declinada. O próximo candidato será notificado.'));
        await load(_currentId, cooperadoId: _currentCooperadoId);
      },
    );
  }

  Future<void> concluir(String oportunidadeId) async {
    final result = await _repo.atualizarStatus(
      oportunidadeId: oportunidadeId,
      novoStatus: 'concluida',
    );
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (_) async {
        emit(const AcaoSuccess('Oportunidade marcada como concluída!'));
        await load(oportunidadeId, cooperadoId: _currentCooperadoId);
      },
    );
  }

  /// Recarrega o estado com o mesmo ID e cooperado atual
  Future<void> reload() async {
    if (_currentId.isEmpty) return;
    await load(_currentId, cooperadoId: _currentCooperadoId);
  }

  /// CA-06-6: admin avalia o desempenho do cooperado selecionado
  Future<void> avaliarCooperado({
    required String oportunidadeId,
    required String cooperadoId,
    required int nota,
    String? comentario,
  }) async {
    final result = await _repo.avaliar(
      oportunidadeId: oportunidadeId,
      cooperadoId: cooperadoId,
      nota: nota,
      comentario: comentario,
    );
    result.fold(
      (f) => emit(OportunidadeDetailError(f.message)),
      (_) => emit(const AcaoSuccess('Avaliação enviada! Obrigado 🌟')),
    );
  }
}
