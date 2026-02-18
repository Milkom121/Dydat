import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/sessione.dart';
import 'package:dydat/services/dio_client.dart';

class SessionService {
  final DioClient _client;

  SessionService({required DioClient client}) : _client = client;

  /// Starts a study session. SSE streaming will be added in a future loop.
  /// For now, makes the POST call. The backend returns SSE but we handle
  /// the initial event in the provider layer.
  Future<void> start({
    String tipo = 'media',
    int? durataPrevistaMin,
  }) async {
    final Map<String, dynamic> data = {'tipo': tipo};
    if (durataPrevistaMin != null) {
      data['durata_prevista_min'] = durataPrevistaMin;
    }
    await _client.dio.post(ApiConfig.sessionStart, data: data);
  }

  /// Sends a student message during a session.
  Future<void> sendTurn({
    required String sessioneId,
    required String messaggio,
  }) async {
    await _client.dio.post(
      ApiConfig.sessionTurn(sessioneId),
      data: MessaggioUtente(messaggio: messaggio).toJson(),
    );
  }

  /// Suspends the active session.
  Future<Sessione> suspend(String sessioneId) async {
    final response = await _client.dio.post(
      ApiConfig.sessionSuspend(sessioneId),
    );
    return Sessione.fromJson(response.data as Map<String, dynamic>);
  }

  /// Ends the session. Backend updates stats and checks achievements.
  Future<Sessione> end(String sessioneId) async {
    final response = await _client.dio.post(
      ApiConfig.sessionEnd(sessioneId),
    );
    return Sessione.fromJson(response.data as Map<String, dynamic>);
  }

  /// Gets the current state of a session.
  Future<Sessione> get(String sessioneId) async {
    final response = await _client.dio.get(
      ApiConfig.sessionGet(sessioneId),
    );
    return Sessione.fromJson(response.data as Map<String, dynamic>);
  }
}
