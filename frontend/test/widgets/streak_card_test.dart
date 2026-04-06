/// Test B31 — StreakCard: mostra streak e statistiche.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/statistiche.dart';
import 'package:dydat/presentation/home_screen/widgets/streak_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

StatisticheUtente _stats({
  int streak = 0,
  int nodiCompletati = 0,
  int eserciziSettimanali = 0,
}) =>
    StatisticheUtente(
      streak: streak,
      nodiCompletati: nodiCompletati,
      sessioniCompletate: 5,
      settimana: PeriodoStats(eserciziSvolti: eserciziSettimanali),
      mese: const PeriodoStats(),
      sempre: const PeriodoStats(),
    );

void main() {
  group('StreakCard', () {
    testWidgets('mostra il valore streak', (tester) async {
      await tester.pumpWidget(_wrap(
        StreakCard(stats: _stats(streak: 7)),
      ));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('mostra "giorno" al singolare per streak 1', (tester) async {
      await tester.pumpWidget(_wrap(
        StreakCard(stats: _stats(streak: 1)),
      ));
      expect(find.text('giorno'), findsOneWidget);
    });

    testWidgets('mostra "giorni" al plurale per streak > 1', (tester) async {
      await tester.pumpWidget(_wrap(
        StreakCard(stats: _stats(streak: 3)),
      ));
      expect(find.text('giorni'), findsOneWidget);
    });

    testWidgets('mostra esercizi settimanali', (tester) async {
      await tester.pumpWidget(_wrap(
        StreakCard(stats: _stats(eserciziSettimanali: 12)),
      ));
      expect(find.text('12'), findsOneWidget);
      expect(find.textContaining('esercizi'), findsOneWidget);
    });

    testWidgets('mostra nodi completati', (tester) async {
      await tester.pumpWidget(_wrap(
        StreakCard(stats: _stats(nodiCompletati: 5)),
      ));
      expect(find.text('5'), findsOneWidget);
      expect(find.textContaining('nodi'), findsOneWidget);
    });

    testWidgets('mostra icona fuoco per streak', (tester) async {
      await tester.pumpWidget(_wrap(
        StreakCard(stats: _stats(streak: 3)),
      ));
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });
  });
}
