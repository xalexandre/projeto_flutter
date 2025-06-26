import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarefa.dart';

/// Repositório responsável por gerenciar a persistência das tarefas
/// 
/// Implementa operações CRUD para tarefas e as armazena
/// usando SharedPreferences, permitindo que os dados persistam
/// entre sessões do aplicativo.
class TarefaRepository {
  static const String _chave = 'tarefas';
  
  /// Carrega todas as tarefas do armazenamento local
  Future<List<Tarefa>> carregarTarefas() async {
    try {
      print('TarefaRepository: Obtendo instância do SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      print('TarefaRepository: Recuperando lista de tarefas com a chave $_chave');
      final tarefasJson = prefs.getStringList(_chave) ?? [];
      print('TarefaRepository: ${tarefasJson.length} tarefas recuperadas do armazenamento');
      
      if (tarefasJson.isNotEmpty) {
        print('TarefaRepository: Exemplo de tarefa salva: ${tarefasJson.first}');
      }
      
      return tarefasJson
          .map((tarefaString) => Tarefa.fromJson(jsonDecode(tarefaString)))
          .toList();
    } catch (e) {
      print('TarefaRepository: Erro ao carregar tarefas: $e');
      // Em caso de erro, retorna uma lista vazia
      return [];
    }
  }
  
  /// Salva a lista completa de tarefas no armazenamento local
  Future<bool> salvarTarefas(List<Tarefa> tarefas) async {
    try {
      print('TarefaRepository: Salvando ${tarefas.length} tarefas');
      final prefs = await SharedPreferences.getInstance();
      final tarefasJson = tarefas
          .map((tarefa) => jsonEncode(tarefa.toJson()))
          .toList();
      
      print('TarefaRepository: Salvando tarefas com a chave $_chave');
      final resultado = await prefs.setStringList(_chave, tarefasJson);
      print('TarefaRepository: Tarefas salvas com sucesso: $resultado');
      return resultado;
    } catch (e) {
      print('TarefaRepository: Erro ao salvar tarefas: $e');
      return false;
    }
  }
  
  /// Adiciona uma nova tarefa ao armazenamento
  Future<bool> adicionarTarefa(Tarefa tarefa) async {
    final tarefas = await carregarTarefas();
    tarefas.add(tarefa);
    return await salvarTarefas(tarefas);
  }
  
  /// Atualiza uma tarefa existente no armazenamento
  Future<bool> atualizarTarefa(Tarefa tarefa) async {
    final tarefas = await carregarTarefas();
    final index = tarefas.indexWhere((t) => t.id == tarefa.id);
    
    if (index != -1) {
      tarefas[index] = tarefa;
      return await salvarTarefas(tarefas);
    }
    
    return false;
  }
  
  /// Remove uma tarefa do armazenamento
  Future<bool> removerTarefa(String id) async {
    final tarefas = await carregarTarefas();
    final tamanhoOriginal = tarefas.length;
    
    tarefas.removeWhere((tarefa) => tarefa.id == id);
    
    if (tarefas.length < tamanhoOriginal) {
      return await salvarTarefas(tarefas);
    }
    
    return false;
  }
  
  /// Marca uma tarefa como concluída ou não concluída
  Future<bool> marcarComoConcluida(String id, bool concluida) async {
    final tarefas = await carregarTarefas();
    final index = tarefas.indexWhere((t) => t.id == id);
    
    if (index != -1) {
      tarefas[index].concluida = concluida;
      return await salvarTarefas(tarefas);
    }
    
    return false;
  }
}
