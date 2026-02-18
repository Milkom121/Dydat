import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart' hide AchievementEvent;
import 'package:dydat/models/onboarding.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/storage_service.dart';

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
  });

  /// Progress from 0.0 to 1.0 based on turns completed (~10 turns total).
  double get progress => (turnsCompleted / 10).clamp(0.0, 1.0);

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
    );

    final stream = _onboardingService.sendTurnStream(
      sessioneId: state.sessioneId!,
      messaggio: message,
    );
    _listenToStream(stream);
  }

  void _listenToStream(Stream<SseEvent> stream) {
    _sseSubscription = stream.listen(
      _handleSseEvent,
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

      case ErroreEvent():
        state = state.copyWith(
          isLoading: false,
          isStreaming: false,
          error: event.messaggio,
        );

      // Events not relevant to onboarding — ignore
      case SessioneCreataEvent():
      case AzioneEvent():
      case AchievementEvent():
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
