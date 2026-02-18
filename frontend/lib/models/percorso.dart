import 'package:json_annotation/json_annotation.dart';

part 'percorso.g.dart';

@JsonSerializable()
class Percorso {
  final int id;
  final String tipo;
  final String materia;
  final String? nome;
  final String stato;
  @JsonKey(name: 'nodo_iniziale_override')
  final String? nodoInizialeOverride;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const Percorso({
    required this.id,
    required this.tipo,
    required this.materia,
    this.nome,
    this.stato = 'attivo',
    this.nodoInizialeOverride,
    this.createdAt,
  });

  factory Percorso.fromJson(Map<String, dynamic> json) =>
      _$PercorsoFromJson(json);
  Map<String, dynamic> toJson() => _$PercorsoToJson(this);
}

@JsonSerializable()
class MappaPercorso {
  @JsonKey(name: 'percorso_id')
  final int percorsoId;
  final String materia;
  @JsonKey(name: 'nodo_iniziale_override')
  final String? nodoInizialeOverride;
  final List<NodoMappa> nodi;

  const MappaPercorso({
    required this.percorsoId,
    required this.materia,
    this.nodoInizialeOverride,
    required this.nodi,
  });

  factory MappaPercorso.fromJson(Map<String, dynamic> json) =>
      _$MappaPercorsoFromJson(json);
  Map<String, dynamic> toJson() => _$MappaPercorsoToJson(this);
}

@JsonSerializable()
class NodoMappa {
  final String id;
  final String nome;
  final String tipo;
  @JsonKey(name: 'tema_id')
  final String? temaId;
  final String livello;
  final bool presunto;
  @JsonKey(name: 'spiegazione_data')
  final bool spiegazioneData;
  @JsonKey(name: 'esercizi_completati')
  final int eserciziCompletati;

  const NodoMappa({
    required this.id,
    required this.nome,
    required this.tipo,
    this.temaId,
    required this.livello,
    this.presunto = false,
    this.spiegazioneData = false,
    this.eserciziCompletati = 0,
  });

  factory NodoMappa.fromJson(Map<String, dynamic> json) =>
      _$NodoMappaFromJson(json);
  Map<String, dynamic> toJson() => _$NodoMappaToJson(this);
}
