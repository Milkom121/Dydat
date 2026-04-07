/// Test B34 + B35.10 — LearningPathScreen: logica di filtraggio ricerca.
///
/// Verifica la logica pura di filtraggio nodi per ricerca argomento.
/// B35.10: ricerca estesa anche alle parole chiave del nodo.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';

/// Replica della logica _getHighlightedNodeIds dal LearningPathScreen
/// per test unitario (funzione pura).
/// B35.10: cerca anche nelle paroleChiave del nodo.
Set<String> getHighlightedNodeIds(List<NodoMappa> nodi, String searchQuery) {
  if (searchQuery.isEmpty) return {};
  final query = searchQuery.toLowerCase();
  return nodi
      .where((n) =>
          n.nome.toLowerCase().contains(query) ||
          n.paroleChiave.any((k) => k.toLowerCase().contains(query)))
      .map((n) => n.id)
      .toSet();
}

NodoMappa _nodo({
  required String id,
  required String nome,
  List<String> paroleChiave = const [],
}) =>
    NodoMappa(
      id: id,
      nome: nome,
      tipo: 'standard',
      livello: 'non_iniziato',
      paroleChiave: paroleChiave,
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

  // B35.10: ricerca per parole chiave
  group('Ricerca per parole chiave (B35.10)', () {
    final nodiConKeywords = [
      _nodo(
        id: 'n1',
        nome: 'Frazioni',
        paroleChiave: ['numeratore', 'denominatore', 'rapporto'],
      ),
      _nodo(
        id: 'n2',
        nome: 'Proporzioni',
        paroleChiave: ['rapporto', 'proporzionalità'],
      ),
      _nodo(
        id: 'n3',
        nome: 'Potenze',
        paroleChiave: ['esponente', 'base', 'elevamento'],
      ),
      _nodo(
        id: 'n4',
        nome: 'Radicali',
        paroleChiave: ['radice quadrata', 'indice'],
      ),
      _nodo(
        id: 'n5',
        nome: 'Equazioni di primo grado',
        paroleChiave: ['incognita', 'soluzione', 'x'],
      ),
    ];

    test('trova nodo per parola chiave esatta', () {
      expect(getHighlightedNodeIds(nodiConKeywords, 'numeratore'), {'n1'});
    });

    test('trova nodo per parola chiave parziale', () {
      // "espon" matcha "esponente" nelle parole chiave di Potenze
      expect(getHighlightedNodeIds(nodiConKeywords, 'espon'), {'n3'});
    });

    test('trova nodo per parola chiave case-insensitive', () {
      expect(getHighlightedNodeIds(nodiConKeywords, 'INCOGNITA'), {'n5'});
    });

    test('parola chiave condivisa trova più nodi', () {
      // "rapporto" è keyword sia di Frazioni che di Proporzioni
      final result = getHighlightedNodeIds(nodiConKeywords, 'rapporto');
      expect(result, containsAll(['n1', 'n2']));
    });

    test('match sia per nome che per keyword', () {
      // "radice" non è nel nome "Radicali" ma è in "radice quadrata" keyword
      // Ma "Radic" matcha il nome "Radicali"
      expect(getHighlightedNodeIds(nodiConKeywords, 'radice'), {'n4'});
      expect(getHighlightedNodeIds(nodiConKeywords, 'Radic'), {'n4'});
    });

    test('nodi senza parole chiave non crashano', () {
      final nodiMisti = [
        _nodo(id: 'n1', nome: 'Frazioni'), // senza parole chiave
        _nodo(id: 'n2', nome: 'Potenze', paroleChiave: ['esponente']),
      ];
      expect(getHighlightedNodeIds(nodiMisti, 'esponente'), {'n2'});
      expect(getHighlightedNodeIds(nodiMisti, 'Frazioni'), {'n1'});
    });

    test('ricerca keyword senza risultati', () {
      expect(getHighlightedNodeIds(nodiConKeywords, 'logaritmo'), isEmpty);
    });
  });

  // B35.10: test deserializzazione NodoMappa con parole_chiave
  group('NodoMappa deserializzazione parole_chiave (B35.10)', () {
    test('fromJson con parole_chiave', () {
      final json = {
        'id': 'n1',
        'nome': 'Frazioni',
        'tipo': 'standard',
        'livello': 'non_iniziato',
        'parole_chiave': ['numeratore', 'denominatore'],
      };
      final nodo = NodoMappa.fromJson(json);
      expect(nodo.paroleChiave, ['numeratore', 'denominatore']);
    });

    test('fromJson senza parole_chiave usa lista vuota', () {
      final json = {
        'id': 'n1',
        'nome': 'Frazioni',
        'tipo': 'standard',
        'livello': 'non_iniziato',
      };
      final nodo = NodoMappa.fromJson(json);
      expect(nodo.paroleChiave, isEmpty);
    });

    test('fromJson con parole_chiave null usa lista vuota', () {
      final json = {
        'id': 'n1',
        'nome': 'Frazioni',
        'tipo': 'standard',
        'livello': 'non_iniziato',
        'parole_chiave': null,
      };
      final nodo = NodoMappa.fromJson(json);
      expect(nodo.paroleChiave, isEmpty);
    });

    test('toJson include parole_chiave', () {
      final nodo = NodoMappa(
        id: 'n1',
        nome: 'Frazioni',
        tipo: 'standard',
        livello: 'non_iniziato',
        paroleChiave: ['test'],
      );
      final json = nodo.toJson();
      expect(json['parole_chiave'], ['test']);
    });
  });
}
