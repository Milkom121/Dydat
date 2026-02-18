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
}
