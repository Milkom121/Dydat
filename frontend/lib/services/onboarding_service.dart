import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/onboarding.dart';
import 'package:dydat/services/dio_client.dart';

class OnboardingService {
  final DioClient _client;

  OnboardingService({required DioClient client}) : _client = client;

  /// Starts onboarding. Returns SSE stream in real backend,
  /// but for REST-only phase we POST and expect non-streaming fallback.
  /// The SSE streaming will be implemented in a future loop.
  /// For now, this just makes the POST call.
  Future<void> start() async {
    await _client.dio.post(ApiConfig.onboardingStart);
  }

  /// Sends a student message during onboarding.
  Future<void> sendTurn({
    required String sessioneId,
    required String messaggio,
  }) async {
    await _client.dio.post(
      ApiConfig.onboardingTurn,
      data: OnboardingTurnoRequest(
        sessioneId: sessioneId,
        messaggio: messaggio,
      ).toJson(),
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
