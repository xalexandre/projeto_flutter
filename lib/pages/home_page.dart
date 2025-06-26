import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/tarefa_item.dart';
import '../models/tarefa.dart';
import '../services/tarefa_service.dart';
import '../services/auth_service.dart';
import '../utils/responsive_util.dart';
import '../routes/app_navigator.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _adicionarTarefa() {
    AppNavigator.navigateToTarefaForm(context);
  }
  
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _editarTarefa(Tarefa tarefa) {
    AppNavigator.navigateToTarefaEdit(context, tarefa);
  }

  void _excluirTarefa(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.goBack(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TarefaService>().removerTarefa(id);
              AppNavigator.goBack(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveUtil.isTablet(context);
    final isLandscape = ResponsiveUtil.isLandscape(context);
    final columnCount = isTablet 
        ? (isLandscape ? 3 : 2) 
        : (isLandscape ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarTarefa,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: _buildBody(context, theme, columnCount, isTablet, isLandscape),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarTarefa,
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, int columnCount, bool isTablet, bool isLandscape) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<TarefaService>(
          builder: (context, tarefaService, child) {
            if (tarefaService.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (tarefaService.erro != null) {
              return _buildErrorMessage(context, theme, tarefaService.erro!);
            }
            
            if (tarefaService.tarefas.isEmpty) {
              return _buildEmptyMessage(context, theme);
            }
            
            return _buildTarefasList(context, tarefaService, columnCount, isTablet, isLandscape);
          },
        );
      },
    );
  }

  Widget _buildErrorMessage(BuildContext context, ThemeData theme, String erro) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtil.adaptiveWidth(context, 64),
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 16)),
          Text(
            'Erro ao carregar tarefas',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontSize: ResponsiveUtil.adaptiveFontSize(context, 18),
            ),
          ),
          SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 8)),
          Text(
            erro,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: ResponsiveUtil.adaptiveWidth(context, 64),
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 16)),
          Text(
            'Nenhuma tarefa cadastrada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: ResponsiveUtil.adaptiveFontSize(context, 18),
            ),
          ),
          SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 8)),
          Text(
            'Toque no botão + para adicionar uma nova tarefa',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: ResponsiveUtil.adaptiveFontSize(context, 14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTarefasList(BuildContext context, TarefaService tarefaService, 
      int columnCount, bool isTablet, bool isLandscape) {
    
    if (columnCount > 1) {
      return GridView.builder(
        padding: ResponsiveUtil.responsivePadding(context, all: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: isLandscape ? 1.8 : 1.5,
          crossAxisSpacing: ResponsiveUtil.adaptiveWidth(context, 8),
          mainAxisSpacing: ResponsiveUtil.adaptiveHeight(context, 8),
        ),
        itemCount: tarefaService.tarefas.length,
        itemBuilder: (context, index) {
          final tarefa = tarefaService.tarefas[index];
          return TarefaItem(
            tarefa: tarefa,
            onEditar: _editarTarefa,
            onExcluir: _excluirTarefa,
          );
        },
      );
    }
    
    // ListView para telefones em modo retrato
    return ListView.builder(
      padding: ResponsiveUtil.responsivePadding(context, vertical: 8),
      itemCount: tarefaService.tarefas.length,
      itemBuilder: (context, index) {
        final tarefa = tarefaService.tarefas[index];
        return TarefaItem(
          tarefa: tarefa,
          onEditar: _editarTarefa,
          onExcluir: _excluirTarefa,
        );
      },
    );
  }
}
