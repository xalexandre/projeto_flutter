import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../models/geo_point.dart';
import '../services/tarefa_service.dart';
import '../utils/responsive_util.dart';

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

  Future<void> _obterLocalizacaoAtual() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço de localização desativado')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de localização permanentemente negada')),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _localizacao = GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao obter localização')),
      );
    }
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
      
      Navigator.of(context).pop();
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
                        child: ListTile(
                          title: Text(
                            'Localização',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.adaptiveFontSize(context, 16),
                            ),
                          ),
                  subtitle: Text(
                    _localizacao == null
                        ? 'Nenhuma localização definida'
                        : '${_localizacao!.latitude.toStringAsFixed(4)}, ${_localizacao!.longitude.toStringAsFixed(4)}',
                  ),
                  leading: const Icon(Icons.location_on),
                  onTap: _obterLocalizacaoAtual,
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
