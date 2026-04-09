// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingIniziato _$OnboardingIniziatoFromJson(Map<String, dynamic> json) =>
    OnboardingIniziato(
      utenteTempId: json['utente_temp_id'] as String,
      sessioneId: json['sessione_id'] as String,
    );

Map<String, dynamic> _$OnboardingIniziatoToJson(OnboardingIniziato instance) =>
    <String, dynamic>{
      'utente_temp_id': instance.utenteTempId,
      'sessione_id': instance.sessioneId,
    };

OnboardingTurnoRequest _$OnboardingTurnoRequestFromJson(
  Map<String, dynamic> json,
) => OnboardingTurnoRequest(
  sessioneId: json['sessione_id'] as String,
  messaggio: json['messaggio'] as String,
);

Map<String, dynamic> _$OnboardingTurnoRequestToJson(
  OnboardingTurnoRequest instance,
) => <String, dynamic>{
  'sessione_id': instance.sessioneId,
  'messaggio': instance.messaggio,
};

OnboardingCompletaRequest _$OnboardingCompletaRequestFromJson(
  Map<String, dynamic> json,
) => OnboardingCompletaRequest(
  sessioneId: json['sessione_id'] as String,
  contestoPersonale: json['contesto_personale'] as Map<String, dynamic>?,
  preferenzeTutor: json['preferenze_tutor'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$OnboardingCompletaRequestToJson(
  OnboardingCompletaRequest instance,
) => <String, dynamic>{
  'sessione_id': instance.sessioneId,
  'contesto_personale': instance.contestoPersonale,
  'preferenze_tutor': instance.preferenzeTutor,
};

OnboardingCompletaResponse _$OnboardingCompletaResponseFromJson(
  Map<String, dynamic> json,
) => OnboardingCompletaResponse(
  percorsoId: (json['percorso_id'] as num).toInt(),
  nodoIniziale: json['nodo_iniziale'] as String?,
  nodiInizializzati: (json['nodi_inizializzati'] as num).toInt(),
);

Map<String, dynamic> _$OnboardingCompletaResponseToJson(
  OnboardingCompletaResponse instance,
) => <String, dynamic>{
  'percorso_id': instance.percorsoId,
  'nodo_iniziale': instance.nodoIniziale,
  'nodi_inizializzati': instance.nodiInizializzati,
};

TurnoRipresa _$TurnoRipresaFromJson(Map<String, dynamic> json) =>
    TurnoRipresa(
      ruolo: json['ruolo'] as String,
      contenuto: json['contenuto'] as String?,
    );

Map<String, dynamic> _$TurnoRipresaToJson(TurnoRipresa instance) =>
    <String, dynamic>{
      'ruolo': instance.ruolo,
      'contenuto': instance.contenuto,
    };

OnboardingRipresaResponse _$OnboardingRipresaResponseFromJson(
  Map<String, dynamic> json,
) => OnboardingRipresaResponse(
  sessioneId: json['sessione_id'] as String,
  faseCorrente: json['fase_corrente'] as String,
  campiCompleti: (json['campi_completi'] as num).toInt(),
  turni: (json['turni'] as List<dynamic>)
      .map((e) => TurnoRipresa.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OnboardingRipresaResponseToJson(
  OnboardingRipresaResponse instance,
) => <String, dynamic>{
  'sessione_id': instance.sessioneId,
  'fase_corrente': instance.faseCorrente,
  'campi_completi': instance.campiCompleti,
  'turni': instance.turni.map((e) => e.toJson()).toList(),
};
