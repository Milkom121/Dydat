import 'package:json_annotation/json_annotation.dart';

part 'nodo.g.dart';

@JsonSerializable()
class Nodo {
  final String id;
  final String nome;
  final String materia;
  final String tipo;
  @JsonKey(name: 'tipo_nodo')
  final String tipoNodo;

  const Nodo({
    required this.id,
    required this.nome,
    required this.materia,
    this.tipo = 'standard',
    this.tipoNodo = 'operativo',
  });

  factory Nodo.fromJson(Map<String, dynamic> json) => _$NodoFromJson(json);
  Map<String, dynamic> toJson() => _$NodoToJson(this);
}

@JsonSerializable()
class StatoNodoUtente {
  @JsonKey(name: 'utente_id')
  final String utenteId;
  @JsonKey(name: 'nodo_id')
  final String nodoId;
  final String livello;
  final bool presunto;
  @JsonKey(name: 'spiegazione_data')
  final bool spiegazioneData;
  @JsonKey(name: 'esercizi_completati')
  final int eserciziCompletati;
  @JsonKey(name: 'errori_in_corso')
  final int erroriInCorso;
  @JsonKey(name: 'esercizi_consecutivi_ok')
  final int? eserciziConsecutiviOk;

  const StatoNodoUtente({
    required this.utenteId,
    required this.nodoId,
    this.livello = 'non_iniziato',
    this.presunto = false,
    this.spiegazioneData = false,
    this.eserciziCompletati = 0,
    this.erroriInCorso = 0,
    this.eserciziConsecutiviOk,
  });

  factory StatoNodoUtente.fromJson(Map<String, dynamic> json) =>
      _$StatoNodoUtenteFromJson(json);
  Map<String, dynamic> toJson() => _$StatoNodoUtenteToJson(this);
}
