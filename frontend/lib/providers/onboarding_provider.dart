import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/models/onboarding.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/storage_service.dart';

class OnboardingScreenState {
  final String? sessioneId;
  final String? utenteTempId;
  final List<String> messages;
  final bool isLoading;
  final bool isCompleted;
  final OnboardingCompletaResponse? result;
  final String? error;

  const OnboardingScreenState({
    this.sessioneId,
    this.utenteTempId,
    this.messages = const [],
    this.isLoading = false,
    this.isCompleted = false,
    this.result,
    this.error,
  });

  OnboardingScreenState copyWith({
    String? sessioneId,
    String? utenteTempId,
    List<String>? messages,
    bool? isLoading,
    bool? isCompleted,
    OnboardingCompletaResponse? result,
    String? error,
    bool clearError = false,
  }) {
    return OnboardingScreenState(
      sessioneId: sessioneId ?? this.sessioneId,
      utenteTempId: utenteTempId ?? this.utenteTempId,
      messages: messages ?? this.messages,
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

  OnboardingNotifier({
    required OnboardingService onboardingService,
    required StorageService storageService,
  })  : _onboardingService = onboardingService,
        _storageService = storageService,
        super(const OnboardingScreenState());

  /// Sets the session/temp IDs from the SSE onboarding_iniziato event.
  void setIds({required String sessioneId, required String utenteTempId}) {
    state = state.copyWith(
      sessioneId: sessioneId,
      utenteTempId: utenteTempId,
    );
    _storageService.saveUtenteTempId(utenteTempId);
  }

  /// Adds a tutor message to the local list.
  void addTutorMessage(String text) {
    state = state.copyWith(messages: [...state.messages, text]);
  }

  /// Sends a student turn.
  Future<void> sendMessage(String message) async {
    if (state.sessioneId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _onboardingService.sendTurn(
        sessioneId: state.sessioneId!,
        messaggio: message,
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

  /// Completes onboarding — saves profile and creates path.
  Future<void> complete({
    Map<String, dynamic>? contestoPersonale,
    Map<String, dynamic>? preferenzeTutor,
  }) async {
    if (state.sessioneId == null) return;
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

  void clear() {
    state = const OnboardingScreenState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingScreenState>((ref) {
  throw UnimplementedError(
    'onboardingProvider must be overridden with proper dependencies',
  );
});
