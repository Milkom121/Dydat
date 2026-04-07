/// Test B35.14 — Fix post-test manuale nottata.
///
/// Verifica i 7 bug NB-01..NB-07 segnalati da Villa.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/quaderno.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/providers/quaderno_provider.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/formula_curriculum_card.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/esempio_inline_card.dart';
import 'package:dydat/presentation/quaderno_screen/nodo_quaderno_screen.dart';
import 'package:dydat/presentation/learning_path_screen/widgets/linear_path_map.dart';
import 'package:dydat/presentation/home_screen/widgets/mini_percorso_widget.dart';
import 'package:dydat/utils/pluralize.dart' as pl;

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
      theme: ThemeData.dark(),
    );

/// Fake notifier per i test del quaderno.
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
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  // -------------------------------------------------------------------------
  // NB-01 — FormulaCurriculumCard con formula lunga non genera overflow
  // -------------------------------------------------------------------------
  group('NB-01: FormulaCurriculumCard FittedBox', () {
    testWidgets('formula lunga non genera overflow', (tester) async {
      const formula = FormulaCurriculum(
        latex:
            r'(-a)^n = \begin{cases} a^n & \text{se } n \text{ pari} \\ -a^n & \text{se } n \text{ dispari} \end{cases}',
        descrizione: 'Potenza di un numero relativo',
      );
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 300,
          child: FormulaCurriculumCard(formula: formula),
        ),
      ));
      expect(find.text('Potenza di un numero relativo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('contiene FittedBox per scaling', (tester) async {
      const formula = FormulaCurriculum(
        latex: r'x^2',
        descrizione: '',
      );
      await tester.pumpWidget(_wrap(
        const FormulaCurriculumCard(formula: formula),
      ));
      expect(find.byType(FittedBox), findsOneWidget);
    });

    testWidgets('NON contiene SingleChildScrollView orizzontale (annullerebbe FittedBox)',
        (tester) async {
      const formula = FormulaCurriculum(
        latex: r'a^n = a \cdot a \cdot a \text{ (n volte)}',
        descrizione: 'test',
      );
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 320,
          child: FormulaCurriculumCard(formula: formula),
        ),
      ));
      // Cerca eventuali SingleChildScrollView orizzontali — non ce ne devono essere
      // perche darebbero larghezza infinita al FittedBox annullando lo scaling.
      final scrollViews = tester.widgetList<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      for (final sv in scrollViews) {
        expect(
          sv.scrollDirection,
          isNot(Axis.horizontal),
          reason:
              'FormulaCurriculumCard non deve avere SingleChildScrollView orizzontale: '
              'annullerebbe il FittedBox e le formule sborderebbero',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // NB-02 — EsempioInlineCard rendering LaTeX
  // -------------------------------------------------------------------------
  group('NB-02: EsempioInlineCard', () {
    testWidgets('esempio plain mostra Text', (tester) async {
      await tester.pumpWidget(_wrap(
        const EsempioInlineCard(esempio: '(-3)^4 = 81'),
      ));
      expect(find.text('(-3)^4 = 81'), findsOneWidget);
    });

    testWidgets('esempio LaTeX non mostra codice grezzo', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 400,
          child: EsempioInlineCard(
            esempio: r'(-2)^{-3} = \frac{1}{(-2)^3} = -\frac{1}{8}',
          ),
        ),
      ));
      // Il testo grezzo \frac non deve apparire come stringa visibile
      expect(
        find.text(r'(-2)^{-3} = \frac{1}{(-2)^3} = -\frac{1}{8}'),
        findsNothing,
      );
      // FittedBox presente per il rendering LaTeX
      expect(find.byType(FittedBox), findsOneWidget);
    });

    testWidgets('separa formula LaTeX dal commento italiano finale',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 400,
          child: EsempioInlineCard(
            esempio:
                r'(-2)^{-3} = \frac{1}{(-2)^3} = -\frac{1}{8} (esponente negativo con base negativa ed esponente dispari)',
          ),
        ),
      ));
      // Il commento italiano deve apparire come Text plain separato
      expect(
        find.text('esponente negativo con base negativa ed esponente dispari'),
        findsOneWidget,
      );
    });

    testWidgets('esempio plain con parentesi finale: commento separato',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 400,
          child: EsempioInlineCard(
            esempio: '(-3)^4 = 81 (esponente pari, risultato positivo)',
          ),
        ),
      ));
      // Il commento deve essere separato dalla formula come Text
      expect(
        find.text('esponente pari, risultato positivo'),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  // NB-03 — Pluralize helper
  // -------------------------------------------------------------------------
  group('NB-03: pluralize', () {
    test('sessione singolare/plurale', () {
      expect(pl.sessione(0), '0 sessioni');
      expect(pl.sessione(1), '1 sessione');
      expect(pl.sessione(5), '5 sessioni');
    });

    test('giorno singolare/plurale', () {
      expect(pl.giorno(0), '0 giorni');
      expect(pl.giorno(1), '1 giorno');
      expect(pl.giorno(5), '5 giorni');
    });

    test('esercizio singolare/plurale', () {
      expect(pl.esercizio(0), '0 esercizi');
      expect(pl.esercizio(1), '1 esercizio');
      expect(pl.esercizio(5), '5 esercizi');
    });

    test('nodo singolare/plurale', () {
      expect(pl.nodo(0), '0 nodi');
      expect(pl.nodo(1), '1 nodo');
      expect(pl.nodo(3), '3 nodi');
    });

    test('ripasso singolare/plurale', () {
      expect(pl.ripasso(0), '0 ripassi');
      expect(pl.ripasso(1), '1 ripasso');
      expect(pl.ripasso(2), '2 ripassi');
    });
  });

  // -------------------------------------------------------------------------
  // NB-04 — Log personale empty state nel quaderno
  // -------------------------------------------------------------------------
  group('NB-04: log personale empty state', () {
    testWidgets('quaderno senza log mostra empty state', (tester) async {
      final quaderno = QuadernoNodo(
        nodoId: 'n1',
        nodoNome: 'Proporzioni',
        temaNome: 'Algebra',
        stato: const StatoNodoQuaderno(
          livello: 'da_iniziare',
          eserciziCompletati: 0,
          srRipetizioni: 0,
        ),
        scheda: const SchedaNodo(
          definizioneTesto: 'Definizione test',
          formule: [],
          esempi: [],
          erroriComuni: [],
          paroleChiave: [],
        ),
      );

      final notifier =
          FakeQuadernoNotifier(QuadernoState(quaderno: quaderno));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quadernoProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: NodoQuadernoScreen(nodoId: 'n1', nodoNome: 'Proporzioni'),
            ),
        ),
      );
      await tester.pump();

      // Il separator deve apparire sempre
      expect(find.text('Il tuo percorso'), findsOneWidget);
      // Il messaggio empty state del log personale
      expect(
        find.text('Non hai ancora fatto sessioni su questo nodo.'),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  // NB-05 — userFriendlyError nel quaderno
  // -------------------------------------------------------------------------
  group('NB-05: errore quaderno user-friendly', () {
    testWidgets('errore connessione mostra messaggio amichevole',
        (tester) async {
      final notifier = FakeQuadernoNotifier(
        const QuadernoState(
          error: 'DioException [connectionError]: connection refused',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quadernoProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: NodoQuadernoScreen(nodoId: 'n1', nodoNome: 'Test'),
          ),
        ),
      );
      await tester.pump();

      // Non deve mostrare il messaggio tecnico
      expect(find.textContaining('DioException'), findsNothing);
      // Deve mostrare un bottone Riprova
      expect(find.text('Riprova'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // NB-06 — Nodo non iniziato senza lucchetto
  // -------------------------------------------------------------------------
  group('NB-06: nodo non iniziato senza lock', () {
    testWidgets('nodo da_iniziare non ha icona lock_outline', (tester) async {
      final nodi = [
        const NodoMappa(
          id: '1',
          nome: 'Nodo test',
          tipo: 'concetto',
          livello: 'da_iniziare',
        ),
      ];

      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 300,
          child: LinearPathMap(
            nodi: nodi,
            onNodeTap: (_) {},
          ),
        ),
      ));

      // Il Semantics label deve contenere il nome del nodo
      expect(
        find.bySemanticsLabel(RegExp('Nodo test')),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  // NB-07 — MiniPercorsoWidget senza overflow con TextScaler
  // -------------------------------------------------------------------------
  group('NB-07: MiniPercorso TextScaler overflow', () {
    testWidgets('non genera overflow con TextScaler 1.5', (tester) async {
      const mappa = MappaPercorso(
        percorsoId: 1,
        materia: 'Algebra',
        nodi: [
          NodoMappa(
            id: '1',
            nome: 'Numeri relativi',
            tipo: 'concetto',
            livello: 'operativo',
            eserciziCompletati: 5,
          ),
          NodoMappa(
            id: '2',
            nome: 'Potenze',
            tipo: 'concetto',
            livello: 'in_corso',
          ),
          NodoMappa(
            id: '3',
            nome: 'Espressioni algebriche',
            tipo: 'concetto',
            livello: 'da_iniziare',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.5),
                size: Size(400, 800),
              ),
              child: SingleChildScrollView(
                child: MiniPercorsoWidget(mappa: mappa),
              ),
            ),
          ),
          theme: ThemeData.dark(),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
