import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/tarefa.dart';
import 'tarefa_repository.dart';
import 'mock_tarefa_repository.dart';

/// Repositório adaptativo que escolhe a implementação adequada com base na plataforma
/// 
/// Usa MockTarefaRepository para web e TarefaRepository para plataformas móveis.
class AdaptiveRepository {
  final TarefaRepository _mobileRepository = TarefaRepository();
  MockTarefaRepository? _webRepository;
  
  /// Verifica se a plataforma atual é web
  bool get _isWeb => kIsWeb;
  
  /// Inicializa o repositório web sob demanda
  MockTarefaRepository _getWebRepository() {
    _webRepository ??= MockTarefaRepository();
    return _webRepository!;
  }
  
  /// Carrega tarefas da fonte apropriada com base na plataforma
  Future<List<Tarefa>> carregarTarefas() async {
    if (_isWeb) {
      print('AdaptiveRepository: Usando MockTarefaRepository para carregar tarefas');
      return _getWebRepository().carregarTarefas();
    } else {
      print('AdaptiveRepository: Usando TarefaRepository para carregar tarefas');
      return await _mobileRepository.carregarTarefas();
    }
  }
  
  /// Salva tarefas na fonte apropriada com base na plataforma
  Future<bool> salvarTarefas(List<Tarefa> tarefas) async {
    if (_isWeb) {
      print('AdaptiveRepository: Usando MockTarefaRepository para salvar tarefas');
      return _getWebRepository().salvarTarefas(tarefas);
    } else {
      print('AdaptiveRepository: Usando TarefaRepository para salvar tarefas');
      return await _mobileRepository.salvarTarefas(tarefas);
    }
  }
  
  /// Adiciona uma tarefa na fonte apropriada com base na plataforma
  Future<bool> adicionarTarefa(Tarefa tarefa) async {
    if (_isWeb) {
      print('AdaptiveRepository: Usando MockTarefaRepository para adicionar tarefa');
      return _getWebRepository().adicionarTarefa(tarefa);
    } else {
      print('AdaptiveRepository: Usando TarefaRepository para adicionar tarefa');
      return await _mobileRepository.adicionarTarefa(tarefa);
    }
  }
  
  /// Atualiza uma tarefa na fonte apropriada com base na plataforma
  Future<bool> atualizarTarefa(Tarefa tarefa) async {
    if (_isWeb) {
      print('AdaptiveRepository: Usando MockTarefaRepository para atualizar tarefa');
      return _getWebRepository().atualizarTarefa(tarefa);
    } else {
      print('AdaptiveRepository: Usando TarefaRepository para atualizar tarefa');
      return await _mobileRepository.atualizarTarefa(tarefa);
    }
  }
  
  /// Remove uma tarefa da fonte apropriada com base na plataforma
  Future<bool> removerTarefa(String id) async {
    if (_isWeb) {
      print('AdaptiveRepository: Usando MockTarefaRepository para remover tarefa');
      return _getWebRepository().removerTarefa(id);
    } else {
      print('AdaptiveRepository: Usando TarefaRepository para remover tarefa');
      return await _mobileRepository.removerTarefa(id);
    }
  }
  
  /// Marca uma tarefa como concluída ou não concluída na fonte apropriada com base na plataforma
  Future<bool> marcarComoConcluida(String id, bool concluida) async {
    if (_isWeb) {
      print('AdaptiveRepository: Usando MockTarefaRepository para marcar tarefa como concluída');
      return _getWebRepository().marcarComoConcluida(id, concluida);
    } else {
      print('AdaptiveRepository: Usando TarefaRepository para marcar tarefa como concluída');
      return await _mobileRepository.marcarComoConcluida(id, concluida);
    }
  }
}
