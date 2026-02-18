import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sse_events.dart';

void main() {
  group('SseEvent.fromRawEvent', () {
    test('parses sessione_creata event', () {
      final event = SseEvent.fromRawEvent(
        'sessione_creata',
        '{"sessione_id": "abc-123", "nodo_id": "derivata_def", "nodo_nome": "Definizione di Derivata"}',
      );

      expect(event, isA<SessioneCreataEvent>());
      final e = event as SessioneCreataEvent;
      expect(e.sessioneId, 'abc-123');
      expect(e.nodoId, 'derivata_def');
      expect(e.nodoNome, 'Definizione di Derivata');
    });

    test('parses sessione_creata with null optional fields', () {
      final event = SseEvent.fromRawEvent(
        'sessione_creata',
        '{"sessione_id": "abc-123"}',
      );

      expect(event, isA<SessioneCreataEvent>());
      final e = event as SessioneCreataEvent;
      expect(e.sessioneId, 'abc-123');
      expect(e.nodoId, isNull);
      expect(e.nodoNome, isNull);
    });

    test('parses onboarding_iniziato event', () {
      final event = SseEvent.fromRawEvent(
        'onboarding_iniziato',
        '{"utente_temp_id": "temp-uuid", "sessione_id": "sess-uuid"}',
      );

      expect(event, isA<OnboardingIniziatoEvent>());
      final e = event as OnboardingIniziatoEvent;
      expect(e.utenteTempId, 'temp-uuid');
      expect(e.sessioneId, 'sess-uuid');
    });

    test('parses text_delta event', () {
      final event = SseEvent.fromRawEvent(
        'text_delta',
        '{"testo": "Ciao! Oggi parliamo di "}',
      );

      expect(event, isA<TextDeltaEvent>());
      final e = event as TextDeltaEvent;
      expect(e.testo, 'Ciao! Oggi parliamo di ');
    });

    test('parses azione event — proponi_esercizio', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "proponi_esercizio", "params": {"esercizio_id": "es_01", "testo": "Calcola 2+2", "difficolta": 2, "nodo_id": "aritmetica"}}',
      );

      expect(event, isA<AzioneEvent>());
      final e = event as AzioneEvent;
      expect(e.tipo, 'proponi_esercizio');
      expect(e.params['esercizio_id'], 'es_01');

      final typed = e.asProponiEsercizio;
      expect(typed, isNotNull);
      expect(typed!.esercizioId, 'es_01');
      expect(typed.testo, 'Calcola 2+2');
      expect(typed.difficolta, 2);
      expect(typed.nodoId, 'aritmetica');
      expect(typed.nessunoDisponibile, false);
    });

    test('parses azione event — proponi_esercizio with nessuno_disponibile', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "proponi_esercizio", "params": {"nodo_id": "aritmetica", "nessun_esercizio_disponibile": true}}',
      );

      expect(event, isA<AzioneEvent>());
      final e = event as AzioneEvent;
      final typed = e.asProponiEsercizio!;
      expect(typed.nessunoDisponibile, true);
      expect(typed.esercizioId, isNull);
      expect(typed.testo, isNull);
    });

    test('parses azione event — mostra_formula', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "mostra_formula", "params": {"latex": "f(x) = x^2", "etichetta": "Formula quadratica"}}',
      );

      expect(event, isA<AzioneEvent>());
      final e = event as AzioneEvent;
      expect(e.tipo, 'mostra_formula');

      final typed = e.asMostraFormula;
      expect(typed, isNotNull);
      expect(typed!.latex, 'f(x) = x^2');
      expect(typed.etichetta, 'Formula quadratica');
    });

    test('parses azione event — suggerisci_backtrack', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "suggerisci_backtrack", "params": {"nodo_id": "algebra_base", "motivo": "Serve ripassare le basi"}}',
      );

      expect(event, isA<AzioneEvent>());
      final e = event as AzioneEvent;

      final typed = e.asSuggerisciBacktrack;
      expect(typed, isNotNull);
      expect(typed!.nodoId, 'algebra_base');
      expect(typed.motivo, 'Serve ripassare le basi');
    });

    test('parses azione event — chiudi_sessione', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "chiudi_sessione", "params": {"riepilogo": "Oggi abbiamo lavorato sulle derivate", "prossimi_passi": "Continua con gli integrali"}}',
      );

      expect(event, isA<AzioneEvent>());
      final e = event as AzioneEvent;

      final typed = e.asChiudiSessione;
      expect(typed, isNotNull);
      expect(typed!.riepilogo, 'Oggi abbiamo lavorato sulle derivate');
      expect(typed.prossimiPassi, 'Continua con gli integrali');
    });

    test('azione typed accessors return null for wrong tipo', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "proponi_esercizio", "params": {"esercizio_id": "es_01"}}',
      ) as AzioneEvent;

      expect(event.asProponiEsercizio, isNotNull);
      expect(event.asMostraFormula, isNull);
      expect(event.asSuggerisciBacktrack, isNull);
      expect(event.asChiudiSessione, isNull);
    });

    test('parses achievement event', () {
      final event = SseEvent.fromRawEvent(
        'achievement',
        '{"id": "primo_nodo", "nome": "Primo passo!", "tipo": "sigillo"}',
      );

      expect(event, isA<AchievementEvent>());
      final e = event as AchievementEvent;
      expect(e.id, 'primo_nodo');
      expect(e.nome, 'Primo passo!');
      expect(e.tipo, 'sigillo');
    });

    test('parses turno_completo event', () {
      final event = SseEvent.fromRawEvent(
        'turno_completo',
        '{"turno_id": 5, "nodo_focale": "derivata_definizione"}',
      );

      expect(event, isA<TurnoCompletoEvent>());
      final e = event as TurnoCompletoEvent;
      expect(e.turnoId, 5);
      expect(e.nodoFocale, 'derivata_definizione');
    });

    test('parses turno_completo with null nodo_focale', () {
      final event = SseEvent.fromRawEvent(
        'turno_completo',
        '{"turno_id": 1, "nodo_focale": null}',
      );

      expect(event, isA<TurnoCompletoEvent>());
      final e = event as TurnoCompletoEvent;
      expect(e.turnoId, 1);
      expect(e.nodoFocale, isNull);
    });

    test('parses errore event', () {
      final event = SseEvent.fromRawEvent(
        'errore',
        '{"codice": "llm_error", "messaggio": "Timeout dopo 60s"}',
      );

      expect(event, isA<ErroreEvent>());
      final e = event as ErroreEvent;
      expect(e.codice, 'llm_error');
      expect(e.messaggio, 'Timeout dopo 60s');
    });

    test('returns null for unknown event type', () {
      final event = SseEvent.fromRawEvent(
        'unknown_event',
        '{"foo": "bar"}',
      );
      expect(event, isNull);
    });

    test('returns null for invalid JSON', () {
      final event = SseEvent.fromRawEvent(
        'text_delta',
        'not valid json{{{',
      );
      expect(event, isNull);
    });

    test('returns null for empty JSON', () {
      final event = SseEvent.fromRawEvent(
        'text_delta',
        '',
      );
      expect(event, isNull);
    });
  });

  group('AzioneEvent — params edge cases', () {
    test('handles missing params gracefully', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "proponi_esercizio"}',
      );

      expect(event, isA<AzioneEvent>());
      final e = event as AzioneEvent;
      expect(e.params, isEmpty);
    });

    test('mostra_formula without etichetta', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "mostra_formula", "params": {"latex": "x^2"}}',
      );

      final typed = (event as AzioneEvent).asMostraFormula!;
      expect(typed.etichetta, isNull);
    });

    test('chiudi_sessione without prossimi_passi', () {
      final event = SseEvent.fromRawEvent(
        'azione',
        '{"tipo": "chiudi_sessione", "params": {"riepilogo": "Bene"}}',
      );

      final typed = (event as AzioneEvent).asChiudiSessione!;
      expect(typed.prossimiPassi, isNull);
    });
  });
}
