# Guia de Testes para o Pacote Core Components

Este documento fornece instruções detalhadas sobre como testar os componentes e utilitários do pacote `core_components`.

## Configuração do Ambiente de Teste

### Pré-requisitos

1. Flutter SDK (versão 3.16.0 ou superior)
2. Dependências de desenvolvimento instaladas:
   ```bash
   flutter pub get
   ```

### Estrutura de Testes

Os testes para o pacote `core_components` estão organizados da seguinte forma:

- **Testes de Widgets**: Para testar os componentes visuais
- **Testes de Utilitários**: Para testar as funções de utilidade
- **Testes de Integração**: Para testar como os componentes funcionam juntos

## Testes de Widgets

### CustomButton

Para testar o `CustomButton`, você deve verificar:

1. **Renderização correta** de cada variante (primário, secundário, texto)
2. **Comportamento do callback** quando pressionado
3. **Estados visuais** (habilitado, desabilitado, carregando)

```dart
testWidgets('CustomButton.primary deve ter estilo primário', (WidgetTester tester) async {
  bool buttonPressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomButton.primary(
          text: 'Botão Primário',
          onPressed: () => buttonPressed = true,
        ),
      ),
    ),
  );
  
  // Verificar estilo primário
  final buttonFinder = find.byType(ElevatedButton);
  expect(buttonFinder, findsOneWidget);
  
  // Verificar callback
  await tester.tap(buttonFinder);
  expect(buttonPressed, true);
});
```

### CustomTextField

Para testar o `CustomTextField`, você deve verificar:

1. **Entrada de texto** e atualização do valor
2. **Validação de entrada** com diferentes regras
3. **Comportamento dos ícones** (prefixo, sufixo, visibilidade de senha)

```dart
testWidgets('CustomTextField deve validar entrada', (WidgetTester tester) async {
  String inputText = '';
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomTextField(
          label: 'Email',
          validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          onChanged: (value) => inputText = value,
        ),
      ),
    ),
  );
  
  // Digitar texto
  await tester.enterText(find.byType(TextField), 'teste@exemplo.com');
  expect(inputText, 'teste@exemplo.com');
  
  // Verificar validação
  final formField = find.byType(Form);
  if (formField.evaluate().isNotEmpty) {
    await tester.tap(find.text('Validar'));
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsNothing);
  }
});
```

## Testes de Utilitários

### DateFormatter

Para testar o `DateFormatter`, você deve verificar:

1. **Formatação de datas** em diferentes formatos
2. **Cálculo de tempo relativo** (timeAgo, timeUntil)
3. **Manipulação de datas** inválidas ou nulas

```dart
test('formatFullDate deve formatar data corretamente', () {
  final date = DateTime(2025, 6, 25, 14, 30);
  final formatted = DateFormatter.formatFullDate(date);
  expect(formatted, '25 de junho de 2025'); // Ajuste conforme o formato esperado
});

test('timeAgo deve calcular tempo relativo corretamente', () {
  final now = DateTime.now();
  final oneHourAgo = now.subtract(const Duration(hours: 1));
  final timeAgo = DateFormatter.timeAgo(oneHourAgo);
  expect(timeAgo, contains('hora'));
});
```

### InputValidators

Para testar o `InputValidators`, você deve verificar:

1. **Validação de email** com diferentes formatos
2. **Validação de senha** com diferentes critérios
3. **Validação de campos obrigatórios** e outros tipos de entrada

```dart
test('validateEmail deve validar emails corretamente', () {
  // Email válido
  expect(InputValidators.validateEmail('usuario@exemplo.com'), isNull);
  
  // Email inválido
  expect(InputValidators.validateEmail('email_invalido'), isNotNull);
  expect(InputValidators.validateEmail(''), isNotNull);
});

test('validatePassword deve validar senhas corretamente', () {
  // Senha válida
  expect(InputValidators.validatePassword('Senha123!'), isNull);
  
  // Senha muito curta
  expect(InputValidators.validatePassword('123'), isNotNull);
});
```

### ResponsiveHelper

Para testar o `ResponsiveHelper`, você deve verificar:

1. **Detecção de tipo de dispositivo** em diferentes tamanhos de tela
2. **Cálculo de tamanhos adaptativos** para diferentes dispositivos
3. **Construção de layouts responsivos** com o builder

```dart
testWidgets('isTablet deve identificar tablets corretamente', (WidgetTester tester) async {
  // Configurar tamanho de tela de tablet
  tester.binding.window.physicalSizeTestValue = const Size(1024, 768);
  tester.binding.window.devicePixelRatioTestValue = 2.0;
  
  bool isTablet = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          isTablet = ResponsiveHelper.isTablet(context);
          return Container();
        },
      ),
    ),
  );
  
  expect(isTablet, true);
  
  // Restaurar
  tester.binding.window.clearPhysicalSizeTestValue();
  tester.binding.window.clearDevicePixelRatioTestValue();
});
```

## Testes de Integração

Para testar como os componentes do pacote funcionam juntos, você pode criar testes que simulam cenários reais de uso:

```dart
testWidgets('Formulário com múltiplos componentes', (WidgetTester tester) async {
  bool formSubmitted = false;
  String name = '';
  String email = '';
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            CustomTextField(
              label: 'Nome',
              onChanged: (value) => name = value,
            ),
            CustomTextField.email(
              onChanged: (value) => email = value,
            ),
            CustomButton.primary(
              text: 'Enviar',
              onPressed: () => formSubmitted = true,
            ),
          ],
        ),
      ),
    ),
  );
  
  // Preencher formulário
  await tester.enterText(find.byType(TextField).first, 'João Silva');
  await tester.enterText(find.byType(TextField).last, 'joao@exemplo.com');
  
  // Enviar formulário
  await tester.tap(find.text('Enviar'));
  await tester.pump();
  
  // Verificar resultados
  expect(name, 'João Silva');
  expect(email, 'joao@exemplo.com');
  expect(formSubmitted, true);
});
```

## Testes de Temas

Para testar os temas e constantes visuais, você deve verificar:

1. **Consistência de cores** entre diferentes partes do aplicativo
2. **Escalas de tipografia** para diferentes tamanhos de tela
3. **Espaçamentos e tamanhos** para garantir consistência visual

```dart
test('AppColors deve fornecer cores consistentes', () {
  // Verificar cores primárias
  expect(AppColors.primary, isNotNull);
  expect(AppColors.secondary, isNotNull);
  
  // Verificar que as cores de prioridade são distintas
  expect(AppColors.getPriorityColor('alta'), isNot(equals(AppColors.getPriorityColor('baixa'))));
});
```

## Executando os Testes

### Testes Unitários e de Widget

Execute todos os testes do pacote com:

```bash
cd packages/core_components
flutter test
```

Para executar um arquivo de teste específico:

```bash
flutter test test/widgets/custom_button_test.dart
```

### Testes de Cobertura

Para verificar a cobertura de testes:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Depois, abra `coverage/html/index.html` em um navegador para visualizar a cobertura.

## Boas Práticas para Testes

1. **Teste cada componente isoladamente** antes de testar suas interações
2. **Use mocks** quando necessário para isolar o componente sendo testado
3. **Teste casos de borda** e cenários de erro, não apenas o caminho feliz
4. **Mantenha os testes simples e focados** em um único aspecto por vez
5. **Atualize os testes** quando modificar os componentes

## Solução de Problemas Comuns

### Problemas com Widgets Assíncronos

Se você estiver testando widgets que dependem de operações assíncronas, use:

```dart
await tester.pump(); // Atualiza uma vez
await tester.pumpAndSettle(); // Atualiza até que não haja mais frames pendentes
```

### Problemas com Contexto

Para testes que dependem do BuildContext:

```dart
await tester.pumpWidget(
  MaterialApp(
    home: Builder(
      builder: (context) {
        // Use o contexto aqui
        return YourWidget(context: context);
      },
    ),
  ),
);
```

### Problemas com Dependências Injetadas

Se seu componente depende de serviços injetados, use o Provider para fornecer mocks:

```dart
await tester.pumpWidget(
  MultiProvider(
    providers: [
      Provider<YourService>.value(value: mockService),
    ],
    child: MaterialApp(
      home: YourWidgetThatNeedsTheService(),
    ),
  ),
);
```

## Integração com o Projeto Principal

### Testando Componentes em Contexto

Para testar como os componentes do pacote se comportam no contexto do aplicativo principal:

1. Crie testes de integração no projeto principal que usam os componentes do pacote
2. Verifique se os componentes funcionam corretamente com o tema e dados do aplicativo
3. Teste cenários de uso real que combinam múltiplos componentes

```dart
// No diretório de testes do projeto principal
testWidgets('TarefaForm deve usar componentes do core_components corretamente', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light, // Tema do aplicativo principal
      home: TarefaForm(), // Widget que usa componentes do core_components
    ),
  );
  
  // Verificar se os componentes estão presentes e funcionando
  expect(find.byType(CustomTextField), findsWidgets);
  expect(find.byType(CustomButton), findsWidgets);
  
  // Interagir com os componentes
  await tester.enterText(find.byKey(const ValueKey('nome_tarefa')), 'Nova Tarefa');
  await tester.tap(find.text('Salvar'));
  await tester.pumpAndSettle();
  
  // Verificar o comportamento esperado
  // ...
});
```

## Conclusão

Testar adequadamente o pacote `core_components` é essencial para garantir que os componentes reutilizáveis funcionem conforme esperado em todas as partes do aplicativo. Seguindo este guia, você pode criar uma suíte de testes abrangente que verifica tanto o comportamento individual de cada componente quanto suas interações.

Lembre-se de que o investimento em testes para este pacote tem um retorno multiplicado, já que os componentes são usados em múltiplas partes do aplicativo. Cada bug corrigido ou melhoria implementada aqui beneficia todo o projeto.
