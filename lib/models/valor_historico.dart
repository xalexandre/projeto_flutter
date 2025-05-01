import 'local.dart';

class ValorHistorico {
  final double preco;
  final DateTime dataRegistro;
  final Local local;
  final String? promocao;
  final String? observacoes;

  ValorHistorico({
    required this.preco,
    required this.dataRegistro,
    required this.local,
    this.promocao,
    this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'preco': preco.toString(),
      'dataRegistro': dataRegistro.toIso8601String(),
      'local': local.toMap(),
      'promocao': promocao,
      'observacoes': observacoes,
    };
  }

  factory ValorHistorico.fromMap(Map<String, dynamic> map) {
    return ValorHistorico(
      preco: double.parse(map['preco']),
      dataRegistro: DateTime.parse(map['dataRegistro']),
      local: Local.fromMap(map['local']),
      promocao: map['promocao'],
      observacoes: map['observacoes'],
    );
  }
}