import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'messaging_service.dart';

/// Serviço centralizador para inicialização e gerenciamento do Firebase
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  /// Singleton para acesso ao serviço
  factory FirebaseService() => _instance;
  
  FirebaseService._internal();
  
  /// Analytics do Firebase
  late final FirebaseAnalytics analytics;
  
  /// Observer para navegação com Analytics
  late final FirebaseAnalyticsObserver observer;
  
  /// Serviço de mensagens do Firebase
  late final MessagingService messagingService;
  
  bool _initialized = false;
  
  /// Verifica se o serviço foi inicializado
  bool get isInitialized => _initialized;
  
  /// Inicializa o Firebase e seus serviços
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Inicializar Firebase Core
    await Firebase.initializeApp();
    
    // Inicializar Analytics
    analytics = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: analytics);
    
    // Inicializar serviço de mensagens
    messagingService = MessagingService();
    await messagingService.initialize(
      onMessageOpenedApp: (message) {
        // Lógica para lidar com notificações quando o app é aberto
        debugPrint('Notificação aberta: ${message.notification?.title}');
        
        // Registrar evento no Analytics
        analytics.logEvent(
          name: 'notification_opened',
          parameters: {'title': message.notification?.title},
        );
      },
    );
    
    _initialized = true;
    debugPrint('FirebaseService: Firebase inicializado com sucesso');
  }
  
  /// Registra um evento no Analytics
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
  
  /// Configura o ID do usuário no Analytics
  Future<void> setUserId(String? userId) async {
    await analytics.setUserId(id: userId);
  }
}
