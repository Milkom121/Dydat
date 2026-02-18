import 'package:json_annotation/json_annotation.dart';
import 'package:dydat/models/percorso.dart';

part 'tema.g.dart';

@JsonSerializable()
class Tema {
  final String id;
  final String nome;
  final String materia;
  final String? descrizione;
  @JsonKey(name: 'nodi_totali')
  final int nodiTotali;
  @JsonKey(name: 'nodi_completati')
  final int nodiCompletati;
  final bool completato;

  const Tema({
    required this.id,
    required this.nome,
    required this.materia,
    this.descrizione,
    this.nodiTotali = 0,
    this.nodiCompletati = 0,
    this.completato = false,
  });

  factory Tema.fromJson(Map<String, dynamic> json) => _$TemaFromJson(json);
  Map<String, dynamic> toJson() => _$TemaToJson(this);
}

@JsonSerializable()
class TemaDettaglio {
  final String id;
  final String nome;
  final String materia;
  final String? descrizione;
  @JsonKey(name: 'nodi_totali')
  final int nodiTotali;
  @JsonKey(name: 'nodi_completati')
  final int nodiCompletati;
  final bool completato;
  final List<NodoMappa> nodi;

  const TemaDettaglio({
    required this.id,
    required this.nome,
    required this.materia,
    this.descrizione,
    this.nodiTotali = 0,
    this.nodiCompletati = 0,
    this.completato = false,
    required this.nodi,
  });

  factory TemaDettaglio.fromJson(Map<String, dynamic> json) =>
      _$TemaDettaglioFromJson(json);
  Map<String, dynamic> toJson() => _$TemaDettaglioToJson(this);
}
