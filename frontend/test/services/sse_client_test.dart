import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/services/sse_client.dart';

/// Helper: converts a raw SSE text into a byte stream (simulating HTTP response).
Stream<List<int>> _sseTextToByteStream(String sseText) {
  return Stream.value(utf8.encode(sseText));
}

void main() {
  group('sseLineTransformer', () {
    test('parses a single event', () async {
      final lines = Stream.fromIterable([
        'event: text_delta',
        'data: {"testo": "Ciao"}',
        '',
      ]);

      final events = await lines.transform(sseLineTransformer()).toList();

      expect(events, hasLength(1));
      expect(events[0].event, 'text_delta');
      expect(events[0].data, '{"testo": "Ciao"}');
    });

    test('parses multiple events', () async {
      final lines = Stream.fromIterable([
        'event: sessione_creata',
        'data: {"sessione_id": "abc"}',
        '',
        'event: text_delta',
        'data: {"testo": "Hello"}',
        '',
        'event: turno_completo',
        'data: {"turno_id": 1, "nodo_focale": null}',
        '',
      ]);

      final events = await lines.transform(sseLineTransformer()).toList();

      expect(events, hasLength(3));
      expect(events[0].event, 'sessione_creata');
      expect(events[1].event, 'text_delta');
      expect(events[2].event, 'turno_completo');
    });

    test('flushes pending event on stream close', () async {
      final lines = Stream.fromIterable([
        'event: text_delta',
        'data: {"testo": "Hello"}',
        // No trailing empty line — stream closes
      ]);

      final events = await lines.transform(sseLineTransformer()).toList();

      expect(events, hasLength(1));
      expect(events[0].event, 'text_delta');
    });

    test('ignores lines without event or data prefix', () async {
      final lines = Stream.fromIterable([
        ': comment line',
        'event: text_delta',
        'id: 123',
        'data: {"testo": "Hi"}',
        '',
      ]);

      final events = await lines.transform(sseLineTransformer()).toList();

      expect(events, hasLength(1));
      expect(events[0].data, '{"testo": "Hi"}');
    });

    test('skips empty events (no event type)', () async {
      final lines = Stream.fromIterable([
        'data: {"testo": "orphan data"}',
        '',
        'event: text_delta',
        'data: {"testo": "good"}',
        '',
      ]);

      final events = await lines.transform(sseLineTransformer()).toList();

      expect(events, hasLength(1));
      expect(events[0].event, 'text_delta');
    });

    test('skips events with no data', () async {
      final lines = Stream.fromIterable([
        'event: keep_alive',
        '',
        'event: text_delta',
        'data: {"testo": "ok"}',
        '',
      ]);

      final events = await lines.transform(sseLineTransformer()).toList();

      expect(events, hasLength(1));
      expect(events[0].event, 'text_delta');
    });
  });

  group('SseClient.parseRawStream', () {
    test('parses a full SSE turn from byte stream', () async {
      const sseText = 'event: sessione_creata\n'
          'data: {"sessione_id": "abc-123", "nodo_id": "deriv", "nodo_nome": "Derivata"}\n'
          '\n'
          'event: text_delta\n'
          'data: {"testo": "Ciao! "}\n'
          '\n'
          'event: text_delta\n'
          'data: {"testo": "Oggi parliamo di derivate."}\n'
          '\n'
          'event: azione\n'
          'data: {"tipo": "proponi_esercizio", "params": {"esercizio_id": "es_01", "testo": "Calcola la derivata di f(x)", "difficolta": 2, "nodo_id": "deriv"}}\n'
          '\n'
          'event: achievement\n'
          'data: {"id": "primo_nodo", "nome": "Primo passo!", "tipo": "sigillo"}\n'
          '\n'
          'event: turno_completo\n'
          'data: {"turno_id": 1, "nodo_focale": "deriv"}\n'
          '\n';

      final byteStream = _sseTextToByteStream(sseText);
      final rawEvents = await SseClient.parseRawStream(byteStream).toList();

      expect(rawEvents, hasLength(6));
      expect(rawEvents[0].event, 'sessione_creata');
      expect(rawEvents[1].event, 'text_delta');
      expect(rawEvents[2].event, 'text_delta');
      expect(rawEvents[3].event, 'azione');
      expect(rawEvents[4].event, 'achievement');
      expect(rawEvents[5].event, 'turno_completo');
    });

    test('parses onboarding flow from byte stream', () async {
      const sseText = 'event: onboarding_iniziato\n'
          'data: {"utente_temp_id": "temp-uuid", "sessione_id": "sess-uuid"}\n'
          '\n'
          'event: text_delta\n'
          'data: {"testo": "Benvenuto!"}\n'
          '\n'
          'event: turno_completo\n'
          'data: {"turno_id": 1, "nodo_focale": null}\n'
          '\n';

      final byteStream = _sseTextToByteStream(sseText);
      final rawEvents = await SseClient.parseRawStream(byteStream).toList();

      expect(rawEvents, hasLength(3));
      expect(rawEvents[0].event, 'onboarding_iniziato');
      expect(rawEvents[1].event, 'text_delta');
      expect(rawEvents[2].event, 'turno_completo');
    });

    test('parses error event from byte stream', () async {
      const sseText = 'event: errore\n'
          'data: {"codice": "llm_error", "messaggio": "Timeout dopo 60s"}\n'
          '\n';

      final byteStream = _sseTextToByteStream(sseText);
      final rawEvents = await SseClient.parseRawStream(byteStream).toList();

      expect(rawEvents, hasLength(1));
      expect(rawEvents[0].event, 'errore');
    });
  });

  group('Full SSE pipeline: bytes → typed events', () {
    test('full study session turn produces correct typed events', () async {
      const sseText = 'event: sessione_creata\n'
          'data: {"sessione_id": "s-123", "nodo_id": "n-1", "nodo_nome": "Nodo Uno"}\n'
          '\n'
          'event: text_delta\n'
          'data: {"testo": "Parte 1 "}\n'
          '\n'
          'event: text_delta\n'
          'data: {"testo": "Parte 2"}\n'
          '\n'
          'event: azione\n'
          'data: {"tipo": "mostra_formula", "params": {"latex": "x^2", "etichetta": "Quadrato"}}\n'
          '\n'
          'event: turno_completo\n'
          'data: {"turno_id": 1, "nodo_focale": "n-1"}\n'
          '\n';

      final byteStream = _sseTextToByteStream(sseText);

      // Convert raw to typed
      final rawEvents = await SseClient.parseRawStream(byteStream).toList();
      final typedEvents = rawEvents
          .map((raw) => SseEvent.fromRawEvent(raw.event, raw.data))
          .whereType<SseEvent>()
          .toList();

      expect(typedEvents, hasLength(5));

      // Verify types and content
      expect(typedEvents[0], isA<SessioneCreataEvent>());
      expect((typedEvents[0] as SessioneCreataEvent).sessioneId, 's-123');

      expect(typedEvents[1], isA<TextDeltaEvent>());
      expect((typedEvents[1] as TextDeltaEvent).testo, 'Parte 1 ');

      expect(typedEvents[2], isA<TextDeltaEvent>());
      expect((typedEvents[2] as TextDeltaEvent).testo, 'Parte 2');

      expect(typedEvents[3], isA<AzioneEvent>());
      final azione = typedEvents[3] as AzioneEvent;
      expect(azione.tipo, 'mostra_formula');
      expect(azione.asMostraFormula!.latex, 'x^2');

      expect(typedEvents[4], isA<TurnoCompletoEvent>());
      expect((typedEvents[4] as TurnoCompletoEvent).turnoId, 1);

      // Concatenation test
      final fullText = typedEvents
          .whereType<TextDeltaEvent>()
          .map((e) => e.testo)
          .join();
      expect(fullText, 'Parte 1 Parte 2');
    });

    test('turn with all action types', () async {
      const sseText = 'event: azione\n'
          'data: {"tipo": "proponi_esercizio", "params": {"esercizio_id": "e1", "testo": "Solve", "difficolta": 3, "nodo_id": "n1"}}\n'
          '\n'
          'event: azione\n'
          'data: {"tipo": "mostra_formula", "params": {"latex": "E=mc^2", "etichetta": "Einstein"}}\n'
          '\n'
          'event: azione\n'
          'data: {"tipo": "suggerisci_backtrack", "params": {"nodo_id": "n0", "motivo": "Basi mancanti"}}\n'
          '\n'
          'event: azione\n'
          'data: {"tipo": "chiudi_sessione", "params": {"riepilogo": "Bravo!", "prossimi_passi": "Integrali"}}\n'
          '\n';

      final byteStream = _sseTextToByteStream(sseText);
      final rawEvents = await SseClient.parseRawStream(byteStream).toList();
      final typedEvents = rawEvents
          .map((raw) => SseEvent.fromRawEvent(raw.event, raw.data))
          .whereType<SseEvent>()
          .toList();

      expect(typedEvents, hasLength(4));

      final a0 = typedEvents[0] as AzioneEvent;
      expect(a0.asProponiEsercizio!.esercizioId, 'e1');
      expect(a0.asProponiEsercizio!.difficolta, 3);

      final a1 = typedEvents[1] as AzioneEvent;
      expect(a1.asMostraFormula!.latex, 'E=mc^2');

      final a2 = typedEvents[2] as AzioneEvent;
      expect(a2.asSuggerisciBacktrack!.nodoId, 'n0');
      expect(a2.asSuggerisciBacktrack!.motivo, 'Basi mancanti');

      final a3 = typedEvents[3] as AzioneEvent;
      expect(a3.asChiudiSessione!.riepilogo, 'Bravo!');
      expect(a3.asChiudiSessione!.prossimiPassi, 'Integrali');
    });

    test('handles chunked byte stream (realistic network delivery)', () async {
      const sseText = 'event: text_delta\n'
          'data: {"testo": "Hello"}\n'
          '\n'
          'event: turno_completo\n'
          'data: {"turno_id": 1, "nodo_focale": null}\n'
          '\n';

      // Simulate chunked delivery: split the text into small chunks
      final bytes = utf8.encode(sseText);
      final chunkSize = 10;
      final chunks = <List<int>>[];
      for (var i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize;
        chunks.add(bytes.sublist(i, end));
      }

      final byteStream = Stream.fromIterable(chunks);
      final rawEvents = await SseClient.parseRawStream(byteStream).toList();

      expect(rawEvents, hasLength(2));
      expect(rawEvents[0].event, 'text_delta');
      expect(rawEvents[1].event, 'turno_completo');
    });

    test('turn with multiple achievements', () async {
      const sseText = 'event: text_delta\n'
          'data: {"testo": "Complimenti!"}\n'
          '\n'
          'event: achievement\n'
          'data: {"id": "primo_nodo", "nome": "Primo passo!", "tipo": "sigillo"}\n'
          '\n'
          'event: achievement\n'
          'data: {"id": "dieci_esercizi", "nome": "Pratica costante", "tipo": "sigillo"}\n'
          '\n'
          'event: turno_completo\n'
          'data: {"turno_id": 3, "nodo_focale": "algebra"}\n'
          '\n';

      final byteStream = _sseTextToByteStream(sseText);
      final rawEvents = await SseClient.parseRawStream(byteStream).toList();
      final typedEvents = rawEvents
          .map((raw) => SseEvent.fromRawEvent(raw.event, raw.data))
          .whereType<SseEvent>()
          .toList();

      expect(typedEvents, hasLength(4));

      final achievements = typedEvents.whereType<AchievementEvent>().toList();
      expect(achievements, hasLength(2));
      expect(achievements[0].id, 'primo_nodo');
      expect(achievements[1].id, 'dieci_esercizi');
    });
  });
}
