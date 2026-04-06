/// Test B31 — WelcomeHeader: saluto contestuale + ritorno dopo assenza.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sessione.dart';
import 'package:dydat/presentation/home_screen/widgets/welcome_header.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

SessioneListItem _sessione({
  required String id,
  String? createdAt,
  String? completedAt,
  String? nodoFocaleNome,
}) =>
    SessioneListItem(
      id: id,
      stato: 'completata',
      createdAt: createdAt,
      completedAt: completedAt,
      nodoFocaleNome: nodoFocaleNome,
    );

void main() {
  group('WelcomeHeader', () {
    testWidgets('mostra "Benvenuto" per utente nuovo (nessuna sessione)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const WelcomeHeader(
          sessionHistory: [],
          hasActiveSession: false,
        ),
      ));
      expect(find.text('Benvenuto su Dydat!'), findsOneWidget);
      expect(find.text('Inizia il tuo percorso di apprendimento'),
          findsOneWidget);
    });

    testWidgets('mostra "Sessione in corso" se sessione attiva',
        (tester) async {
      await tester.pumpWidget(_wrap(
        WelcomeHeader(
          sessionHistory: [
            _sessione(id: 's1', createdAt: DateTime.now().toIso8601String()),
          ],
          hasActiveSession: true,
        ),
      ));
      expect(find.text('Sessione in corso'), findsOneWidget);
    });

    testWidgets('mostra "Bentornato" con nome nodo se ritorno normale',
        (tester) async {
      final recente = DateTime.now().subtract(const Duration(days: 1));
      await tester.pumpWidget(_wrap(
        WelcomeHeader(
          sessionHistory: [
            _sessione(
              id: 's1',
              createdAt: recente.toIso8601String(),
              nodoFocaleNome: 'Frazioni',
            ),
          ],
          hasActiveSession: false,
          lastNodeName: 'Frazioni',
        ),
      ));
      expect(find.text('Bentornato!'), findsOneWidget);
      expect(find.textContaining('Frazioni'), findsOneWidget);
    });

    testWidgets('mostra card assenza se ultima sessione > 7 giorni',
        (tester) async {
      final vecchia = DateTime.now().subtract(const Duration(days: 15));
      await tester.pumpWidget(_wrap(
        WelcomeHeader(
          sessionHistory: [
            _sessione(
              id: 's1',
              createdAt: vecchia.toIso8601String(),
              completedAt: vecchia.toIso8601String(),
            ),
          ],
          hasActiveSession: false,
        ),
      ));
      expect(find.text('Bentornato!'), findsOneWidget);
      // Messaggio assenza (tono caldo, nessun senso di colpa)
      expect(find.textContaining('5 minuti'), findsOneWidget);
    });

    testWidgets('NON mostra card assenza se ultima sessione < 7 giorni',
        (tester) async {
      final recente = DateTime.now().subtract(const Duration(days: 2));
      await tester.pumpWidget(_wrap(
        WelcomeHeader(
          sessionHistory: [
            _sessione(id: 's1', createdAt: recente.toIso8601String()),
          ],
          hasActiveSession: false,
        ),
      ));
      expect(find.textContaining('5 minuti'), findsNothing);
    });
  });
}
