import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/tarefa_service.dart';
import 'services/firebase_service.dart';
import 'routes/app_routes.dart';
import 'routes/app_route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase Service (que inicializa Core, Analytics e Messaging)
  await FirebaseService().initialize();
  
  // Permite que o aplicativo suporte ambas as orientações
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // Usar o FirebaseService para acessar o Analytics
  static FirebaseAnalytics get analytics => FirebaseService().analytics;
  static FirebaseAnalyticsObserver get observer => FirebaseService().observer;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProxyProvider<AuthService, TarefaService>(
          create: (_) => TarefaService(),
          update: (_, authService, tarefaService) => tarefaService ?? TarefaService(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Gerenciador de Tarefas',
            theme: AppTheme.lightTheme,
            initialRoute: authService.isAuthenticated ? AppRoutes.home : AppRoutes.login,
            onGenerateRoute: AppRouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [observer], // Adiciona o observer do Analytics
            // Adicionando suporte a responsividade para diferentes tipos de telas
            builder: (context, child) {
              // Aplicar escala de texto acessível a todo o aplicativo
              return MediaQuery(
                // Evita que a fonte seja afetada pelas configurações de acessibilidade do sistema
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
/*class HomePage extends StatefulWidget {
   const HomePage({super.key});

   @override
   State<HomePage> createState() => _HomePageState();
 }

 class _HomePageState extends State<HomePage> {
   int _counter = 0;
   void _incrementCounter() {
     setState(() {
       _counter++;
     });
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
         title: Text("Planejador de Compras"),
       ),
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             const Text('You have pushed the button this many times:'),
             Text(
               '$_counter',
               style: Theme.of(context).textTheme.headlineMedium,
             ),
           ],
         ),
       ),
       floatingActionButton: FloatingActionButton(
         onPressed: _incrementCounter,
         tooltip: 'Increment',
         child: const Icon(Icons.add),
       ),
     );
   }
 }*/
