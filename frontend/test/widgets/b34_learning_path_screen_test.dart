/// Test B34 — LearningPathScreen: logica di filtraggio ricerca.
///
/// Verifica la logica pura di filtraggio nodi per ricerca argomento.
/// Il rendering del screen con provider è testato indirettamente
/// attraverso i widget standalone (LinearPathMap, GraphOverview, etc.).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';

/// Replica della logica _getHighlightedNodeIds dal LearningPathScreen
/// per test unitario (funzione pura).
Set<String> getHighlightedNodeIds(List<NodoMappa> nodi, String searchQuery) {
  if (searchQuery.isEmpty) return {};
  final query = searchQuery.toLowerCase();
  return nodi
      .where((n) => n.nome.toLowerCase().contains(query))
      .map((n) => n.id)
      .toSet();
}

NodoMappa _nodo({required String id, required String nome}) => NodoMappa(
      id: id,
      nome: nome,
      tipo: 'standard',
      livello: 'non_iniziato',
    );

void main() {
  final nodi = [
    _nodo(id: 'n1', nome: 'Frazioni'),
    _nodo(id: 'n2', nome: 'Proporzioni'),
    _nodo(id: 'n3', nome: 'Potenze'),
    _nodo(id: 'n4', nome: 'Radicali'),
    _nodo(id: 'n5', nome: 'Equazioni di primo grado'),
  ];

  group('Ricerca argomento (filtering)', () {
    test('query vuota restituisce set vuoto (mostra tutti)', () {
      expect(getHighlightedNodeIds(nodi, ''), isEmpty);
    });

    test('ricerca case-insensitive', () {
      expect(getHighlightedNodeIds(nodi, 'FRAZIONI'), {'n1'});
      expect(getHighlightedNodeIds(nodi, 'frazioni'), {'n1'});
      expect(getHighlightedNodeIds(nodi, 'Frazioni'), {'n1'});
    });

    test('ricerca parziale', () {
      // "zioni" matcha sia Frazioni che Proporzioni ed Equazioni
      final result = getHighlightedNodeIds(nodi, 'zioni');
      expect(result, containsAll(['n1', 'n2', 'n5']));
    });

    test('ricerca senza risultati', () {
      expect(getHighlightedNodeIds(nodi, 'trigonometria'), isEmpty);
    });

    test('ricerca con un solo risultato', () {
      expect(getHighlightedNodeIds(nodi, 'Radicali'), {'n4'});
    });

    test('ricerca sottostringhe', () {
      // "pot" matcha Potenze
      expect(getHighlightedNodeIds(nodi, 'pot'), {'n3'});
    });

    test('ricerca con spazi', () {
      expect(getHighlightedNodeIds(nodi, 'primo grado'), {'n5'});
    });

    test('lista nodi vuota', () {
      expect(getHighlightedNodeIds([], 'qualcosa'), isEmpty);
    });
  });
}
