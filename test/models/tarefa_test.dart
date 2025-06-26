import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/models/tarefa.dart';

void main() {
  group('Tarefa', () {
    test('deve criar uma tarefa com valores padrão', () {
      final tarefa = Tarefa(
        id: '1',
        nome: 'Teste',
        dataHora: DateTime.now(),
      );
      
      expect(tarefa.id, '1');
      expect(tarefa.nome, 'Teste');
      expect(tarefa.concluida, false); // valor padrão
      expect(tarefa.dataHora, isNotNull);
      expect(tarefa.localizacao, isNull);
    });
    
    test('deve criar uma tarefa com todos os campos', () {
      final dataHora = DateTime(2025, 6, 25, 12, 0);
      final tarefa = Tarefa(
        id: '2',
        nome: 'Teste completo',
        concluida: true,
        dataHora: dataHora,
        localizacao: null,
      );
      
      expect(tarefa.id, '2');
      expect(tarefa.nome, 'Teste completo');
      expect(tarefa.concluida, true);
      expect(tarefa.dataHora, dataHora);
      expect(tarefa.localizacao, isNull);
    });
    
    test('deve converter para JSON corretamente', () {
      final dataHora = DateTime(2025, 6, 25, 12, 0);
      final tarefa = Tarefa(
        id: '3',
        nome: 'Teste JSON',
        concluida: true,
        dataHora: dataHora,
        localizacao: null,
      );
      
      final json = tarefa.toJson();
      
      expect(json['id'], '3');
      expect(json['nome'], 'Teste JSON');
      expect(json['concluida'], true);
      expect(json['dataHora'], dataHora.toIso8601String());
      expect(json['localizacao'], isNull);
    });
    
    test('deve criar a partir de JSON corretamente', () {
      final dataHora = DateTime(2025, 6, 25, 12, 0);
      final json = {
        'id': '4',
        'nome': 'Teste from JSON',
        'concluida': true,
        'dataHora': dataHora.toIso8601String(),
        'localizacao': null,
      };
      
      final tarefa = Tarefa.fromJson(json);
      
      expect(tarefa.id, '4');
      expect(tarefa.nome, 'Teste from JSON');
      expect(tarefa.concluida, true);
      expect(tarefa.dataHora.year, dataHora.year);
      expect(tarefa.dataHora.month, dataHora.month);
      expect(tarefa.dataHora.day, dataHora.day);
      expect(tarefa.dataHora.hour, dataHora.hour);
      expect(tarefa.dataHora.minute, dataHora.minute);
      expect(tarefa.localizacao, isNull);
    });
  });
}
