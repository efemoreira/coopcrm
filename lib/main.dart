// Ponto de entrada do CoopCRM.
// Responsável por:
//  - Inicializar Supabase (BaaS), Firebase e injeção de dependências.
//  - Configurar push notifications (FCM) e canal Android de alta prioridade.
//  - Persistir o token FCM na tabela `cooperados` para envio server-side.
//  - Tratar deep links de notificação (app em background e app fechado).
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/env/env.dart';
import 'core/router/app_router.dart';

final _localNotifications = FlutterLocalNotificationsPlugin();

/// Handler isolado para mensagens FCM recebidas com app em background/fechado.
/// Precisa do pragma para não ser removido pelo tree-shaker.
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Inicializa o plugin de notificações locais e cria o canal Android
/// `coopcrm_high` com prioridade alta para mensagens em foreground.
Future<void> _setupLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _localNotifications.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'coopcrm_high',
          'CoopCRM — Notificações',
          importance: Importance.high,
        ),
      );
}

/// Solicita permissão de push, obtém o token FCM inicial e configura
/// o listener de foreground para exibir notificações locais.
Future<void> _setupFCM() async {
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken();
  if (token != null) await _saveFcmToken(token);
  messaging.onTokenRefresh.listen(_saveFcmToken);

  // Foreground messages → local notification
  FirebaseMessaging.onMessage.listen((msg) {
    final n = msg.notification;
    if (n != null) {
      _localNotifications.show(
        id: n.hashCode,
        title: n.title,
        body: n.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'coopcrm_high',
            'CoopCRM — Notificações',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });
}

/// Configura o listener de deep link para quando o app está em background
/// e o usuário toca na notificação push de nova oportunidade.
void _setupDeepLinks() {
  // App in background → tapped notification
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    final oportunidadeId = msg.data['oportunidade_id'] as String?;
    if (oportunidadeId != null && oportunidadeId.isNotEmpty) {
      try {
        getIt<AppRouter>().router.go('/feed/$oportunidadeId');
      } catch (_) {}
    }
  });
}

/// Persiste ou atualiza o token FCM do usuário autenticado na tabela
/// `cooperados`, vinculado pelo `user_id` do Supabase Auth.
Future<void> _saveFcmToken(String token) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    // Salva token na tabela cooperados (vinculado ao user_id do Supabase Auth)
    await Supabase.instance.client
        .from('cooperados')
        .update({'fcm_token': token})
        .eq('user_id', user.id);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await Firebase.initializeApp();
  await _setupLocalNotifications();
  await _setupFCM();

  configureDependencies();

  // Deep link: app terminated → save pending route before runApp
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final oportunidadeId = initialMessage.data['oportunidade_id'] as String?;
    if (oportunidadeId != null && oportunidadeId.isNotEmpty) {
      getIt<AppRouter>().pendingDeepLink = '/feed/$oportunidadeId';
    }
  }

  // Deep link: app backgrounded → live listener
  _setupDeepLinks();

  runApp(const App());
}
