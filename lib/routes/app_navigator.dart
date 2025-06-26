import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import 'app_routes.dart';

/// Classe utilitária para centralizar a navegação do aplicativo.
/// 
/// Fornece métodos para navegar entre as diferentes telas do aplicativo
/// usando rotas nomeadas, facilitando a manutenção e consistência.
class AppNavigator {
  /// Navega para a página inicial
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  /// Navega para o formulário de criação de tarefa
  static void navigateToTarefaForm(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.tarefaForm);
  }

  /// Navega para o formulário de edição de tarefa
  static void navigateToTarefaEdit(BuildContext context, Tarefa tarefa) {
    Navigator.of(context).pushNamed(
      AppRoutes.tarefaForm,
      arguments: tarefa,
    );
  }

  /// Volta para a tela anterior
  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Navega para a tela de detalhes da tarefa (para implementação futura)
  static void navigateToTarefaDetalhes(BuildContext context, Tarefa tarefa) {
    Navigator.of(context).pushNamed(
      AppRoutes.tarefaDetalhes,
      arguments: tarefa,
    );
  }

  /// Navega para a tela de configurações (para implementação futura)
  static void navigateToConfiguracoes(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.configuracoes);
  }
}
