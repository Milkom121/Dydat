import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/sessione.dart';
import 'package:dydat/services/dio_client.dart';

class SessionService {
  final DioClient _client;

  SessionService({required DioClient client}) : _client = client;

  /// Starts a study session. The backend returns SSE stream.
  /// We request as plain text, parse the sessione_creata event to extract
  /// the session ID, then fetch full session via GET.
  ///
  /// If a 409 is returned (active session with <5 min inactivity), we extract
  /// the existing session ID and load it instead of failing.
  Future<Sessione> start({
    String tipo = 'media',
    int? durataPrevistaMin,
  }) async {
    final Map<String, dynamic> data = {'tipo': tipo};
    if (durataPrevistaMin != null) {
      data['durata_prevista_min'] = durataPrevistaMin;
    }

    // Accept 409 as valid so it bypasses the DioClient error interceptor
    // and we can handle the structured body in-band.
    final response = await _client.dio.post(
      ApiConfig.sessionStart,
      data: data,
      options: Options(
        responseType: ResponseType.plain,
        receiveTimeout: ApiConfig.sseTimeout,
        validateStatus: (status) =>
            (status != null && status >= 200 && status < 300) ||
            status == 409,
      ),
    );

    // Handle 409: active session with <5 min inactivity.
    // Body: {"sessione_id_esistente": "uuid", "messaggio": "..."}
    if (response.statusCode == 409) {
      final existingId = _extractExistingSessionId(response);
      if (existingId != null) {
        return get(existingId);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Sessione attiva esistente',
      );
    }

    // Parse SSE text to extract sessione_creata event data.
    final sseData = _parseSessioneCreataFromSse(response.data as String);
    final sessioneId = sseData?['sessione_id'] as String?;
    if (sessioneId != null) {
      final session = await get(sessioneId);
      // The GET may not return nodo_focale_nome, but the SSE event has nodo_nome.
      // Merge the SSE data into the session if GET returned null for the name.
      if (session.nodoFocaleNome == null && sseData?['nodo_nome'] != null) {
        return Sessione(
          id: session.id,
          stato: session.stato,
          tipo: session.tipo,
          nodoFocaleId: session.nodoFocaleId ?? sseData?['nodo_id'] as String?,
          nodoFocaleNome: sseData!['nodo_nome'] as String?,
          attivitaCorrente: session.attivitaCorrente,
          durataPrevistaMin: session.durataPrevistaMin,
          durataEffettivaMin: session.durataEffettivaMin,
          nodiLavorati: session.nodiLavorati,
        );
      }
      return session;
    }

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Impossibile estrarre sessione_id dalla risposta SSE',
    );
  }

  /// Extracts the existing session ID from a 409 response.
  /// The response body can be a JSON string (ResponseType.plain) or a Map.
  /// Handles both flat body and FastAPI-style {"detail": {...}} wrapper.
  String? _extractExistingSessionId(Response<dynamic>? response) {
    if (response?.data == null) return null;
    try {
      Map<String, dynamic> body;
      if (response!.data is String) {
        final str = (response.data as String).trim();
        if (str.isEmpty) return null;
        body = jsonDecode(str) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        body = response.data as Map<String, dynamic>;
      } else {
        return null;
      }

      // Direct field
      if (body.containsKey('sessione_id_esistente')) {
        return body['sessione_id_esistente'] as String?;
      }

      // FastAPI wraps HTTPException in {"detail": ...}
      final detail = body['detail'];
      if (detail is Map<String, dynamic> &&
          detail.containsKey('sessione_id_esistente')) {
        return detail['sessione_id_esistente'] as String?;
      }

      // detail might be a JSON-encoded string itself
      if (detail is String) {
        try {
          final parsed = jsonDecode(detail) as Map<String, dynamic>;
          return parsed['sessione_id_esistente'] as String?;
        } catch (_) {}
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Parse SSE text to find the sessione_creata event data.
  /// Returns the full JSON map with sessione_id, nodo_id, nodo_nome.
  Map<String, dynamic>? _parseSessioneCreataFromSse(String sseText) {
    final lines = sseText.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim() == 'event: sessione_creata' && i + 1 < lines.length) {
        final dataLine = lines[i + 1].trim();
        if (dataLine.startsWith('data: ')) {
          try {
            return jsonDecode(dataLine.substring(6)) as Map<String, dynamic>;
          } catch (_) {}
        }
      }
    }
    return null;
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
