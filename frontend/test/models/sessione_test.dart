import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sessione.dart';

void main() {
  group('Sessione', () {
    final json = {
      'id': 'sess-uuid-123',
      'stato': 'attiva',
      'tipo': 'media',
      'nodo_focale_id': 'derivata_definizione',
      'nodo_focale_nome': 'Definizione di Derivata',
      'attivita_corrente': 'spiegazione',
      'durata_prevista_min': 30,
      'durata_effettiva_min': 15,
      'nodi_lavorati': ['derivata_definizione', 'derivata_regole'],
    };

    test('fromJson → toJson roundtrip', () {
      final s = Sessione.fromJson(json);
      expect(s.id, 'sess-uuid-123');
      expect(s.stato, 'attiva');
      expect(s.tipo, 'media');
      expect(s.nodoFocaleId, 'derivata_definizione');
      expect(s.nodoFocaleNome, 'Definizione di Derivata');
      expect(s.attivitaCorrente, 'spiegazione');
      expect(s.durataPrevistaMin, 30);
      expect(s.durataEffettivaMin, 15);
      expect(s.nodiLavorati, hasLength(2));

      final back = s.toJson();
      expect(back['nodo_focale_id'], 'derivata_definizione');
      expect(back['durata_prevista_min'], 30);
    });

    test('fromJson minimal', () {
      final s = Sessione.fromJson({'id': 'x', 'stato': 'sospesa'});
      expect(s.tipo, isNull);
      expect(s.nodoFocaleId, isNull);
      expect(s.nodiLavorati, isNull);
    });
  });

  group('MessaggioUtente', () {
    test('fromJson → toJson roundtrip', () {
      final json = {'messaggio': 'Ciao tutor!'};
      final m = MessaggioUtente.fromJson(json);
      expect(m.messaggio, 'Ciao tutor!');
      expect(m.toJson(), json);
    });
  });

  group('SessioneCreataEvent', () {
    test('fromJson → toJson roundtrip', () {
      final json = {
        'sessione_id': 'sess-123',
        'nodo_id': 'derivata_definizione',
        'nodo_nome': 'Definizione di Derivata',
      };
      final e = SessioneCreataEvent.fromJson(json);
      expect(e.sessioneId, 'sess-123');
      expect(e.nodoId, 'derivata_definizione');
      expect(e.nodoNome, 'Definizione di Derivata');

      final back = e.toJson();
      expect(back['sessione_id'], 'sess-123');
    });
  });

  group('TurnoCompletoEvent', () {
    test('fromJson → toJson roundtrip', () {
      final json = {'turno_id': 5, 'nodo_focale': 'derivata_definizione'};
      final e = TurnoCompletoEvent.fromJson(json);
      expect(e.turnoId, 5);
      expect(e.nodoFocale, 'derivata_definizione');

      final back = e.toJson();
      expect(back['turno_id'], 5);
    });
  });

  group('TextDeltaEvent', () {
    test('fromJson → toJson roundtrip', () {
      final json = {'testo': 'Ciao! Oggi parliamo di '};
      final e = TextDeltaEvent.fromJson(json);
      expect(e.testo, 'Ciao! Oggi parliamo di ');
      expect(e.toJson(), json);
    });
  });

  group('AzioneEvent', () {
    test('fromJson → toJson roundtrip', () {
      final json = {
        'tipo': 'proponi_esercizio',
        'params': {
          'esercizio_id': 'es_01',
          'testo': 'Calcola la derivata',
          'difficolta': 2,
          'nodo_id': 'derivata_definizione',
        },
      };
      final e = AzioneEvent.fromJson(json);
      expect(e.tipo, 'proponi_esercizio');
      expect(e.params['esercizio_id'], 'es_01');
      expect(e.params['difficolta'], 2);

      final back = e.toJson();
      expect(back['tipo'], 'proponi_esercizio');
    });
  });

  group('SessioneListItem', () {
    test('fromJson → toJson roundtrip full', () {
      final json = {
        'id': 'sess-uuid-456',
        'stato': 'completata',
        'tipo': 'media',
        'nodo_focale_id': 'potenza_numeri',
        'nodo_focale_nome': 'Potenza di un numero relativo',
        'durata_effettiva_min': 25,
        'nodi_lavorati': ['potenza_numeri', 'espressioni_algebriche'],
        'created_at': '2026-02-19T10:00:00+00:00',
        'completed_at': '2026-02-19T10:25:00+00:00',
      };
      final s = SessioneListItem.fromJson(json);
      expect(s.id, 'sess-uuid-456');
      expect(s.stato, 'completata');
      expect(s.tipo, 'media');
      expect(s.nodoFocaleId, 'potenza_numeri');
      expect(s.nodoFocaleNome, 'Potenza di un numero relativo');
      expect(s.durataEffettivaMin, 25);
      expect(s.nodiLavorati, hasLength(2));
      expect(s.createdAt, '2026-02-19T10:00:00+00:00');
      expect(s.completedAt, '2026-02-19T10:25:00+00:00');

      final back = s.toJson();
      expect(back['nodo_focale_id'], 'potenza_numeri');
      expect(back['durata_effettiva_min'], 25);
      expect(back['created_at'], '2026-02-19T10:00:00+00:00');
    });

    test('fromJson minimal', () {
      final s = SessioneListItem.fromJson({
        'id': 'x',
        'stato': 'attiva',
      });
      expect(s.tipo, isNull);
      expect(s.nodoFocaleId, isNull);
      expect(s.nodoFocaleNome, isNull);
      expect(s.durataEffettivaMin, isNull);
      expect(s.nodiLavorati, isNull);
      expect(s.createdAt, isNull);
      expect(s.completedAt, isNull);
    });

    test('fromJson sospesa without completed_at', () {
      final json = {
        'id': 'sess-uuid-789',
        'stato': 'sospesa',
        'tipo': 'media',
        'nodo_focale_id': 'equazioni_primo_grado',
        'nodo_focale_nome': 'Equazioni di primo grado',
        'durata_effettiva_min': 10,
        'nodi_lavorati': ['equazioni_primo_grado'],
        'created_at': '2026-02-19T14:00:00+00:00',
        'completed_at': null,
      };
      final s = SessioneListItem.fromJson(json);
      expect(s.stato, 'sospesa');
      expect(s.completedAt, isNull);
      expect(s.durataEffettivaMin, 10);
    });
  });
}
