import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart' hide AchievementEvent;
import 'package:dydat/models/sessione.dart'
    hide SessioneCreataEvent, TextDeltaEvent, AzioneEvent, TurnoCompletoEvent;
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/services/session_service.dart';

class SessionScreenState {
  final Sessione? activeSession;
  final List<String> tutorMessages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;

  /// Text being accumulated during SSE streaming (grows with each text_delta).
  final String currentTutorText;

  /// Actions received during the current turn.
  final List<AzioneEvent> currentTurnActions;

  /// Achievements received during the current turn.
  final List<AchievementEvent> currentTurnAchievements;

  const SessionScreenState({
    this.activeSession,
    this.tutorMessages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
    this.currentTutorText = '',
    this.currentTurnActions = const [],
    this.currentTurnAchievements = const [],
  });

  SessionScreenState copyWith({
    Sessione? activeSession,
    List<String>? tutorMessages,
    bool? isLoading,
    bool? isStreaming,
    String? error,
    String? currentTutorText,
    List<AzioneEvent>? currentTurnActions,
    List<AchievementEvent>? currentTurnAchievements,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return SessionScreenState(
      activeSession:
          clearSession ? null : (activeSession ?? this.activeSession),
      tutorMessages: tutorMessages ?? this.tutorMessages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : (error ?? this.error),
      currentTutorText: currentTutorText ?? this.currentTutorText,
      currentTurnActions: currentTurnActions ?? this.currentTurnActions,
      currentTurnAchievements:
          currentTurnAchievements ?? this.currentTurnAchievements,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionScreenState> {
  final SessionService _sessionService;
  StreamSubscription<SseEvent>? _sseSubscription;

  SessionNotifier({required SessionService sessionService})
      : _sessionService = sessionService,
        super(const SessionScreenState());

  /// Starts a study session via SSE streaming.
  ///
  /// Listens to the stream and processes each event:
  /// - sessione_creata → sets activeSession
  /// - text_delta → accumulates text in currentTutorText
  /// - azione → adds to currentTurnActions
  /// - achievement → adds to currentTurnAchievements
  /// - turno_completo → finalizes the tutor message, updates nodoFocale
  /// - errore → sets error, stream ends
  Future<void> startSessionStream({int? durataPrevistaMin}) async {
    _cancelSubscription();
    state = state.copyWith(
      isLoading: true,
      isStreaming: false,
      clearError: true,
      currentTutorText: '',
      currentTurnActions: const [],
      currentTurnAchievements: const [],
      tutorMessages: [],
    );

    final stream = _sessionService.startStream(
      durataPrevistaMin: durataPrevistaMin,
    );

    _listenToStream(stream, handle409: true);
  }

  /// Sends a student message and listens to SSE streaming response.
  Future<void> sendTurnStream(String messaggio) async {
    if (state.activeSession == null) return;
    _cancelSubscription();
    state = state.copyWith(
      isStreaming: true,
      clearError: true,
      currentTutorText: '',
      currentTurnActions: const [],
      currentTurnAchievements: const [],
    );

    final stream = _sessionService.sendTurnStream(
      sessioneId: state.activeSession!.id,
      messaggio: messaggio,
    );

    _listenToStream(stream);
  }

  void _listenToStream(Stream<SseEvent> stream, {bool handle409 = false}) {
    _sseSubscription = stream.listen(
      (event) => _handleSseEvent(event, handle409: handle409),
      onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          isStreaming: false,
          error: 'Errore stream: $error',
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

  void _handleSseEvent(SseEvent event, {bool handle409 = false}) {
    switch (event) {
      case SessioneCreataEvent():
        final session = Sessione(
          id: event.sessioneId,
          stato: 'attiva',
          nodoFocaleId: event.nodoId,
          nodoFocaleNome: event.nodoNome,
        );
        state = state.copyWith(
          activeSession: session,
          isLoading: false,
          isStreaming: true,
        );

      case TextDeltaEvent():
        state = state.copyWith(
          currentTutorText: state.currentTutorText + event.testo,
          isStreaming: true,
        );

      case AzioneEvent():
        state = state.copyWith(
          currentTurnActions: [...state.currentTurnActions, event],
        );

      case AchievementEvent():
        state = state.copyWith(
          currentTurnAchievements: [...state.currentTurnAchievements, event],
        );

      case TurnoCompletoEvent():
        _finalizeTutorMessage();
        // Update nodoFocale if changed
        if (event.nodoFocale != null && state.activeSession != null) {
          state = state.copyWith(
            activeSession: Sessione(
              id: state.activeSession!.id,
              stato: state.activeSession!.stato,
              tipo: state.activeSession!.tipo,
              nodoFocaleId: event.nodoFocale,
              nodoFocaleNome: state.activeSession!.nodoFocaleNome,
              attivitaCorrente: state.activeSession!.attivitaCorrente,
              durataPrevistaMin: state.activeSession!.durataPrevistaMin,
              durataEffettivaMin: state.activeSession!.durataEffettivaMin,
              nodiLavorati: state.activeSession!.nodiLavorati,
            ),
            isStreaming: false,
          );
        } else {
          state = state.copyWith(isStreaming: false);
        }

      case ErroreEvent():
        // Handle 409: active session exists — fall back to REST start()
        if (handle409 && event.codice == 'http_409') {
          _cancelSubscription();
          startSession();
          return;
        }
        state = state.copyWith(
          isLoading: false,
          isStreaming: false,
          error: event.messaggio,
        );

      case OnboardingIniziatoEvent():
        // Not handled in session — this is for onboarding
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

  void _cancelSubscription() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  /// Creates a new study session via REST (fallback).
  Future<void> startSession({int? durataPrevistaMin}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _sessionService.start(
        durataPrevistaMin: durataPrevistaMin,
      );
      state = state.copyWith(
        activeSession: session,
        isLoading: false,
        tutorMessages: [],
      );
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore creazione sessione';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Sets the active session.
  void setActiveSession(Sessione session) {
    state = state.copyWith(activeSession: session);
  }

  /// Adds a tutor message (used for finalized messages).
  void addTutorMessage(String text) {
    state = state.copyWith(
      tutorMessages: [...state.tutorMessages, text],
    );
  }

  /// Sends a student turn via REST (fallback).
  Future<void> sendTurn(String messaggio) async {
    if (state.activeSession == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _sessionService.sendTurn(
        sessioneId: state.activeSession!.id,
        messaggio: messaggio,
      );
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore invio messaggio';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Suspends the active session.
  Future<void> suspend() async {
    if (state.activeSession == null) return;
    _cancelSubscription();
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session =
          await _sessionService.suspend(state.activeSession!.id);
      state = state.copyWith(activeSession: session, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore sospensione sessione';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Ends the active session.
  Future<void> endSession() async {
    if (state.activeSession == null) return;
    _cancelSubscription();
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _sessionService.end(state.activeSession!.id);
      state = state.copyWith(activeSession: session, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore terminazione sessione';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Loads a session by ID.
  Future<void> loadSession(String sessioneId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _sessionService.get(sessioneId);
      state = state.copyWith(activeSession: session, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento sessione';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  void clear() {
    _cancelSubscription();
    state = const SessionScreenState();
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionScreenState>((ref) {
  throw UnimplementedError(
    'sessionProvider must be overridden with proper dependencies',
  );
});
