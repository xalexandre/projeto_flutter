import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class TarefaItem extends StatelessWidget {
  final Tarefa tarefa;
  final Function(Tarefa) onEditar;
  final Function(String) onExcluir;
  final Function(String, bool) onConcluir;

  const TarefaItem({
    super.key,
    required this.tarefa,
    required this.onEditar,
    required this.onExcluir,
    required this.onConcluir,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConcluida = tarefa.concluida;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => onEditar(tarefa),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isConcluida,
                    onChanged: (value) => onConcluir(tarefa.id, value ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tarefa.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: isConcluida ? TextDecoration.lineThrough : null,
                        color: isConcluida ? theme.colorScheme.outline : null,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            const Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEditar(tarefa);
                      } else if (value == 'delete') {
                        onExcluir(tarefa.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${tarefa.dataHora.day}/${tarefa.dataHora.month}/${tarefa.dataHora.year} ${tarefa.dataHora.hour}:${tarefa.dataHora.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (tarefa.localizacao != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${tarefa.localizacao!.latitude.toStringAsFixed(4)}, ${tarefa.localizacao!.longitude.toStringAsFixed(4)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 