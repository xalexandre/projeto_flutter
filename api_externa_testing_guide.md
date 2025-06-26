# Guia de Teste para Integração com API Externa (OpenStreetMap/Nominatim)

Este documento fornece instruções detalhadas sobre como testar a integração do aplicativo com a API externa do OpenStreetMap (Nominatim) para funcionalidades de geocodificação e mapas.

## 1. Configuração do Ambiente de Teste

### 1.1 Dependências Necessárias

Certifique-se de que as seguintes dependências estão instaladas no seu projeto:

```yaml
dependencies:
  http: ^1.4.0              # Para chamadas HTTP à API
  flutter_map: ^8.1.1       # Implementação do mapa OpenStreetMap para Flutter
  latlong2: ^0.9.1          # Para manipulação de coordenadas geográficas

dev_dependencies:
  mockito: ^5.4.2           # Para mock de serviços em testes
  http_mock_adapter: ^0.6.0  # Para simular respostas HTTP
```

### 1.2 Arquivos de Teste Necessários

Para testar a integração com a API externa, você deve ter os seguintes arquivos de teste:

1. `test/services/location_service_test.dart` - Testes unitários para o serviço de localização
2. `test/widgets/location_search_test.dart` - Testes de widget para o componente de busca
3. `integration_test/location_api_test.dart` - Testes de integração para o fluxo completo

## 2. Testes Unitários para LocationService

### 2.1 Configuração do Mock HTTP

Crie um arquivo `test/services/location_service_test.dart` com o seguinte conteúdo:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:projeto_flutter/models/geo_point.dart';
import 'package:projeto_flutter/services/location_service.dart';

import 'location_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late LocationService locationService;

  setUp(() {
    mockClient = MockClient();
    locationService = LocationService();
    // Injetar o cliente HTTP mockado
    locationService.client = mockClient;
  });

  group('LocationService', () {
    test('searchAddress deve retornar lista de resultados formatados', () async {
      // Configurar resposta mock
      when(mockClient.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=New%20York&format=json&limit=5&addressdetails=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('''
        [
          {
            "place_id": 123456,
            "lat": "40.7127281",
            "lon": "-74.0060152",
            "display_name": "New York, United States"
          }
        ]
      ''', 200));

      // Executar o método
      final results = await locationService.searchAddress('New York');

      // Verificar resultados
      expect(results.length, 1);
      expect(results[0]['name'], 'New York, United States');
      expect(results[0]['latitude'], 40.7127281);
      expect(results[0]['longitude'], -74.0060152);
    });

    test('getAddressFromCoordinates deve retornar endereço formatado', () async {
      // Configurar resposta mock
      when(mockClient.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=40.7127281&lon=-74.0060152&format=json'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('''
        {
          "place_id": 123456,
          "display_name": "New York, NY, United States"
        }
      ''', 200));

      // Executar o método
      final address = await locationService.getAddressFromCoordinates(
        GeoPoint(latitude: 40.7127281, longitude: -74.0060152)
      );

      // Verificar resultados
      expect(address, 'New York, NY, United States');
    });

    test('searchAddress deve lidar com erro de API', () async {
      // Configurar resposta mock com erro
      when(mockClient.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=Invalid%20Location&format=json&limit=5&addressdetails=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      // Executar o método
      final results = await locationService.searchAddress('Invalid Location');

      // Verificar que retorna lista vazia em caso de erro
      expect(results, isEmpty);
    });

    test('isValidCoordinate deve validar coordenadas corretamente', () {
      // Coordenadas válidas
      expect(locationService.isValidCoordinate(
        GeoPoint(latitude: 40.7127281, longitude: -74.0060152)
      ), isTrue);

      // Coordenadas inválidas (fora do intervalo)
      expect(locationService.isValidCoordinate(
        GeoPoint(latitude: 100.0, longitude: -74.0060152)
      ), isFalse);

      // Coordenadas nulas
      expect(locationService.isValidCoordinate(null), isFalse);
    });
  });
}
```

### 2.2 Executando os Testes Unitários

Execute os testes unitários com o seguinte comando:

```bash
flutter test test/services/location_service_test.dart
```

## 3. Testes de Widget para LocationSearch

### 3.1 Configuração do Teste de Widget

Crie um arquivo `test/widgets/location_search_test.dart` com o seguinte conteúdo:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:projeto_flutter/components/location_search.dart';
import 'package:projeto_flutter/models/geo_point.dart';
import 'package:projeto_flutter/services/location_service.dart';

import 'location_search_test.mocks.dart';

@GenerateMocks([LocationService])
void main() {
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
  });

  Widget createLocationSearch() {
    return MaterialApp(
      home: Scaffold(
        body: LocationSearch(
          onLocationSelected: (_) {},
          locationService: mockLocationService,
        ),
      ),
    );
  }

  group('LocationSearch Widget', () {
    testWidgets('deve mostrar campo de busca', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createLocationSearch());
      
      // Verificar se o campo de busca está presente
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar endereço...'), findsOneWidget);
    });

    testWidgets('deve mostrar resultados de busca', (WidgetTester tester) async {
      // Configurar mock para retornar resultados
      when(mockLocationService.searchAddress('New York')).thenAnswer((_) async => [
        {
          'name': 'New York, United States',
          'latitude': 40.7127281,
          'longitude': -74.0060152,
        }
      ]);
      
      // Renderizar o widget
      await tester.pumpWidget(createLocationSearch());
      
      // Digitar no campo de busca
      await tester.enterText(find.byType(TextField), 'New York');
      await tester.pumpAndSettle(); // Aguardar animações
      
      // Verificar se os resultados são exibidos
      expect(find.text('New York, United States'), findsOneWidget);
    });

    testWidgets('deve chamar onLocationSelected quando um resultado é selecionado', (WidgetTester tester) async {
      // Variável para capturar a localização selecionada
      GeoPoint? selectedLocation;
      
      // Configurar mock para retornar resultados
      when(mockLocationService.searchAddress('New York')).thenAnswer((_) async => [
        {
          'name': 'New York, United States',
          'latitude': 40.7127281,
          'longitude': -74.0060152,
        }
      ]);
      
      // Renderizar o widget com callback
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LocationSearch(
            onLocationSelected: (location) {
              selectedLocation = location;
            },
            locationService: mockLocationService,
          ),
        ),
      ));
      
      // Digitar no campo de busca
      await tester.enterText(find.byType(TextField), 'New York');
      await tester.pumpAndSettle(); // Aguardar animações
      
      // Selecionar resultado
      await tester.tap(find.text('New York, United States'));
      await tester.pumpAndSettle();
      
      // Verificar se o callback foi chamado com os valores corretos
      expect(selectedLocation, isNotNull);
      expect(selectedLocation!.latitude, 40.7127281);
      expect(selectedLocation!.longitude, -74.0060152);
    });
  });
}
```

### 3.2 Executando os Testes de Widget

Execute os testes de widget com o seguinte comando:

```bash
flutter test test/widgets/location_search_test.dart
```

## 4. Testes de Integração

### 4.1 Configuração do Teste de Integração

Crie um arquivo `integration_test/location_api_test.dart` com o seguinte conteúdo:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projeto_flutter/main.dart' as app;
import 'package:projeto_flutter/models/geo_point.dart';
import 'package:projeto_flutter/services/location_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Testes de Integração da API de Localização', () {
    testWidgets('Deve buscar endereço e exibir resultados', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa (onde está o componente de busca)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Verificar se a tela de formulário foi aberta
      expect(find.text('Nova Tarefa'), findsOneWidget);
      
      // Encontrar e tocar no botão de seleção de localização
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pumpAndSettle();
      
      // Verificar se o componente de busca de localização é exibido
      expect(find.text('Buscar endereço...'), findsOneWidget);
      
      // Digitar um endereço para busca
      await tester.enterText(find.byType(TextField).last, 'New York');
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Aguardar a resposta da API
      
      // Verificar se os resultados da busca são exibidos
      // Note: Este teste pode falhar se a API estiver indisponível ou mudar seu formato
      expect(find.textContaining('New York'), findsWidgets);
      
      // Selecionar o primeiro resultado
      await tester.tap(find.textContaining('New York').first);
      await tester.pumpAndSettle();
      
      // Verificar se voltamos para o formulário com a localização selecionada
      expect(find.text('Nova Tarefa'), findsOneWidget);
      expect(find.textContaining('Latitude:'), findsOneWidget);
      expect(find.textContaining('Longitude:'), findsOneWidget);
    });

    testWidgets('Deve abrir o mapa e selecionar localização', (WidgetTester tester) async {
      // Inicializar o aplicativo
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para a tela de criação de tarefa
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Tocar no botão para abrir o mapa
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      
      // Verificar se a tela do mapa foi aberta
      expect(find.text('Selecionar Localização'), findsOneWidget);
      
      // Simular um toque no mapa (coordenadas aproximadas do centro do mapa)
      // Nota: Esta parte pode variar dependendo de como seu mapa é implementado
      final mapFinder = find.byType(Scaffold);
      final center = tester.getCenter(mapFinder);
      await tester.tapAt(center);
      await tester.pumpAndSettle();
      
      // Confirmar a seleção da localização
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      
      // Verificar se voltamos para o formulário com a localização selecionada
      expect(find.text('Nova Tarefa'), findsOneWidget);
      expect(find.textContaining('Latitude:'), findsOneWidget);
      expect(find.textContaining('Longitude:'), findsOneWidget);
    });
  });
}
```

### 4.2 Executando os Testes de Integração

Execute os testes de integração com o seguinte comando:

```bash
flutter test integration_test/location_api_test.dart
```

## 5. Testando com API Real vs. Mock

### 5.1 Considerações para Testes com API Real

Os testes de integração acima usam a API real do OpenStreetMap, o que pode apresentar alguns desafios:

1. **Dependência de Conexão Internet**: Os testes falharão sem conexão à internet
2. **Limites de Taxa**: A API Nominatim tem limites de uso (1 requisição por segundo)
3. **Variação nos Resultados**: Os resultados da API podem mudar com o tempo
4. **Latência**: A API pode ter tempos de resposta variáveis

### 5.2 Configurando Testes com Mock para Integração

Para testes mais confiáveis e independentes da API real, você pode modificar o teste de integração para usar mocks:

```dart
// Adicione no início do arquivo integration_test/location_api_test.dart
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockLocationService extends Mock implements LocationService {}

void setupMockLocationService() {
  final mockService = MockLocationService();
  
  // Configurar respostas mock
  when(mockService.searchAddress('New York')).thenAnswer((_) async => [
    {
      'name': 'New York, United States',
      'latitude': 40.7127281,
      'longitude': -74.0060152,
    }
  ]);
  
  when(mockService.getAddressFromCoordinates(any)).thenAnswer((_) async => 
    'Endereço Simulado para Teste'
  );
  
  // Registrar o mock no sistema de injeção de dependência
  GetIt.instance.registerSingleton<LocationService>(mockService);
}

// E então no início do teste:
setUpAll(() {
  setupMockLocationService();
});
```

## 6. Solução de Problemas Comuns

### 6.1 Erros de Rede

**Problema**: Testes falham com erros de conexão à API

**Solução**:
- Verifique sua conexão com a internet
- Use mocks para testes que não dependam da API real
- Adicione tratamento de retry para falhas temporárias

### 6.2 Limites de Taxa Excedidos

**Problema**: A API retorna erro 429 (Too Many Requests)

**Solução**:
- Adicione delays entre requisições (pelo menos 1 segundo)
- Implemente cache local para reduzir o número de requisições
- Use mocks para testes automatizados

### 6.3 Resultados Inconsistentes

**Problema**: Os resultados da busca variam entre execuções

**Solução**:
- Use mocks com respostas fixas para testes automatizados
- Nos testes de integração, verifique apenas a presença de resultados, não seu conteúdo exato
- Implemente verificações mais flexíveis (ex: `expect(find.textContaining('New York'), findsWidgets)` em vez de `expect(find.text('New York, NY, United States'), findsOneWidget)`)

### 6.4 Problemas com Geocodificação Reversa

**Problema**: A conversão de coordenadas para endereços retorna resultados imprecisos

**Solução**:
- Verifique se as coordenadas estão no formato correto (latitude, longitude)
- Aumente o nível de zoom para obter resultados mais precisos
- Considere usar outras APIs de geocodificação para comparação

## 7. Boas Práticas para Testar APIs Externas

1. **Separação de Responsabilidades**: Mantenha o código de acesso à API em um serviço isolado para facilitar o mock
2. **Cache de Resultados**: Implemente cache local para reduzir o número de chamadas à API
3. **Tratamento de Erros Robusto**: Prepare-se para falhas de rede, limites de taxa e outros erros
4. **Testes Unitários com Mock**: Use mocks para testar a lógica de negócios sem depender da API real
5. **Testes de Integração Seletivos**: Use a API real apenas em testes de integração críticos
6. **Verificações Flexíveis**: Evite verificações muito rígidas que possam quebrar com pequenas mudanças na API
7. **Respeito aos Limites de Uso**: Adicione delays entre chamadas para respeitar os limites de taxa da API

## 8. Conclusão

Este guia fornece uma abordagem abrangente para testar a integração com a API OpenStreetMap/Nominatim no projeto. Seguindo estas práticas, você pode garantir que a funcionalidade de localização do aplicativo seja robusta e confiável, mesmo diante das incertezas inerentes ao uso de APIs externas.

Os testes implementados cobrem desde a unidade básica (o serviço de localização) até a integração completa (o fluxo do usuário), proporcionando alta confiança na qualidade da integração.

Lembre-se de que, ao trabalhar com APIs externas, é importante manter um equilíbrio entre testes automatizados (que devem usar mocks para serem confiáveis e rápidos) e testes manuais periódicos com a API real para garantir que a integração continue funcionando conforme esperado.
