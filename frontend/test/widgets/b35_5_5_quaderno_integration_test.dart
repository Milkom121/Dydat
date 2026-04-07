/// Test B35.5.5 — Integrazione NodoQuadernoScreen con scheda curricolare.
///
/// Verifica le 10 sezioni del quaderno: breadcrumb, parole chiave,
/// definizione, formule curriculum, esempi, errori comuni, note utente,
/// separator, log personale.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/quaderno.dart';
import 'package:dydat/providers/quaderno_provider.dart';
import 'package:dydat/presentation/quaderno_screen/nodo_quaderno_screen.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/collapsible_text.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/formula_curriculum_card.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/errore_comune_card.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/nota_utente_editor.dart';

/// Fake notifier senza servizio reale.
class FakeQuadernoNotifier extends StateNotifier<QuadernoState>
    implements QuadernoNotifier {
  FakeQuadernoNotifier(super.initial);

  @override
  Future<void> carica(String nodoId) async {}

  @override
  Future<void> saveNota(String nodoId, String testo) async {}

  @override
  void clear() {
    state = const QuadernoState();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child, {QuadernoState? initialState}) {
  final notifier =
      FakeQuadernoNotifier(initialState ?? const QuadernoState());
  return ProviderScope(
    overrides: [
      quadernoProvider.overrideWith((ref) => notifier),
    ],
    child: MaterialApp(home: child, theme: ThemeData.dark()),
  );
}

/// Quaderno completo con tutte le sezioni per test di integrazione.
QuadernoNodo _fullQuaderno() => QuadernoNodo(
      nodoId: 'nodo_42',
      nodoNome: 'Equazioni di primo grado',
      temaNome: 'Algebra',
      stato: const StatoNodoQuaderno(
        livello: 'operativo',
        eserciziCompletati: 3,
        srRipetizioni: 1,
      ),
      sessioniCount: 5,
      scheda: const SchedaNodo(
        definizioneTesto:
            'Un\'equazione di primo grado è un\'equazione in cui l\'incognita compare con esponente 1.',
        formule: [
          FormulaCurriculum(
            latex: r'ax + b = 0',
            descrizione: 'Forma standard',
          ),
        ],
        esempi: [
          '2x + 3 = 7 → x = 2',
          '5x - 10 = 0 → x = 2',
        ],
        erroriComuni: [
          ErroreComune(
            tipo: 'Segno errato',
            descrizione: 'Dimenticare di cambiare segno spostando un termine',
            esempioSbagliato: '2x + 3 = 7 → 2x = 7 + 3',
            correzione: '2x = 7 - 3',
            suggerimento: 'Quando sposti un termine, cambia sempre il segno',
          ),
        ],
        paroleChiave: ['equazione', 'primo grado', 'incognita'],
      ),
      notaUtente: const NotaUtente(testo: 'Ricordare il metodo di Cramer'),
      esercizi: const [
        EsercizioQuaderno(id: 1, esito: 'corretto', testo: 'Risolvi 2x+3=7'),
        EsercizioQuaderno(id: 2, esito: 'errato', testo: 'Risolvi 5x-10=0'),
      ],
      formule: const [
        FormulaQuaderno(titolo: 'Forma canonica', formula: 'ax+b=0'),
      ],
      spiegazioni: const [
        SpiegazioneQuaderno(
          contenuto: 'Per risolvere, isola l\'incognita a sinistra.',
          sessioneId: 's1',
        ),
      ],
    );

/// Quaderno con solo scheda (nessun log personale).
QuadernoNodo _schedaOnlyQuaderno() => const QuadernoNodo(
      nodoId: 'nodo_99',
      nodoNome: 'Proporzioni',
      temaNome: 'Aritmetica',
      stato: StatoNodoQuaderno(livello: 'non_iniziato'),
      scheda: SchedaNodo(
        definizioneTesto: 'Una proporzione è un\'uguaglianza tra due rapporti.',
        paroleChiave: ['proporzione', 'rapporto'],
      ),
    );

void main() {
  group('NodoQuadernoScreen integrazione B35.5.5', () {
    testWidgets('mostra breadcrumb tema > nodo', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      // Breadcrumb mostra il nome del tema
      expect(find.text('Algebra'), findsWidgets);
      // E il nome del nodo
      expect(find.text('Equazioni di primo grado'), findsWidgets);
    });

    testWidgets('mostra chip parole chiave', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      expect(find.text('equazione'), findsOneWidget);
      expect(find.text('primo grado'), findsOneWidget);
      expect(find.text('incognita'), findsOneWidget);
    });

    testWidgets('mostra sezione Cosa imparerai con CollapsibleText',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      expect(find.text('Cosa imparerai'), findsOneWidget);
      expect(find.byType(CollapsibleText), findsOneWidget);
    });

    testWidgets('mostra FormulaCurriculumCard per formule chiave',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      expect(find.text('Formule chiave'), findsOneWidget);
      expect(find.byType(FormulaCurriculumCard), findsOneWidget);
    });

    testWidgets('mostra sezione Esempi', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      // Scorri per raggiungere la sezione esempi
      await tester.scrollUntilVisible(
        find.text('Esempi'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Esempi'), findsOneWidget);
    });

    testWidgets('mostra ErroreComuneCard per errori comuni', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      // Scorri per raggiungere la sezione errori comuni
      await tester.scrollUntilVisible(
        find.text('Attenzione a...'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Attenzione a...'), findsOneWidget);
      expect(find.byType(ErroreComuneCard), findsOneWidget);
    });

    testWidgets('mostra NotaUtenteEditor con testo iniziale', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      // Scorri fino all'editor note
      await tester.scrollUntilVisible(
        find.byType(NotaUtenteEditor),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(NotaUtenteEditor), findsOneWidget);
      expect(find.text('Ricordare il metodo di Cramer'), findsOneWidget);
    });

    testWidgets('mostra separator quando c\'è log personale', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_42', nodoNome: 'Equazioni di primo grado'),
        initialState: QuadernoState(quaderno: _fullQuaderno()),
      ));
      await tester.pump();

      // Scorri fino al separator
      await tester.scrollUntilVisible(
        find.text('Il tuo percorso'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Il tuo percorso'), findsOneWidget);
    });

    testWidgets('mostra separator SEMPRE (con empty state se no log)', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_99', nodoNome: 'Proporzioni'),
        initialState: QuadernoState(quaderno: _schedaOnlyQuaderno()),
      ));
      await tester.pump();

      // NB-04: il separator ora appare sempre
      expect(find.text('Il tuo percorso'), findsOneWidget);
      // E mostra il messaggio empty state del log personale
      expect(find.text('Non hai ancora fatto sessioni su questo nodo.'), findsOneWidget);
    });

    testWidgets('NON mostra stato vuoto quando c\'è scheda', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_99', nodoNome: 'Proporzioni'),
        initialState: QuadernoState(quaderno: _schedaOnlyQuaderno()),
      ));
      await tester.pump();

      // Ha la definizione, quindi non è vuoto
      expect(find.textContaining('si riempirà'), findsNothing);
    });

    testWidgets('mostra NotaUtenteEditor anche senza nota esistente',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(
            nodoId: 'nodo_99', nodoNome: 'Proporzioni'),
        initialState: QuadernoState(quaderno: _schedaOnlyQuaderno()),
      ));
      await tester.pump();

      // L'editor note è sempre presente
      expect(find.byType(NotaUtenteEditor), findsOneWidget);
    });
  });
}
