// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessione.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sessione _$SessioneFromJson(Map<String, dynamic> json) => Sessione(
  id: json['id'] as String,
  stato: json['stato'] as String,
  tipo: json['tipo'] as String?,
  nodoFocaleId: json['nodo_focale_id'] as String?,
  nodoFocaleNome: json['nodo_focale_nome'] as String?,
  attivitaCorrente: json['attivita_corrente'] as String?,
  durataPrevistaMin: (json['durata_prevista_min'] as num?)?.toInt(),
  durataEffettivaMin: (json['durata_effettiva_min'] as num?)?.toInt(),
  nodiLavorati: (json['nodi_lavorati'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SessioneToJson(Sessione instance) => <String, dynamic>{
  'id': instance.id,
  'stato': instance.stato,
  'tipo': instance.tipo,
  'nodo_focale_id': instance.nodoFocaleId,
  'nodo_focale_nome': instance.nodoFocaleNome,
  'attivita_corrente': instance.attivitaCorrente,
  'durata_prevista_min': instance.durataPrevistaMin,
  'durata_effettiva_min': instance.durataEffettivaMin,
  'nodi_lavorati': instance.nodiLavorati,
};

MessaggioUtente _$MessaggioUtenteFromJson(Map<String, dynamic> json) =>
    MessaggioUtente(messaggio: json['messaggio'] as String);

Map<String, dynamic> _$MessaggioUtenteToJson(MessaggioUtente instance) =>
    <String, dynamic>{'messaggio': instance.messaggio};

SessioneCreataEvent _$SessioneCreataEventFromJson(Map<String, dynamic> json) =>
    SessioneCreataEvent(
      sessioneId: json['sessione_id'] as String,
      nodoId: json['nodo_id'] as String?,
      nodoNome: json['nodo_nome'] as String?,
    );

Map<String, dynamic> _$SessioneCreataEventToJson(
  SessioneCreataEvent instance,
) => <String, dynamic>{
  'sessione_id': instance.sessioneId,
  'nodo_id': instance.nodoId,
  'nodo_nome': instance.nodoNome,
};

TurnoCompletoEvent _$TurnoCompletoEventFromJson(Map<String, dynamic> json) =>
    TurnoCompletoEvent(
      turnoId: (json['turno_id'] as num).toInt(),
      nodoFocale: json['nodo_focale'] as String?,
    );

Map<String, dynamic> _$TurnoCompletoEventToJson(TurnoCompletoEvent instance) =>
    <String, dynamic>{
      'turno_id': instance.turnoId,
      'nodo_focale': instance.nodoFocale,
    };

TextDeltaEvent _$TextDeltaEventFromJson(Map<String, dynamic> json) =>
    TextDeltaEvent(testo: json['testo'] as String);

Map<String, dynamic> _$TextDeltaEventToJson(TextDeltaEvent instance) =>
    <String, dynamic>{'testo': instance.testo};

AzioneEvent _$AzioneEventFromJson(Map<String, dynamic> json) => AzioneEvent(
  tipo: json['tipo'] as String,
  params: json['params'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AzioneEventToJson(AzioneEvent instance) =>
    <String, dynamic>{'tipo': instance.tipo, 'params': instance.params};
