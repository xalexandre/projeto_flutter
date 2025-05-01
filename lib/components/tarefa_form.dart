import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tarefa.dart';
import '../models/geo_point.dart';

class TarefaForm extends StatefulWidget {
  final Tarefa? tarefa;
  final Function(Tarefa) onSubmit;

  const TarefaForm({
    super.key,
    this.tarefa,
    required this.onSubmit,
  });

  @override
  State<TarefaForm> createState() => _TarefaFormState();
}

class _TarefaFormState extends State<TarefaForm> {
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
      final tarefa = Tarefa(
        id: widget.tarefa?.id ?? DateTime.now().toString(),
        nome: _nomeController.text,
        dataHora: _dataHora,
        localizacao: _localizacao,
      );
      widget.onSubmit(tarefa);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  title: const Text('Data e Hora'),
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
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Localização'),
                  subtitle: Text(
                    _localizacao == null
                        ? 'Nenhuma localização definida'
                        : '${_localizacao!.latitude.toStringAsFixed(4)}, ${_localizacao!.longitude.toStringAsFixed(4)}',
                  ),
                  leading: const Icon(Icons.location_on),
                  onTap: _obterLocalizacaoAtual,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 