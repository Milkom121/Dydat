import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/tema.dart';

void main() {
  group('Tema', () {
    final json = {
      'id': 'tema_derivate',
      'nome': 'Derivate',
      'materia': 'matematica',
      'descrizione': 'Concetti fondamentali sulle derivate',
      'nodi_totali': 10,
      'nodi_completati': 3,
      'completato': false,
    };

    test('fromJson → toJson roundtrip', () {
      final t = Tema.fromJson(json);
      expect(t.id, 'tema_derivate');
      expect(t.nome, 'Derivate');
      expect(t.materia, 'matematica');
      expect(t.descrizione, 'Concetti fondamentali sulle derivate');
      expect(t.nodiTotali, 10);
      expect(t.nodiCompletati, 3);
      expect(t.completato, false);

      final back = t.toJson();
      expect(back['nodi_totali'], 10);
      expect(back['nodi_completati'], 3);
    });
  });

  group('TemaDettaglio', () {
    final json = {
      'id': 'tema_derivate',
      'nome': 'Derivate',
      'materia': 'matematica',
      'descrizione': null,
      'nodi_totali': 2,
      'nodi_completati': 1,
      'completato': false,
      'nodi': [
        {
          'id': 'nodo1',
          'nome': 'Nodo 1',
          'tipo': 'standard',
          'livello': 'operativo',
          'presunto': false,
          'spiegazione_data': true,
          'esercizi_completati': 5,
        },
        {
          'id': 'nodo2',
          'nome': 'Nodo 2',
          'tipo': 'standard',
          'livello': 'non_iniziato',
          'presunto': false,
          'spiegazione_data': false,
          'esercizi_completati': 0,
        },
      ],
    };

    test('fromJson → toJson roundtrip', () {
      final td = TemaDettaglio.fromJson(json);
      expect(td.id, 'tema_derivate');
      expect(td.nodi, hasLength(2));
      expect(td.nodi[0].id, 'nodo1');
      expect(td.nodi[0].livello, 'operativo');
      expect(td.nodi[1].eserciziCompletati, 0);

      final back = td.toJson();
      expect((back['nodi'] as List).length, 2);
    });
  });
}
