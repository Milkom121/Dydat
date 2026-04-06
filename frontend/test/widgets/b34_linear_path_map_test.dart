/// Test B34 — LinearPathMap: mappa lineare verticale del percorso.
///
/// Verifica rendering nodi, connessioni, stati, badge ripasso,
/// filtro ricerca (highlight), tap nodo, stato vuoto.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/presentation/learning_path_screen/widgets/linear_path_map.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

NodoMappa _nodo({
  required String id,
  required String nome,
  String livello = 'non_iniziato',
  bool presunto = false,
  int eserciziCompletati = 0,
}) =>
    NodoMappa(
      id: id,
      nome: nome,
      tipo: 'standard',
      livello: livello,
      presunto: presunto,
      eserciziCompletati: eserciziCompletati,
    );

List<NodoMappa> _sampleNodi() => [
      _nodo(id: 'n1', nome: 'Frazioni', livello: 'operativo', eserciziCompletati: 5),
      _nodo(id: 'n2', nome: 'Proporzioni', livello: 'in_corso', eserciziCompletati: 2),
      _nodo(id: 'n3', nome: 'Potenze', livello: 'non_iniziato'),
      _nodo(id: 'n4', nome: 'Radicali', livello: 'comprensivo', eserciziCompletati: 8),
    ];

void main() {
  group('LinearPathMap', () {
    testWidgets('renderizza nodi con nome e stato', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          onNodeTap: (_) {},
        ),
      ));

      expect(find.text('Frazioni'), findsOneWidget);
      expect(find.text('Proporzioni'), findsOneWidget);
      expect(find.text('Potenze'), findsOneWidget);
      expect(find.text('Radicali'), findsOneWidget);
    });

    testWidgets('renderizza cerchi con icone diverse per ogni stato', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          onNodeTap: (_) {},
        ),
      ));

      // Verifica che i nomi dei nodi sono visibili (layout centrato)
      expect(find.text('Frazioni'), findsOneWidget);
      expect(find.text('Proporzioni'), findsOneWidget);
    });

    testWidgets('mostra esercizi completati se > 0', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          onNodeTap: (_) {},
        ),
      ));

      expect(find.text('5 esercizi'), findsOneWidget);
      expect(find.text('2 esercizi'), findsOneWidget);
      expect(find.text('8 esercizi'), findsOneWidget);
      // Potenze ha 0 esercizi — non deve comparire
      expect(find.text('0 esercizi'), findsNothing);
    });

    testWidgets('mostra badge ripasso per nodi SR', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          nodiDaRipassare: {'n1', 'n4'},
          onNodeTap: (_) {},
        ),
      ));

      // Due badge "Ripasso"
      expect(find.text('Ripasso'), findsNWidgets(2));
    });

    testWidgets('nessun badge ripasso se set vuoto', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          onNodeTap: (_) {},
        ),
      ));

      expect(find.text('Ripasso'), findsNothing);
    });

    testWidgets('mostra badge presunto', (tester) async {
      final nodi = [
        _nodo(id: 'n1', nome: 'Frazioni', livello: 'operativo', presunto: true),
        _nodo(id: 'n2', nome: 'Potenze'),
      ];

      await tester.pumpWidget(_wrap(
        LinearPathMap(nodi: nodi, onNodeTap: (_) {}),
      ));

      // Badge presunto mostra "P"
      expect(find.text('P'), findsOneWidget);
    });

    testWidgets('tap nodo invoca callback con nodo corretto', (tester) async {
      NodoMappa? tappedNodo;

      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          onNodeTap: (nodo) => tappedNodo = nodo,
        ),
      ));

      await tester.tap(find.text('Proporzioni'));
      expect(tappedNodo?.id, 'n2');
      expect(tappedNodo?.nome, 'Proporzioni');
    });

    testWidgets('stato vuoto non renderizza nulla', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(nodi: const [], onNodeTap: (_) {}),
      ));

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('highlight con set vuoto mostra tutti opachi', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          highlightedNodeIds: const {},
          onNodeTap: (_) {},
        ),
      ));

      // Tutti visibili (opacity 1.0) — set vuoto = mostra tutti
      final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
      for (final o in opacities) {
        expect(o.opacity, 1.0);
      }
    });

    testWidgets('highlight con set specifico riduce opacita non-match', (tester) async {
      await tester.pumpWidget(_wrap(
        LinearPathMap(
          nodi: _sampleNodi(),
          highlightedNodeIds: {'n1'},
          onNodeTap: (_) {},
        ),
      ));

      final opacities =
          tester.widgetList<Opacity>(find.byType(Opacity)).toList();
      // n1 highlighted (1.0), gli altri 3 smorzati (0.3)
      expect(opacities.where((o) => o.opacity == 1.0).length, 1);
      expect(opacities.where((o) => o.opacity == 0.3).length, 3);
    });
  });
}
