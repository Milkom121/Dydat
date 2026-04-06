/// Test B34 — GraphOverview: vista grafo completo con InteractiveViewer.
///
/// Verifica rendering nodi raggruppati, label temi, tap nodo,
/// badge ripasso, stato vuoto.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/models/tema.dart';
import 'package:dydat/presentation/learning_path_screen/widgets/graph_overview.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

NodoMappa _nodo({
  required String id,
  required String nome,
  String livello = 'non_iniziato',
  String? temaId,
}) =>
    NodoMappa(
      id: id,
      nome: nome,
      tipo: 'standard',
      temaId: temaId,
      livello: livello,
    );

Tema _tema({required String id, required String nome}) => Tema(
      id: id,
      nome: nome,
      materia: 'matematica',
    );

void main() {
  group('GraphOverview', () {
    testWidgets('renderizza nodi con nome', (tester) async {
      final nodi = [
        _nodo(id: 'n1', nome: 'Frazioni', temaId: 't1', livello: 'operativo'),
        _nodo(id: 'n2', nome: 'Proporzioni', temaId: 't1'),
        _nodo(id: 'n3', nome: 'Potenze', temaId: 't2'),
      ];
      final temi = [_tema(id: 't1', nome: 'Algebra'), _tema(id: 't2', nome: 'Aritmetica')];

      await tester.pumpWidget(_wrap(
        GraphOverview(nodi: nodi, temi: temi, onNodeTap: (_) {}),
      ));

      expect(find.text('Frazioni'), findsOneWidget);
      expect(find.text('Proporzioni'), findsOneWidget);
      expect(find.text('Potenze'), findsOneWidget);
    });

    testWidgets('mostra label temi come header di gruppo', (tester) async {
      final nodi = [
        _nodo(id: 'n1', nome: 'Frazioni', temaId: 't1'),
        _nodo(id: 'n2', nome: 'Potenze', temaId: 't2'),
      ];
      final temi = [_tema(id: 't1', nome: 'Algebra'), _tema(id: 't2', nome: 'Aritmetica')];

      await tester.pumpWidget(_wrap(
        GraphOverview(nodi: nodi, temi: temi, onNodeTap: (_) {}),
      ));

      expect(find.text('Algebra'), findsOneWidget);
      expect(find.text('Aritmetica'), findsOneWidget);
    });

    testWidgets('usa InteractiveViewer per pan/zoom', (tester) async {
      final nodi = [_nodo(id: 'n1', nome: 'X', temaId: 't1')];
      final temi = [_tema(id: 't1', nome: 'T')];

      await tester.pumpWidget(_wrap(
        GraphOverview(nodi: nodi, temi: temi, onNodeTap: (_) {}),
      ));

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('tap nodo invoca callback', (tester) async {
      NodoMappa? tapped;
      final nodi = [_nodo(id: 'n1', nome: 'Frazioni', temaId: 't1')];
      final temi = [_tema(id: 't1', nome: 'Algebra')];

      await tester.pumpWidget(_wrap(
        GraphOverview(
          nodi: nodi,
          temi: temi,
          onNodeTap: (n) => tapped = n,
        ),
      ));

      await tester.tap(find.text('Frazioni'));
      expect(tapped?.id, 'n1');
    });

    testWidgets('stato vuoto non renderizza nulla', (tester) async {
      await tester.pumpWidget(_wrap(
        GraphOverview(nodi: const [], temi: const [], onNodeTap: (_) {}),
      ));

      expect(find.byType(InteractiveViewer), findsNothing);
    });

    testWidgets('nodi senza temaId raggruppati sotto "Altro"', (tester) async {
      final nodi = [_nodo(id: 'n1', nome: 'Orphan')];

      await tester.pumpWidget(_wrap(
        GraphOverview(nodi: nodi, temi: const [], onNodeTap: (_) {}),
      ));

      expect(find.text('Altro'), findsOneWidget);
    });

    testWidgets('usa CustomPaint per linee connessione', (tester) async {
      final nodi = [
        _nodo(id: 'n1', nome: 'A', temaId: 't1'),
        _nodo(id: 'n2', nome: 'B', temaId: 't1'),
      ];
      final temi = [_tema(id: 't1', nome: 'T')];

      await tester.pumpWidget(_wrap(
        GraphOverview(nodi: nodi, temi: temi, onNodeTap: (_) {}),
      ));

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
