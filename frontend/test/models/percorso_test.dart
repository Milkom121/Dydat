import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';

void main() {
  group('Percorso', () {
    final json = {
      'id': 1,
      'tipo': 'binario_1',
      'materia': 'matematica',
      'nome': 'Percorso Matematica',
      'stato': 'attivo',
      'nodo_iniziale_override': 'derivata_definizione',
      'created_at': '2026-02-18T10:00:00',
    };

    test('fromJson → toJson roundtrip', () {
      final p = Percorso.fromJson(json);
      expect(p.id, 1);
      expect(p.tipo, 'binario_1');
      expect(p.materia, 'matematica');
      expect(p.nome, 'Percorso Matematica');
      expect(p.stato, 'attivo');
      expect(p.nodoInizialeOverride, 'derivata_definizione');
      expect(p.createdAt, '2026-02-18T10:00:00');

      final back = p.toJson();
      expect(back['nodo_iniziale_override'], 'derivata_definizione');
      expect(back['created_at'], '2026-02-18T10:00:00');
    });
  });

  group('MappaPercorso', () {
    final json = {
      'percorso_id': 1,
      'materia': 'matematica',
      'nodo_iniziale_override': null,
      'nodi': [
        {
          'id': 'derivata_definizione',
          'nome': 'Definizione di Derivata',
          'tipo': 'standard',
          'tema_id': 'tema_derivate',
          'livello': 'in_corso',
          'presunto': false,
          'spiegazione_data': true,
          'esercizi_completati': 3,
        },
      ],
    };

    test('fromJson → toJson roundtrip', () {
      final m = MappaPercorso.fromJson(json);
      expect(m.percorsoId, 1);
      expect(m.materia, 'matematica');
      expect(m.nodi, hasLength(1));
      expect(m.nodi[0].id, 'derivata_definizione');
      expect(m.nodi[0].livello, 'in_corso');
      expect(m.nodi[0].spiegazioneData, true);
      expect(m.nodi[0].eserciziCompletati, 3);

      final back = m.toJson();
      expect(back['percorso_id'], 1);
      expect((back['nodi'] as List).length, 1);
    });
  });

  group('NodoMappa', () {
    test('fromJson → toJson roundtrip', () {
      final json = {
        'id': 'nodo1',
        'nome': 'Nodo 1',
        'tipo': 'standard',
        'tema_id': 'tema1',
        'livello': 'operativo',
        'presunto': true,
        'spiegazione_data': false,
        'esercizi_completati': 5,
      };
      final n = NodoMappa.fromJson(json);
      expect(n.id, 'nodo1');
      expect(n.presunto, true);
      expect(n.eserciziCompletati, 5);

      final back = n.toJson();
      expect(back['tema_id'], 'tema1');
    });
  });
}
