# Core Components

Um pacote interno de componentes e utilitários para o projeto de gerenciamento de tarefas.

## Visão Geral

Este pacote fornece componentes de UI, utilitários e constantes que são reutilizados em todo o aplicativo. O objetivo é manter a consistência visual e comportamental, além de facilitar a manutenção ao centralizar componentes comuns.

## Componentes

### Widgets

#### CustomButton

Um botão personalizado que mantém o estilo consistente em todo o aplicativo. Suporta diferentes variantes (primário, secundário, texto) e estados (habilitado, desabilitado, carregando).

```dart
// Exemplo de uso
CustomButton(
  text: 'Salvar',
  onPressed: () => salvarTarefa(),
  variant: CustomButtonVariant.primary,
  size: CustomButtonSize.medium,
  icon: Icons.save,
);

// Ou usando construtores nomeados
CustomButton.primary(
  text: 'Salvar',
  onPressed: () => salvarTarefa(),
);

CustomButton.secondary(
  text: 'Cancelar',
  onPressed: () => cancelar(),
);

CustomButton.text(
  text: 'Saiba mais',
  onPressed: () => exibirDetalhes(),
);
```

#### CustomTextField

Um campo de texto personalizado que mantém o estilo consistente em todo o aplicativo. Suporta diferentes variantes, validação e formatação.

```dart
// Exemplo de uso
CustomTextField(
  label: 'Nome',
  hint: 'Digite seu nome',
  prefixIcon: Icons.person,
  onChanged: (value) => atualizarNome(value),
  validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
  required: true,
);

// Ou usando construtores nomeados
CustomTextField.email(
  onChanged: (value) => atualizarEmail(value),
);

CustomTextField.password(
  onChanged: (value) => atualizarSenha(value),
);

CustomTextField.search(
  onChanged: (value) => buscar(value),
);
```

### Utilitários

#### DateFormatter

Utilitário para formatação de datas em diferentes formatos para uso consistente em todo o aplicativo.

```dart
// Exemplo de uso
final dataFormatada = DateFormatter.formatFullDate(tarefa.dataHora);
final tempoRelativo = DateFormatter.timeAgo(tarefa.dataCriacao);
final tempoRestante = DateFormatter.timeUntil(tarefa.dataHora);
```

#### InputValidators

Utilitário para validação de entradas como email, senha, números, etc.

```dart
// Exemplo de uso
final emailError = InputValidators.validateEmail(email);
final passwordError = InputValidators.validatePassword(password);
final numberError = InputValidators.validateNumber(valor, fieldName: 'preço');
```

#### ResponsiveHelper

Utilitário para ajudar na criação de interfaces responsivas, determinando o tipo de dispositivo, calculando tamanhos adaptativos e aplicando diferentes layouts com base no tamanho da tela.

```dart
// Exemplo de uso
final isTablet = ResponsiveHelper.isTablet(context);
final padding = ResponsiveHelper.responsivePadding(context);
final fontSize = ResponsiveHelper.adaptiveFontSize(context, 16);

// Construir layout responsivo
ResponsiveHelper.responsiveBuilder(
  context: context,
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
);
```

### Temas

#### AppColors

Constantes de cores usadas em todo o aplicativo.

```dart
// Exemplo de uso
Container(
  color: AppColors.primary,
  child: Text('Texto colorido'),
);

// Cores para prioridades
final corPrioridade = AppColors.getPriorityColor(tarefa.prioridade);
```

## Como Adicionar Novos Componentes

Para adicionar novos componentes ao pacote:

1. Crie um novo arquivo em `lib/src/widgets/` para widgets, `lib/src/utils/` para utilitários ou `lib/src/theme/` para temas.
2. Implemente o componente seguindo o padrão de design existente.
3. Adicione a exportação do componente em `lib/core_components.dart`.
4. Documente o componente neste README.

## Boas Práticas

- Mantenha os componentes simples e focados em uma única responsabilidade.
- Forneça documentação clara e exemplos de uso.
- Use construtores nomeados para variantes comuns.
- Mantenha a consistência visual e comportamental entre componentes.
- Teste os componentes para garantir que funcionem em diferentes tamanhos de tela e configurações.
