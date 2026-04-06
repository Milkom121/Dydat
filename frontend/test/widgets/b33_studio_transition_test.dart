/// Test B33 — StudioTransitionOverlay: overlay animato transizione Home->Studio.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/presentation/home_screen/widgets/studio_transition_overlay.dart';

void main() {
  group('StudioTransitionOverlay', () {
    testWidgets('render senza errori', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: StudioTransitionOverlay(
            onComplete: () {},
          ),
        ),
      ));

      // Deve renderizzare senza eccezioni
      expect(tester.takeException(), isNull);
    });

    testWidgets('mostra testo di invito', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: StudioTransitionOverlay(
            onComplete: () {},
          ),
        ),
      ));

      // Avanza l'animazione fino al punto in cui il testo è visibile
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Pronti a studiare!'), findsOneWidget);
    });

    testWidgets('chiama onComplete al termine dell\'animazione', (tester) async {
      bool completato = false;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: StudioTransitionOverlay(
            onComplete: () => completato = true,
          ),
        ),
      ));

      // Fase 1: scale controller (600ms)
      await tester.pump(const Duration(milliseconds: 650));
      // Fase 2: Future.delayed(150ms)
      await tester.pump(const Duration(milliseconds: 200));
      // Fase 3: fade controller (400ms)
      await tester.pump(const Duration(milliseconds: 450));

      expect(completato, isTrue);
    });

    testWidgets('onComplete non chiamato se widget rimosso prima', (tester) async {
      bool completato = false;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: StudioTransitionOverlay(
            onComplete: () => completato = true,
          ),
        ),
      ));

      // Rimuove il widget prima del completamento
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Non deve aver chiamato onComplete
      expect(completato, isFalse);
    });
  });
}
