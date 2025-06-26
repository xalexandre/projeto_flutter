import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projeto_flutter/main.dart' as app;
import 'package:projeto_flutter/models/tarefa.dart';
import 'package:projeto_flutter/services/auth_service.dart';
import 'package:projeto_flutter/services/firestore_service.dart';
import 'package:provider/provider.dart';

/// Este teste de integração verifica o fluxo completo de:
/// 1. Inicialização do Firebase
/// 2. Autenticação de usuário
/// 3. Sincronização de tarefas com o Firestore
/// 4. Operações CRUD em tarefas
///
/// IMPORTANTE: Para executar este teste, você precisa:
/// 1. Ter configurado um projeto Firebase
/// 2. Ter adicionado as credenciais no projeto
/// 3. Ter criado um usuário de teste no Firebase Auth
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Credenciais de teste - SUBSTITUA POR CREDENCIAIS VÁLIDAS
  const testEmail = 'teste@exemplo.com';
  const testPassword = 'senha123';
  
  group('Teste de Integração com Firebase', () {
    setUpAll(() async {
      // Inicializar o Firebase
      await Firebase.initializeApp();
      
      // Garantir que o usuário não está autenticado no início do teste
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        await auth.signOut();
      }
    });
    
    tearDownAll(() async {
      // Limpar após os testes
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        await auth.signOut();
      }
    });
    
    testWidgets('Fluxo completo de autenticação e sincronização', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Verificar se a tela de login é exibida
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      
      // Preencher os campos de login
      await tester.enterText(find.byType(TextFormField).first, testEmail);
      await tester.enterText(find.byType(TextFormField).last, testPassword);
      
      // Fazer login
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Aguardar autenticação
      
      // Verificar se o login foi bem-sucedido e a página inicial foi carregada
      expect(find.text('Gerenciador de Tarefas'), findsOneWidget);
      
      // Obter o AuthService para verificar o estado da autenticação
      final authService = tester.element(find.byType(Scaffold)).findAncestorWidgetOfExactType<MaterialApp>()!
          .builder!(tester.element(find.byType(Scaffold)), tester.element(find.byType(Scaffold)).widget)
          .findAncestorStateOfType<State>()!
          .context
          .read<AuthService>();
      
      expect(authService.isAuthenticated, true);
      
      // Adicionar uma nova tarefa
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Verificar se a tela de formulário de tarefa foi aberta
      expect(find.text('Nova Tarefa'), findsOneWidget);
      
      // Preencher o formulário
      final now = DateTime.now();
      const nomeTarefa = 'Tarefa de Teste Firebase';
      const descricaoTarefa = 'Descrição da tarefa de teste de integração com Firebase';
      
      await tester.enterText(find.byKey(const ValueKey('nome_tarefa')), nomeTarefa);
      await tester.enterText(find.byKey(const ValueKey('descricao_tarefa')), descricaoTarefa);
      
      // Salvar a tarefa
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      
      // Verificar se voltou para a tela inicial
      expect(find.text('Gerenciador de Tarefas'), findsOneWidget);
      
      // Verificar se a tarefa foi adicionada à lista
      expect(find.text(nomeTarefa), findsOneWidget);
      expect(find.text(descricaoTarefa), findsOneWidget);
      
      // Verificar se a tarefa foi salva no Firestore
      final firestoreService = FirestoreService();
      final tarefasFirestore = await firestoreService.carregarTarefas();
      
      expect(
        tarefasFirestore.any((t) => 
          t.nome == nomeTarefa && 
          t.descricao == descricaoTarefa && 
          !t.concluida
        ), 
        isTrue
      );
      
      // Editar a tarefa
      // Encontrar o botão de editar na tarefa
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();
      
      // Verificar se a tela de edição foi aberta
      expect(find.text('Editar Tarefa'), findsOneWidget);
      
      // Modificar a tarefa
      const novoNome = 'Tarefa Editada - Firebase';
      await tester.enterText(find.byKey(const ValueKey('nome_tarefa')), novoNome);
      
      // Marcar como concluída
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      
      // Salvar as alterações
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      
      // Verificar se a tarefa foi atualizada na lista
      expect(find.text(novoNome), findsOneWidget);
      
      // Verificar se as alterações foram salvas no Firestore
      final tarefasAtualizadas = await firestoreService.carregarTarefas();
      expect(
        tarefasAtualizadas.any((t) => 
          t.nome == novoNome && 
          t.concluida
        ), 
        isTrue
      );
      
      // Excluir a tarefa
      // Encontrar o botão de excluir na tarefa
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      // Confirmar a exclusão
      expect(find.text('Confirmar exclusão'), findsOneWidget);
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      
      // Verificar se a tarefa foi removida da lista
      expect(find.text(novoNome), findsNothing);
      
      // Verificar se a tarefa foi removida do Firestore
      final tarefasAposExclusao = await firestoreService.carregarTarefas();
      expect(
        tarefasAposExclusao.any((t) => t.nome == novoNome),
        isFalse
      );
      
      // Fazer logout
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      
      // Confirmar o logout
      expect(find.text('Sair'), findsOneWidget);
      await tester.tap(find.text('Sair').last); // O último porque pode haver múltiplos (no diálogo e no título)
      await tester.pumpAndSettle();
      
      // Verificar se voltou para a tela de login
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      
      // Verificar se o usuário foi deslogado
      expect(FirebaseAuth.instance.currentUser, isNull);
    });
    
    testWidgets('Deve sincronizar tarefas entre dispositivos', (WidgetTester tester) async {
      // Este teste simula o cenário de um usuário com múltiplos dispositivos
      // Primeiro, vamos adicionar uma tarefa diretamente no Firestore
      await Firebase.initializeApp();
      
      // Fazer login programaticamente
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      // Adicionar uma tarefa diretamente via Firestore
      final firestoreService = FirestoreService();
      final tarefaRemota = Tarefa(
        id: '',
        nome: 'Tarefa Remota',
        descricao: 'Esta tarefa foi criada em outro dispositivo',
        concluida: false,
        dataHora: DateTime.now(),
      );
      
      final idTarefaRemota = await firestoreService.adicionarTarefa(tarefaRemota);
      
      // Fazer logout
      await FirebaseAuth.instance.signOut();
      
      // Agora iniciar o app e fazer login novamente
      app.main();
      await tester.pumpAndSettle();
      
      // Fazer login pela UI
      await tester.enterText(find.byType(TextFormField).first, testEmail);
      await tester.enterText(find.byType(TextFormField).last, testPassword);
      
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Aguardar autenticação e sincronização
      
      // Verificar se a tarefa remota foi sincronizada e aparece na lista
      expect(find.text('Tarefa Remota'), findsOneWidget);
      expect(find.text('Esta tarefa foi criada em outro dispositivo'), findsOneWidget);
      
      // Limpar - remover a tarefa remota
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      
      // Verificar que a tarefa foi removida
      expect(find.text('Tarefa Remota'), findsNothing);
    });
  });
}
