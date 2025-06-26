import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/repositories/adaptive_repository.dart';
import 'package:projeto_flutter/services/tarefa_service.dart';

// Implementação simples de mock para o AdaptiveRepository
class MockAdaptiveRepository extends AdaptiveRepository {
  List<Tarefa> tarefasMock = [];
  bool falharOperacao = false;
  
  @override
  Future<List<Tarefa>> carregarTarefas() async {
    if (falharOperacao) {
      throw Exception('Erro simulado');
    }
    return tarefasMock;
  }
  
  @override
  Future<bool> adicionarTarefa(Tarefa tarefa) async {
    if (falharOperacao) {
      throw Exception('Erro simulado');
    }
    tarefasMock.add(tarefa);
    return true;
  }
  
  @override
  Future<bool> atualizarTarefa(Tarefa tarefa) async {
    if (falharOperacao) {
      throw Exception('Erro simulado');
    }
    final index = tarefasMock.indexWhere((t) => t.id == tarefa.id);
    if (index != -1) {
      tarefasMock[index] = tarefa;
      return true;
    }
    return false;
  }
  
  @override
  Future<bool> removerTarefa(String id) async {
    if (falharOperacao) {
      throw Exception('Erro simulado');
    }
    final tamanhoOriginal = tarefasMock.length;
    tarefasMock.removeWhere((t) => t.id == id);
    return tarefasMock.length < tamanhoOriginal;
  }
  
  @override
  Future<bool> marcarComoConcluida(String id, bool concluida) async {
    if (falharOperacao) {
      throw Exception('Erro simulado');
    }
    final index = tarefasMock.indexWhere((t) => t.id == id);
    if (index != -1) {
      tarefasMock[index].concluida = concluida;
      return true;
    }
    return false;
  }
}

void main() {
  group('TarefaService', () {
    late MockAdaptiveRepository mockRepository;
    late TarefaService service;
    late Tarefa tarefa1;
    late Tarefa tarefa2;
    
    setUp(() {
      mockRepository = MockAdaptiveRepository();
      service = TarefaService(mockRepository);
      
      tarefa1 = Tarefa(id: '1', nome: 'Tarefa de teste 1', dataHora: DateTime.now());
      tarefa2 = Tarefa(id: '2', nome: 'Tarefa de teste 2', dataHora: DateTime.now());
      
      // Limpar o estado entre os testes
      mockRepository.tarefasMock = [];
      mockRepository.falharOperacao = false;
    });
    
    test('deve inicializar com lista vazia e carregar tarefas do repositório', () async {
      // Arrange
      mockRepository.tarefasMock = [tarefa1, tarefa2];
      
      // Act
      await service.carregarTarefas();
      
      // Assert
      expect(service.tarefas.length, 2);
      expect(service.tarefas[0].id, '1');
      expect(service.tarefas[1].id, '2');
    });
    
    test('deve adicionar tarefa e salvar no repositório', () async {
      // Act
      await service.adicionarTarefa(tarefa1);
      
      // Assert
      expect(service.tarefas.length, 1);
      expect(service.tarefas[0].id, '1');
      expect(mockRepository.tarefasMock.length, 1);
    });
    
    test('deve atualizar tarefa existente', () async {
      // Arrange
      mockRepository.tarefasMock = [tarefa1];
      await service.carregarTarefas();
      
      final tarefaAtualizada = Tarefa(
        id: '1',
        nome: 'Tarefa atualizada',
        concluida: true,
        dataHora: DateTime.now(),
      );
      
      // Act
      await service.atualizarTarefa(tarefaAtualizada);
      
      // Assert
      expect(service.tarefas.length, 1);
      expect(service.tarefas[0].id, '1');
      expect(service.tarefas[0].nome, 'Tarefa atualizada');
      expect(service.tarefas[0].concluida, true);
    });
    
    test('deve remover tarefa existente', () async {
      // Arrange
      mockRepository.tarefasMock = [tarefa1, tarefa2];
      await service.carregarTarefas();
      
      // Act
      await service.removerTarefa('1');
      
      // Assert
      expect(service.tarefas.length, 1);
      expect(service.tarefas[0].id, '2');
      expect(mockRepository.tarefasMock.length, 1);
    });
    
    test('deve marcar tarefa como concluída', () async {
      // Arrange
      mockRepository.tarefasMock = [tarefa1];
      await service.carregarTarefas();
      
      // Act
      await service.marcarComoConcluida('1', true);
      
      // Assert
      expect(service.tarefas[0].concluida, true);
      expect(mockRepository.tarefasMock[0].concluida, true);
    });
    
    test('deve lidar com erro ao carregar tarefas', () async {
      // Arrange
      mockRepository.falharOperacao = true;
      
      // Act
      await service.carregarTarefas();
      
      // Assert
      expect(service.tarefas, isEmpty);
      expect(service.erro, isNotNull);
    });
    
    test('deve lidar com erro ao adicionar tarefa', () async {
      // Arrange
      mockRepository.falharOperacao = true;
      
      // Act
      await service.adicionarTarefa(tarefa1);
      
      // Assert
      expect(service.erro, isNotNull);
    });
    
    test('deve notificar listeners quando o estado mudar', () async {
      // Arrange
      bool notified = false;
      service.addListener(() {
        notified = true;
      });
      
      // Act
      await service.adicionarTarefa(tarefa1);
      
      // Assert
      expect(notified, true);
    });
  });
}
