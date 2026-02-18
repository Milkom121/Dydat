import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/achievement.dart';

void main() {
  group('Achievement', () {
    final json = {
      'id': 'primo_nodo',
      'nome': 'Primo passo!',
      'tipo': 'sigillo',
      'descrizione': 'Completa il primo nodo',
      'sbloccato_at': '2026-02-18T10:30:00',
    };

    test('fromJson → toJson roundtrip', () {
      final a = Achievement.fromJson(json);
      expect(a.id, 'primo_nodo');
      expect(a.nome, 'Primo passo!');
      expect(a.tipo, 'sigillo');
      expect(a.descrizione, 'Completa il primo nodo');
      expect(a.sbloccatoAt, '2026-02-18T10:30:00');

      final back = a.toJson();
      expect(back['sbloccato_at'], '2026-02-18T10:30:00');
    });
  });

  group('AchievementProssimo', () {
    final json = {
      'id': 'cinque_nodi',
      'nome': 'Cinque su cinque',
      'tipo': 'sigillo',
      'descrizione': null,
      'condizione': {'tipo': 'nodi_completati', 'valore': 5},
      'progresso': {'corrente': 2, 'richiesto': 5},
    };

    test('fromJson → toJson roundtrip', () {
      final ap = AchievementProssimo.fromJson(json);
      expect(ap.id, 'cinque_nodi');
      expect(ap.condizione.tipo, 'nodi_completati');
      expect(ap.condizione.valore, 5);
      expect(ap.progresso.corrente, 2);
      expect(ap.progresso.richiesto, 5);

      final back = ap.toJson();
      final condBack = (back['condizione'] as AchievementCondizione).toJson();
      expect(condBack['valore'], 5);
      final progBack = (back['progresso'] as AchievementProgresso).toJson();
      expect(progBack['corrente'], 2);
    });
  });

  group('AchievementResponse', () {
    final json = {
      'sbloccati': [
        {
          'id': 'primo_nodo',
          'nome': 'Primo passo!',
          'tipo': 'sigillo',
          'descrizione': null,
          'sbloccato_at': '2026-02-18T10:30:00',
        },
      ],
      'prossimi': [
        {
          'id': 'cinque_nodi',
          'nome': 'Cinque su cinque',
          'tipo': 'sigillo',
          'descrizione': null,
          'condizione': {'tipo': 'nodi_completati', 'valore': 5},
          'progresso': {'corrente': 1, 'richiesto': 5},
        },
      ],
    };

    test('fromJson → toJson roundtrip', () {
      final resp = AchievementResponse.fromJson(json);
      expect(resp.sbloccati, hasLength(1));
      expect(resp.sbloccati[0].id, 'primo_nodo');
      expect(resp.prossimi, hasLength(1));
      expect(resp.prossimi[0].condizione.tipo, 'nodi_completati');

      final back = resp.toJson();
      expect((back['sbloccati'] as List).length, 1);
      expect((back['prossimi'] as List).length, 1);
    });
  });
}
