import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/onboarding.dart';

void main() {
  group('OnboardingIniziato', () {
    final json = {
      'utente_temp_id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      'sessione_id': 'f0e1d2c3-b4a5-6789-0abc-def123456789',
    };

    test('fromJson → toJson roundtrip', () {
      final o = OnboardingIniziato.fromJson(json);
      expect(o.utenteTempId, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
      expect(o.sessioneId, 'f0e1d2c3-b4a5-6789-0abc-def123456789');

      final back = o.toJson();
      expect(back['utente_temp_id'], json['utente_temp_id']);
      expect(back['sessione_id'], json['sessione_id']);
    });
  });

  group('OnboardingTurnoRequest', () {
    final json = {
      'sessione_id': 'sess-123',
      'messaggio': 'Ciao, voglio ripassare le derivate',
    };

    test('fromJson → toJson roundtrip', () {
      final req = OnboardingTurnoRequest.fromJson(json);
      expect(req.sessioneId, 'sess-123');
      expect(req.messaggio, 'Ciao, voglio ripassare le derivate');

      final back = req.toJson();
      expect(back['sessione_id'], 'sess-123');
    });
  });

  group('OnboardingCompletaRequest', () {
    final json = {
      'sessione_id': 'sess-123',
      'contesto_personale': {'obiettivo': 'esame analisi 1', 'anno': 'primo'},
      'preferenze_tutor': {'velocita': 'normale', 'incoraggiamento': 'alto'},
    };

    test('fromJson → toJson roundtrip', () {
      final req = OnboardingCompletaRequest.fromJson(json);
      expect(req.sessioneId, 'sess-123');
      expect(req.contestoPersonale!['obiettivo'], 'esame analisi 1');
      expect(req.preferenzeTutor!['velocita'], 'normale');

      final back = req.toJson();
      expect(back['sessione_id'], 'sess-123');
    });

    test('fromJson with null optional fields', () {
      final minimal = {'sessione_id': 'sess-456'};
      final req = OnboardingCompletaRequest.fromJson(minimal);
      expect(req.contestoPersonale, isNull);
      expect(req.preferenzeTutor, isNull);
    });
  });

  group('OnboardingCompletaResponse', () {
    final json = {
      'percorso_id': 1,
      'nodo_iniziale': 'derivata_definizione',
      'nodi_inizializzati': 42,
    };

    test('fromJson → toJson roundtrip', () {
      final resp = OnboardingCompletaResponse.fromJson(json);
      expect(resp.percorsoId, 1);
      expect(resp.nodoIniziale, 'derivata_definizione');
      expect(resp.nodiInizializzati, 42);

      final back = resp.toJson();
      expect(back['percorso_id'], 1);
      expect(back['nodo_iniziale'], 'derivata_definizione');
    });

    test('fromJson with null nodo_iniziale', () {
      final json = {
        'percorso_id': 1,
        'nodi_inizializzati': 42,
      };
      final resp = OnboardingCompletaResponse.fromJson(json);
      expect(resp.nodoIniziale, isNull);
    });
  });
}
