import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/tarefa.dart';

/// Serviço temporário de notificações (stub)
/// Implementação temporária enquanto resolvemos o problema de compilação com flutter_local_notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;
  final Map<String, Tarefa> _monitoredTasks = {};
  Timer? _locationCheckTimer;
  
  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) return;
    debugPrint('Inicializando serviço de notificações (stub temporário)');
    _initialized = true;
    _startLocationChecking();
  }
  
  /// Solicita as permissões necessárias
  Future<bool> requestPermissions() async {
    final notificationStatus = await Permission.notification.request();
    final locationStatus = await Permission.location.request();
    return notificationStatus.isGranted && locationStatus.isGranted;
  }

  /// Adiciona uma tarefa para ser monitorada por proximidade
  void addTaskForLocationMonitoring(Tarefa tarefa) {
    if (tarefa.localizacao == null) return;
    _monitoredTasks[tarefa.id] = tarefa;
  }

  /// Remove uma tarefa do monitoramento por proximidade
  void removeTaskFromLocationMonitoring(String tarefaId) {
    _monitoredTasks.remove(tarefaId);
  }

  /// Inicia a verificação periódica de localização
  void _startLocationChecking() {
    _locationCheckTimer?.cancel();
    _locationCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkNearbyTasks(),
    );
    _checkNearbyTasks();
  }

  /// Verifica tarefas próximas da localização atual
  Future<void> _checkNearbyTasks() async {
    if (_monitoredTasks.isEmpty) return;
    
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      for (final tarefa in _monitoredTasks.values) {
        if (tarefa.localizacao == null) continue;
        
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          tarefa.localizacao!.latitude,
          tarefa.localizacao!.longitude,
        );
        
        if (distance < 500) {
          debugPrint('STUB: Tarefa próxima: ${tarefa.nome}');
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar tarefas próximas: $e');
    }
  }

  /// Mostra uma notificação simples (stub)
  Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('STUB: Notificação simples: $title - $body');
  }
  
  /// Agenda uma notificação (stub)
  Future<void> agendarNotificacao({
    required int id,
    required String titulo,
    required String corpo,
    required DateTime dataHora,
    String? payload,
  }) async {
    debugPrint('STUB: Notificação agendada: $titulo para ${dataHora.toString()}');
  }
  
  /// Cancela uma notificação agendada pelo ID (stub)
  Future<void> cancelarNotificacao(int id) async {
    debugPrint('STUB: Cancelando notificação com ID: $id');
  }
  
  /// Cancela todas as notificações agendadas (stub)
  Future<void> cancelarTodasNotificacoes() async {
    debugPrint('STUB: Cancelando todas as notificações');
  }
}
