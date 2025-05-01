import 'package:flutter/material.dart';

import '../models/produto.dart';

class ProdutoForm extends StatelessWidget {
  final double height;
  final Function salvarProduto;
  final Produto? produto;

  final nomeProdutoController = TextEditingController();
  final descricaoProdutoController = TextEditingController();
  final urlImagemProdutoController = TextEditingController();

  ProdutoForm(this.height, this.salvarProduto, {super.key, this.produto = null});

  @override
  Widget build(BuildContext context) {

    if (produto != null) {
      nomeProdutoController.text = produto!.nome;
      descricaoProdutoController.text = produto!.descricao;
      urlImagemProdutoController.text = produto!.imagens[0];
    }

    return SizedBox(
      height: height * 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            const Text("Formulário"),
            TextField(
              controller: nomeProdutoController,
              decoration: InputDecoration(
                  hintText: 'Nome'
              ),
            ),
            TextField(
              controller: descricaoProdutoController,
              decoration: InputDecoration(
                  hintText: 'Descrição'
              ),
            ),
            TextField(
              controller: urlImagemProdutoController,
              decoration: InputDecoration(
                hintText: 'URL da imagem',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String nome = nomeProdutoController.text;
                String descricao = descricaoProdutoController.text;
                String urlImagem = urlImagemProdutoController.text;
                Produto produto = Produto(
                    id: nome,
                    nome: nome,
                    descricao: descricao,
                    imagens: [urlImagem]
                );
                salvarProduto(produto);
              },
              child: Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

}