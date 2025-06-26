# Integração com API Externa - OpenStreetMap (Nominatim)

## Visão Geral

O projeto foi integrado com a API de geocodificação Nominatim do OpenStreetMap para fornecer funcionalidades de localização mais avançadas. Esta integração permite:

1. Buscar endereços por nome e obter suas coordenadas geográficas
2. Fazer geocodificação reversa (converter coordenadas em endereços legíveis)
3. Visualizar tarefas em um mapa interativo
4. Selecionar localizações diretamente no mapa

## Componentes Implementados

### 1. Serviço de Localização

Um novo serviço `LocationService` foi criado para encapsular todas as interações com a API Nominatim:

```dart
class LocationService {
  // Métodos principais:
  Future<List<Map<String, dynamic>>> searchAddress(String query) async {...}
  Future<String> getAddressFromCoordinates(GeoPoint coordinates) async {...}
  String getStaticMapUrl(GeoPoint coordinates, {...}) {...}
  bool isValidCoordinate(GeoPoint? coordinates) {...}
  String formatCoordinates(GeoPoint coordinates) {...}
}
```

### 2. Página de Mapa

A nova página `LocationMapPage` permite visualizar e selecionar localizações em um mapa interativo:

```dart
class LocationMapPage extends StatefulWidget {
  final GeoPoint? initialLocation;
  final String title;
  final bool selectable;
  final Function(GeoPoint)? onLocationSelected;
  ...
}
```

### 3. Componente de Busca de Localização

O componente `LocationSearch` permite buscar endereços por nome e selecionar localizações:

```dart
class LocationSearch extends StatefulWidget {
  final Function(GeoPoint) onLocationSelected;
  final GeoPoint? initialLocation;
  ...
}
```

### 4. Integrações na Interface

- **Formulário de Tarefa**: Agora inclui busca de endereços e seleção de localização no mapa
- **Item de Tarefa**: Exibe a localização e permite visualizá-la no mapa
- **Sistema de Rotas**: Adicionada rota para a página de mapa

## Fluxos de Usuário

### 1. Adicionar Localização a uma Tarefa

1. O usuário abre o formulário de criação/edição de tarefa
2. No campo de localização, o usuário pode:
   - Buscar um endereço por nome
   - Usar sua localização atual (com permissão)
   - Selecionar uma localização diretamente no mapa
3. Após selecionar a localização, ela é exibida no formulário com suas coordenadas
4. O usuário pode remover ou alterar a localização antes de salvar a tarefa

### 2. Visualizar Localização de uma Tarefa

1. Na lista de tarefas, as tarefas com localização exibem suas coordenadas
2. O usuário pode clicar no ícone do mapa ao lado das coordenadas
3. Alternativamente, o usuário pode selecionar "Ver no mapa" no menu de opções da tarefa
4. O aplicativo abre a página do mapa mostrando a localização da tarefa

## Implementação Técnica

### Dependências Adicionadas

```yaml
dependencies:
  http: ^1.4.0              # Para chamadas HTTP à API
  flutter_map: ^8.1.1       # Implementação do mapa OpenStreetMap para Flutter
  latlong2: ^0.9.1          # Para manipulação de coordenadas geográficas
```

### Detalhes da API Nominatim

- **Base URL**: https://nominatim.openstreetmap.org
- **Endpoints**:
  - `/search`: Busca de endereços por nome (geocodificação)
  - `/reverse`: Conversão de coordenadas em endereços (geocodificação reversa)
- **Headers Necessários**:
  - `User-Agent`: Identificação do aplicativo (requisito da API)
  - `Accept`: Formato de resposta (JSON)
- **Limites de Uso**:
  - Máximo de 1 requisição por segundo
  - Uso justo sem necessidade de chave de API para aplicações de pequeno porte

### Considerações sobre a API

1. **Política de Uso Justo**: A API Nominatim tem uma política de uso justo que limita a quantidade de requisições. Para aplicações com grande volume de usuários, seria recomendável:
   - Implementar cache local de resultados frequentes
   - Considerar hospedar uma instância própria do Nominatim
   - Ou migrar para uma API comercial como Google Maps ou Mapbox

2. **Privacidade**: A API não armazena informações pessoais dos usuários, mas é importante informar os usuários sobre o envio de suas coordenadas para o serviço OpenStreetMap.

3. **Disponibilidade Offline**: A implementação atual não suporta uso offline. Para adicionar suporte offline, seria necessário:
   - Implementar cache local de mapas e resultados de busca
   - Considerar usar pacotes como `mapsforge` para renderização offline

## Melhorias Futuras

1. **Clustering de Tarefas**: Agrupar tarefas próximas no mapa quando há muitas em uma área pequena.

2. **Rotas e Navegação**: Adicionar funcionalidade para calcular rotas entre tarefas e fornecer navegação.

3. **Geofencing**: Notificar o usuário quando estiver próximo do local de uma tarefa.

4. **Compartilhamento de Localização**: Permitir compartilhar a localização de uma tarefa com outros usuários.

5. **Integração com Outras APIs**:
   - Previsão do tempo para o local da tarefa
   - Informações sobre estabelecimentos próximos
   - Transporte público para chegar ao local

## Conclusão

A integração com a API Nominatim do OpenStreetMap aprimorou significativamente as funcionalidades de localização do aplicativo, permitindo aos usuários associar tarefas a locais específicos e visualizá-los em um mapa interativo. Esta funcionalidade é especialmente útil para tarefas que precisam ser realizadas em locais específicos, como compras, reuniões ou visitas.

A implementação atual é robusta e atende bem às necessidades básicas de um gerenciador de tarefas com funcionalidades de localização, mantendo-se dentro dos limites de uso justo da API Nominatim.
