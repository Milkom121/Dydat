/// Test B30 — Nuova navigazione: 3 tab + Studio modale.
///
/// Verifica che CustomBottomBar mostri correttamente i 3 tab:
/// Home, I miei studi, Profilo.
/// Lo Studio non appare come tab (è una route fullscreen separata).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/custom_bottom_bar.dart';

Widget _wrapWidget(Widget child) {
  return MaterialApp(
    home: child,
    theme: ThemeData.dark(),
  );
}

void main() {
  group('CustomBottomBar — struttura 3 tab B30', () {
    testWidgets('mostra tab Home, I miei studi, Profilo', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        CustomBottomBar(
          currentIndex: 0,
          onTap: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('I miei studi'), findsOneWidget);
      expect(find.text('Profilo'), findsOneWidget);
    });

    testWidgets('NON mostra tab Studio (è route modale)', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        CustomBottomBar(
          currentIndex: 0,
          onTap: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Studio'), findsNothing);
    });

    testWidgets('ha esattamente 3 tab', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        CustomBottomBar(
          currentIndex: 0,
          onTap: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // BottomNavigationBarItem labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('I miei studi'), findsOneWidget);
      expect(find.text('Profilo'), findsOneWidget);

      // Nessun quarto tab
      expect(find.text('Percorso'), findsNothing);
    });

    testWidgets('invoca onTap con indice corretto', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(_wrapWidget(
        CustomBottomBar(
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('I miei studi'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });

    testWidgets('currentIndex 2 seleziona tab Profilo', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        CustomBottomBar(
          currentIndex: 2,
          onTap: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Il BottomNavigationBar mostra 3 item totali
      // (uno per tab, currentIndex=2 significa Profilo attivo)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      final navBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, 2);
    });
  });
}
