import 'package:json_annotation/json_annotation.dart';

part 'sessione.g.dart';

@JsonSerializable()
class Sessione {
  final String id;
  final String stato;
  final String? tipo;
  @JsonKey(name: 'nodo_focale_id')
  final String? nodoFocaleId;
  @JsonKey(name: 'nodo_focale_nome')
  final String? nodoFocaleNome;
  @JsonKey(name: 'attivita_corrente')
  final String? attivitaCorrente;
  @JsonKey(name: 'durata_prevista_min')
  final int? durataPrevistaMin;
  @JsonKey(name: 'durata_effettiva_min')
  final int? durataEffettivaMin;
  @JsonKey(name: 'nodi_lavorati')
  final List<String>? nodiLavorati;

  const Sessione({
    required this.id,
    required this.stato,
    this.tipo,
    this.nodoFocaleId,
    this.nodoFocaleNome,
    this.attivitaCorrente,
    this.durataPrevistaMin,
    this.durataEffettivaMin,
    this.nodiLavorati,
  });

  factory Sessione.fromJson(Map<String, dynamic> json) =>
      _$SessioneFromJson(json);
  Map<String, dynamic> toJson() => _$SessioneToJson(this);
}

@JsonSerializable()
class MessaggioUtente {
  final String messaggio;

  const MessaggioUtente({required this.messaggio});

  factory MessaggioUtente.fromJson(Map<String, dynamic> json) =>
      _$MessaggioUtenteFromJson(json);
  Map<String, dynamic> toJson() => _$MessaggioUtenteToJson(this);
}

@JsonSerializable()
class SessioneCreataEvent {
  @JsonKey(name: 'sessione_id')
  final String sessioneId;
  @JsonKey(name: 'nodo_id')
  final String? nodoId;
  @JsonKey(name: 'nodo_nome')
  final String? nodoNome;

  const SessioneCreataEvent({
    required this.sessioneId,
    this.nodoId,
    this.nodoNome,
  });

  factory SessioneCreataEvent.fromJson(Map<String, dynamic> json) =>
      _$SessioneCreataEventFromJson(json);
  Map<String, dynamic> toJson() => _$SessioneCreataEventToJson(this);
}

@JsonSerializable()
class TurnoCompletoEvent {
  @JsonKey(name: 'turno_id')
  final int turnoId;
  @JsonKey(name: 'nodo_focale')
  final String? nodoFocale;

  const TurnoCompletoEvent({required this.turnoId, this.nodoFocale});

  factory TurnoCompletoEvent.fromJson(Map<String, dynamic> json) =>
      _$TurnoCompletoEventFromJson(json);
  Map<String, dynamic> toJson() => _$TurnoCompletoEventToJson(this);
}

@JsonSerializable()
class TextDeltaEvent {
  final String testo;

  const TextDeltaEvent({required this.testo});

  factory TextDeltaEvent.fromJson(Map<String, dynamic> json) =>
      _$TextDeltaEventFromJson(json);
  Map<String, dynamic> toJson() => _$TextDeltaEventToJson(this);
}

@JsonSerializable()
class AzioneEvent {
  final String tipo;
  final Map<String, dynamic> params;

  const AzioneEvent({required this.tipo, required this.params});

  factory AzioneEvent.fromJson(Map<String, dynamic> json) =>
      _$AzioneEventFromJson(json);
  Map<String, dynamic> toJson() => _$AzioneEventToJson(this);
}
