/// Test B35.5.4 — Widget riutilizzabili quaderno.
///
/// Verifica: CollapsibleText, FormulaCurriculumCard, ErroreComuneCard, NotaUtenteEditor.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/quaderno.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/collapsible_text.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/formula_curriculum_card.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/errore_comune_card.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/nota_utente_editor.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
      theme: ThemeData.dark(),
    );

void main() {
  // -------------------------------------------------------------------------
  // CollapsibleText
  // -------------------------------------------------------------------------
  group('CollapsibleText', () {
    testWidgets('mostra testo corto senza pulsante expand', (tester) async {
      await tester.pumpWidget(_wrap(
        const CollapsibleText(text: 'Testo breve'),
      ));
      expect(find.text('Testo breve'), findsOneWidget);
      expect(find.text('Mostra tutto'), findsNothing);
      expect(find.text('Mostra meno'), findsNothing);
    });

    testWidgets('mostra testo troncato con pulsante Mostra tutto',
        (tester) async {
      final longText = 'A' * 300;
      await tester.pumpWidget(_wrap(
        CollapsibleText(text: longText, maxChars: 100),
      ));
      expect(find.text('Mostra tutto'), findsOneWidget);
      expect(find.text('Mostra meno'), findsNothing);
    });

    testWidgets('expand/collapse funziona', (tester) async {
      final longText = 'B' * 300;
      await tester.pumpWidget(_wrap(
        CollapsibleText(text: longText, maxChars: 100),
      ));

      await tester.tap(find.text('Mostra tutto'));
      await tester.pump();
      expect(find.text('Mostra meno'), findsOneWidget);
      expect(find.text('Mostra tutto'), findsNothing);

      await tester.tap(find.text('Mostra meno'));
      await tester.pump();
      expect(find.text('Mostra tutto'), findsOneWidget);
    });

    testWidgets('rispetta maxChars custom', (tester) async {
      final longText = 'C' * 100;
      await tester.pumpWidget(_wrap(
        CollapsibleText(text: longText, maxChars: 50),
      ));
      expect(find.text('Mostra tutto'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // FormulaCurriculumCard
  // -------------------------------------------------------------------------
  group('FormulaCurriculumCard', () {
    testWidgets('renderizza formula e descrizione', (tester) async {
      const formula = FormulaCurriculum(
        latex: 'x^2 + y^2 = r^2',
        descrizione: 'Equazione del cerchio',
      );
      await tester
          .pumpWidget(_wrap(const FormulaCurriculumCard(formula: formula)));
      expect(find.text('Equazione del cerchio'), findsOneWidget);
    });

    testWidgets('non mostra descrizione se vuota', (tester) async {
      const formula = FormulaCurriculum(latex: 'a^2 + b^2 = c^2');
      await tester
          .pumpWidget(_wrap(const FormulaCurriculumCard(formula: formula)));
      expect(find.text('Equazione del cerchio'), findsNothing);
    });

    testWidgets('fallback per LaTeX non valido', (tester) async {
      const formula = FormulaCurriculum(
        latex: r'\invalidcommand{',
        descrizione: 'Formula rotta',
      );
      await tester
          .pumpWidget(_wrap(const FormulaCurriculumCard(formula: formula)));
      expect(find.text('Formula rotta'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // ErroreComuneCard
  // -------------------------------------------------------------------------
  group('ErroreComuneCard', () {
    testWidgets('renderizza tipo e descrizione', (tester) async {
      const errore = ErroreComune(
        tipo: 'Segno sbagliato',
        descrizione:
            'Dimenticare di cambiare segno quando si sposta un termine.',
      );
      await tester
          .pumpWidget(_wrap(const ErroreComuneCard(errore: errore)));
      expect(find.text('Segno sbagliato'), findsOneWidget);
      expect(
        find.text(
            'Dimenticare di cambiare segno quando si sposta un termine.'),
        findsOneWidget,
      );
    });

    testWidgets('mostra esempio sbagliato e correzione', (tester) async {
      const errore = ErroreComune(
        tipo: 'Divisione per zero',
        descrizione: 'Non verificare il denominatore.',
        esempioSbagliato: '1/x con x=0',
        correzione: 'Verifica x≠0 prima',
        suggerimento: 'Controlla sempre il dominio',
      );
      await tester
          .pumpWidget(_wrap(const ErroreComuneCard(errore: errore)));
      // RichText con TextSpan — verifica che i 3 campi opzionali siano renderizzati
      bool richTextContains(RichText rt, String text) {
        return rt.text.toPlainText().contains(text);
      }

      expect(
        find.byWidgetPredicate(
            (w) => w is RichText && richTextContains(w, '1/x con x=0')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
            (w) => w is RichText && richTextContains(w, 'Verifica')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
            (w) => w is RichText && richTextContains(w, 'Controlla sempre')),
        findsOneWidget,
      );
    });

    testWidgets('non mostra campi opzionali se assenti', (tester) async {
      const errore = ErroreComune(
        tipo: 'Errore semplice',
        descrizione: 'Solo descrizione.',
      );
      await tester
          .pumpWidget(_wrap(const ErroreComuneCard(errore: errore)));
      expect(find.text('Errore semplice'), findsOneWidget);
      expect(find.textContaining('Errore tipico'), findsNothing);
      expect(find.textContaining('Corretto:'), findsNothing);
      expect(find.textContaining('Suggerimento:'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // NotaUtenteEditor
  // -------------------------------------------------------------------------
  group('NotaUtenteEditor', () {
    testWidgets('mostra testo iniziale', (tester) async {
      await tester.pumpWidget(_wrap(
        NotaUtenteEditor(
          initialText: 'Nota esistente',
          onSave: (_) {},
        ),
      ));
      expect(find.text('Nota esistente'), findsOneWidget);
      expect(find.text('Le mie note'), findsOneWidget);
    });

    testWidgets('mostra placeholder se vuoto', (tester) async {
      await tester.pumpWidget(_wrap(
        NotaUtenteEditor(onSave: (_) {}),
      ));
      expect(find.text('Scrivi qui i tuoi appunti...'), findsOneWidget);
    });

    testWidgets('chiama onSave dopo debounce', (tester) async {
      String? savedText;
      await tester.pumpWidget(_wrap(
        NotaUtenteEditor(
          onSave: (t) => savedText = t,
          debounceDuration: const Duration(milliseconds: 100),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Nuovo appunto');
      expect(savedText, isNull);

      // Aspetta il debounce
      await tester.pump(const Duration(milliseconds: 150));
      expect(savedText, 'Nuovo appunto');
    });

    testWidgets('mostra indicatore Salvo quando isSaving', (tester) async {
      await tester.pumpWidget(_wrap(
        NotaUtenteEditor(
          isSaving: true,
          onSave: (_) {},
        ),
      ));
      expect(find.text('Salvo...'), findsOneWidget);
    });

    testWidgets('mostra Modificato dopo digitazione prima del debounce',
        (tester) async {
      await tester.pumpWidget(_wrap(
        NotaUtenteEditor(
          onSave: (_) {},
          debounceDuration: const Duration(seconds: 5),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Qualcosa');
      await tester.pump();
      expect(find.text('Modificato'), findsOneWidget);
    });
  });
}
