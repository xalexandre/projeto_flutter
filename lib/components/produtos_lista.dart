import 'package:flutter/material.dart';
import 'package:projeto_flutter/components/produto_item.dart';
import 'package:projeto_flutter/models/produto.dart';

class ProdutosLista extends StatelessWidget {
  final double height;
  final bool isPortrait;
  final List<Produto> listaProdutos;
  final Function editarProduto;

  const ProdutosLista(
      this.listaProdutos,
      this.editarProduto,
      this.height,
      {super.key, this.isPortrait = true});

  Widget gerarItemLista(int index, bool isPortrait) {
    Produto produto = listaProdutos[index];
    return ProdutoItem(produto, editarProduto, isPortrait: isPortrait);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.6,
      child: ListView.builder(
          itemCount: listaProdutos.length,
          itemBuilder: (context, index) {
            return gerarItemLista(index, isPortrait);
          }
      ),
    );
  }

}