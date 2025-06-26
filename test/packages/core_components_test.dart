import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_components/core_components.dart';

/// Este arquivo contém testes para verificar a integração dos componentes
/// do pacote core_components no projeto principal.
void main() {
  group('CustomButton no projeto principal', () {
    testWidgets('CustomButton.primary deve ser renderizado corretamente', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomButton.primary(
                text: 'Botão de Teste',
                onPressed: () => buttonPressed = true,
              ),
            ),
          ),
        ),
      );
      
      // Verificar se o botão foi renderizado
      expect(find.text('Botão de Teste'), findsOneWidget);
      
      // Verificar se o botão tem o estilo primário (cor de fundo)
      final buttonMaterial = tester.widget<Material>(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.byType(Material),
        ),
      );
      expect(buttonMaterial.color, equals(AppColors.primary));
      
      // Verificar o callback
      await tester.tap(find.byType(ElevatedButton));
      expect(buttonPressed, true);
    });
    
    testWidgets('CustomButton.secondary deve ser renderizado com estilo secundário', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomButton.secondary(
                text: 'Botão Secundário',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      
      // Verificar se o botão foi renderizado
      expect(find.text('Botão Secundário'), findsOneWidget);
      
      // Verificar se o botão tem o estilo secundário
      final buttonMaterial = tester.widget<Material>(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.byType(Material),
        ),
      );
      expect(buttonMaterial.color, equals(AppColors.secondary));
    });
    
    testWidgets('CustomButton deve mostrar indicador de carregamento quando isLoading=true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomButton.primary(
                text: 'Carregando',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );
      
      // Verificar se o indicador de carregamento é exibido
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Carregando'), findsNothing); // O texto fica oculto durante o carregamento
    });
  });
  
  group('CustomTextField no projeto principal', () {
    testWidgets('CustomTextField deve ser renderizado corretamente', (WidgetTester tester) async {
      String inputText = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomTextField(
                label: 'Nome',
                hint: 'Digite seu nome',
                onChanged: (value) => inputText = value,
              ),
            ),
          ),
        ),
      );
      
      // Verificar se o campo foi renderizado
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Digite seu nome'), findsOneWidget);
      
      // Digitar texto e verificar o callback
      await tester.enterText(find.byType(TextField), 'Teste de Input');
      expect(inputText, 'Teste de Input');
    });
    
    testWidgets('CustomTextField.email deve ter validação de email', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField.email(
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      
      // Verificar se o campo foi renderizado com ícone de email
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      
      // Digitar um email inválido
      await tester.enterText(find.byType(TextField), 'email_invalido');
      
      // Validar o formulário
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump(); // Atualizar para mostrar mensagem de erro
      
      // Verificar mensagem de erro
      expect(find.text('Email inválido'), findsOneWidget);
      
      // Digitar um email válido
      await tester.enterText(find.byType(TextField), 'teste@exemplo.com');
      
      // Validar o formulário novamente
      expect(formKey.currentState!.validate(), isTrue);
    });
    
    testWidgets('CustomTextField com senha deve alternar visibilidade', (WidgetTester tester) async {
      bool passwordVisible = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomTextField(
                label: 'Senha',
                obscureText: !passwordVisible,
                suffixIcon: passwordVisible ? Icons.visibility_off : Icons.visibility,
                onSuffixIconPressed: () => passwordVisible = !passwordVisible,
              ),
            ),
          ),
        ),
      );
      
      // Verificar se o campo está com a senha oculta inicialmente
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
      
      // Verificar se o ícone de visibilidade está presente
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
  
  group('ResponsiveHelper no projeto principal', () {
    testWidgets('ResponsiveHelper deve fornecer tamanhos adaptativos', (WidgetTester tester) async {
      double adaptiveSize = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              adaptiveSize = ResponsiveHelper.adaptiveFontSize(context, 16);
              return Text('Texto de teste', style: TextStyle(fontSize: adaptiveSize));
            },
          ),
        ),
      );
      
      // Verificar se o tamanho foi calculado (não deve ser zero)
      expect(adaptiveSize, isNot(0));
      
      // Verificar se o texto foi renderizado com o tamanho adaptativo
      final textWidget = tester.widget<Text>(find.text('Texto de teste'));
      expect(textWidget.style?.fontSize, equals(adaptiveSize));
    });
    
    testWidgets('ResponsiveHelper deve detectar tipo de dispositivo', (WidgetTester tester) async {
      bool? isMobile;
      bool? isTablet;
      bool? isDesktop;
      
      // Tamanho de tela de celular
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 3.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isMobile = ResponsiveHelper.isMobile(context);
              isTablet = ResponsiveHelper.isTablet(context);
              isDesktop = ResponsiveHelper.isDesktop(context);
              return Container();
            },
          ),
        ),
      );
      
      // Verificar detecção para celular
      expect(isMobile, isTrue);
      expect(isTablet, isFalse);
      expect(isDesktop, isFalse);
      
      // Restaurar
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
  
  group('DateFormatter no projeto principal', () {
    test('formatFullDate deve formatar data corretamente', () {
      final date = DateTime(2025, 6, 25);
      final formatted = DateFormatter.formatFullDate(date);
      
      // O formato exato pode variar dependendo da implementação, mas deve conter o dia, mês e ano
      expect(formatted, contains('25'));
      expect(formatted, contains('2025'));
    });
    
    test('timeAgo deve calcular tempo relativo corretamente', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      
      expect(DateFormatter.timeAgo(oneHourAgo), contains('hora'));
      expect(DateFormatter.timeAgo(oneMinuteAgo), contains('minuto'));
    });
  });
  
  group('InputValidators no projeto principal', () {
    test('validateRequired deve validar campos obrigatórios', () {
      expect(InputValidators.validateRequired(''), isNotNull); // Erro para campo vazio
      expect(InputValidators.validateRequired('Texto'), isNull); // Nulo (válido) para campo preenchido
    });
    
    test('validateEmail deve validar emails corretamente', () {
      expect(InputValidators.validateEmail(''), isNotNull); // Erro para campo vazio
      expect(InputValidators.validateEmail('email_invalido'), isNotNull); // Erro para email inválido
      expect(InputValidators.validateEmail('teste@exemplo.com'), isNull); // Nulo (válido) para email correto
    });
    
    test('validatePassword deve validar senhas corretamente', () {
      expect(InputValidators.validatePassword('123'), isNotNull); // Erro para senha muito curta
      expect(InputValidators.validatePassword('senha123'), isNull); // Nulo (válido) para senha correta
    });
  });
  
  group('Integração de componentes do core_components', () {
    testWidgets('Formulário com múltiplos componentes deve funcionar corretamente', (WidgetTester tester) async {
      bool formSubmitted = false;
      final formKey = GlobalKey<FormState>();
      String name = '';
      String email = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Nome',
                    onChanged: (value) => name = value,
                    validator: InputValidators.validateRequired,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField.email(
                    onChanged: (value) => email = value,
                  ),
                  const SizedBox(height: 24),
                  CustomButton.primary(
                    text: 'Enviar',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formSubmitted = true;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // Verificar se os campos foram renderizados
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Enviar'), findsOneWidget);
      
      // Tentar submeter o formulário sem preencher (deve falhar)
      await tester.tap(find.text('Enviar'));
      await tester.pump();
      expect(formSubmitted, false);
      
      // Preencher os campos
      await tester.enterText(find.byType(TextField).first, 'João Silva');
      await tester.enterText(find.byType(TextField).last, 'joao@exemplo.com');
      
      // Submeter o formulário (deve ter sucesso)
      await tester.tap(find.text('Enviar'));
      await tester.pump();
      
      // Verificar se o formulário foi submetido com sucesso
      expect(formSubmitted, true);
      expect(name, 'João Silva');
      expect(email, 'joao@exemplo.com');
    });
  });
}
