import 'package:json_annotation/json_annotation.dart';

part 'ripasso.g.dart';

/// Nodo con spaced repetition scaduto — da ripassare oggi.
@JsonSerializable()
class NodoRipasso {
  @JsonKey(name: 'nodo_id')
  final String nodoId;
  @JsonKey(name: 'nodo_nome')
  final String nodoNome;
  @JsonKey(name: 'tema_id')
  final String temaId;
  @JsonKey(name: 'tema_nome')
  final String temaNome;
  @JsonKey(name: 'sr_prossimo_ripasso')
  final String? srProssimoRipasso;
  @JsonKey(name: 'sr_ripetizioni')
  final int srRipetizioni;

  const NodoRipasso({
    required this.nodoId,
    required this.nodoNome,
    required this.temaId,
    required this.temaNome,
    this.srProssimoRipasso,
    this.srRipetizioni = 0,
  });

  factory NodoRipasso.fromJson(Map<String, dynamic> json) =>
      _$NodoRipassoFromJson(json);
  Map<String, dynamic> toJson() => _$NodoRipassoToJson(this);
}
