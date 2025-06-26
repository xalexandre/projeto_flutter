# Configuração do Firebase no Projeto Flutter

Para configurar o Firebase em um projeto Flutter, é necessário seguir os passos abaixo para cada plataforma suportada.

## Arquivos de Configuração

### Para Android:

1. **google-services.json**
   - Localização: `android/app/google-services.json`
   - Este arquivo é gerado pelo Firebase Console quando você registra seu aplicativo Android
   - Contém todas as chaves e identificadores necessários para conectar seu aplicativo aos serviços do Firebase

2. **build.gradle (nível do projeto)**
   - Localização: `android/build.gradle`
   - Adicionar o classpath do Google Services:
   ```gradle
   buildscript {
     repositories {
       google()
       // ...
     }
     dependencies {
       classpath 'com.android.tools.build:gradle:7.3.0'
       classpath 'com.google.gms:google-services:4.3.15'  // Plugin do Google Services
       classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9' // Para Crashlytics (opcional)
     }
   }
   ```

3. **build.gradle (nível do aplicativo)**
   - Localização: `android/app/build.gradle`
   - Aplicar o plugin do Google Services:
   ```gradle
   apply plugin: 'com.android.application'
   apply plugin: 'kotlin-android'
   apply plugin: 'com.google.gms.google-services'  // Plugin do Firebase
   apply plugin: 'com.google.firebase.crashlytics'  // Para Crashlytics (opcional)
   ```

4. **AndroidManifest.xml**
   - Localização: `android/app/src/main/AndroidManifest.xml`
   - Adicionar permissões necessárias:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   <!-- Para notificações -->
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   <uses-permission android:name="android.permission.VIBRATE" />
   <!-- Para geolocalização -->
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
   ```

### Para iOS:

1. **GoogleService-Info.plist**
   - Localização: `ios/Runner/GoogleService-Info.plist`
   - Este arquivo é gerado pelo Firebase Console quando você registra seu aplicativo iOS
   - Contém todas as chaves e identificadores necessários para conectar seu aplicativo aos serviços do Firebase

2. **Info.plist**
   - Localização: `ios/Runner/Info.plist`
   - Adicionar configurações para notificações:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>fetch</string>
       <string>remote-notification</string>
   </array>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Este aplicativo precisa de acesso à sua localização para notificar sobre tarefas próximas.</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>Este aplicativo precisa de acesso à sua localização em segundo plano para notificar sobre tarefas próximas mesmo quando não estiver em uso.</string>
   ```

3. **Podfile**
   - Localização: `ios/Podfile`
   - Adicionar a versão mínima do iOS:
   ```ruby
   platform :ios, '12.0'
   ```

### Para Web:

1. **index.html**
   - Localização: `web/index.html`
   - Adicionar os scripts do Firebase:
   ```html
   <body>
     <!-- Outros elementos -->
     
     <!-- Firebase Core -->
     <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app.js"></script>
     
     <!-- Firebase produtos que você quer usar -->
     <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth.js"></script>
     <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore.js"></script>
     <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-analytics.js"></script>
     <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging.js"></script>
     
     <!-- Inicializar Firebase -->
     <script>
       // Seu objeto de configuração do Firebase
       const firebaseConfig = {
         apiKey: "seu-api-key",
         authDomain: "seu-projeto.firebaseapp.com",
         projectId: "seu-projeto",
         storageBucket: "seu-projeto.appspot.com",
         messagingSenderId: "seu-messaging-sender-id",
         appId: "seu-app-id",
         measurementId: "seu-measurement-id"
       };
       
       // Initialize Firebase
       firebase.initializeApp(firebaseConfig);
       firebase.analytics();
     </script>
     
     <!-- Flutter -->
     <script src="main.dart.js" type="application/javascript"></script>
   </body>
   ```

## Como Obter os Arquivos de Configuração

### Passo a Passo:

1. **Crie um Projeto no Firebase Console**:
   - Acesse [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - Clique em "Adicionar projeto"
   - Siga as instruções para criar um novo projeto

2. **Registre seu Aplicativo Android**:
   - No console do Firebase, clique no ícone do Android
   - Digite o nome do pacote do seu aplicativo: `br.com.brodt.projeto_flutter`
   - (Opcional) Digite o apelido do aplicativo e o SHA-1
   - Baixe o arquivo `google-services.json`
   - Coloque o arquivo em `android/app/`

3. **Registre seu Aplicativo iOS**:
   - No console do Firebase, clique no ícone do iOS
   - Digite o Bundle ID do seu aplicativo (encontrado em `ios/Runner.xcodeproj/project.pbxproj`)
   - (Opcional) Digite o apelido do aplicativo
   - Baixe o arquivo `GoogleService-Info.plist`
   - Adicione o arquivo ao seu projeto iOS usando o Xcode (não apenas copie para a pasta)

4. **Registre seu Aplicativo Web**:
   - No console do Firebase, clique no ícone da Web
   - Digite um apelido para seu aplicativo web
   - (Opcional) Configure o Firebase Hosting
   - Copie o objeto de configuração do Firebase para seu arquivo `web/index.html`

## Configuração no Código Flutter

Após configurar os arquivos nativos, você precisa inicializar o Firebase no código Dart do seu aplicativo:

1. **Inicialização no main.dart**:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(MyApp());
   }
   ```

2. **Configuração para Web (opcional)**:
   Se você estiver usando o Firebase no Flutter Web, pode ser necessário fornecer as opções de configuração manualmente:
   ```dart
   await Firebase.initializeApp(
     options: const FirebaseOptions(
       apiKey: "seu-api-key",
       authDomain: "seu-projeto.firebaseapp.com",
       projectId: "seu-projeto",
       storageBucket: "seu-projeto.appspot.com",
       messagingSenderId: "seu-messaging-sender-id",
       appId: "seu-app-id",
       measurementId: "seu-measurement-id"
     ),
   );
   ```

## Verificação da Configuração

Para verificar se o Firebase está configurado corretamente:

1. Execute o aplicativo em um dispositivo ou emulador.
2. No console do Firebase, vá para a seção "Analytics" e verifique se eventos como "first_open" estão sendo registrados.
3. Tente usar algum serviço específico do Firebase (como autenticação) e verifique se funciona conforme esperado.

## Solução de Problemas Comuns

### Android:
- **Erro de versão do Google Play Services**: Certifique-se de que o emulador ou dispositivo tem uma versão recente do Google Play Services.
- **Erro de SHA-1**: Para funções como autenticação, certifique-se de adicionar a impressão digital SHA-1 no console do Firebase.

### iOS:
- **Erro de CocoaPods**: Execute `pod install` na pasta iOS se encontrar problemas com dependências.
- **Permissões**: Verifique se todas as permissões necessárias estão configuradas no `Info.plist`.

### Web:
- **CORS**: Verifique se há erros de CORS no console do navegador.
- **Scripts**: Certifique-se de que os scripts do Firebase estão sendo carregados na ordem correta.
