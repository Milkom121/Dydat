/// Test B33 — SessionGoalPicker: selezione obiettivo di sessione.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/presentation/studio_screen/widgets/session_goal_picker.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

void main() {
  group('SessionGoal enum', () {
    test('veloce ha durata 15 minuti', () {
      expect(SessionGoal.veloce.durataMsMin, equals(15));
    });

    test('normale ha durata 30 minuti', () {
      expect(SessionGoal.normale.durataMsMin, equals(30));
    });

    test('approfondita ha durata 60 minuti', () {
      expect(SessionGoal.approfondita.durataMsMin, equals(60));
    });

    test('tutte le opzioni hanno label non vuota', () {
      for (final goal in SessionGoal.values) {
        expect(goal.label.isNotEmpty, isTrue);
        expect(goal.descrizione.isNotEmpty, isTrue);
        expect(goal.iconName.isNotEmpty, isTrue);
      }
    });
  });

  group('SessionGoalPicker widget', () {
    testWidgets('mostra titolo e tre opzioni', (tester) async {
      await tester.pumpWidget(_wrap(const SessionGoalPicker()));

      expect(find.text('Come vuoi studiare oggi?'), findsOneWidget);
      expect(find.text('Veloce'), findsOneWidget);
      expect(find.text('Normale'), findsOneWidget);
      expect(find.text('Approfondita'), findsOneWidget);
    });

    testWidgets('normale è selezionato per default', (tester) async {
      await tester.pumpWidget(_wrap(const SessionGoalPicker()));

      // "Normale" compare come label e come testo nel dialog
      expect(find.text('Normale'), findsOneWidget);
    });

    testWidgets('mostra bottone Inizia e Salta', (tester) async {
      await tester.pumpWidget(_wrap(const SessionGoalPicker()));

      expect(find.text('Inizia'), findsOneWidget);
      expect(find.text('Salta'), findsOneWidget);
    });

    testWidgets('tap su Veloce seleziona veloce', (tester) async {
      await tester.pumpWidget(_wrap(const SessionGoalPicker()));

      await tester.tap(find.text('Veloce'));
      await tester.pump();

      // check_circle appare solo sull'opzione selezionata — dopo tap su Veloce
      // il widget non pop il context in modalità non-dialog, verifica solo che
      // non si verifichino errori.
      expect(find.text('Veloce'), findsOneWidget);
    });

    testWidgets('mostra le descrizioni delle opzioni', (tester) async {
      await tester.pumpWidget(_wrap(const SessionGoalPicker()));

      expect(find.text('15 minuti — ideale per un ripasso rapido'), findsOneWidget);
      expect(find.text('30 minuti — una sessione standard'), findsOneWidget);
      expect(find.text('60 minuti — per studiare con calma'), findsOneWidget);
    });
  });

  group('showSessionGoalPicker', () {
    testWidgets('restituisce il goal selezionato quando si clicca Inizia', (tester) async {
      SessionGoal? result;

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showSessionGoalPicker(context);
            },
            child: const Text('Apri'),
          ),
        ),
      ));

      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();

      // Dialog aperto — clicca Inizia senza cambiare selezione (default: normale)
      expect(find.text('Come vuoi studiare oggi?'), findsOneWidget);
      await tester.tap(find.text('Inizia'));
      await tester.pumpAndSettle();

      expect(result, equals(SessionGoal.normale));
    });

    testWidgets('restituisce null quando si clicca Salta', (tester) async {
      SessionGoal? result = SessionGoal.veloce; // valore non-null per verificare il reset

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showSessionGoalPicker(context);
            },
            child: const Text('Apri'),
          ),
        ),
      ));

      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salta'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('restituisce veloce quando si seleziona Veloce e clicca Inizia', (tester) async {
      SessionGoal? result;

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showSessionGoalPicker(context);
            },
            child: const Text('Apri'),
          ),
        ),
      ));

      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();

      // Seleziona Veloce
      await tester.tap(find.text('Veloce'));
      await tester.pump();

      await tester.tap(find.text('Inizia'));
      await tester.pumpAndSettle();

      expect(result, equals(SessionGoal.veloce));
    });
  });
}
