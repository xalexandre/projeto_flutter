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

    test('getAddressFromCoordinates deve lidar com erro de API', () async {
      // Configurar resposta mock com erro
      when(mockClient.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=0.0&lon=0.0&format=json'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      // Executar o método
      final address = await locationService.getAddressFromCoordinates(
        GeoPoint(latitude: 0.0, longitude: 0.0)
      );

      // Verificar que retorna mensagem de erro
      expect(address, 'Erro ao buscar endereço');
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

      expect(locationService.isValidCoordinate(
        GeoPoint(latitude: 40.7127281, longitude: -200.0)
      ), isFalse);

      // Coordenadas nulas
      expect(locationService.isValidCoordinate(null), isFalse);
    });

    test('formatCoordinates deve formatar coordenadas corretamente', () {
      final formattedCoords = locationService.formatCoordinates(
        GeoPoint(latitude: 40.7127281, longitude: -74.0060152)
      );
      
      expect(formattedCoords, '40.712728, -74.006015');
    });

    test('getStaticMapUrl deve retornar URL válida para mapa estático', () {
      final mapUrl = locationService.getStaticMapUrl(
        GeoPoint(latitude: 40.7127281, longitude: -74.0060152),
        zoom: 15,
        width: 500,
        height: 300
      );
      
      expect(mapUrl, contains('staticmap.openstreetmap.de'));
      expect(mapUrl, contains('40.7127281,-74.0060152'));
      expect(mapUrl, contains('zoom=15'));
      expect(mapUrl, contains('size=500x300'));
      expect(mapUrl, contains('markers=40.7127281,-74.0060152,red'));
    });
  });
}
