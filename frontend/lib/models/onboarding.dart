import 'package:json_annotation/json_annotation.dart';

part 'onboarding.g.dart';

@JsonSerializable()
class OnboardingIniziato {
  @JsonKey(name: 'utente_temp_id')
  final String utenteTempId;
  @JsonKey(name: 'sessione_id')
  final String sessioneId;

  const OnboardingIniziato({
    required this.utenteTempId,
    required this.sessioneId,
  });

  factory OnboardingIniziato.fromJson(Map<String, dynamic> json) =>
      _$OnboardingIniziatoFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingIniziatoToJson(this);
}

@JsonSerializable()
class OnboardingTurnoRequest {
  @JsonKey(name: 'sessione_id')
  final String sessioneId;
  final String messaggio;

  const OnboardingTurnoRequest({
    required this.sessioneId,
    required this.messaggio,
  });

  factory OnboardingTurnoRequest.fromJson(Map<String, dynamic> json) =>
      _$OnboardingTurnoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingTurnoRequestToJson(this);
}

@JsonSerializable()
class OnboardingCompletaRequest {
  @JsonKey(name: 'sessione_id')
  final String sessioneId;
  @JsonKey(name: 'contesto_personale')
  final Map<String, dynamic>? contestoPersonale;
  @JsonKey(name: 'preferenze_tutor')
  final Map<String, dynamic>? preferenzeTutor;

  const OnboardingCompletaRequest({
    required this.sessioneId,
    this.contestoPersonale,
    this.preferenzeTutor,
  });

  factory OnboardingCompletaRequest.fromJson(Map<String, dynamic> json) =>
      _$OnboardingCompletaRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingCompletaRequestToJson(this);
}

@JsonSerializable()
class OnboardingCompletaResponse {
  @JsonKey(name: 'percorso_id')
  final int percorsoId;
  @JsonKey(name: 'nodo_iniziale')
  final String? nodoIniziale;
  @JsonKey(name: 'nodi_inizializzati')
  final int nodiInizializzati;

  const OnboardingCompletaResponse({
    required this.percorsoId,
    this.nodoIniziale,
    required this.nodiInizializzati,
  });

  factory OnboardingCompletaResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingCompletaResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingCompletaResponseToJson(this);
}

/// Singolo turno della conversazione per ripresa onboarding.
@JsonSerializable()
class TurnoRipresa {
  final String ruolo;
  final String? contenuto;

  const TurnoRipresa({
    required this.ruolo,
    this.contenuto,
  });

  factory TurnoRipresa.fromJson(Map<String, dynamic> json) =>
      _$TurnoRipresaFromJson(json);
  Map<String, dynamic> toJson() => _$TurnoRipresaToJson(this);
}

/// Stato sessione onboarding per ripresa dopo skip/interruzione.
@JsonSerializable()
class OnboardingRipresaResponse {
  @JsonKey(name: 'sessione_id')
  final String sessioneId;
  @JsonKey(name: 'fase_corrente')
  final String faseCorrente;
  @JsonKey(name: 'campi_completi')
  final int campiCompleti;
  final List<TurnoRipresa> turni;

  const OnboardingRipresaResponse({
    required this.sessioneId,
    required this.faseCorrente,
    required this.campiCompleti,
    required this.turni,
  });

  factory OnboardingRipresaResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingRipresaResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingRipresaResponseToJson(this);
}
