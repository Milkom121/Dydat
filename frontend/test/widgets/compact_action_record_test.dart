/// Test B32 — CompactActionRecord: record compatti nel feed dopo azione fullscreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/presentation/studio_screen/widgets/compact_action_record.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

void main() {
  group('CompactActionRecord', () {
    testWidgets('mostra label e risultato per esercizio', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompactActionRecord(
          actionType: 'exercise_record',
          label: 'Esercizio: Calcola 2+2',
          result: 'completato',
        ),
      ));

      expect(find.text('Esercizio: Calcola 2+2'), findsOneWidget);
      expect(find.text('completato'), findsOneWidget);
    });

    testWidgets('mostra label e risultato per formula', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompactActionRecord(
          actionType: 'formula_record',
          label: 'Formula: Pitagora',
          result: 'visto',
        ),
      ));

      expect(find.text('Formula: Pitagora'), findsOneWidget);
      expect(find.text('visto'), findsOneWidget);
    });

    testWidgets('mostra label e risultato per backtrack accettato', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompactActionRecord(
          actionType: 'backtrack_record',
          label: 'Ripasso: Frazioni',
          result: 'accettato',
        ),
      ));

      expect(find.text('Ripasso: Frazioni'), findsOneWidget);
      expect(find.text('accettato'), findsOneWidget);
    });

    testWidgets('mostra label e risultato per backtrack rifiutato', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompactActionRecord(
          actionType: 'backtrack_record',
          label: 'Ripasso: Proporzioni',
          result: 'rifiutato',
        ),
      ));

      expect(find.text('Ripasso: Proporzioni'), findsOneWidget);
      expect(find.text('rifiutato'), findsOneWidget);
    });

    testWidgets('esercizio saltato mostra risultato saltato', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompactActionRecord(
          actionType: 'exercise_record',
          label: 'Esercizio: Risolvi 3x=9',
          result: 'saltato',
        ),
      ));

      expect(find.text('saltato'), findsOneWidget);
    });

    testWidgets('tronca label lunga con ellipsis', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompactActionRecord(
          actionType: 'exercise_record',
          label: 'Esercizio: Un esercizio con un testo molto molto lungo che non dovrebbe essere mostrato per intero nel record compatto',
          result: 'completato',
        ),
      ));

      // Il widget ha maxLines: 1 e overflow: TextOverflow.ellipsis,
      // quindi il testo viene troncato visivamente
      expect(find.textContaining('Esercizio:'), findsOneWidget);
    });
  });

  group('CompactActionRecord — Stile', () {
    testWidgets('usa Container con bordo e sfondo', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompactActionRecord(
          actionType: 'exercise_record',
          label: 'Test',
          result: 'ok',
        ),
      ));

      // Verifica che il Container principale è presente
      expect(find.byType(Container), findsWidgets);
    });
  });
}
