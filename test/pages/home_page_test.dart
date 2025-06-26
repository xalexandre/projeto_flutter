import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/pages/home_page.dart';
import 'package:projeto_flutter/services/tarefa_service.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Gere mocks com: flutter pub run build_runner build
@GenerateMocks([TarefaService])

// Criamos uma classe mock manualmente para não depender do arquivo gerado
class MockTarefaService extends Mock implements TarefaService {}

void main() {
  group('HomePage', () {
    late MockTarefaService mockService;
    
    setUp(() {
      mockService = MockTarefaService();
    });
    
    Future<void> pumpHomePage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TarefaService>.value(
            value: mockService,
            child: const HomePage(),
          ),
        ),
      );
    }
    
    testWidgets('deve exibir título correto', (WidgetTester tester) async {
      // Arrange
      when(mockService.tarefas).thenReturn([]);
      when(mockService.isLoading).thenReturn(false);
      
      // Act
      await pumpHomePage(tester);
      
      // Assert
      expect(find.text('Gerenciador de Tarefas'), findsOneWidget);
    });
    
    testWidgets('deve exibir mensagem quando não há tarefas', (WidgetTester tester) async {
      // Arrange
      when(mockService.tarefas).thenReturn([]);
      when(mockService.isLoading).thenReturn(false);
      
      // Act
      await pumpHomePage(tester);
      
      // Assert
      expect(find.text('Nenhuma tarefa cadastrada'), findsOneWidget);
    });
    
    testWidgets('deve exibir lista de tarefas quando houver tarefas', (WidgetTester tester) async {
      // Arrange
      final tarefas = [
        Tarefa(id: '1', nome: 'Tarefa 1', dataHora: DateTime.now()),
        Tarefa(id: '2', nome: 'Tarefa 2', dataHora: DateTime.now()),
      ];
      
      when(mockService.tarefas).thenReturn(tarefas);
      when(mockService.isLoading).thenReturn(false);
      
      // Act
      await pumpHomePage(tester);
      
      // Assert
      expect(find.text('Tarefa 1'), findsOneWidget);
      expect(find.text('Tarefa 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
    
    testWidgets('deve exibir indicador de carregamento quando isLoading for true', (WidgetTester tester) async {
      // Arrange
      when(mockService.tarefas).thenReturn([]);
      when(mockService.isLoading).thenReturn(true);
      
      // Act
      await pumpHomePage(tester);
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('deve chamar marcarComoConcluida quando checkbox for clicado', (WidgetTester tester) async {
      // Arrange
      final tarefas = [
        Tarefa(id: '1', nome: 'Tarefa 1', concluida: false, dataHora: DateTime.now()),
      ];
      
      when(mockService.tarefas).thenReturn(tarefas);
      when(mockService.isLoading).thenReturn(false);
      when(mockService.marcarComoConcluida(any, any)).thenAnswer((_) => Future.value());
      
      // Act
      await pumpHomePage(tester);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      
      // Assert
      verify(mockService.marcarComoConcluida('1', true)).called(1);
    });
    
    testWidgets('deve exibir botão de adicionar tarefa', (WidgetTester tester) async {
      // Arrange
      when(mockService.tarefas).thenReturn([]);
      when(mockService.isLoading).thenReturn(false);
      
      // Act
      await pumpHomePage(tester);
      
      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
    
    testWidgets('deve exibir mensagem de erro quando houver erro', (WidgetTester tester) async {
      // Arrange
      when(mockService.tarefas).thenReturn([]);
      when(mockService.isLoading).thenReturn(false);
      when(mockService.erro).thenReturn('Erro ao carregar tarefas');
      
      // Act
      await pumpHomePage(tester);
      
      // Assert
      expect(find.text('Erro ao carregar tarefas'), findsOneWidget);
    });
    
    testWidgets('deve exibir menu de opções ao fazer long press em um item', (WidgetTester tester) async {
      // Arrange
      final tarefas = [
        Tarefa(id: '1', nome: 'Tarefa 1', dataHora: DateTime.now()),
      ];
      
      when(mockService.tarefas).thenReturn(tarefas);
      when(mockService.isLoading).thenReturn(false);
      
      // Act
      await pumpHomePage(tester);
      await tester.longPress(find.text('Tarefa 1'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });
  });
}
