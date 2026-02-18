import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/models/sessione.dart';
import 'package:dydat/services/session_service.dart';

class SessionScreenState {
  final Sessione? activeSession;
  final List<String> tutorMessages;
  final bool isLoading;
  final String? error;

  const SessionScreenState({
    this.activeSession,
    this.tutorMessages = const [],
    this.isLoading = false,
    this.error,
  });

  SessionScreenState copyWith({
    Sessione? activeSession,
    List<String>? tutorMessages,
    bool? isLoading,
    String? error,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return SessionScreenState(
      activeSession:
          clearSession ? null : (activeSession ?? this.activeSession),
      tutorMessages: tutorMessages ?? this.tutorMessages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SessionNotifier extends StateNotifier<SessionScreenState> {
  final SessionService _sessionService;

  SessionNotifier({required SessionService sessionService})
      : _sessionService = sessionService,
        super(const SessionScreenState());

  /// Creates a new study session via REST.
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

  /// Sets the active session from an SSE sessione_creata event.
  void setActiveSession(Sessione session) {
    state = state.copyWith(activeSession: session);
  }

  /// Adds a tutor message fragment (from text_delta events).
  void addTutorMessage(String text) {
    state = state.copyWith(
      tutorMessages: [...state.tutorMessages, text],
    );
  }

  /// Sends a student turn.
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
    state = const SessionScreenState();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionScreenState>((ref) {
  throw UnimplementedError(
    'sessionProvider must be overridden with proper dependencies',
  );
});
