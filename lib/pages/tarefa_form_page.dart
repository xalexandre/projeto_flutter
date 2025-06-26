import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/location_search.dart';
import '../models/tarefa.dart';
import '../models/geo_point.dart';
import '../pages/location_map_page.dart';
import '../services/location_service.dart';
import '../services/tarefa_service.dart';
import '../utils/responsive_util.dart';
import '../routes/app_navigator.dart';

class TarefaFormPage extends StatefulWidget {
  final Tarefa? tarefa;

  const TarefaFormPage({
    super.key,
    this.tarefa,
  });

  @override
  State<TarefaFormPage> createState() => _TarefaFormPageState();
}

class _TarefaFormPageState extends State<TarefaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late DateTime _dataHora;
  GeoPoint? _localizacao;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.tarefa?.nome ?? '');
    _dataHora = widget.tarefa?.dataHora ?? DateTime.now();
    _localizacao = widget.tarefa?.localizacao;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  final LocationService _locationService = LocationService();

  void _atualizarLocalizacao(GeoPoint localizacao) {
    setState(() {
      _localizacao = localizacao;
    });
  }
  
  void _abrirMapaSelecao() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationMapPage(
          title: 'Selecionar Localização',
          initialLocation: _localizacao,
          selectable: true,
          onLocationSelected: _atualizarLocalizacao,
        ),
      ),
    );
  }

  void _visualizarLocalizacaoNoMapa() {
    if (_localizacao == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationMapPage(
          title: 'Localização da Tarefa',
          initialLocation: _localizacao,
          selectable: false,
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final tarefaService = context.read<TarefaService>();
      final tarefa = Tarefa(
        id: widget.tarefa?.id ?? DateTime.now().toString(),
        nome: _nomeController.text,
        dataHora: _dataHora,
        localizacao: _localizacao,
      );
      
      if (widget.tarefa == null) {
        tarefaService.adicionarTarefa(tarefa);
      } else {
        tarefaService.atualizarTarefa(tarefa);
      }
      
      AppNavigator.goBack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Layout responsivo baseado na largura disponível
          final isWideScreen = constraints.maxWidth > 600;
          
          return SingleChildScrollView(
            padding: ResponsiveUtil.responsivePadding(context, all: 16),
            child: Center(
              child: Container(
                // Em telas maiores, limita a largura do formulário para melhor legibilidade
                constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 600 : double.infinity,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Tarefa',
                          prefixIcon: Icon(Icons.task),
                        ),
                        style: TextStyle(
                          fontSize: ResponsiveUtil.adaptiveFontSize(context, 16),
                        ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
                      SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 24)),
                      Card(
                        child: ListTile(
                          title: Text(
                            'Data e Hora',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.adaptiveFontSize(context, 16),
                            ),
                          ),
                  subtitle: Text(
                    '${_dataHora.day}/${_dataHora.month}/${_dataHora.year} ${_dataHora.hour}:${_dataHora.minute.toString().padLeft(2, '0')}',
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dataHora,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_dataHora),
                      );
                      if (time != null) {
                        setState(() {
                          _dataHora = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
                      SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 16)),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Localização',
                                style: TextStyle(
                                  fontSize: ResponsiveUtil.adaptiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_localizacao != null) ...[
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: FutureBuilder<String>(
                                    future: _locationService.getAddressFromCoordinates(_localizacao!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Text('Carregando endereço...');
                                      } else if (snapshot.hasError) {
                                        return Text('Erro: ${snapshot.error}');
                                      } else {
                                        return Text(
                                          snapshot.data ?? 'Endereço não encontrado',
                                          style: const TextStyle(fontWeight: FontWeight.normal),
                                        );
                                      }
                                    },
                                  ),
                                  subtitle: Text(
                                    _locationService.formatCoordinates(_localizacao!),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  leading: const Icon(Icons.location_on),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.map),
                                    onPressed: _visualizarLocalizacaoNoMapa,
                                    tooltip: 'Ver no mapa',
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => setState(() => _localizacao = null),
                                      child: const Text('Remover'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: _abrirMapaSelecao,
                                      child: const Text('Alterar'),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                SizedBox(
                                  height: 250,
                                  child: LocationSearch(
                                    onLocationSelected: _atualizarLocalizacao,
                                    initialLocation: _localizacao,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtil.adaptiveHeight(context, 32)),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save),
                        label: Text(
                          'Salvar',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.adaptiveFontSize(context, 16),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtil.adaptiveHeight(context, 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
