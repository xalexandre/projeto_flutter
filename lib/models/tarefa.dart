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
  
  /// Alias para toJson para compatibilidade com Firestore
  Map<String, dynamic> toMap() => toJson();
  
  /// Alias para fromJson para compatibilidade com Firestore
  static Tarefa fromMap(Map<String, dynamic> map) => Tarefa.fromJson(map);
  
  /// Cria uma cópia desta tarefa com propriedades opcionalmente modificadas
  Tarefa copyWith({
    String? id,
    String? nome,
    DateTime? dataHora,
    GeoPoint? localizacao,
    bool? concluida,
  }) {
    return Tarefa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataHora: dataHora ?? this.dataHora,
      localizacao: localizacao ?? this.localizacao,
      concluida: concluida ?? this.concluida,
    );
  }
}
