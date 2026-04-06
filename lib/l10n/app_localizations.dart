import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('pt', 'BR')
  ];

  /// Nome do aplicativo
  ///
  /// In pt_BR, this message translates to:
  /// **'CoopCRM'**
  String get appTitle;

  /// Tab de oportunidades
  ///
  /// In pt_BR, this message translates to:
  /// **'Oportunidades'**
  String get navOportunidades;

  /// Tab de comunicados
  ///
  /// In pt_BR, this message translates to:
  /// **'Comunicados'**
  String get navComunicados;

  /// Tab de cotas
  ///
  /// In pt_BR, this message translates to:
  /// **'Cotas'**
  String get navCotas;

  /// Tab de perfil
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil'**
  String get navPerfil;

  /// No description provided for @loginTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrar no CoopCRM'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In pt_BR, this message translates to:
  /// **'E-mail'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @loginLoading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrando...'**
  String get loginLoading;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt_BR, this message translates to:
  /// **'Esqueci minha senha'**
  String get loginForgotPassword;

  /// No description provided for @loginError.
  ///
  /// In pt_BR, this message translates to:
  /// **'E-mail ou senha incorretos. Tente novamente.'**
  String get loginError;

  /// No description provided for @feedTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Oportunidades'**
  String get feedTitle;

  /// No description provided for @feedEmpty.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nenhuma oportunidade encontrada'**
  String get feedEmpty;

  /// No description provided for @feedFilterAll.
  ///
  /// In pt_BR, this message translates to:
  /// **'Todas'**
  String get feedFilterAll;

  /// No description provided for @feedFilterOpen.
  ///
  /// In pt_BR, this message translates to:
  /// **'Abertas'**
  String get feedFilterOpen;

  /// No description provided for @feedFilterAssigned.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atribuídas'**
  String get feedFilterAssigned;

  /// No description provided for @feedFilterDone.
  ///
  /// In pt_BR, this message translates to:
  /// **'Concluídas'**
  String get feedFilterDone;

  /// No description provided for @feedNewOpportunity.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nova'**
  String get feedNewOpportunity;

  /// No description provided for @detailCandidateButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Candidatar-me'**
  String get detailCandidateButton;

  /// No description provided for @detailAlreadyCandidated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Você já se candidatou'**
  String get detailAlreadyCandidated;

  /// No description provided for @detailCandidatureSuccess.
  ///
  /// In pt_BR, this message translates to:
  /// **'Candidatura enviada com sucesso!'**
  String get detailCandidatureSuccess;

  /// No description provided for @detailDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Descrição'**
  String get detailDescription;

  /// No description provided for @detailRequirements.
  ///
  /// In pt_BR, this message translates to:
  /// **'Requisitos'**
  String get detailRequirements;

  /// No description provided for @detailCandidates.
  ///
  /// In pt_BR, this message translates to:
  /// **'Candidatos ({count})'**
  String detailCandidates(int count);

  /// No description provided for @detailDeadline.
  ///
  /// In pt_BR, this message translates to:
  /// **'Prazo: {date}'**
  String detailDeadline(String date);

  /// No description provided for @detailVacancies.
  ///
  /// In pt_BR, this message translates to:
  /// **'{count, plural, one{{count} vaga} other{{count} vagas}}'**
  String detailVacancies(int count);

  /// No description provided for @comunicadosTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Comunicados'**
  String get comunicadosTitle;

  /// No description provided for @comunicadosEmpty.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nenhum comunicado'**
  String get comunicadosEmpty;

  /// No description provided for @cotasTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Minhas Cotas'**
  String get cotasTitle;

  /// No description provided for @cotasEmpty.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nenhuma cota encontrada'**
  String get cotasEmpty;

  /// No description provided for @cotasTotal.
  ///
  /// In pt_BR, this message translates to:
  /// **'Total Pago'**
  String get cotasTotal;

  /// No description provided for @cotasOpen.
  ///
  /// In pt_BR, this message translates to:
  /// **'Em aberto'**
  String get cotasOpen;

  /// No description provided for @cotasPaid.
  ///
  /// In pt_BR, this message translates to:
  /// **'Pago'**
  String get cotasPaid;

  /// No description provided for @perfilTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Meu Perfil'**
  String get perfilTitle;

  /// No description provided for @perfilAdmin.
  ///
  /// In pt_BR, this message translates to:
  /// **'Administrador'**
  String get perfilAdmin;

  /// No description provided for @perfilSignOut.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sair'**
  String get perfilSignOut;

  /// No description provided for @perfilPersonalData.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dados pessoais'**
  String get perfilPersonalData;

  /// No description provided for @perfilChangePassword.
  ///
  /// In pt_BR, this message translates to:
  /// **'Alterar senha'**
  String get perfilChangePassword;

  /// No description provided for @perfilNotificationPrefs.
  ///
  /// In pt_BR, this message translates to:
  /// **'Preferências de notificação'**
  String get perfilNotificationPrefs;

  /// No description provided for @statusRascunho.
  ///
  /// In pt_BR, this message translates to:
  /// **'Rascunho'**
  String get statusRascunho;

  /// No description provided for @statusAberta.
  ///
  /// In pt_BR, this message translates to:
  /// **'Aberta'**
  String get statusAberta;

  /// No description provided for @statusEmCandidatura.
  ///
  /// In pt_BR, this message translates to:
  /// **'Em candidatura'**
  String get statusEmCandidatura;

  /// No description provided for @statusAtribuida.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atribuída'**
  String get statusAtribuida;

  /// No description provided for @statusEmExecucao.
  ///
  /// In pt_BR, this message translates to:
  /// **'Em execução'**
  String get statusEmExecucao;

  /// No description provided for @statusConcluida.
  ///
  /// In pt_BR, this message translates to:
  /// **'Concluída'**
  String get statusConcluida;

  /// No description provided for @statusCancelada.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelada'**
  String get statusCancelada;

  /// No description provided for @errorGeneric.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ocorreu um erro. Tente novamente.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In pt_BR, this message translates to:
  /// **'Verifique sua conexão com a internet.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In pt_BR, this message translates to:
  /// **'Item não encontrado.'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sessão expirada. Faça login novamente.'**
  String get errorUnauthorized;

  /// No description provided for @retryButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar novamente'**
  String get retryButton;

  /// No description provided for @cancelButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar'**
  String get saveButton;

  /// No description provided for @confirmButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar'**
  String get confirmButton;

  /// No description provided for @loadingLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carregando...'**
  String get loadingLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
