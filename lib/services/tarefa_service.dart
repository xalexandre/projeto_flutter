import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class TarefaService extends ChangeNotifier {
  final List<Tarefa> _tarefas = [];

  List<Tarefa> get tarefas => _tarefas;

  void adicionarTarefa(Tarefa tarefa) {
    _tarefas.add(tarefa);
    notifyListeners();
  }

  void atualizarTarefa(Tarefa tarefa) {
    final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
    if (index != -1) {
      _tarefas[index] = tarefa;
      notifyListeners();
    }
  }

  void removerTarefa(String id) {
    _tarefas.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void marcarComoConcluida(String id, bool concluida) {
    final index = _tarefas.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tarefas[index].concluida = concluida;
      notifyListeners();
    }
  }
} 