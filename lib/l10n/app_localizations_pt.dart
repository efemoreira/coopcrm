// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'CoopCRM';

  @override
  String get navOportunidades => 'Oportunidades';

  @override
  String get navComunicados => 'Comunicados';

  @override
  String get navCotas => 'Cotas';

  @override
  String get navPerfil => 'Perfil';

  @override
  String get loginTitle => 'Entrar no CoopCRM';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginLoading => 'Entrando...';

  @override
  String get loginForgotPassword => 'Esqueci minha senha';

  @override
  String get loginError => 'E-mail ou senha incorretos. Tente novamente.';

  @override
  String get feedTitle => 'Oportunidades';

  @override
  String get feedEmpty => 'Nenhuma oportunidade encontrada';

  @override
  String get feedFilterAll => 'Todas';

  @override
  String get feedFilterOpen => 'Abertas';

  @override
  String get feedFilterAssigned => 'Atribuídas';

  @override
  String get feedFilterDone => 'Concluídas';

  @override
  String get feedNewOpportunity => 'Nova';

  @override
  String get detailCandidateButton => 'Candidatar-me';

  @override
  String get detailAlreadyCandidated => 'Você já se candidatou';

  @override
  String get detailCandidatureSuccess => 'Candidatura enviada com sucesso!';

  @override
  String get detailDescription => 'Descrição';

  @override
  String get detailRequirements => 'Requisitos';

  @override
  String detailCandidates(int count) {
    return 'Candidatos ($count)';
  }

  @override
  String detailDeadline(String date) {
    return 'Prazo: $date';
  }

  @override
  String detailVacancies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vagas',
      one: '$count vaga',
    );
    return '$_temp0';
  }

  @override
  String get comunicadosTitle => 'Comunicados';

  @override
  String get comunicadosEmpty => 'Nenhum comunicado';

  @override
  String get cotasTitle => 'Minhas Cotas';

  @override
  String get cotasEmpty => 'Nenhuma cota encontrada';

  @override
  String get cotasTotal => 'Total Pago';

  @override
  String get cotasOpen => 'Em aberto';

  @override
  String get cotasPaid => 'Pago';

  @override
  String get perfilTitle => 'Meu Perfil';

  @override
  String get perfilAdmin => 'Administrador';

  @override
  String get perfilSignOut => 'Sair';

  @override
  String get perfilPersonalData => 'Dados pessoais';

  @override
  String get perfilChangePassword => 'Alterar senha';

  @override
  String get perfilNotificationPrefs => 'Preferências de notificação';

  @override
  String get statusRascunho => 'Rascunho';

  @override
  String get statusAberta => 'Aberta';

  @override
  String get statusEmCandidatura => 'Em candidatura';

  @override
  String get statusAtribuida => 'Atribuída';

  @override
  String get statusEmExecucao => 'Em execução';

  @override
  String get statusConcluida => 'Concluída';

  @override
  String get statusCancelada => 'Cancelada';

  @override
  String get errorGeneric => 'Ocorreu um erro. Tente novamente.';

  @override
  String get errorNetwork => 'Verifique sua conexão com a internet.';

  @override
  String get errorNotFound => 'Item não encontrado.';

  @override
  String get errorUnauthorized => 'Sessão expirada. Faça login novamente.';

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get confirmButton => 'Confirmar';

  @override
  String get loadingLabel => 'Carregando...';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'CoopCRM';

  @override
  String get navOportunidades => 'Oportunidades';

  @override
  String get navComunicados => 'Comunicados';

  @override
  String get navCotas => 'Cotas';

  @override
  String get navPerfil => 'Perfil';

  @override
  String get loginTitle => 'Entrar no CoopCRM';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginLoading => 'Entrando...';

  @override
  String get loginForgotPassword => 'Esqueci minha senha';

  @override
  String get loginError => 'E-mail ou senha incorretos. Tente novamente.';

  @override
  String get feedTitle => 'Oportunidades';

  @override
  String get feedEmpty => 'Nenhuma oportunidade encontrada';

  @override
  String get feedFilterAll => 'Todas';

  @override
  String get feedFilterOpen => 'Abertas';

  @override
  String get feedFilterAssigned => 'Atribuídas';

  @override
  String get feedFilterDone => 'Concluídas';

  @override
  String get feedNewOpportunity => 'Nova';

  @override
  String get detailCandidateButton => 'Candidatar-me';

  @override
  String get detailAlreadyCandidated => 'Você já se candidatou';

  @override
  String get detailCandidatureSuccess => 'Candidatura enviada com sucesso!';

  @override
  String get detailDescription => 'Descrição';

  @override
  String get detailRequirements => 'Requisitos';

  @override
  String detailCandidates(int count) {
    return 'Candidatos ($count)';
  }

  @override
  String detailDeadline(String date) {
    return 'Prazo: $date';
  }

  @override
  String detailVacancies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vagas',
      one: '$count vaga',
    );
    return '$_temp0';
  }

  @override
  String get comunicadosTitle => 'Comunicados';

  @override
  String get comunicadosEmpty => 'Nenhum comunicado';

  @override
  String get cotasTitle => 'Minhas Cotas';

  @override
  String get cotasEmpty => 'Nenhuma cota encontrada';

  @override
  String get cotasTotal => 'Total Pago';

  @override
  String get cotasOpen => 'Em aberto';

  @override
  String get cotasPaid => 'Pago';

  @override
  String get perfilTitle => 'Meu Perfil';

  @override
  String get perfilAdmin => 'Administrador';

  @override
  String get perfilSignOut => 'Sair';

  @override
  String get perfilPersonalData => 'Dados pessoais';

  @override
  String get perfilChangePassword => 'Alterar senha';

  @override
  String get perfilNotificationPrefs => 'Preferências de notificação';

  @override
  String get statusRascunho => 'Rascunho';

  @override
  String get statusAberta => 'Aberta';

  @override
  String get statusEmCandidatura => 'Em candidatura';

  @override
  String get statusAtribuida => 'Atribuída';

  @override
  String get statusEmExecucao => 'Em execução';

  @override
  String get statusConcluida => 'Concluída';

  @override
  String get statusCancelada => 'Cancelada';

  @override
  String get errorGeneric => 'Ocorreu um erro. Tente novamente.';

  @override
  String get errorNetwork => 'Verifique sua conexão com a internet.';

  @override
  String get errorNotFound => 'Item não encontrado.';

  @override
  String get errorUnauthorized => 'Sessão expirada. Faça login novamente.';

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get confirmButton => 'Confirmar';

  @override
  String get loadingLabel => 'Carregando...';
}
