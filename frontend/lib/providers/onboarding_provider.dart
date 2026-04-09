import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:dydat/models/api_response.dart' hide AchievementEvent;
import 'package:dydat/models/onboarding.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/utils/error_messages.dart';

/// Fasi dell'onboarding narrativo (mappa 1:1 con il backend).
enum OnboardingFase {
  accoglienza,
  conoscenza,
  placement,
  piano,
  conclusione,
}

/// Converte la stringa backend nella enum Dart.
OnboardingFase onboardingFaseFromString(String value) {
  return OnboardingFase.values.firstWhere(
    (f) => f.name == value,
    orElse: () => OnboardingFase.accoglienza,
  );
}

class OnboardingScreenState {
  final String? sessioneId;
  final String? utenteTempId;

  /// Finalized tutor messages (complete, after turno_completo).
  final List<String> tutorMessages;

  /// Text being accumulated during SSE streaming (grows with each text_delta).
  final String currentTutorText;

  /// Whether we are currently receiving SSE text deltas.
  final bool isStreaming;

  /// Number of completed turns (for progress calculation).
  final int turnsCompleted;

  final bool isLoading;
  final bool isCompleted;
  final OnboardingCompletaResponse? result;
  final String? error;

  /// Current structured question from onboarding_domanda azione.
  /// Null means no question is pending (show default text input or nothing).
  final OnboardingDomandaAction? currentQuestion;

  /// Fase corrente dell'onboarding (dal backend via decisione_onboarding).
  final OnboardingFase faseCorrente;

  /// Numero campi profilo con confidenza alta/media (0-5).
  final int campiCompleti;

  /// L'utente ha scelto di saltare l'onboarding.
  final bool isSkipped;

  /// Ultima azione del decisore forma C (per logica UI condizionale).
  final String? ultimaAzioneDecisore;

  /// Conversazione ripristinata dal backend (solo dopo resumeOnboarding).
  /// Contiene tutti i turni (user + assistant) nell'ordine originale.
  /// Null se la sessione è nuova.
  final List<TurnoRipresa>? resumedConversation;

  const OnboardingScreenState({
    this.sessioneId,
    this.utenteTempId,
    this.tutorMessages = const [],
    this.currentTutorText = '',
    this.isStreaming = false,
    this.turnsCompleted = 0,
    this.isLoading = false,
    this.isCompleted = false,
    this.result,
    this.error,
    this.currentQuestion,
    this.faseCorrente = OnboardingFase.accoglienza,
    this.campiCompleti = 0,
    this.isSkipped = false,
    this.ultimaAzioneDecisore,
    this.resumedConversation,
  });

  /// Progresso da 0.0 a 1.0 calcolato in base alla fase.
  /// accoglienza=0.0, conoscenza=0.1-0.4 (proporzionale ai campi),
  /// placement=0.5, piano=0.7, conclusione=0.9, completato=1.0.
  double get progress {
    if (isCompleted) return 1.0;
    return switch (faseCorrente) {
      OnboardingFase.accoglienza => 0.0,
      // In conoscenza, progresso proporzionale ai campi completi (5 max)
      OnboardingFase.conoscenza => 0.1 + (campiCompleti / 5) * 0.3,
      OnboardingFase.placement => 0.5,
      OnboardingFase.piano => 0.7,
      OnboardingFase.conclusione => 0.9,
    };
  }

  OnboardingScreenState copyWith({
    String? sessioneId,
    String? utenteTempId,
    List<String>? tutorMessages,
    String? currentTutorText,
    bool? isStreaming,
    int? turnsCompleted,
    bool? isLoading,
    bool? isCompleted,
    OnboardingCompletaResponse? result,
    String? error,
    bool clearError = false,
    OnboardingDomandaAction? currentQuestion,
    bool clearQuestion = false,
    OnboardingFase? faseCorrente,
    int? campiCompleti,
    bool? isSkipped,
    String? ultimaAzioneDecisore,
    bool clearUltimaAzione = false,
    List<TurnoRipresa>? resumedConversation,
    bool clearResumedConversation = false,
  }) {
    return OnboardingScreenState(
      sessioneId: sessioneId ?? this.sessioneId,
      utenteTempId: utenteTempId ?? this.utenteTempId,
      tutorMessages: tutorMessages ?? this.tutorMessages,
      currentTutorText: currentTutorText ?? this.currentTutorText,
      isStreaming: isStreaming ?? this.isStreaming,
      turnsCompleted: turnsCompleted ?? this.turnsCompleted,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
      error: clearError ? null : (error ?? this.error),
      currentQuestion:
          clearQuestion ? null : (currentQuestion ?? this.currentQuestion),
      faseCorrente: faseCorrente ?? this.faseCorrente,
      campiCompleti: campiCompleti ?? this.campiCompleti,
      isSkipped: isSkipped ?? this.isSkipped,
      ultimaAzioneDecisore: clearUltimaAzione
          ? null
          : (ultimaAzioneDecisore ?? this.ultimaAzioneDecisore),
      resumedConversation: clearResumedConversation
          ? null
          : (resumedConversation ?? this.resumedConversation),
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingScreenState> {
  final OnboardingService _onboardingService;
  final StorageService _storageService;
  StreamSubscription<SseEvent>? _sseSubscription;

  OnboardingNotifier({
    required OnboardingService onboardingService,
    required StorageService storageService,
  })  : _onboardingService = onboardingService,
        _storageService = storageService,
        super(const OnboardingScreenState());

  /// Starts onboarding via SSE streaming.
  /// First event: onboarding_iniziato with utenteTempId and sessioneId.
  /// Then: text_delta events with tutor text, ending with turno_completo.
  Future<void> startOnboarding() async {
    _cancelSubscription();
    state = state.copyWith(
      isLoading: true,
      isStreaming: false,
      clearError: true,
      currentTutorText: '',
      tutorMessages: [],
      turnsCompleted: 0,
      clearQuestion: true,
      faseCorrente: OnboardingFase.accoglienza,
      campiCompleti: 0,
      isSkipped: false,
      clearUltimaAzione: true,
      clearResumedConversation: true,
    );

    final stream = _onboardingService.startStream();
    _listenToStream(stream);
  }

  /// Sends a student message during onboarding via SSE streaming.
  Future<void> sendMessage(String message) async {
    if (state.sessioneId == null) return;
    _cancelSubscription();
    state = state.copyWith(
      isStreaming: true,
      clearError: true,
      currentTutorText: '',
      clearQuestion: true,
    );

    final stream = _onboardingService.sendTurnStream(
      sessioneId: state.sessioneId!,
      messaggio: message,
    );
    _listenToStream(stream);
  }

  /// Answers the current onboarding question and sends the response.
  /// Clears currentQuestion so the UI reverts to waiting state.
  Future<void> answerQuestion(String answer) async {
    state = state.copyWith(clearQuestion: true);
    await sendMessage(answer);
  }

  /// L'utente salta l'onboarding. Lo stato resta in_progress sul backend
  /// (nessuna chiamata API), il banner in Home lo inviterà a riprendere.
  void skipOnboarding() {
    _cancelSubscription();
    state = state.copyWith(
      isSkipped: true,
      isLoading: false,
      isStreaming: false,
    );
  }

  /// Riprende un onboarding saltato o interrotto.
  /// Carica lo stato dal backend (sessione + storico turni) e ricostruisce la UI.
  /// Se non trova sessione attiva, ricomincia da capo.
  Future<void> resumeOnboarding() async {
    _cancelSubscription();
    state = state.copyWith(isLoading: true, clearError: true, isSkipped: false);

    // Recupera utente_temp_id dallo storage
    final utenteTempId =
        state.utenteTempId ?? await _storageService.getUtenteTempId();

    if (utenteTempId == null) {
      // Nessun utente temporaneo — ricomincia da capo
      await startOnboarding();
      return;
    }

    try {
      final ripresa = await _onboardingService.getResumeState(
        utenteId: utenteTempId,
      );

      // Ricostruisci messaggi tutor e contatore turni dalla conversazione
      final tutorMessages = <String>[];
      int turnsCompleted = 0;
      for (final turno in ripresa.turni) {
        if (turno.ruolo == 'assistant' && turno.contenuto != null) {
          tutorMessages.add(turno.contenuto!);
        }
        // Ogni coppia user+assistant = 1 turno completo
        if (turno.ruolo == 'assistant') turnsCompleted++;
      }

      state = state.copyWith(
        sessioneId: ripresa.sessioneId,
        utenteTempId: utenteTempId,
        tutorMessages: tutorMessages,
        turnsCompleted: turnsCompleted,
        faseCorrente: onboardingFaseFromString(ripresa.faseCorrente),
        campiCompleti: ripresa.campiCompleti,
        isLoading: false,
        isStreaming: false,
        resumedConversation: ripresa.turni,
      );

      // Persisti sessioneId per future riprese
      await _storageService.saveOnboardingSessioneId(ripresa.sessioneId);
    } on dio_lib.DioException catch (e) {
      // 404 = nessuna sessione attiva — ricomincia da capo
      if (e.response?.statusCode == 404) {
        await startOnboarding();
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: userFriendlyError('$e'),
      );
    }
  }

  void _listenToStream(Stream<SseEvent> stream) {
    _sseSubscription = stream.listen(
      _handleSseEvent,
      onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          isStreaming: false,
          error: userFriendlyError('$error'),
        );
      },
      onDone: () {
        // Stream ended — if still streaming, finalize
        if (state.isStreaming && state.currentTutorText.isNotEmpty) {
          _finalizeTutorMessage();
        }
        state = state.copyWith(isLoading: false, isStreaming: false);
      },
    );
  }

  void _handleSseEvent(SseEvent event) {
    switch (event) {
      case OnboardingIniziatoEvent():
        state = state.copyWith(
          sessioneId: event.sessioneId,
          utenteTempId: event.utenteTempId,
          isLoading: false,
          isStreaming: true,
        );
        _storageService.saveUtenteTempId(event.utenteTempId);
        _storageService.saveOnboardingSessioneId(event.sessioneId);

      case TextDeltaEvent():
        state = state.copyWith(
          currentTutorText: state.currentTutorText + event.testo,
          isStreaming: true,
        );

      case TurnoCompletoEvent():
        _finalizeTutorMessage();
        state = state.copyWith(
          isStreaming: false,
          turnsCompleted: state.turnsCompleted + 1,
        );

      case DecisioneOnboardingEvent():
        state = state.copyWith(
          faseCorrente: onboardingFaseFromString(event.faseCorrente),
          campiCompleti: event.campiCompleti,
          ultimaAzioneDecisore: event.azione,
        );

      case ErroreEvent():
        state = state.copyWith(
          isLoading: false,
          isStreaming: false,
          error: userFriendlyError(event.messaggio),
        );

      case AzioneEvent():
        final onboardingQ = event.asOnboardingDomanda;
        if (onboardingQ != null) {
          state = state.copyWith(currentQuestion: onboardingQ);
        }

      // Eventi non rilevanti per l'onboarding — ignorati
      case SessioneCreataEvent():
      case AchievementEvent():
      case EsitoEsercizioEvent():
      case PromozioneEvent():
      case ReconnectingEvent():
        break;
    }
  }

  /// Finalizes the current streaming text into a tutor message.
  void _finalizeTutorMessage() {
    if (state.currentTutorText.isNotEmpty) {
      state = state.copyWith(
        tutorMessages: [...state.tutorMessages, state.currentTutorText],
        currentTutorText: '',
      );
    }
  }

  /// Completes onboarding — saves profile and creates path.
  Future<void> completeOnboarding({
    Map<String, dynamic>? contestoPersonale,
    Map<String, dynamic>? preferenzeTutor,
  }) async {
    if (state.sessioneId == null) return;
    _cancelSubscription();
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _onboardingService.complete(
        sessioneId: state.sessioneId!,
        contestoPersonale: contestoPersonale,
        preferenzeTutor: preferenzeTutor,
      );
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        result: result,
      );
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore completamento onboarding';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  void _cancelSubscription() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  void clear() {
    _cancelSubscription();
    state = const OnboardingScreenState();
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingScreenState>((ref) {
  throw UnimplementedError(
    'onboardingProvider must be overridden with proper dependencies',
  );
});
