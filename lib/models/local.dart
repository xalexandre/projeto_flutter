import 'tipo_local.dart';
import 'geo_point.dart';

class Local {
  final String id;
  final String nome;
  final String? endereco;
  final GeoPoint? coordenadas;
  final TipoLocal tipo;

  Local({
    required this.id,
    required this.nome,
    this.endereco,
    this.coordenadas,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'coordenadas': coordenadas?.toMap(),
      'tipo': tipo.index,
    };
  }

  factory Local.fromMap(Map<String, dynamic> map) {
    return Local(
      id: map['id'],
      nome: map['nome'],
      endereco: map['endereco'],
      coordenadas: map['coordenadas'] != null
          ? GeoPoint.fromMap(map['coordenadas'])
          : null,
      tipo: TipoLocal.values[map['tipo']],
    );
  }
}