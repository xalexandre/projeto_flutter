import 'package:projeto_flutter/models/valor_historico.dart';
import 'local.dart';

class Produto {
  final String id;
  final String nome;
  final String descricao;
  final List<String> imagens;
  ValorHistorico? precoAtual;
  final List<ValorHistorico> historicoPrecos;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagens,
    this.precoAtual,
    List<ValorHistorico>? historicoPrecos,
  }) : historicoPrecos = historicoPrecos ?? [];

  void atualizarPreco(
      double novoPreco,
      DateTime data,
      Local local,
      {String? promocao, String? observacoes}) {
    final novoValor = ValorHistorico(
      preco: novoPreco,
      dataRegistro: data,
      local: local,
      promocao: promocao,
      observacoes: observacoes,
    );

    historicoPrecos.add(novoValor);
    precoAtual = novoValor;
    historicoPrecos.sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
  }

  double get precoMinimo {
    if (historicoPrecos.isEmpty) return 0.0;
    return historicoPrecos.map((v) => v.preco).reduce((a, b) => a < b ? a : b);
  }
  double get precoMaximo {
    if (historicoPrecos.isEmpty) return 0.0;
    return historicoPrecos.map((v) => v.preco).reduce((a, b) => a > b ? a : b);
  }
  double get precoMedio {
    if (historicoPrecos.isEmpty) return 0.0;
    final total = historicoPrecos.fold<double>(
        0.0, (sum, v) => sum + v.preco);
    return total / historicoPrecos.length.toDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'imagens': imagens,
      'precoAtual': precoAtual?.toMap(),
      'historicoPrecos': historicoPrecos.map((v) => v.toMap()).toList(),
    };
  }
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      imagens: List<String>.from(map['imagens']),
      precoAtual: map['precoAtual'] != null
          ? ValorHistorico.fromMap(map['precoAtual'])
          : null,
      historicoPrecos: List<ValorHistorico>.from(
        map['historicoPrecos']?.map((x) => ValorHistorico.fromMap(x)) ?? [],
      ),
    );
  }
}