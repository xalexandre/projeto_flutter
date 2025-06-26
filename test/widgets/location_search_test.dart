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
    
    testWidgets('deve mostrar mensagem quando não há resultados', (WidgetTester tester) async {
      // Configurar mock para retornar lista vazia
      when(mockLocationService.searchAddress('NonExistentPlace')).thenAnswer((_) async => []);
      
      // Renderizar o widget
      await tester.pumpWidget(createLocationSearch());
      
      // Digitar no campo de busca
      await tester.enterText(find.byType(TextField), 'NonExistentPlace');
      await tester.pumpAndSettle(); // Aguardar animações
      
      // Verificar se a mensagem de "Nenhum resultado encontrado" é exibida
      expect(find.text('Nenhum resultado encontrado'), findsOneWidget);
    });
    
    testWidgets('deve mostrar indicador de carregamento durante busca', (WidgetTester tester) async {
      // Configurar mock para retornar após um delay
      when(mockLocationService.searchAddress('New York')).thenAnswer((_) async {
        // Simular delay da requisição
        await Future.delayed(const Duration(milliseconds: 100));
        return [
          {
            'name': 'New York, United States',
            'latitude': 40.7127281,
            'longitude': -74.0060152,
          }
        ];
      });
      
      // Renderizar o widget
      await tester.pumpWidget(createLocationSearch());
      
      // Digitar no campo de busca
      await tester.enterText(find.byType(TextField), 'New York');
      await tester.pump(); // Atualizar sem esperar o futuro completar
      
      // Verificar se o indicador de carregamento é exibido
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Aguardar a conclusão da busca
      await tester.pumpAndSettle();
      
      // Verificar se o indicador de carregamento desapareceu
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      // Verificar se os resultados são exibidos
      expect(find.text('New York, United States'), findsOneWidget);
    });
    
    testWidgets('deve limpar resultados quando campo de busca é limpo', (WidgetTester tester) async {
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
      
      // Limpar o campo de busca
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      
      // Verificar se os resultados foram limpos
      expect(find.text('New York, United States'), findsNothing);
    });
  });
}
