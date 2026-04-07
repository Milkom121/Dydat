/// Test B35.13 — Audit accessibilità base: Semantics labels.
///
/// Verifica che i widget interattivi principali abbiano Semantics labels
/// per screen reader e tooltip sui pulsanti chiudi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/presentation/learning_path_screen/widgets/linear_path_map.dart';
import 'package:dydat/presentation/learning_path_screen/widgets/graph_overview.dart';
import 'package:dydat/presentation/studio_screen/widgets/tools_tray_widget.dart';
import 'package:dydat/presentation/studio_screen/widgets/mascotte_widget.dart';
import 'package:dydat/presentation/studio_screen/widgets/exercise_card_widget.dart';
import 'package:dydat/presentation/studio_screen/widgets/formula_card_widget.dart';
import 'package:dydat/presentation/studio_screen/widgets/backtrack_card_widget.dart';
import 'package:dydat/presentation/studio_screen/widgets/tutor_panel_widget.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/collapsible_text.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

NodoMappa _nodo({
  required String id,
  required String nome,
  String livello = 'non_iniziato',
}) =>
    NodoMappa(
      id: id,
      nome: nome,
      tipo: 'standard',
      livello: livello,
      presunto: false,
      eserciziCompletati: 0,
    );

void main() {
  group('LinearPathMap Semantics', () {
    testWidgets('nodi hanno Semantics widget con label', (tester) async {
      await tester.pumpWidget(_wrap(LinearPathMap(
        nodi: [
          _nodo(id: 'n1', nome: 'Frazioni', livello: 'operativo'),
          _nodo(id: 'n2', nome: 'Potenze', livello: 'non_iniziato'),
        ],
        onNodeTap: (_) {},
      )));

      // Verifica Semantics widget con label contenente il nome del nodo
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && (w.properties.label?.contains('Frazioni') ?? false)),
        findsOneWidget,
        reason: 'Nodo Frazioni deve avere Semantics label',
      );
    });

    testWidgets('nodo da ripassare ha indicazione nel label', (tester) async {
      await tester.pumpWidget(_wrap(LinearPathMap(
        nodi: [_nodo(id: 'n1', nome: 'Frazioni', livello: 'operativo')],
        nodiDaRipassare: const {'n1'},
        onNodeTap: (_) {},
      )));

      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && (w.properties.label?.contains('ripassare') ?? false)),
        findsOneWidget,
        reason: 'Nodo da ripassare deve indicarlo nel label',
      );
    });
  });

  group('GraphOverview Semantics', () {
    testWidgets('nodo grafo ha Semantics label', (tester) async {
      await tester.pumpWidget(_wrap(GraphOverview(
        nodi: [_nodo(id: 'n1', nome: 'Algebra', livello: 'in_corso')],
        temi: const [],
        onNodeTap: (_) {},
      )));

      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && (w.properties.label?.contains('Algebra') ?? false)),
        findsOneWidget,
        reason: 'Nodo grafo Algebra deve avere Semantics label',
      );
    });
  });

  group('ToolsTrayWidget Semantics', () {
    testWidgets('bottoni strumenti hanno Semantics label', (tester) async {
      // Serve superficie piu grande per evitare overflow
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(ToolsTrayWidget(
        theme: theme,
        onToolSelected: (_) {},
        onClose: () {},
      )));

      // Verifica che almeno Calcolatrice abbia Semantics
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && (w.properties.label?.contains('Calcolatrice') ?? false)),
        findsOneWidget,
      );
    });

    testWidgets('bottone chiudi ha tooltip', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(ToolsTrayWidget(
        theme: theme,
        onToolSelected: (_) {},
        onClose: () {},
      )));

      expect(find.byTooltip('Chiudi strumenti'), findsOneWidget);
    });
  });

  group('MascotteWidget Semantics', () {
    testWidgets('mascotte ha Semantics label', (tester) async {
      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(MascotteWidget(
        theme: theme,
        onTap: () {},
        mascotteState: MascotteState.idle,
      )));

      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && (w.properties.label?.contains('Mascotte') ?? false)),
        findsOneWidget,
      );
    });
  });

  group('Card widget tooltips', () {
    testWidgets('ExerciseCardWidget ha tooltip chiudi', (tester) async {
      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(ExerciseCardWidget(
        exercise: const ProponiEsercizioAction(
          testo: 'Risolvi 2+2',
          difficolta: 3,
        ),
        theme: theme,
        onVerify: (_) {},
        onDismiss: () {},
      )));

      expect(find.byTooltip('Chiudi esercizio'), findsOneWidget);
    });

    testWidgets('FormulaCardWidget ha tooltip chiudi', (tester) async {
      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(FormulaCardWidget(
        formula: const MostraFormulaAction(
          latex: 'x^2',
          etichetta: 'Potenza',
        ),
        theme: theme,
        onDismiss: () {},
      )));

      expect(find.byTooltip('Chiudi formula'), findsOneWidget);
    });

    testWidgets('BacktrackCardWidget ha tooltip chiudi', (tester) async {
      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(BacktrackCardWidget(
        suggestion: const SuggerisciBacktrackAction(
          motivo: 'Rivedi frazioni',
          nodoId: 'frazioni',
        ),
        theme: theme,
        onAccept: () {},
        onDismiss: () {},
      )));

      expect(find.byTooltip('Chiudi suggerimento'), findsOneWidget);
    });
  });

  group('TutorPanelWidget Semantics', () {
    testWidgets('pannello chiudi ha tooltip', (tester) async {
      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(TutorPanelWidget(
        theme: theme,
        onClose: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Chiudi pannello tutor'), findsOneWidget);
    });

    testWidgets('modalita tutor hanno Semantics label', (tester) async {
      final theme = ThemeData.dark();
      await tester.pumpWidget(_wrap(TutorPanelWidget(
        theme: theme,
        onClose: () {},
      )));
      await tester.pumpAndSettle();

      // Almeno la modalita Spiegazione deve avere Semantics
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && (w.properties.label?.contains('Spiegazione') ?? false)),
        findsOneWidget,
      );
    });
  });

  group('CollapsibleText Semantics', () {
    testWidgets('pulsante expand ha Semantics label', (tester) async {
      final longText = List.filled(300, 'A').join();
      await tester.pumpWidget(_wrap(CollapsibleText(
        text: longText,
        maxChars: 50,
      )));

      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && (w.properties.label?.contains('Mostra tutto') ?? false)),
        findsOneWidget,
      );
    });
  });
}
