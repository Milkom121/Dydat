import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/nodo.dart';

void main() {
  group('Nodo', () {
    final json = {
      'id': 'derivata_definizione',
      'nome': 'Definizione di Derivata',
      'materia': 'matematica',
      'tipo': 'standard',
      'tipo_nodo': 'operativo',
    };

    test('fromJson → toJson roundtrip', () {
      final n = Nodo.fromJson(json);
      expect(n.id, 'derivata_definizione');
      expect(n.nome, 'Definizione di Derivata');
      expect(n.materia, 'matematica');
      expect(n.tipo, 'standard');
      expect(n.tipoNodo, 'operativo');

      final back = n.toJson();
      expect(back['tipo_nodo'], 'operativo');
    });
  });

  group('StatoNodoUtente', () {
    final json = {
      'utente_id': 'user-uuid-123',
      'nodo_id': 'derivata_definizione',
      'livello': 'in_corso',
      'presunto': false,
      'spiegazione_data': true,
      'esercizi_completati': 3,
      'errori_in_corso': 1,
      'esercizi_consecutivi_ok': 2,
    };

    test('fromJson → toJson roundtrip', () {
      final s = StatoNodoUtente.fromJson(json);
      expect(s.utenteId, 'user-uuid-123');
      expect(s.nodoId, 'derivata_definizione');
      expect(s.livello, 'in_corso');
      expect(s.presunto, false);
      expect(s.spiegazioneData, true);
      expect(s.eserciziCompletati, 3);
      expect(s.erroriInCorso, 1);
      expect(s.eserciziConsecutiviOk, 2);

      final back = s.toJson();
      expect(back['utente_id'], 'user-uuid-123');
      expect(back['esercizi_completati'], 3);
    });

    test('fromJson with null esercizi_consecutivi_ok', () {
      final minimal = {
        'utente_id': 'u1',
        'nodo_id': 'n1',
        'livello': 'non_iniziato',
        'presunto': false,
        'spiegazione_data': false,
        'esercizi_completati': 0,
        'errori_in_corso': 0,
      };
      final s = StatoNodoUtente.fromJson(minimal);
      expect(s.eserciziConsecutiviOk, isNull);
    });
  });
}
