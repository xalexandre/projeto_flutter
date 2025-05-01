import 'package:projeto_flutter/models/planejamento_compras.dart';
import 'package:projeto_flutter/models/produto.dart';
import 'package:projeto_flutter/models/tipo_local.dart';
import 'package:projeto_flutter/models/valor_historico.dart';

import 'estado_item.dart';
import 'item_planejamento.dart';
import 'local.dart';

Local mercadoA = Local(
  id: '1',
  nome: 'Supermercado A',
  tipo: TipoLocal.fisico,
  endereco: 'Rua Principal, 123',
);
Local mercadoB = Local(
  id: '2',
  nome: 'Mercado do Bairro',
  tipo: TipoLocal.fisico,
  endereco: 'Av. Secundária, 456',
);
Local lojaOnline = Local(
  id: '3',
  nome: 'Loja Online Express',
  tipo: TipoLocal.online,
);

final PRODUTOS_MOCK = [
  Produto(
    id: '1',
    nome: 'Arroz Integral 5kg',
    descricao: 'Arroz integral tipo 1, ideal para diversos pratos, soltinhos e saborosos, perfeito para a sua culinária diária, pacote de 5kg',
    imagens: ['assets/produtos/arroz.jpg'],
    historicoPrecos: [
      ValorHistorico(
        preco: 22.90,
        dataRegistro: DateTime.parse('2023-05-01'),
        local: mercadoA,
      ),
      ValorHistorico(
        preco: 21.50,
        dataRegistro: DateTime.parse('2023-05-15'),
        local: mercadoB,
      ),
      ValorHistorico(
        preco: 23.75,
        dataRegistro: DateTime.parse('2023-06-01'),
        local: mercadoA,
      ),
    ],
  ),
  Produto(
    id: '2',
    nome: 'Feijão Carioca 1kg',
    descricao: 'Feijão carioca especial',
    imagens: ['assets/produtos/feijao.jpg'],
    historicoPrecos: [
      ValorHistorico(
        preco:8.90,
        dataRegistro: DateTime.parse('2023-04-20'),
        local: mercadoA,
      ),
      ValorHistorico(
        preco: 7.99,
        dataRegistro: DateTime.parse('2023-05-10'),
        local: mercadoB,
      ),
      ValorHistorico(
        preco: 9.20,
        dataRegistro: DateTime.parse('2023-05-25'),
        local: lojaOnline,
      ),
    ],
  ),
];

final itensPlanejamentoMock = [
  ItemPlanejamento(
    produto: PRODUTOS_MOCK[0], // Arroz
    quantidade: 2,
    prioridade: 1,
    observacoes: 'Preferência marca X',
  ),
  ItemPlanejamento(
    produto: PRODUTOS_MOCK[1], // Feijão
    quantidade: 3,
    estado: EstadoItem.noCarrinho,
  ),
];

final PLANEJAMENTO_MOCK = PlanejamentoCompras(
  id: 'mock1',
  nome: 'Compras Mensais Mock',
  descricao: 'Lista de compras para testes',
  itens: itensPlanejamentoMock,
);