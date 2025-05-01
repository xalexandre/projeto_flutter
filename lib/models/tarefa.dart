import 'package:flutter/material.dart';
import 'geo_point.dart';

class Tarefa {
  final String id;
  String nome;
  DateTime dataHora;
  GeoPoint? localizacao;
  bool concluida;

  Tarefa({
    required this.id,
    required this.nome,
    required this.dataHora,
    this.localizacao,
    this.concluida = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dataHora': dataHora.toIso8601String(),
      'localizacao': localizacao?.toJson(),
      'concluida': concluida,
    };
  }

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      nome: json['nome'],
      dataHora: DateTime.parse(json['dataHora']),
      localizacao: json['localizacao'] != null 
          ? GeoPoint.fromJson(json['localizacao']) 
          : null,
      concluida: json['concluida'] ?? false,
    );
  }
} 