/// Test B31 — RipassoSection: sezione ripasso FSRS migliorata.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/ripasso.dart';
import 'package:dydat/presentation/home_screen/widgets/ripasso_section.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

NodoRipasso _nodo({required String nome, String temaId = 't1'}) => NodoRipasso(
      nodoId: 'n_$nome',
      nodoNome: nome,
      temaId: temaId,
      temaNome: 'Algebra',
    );

void main() {
  group('RipassoSection', () {
    testWidgets('non renderizza se lista vuota', (tester) async {
      await tester.pumpWidget(_wrap(
        RipassoSection(nodi: const [], onRipassoTap: () {}),
      ));
      // SizedBox.shrink
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('mostra conteggio nodi al singolare', (tester) async {
      await tester.pumpWidget(_wrap(
        RipassoSection(nodi: [_nodo(nome: 'Frazioni')], onRipassoTap: () {}),
      ));
      expect(find.text('1 nodo da ripassare'), findsOneWidget);
    });

    testWidgets('mostra conteggio nodi al plurale', (tester) async {
      await tester.pumpWidget(_wrap(
        RipassoSection(
          nodi: [_nodo(nome: 'A'), _nodo(nome: 'B')],
          onRipassoTap: () {},
        ),
      ));
      expect(find.text('2 nodi da ripassare'), findsOneWidget);
    });

    testWidgets('mostra nomi nodi come chip (max 3)', (tester) async {
      await tester.pumpWidget(_wrap(
        RipassoSection(
          nodi: [
            _nodo(nome: 'Frazioni'),
            _nodo(nome: 'Proporzioni'),
            _nodo(nome: 'Potenze'),
            _nodo(nome: 'Radicali'),
            _nodo(nome: 'Equazioni'),
          ],
          onRipassoTap: () {},
        ),
      ));
      expect(find.text('Frazioni'), findsOneWidget);
      expect(find.text('Proporzioni'), findsOneWidget);
      expect(find.text('Potenze'), findsOneWidget);
      // I restanti 2 sono nel chip "e altri 2"
      expect(find.text('e altri 2'), findsOneWidget);
      expect(find.text('Radicali'), findsNothing);
    });

    testWidgets('bottone "Inizia ripasso" invoca callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        RipassoSection(
          nodi: [_nodo(nome: 'Frazioni')],
          onRipassoTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Inizia ripasso'));
      expect(tapped, isTrue);
    });

    testWidgets('singolo nodo extra usa "un altro"', (tester) async {
      await tester.pumpWidget(_wrap(
        RipassoSection(
          nodi: [
            _nodo(nome: 'A'),
            _nodo(nome: 'B'),
            _nodo(nome: 'C'),
            _nodo(nome: 'D'),
          ],
          onRipassoTap: () {},
        ),
      ));
      expect(find.text('e un altro'), findsOneWidget);
    });
  });
}
