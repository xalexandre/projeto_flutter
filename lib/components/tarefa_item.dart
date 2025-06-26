import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../pages/location_map_page.dart';
import '../services/location_service.dart';
import '../services/tarefa_service.dart';
import '../utils/responsive_util.dart';

class TarefaItem extends StatelessWidget {
  final Tarefa tarefa;
  final Function(Tarefa) onEditar;
  final Function(String) onExcluir;

  const TarefaItem({
    super.key,
    required this.tarefa,
    required this.onEditar,
    required this.onExcluir,
  });
  
  void _visualizarLocalizacaoNoMapa(BuildContext context) {
    if (tarefa.localizacao == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationMapPage(
          title: 'Localização: ${tarefa.nome}',
          initialLocation: tarefa.localizacao,
          selectable: false,
        ),
      ),
    );
  }
  
  String _formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConcluida = tarefa.concluida;

    // Determinar o estilo baseado no tamanho da tela
    final isTablet = ResponsiveUtil.isTablet(context);
    final isLandscape = ResponsiveUtil.isLandscape(context);
    
    return Card(
      margin: ResponsiveUtil.responsivePadding(
        context, 
        horizontal: 16, 
        vertical: 8,
      ),
      child: InkWell(
        onTap: () => onEditar(tarefa),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(
            minHeight: isTablet ? 120 : 100,
          ),
          child: Padding(
            padding: ResponsiveUtil.responsivePadding(context, all: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determinar o estilo baseado no espaço disponível
                final isVeryConstrained = constraints.maxHeight < 100 || constraints.maxWidth < 200;
                final isExtremelyConstrained = constraints.maxHeight < 80 || constraints.maxWidth < 150;
                
                // Em casos extremos, mostrar apenas as informações essenciais
                if (isExtremelyConstrained) {
                  return Row(
                    children: [
                      Checkbox(
                        value: isConcluida,
                        onChanged: (value) => context.read<TarefaService>()
                            .marcarComoConcluida(tarefa.id, value ?? false),
                        visualDensity: VisualDensity.compact,
                      ),
                      Expanded(
                        child: Text(
                          tarefa.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: ResponsiveUtil.adaptiveFontSize(context, 14),
                            decoration: isConcluida ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isConcluida,
                          onChanged: (value) => context.read<TarefaService>()
                              .marcarComoConcluida(tarefa.id, value ?? false),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          visualDensity: isVeryConstrained ? VisualDensity.compact : null,
                        ),
                        Expanded(
                          child: Text(
                            tarefa.nome,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: isConcluida ? TextDecoration.lineThrough : null,
                              color: isConcluida ? theme.colorScheme.outline : null,
                              fontSize: ResponsiveUtil.adaptiveFontSize(context, isVeryConstrained ? 14 : 16),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: isVeryConstrained ? 1 : 2,
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: isVeryConstrained ? 20 : 24,
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
                            if (tarefa.localizacao != null)
                              PopupMenuItem(
                                value: 'map',
                                child: Row(
                                  children: [
                                    Icon(Icons.map, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 8),
                                    const Text('Ver no mapa'),
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
                            } else if (value == 'map') {
                              _visualizarLocalizacaoNoMapa(context);
                            } else if (value == 'delete') {
                              onExcluir(tarefa.id);
                            }
                          },
                        ),
                      ],
                    ),
                    // Espaçamento adaptativo
                    if (!isVeryConstrained) 
                      SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 4)),
                    // Informações de data compactas
                    SizedBox(
                      height: isVeryConstrained ? 16 : 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: ResponsiveUtil.adaptiveWidth(context, isVeryConstrained ? 12 : 16),
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: ResponsiveUtil.adaptiveWidth(context, 4)),
                          Expanded(
                            child: Text(
                              '${tarefa.dataHora.day}/${tarefa.dataHora.month}/${tarefa.dataHora.year} ${tarefa.dataHora.hour}:${tarefa.dataHora.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: ResponsiveUtil.adaptiveFontSize(context, isVeryConstrained ? 10 : 12),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Localização apenas se houver espaço suficiente
                    if (!isVeryConstrained && tarefa.localizacao != null) ...[
                      SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 4)),
                      SizedBox(
                        height: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: ResponsiveUtil.adaptiveWidth(context, 16),
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: ResponsiveUtil.adaptiveWidth(context, 4)),
                            Expanded(
                              child: Text(
                                _formatCoordinates(tarefa.localizacao!.latitude, tarefa.localizacao!.longitude),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: ResponsiveUtil.adaptiveFontSize(context, 12),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.map_outlined),
                              iconSize: 16,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Ver no mapa',
                              onPressed: () => _visualizarLocalizacaoNoMapa(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
