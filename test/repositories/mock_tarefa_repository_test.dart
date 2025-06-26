import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/repositories/mock_tarefa_repository.dart';

void main() {
  group('MockTarefaRepository', () {
    late MockTarefaRepository repository;
    late Tarefa tarefa1;
    late Tarefa tarefa2;
    
    setUp(() {
      repository = MockTarefaRepository();
      tarefa1 = Tarefa(id: '1', nome: 'Tarefa de teste 1', dataHora: DateTime.now());
      tarefa2 = Tarefa(id: '2', nome: 'Tarefa de teste 2', dataHora: DateTime.now());
    });
    
    test('deve inicializar com lista vazia', () async {
      final tarefas = await repository.carregarTarefas();
      expect(tarefas, isEmpty);
    });
    
    test('deve adicionar uma tarefa', () async {
      final resultado = await repository.adicionarTarefa(tarefa1);
      expect(resultado, true);
      
      final tarefas = await repository.carregarTarefas();
      expect(tarefas.length, 1);
      expect(tarefas[0].id, '1');
      expect(tarefas[0].nome, 'Tarefa de teste 1');
    });
    
    test('deve adicionar múltiplas tarefas', () async {
      await repository.adicionarTarefa(tarefa1);
      await repository.adicionarTarefa(tarefa2);
      
      final tarefas = await repository.carregarTarefas();
      expect(tarefas.length, 2);
      expect(tarefas[0].id, '1');
      expect(tarefas[1].id, '2');
    });
    
    test('deve atualizar uma tarefa existente', () async {
      await repository.adicionarTarefa(tarefa1);
      
      final tarefaAtualizada = Tarefa(
        id: '1',
        nome: 'Tarefa atualizada',
        concluida: true,
        dataHora: DateTime.now(),
      );
      
      final resultado = await repository.atualizarTarefa(tarefaAtualizada);
      expect(resultado, true);
      
      final tarefas = await repository.carregarTarefas();
      expect(tarefas.length, 1);
      expect(tarefas[0].id, '1');
      expect(tarefas[0].nome, 'Tarefa atualizada');
      expect(tarefas[0].concluida, true);
    });
    
    test('deve retornar false ao tentar atualizar tarefa inexistente', () async {
      final resultado = await repository.atualizarTarefa(tarefa1);
      expect(resultado, false);
    });
    
    test('deve remover uma tarefa existente', () async {
      await repository.adicionarTarefa(tarefa1);
      await repository.adicionarTarefa(tarefa2);
      
      final resultado = await repository.removerTarefa('1');
      expect(resultado, true);
      
      final tarefas = await repository.carregarTarefas();
      expect(tarefas.length, 1);
      expect(tarefas[0].id, '2');
    });
    
    test('deve retornar false ao tentar remover tarefa inexistente', () async {
      final resultado = await repository.removerTarefa('999');
      expect(resultado, false);
    });
    
    test('deve marcar tarefa como concluída', () async {
      await repository.adicionarTarefa(tarefa1);
      
      final resultado = await repository.marcarComoConcluida('1', true);
      expect(resultado, true);
      
      final tarefas = await repository.carregarTarefas();
      expect(tarefas[0].concluida, true);
    });
    
    test('deve marcar tarefa como não concluída', () async {
      final tarefaConcluida = Tarefa(
        id: '3',
        nome: 'Tarefa concluída',
        concluida: true,
        dataHora: DateTime.now(),
      );
      
      await repository.adicionarTarefa(tarefaConcluida);
      
      final resultado = await repository.marcarComoConcluida('3', false);
      expect(resultado, true);
      
      final tarefas = await repository.carregarTarefas();
      expect(tarefas[0].concluida, false);
    });
    
    test('deve retornar false ao tentar marcar tarefa inexistente como concluída', () async {
      final resultado = await repository.marcarComoConcluida('999', true);
      expect(resultado, false);
    });
    
    test('deve salvar e carregar múltiplas tarefas', () async {
      final tarefas = [tarefa1, tarefa2];
      
      final resultadoSalvar = await repository.salvarTarefas(tarefas);
      expect(resultadoSalvar, true);
      
      final tarefasCarregadas = await repository.carregarTarefas();
      expect(tarefasCarregadas.length, 2);
      expect(tarefasCarregadas[0].id, '1');
      expect(tarefasCarregadas[1].id, '2');
    });
    
    test('deve limpar tarefas existentes ao salvar nova lista', () async {
      await repository.adicionarTarefa(tarefa1);
      
      final novasTarefas = [tarefa2];
      await repository.salvarTarefas(novasTarefas);
      
      final tarefasCarregadas = await repository.carregarTarefas();
      expect(tarefasCarregadas.length, 1);
      expect(tarefasCarregadas[0].id, '2');
    });
  });
}
