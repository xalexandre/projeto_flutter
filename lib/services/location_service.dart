import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projeto_flutter/models/geo_point.dart';

/// Serviço para interagir com a API de geocodificação do OpenStreetMap (Nominatim)
class LocationService {
  // Base URL da API Nominatim do OpenStreetMap
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  // Headers necessários para a API
  static final Map<String, String> _headers = {
    'User-Agent': 'TarefasApp/1.0', // Identificação do app para a API
    'Accept': 'application/json',
  };

  /// Busca endereços por nome ou termos de pesquisa
  /// 
  /// Retorna uma lista de resultados com nome e coordenadas
  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    final encodedQuery = Uri.encodeComponent(query);
    final url = '$_baseUrl/search?q=$encodedQuery&format=json&limit=5&addressdetails=1';
    
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((item) => {
          'name': item['display_name'] ?? 'Endereço desconhecido',
          'latitude': double.tryParse(item['lat']) ?? 0.0,
          'longitude': double.tryParse(item['lon']) ?? 0.0,
        }).toList();
      } else {
        print('Erro na busca de endereço: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exceção na busca de endereço: $e');
      return [];
    }
  }

  /// Converte coordenadas em um endereço legível (geocodificação reversa)
  /// 
  /// Retorna uma string formatada com o endereço
  Future<String> getAddressFromCoordinates(GeoPoint coordinates) async {
    final url = '$_baseUrl/reverse?lat=${coordinates.latitude}&lon=${coordinates.longitude}&format=json';
    
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Endereço desconhecido';
      } else {
        print('Erro na geocodificação reversa: ${response.statusCode}');
        return 'Endereço não encontrado';
      }
    } catch (e) {
      print('Exceção na geocodificação reversa: $e');
      return 'Erro ao buscar endereço';
    }
  }
  
  /// Obtém uma URL para um mapa estático mostrando a localização
  String getStaticMapUrl(GeoPoint coordinates, {int zoom = 16, int width = 600, int height = 400}) {
    return 'https://staticmap.openstreetmap.de/staticmap.php?center=${coordinates.latitude},${coordinates.longitude}&zoom=$zoom&size=${width}x$height&markers=${coordinates.latitude},${coordinates.longitude},red';
  }
  
  /// Verifica se as coordenadas são válidas
  bool isValidCoordinate(GeoPoint? coordinates) {
    if (coordinates == null) return false;
    
    // Verifica se as coordenadas estão dentro dos limites válidos
    return coordinates.latitude >= -90 && coordinates.latitude <= 90 &&
           coordinates.longitude >= -180 && coordinates.longitude <= 180;
  }
  
  /// Formata as coordenadas para exibição
  String formatCoordinates(GeoPoint coordinates) {
    return '${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';
  }
}
