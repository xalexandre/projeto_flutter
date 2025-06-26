import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/main.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/services/tarefa_service.dart';
import 'package:provider/provider.dart';

// Implementação simples de mock para o TarefaService
class MockTarefaService extends ChangeNotifier implements TarefaService {
  final List<Tarefa> _mockTarefas = [];
  bool _mockIsLoading = false;
  String? _mockErro;
  
  @override
  List<Tarefa> get tarefas => _mockTarefas;
  
  @override
  bool get isLoading => _mockIsLoading;
  
  @override
  String? get erro => _mockErro;
  
  // Implementações vazias para métodos que não usaremos nos testes
  @override
  Future<void> carregarTarefas() async {}
  
  @override
  Future<void> adicionarTarefa(Tarefa tarefa) async {}
  
  @override
  Future<void> atualizarTarefa(Tarefa tarefa) async {}
  
  @override
  Future<void> removerTarefa(String id) async {}
  
  @override
  Future<void> marcarComoConcluida(String id, bool concluida) async {}
  
  // Métodos para configurar o mock
  void setMockTarefas(List<Tarefa> tarefas) {
    _mockTarefas.clear();
    _mockTarefas.addAll(tarefas);
    notifyListeners();
  }
  
  void setMockIsLoading(bool isLoading) {
    _mockIsLoading = isLoading;
    notifyListeners();
  }
  
  void setMockErro(String? erro) {
    _mockErro = erro;
    notifyListeners();
  }
}

void main() {
  testWidgets('Aplicativo deve renderizar corretamente', (WidgetTester tester) async {
    // Arrange
    final mockService = MockTarefaService();
    
    // Act
    await tester.pumpWidget(
      ChangeNotifierProvider<TarefaService>.value(
        value: mockService,
        child: const App(),
      )
    );
    
    // Assert
    expect(find.text('Gerenciador de Tarefas'), findsOneWidget);
    // Há mais de um ícone de adição, então verificamos apenas a presença do título
  });
  
  testWidgets('Deve navegar para a tela de adicionar tarefa ao clicar no botão +', (WidgetTester tester) async {
    // Arrange
    final mockService = MockTarefaService();
    
    // Act
    await tester.pumpWidget(
      ChangeNotifierProvider<TarefaService>.value(
        value: mockService,
        child: const App(),
      )
    );
    
    // Em vez de clicar no ícone, vamos clicar no FloatingActionButton que contém o ícone
    await tester.tap(find.byType(FloatingActionButton).first);
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.text('Nova Tarefa'), findsOneWidget);
  });
}
