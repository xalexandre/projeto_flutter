import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tarefa.dart';
import '../repositories/adaptive_repository.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';

/// Serviço de gerenciamento de tarefas que implementa o padrão ChangeNotifier
/// 
/// Responsável pela lógica de negócios relacionada às tarefas e
/// pela comunicação entre a UI e a camada de persistência de dados.
/// Utiliza o AdaptiveRepository para salvar e recuperar dados localmente,
/// e o FirestoreService para sincronizar dados na nuvem quando o usuário está autenticado.
class TarefaService extends ChangeNotifier {
  final List<Tarefa> _tarefas = [];
  final AdaptiveRepository _repository;
  final NotificationService _notificationService = NotificationService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Construtor que inicializa o serviço com o repositório padrão ou um personalizado
  TarefaService([AdaptiveRepository? repository]) : 
      _repository = repository ?? AdaptiveRepository() {
    _initializeServices();
    // Ouvir mudanças no estado de autenticação
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _sincronizarComFirestore();
      } else {
        _usandoFirestore = false;
        carregarTarefas(); // Recarregar tarefas locais
      }
    });
  }
  bool _isLoading = false;
  String? _erro;
  bool _usandoFirestore = false;
  
  /// Verifica se o usuário está autenticado
  bool get isAutenticado => _auth.currentUser != null;
  
  /// Inicializa os serviços necessários
  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
    await carregarTarefas();
    
    // Verifica se o usuário está autenticado para usar o Firestore
    if (_auth.currentUser != null) {
      await _sincronizarComFirestore();
    }
  }
  
  /// Sincroniza as tarefas com o Firestore quando o usuário está autenticado
  Future<void> _sincronizarComFirestore() async {
    if (_auth.currentUser == null) return;
    
    _isLoading = true;
    _erro = null;
    notifyListeners();
    
    try {
      print('TarefaService: Sincronizando tarefas com Firestore...');
      
      // Carrega tarefas do Firestore
      final tarefasFirestore = await _firestoreService.carregarTarefas();
      
      // Se o usuário não tinha tarefas no Firestore, envia as tarefas locais
      if (tarefasFirestore.isEmpty && _tarefas.isNotEmpty) {
        for (var tarefa in _tarefas) {
          await _firestoreService.adicionarTarefa(tarefa);
        }
      } else {
        // Substitui as tarefas locais pelas do Firestore
        _tarefas.clear();
        _tarefas.addAll(tarefasFirestore);
        
        // Atualiza o repositório local
        for (var tarefa in _tarefas) {
          await _repository.adicionarTarefa(tarefa);
        }
      }
      
      _usandoFirestore = true;
      print('TarefaService: Sincronização com Firestore concluída');
      
    } catch (e) {
      print('TarefaService: Erro ao sincronizar com Firestore: $e');
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Lista de tarefas atual
  List<Tarefa> get tarefas => [..._tarefas];
  
  /// Indica se está carregando dados
  bool get isLoading => _isLoading;
  
  /// Mensagem de erro, se houver
  String? get erro => _erro;
  
  /// Carrega as tarefas do repositório local
  Future<void> carregarTarefas() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    
    try {
      final tarefas = await _repository.carregarTarefas();
      _tarefas.clear();
      _tarefas.addAll(tarefas);
    } catch (e) {
      _erro = 'Erro ao carregar tarefas: $e';
      print('TarefaService: $_erro');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Adiciona uma nova tarefa
  Future<void> adicionarTarefa(Tarefa tarefa) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    
    try {
      // Adicionar localmente
      await _repository.adicionarTarefa(tarefa);
      _tarefas.add(tarefa);
      
      // Sincronizar com Firestore se estiver autenticado
      if (_usandoFirestore) {
        await _firestoreService.adicionarTarefa(tarefa);
      }
      
      // Agendar notificação se tiver data
      if (tarefa.dataHora != null) {
        await _notificationService.agendarNotificacao(
          id: tarefa.id.hashCode,
          titulo: 'Lembrete de Tarefa',
          corpo: tarefa.nome,
          dataHora: tarefa.dataHora!,
        );
      }
    } catch (e) {
      _erro = 'Erro ao adicionar tarefa: $e';
      print('TarefaService: $_erro');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Atualiza uma tarefa existente
  Future<void> atualizarTarefa(Tarefa tarefa) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    
    try {
      // Atualizar localmente
      await _repository.atualizarTarefa(tarefa);
      
      final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
      if (index >= 0) {
        _tarefas[index] = tarefa;
      }
      
      // Sincronizar com Firestore se estiver autenticado
      if (_usandoFirestore) {
        await _firestoreService.atualizarTarefa(tarefa);
      }
      
      // Atualizar notificação se tiver data
      if (tarefa.dataHora != null) {
        await _notificationService.cancelarNotificacao(tarefa.id.hashCode);
        await _notificationService.agendarNotificacao(
          id: tarefa.id.hashCode,
          titulo: 'Lembrete de Tarefa',
          corpo: tarefa.nome,
          dataHora: tarefa.dataHora!,
        );
      } else {
        // Cancelar notificação se não tiver mais data
        await _notificationService.cancelarNotificacao(tarefa.id.hashCode);
      }
    } catch (e) {
      _erro = 'Erro ao atualizar tarefa: $e';
      print('TarefaService: $_erro');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Remove uma tarefa pelo ID
  Future<void> removerTarefa(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    
    try {
      // Remover localmente
      await _repository.removerTarefa(id);
      
      _tarefas.removeWhere((tarefa) => tarefa.id == id);
      
      // Sincronizar com Firestore se estiver autenticado
      if (_usandoFirestore) {
        await _firestoreService.removerTarefa(id);
      }
      
      // Cancelar notificação associada
      await _notificationService.cancelarNotificacao(id.hashCode);
    } catch (e) {
      _erro = 'Erro ao remover tarefa: $e';
      print('TarefaService: $_erro');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Marca uma tarefa como concluída ou não concluída
  Future<void> marcarComoConcluida(String id, bool concluida) async {
    final index = _tarefas.indexWhere((tarefa) => tarefa.id == id);
    if (index == -1) return;
    
    final tarefa = _tarefas[index].copyWith(concluida: concluida);
    await atualizarTarefa(tarefa);
  }
}
