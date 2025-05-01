import 'package:projeto_flutter/models/produto.dart';

import 'estado_item.dart';

class ItemPlanejamento {
  final Produto produto;
  int quantidade;
  EstadoItem estado;
  final DateTime dataAdicao;
  DateTime? dataModificacao;
  String? observacoes;
  int? prioridade; // 1-5, onde 1 é mais importante

  ItemPlanejamento({
    required this.produto,
    required this.quantidade,
    this.estado = EstadoItem.aComprar,
    DateTime? dataAdicao,
    this.dataModificacao,
    this.observacoes,
    this.prioridade,
  }) : dataAdicao = dataAdicao ?? DateTime.now();

  void atualizarQuantidade(int novaQuantidade) {
    if (novaQuantidade > 0) {
      quantidade = novaQuantidade;
      dataModificacao = DateTime.now();
    }
  }

  void marcarComoNoCarrinho() {
    estado = EstadoItem.noCarrinho;
    dataModificacao = DateTime.now();
  }

  void marcarComoComprado() {
    estado = EstadoItem.comprado;
    dataModificacao = DateTime.now();
  }

  void resetarEstado() {
    estado = EstadoItem.aComprar;
    dataModificacao = DateTime.now();
  }

  double get valorTotal {
    return produto.precoAtual?.preco ?? 0.0 * quantidade.toDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'produto': produto.toMap(),
      'quantidade': quantidade,
      'estado': estado.index,
      'dataAdicao': dataAdicao.toIso8601String(),
      'dataModificacao': dataModificacao?.toIso8601String(),
      'observacoes': observacoes,
      'prioridade': prioridade,
    };
  }

  factory ItemPlanejamento.fromMap(Map<String, dynamic> map) {
    return ItemPlanejamento(
      produto: Produto.fromMap(map['produto']),
      quantidade: map['quantidade'],
      estado: EstadoItem.values[map['estado']],
      dataAdicao: DateTime.parse(map['dataAdicao']),
      dataModificacao: map['dataModificacao'] != null
          ? DateTime.parse(map['dataModificacao'])
          : null,
      observacoes: map['observacoes'],
      prioridade: map['prioridade'],
    );
  }
}