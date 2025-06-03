import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/tarefa_item.dart';
import 'tarefa_form_page.dart';
import '../models/tarefa.dart';
import '../services/tarefa_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _adicionarTarefa() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TarefaFormPage(),
      ),
    );
  }

  void _editarTarefa(Tarefa tarefa) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TarefaFormPage(tarefa: tarefa),
      ),
    );
  }

  void _excluirTarefa(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TarefaService>().removerTarefa(id);
              Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarTarefa,
          ),
        ],
      ),
      body: Consumer<TarefaService>(
        builder: (context, tarefaService, child) {
          if (tarefaService.tarefas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa cadastrada',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar uma nova tarefa',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarTarefa,
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
      ),
    );
  }
}
