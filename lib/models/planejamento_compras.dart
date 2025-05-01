import 'produto.dart';
import 'estado_item.dart';
import 'item_planejamento.dart';

class PlanejamentoCompras {
  final String id;
  final String nome;
  final String? descricao;
  final DateTime dataCriacao;
  final List<ItemPlanejamento> itens;
  final DateTime? periodoValidade;

  PlanejamentoCompras({
    required this.id,
    required this.nome,
    this.descricao,
    List<ItemPlanejamento>? itens,
    this.periodoValidade,
    DateTime? dataCriacao,
  })  : dataCriacao = dataCriacao ?? DateTime.now(),
        itens = itens ?? [];

  // Adiciona um novo item ao planejamento
  void adicionarItem(Produto produto, int quantidade, {int? prioridade, String? observacoes}) {
    final itemExistente = itens.firstWhere(
          (item) => item.produto.id == produto.id,
      // orElse: () => null,
    );

    if (itemExistente != null) {
      itemExistente.atualizarQuantidade(itemExistente.quantidade + quantidade);
    } else {
      itens.add(ItemPlanejamento(
        produto: produto,
        quantidade: quantidade,
        prioridade: prioridade,
        observacoes: observacoes,
      ));
    }
  }

  void removerItem(String produtoId) {
    itens.removeWhere((item) => item.produto.id == produtoId);
  }

  void atualizarQuantidade(String produtoId, int novaQuantidade) {
    final item = itens.firstWhere((item) => item.produto.id == produtoId);
    item.atualizarQuantidade(novaQuantidade);
  }

  void marcarComoNoCarrinho(String produtoId) {
    final item = itens.firstWhere((item) => item.produto.id == produtoId);
    item.marcarComoNoCarrinho();
  }

  void marcarComoComprado(String produtoId) {
    final item = itens.firstWhere((item) => item.produto.id == produtoId);
    item.marcarComoComprado();
  }

  List<ItemPlanejamento> filtrarPorEstado(EstadoItem estado) {
    return itens.where((item) => item.estado == estado).toList();
  }

  double get valorTotalMinimo {
    return _calcularTotal((item) => item.produto.precoMinimo * item.quantidade.toDouble());
  }

  double get valorTotalMaximo {
    return _calcularTotal((item) => item.produto.precoMaximo * item.quantidade.toDouble());
  }

  double get valorTotalMedio {
    return _calcularTotal((item) => item.produto.precoMedio * item.quantidade.toDouble());
  }

  double get valorTotalAtual {
    return _calcularTotal((item) => item.valorTotal);
  }

  double _calcularTotal(double Function(ItemPlanejamento) calcularValorItem) {
    return itens.fold<double>(
      0.0,
          (total, item) => total + calcularValorItem(item),
    );
  }

  void ordenarPorPrioridade() {
    itens.sort((a, b) {
      final prioridadeA = a.prioridade ?? 3;
      final prioridadeB = b.prioridade ?? 3;
      return prioridadeA.compareTo(prioridadeB);
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'dataCriacao': dataCriacao.toIso8601String(),
      'periodoValidade': periodoValidade?.toIso8601String(),
      // 'itens': itens.map((item) => item.toMap()).toList(),
    };
  }

  factory PlanejamentoCompras.fromMap(Map<String, dynamic> map) {
    return PlanejamentoCompras(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
      periodoValidade: map['periodoValidade'] != null
          ? DateTime.parse(map['periodoValidade'])
          : null,
      itens: List<ItemPlanejamento>.from(
        map['itens']?.map((x) => ItemPlanejamento.fromMap(x)) ?? [],
      ),
    );
  }
}