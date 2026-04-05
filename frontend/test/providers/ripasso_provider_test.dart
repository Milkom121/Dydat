import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/ripasso.dart';
import 'package:dydat/providers/ripasso_provider.dart';

NodoRipasso _nodo(String nodoId, String temaId) => NodoRipasso(
      nodoId: nodoId,
      nodoNome: 'Nodo $nodoId',
      temaId: temaId,
      temaNome: 'Tema $temaId',
      srRipetizioni: 1,
    );

void main() {
  group('RipassoState', () {
    test('stato iniziale è vuoto', () {
      const s = RipassoState();
      expect(s.nodi, isEmpty);
      expect(s.isLoading, false);
      expect(s.error, isNull);
      expect(s.totale, 0);
      expect(s.conteggioPerTema, isEmpty);
    });

    test('totale restituisce numero di nodi', () {
      final s = RipassoState(nodi: [
        _nodo('n1', 'tema_a'),
        _nodo('n2', 'tema_a'),
        _nodo('n3', 'tema_b'),
      ]);
      expect(s.totale, 3);
    });

    test('conteggioPerTema aggrega per tema_id', () {
      final s = RipassoState(nodi: [
        _nodo('n1', 'tema_a'),
        _nodo('n2', 'tema_a'),
        _nodo('n3', 'tema_b'),
      ]);
      final counts = s.conteggioPerTema;
      expect(counts['tema_a'], 2);
      expect(counts['tema_b'], 1);
      expect(counts['tema_c'], isNull);
    });

    test('conteggioPerTema vuoto se nessun nodo', () {
      const s = RipassoState();
      expect(s.conteggioPerTema, isEmpty);
    });

    test('copyWith aggiorna campi selezionati', () {
      const s = RipassoState(isLoading: true);
      final s2 = s.copyWith(isLoading: false, nodi: [_nodo('n1', 't1')]);
      expect(s2.isLoading, false);
      expect(s2.nodi.length, 1);
    });

    test('copyWith clearError azzera errore', () {
      const s = RipassoState(error: 'Errore');
      final s2 = s.copyWith(clearError: true);
      expect(s2.error, isNull);
    });
  });
}
