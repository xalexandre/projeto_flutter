import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';
import 'services/tarefa_service.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TarefaService>(
      create: (_) => TarefaService(),
      child: MaterialApp(
        title: 'Gerenciador de Tarefas',
        theme: AppTheme.lightTheme,
        home: const HomePage(),
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
