import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/ripasso.dart';

void main() {
  group('NodoRipasso', () {
    final json = {
      'nodo_id': 'equazioni_1grado',
      'nodo_nome': 'Equazioni di primo grado',
      'tema_id': 'algebra',
      'tema_nome': 'Algebra',
      'sr_prossimo_ripasso': '2026-04-04T10:00:00+00:00',
      'sr_ripetizioni': 3,
    };

    test('fromJson → valori corretti', () {
      final n = NodoRipasso.fromJson(json);
      expect(n.nodoId, 'equazioni_1grado');
      expect(n.nodoNome, 'Equazioni di primo grado');
      expect(n.temaId, 'algebra');
      expect(n.temaNome, 'Algebra');
      expect(n.srProssimoRipasso, '2026-04-04T10:00:00+00:00');
      expect(n.srRipetizioni, 3);
    });

    test('fromJson → sr_prossimo_ripasso nullable', () {
      final j = Map<String, dynamic>.from(json)..['sr_prossimo_ripasso'] = null;
      final n = NodoRipasso.fromJson(j);
      expect(n.srProssimoRipasso, isNull);
    });

    test('fromJson → sr_ripetizioni default 0 se null', () {
      final j = Map<String, dynamic>.from(json)..remove('sr_ripetizioni');
      final n = NodoRipasso.fromJson(j);
      expect(n.srRipetizioni, 0);
    });

    test('toJson → roundtrip snake_case', () {
      final n = NodoRipasso.fromJson(json);
      final back = n.toJson();
      expect(back['nodo_id'], 'equazioni_1grado');
      expect(back['nodo_nome'], 'Equazioni di primo grado');
      expect(back['tema_id'], 'algebra');
      expect(back['sr_ripetizioni'], 3);
    });
  });
}
