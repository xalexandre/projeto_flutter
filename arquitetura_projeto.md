# Arquitetura do Projeto Flutter - Gerenciador de Tarefas

## Diagrama de Arquitetura

```
┌───────────────────────────────────────┐
│               CAMADA UI               │
│                                       │
│  ┌─────────┐  ┌─────────┐  ┌───────┐  │
│  │ Páginas │  │   UI    │  │ Temas │  │
│  │         │  │Components│  │       │  │
│  └─────────┘  └─────────┘  └───────┘  │
└───────────────────┬───────────────────┘
                    │
                    ▼
┌───────────────────────────────────────┐
│       CAMADA DE LÓGICA DE NEGÓCIO     │
│                                       │
│           ┌─────────────────┐         │
│           │   TarefaService │         │
│           │  (ChangeNotifier)│         │
│           └────────┬────────┘         │
│                    │                  │
│           ┌────────┴────────┐         │
│           │     Modelos     │         │
│           │ (Tarefa, etc.)  │         │
│           └─────────────────┘         │
└───────────────────┬───────────────────┘
                    │
                    ▼
┌───────────────────────────────────────┐
│          CAMADA DE DADOS              │
│                                       │
│       ┌─────────────────────┐         │
│       │  AdaptiveRepository │         │
│       └──────────┬──────────┘         │
│                  │                    │
│    ┌─────────────┼─────────────┐      │
│    │             │             │      │
│    ▼             ▼             ▼      │
│┌─────────┐ ┌──────────┐ ┌───────────┐ │
││ Tarefa  │ │   Mock   │ │    Web    │ │
││Repository│ │Repository│ │ Repository│ │
│└─────────┘ └──────────┘ └───────────┘ │
└───────────────────────────────────────┘
```

## Fluxo de Dados

1. **Entrada de Dados do Usuário**: 
   - O usuário interage com a UI (Páginas e Componentes)
   - Eventos são capturados pelos widgets

2. **Processamento**:
   - Os eventos são enviados para o `TarefaService`
   - O serviço aplica a lógica de negócio
   - Os modelos são atualizados

3. **Persistência**:
   - O `TarefaService` chama o `AdaptiveRepository`
   - O repositório adequado é selecionado com base na plataforma
   - Os dados são persistidos

4. **Atualização da UI**:
   - O `TarefaService` notifica os ouvintes sobre mudanças
   - Os widgets que dependem dos dados são reconstruídos
   - A UI é atualizada para refletir o novo estado

## Padrões de Design Utilizados

### 1. Provider Pattern

Implementado através do pacote Provider para gerenciamento de estado e injeção de dependência.

```dart
ChangeNotifierProvider<TarefaService>(
  create: (_) => TarefaService(AdaptiveRepository()),
  child: MaterialApp(...)
)
```

Uso nos widgets:
```dart
// Leitura do estado
final tarefas = context.watch<TarefaService>().tarefas;

// Chamada de método
context.read<TarefaService>().marcarComoConcluida(id, concluida);
```

### 2. Repository Pattern

Implementado para abstrair a fonte de dados e permitir diferentes implementações de persistência.

```dart
abstract class TarefaRepositoryInterface {
  Future<List<Tarefa>> carregarTarefas();
  Future<bool> salvarTarefas(List<Tarefa> tarefas);
  Future<bool> adicionarTarefa(Tarefa tarefa);
  Future<bool> atualizarTarefa(Tarefa tarefa);
  Future<bool> removerTarefa(String id);
  Future<bool> marcarComoConcluida(String id, bool concluida);
}
```

### 3. Strategy Pattern

Implementado através do `AdaptiveRepository` que seleciona a implementação apropriada com base na plataforma.

```dart
class AdaptiveRepository implements TarefaRepositoryInterface {
  final TarefaRepositoryInterface _repository;

  AdaptiveRepository() : _repository = _selecionarRepositorio();

  static TarefaRepositoryInterface _selecionarRepositorio() {
    if (kIsWeb) {
      return WebLocalStorageRepository();
    } else {
      return TarefaRepository();
    }
  }
  
  // Delegação de métodos para o repositório selecionado
  @override
  Future<List<Tarefa>> carregarTarefas() => _repository.carregarTarefas();
  
  // Outros métodos delegados...
}
```

### 4. Observer Pattern

Implementado através do `ChangeNotifier` para notificar os widgets sobre mudanças no estado.

```dart
class TarefaService extends ChangeNotifier {
  final AdaptiveRepository _repository;
  List<Tarefa> _tarefas = [];
  
  // Quando os dados mudam
  Future<void> adicionarTarefa(Tarefa tarefa) async {
    final resultado = await _repository.adicionarTarefa(tarefa);
    if (resultado) {
      _tarefas.add(tarefa);
      notifyListeners(); // Notifica os observadores
    }
  }
}
```

## Navegação

O aplicativo utiliza o sistema de navegação do Flutter com rotas nomeadas para facilitar a navegação entre telas.

```dart
class AppRoutes {
  static const home = '/';
  static const tarefaForm = '/tarefa-form';
}

class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.tarefaForm:
        final tarefa = settings.arguments as Tarefa?;
        return MaterialPageRoute(
          builder: (_) => TarefaFormPage(tarefa: tarefa),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
```

## Modelo de Dados

O modelo central do aplicativo é a classe `Tarefa`, que encapsula os dados e comportamentos relacionados a uma tarefa.

```dart
class Tarefa {
  final String id;
  final String nome;
  bool concluida;
  final DateTime dataHora;
  final GeoPoint? localizacao;

  Tarefa({
    required this.id,
    required this.nome,
    this.concluida = false,
    required this.dataHora,
    this.localizacao,
  });

  // Métodos para serialização/deserialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'concluida': concluida,
      'dataHora': dataHora.toIso8601String(),
      'localizacao': localizacao?.toJson(),
    };
  }

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      nome: json['nome'],
      concluida: json['concluida'] ?? false,
      dataHora: DateTime.parse(json['dataHora']),
      localizacao: json['localizacao'] != null
          ? GeoPoint.fromJson(json['localizacao'])
          : null,
    );
  }
}
```

## Responsividade

O aplicativo utiliza o utilitário `ResponsiveUtil` para adaptar a interface para diferentes tamanhos de tela e orientações.

```dart
class ResponsiveUtil {
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= 600;
  }

  static bool isLandscape(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape;
  }

  static double adaptiveFontSize(BuildContext context, double size) {
    final isTab = isTablet(context);
    return size * (isTab ? 1.3 : 1.0);
  }

  // Outros métodos para responsividade...
}
```

## Testes

O projeto inclui uma estrutura abrangente de testes, cobrindo os diferentes componentes da arquitetura:

1. **Testes de Modelos**:
   - Verificam a correta inicialização, serialização e deserialização dos modelos de dados.
   - Implementados em `test/models/tarefa_test.dart`.

2. **Testes de Repositório**:
   - Validam as operações CRUD nos repositórios.
   - Garantem que os dados são corretamente persistidos e recuperados.
   - Implementados em `test/repositories/mock_tarefa_repository_test.dart`.

3. **Testes de Serviços**:
   - Verificam a lógica de negócio implementada nos serviços.
   - Garantem que os serviços interagem corretamente com os repositórios.
   - Validam a notificação dos observadores quando o estado muda.
   - Implementados em `test/services/tarefa_service_test_simples.dart`.

4. **Testes de Widget**:
   - Verificam a correta renderização dos componentes de UI.
   - Validam as interações do usuário com os widgets.
   - Garantem que os componentes se adaptam corretamente a diferentes tamanhos de tela.
   - Implementados em `test/components/tarefa_item_test.dart` e `test/pages/home_page_test.dart`.

5. **Testes de Integração**:
   - Validam a interação entre os diferentes componentes do sistema.
   - Garantem que o aplicativo funciona como um todo.
   - Simulam fluxos completos de usuário como adicionar, editar, marcar como concluída e excluir tarefas.
   - Testam diferentes estados da interface (carregamento, erro, vazio, com dados).
   - Verificam a adaptação da interface a diferentes tamanhos de tela.
   - Implementados em `integration_test/app_test.dart`.

### Estrutura de Testes de Integração

Os testes de integração utilizam a biblioteca `integration_test` do Flutter e um mock do `TarefaService` para simular as interações com a camada de dados:

```dart
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

group('Testes de integração do aplicativo', () {
  late MockTarefaService mockService;

  setUp(() {
    mockService = MockTarefaService();
  });

  testWidgets('Deve exibir lista vazia e adicionar nova tarefa', (WidgetTester tester) async {
    // Implementação do teste...
  });
});
```

## Conclusão

A arquitetura do projeto "Gerenciador de Tarefas" segue boas práticas de desenvolvimento Flutter, com uma clara separação de responsabilidades e uso adequado de padrões de design. Isso resulta em um código mais manutenível, testável e extensível, facilitando futuras evoluções do aplicativo.

A combinação do Provider para gerenciamento de estado com o padrão Repository para abstração de dados cria uma base sólida para o aplicativo, enquanto o uso de componentes responsivos garante uma boa experiência de usuário em diferentes dispositivos.
