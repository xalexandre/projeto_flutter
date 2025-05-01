import 'package:flutter/material.dart';
import 'package:projeto_flutter/models/produto.dart';

class ProdutoItem extends StatelessWidget {
  final Produto produto;
  final bool isPortrait;
  final Function editarProduto;

  const ProdutoItem(
      this.produto,
      this.editarProduto,
      {super.key, this.isPortrait = true});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: !isPortrait ? Icon(Icons.shopping_bag_rounded) : null,
      title: Text(produto.nome),
      subtitle: Text(produto.descricao),
      trailing: IconButton(
        onPressed: () => editarProduto(produto),
        icon: Icon(Icons.edit),
      ),
      isThreeLine: !isPortrait,
    )
    ;
  }

}