import 'dart:convert';
import 'dart:html' as html;
import '../models/tarefa.dart';

/// Repositório específico para web que usa localStorage diretamente
/// 
/// Esta implementação é usada especificamente para ambientes web,
/// garantindo que os dados persistam entre sessões usando localStorage.
class WebLocalStorageRepository {
  static const String _chave = 'tarefas_web';
  
  /// Carrega todas as tarefas do localStorage
  List<Tarefa> carregarTarefas() {
    try {
      print('WebLocalStorageRepository: Verificando se localStorage está disponível');
      try {
        // Teste para verificar se localStorage está disponível
        html.window.localStorage['test'] = 'test';
        print('WebLocalStorageRepository: localStorage está disponível');
      } catch (e) {
        print('WebLocalStorageRepository: localStorage NÃO está disponível: $e');
      }
      
      print('WebLocalStorageRepository: Carregando tarefas do localStorage');
      final tarefasString = html.window.localStorage[_chave];
      print('WebLocalStorageRepository: Valor bruto recuperado: $tarefasString');
      
      if (tarefasString == null || tarefasString.isEmpty) {
        print('WebLocalStorageRepository: Nenhuma tarefa encontrada no localStorage');
        return [];
      }
      
      print('WebLocalStorageRepository: Tarefas encontradas no localStorage');
      final List<dynamic> tarefasJson = jsonDecode(tarefasString);
      final tarefas = tarefasJson
          .map((json) => Tarefa.fromJson(json))
          .toList();
          
      print('WebLocalStorageRepository: ${tarefas.length} tarefas carregadas');
      return tarefas;
    } catch (e) {
      print('WebLocalStorageRepository: Erro ao carregar tarefas: $e');
      return [];
    }
  }
  
  /// Salva todas as tarefas no localStorage
  bool salvarTarefas(List<Tarefa> tarefas) {
    try {
      print('WebLocalStorageRepository: Salvando ${tarefas.length} tarefas');
      final tarefasJson = tarefas.map((t) => t.toJson()).toList();
      final tarefasString = jsonEncode(tarefasJson);
      print('WebLocalStorageRepository: String a ser salva: $tarefasString');
      
      html.window.localStorage[_chave] = tarefasString;
      
      // Verificar se foi realmente salvo
      final valorSalvo = html.window.localStorage[_chave];
      print('WebLocalStorageRepository: Valor confirmado no localStorage: $valorSalvo');
      print('WebLocalStorageRepository: Tarefas salvas com sucesso');
      return true;
    } catch (e) {
      print('WebLocalStorageRepository: Erro ao salvar tarefas: $e');
      return false;
    }
  }
  
  /// Adiciona uma tarefa ao localStorage
  bool adicionarTarefa(Tarefa tarefa) {
    final tarefas = carregarTarefas();
    tarefas.add(tarefa);
    return salvarTarefas(tarefas);
  }
  
  /// Atualiza uma tarefa existente no localStorage
  bool atualizarTarefa(Tarefa tarefa) {
    final tarefas = carregarTarefas();
    final index = tarefas.indexWhere((t) => t.id == tarefa.id);
    
    if (index != -1) {
      tarefas[index] = tarefa;
      return salvarTarefas(tarefas);
    }
    
    return false;
  }
  
  /// Remove uma tarefa do localStorage
  bool removerTarefa(String id) {
    final tarefas = carregarTarefas();
    final tamanhoOriginal = tarefas.length;
    
    tarefas.removeWhere((t) => t.id == id);
    
    if (tarefas.length < tamanhoOriginal) {
      return salvarTarefas(tarefas);
    }
    
    return false;
  }
  
  /// Marca uma tarefa como concluída ou não concluída no localStorage
  bool marcarComoConcluida(String id, bool concluida) {
    final tarefas = carregarTarefas();
    final index = tarefas.indexWhere((t) => t.id == id);
    
    if (index != -1) {
      tarefas[index].concluida = concluida;
      return salvarTarefas(tarefas);
    }
    
    return false;
  }
}
