import 'package:flutter/material.dart';
import '../models/geo_point.dart';
import '../models/tarefa.dart';
import '../pages/home_page.dart';
import '../pages/location_map_page.dart';
import '../pages/tarefa_form_page.dart';
import '../pages/login_page.dart';
import 'app_routes.dart';

/// Classe responsável por gerar rotas baseadas no nome da rota
/// 
/// Esta classe centraliza a lógica de criação de rotas e manipulação
/// de argumentos, facilitando a manutenção e expansão do sistema de rotas.
class AppRouteGenerator {
  /// Gera uma rota com base no nome da rota e seus argumentos
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Obter os argumentos passados para a rota
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      
      case AppRoutes.tarefaForm:
        // Verificar se há argumentos (para edição de tarefa)
        if (args is Tarefa) {
          return MaterialPageRoute(
            builder: (_) => TarefaFormPage(tarefa: args),
          );
        }
        // Sem argumentos (para criação de tarefa)
        return MaterialPageRoute(
          builder: (_) => const TarefaFormPage(),
        );
      
      // Para rotas futuras que serão implementadas
      case AppRoutes.tarefaDetalhes:
        if (args is Tarefa) {
          // Aqui seria implementada a página de detalhes da tarefa
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Detalhes da Tarefa')),
              body: Center(child: Text('Detalhes da tarefa: ${args.nome}')),
            ),
          );
        }
        return _errorRoute();
      
      case AppRoutes.locationMap:
        if (args is Map<String, dynamic>) {
          final GeoPoint? location = args['location'] as GeoPoint?;
          final String title = args['title'] as String? ?? 'Mapa';
          final bool selectable = args['selectable'] as bool? ?? false;
          final Function(GeoPoint)? onLocationSelected = args['onLocationSelected'] as Function(GeoPoint)?;
          
          return MaterialPageRoute(
            builder: (_) => LocationMapPage(
              initialLocation: location,
              title: title,
              selectable: selectable,
              onLocationSelected: onLocationSelected,
            ),
          );
        }
        return _errorRoute();
        
      case AppRoutes.configuracoes:
        // Aqui seria implementada a página de configurações
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Configurações')),
            body: const Center(child: Text('Página de configurações')),
          ),
        );
      
      default:
        // Rota não encontrada
        return _errorRoute();
    }
  }

  /// Rota de erro para quando uma rota não é encontrada
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
        ),
        body: const Center(
          child: Text('Rota não encontrada'),
        ),
      ),
    );
  }
}
