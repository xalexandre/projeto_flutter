import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Temporarily removed

/// Serviço para gerenciamento de notificações push com Firebase Cloud Messaging
/// Versão temporária enquanto resolvemos o problema de compilação com flutter_local_notifications
class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // Removido temporariamente: final FlutterLocalNotificationsPlugin _localNotifications
  
  /// Inicializa o serviço de mensagens
  Future<void> initialize({
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    // Solicitar permissões
    await requestPermissions();
    
    // Configuração de notificações locais removida temporariamente
    debugPrint('MessagingService: Serviço de mensagens inicializado (versão stub)');
    
    // Configurar handlers para mensagens
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    if (onMessageOpenedApp != null) {
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    }
    
    // Verificar se o app foi aberto de uma notificação enquanto estava fechado
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && onMessageOpenedApp != null) {
      onMessageOpenedApp(initialMessage);
    }
  }
  
  /// Solicita permissões para notificações
  Future<bool> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                   settings.authorizationStatus == AuthorizationStatus.provisional;
    
    debugPrint('MessagingService: Permissões ${granted ? "concedidas" : "negadas"}');
    return granted;
  }
  
  /// Obtém o token FCM do dispositivo
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
  
  /// Inscreve o dispositivo em um tópico
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('MessagingService: Inscrito no tópico $topic');
  }
  
  /// Cancela a inscrição do dispositivo em um tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('MessagingService: Cancelada inscrição no tópico $topic');
  }
  
  /// Lida com mensagens recebidas enquanto o app está em primeiro plano
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('MessagingService: Mensagem recebida em primeiro plano: ${message.notification?.title}');
    
    if (message.notification != null) {
      // Substituído por um log em vez de mostrar notificação local
      debugPrint('STUB: Notificação recebida: ${message.notification!.title} - ${message.notification!.body}');
    }
  }
  
  /// Exibe uma notificação local (stub)
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('STUB: _showLocalNotification: $title - $body');
  }
  
  /// Exibe uma notificação local simples (stub)
  Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('STUB: showSimpleNotification: $title - $body');
  }
}
