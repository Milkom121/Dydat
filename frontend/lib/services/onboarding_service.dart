import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/onboarding.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/sse_client.dart';

class OnboardingService {
  final DioClient _client;
  final SseClient _sseClient;

  OnboardingService({
    required DioClient client,
    required SseClient sseClient,
  })  : _client = client,
        _sseClient = sseClient;

  /// Starts onboarding via SSE streaming.
  /// Returns a stream with onboarding_iniziato, text_delta, turno_completo.
  /// No authentication required.
  Stream<SseEvent> startStream() {
    return _sseClient.stream(
      ApiConfig.onboardingStart,
      authenticated: false,
    );
  }

  /// Sends a student message during onboarding via SSE streaming.
  /// Returns a stream with text_delta, turno_completo.
  /// No authentication required.
  Stream<SseEvent> sendTurnStream({
    required String sessioneId,
    required String messaggio,
  }) {
    return _sseClient.stream(
      ApiConfig.onboardingTurn,
      body: {
        'sessione_id': sessioneId,
        'messaggio': messaggio,
      },
      authenticated: false,
    );
  }

  /// Recupera lo stato di una sessione onboarding attiva per ripresa.
  /// Restituisce sessione_id, fase corrente, campi completi e storico turni.
  /// Lancia DioException se nessuna sessione attiva (404).
  Future<OnboardingRipresaResponse> getResumeState({
    required String utenteId,
  }) async {
    final response = await _client.dio.get(
      ApiConfig.onboardingResume(utenteId),
    );
    return OnboardingRipresaResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Completes onboarding — saves profile, creates path, initializes node states.
  Future<OnboardingCompletaResponse> complete({
    required String sessioneId,
    Map<String, dynamic>? contestoPersonale,
    Map<String, dynamic>? preferenzeTutor,
  }) async {
    final response = await _client.dio.post(
      ApiConfig.onboardingComplete,
      data: OnboardingCompletaRequest(
        sessioneId: sessioneId,
        contestoPersonale: contestoPersonale,
        preferenzeTutor: preferenzeTutor,
      ).toJson(),
    );
    return OnboardingCompletaResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
