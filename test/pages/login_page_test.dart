import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/pages/login_page.dart';
import 'package:projeto_flutter/services/auth_service.dart';
import 'package:projeto_flutter/services/firebase_service.dart';
import 'package:projeto_flutter/routes/app_routes.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthService, FirebaseService, NavigatorObserver])
void main() {
  late MockAuthService mockAuthService;
  late MockFirebaseService mockFirebaseService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockAuthService = MockAuthService();
    mockFirebaseService = MockFirebaseService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createLoginPage() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
        ),
      ],
      child: MaterialApp(
        initialRoute: AppRoutes.login,
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.home: (context) => const Scaffold(body: Text('Home Page')),
        },
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('deve mostrar campos de email e senha', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      
      // Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Não tem uma conta? Registre-se'), findsOneWidget);
    });
    
    testWidgets('deve alternar entre modos de login e registro', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      
      // Act - Renderiza a tela inicial (login)
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Assert - Verifica modo de login
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      
      // Act - Clica para mudar para o modo de registro
      await tester.tap(find.text('Não tem uma conta? Registre-se'));
      await tester.pumpAndSettle();
      
      // Assert - Verifica modo de registro
      expect(find.text('Crie sua conta'), findsOneWidget);
      expect(find.text('Registrar'), findsOneWidget);
      
      // Act - Volta para o modo de login
      await tester.tap(find.text('Já tem uma conta? Faça login'));
      await tester.pumpAndSettle();
      
      // Assert - Verifica que voltou para o modo de login
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });
    
    testWidgets('deve validar campos de email e senha vazios', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      
      // Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Tenta fazer login sem preencher os campos
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      
      // Assert - Verifica mensagens de erro
      expect(find.text('E-mail é obrigatório'), findsOneWidget);
      expect(find.text('Senha é obrigatória'), findsOneWidget);
    });
    
    testWidgets('deve chamar login quando formulário for válido', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      when(mockAuthService.login('teste@exemplo.com', 'senha123'))
          .thenAnswer((_) async => MockUser());
      when(mockAuthService.isAuthenticated).thenReturn(true);
      
      // Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Preenche os campos
      await tester.enterText(find.byType(TextFormField).first, 'teste@exemplo.com');
      await tester.enterText(find.byType(TextFormField).last, 'senha123');
      
      // Submete o formulário
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      
      // Assert
      verify(mockAuthService.login('teste@exemplo.com', 'senha123')).called(1);
    });
    
    testWidgets('deve navegar para home após login bem-sucedido', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      when(mockAuthService.login('teste@exemplo.com', 'senha123'))
          .thenAnswer((_) async => MockUser());
      when(mockAuthService.isAuthenticated).thenReturn(true);
      
      // Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Preenche os campos
      await tester.enterText(find.byType(TextFormField).first, 'teste@exemplo.com');
      await tester.enterText(find.byType(TextFormField).last, 'senha123');
      
      // Submete o formulário
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      
      // Assert - Verifica que navegou para a página inicial
      verify(mockNavigatorObserver.didPush(any, any)).called(2); // Login + Home
      expect(find.text('Home Page'), findsOneWidget);
    });
    
    testWidgets('deve mostrar erro quando login falhar', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      when(mockAuthService.login('teste@exemplo.com', 'senha_errada'))
          .thenAnswer((_) async => null);
      when(mockAuthService.errorMessage).thenReturn('Senha incorreta.');
      when(mockAuthService.status).thenReturn(AuthStatus.error);
      
      // Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Preenche os campos
      await tester.enterText(find.byType(TextFormField).first, 'teste@exemplo.com');
      await tester.enterText(find.byType(TextFormField).last, 'senha_errada');
      
      // Submete o formulário
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      
      // Assert
      verify(mockAuthService.login('teste@exemplo.com', 'senha_errada')).called(1);
      
      // Verifica que mostrou o SnackBar com a mensagem de erro
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Senha incorreta.'), findsOneWidget);
    });
    
    testWidgets('deve chamar resetarSenha quando esqueci minha senha for clicado', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      when(mockAuthService.resetarSenha('teste@exemplo.com')).thenAnswer((_) async => true);
      
      // Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Preenche o campo de email
      await tester.enterText(find.byType(TextFormField).first, 'teste@exemplo.com');
      
      // Clica em "Esqueci minha senha"
      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();
      
      // Assert
      verify(mockAuthService.resetarSenha('teste@exemplo.com')).called(1);
      
      // Verifica que mostrou o SnackBar com a mensagem de sucesso
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email de redefinição de senha enviado. Verifique sua caixa de entrada.'), findsOneWidget);
    });
    
    testWidgets('deve mostrar indicador de carregamento durante autenticação', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.status).thenReturn(AuthStatus.initial);
      
      // Simular que o login será assíncrono e mostrará o estado de carregamento
      when(mockAuthService.login('teste@exemplo.com', 'senha123')).thenAnswer((_) {
        when(mockAuthService.status).thenReturn(AuthStatus.authenticating);
        return Future.delayed(const Duration(milliseconds: 100), () => MockUser());
      });
      
      // Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();
      
      // Preenche os campos
      await tester.enterText(find.byType(TextFormField).first, 'teste@exemplo.com');
      await tester.enterText(find.byType(TextFormField).last, 'senha123');
      
      // Submete o formulário
      await tester.tap(find.text('Entrar'));
      await tester.pump(); // Atualiza sem esperar animações
      
      // Assert - Verifica que o indicador de carregamento está visível
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
