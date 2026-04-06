/// Test B34 — NodeDetailBottomSheet: dettaglio nodo con placeholder quaderno.
///
/// Verifica nome, livello, esercizi, spiegazione, badge presunto,
/// placeholder quaderno.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/presentation/learning_path_screen/widgets/node_detail_bottom_sheet.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

NodoMappa _nodo({
  String id = 'n1',
  String nome = 'Frazioni',
  String livello = 'non_iniziato',
  bool presunto = false,
  bool spiegazioneData = false,
  int eserciziCompletati = 0,
}) =>
    NodoMappa(
      id: id,
      nome: nome,
      tipo: 'standard',
      livello: livello,
      presunto: presunto,
      spiegazioneData: spiegazioneData,
      eserciziCompletati: eserciziCompletati,
    );

void main() {
  group('NodeDetailBottomSheet', () {
    testWidgets('mostra nome nodo', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(nome: 'Frazioni')),
      ));

      expect(find.text('Frazioni'), findsOneWidget);
    });

    testWidgets('mostra label stato Da iniziare', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(livello: 'non_iniziato')),
      ));

      expect(find.text('Da iniziare'), findsOneWidget);
    });

    testWidgets('mostra label stato In corso', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(livello: 'in_corso')),
      ));

      expect(find.text('In corso'), findsOneWidget);
    });

    testWidgets('mostra label stato Operativo', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(livello: 'operativo')),
      ));

      expect(find.text('Operativo'), findsOneWidget);
    });

    testWidgets('mostra label stato Comprensivo', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(livello: 'comprensivo')),
      ));

      expect(find.text('Comprensivo'), findsOneWidget);
    });

    testWidgets('mostra esercizi completati se > 0', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(eserciziCompletati: 7)),
      ));

      expect(find.text('7 esercizi completati'), findsOneWidget);
    });

    testWidgets('non mostra esercizi se 0', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(eserciziCompletati: 0)),
      ));

      expect(find.textContaining('esercizi completati'), findsNothing);
    });

    testWidgets('mostra spiegazione completata se true', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(spiegazioneData: true)),
      ));

      expect(find.text('Spiegazione completata'), findsOneWidget);
    });

    testWidgets('non mostra spiegazione se false', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(spiegazioneData: false)),
      ));

      expect(find.text('Spiegazione completata'), findsNothing);
    });

    testWidgets('mostra badge presunto', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo(presunto: true)),
      ));

      expect(find.text('Presunto'), findsOneWidget);
    });

    testWidgets('mostra placeholder quaderno B35', (tester) async {
      await tester.pumpWidget(_wrap(
        NodeDetailBottomSheet(nodo: _nodo()),
      ));

      expect(find.text('Quaderno'), findsOneWidget);
      expect(find.textContaining('in arrivo'), findsOneWidget);
    });
  });
}
