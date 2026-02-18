import 'dart:convert';

/// Base class for all SSE events from the Dydat backend.
///
/// The backend sends `text/event-stream` with format:
/// ```
/// event: <type>
/// data: <json>
/// ```
sealed class SseEvent {
  const SseEvent();

  /// Parses a raw SSE event (type + JSON data) into a typed [SseEvent].
  ///
  /// Returns `null` if the event type is unknown or parsing fails.
  static SseEvent? fromRawEvent(String eventType, String jsonData) {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      return switch (eventType) {
        'sessione_creata' => SessioneCreataEvent.fromJson(data),
        'onboarding_iniziato' => OnboardingIniziatoEvent.fromJson(data),
        'text_delta' => TextDeltaEvent.fromJson(data),
        'azione' => AzioneEvent.fromJson(data),
        'achievement' => AchievementEvent.fromJson(data),
        'turno_completo' => TurnoCompletoEvent.fromJson(data),
        'errore' => ErroreEvent.fromJson(data),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }
}

/// First event when starting a study session via `POST /sessione/inizia`.
class SessioneCreataEvent extends SseEvent {
  final String sessioneId;
  final String? nodoId;
  final String? nodoNome;

  const SessioneCreataEvent({
    required this.sessioneId,
    this.nodoId,
    this.nodoNome,
  });

  factory SessioneCreataEvent.fromJson(Map<String, dynamic> json) {
    return SessioneCreataEvent(
      sessioneId: json['sessione_id'] as String,
      nodoId: json['nodo_id'] as String?,
      nodoNome: json['nodo_nome'] as String?,
    );
  }
}

/// First event when starting onboarding via `POST /onboarding/inizia`.
class OnboardingIniziatoEvent extends SseEvent {
  final String utenteTempId;
  final String sessioneId;

  const OnboardingIniziatoEvent({
    required this.utenteTempId,
    required this.sessioneId,
  });

  factory OnboardingIniziatoEvent.fromJson(Map<String, dynamic> json) {
    return OnboardingIniziatoEvent(
      utenteTempId: json['utente_temp_id'] as String,
      sessioneId: json['sessione_id'] as String,
    );
  }
}

/// Incremental text fragment from the tutor. Multiple per turn.
/// Concatenate all [testo] to get the full tutor message.
class TextDeltaEvent extends SseEvent {
  final String testo;

  const TextDeltaEvent({required this.testo});

  factory TextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return TextDeltaEvent(
      testo: json['testo'] as String,
    );
  }
}

/// Tutor action event. Contains [tipo] and [params] with action-specific data.
class AzioneEvent extends SseEvent {
  final String tipo;
  final Map<String, dynamic> params;

  const AzioneEvent({
    required this.tipo,
    required this.params,
  });

  factory AzioneEvent.fromJson(Map<String, dynamic> json) {
    return AzioneEvent(
      tipo: json['tipo'] as String,
      params: json['params'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Typed accessor for `proponi_esercizio` actions.
  ProponiEsercizioAction? get asProponiEsercizio =>
      tipo == 'proponi_esercizio' ? ProponiEsercizioAction.fromParams(params) : null;

  /// Typed accessor for `mostra_formula` actions.
  MostraFormulaAction? get asMostraFormula =>
      tipo == 'mostra_formula' ? MostraFormulaAction.fromParams(params) : null;

  /// Typed accessor for `suggerisci_backtrack` actions.
  SuggerisciBacktrackAction? get asSuggerisciBacktrack =>
      tipo == 'suggerisci_backtrack' ? SuggerisciBacktrackAction.fromParams(params) : null;

  /// Typed accessor for `chiudi_sessione` actions.
  ChiudiSessioneAction? get asChiudiSessione =>
      tipo == 'chiudi_sessione' ? ChiudiSessioneAction.fromParams(params) : null;
}

/// Typed data for `proponi_esercizio` action.
class ProponiEsercizioAction {
  final String? esercizioId;
  final String? testo;
  final int? difficolta;
  final String? nodoId;
  final bool nessunoDisponibile;

  const ProponiEsercizioAction({
    this.esercizioId,
    this.testo,
    this.difficolta,
    this.nodoId,
    this.nessunoDisponibile = false,
  });

  factory ProponiEsercizioAction.fromParams(Map<String, dynamic> params) {
    return ProponiEsercizioAction(
      esercizioId: params['esercizio_id'] as String?,
      testo: params['testo'] as String?,
      difficolta: params['difficolta'] as int?,
      nodoId: params['nodo_id'] as String?,
      nessunoDisponibile:
          params['nessun_esercizio_disponibile'] as bool? ?? false,
    );
  }
}

/// Typed data for `mostra_formula` action.
class MostraFormulaAction {
  final String latex;
  final String? etichetta;

  const MostraFormulaAction({
    required this.latex,
    this.etichetta,
  });

  factory MostraFormulaAction.fromParams(Map<String, dynamic> params) {
    return MostraFormulaAction(
      latex: params['latex'] as String,
      etichetta: params['etichetta'] as String?,
    );
  }
}

/// Typed data for `suggerisci_backtrack` action.
class SuggerisciBacktrackAction {
  final String nodoId;
  final String motivo;

  const SuggerisciBacktrackAction({
    required this.nodoId,
    required this.motivo,
  });

  factory SuggerisciBacktrackAction.fromParams(Map<String, dynamic> params) {
    return SuggerisciBacktrackAction(
      nodoId: params['nodo_id'] as String,
      motivo: params['motivo'] as String,
    );
  }
}

/// Typed data for `chiudi_sessione` action.
class ChiudiSessioneAction {
  final String riepilogo;
  final String? prossimiPassi;

  const ChiudiSessioneAction({
    required this.riepilogo,
    this.prossimiPassi,
  });

  factory ChiudiSessioneAction.fromParams(Map<String, dynamic> params) {
    return ChiudiSessioneAction(
      riepilogo: params['riepilogo'] as String,
      prossimiPassi: params['prossimi_passi'] as String?,
    );
  }
}

/// Achievement unlocked during a turn.
class AchievementEvent extends SseEvent {
  final String id;
  final String nome;
  final String tipo;

  const AchievementEvent({
    required this.id,
    required this.nome,
    required this.tipo,
  });

  factory AchievementEvent.fromJson(Map<String, dynamic> json) {
    return AchievementEvent(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
    );
  }
}

/// Last event of every turn. Signals the turn is complete.
class TurnoCompletoEvent extends SseEvent {
  final int turnoId;
  final String? nodoFocale;

  const TurnoCompletoEvent({
    required this.turnoId,
    this.nodoFocale,
  });

  factory TurnoCompletoEvent.fromJson(Map<String, dynamic> json) {
    return TurnoCompletoEvent(
      turnoId: json['turno_id'] as int,
      nodoFocale: json['nodo_focale'] as String?,
    );
  }
}

/// Error event. The stream terminates after this.
class ErroreEvent extends SseEvent {
  final String codice;
  final String messaggio;

  const ErroreEvent({
    required this.codice,
    required this.messaggio,
  });

  factory ErroreEvent.fromJson(Map<String, dynamic> json) {
    return ErroreEvent(
      codice: json['codice'] as String,
      messaggio: json['messaggio'] as String,
    );
  }
}
