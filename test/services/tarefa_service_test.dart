import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/repositories/adaptive_repository.dart';
import 'package:projeto_flutter/services/tarefa_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Gere mocks com: flutter pub run build_runner build
@GenerateMocks([AdaptiveRepository])

// Criamos uma classe mock manualmente para não depender do arquivo gerado
class MockAdaptiveRepository extends Mock implements AdaptiveRepository {}
void main() {
  group('TarefaService', () {
    late MockAdaptiveRepository mockRepository;
    late TarefaService service;
    late Tarefa tarefa1;
    late Tarefa tarefa2;
    
    setUp(() {
      mockRepository = MockAdaptiveRepository();
      // Agora podemos injetar o mock diretamente no construtor
      service = TarefaService(mockRepository);
      
      tarefa1 = Tarefa(id: '1', nome: 'Tarefa de teste 1', dataHora: DateTime.now());
      tarefa2 = Tarefa(id: '2', nome: 'Tarefa de teste 2', dataHora: DateTime.now());
    });
    
    test('deve inicializar com lista vazia e carregar tarefas do repositório', () async {
      // Arrange
      when(mockRepository.carregarTarefas()).thenAnswer((_) async => [tarefa1, tarefa2]);
      
      // Act
      await service.carregarTarefas();
      
      // Assert
      expect(service.tarefas.length, 2);
      expect(service.tarefas[0].id, '1');
      expect(service.tarefas[1].id, '2');
      verify(mockRepository.carregarTarefas()).called(1);
    });
    
    test('deve adicionar tarefa e salvar no repositório', () async {
      // Arrange
      when(mockRepository.adicionarTarefa(argThat(isA<Tarefa>()))).thenAnswer((_) async => true);
      
      // Act
      await service.adicionarTarefa(tarefa1);
      
      // Assert
      expect(service.tarefas.length, 1);
      expect(service.tarefas[0].id, '1');
      verify(mockRepository.adicionarTarefa(tarefa1)).called(1);
    });
    
    test('deve atualizar tarefa existente', () async {
      // Arrange
      when(mockRepository.carregarTarefas()).thenAnswer((_) async => [tarefa1]);
      when(mockRepository.atualizarTarefa(argThat(isA<Tarefa>()))).thenAnswer((_) async => true);
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
      verify(mockRepository.atualizarTarefa(tarefaAtualizada)).called(1);
    });
    
    test('deve remover tarefa existente', () async {
      // Arrange
      when(mockRepository.carregarTarefas()).thenAnswer((_) async => [tarefa1, tarefa2]);
      when(mockRepository.removerTarefa(argThat(isA<String>()))).thenAnswer((_) async => true);
      await service.carregarTarefas();
      
      // Act
      await service.removerTarefa('1');
      
      // Assert
      expect(service.tarefas.length, 1);
      expect(service.tarefas[0].id, '2');
      verify(mockRepository.removerTarefa('1')).called(1);
    });
    
    test('deve marcar tarefa como concluída', () async {
      // Arrange
      when(mockRepository.carregarTarefas()).thenAnswer((_) async => [tarefa1]);
      when(mockRepository.marcarComoConcluida(argThat(isA<String>()), anyBool)).thenAnswer((_) async => true);
      await service.carregarTarefas();
      
      // Act
      await service.marcarComoConcluida('1', true);
      
      // Assert
      expect(service.tarefas[0].concluida, true);
      verify(mockRepository.marcarComoConcluida('1', true)).called(1);
    });
    
    test('deve lidar com erro ao carregar tarefas', () async {
      // Arrange
      when(mockRepository.carregarTarefas()).thenThrow(Exception('Erro simulado'));
      
      // Act
      await service.carregarTarefas();
      
      // Assert
      expect(service.tarefas, isEmpty);
      expect(service.erro, isNotNull);
      verify(mockRepository.carregarTarefas()).called(1);
    });
    
    test('deve lidar com erro ao adicionar tarefa', () async {
      // Arrange
      when(mockRepository.adicionarTarefa(argThat(isA<Tarefa>()))).thenThrow(Exception('Erro simulado'));
      
      // Act
      await service.adicionarTarefa(tarefa1);
      
      // Assert
      expect(service.erro, isNotNull);
      verify(mockRepository.adicionarTarefa(tarefa1)).called(1);
    });
    
    test('deve notificar listeners quando o estado mudar', () async {
      // Arrange
      bool notified = false;
      service.addListener(() {
        notified = true;
      });
      
      when(mockRepository.adicionarTarefa(argThat(isA<Tarefa>()))).thenAnswer((_) async => true);
      
      // Act
      await service.adicionarTarefa(tarefa1);
      
      // Assert
      expect(notified, true);
    });
  });
}
