import 'package:json_annotation/json_annotation.dart';

part 'quaderno.g.dart';

/// Stato dell'utente su un nodo specifico nel quaderno.
@JsonSerializable()
class StatoNodoQuaderno {
  final String livello;
  final bool presunto;
  @JsonKey(name: 'spiegazione_data')
  final bool spiegazioneData;
  @JsonKey(name: 'esercizi_completati')
  final int eserciziCompletati;
  @JsonKey(name: 'sr_prossimo_ripasso')
  final String? srProssimoRipasso;
  @JsonKey(name: 'sr_ripetizioni')
  final int srRipetizioni;
  @JsonKey(name: 'ultima_interazione')
  final String? ultimaInterazione;

  const StatoNodoQuaderno({
    this.livello = 'non_iniziato',
    this.presunto = false,
    this.spiegazioneData = false,
    this.eserciziCompletati = 0,
    this.srProssimoRipasso,
    this.srRipetizioni = 0,
    this.ultimaInterazione,
  });

  factory StatoNodoQuaderno.fromJson(Map<String, dynamic> json) =>
      _$StatoNodoQuadernoFromJson(json);
  Map<String, dynamic> toJson() => _$StatoNodoQuadernoToJson(this);
}

/// Esercizio svolto nel quaderno di un nodo.
@JsonSerializable()
class EsercizioQuaderno {
  final int id;
  @JsonKey(name: 'esercizio_id')
  final String? esercizioId;
  final String esito;
  final String? testo;
  final String? tipo;
  final int? difficolta;
  final String? data;

  const EsercizioQuaderno({
    required this.id,
    this.esercizioId,
    required this.esito,
    this.testo,
    this.tipo,
    this.difficolta,
    this.data,
  });

  factory EsercizioQuaderno.fromJson(Map<String, dynamic> json) =>
      _$EsercizioQuadernoFromJson(json);
  Map<String, dynamic> toJson() => _$EsercizioQuadernoToJson(this);
}

/// Formula mostrata dal tutor per un nodo.
@JsonSerializable()
class FormulaQuaderno {
  final String titolo;
  final String formula;
  final String spiegazione;
  final String? data;

  const FormulaQuaderno({
    required this.titolo,
    required this.formula,
    this.spiegazione = '',
    this.data,
  });

  factory FormulaQuaderno.fromJson(Map<String, dynamic> json) =>
      _$FormulaQuadernoFromJson(json);
  Map<String, dynamic> toJson() => _$FormulaQuadernoToJson(this);
}

/// Spiegazione chiave del tutor per un nodo.
@JsonSerializable()
class SpiegazioneQuaderno {
  final String contenuto;
  @JsonKey(name: 'sessione_id')
  final String sessioneId;
  final String? data;

  const SpiegazioneQuaderno({
    required this.contenuto,
    required this.sessioneId,
    this.data,
  });

  factory SpiegazioneQuaderno.fromJson(Map<String, dynamic> json) =>
      _$SpiegazioneQuadernoFromJson(json);
  Map<String, dynamic> toJson() => _$SpiegazioneQuadernoToJson(this);
}

/// Quaderno aggregato per un nodo — raccoglie tutto: stato, esercizi, formule, spiegazioni.
@JsonSerializable()
class QuadernoNodo {
  @JsonKey(name: 'nodo_id')
  final String nodoId;
  @JsonKey(name: 'nodo_nome')
  final String nodoNome;
  @JsonKey(name: 'tema_nome')
  final String? temaNome;
  final StatoNodoQuaderno stato;
  @JsonKey(name: 'sessioni_count')
  final int sessioniCount;
  final List<EsercizioQuaderno> esercizi;
  final List<FormulaQuaderno> formule;
  final List<SpiegazioneQuaderno> spiegazioni;

  const QuadernoNodo({
    required this.nodoId,
    required this.nodoNome,
    this.temaNome,
    required this.stato,
    this.sessioniCount = 0,
    this.esercizi = const [],
    this.formule = const [],
    this.spiegazioni = const [],
  });

  factory QuadernoNodo.fromJson(Map<String, dynamic> json) =>
      _$QuadernoNodoFromJson(json);
  Map<String, dynamic> toJson() => _$QuadernoNodoToJson(this);

  /// Conteggio esercizi corretti.
  int get eserciziCorretti =>
      esercizi.where((e) => e.esito == 'corretto').length;

  /// Conteggio esercizi errati.
  int get eserciziErrati =>
      esercizi.where((e) => e.esito != 'corretto').length;
}
