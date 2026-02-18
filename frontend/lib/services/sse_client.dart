import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/services/storage_service.dart';

/// Raw parsed SSE frame before deserialization into typed [SseEvent].
class RawSseEvent {
  final String event;
  final String data;

  const RawSseEvent({required this.event, required this.data});
}

/// Generic SSE client for the Dydat backend.
///
/// Uses the `http` package (not Dio) because Dio does not support line-by-line
/// streaming of `text/event-stream` responses.
///
/// Usage:
/// ```dart
/// final client = SseClient(storageService: storageService);
/// final stream = client.stream('/sessione/inizia', body: {'tipo': 'media'});
/// await for (final event in stream) {
///   switch (event) {
///     case TextDeltaEvent(:final testo):
///       print(testo);
///     case TurnoCompletoEvent():
///       break;
///     // ...
///   }
/// }
/// ```
class SseClient {
  final StorageService _storageService;
  final http.Client _httpClient;
  final Duration _timeout;

  SseClient({
    required StorageService storageService,
    http.Client? httpClient,
    Duration? timeout,
  })  : _storageService = storageService,
        _httpClient = httpClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 120);

  /// Sends a POST request to [path] and returns a stream of typed [SseEvent]s.
  ///
  /// The [path] is relative to [ApiConfig.baseUrl] (e.g. `/sessione/inizia`).
  /// The [body] is JSON-encoded and sent as the request body.
  /// Set [authenticated] to `false` for unauthenticated endpoints (onboarding).
  Stream<SseEvent> stream(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async* {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    };

    if (authenticated) {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final request = http.Request('POST', uri)
      ..headers.addAll(headers);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final http.StreamedResponse response;
    try {
      response = await _httpClient.send(request).timeout(_timeout);
    } on TimeoutException {
      yield const ErroreEvent(
        codice: 'timeout',
        messaggio: 'Timeout connessione al server',
      );
      return;
    } catch (e) {
      yield ErroreEvent(
        codice: 'connection_error',
        messaggio: 'Errore di connessione: $e',
      );
      return;
    }

    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      yield ErroreEvent(
        codice: 'http_${response.statusCode}',
        messaggio: _extractErrorMessage(response.statusCode, responseBody),
      );
      return;
    }

    yield* _parseStream(response.stream);
  }

  /// Parses a byte stream of SSE data into typed [SseEvent]s.
  Stream<SseEvent> _parseStream(Stream<List<int>> byteStream) async* {
    yield* parseRawStream(byteStream).transform(_typedEventTransformer());
  }

  /// Parses a byte stream into [RawSseEvent]s.
  ///
  /// Exposed for testing: tests can verify raw parsing without typed conversion.
  static Stream<RawSseEvent> parseRawStream(Stream<List<int>> byteStream) {
    return byteStream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .transform(sseLineTransformer());
  }

  /// Transforms [RawSseEvent]s into typed [SseEvent]s, filtering out nulls.
  static StreamTransformer<RawSseEvent, SseEvent> _typedEventTransformer() {
    return StreamTransformer.fromHandlers(
      handleData: (RawSseEvent raw, EventSink<SseEvent> sink) {
        final typed = SseEvent.fromRawEvent(raw.event, raw.data);
        if (typed != null) {
          sink.add(typed);
        }
      },
    );
  }

  /// Extracts a user-friendly error message from the HTTP response.
  String _extractErrorMessage(int statusCode, String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      // FastAPI error format
      if (json.containsKey('detail')) {
        final detail = json['detail'];
        if (detail is String) return detail;
        if (detail is Map<String, dynamic>) {
          return detail['messaggio'] as String? ?? body;
        }
      }
      if (json.containsKey('messaggio')) {
        return json['messaggio'] as String;
      }
    } catch (_) {}
    return 'Errore HTTP $statusCode';
  }
}

/// Transforms a stream of SSE lines into [RawSseEvent]s.
///
/// Public so it can be used in tests.
StreamTransformer<String, RawSseEvent> sseLineTransformer() {
  String? currentEvent;
  StringBuffer dataBuffer = StringBuffer();

  return StreamTransformer.fromHandlers(
    handleData: (String line, EventSink<RawSseEvent> sink) {
      if (line.startsWith('event: ')) {
        currentEvent = line.substring(7).trim();
      } else if (line.startsWith('data: ')) {
        if (dataBuffer.isNotEmpty) {
          dataBuffer.write('\n');
        }
        dataBuffer.write(line.substring(6));
      } else if (line.trim().isEmpty) {
        // Empty line = end of event
        if (currentEvent != null && dataBuffer.isNotEmpty) {
          sink.add(RawSseEvent(
            event: currentEvent!,
            data: dataBuffer.toString(),
          ));
        }
        currentEvent = null;
        dataBuffer = StringBuffer();
      }
    },
    handleDone: (EventSink<RawSseEvent> sink) {
      // Flush any pending event
      if (currentEvent != null && dataBuffer.isNotEmpty) {
        sink.add(RawSseEvent(
          event: currentEvent!,
          data: dataBuffer.toString(),
        ));
      }
      sink.close();
    },
  );
}
