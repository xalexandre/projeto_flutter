import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projeto_flutter/main.dart';
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/services/tarefa_service.dart';
import 'package:provider/provider.dart';

// Mock do TarefaService para testes de integração
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
  
  // Implementações para teste
  @override
  Future<void> carregarTarefas() async {
    _mockIsLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    _mockIsLoading = false;
    notifyListeners();
  }
  
  @override
  Future<void> adicionarTarefa(Tarefa tarefa) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockTarefas.add(tarefa);
    notifyListeners();
  }
  
  @override
  Future<void> atualizarTarefa(Tarefa tarefa) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockTarefas.indexWhere((t) => t.id == tarefa.id);
    if (index != -1) {
      _mockTarefas[index] = tarefa;
      notifyListeners();
    }
  }
  
  @override
  Future<void> removerTarefa(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockTarefas.removeWhere((t) => t.id == id);
    notifyListeners();
  }
  
  @override
  Future<void> marcarComoConcluida(String id, bool concluida) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockTarefas.indexWhere((t) => t.id == id);
    if (index != -1) {
      _mockTarefas[index].concluida = concluida;
      notifyListeners();
    }
  }
  
  // Método para adicionar tarefas de teste
  void adicionarTarefasDeTeste() {
    final now = DateTime.now();
    _mockTarefas.addAll([
      Tarefa(
        id: '1', 
        nome: 'Comprar leite', 
        dataHora: now,
        concluida: false,
      ),
      Tarefa(
        id: '2', 
        nome: 'Reunião de equipe', 
        dataHora: now.add(const Duration(days: 1)),
        concluida: false,
      ),
      Tarefa(
        id: '3', 
        nome: 'Lavar o carro', 
        dataHora: now.add(const Duration(days: 2)),
        concluida: true,
      ),
    ]);
    notifyListeners();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Testes de integração do aplicativo', () {
    late MockTarefaService mockService;

    setUp(() {
      mockService = MockTarefaService();
    });

    testWidgets('Deve exibir lista vazia e adicionar nova tarefa', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      
      // Verificar que a lista está vazia inicialmente
      expect(find.text('Nenhuma tarefa cadastrada'), findsOneWidget);
      
      // Tap no botão de adicionar
      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();
      
      // Verificar que navegou para a tela de formulário
      expect(find.text('Nova Tarefa'), findsOneWidget);
      
      // Preencher o formulário
      await tester.enterText(find.byType(TextFormField).first, 'Teste de integração');
      await tester.pump();
      
      // Tap no botão de salvar
      await tester.tap(find.text('SALVAR'));
      await tester.pumpAndSettle();
      
      // Verificar que voltou para a tela inicial e a tarefa foi adicionada
      expect(find.text('Gerenciador de Tarefas'), findsOneWidget);
      expect(find.text('Teste de integração'), findsOneWidget);
    });

    testWidgets('Deve exibir lista de tarefas e marcar como concluída', (WidgetTester tester) async {
      // Arrange
      mockService.adicionarTarefasDeTeste();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      
      // Verificar que as tarefas estão sendo exibidas
      expect(find.text('Comprar leite'), findsOneWidget);
      expect(find.text('Reunião de equipe'), findsOneWidget);
      expect(find.text('Lavar o carro'), findsOneWidget);
      
      // Encontrar o checkbox da primeira tarefa e clicar
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pumpAndSettle();
      
      // Verificar que a tarefa foi marcada como concluída
      final checkbox = tester.widget<Checkbox>(firstCheckbox);
      expect(checkbox.value, true);
    });

    testWidgets('Deve exibir menu de opções e excluir tarefa', (WidgetTester tester) async {
      // Arrange
      mockService.adicionarTarefasDeTeste();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      
      // Verificar que as tarefas estão sendo exibidas
      expect(find.text('Comprar leite'), findsOneWidget);
      
      // Abrir menu de opções
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();
      
      // Verificar que o menu foi aberto
      expect(find.text('Excluir'), findsOneWidget);
      
      // Clicar na opção de excluir
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      
      // Verificar diálogo de confirmação
      expect(find.text('Confirmar exclusão'), findsOneWidget);
      
      // Confirmar a exclusão
      await tester.tap(find.text('SIM'));
      await tester.pumpAndSettle();
      
      // Verificar que a tarefa foi removida
      expect(find.text('Comprar leite'), findsNothing);
    });
    
    testWidgets('Deve editar uma tarefa existente', (WidgetTester tester) async {
      // Arrange
      mockService.adicionarTarefasDeTeste();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      
      // Verificar que as tarefas estão sendo exibidas
      expect(find.text('Comprar leite'), findsOneWidget);
      
      // Abrir menu de opções
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();
      
      // Clicar na opção de editar
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      
      // Verificar que navegou para a tela de edição
      expect(find.text('Editar Tarefa'), findsOneWidget);
      
      // Limpar o campo e inserir novo texto
      await tester.enterText(find.byType(TextFormField).first, 'Comprar leite desnatado');
      await tester.pump();
      
      // Tap no botão de salvar
      await tester.tap(find.text('SALVAR'));
      await tester.pumpAndSettle();
      
      // Verificar que voltou para a tela inicial e a tarefa foi atualizada
      expect(find.text('Gerenciador de Tarefas'), findsOneWidget);
      expect(find.text('Comprar leite desnatado'), findsOneWidget);
    });
    
    testWidgets('Deve lidar com estado de carregamento', (WidgetTester tester) async {
      // Arrange - tornar o carregamento visível
      mockService._mockIsLoading = true;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      
      // Verificar que o indicador de carregamento está sendo exibido
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Simular fim do carregamento
      mockService._mockIsLoading = false;
      mockService.notifyListeners();
      await tester.pump();
      
      // Verificar que o indicador de carregamento foi removido
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    
    testWidgets('Deve exibir mensagem de erro quando ocorrer um erro', (WidgetTester tester) async {
      // Arrange - definir um erro
      mockService._mockErro = 'Erro ao carregar tarefas';
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      
      // Verificar que a mensagem de erro está sendo exibida
      expect(find.text('Erro ao carregar tarefas'), findsOneWidget);
    });
    
    testWidgets('Deve se adaptar a diferentes tamanhos de tela', (WidgetTester tester) async {
      // Arrange
      mockService.adicionarTarefasDeTeste();
      
      // Configurar tamanho de tela para tablet (paisagem)
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      
      // Verificar que a interface se adaptou ao tamanho de tablet
      // (Isso depende da implementação específica da responsividade)
      expect(find.text('Comprar leite'), findsOneWidget);
      
      // Restaurar tamanho de tela
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('Deve navegar para a tela de formulário e voltar sem salvar', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<TarefaService>.value(
          value: mockService,
          child: const App(),
        ),
      );
      
      // Tap no botão de adicionar
      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();
      
      // Verificar que navegou para a tela de formulário
      expect(find.text('Nova Tarefa'), findsOneWidget);
      
      // Tap no botão de voltar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verificar que voltou para a tela inicial sem adicionar tarefa
      expect(find.text('Gerenciador de Tarefas'), findsOneWidget);
      expect(mockService.tarefas, isEmpty);
    });
  });
}
