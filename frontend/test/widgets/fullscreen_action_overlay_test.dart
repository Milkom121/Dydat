/// Test B32 — FullscreenActionOverlay: esercizi, formule, backtrack a schermo intero.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/presentation/studio_screen/widgets/fullscreen_action_overlay.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

AzioneEvent _exerciseAction({String testo = 'Calcola 2+2'}) => AzioneEvent(
      tipo: 'proponi_esercizio',
      params: {'testo': testo, 'difficolta': 3, 'esercizio_id': 'e1'},
    );

AzioneEvent _formulaAction({String latex = 'x^2', String? etichetta}) =>
    AzioneEvent(
      tipo: 'mostra_formula',
      params: {'latex': latex, if (etichetta != null) 'etichetta': etichetta},
    );

AzioneEvent _backtrackAction({String motivo = 'Serve ripassare'}) =>
    AzioneEvent(
      tipo: 'suggerisci_backtrack',
      params: {'nodo_id': 'n1', 'motivo': motivo},
    );

void main() {
  group('FullscreenActionOverlay — Esercizio', () {
    testWidgets('mostra testo esercizio', (tester) async {
      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'exercise',
          action: _exerciseAction(testo: 'Risolvi 3x=9'),
          onExerciseVerify: (_) {},
          onDismiss: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Risolvi 3x=9'), findsOneWidget);
      expect(find.text('Esercizio'), findsOneWidget);
      expect(find.text('Verifica'), findsOneWidget);
    });

    testWidgets('bottone Verifica invoca onExerciseVerify e onDismiss', (tester) async {
      String? receivedAnswer;
      String? receivedResult;

      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'exercise',
          action: _exerciseAction(),
          onExerciseVerify: (r) => receivedAnswer = r,
          onDismiss: (r) => receivedResult = r,
        ),
      ));
      await tester.pumpAndSettle();

      // Inserisci risposta
      await tester.enterText(find.byType(TextField), '4');
      await tester.tap(find.text('Verifica'));
      await tester.pumpAndSettle();

      expect(receivedAnswer, '4');
      expect(receivedResult, 'completato');
    });

    testWidgets('dismiss esercizio senza risposta invoca con saltato', (tester) async {
      String? result;

      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'exercise',
          action: _exerciseAction(),
          onExerciseVerify: (_) {},
          onDismiss: (r) => result = r,
        ),
      ));
      await tester.pumpAndSettle();

      // ExerciseCardWidget usa CustomIconWidget con iconName 'close' in un IconButton
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsWidgets);
      await tester.tap(iconButtons.first);
      await tester.pumpAndSettle();

      expect(result, 'saltato');
    });
  });

  group('FullscreenActionOverlay — Formula', () {
    testWidgets('mostra formula con etichetta', (tester) async {
      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'formula',
          action: _formulaAction(latex: 'a^2+b^2=c^2', etichetta: 'Pitagora'),
          onExerciseVerify: (_) {},
          onDismiss: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pitagora'), findsOneWidget);
    });

    testWidgets('dismiss formula invoca con visto', (tester) async {
      String? result;

      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'formula',
          action: _formulaAction(),
          onExerciseVerify: (_) {},
          onDismiss: (r) => result = r,
        ),
      ));
      await tester.pumpAndSettle();

      // Cerca il primo IconButton (close)
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsWidgets);
      await tester.tap(iconButtons.first);
      await tester.pumpAndSettle();

      expect(result, 'visto');
    });
  });

  group('FullscreenActionOverlay — Backtrack', () {
    testWidgets('mostra motivo backtrack', (tester) async {
      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'backtrack',
          action: _backtrackAction(motivo: 'Hai difficoltà con le frazioni'),
          onExerciseVerify: (_) {},
          onDismiss: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hai difficoltà con le frazioni'), findsOneWidget);
      expect(find.text('Suggerimento di ripasso'), findsOneWidget);
    });

    testWidgets('accetta backtrack invoca con accettato', (tester) async {
      String? result;

      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'backtrack',
          action: _backtrackAction(),
          onExerciseVerify: (_) {},
          onDismiss: (r) => result = r,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ok, rivediamolo'));
      await tester.pumpAndSettle();

      expect(result, 'accettato');
    });

    testWidgets('rifiuta backtrack invoca con rifiutato', (tester) async {
      String? result;

      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'backtrack',
          action: _backtrackAction(),
          onExerciseVerify: (_) {},
          onDismiss: (r) => result = r,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continua qui'));
      await tester.pumpAndSettle();

      expect(result, 'rifiutato');
    });
  });

  group('FullscreenActionOverlay — Animazione', () {
    testWidgets('mostra contenuto con animazione (non istantaneo)', (tester) async {
      await tester.pumpWidget(_wrap(
        FullscreenActionOverlay(
          actionType: 'exercise',
          action: _exerciseAction(),
          onExerciseVerify: (_) {},
          onDismiss: (_) {},
        ),
      ));

      // Dopo pump ma prima di pumpAndSettle, l'animazione è in corso
      await tester.pump(const Duration(milliseconds: 100));
      // Il widget è presente ma l'animazione non è finita
      expect(find.text('Esercizio'), findsOneWidget);

      await tester.pumpAndSettle();
      // Dopo l'animazione il widget è completamente visibile
      expect(find.text('Esercizio'), findsOneWidget);
    });
  });
}
