import '../models/tarefa.dart';

/// Repositório de tarefas simulado para demonstração
/// 
/// Esta implementação simula persistência em memória com logs detalhados
/// para demonstrar como funcionaria a persistência em um ambiente real.
class MockTarefaRepository {
  // Armazenamento em memória para simular persistência
  // Não usamos static para evitar compartilhar estado entre instâncias
  final List<Tarefa> _tarefas = [];
  
  /// Carrega todas as tarefas do armazenamento simulado
  Future<List<Tarefa>> carregarTarefas() async {
    print('MockTarefaRepository: Carregando ${_tarefas.length} tarefas do armazenamento simulado');
    
    // Simula um atraso para imitar operação de I/O
    await Future.delayed(const Duration(milliseconds: 300));
    
    return List.from(_tarefas);
  }
  
  /// Salva todas as tarefas no armazenamento simulado
  Future<bool> salvarTarefas(List<Tarefa> tarefas) async {
    print('MockTarefaRepository: Salvando ${tarefas.length} tarefas no armazenamento simulado');
    
    // Simula um atraso para imitar operação de I/O
    await Future.delayed(const Duration(milliseconds: 300));
    
    _tarefas.clear();
    _tarefas.addAll(tarefas);
    
    print('MockTarefaRepository: Armazenamento atualizado com ${_tarefas.length} tarefas');
    return true;
  }
  
  /// Adiciona uma tarefa ao armazenamento simulado
  Future<bool> adicionarTarefa(Tarefa tarefa) async {
    print('MockTarefaRepository: Adicionando tarefa ${tarefa.id} ao armazenamento simulado');
    
    // Simula um atraso para imitar operação de I/O
    await Future.delayed(const Duration(milliseconds: 300));
    
    _tarefas.add(tarefa);
    
    print('MockTarefaRepository: Tarefa adicionada com sucesso. Total: ${_tarefas.length}');
    return true;
  }
  
  /// Atualiza uma tarefa existente no armazenamento simulado
  Future<bool> atualizarTarefa(Tarefa tarefa) async {
    print('MockTarefaRepository: Atualizando tarefa ${tarefa.id}');
    
    // Simula um atraso para imitar operação de I/O
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
    
    if (index != -1) {
      _tarefas[index] = tarefa;
      print('MockTarefaRepository: Tarefa atualizada com sucesso');
      return true;
    }
    
    print('MockTarefaRepository: Tarefa não encontrada para atualização');
    return false;
  }
  
  /// Remove uma tarefa do armazenamento simulado
  Future<bool> removerTarefa(String id) async {
    print('MockTarefaRepository: Removendo tarefa $id');
    
    // Simula um atraso para imitar operação de I/O
    await Future.delayed(const Duration(milliseconds: 300));
    
    final tamanhoOriginal = _tarefas.length;
    _tarefas.removeWhere((t) => t.id == id);
    
    final removida = _tarefas.length < tamanhoOriginal;
    if (removida) {
      print('MockTarefaRepository: Tarefa removida com sucesso. Total restante: ${_tarefas.length}');
    } else {
      print('MockTarefaRepository: Tarefa não encontrada para remoção');
    }
    
    return removida;
  }
  
  /// Marca uma tarefa como concluída ou não concluída
  Future<bool> marcarComoConcluida(String id, bool concluida) async {
    print('MockTarefaRepository: Marcando tarefa $id como ${concluida ? "concluída" : "não concluída"}');
    
    // Simula um atraso para imitar operação de I/O
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _tarefas.indexWhere((t) => t.id == id);
    
    if (index != -1) {
      _tarefas[index].concluida = concluida;
      print('MockTarefaRepository: Estado da tarefa atualizado com sucesso');
      return true;
    }
    
    print('MockTarefaRepository: Tarefa não encontrada para atualização de estado');
    return false;
  }
}
