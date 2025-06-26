# Integração com APIs do Dispositivo - Notificações e Geolocalização

## Visão Geral

Este documento descreve a integração do aplicativo com duas APIs nativas importantes do dispositivo:

1. **API de Notificações**: Para enviar notificações locais ao usuário
2. **API de Geolocalização**: Para monitorar a localização do usuário em relação às tarefas

Estas integrações melhoram significativamente a experiência do usuário ao fornecer lembretes contextuais baseados em localização e tempo.

## API de Notificações

### Funcionalidades Implementadas

- **Notificações baseadas em localização**: Alertam o usuário quando ele está próximo do local de uma tarefa
- **Notificações de conclusão**: Parabenizam o usuário quando uma tarefa é marcada como concluída
- **Notificações informativas**: Informam o usuário sobre alterações em tarefas com localização

### Implementação Técnica

A integração foi realizada através do pacote `flutter_local_notifications`, que fornece uma interface unificada para o sistema de notificações em diferentes plataformas:

```dart
final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

// Inicialização do plugin com configurações específicas para Android e iOS
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
);
```

### Permissões Necessárias

Para utilizar a API de notificações, foram adicionadas as seguintes permissões:

**Android (AndroidManifest.xml)**:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

**iOS (Info.plist)**:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### Tipos de Notificações

1. **Notificações de Proximidade**:
   - Enviadas quando o usuário está a menos de 500 metros de uma tarefa com localização
   - Incluem o nome da tarefa e opção para visualizá-la

2. **Notificações de Conclusão**:
   - Enviadas quando o usuário marca uma tarefa como concluída
   - Fornecem feedback positivo e reforço para o usuário

3. **Notificações Informativas**:
   - Enviadas quando uma tarefa recebe ou tem sua localização alterada
   - Informam o usuário sobre o monitoramento de proximidade

## API de Geolocalização

### Funcionalidades Implementadas

- **Monitoramento de proximidade**: Verifica periodicamente se o usuário está próximo de locais associados a tarefas
- **Cálculo de distância**: Determina a distância entre o usuário e os locais das tarefas
- **Verificação em segundo plano**: Continua monitorando mesmo quando o aplicativo não está em primeiro plano

### Implementação Técnica

A integração foi realizada através do pacote `geolocator`, que fornece acesso à API de geolocalização do dispositivo:

```dart
// Obter localização atual
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);

// Calcular distância entre dois pontos
final distance = Geolocator.distanceBetween(
  position.latitude,
  position.longitude,
  tarefa.localizacao!.latitude,
  tarefa.localizacao!.longitude,
);
```

### Permissões Necessárias

Para utilizar a API de geolocalização, foram adicionadas as seguintes permissões:

**Android (AndroidManifest.xml)**:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**iOS (Info.plist)**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este aplicativo precisa de acesso à sua localização para notificar sobre tarefas próximas.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Este aplicativo precisa de acesso à sua localização em segundo plano para notificar sobre tarefas próximas mesmo quando não estiver em uso.</string>
```

### Monitoramento em Segundo Plano

Para permitir o monitoramento contínuo da localização do usuário em relação às tarefas, implementamos um sistema de verificação periódica:

```dart
// Iniciar verificação periódica
_locationCheckTimer = Timer.periodic(
  const Duration(minutes: 5),
  (_) => _checkNearbyTasks(),
);
```

Este timer verifica a cada 5 minutos se o usuário está próximo de alguma tarefa com localização. Quando a distância é menor que 500 metros, uma notificação é enviada.

## Integração entre Serviços

### Fluxo de Trabalho

A integração entre o serviço de tarefas e as APIs de notificação e geolocalização segue o seguinte fluxo:

1. Quando uma tarefa é criada ou editada com uma localização:
   - A localização é armazenada no modelo `Tarefa`
   - A tarefa é adicionada ao monitoramento de proximidade
   - Uma notificação informativa é exibida ao usuário

2. Periodicamente, o aplicativo:
   - Obtém a localização atual do usuário
   - Calcula a distância para cada tarefa monitorada
   - Envia notificações para tarefas próximas

3. Quando uma tarefa é concluída:
   - Uma notificação de parabéns é exibida
   - A tarefa é removida do monitoramento de proximidade

### Classe `NotificationService`

Esta classe centraliza toda a lógica relacionada a notificações e monitoramento de localização:

```dart
class NotificationService {
  // Métodos principais
  Future<void> initialize() async {...}
  Future<bool> requestPermissions() async {...}
  void addTaskForLocationMonitoring(Tarefa tarefa) {...}
  void removeTaskFromLocationMonitoring(String tarefaId) {...}
  Future<void> _checkNearbyTasks() async {...}
  Future<void> showSimpleNotification({...}) async {...}
}
```

## Considerações e Melhorias

### Consumo de Bateria

O monitoramento de localização em segundo plano pode ter um impacto significativo na duração da bateria do dispositivo. Para mitigar esse problema:

1. Utilizamos um intervalo de verificação relativamente longo (5 minutos)
2. A precisão da localização é ajustada conforme necessário
3. O monitoramento é interrompido para tarefas concluídas

### Privacidade do Usuário

A coleta de dados de localização é uma questão sensível em termos de privacidade. Nosso aplicativo:

1. Solicita explicitamente permissão para acessar a localização
2. Explica claramente o propósito da coleta de localização
3. Não compartilha dados de localização com serviços externos
4. Permite que o usuário desative o monitoramento de localização

### Melhorias Futuras

1. **Geofencing nativo**: Substituir nossa implementação atual por APIs de geofencing nativas, que são mais eficientes em termos de bateria e precisão:
   - `GeofencingClient` no Android
   - `CLLocationManager` com `startMonitoring(for:)` no iOS

2. **Ajuste dinâmico da frequência**: Modificar a frequência de verificação com base em:
   - Distância até a tarefa mais próxima
   - Padrões de movimento do usuário
   - Nível de bateria do dispositivo

3. **Notificações agendadas**: Implementar lembretes baseados em data/hora para complementar as notificações baseadas em localização

4. **Análise de padrões**: Sugerir localizações com base no histórico de uso e padrões de movimento do usuário

5. **Modo offline**: Armazenar em cache os dados de mapa para permitir a visualização de localizações mesmo sem conexão com a internet

## Conclusão

A integração com as APIs de notificações e geolocalização do dispositivo transformou nosso gerenciador de tarefas em uma ferramenta contextualmente consciente, capaz de fornecer lembretes no momento e local certos. Estas funcionalidades aumentam significativamente a utilidade do aplicativo, tornando-o mais proativo e útil para o usuário.

Ao mesmo tempo, implementamos essas funcionalidades com atenção ao consumo de bateria e às preocupações de privacidade, garantindo uma experiência de usuário equilibrada.
