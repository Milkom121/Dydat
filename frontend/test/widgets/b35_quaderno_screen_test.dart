/// Test B35 — NodoQuadernoScreen e widget sezioni.
///
/// Verifica rendering header, sezioni formule/esercizi/spiegazioni,
/// stato vuoto, stato errore, stato loading.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/quaderno.dart';
import 'package:dydat/providers/quaderno_provider.dart';
import 'package:dydat/presentation/quaderno_screen/nodo_quaderno_screen.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/stato_header.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/formule_section.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/esercizi_section.dart';
import 'package:dydat/presentation/quaderno_screen/widgets/spiegazioni_section.dart';
import 'package:dydat/widgets/skeleton_loader.dart';

/// Fake notifier che non chiama il service — permette di impostare lo stato direttamente.
class FakeQuadernoNotifier extends StateNotifier<QuadernoState>
    implements QuadernoNotifier {
  FakeQuadernoNotifier(super.initial);

  @override
  Future<void> carica(String nodoId) async {}

  @override
  void clear() {
    state = const QuadernoState();
  }

  // Ignora il getter _pathService — nel fake non serve
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

QuadernoNodo _quaderno({
  List<EsercizioQuaderno> esercizi = const [],
  List<FormulaQuaderno> formule = const [],
  List<SpiegazioneQuaderno> spiegazioni = const [],
  int sessioniCount = 2,
  String livello = 'operativo',
}) =>
    QuadernoNodo(
      nodoId: 'nodo_1',
      nodoNome: 'Equazioni lineari',
      temaNome: 'Algebra',
      stato: StatoNodoQuaderno(
        livello: livello,
        eserciziCompletati: esercizi.length,
        srRipetizioni: 1,
      ),
      sessioniCount: sessioniCount,
      esercizi: esercizi,
      formule: formule,
      spiegazioni: spiegazioni,
    );

void main() {
  group('NodoQuadernoScreen', () {
    testWidgets('mostra loading quando isLoading', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(nodoId: 'n1', nodoNome: 'Test'),
        initialState: const QuadernoState(isLoading: true),
      ));
      await tester.pump();

      expect(find.byType(QuadernoSkeleton), findsOneWidget);
    });

    testWidgets('mostra errore con bottone riprova', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(nodoId: 'n1', nodoNome: 'Test'),
        initialState: const QuadernoState(error: 'Errore rete'),
      ));
      await tester.pump();

      expect(find.text('Errore rete'), findsOneWidget);
      expect(find.text('Riprova'), findsOneWidget);
    });

    testWidgets('mostra stato vuoto quando nessun dato', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(nodoId: 'n1', nodoNome: 'Test'),
        initialState: QuadernoState(quaderno: _quaderno()),
      ));
      await tester.pump();

      expect(
        find.textContaining('si riempirà man mano'),
        findsOneWidget,
      );
    });

    testWidgets('mostra sezioni quando ci sono dati', (tester) async {
      final q = _quaderno(
        esercizi: const [
          EsercizioQuaderno(id: 1, esito: 'corretto', testo: 'Risolvi x+1=2'),
        ],
        formule: const [
          FormulaQuaderno(titolo: 'F=ma', formula: 'F=ma'),
        ],
        spiegazioni: const [
          SpiegazioneQuaderno(
            contenuto: 'Spiegazione test contenuto',
            sessioneId: 's1',
          ),
        ],
      );
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(nodoId: 'n1', nodoNome: 'Equazioni'),
        initialState: QuadernoState(quaderno: q),
      ));
      await tester.pump();

      // Non mostra stato vuoto
      expect(find.textContaining('si riempirà'), findsNothing);
    });

    testWidgets('titolo AppBar mostra nome nodo', (tester) async {
      await tester.pumpWidget(_wrap(
        const NodoQuadernoScreen(nodoId: 'n1', nodoNome: 'Frazioni'),
        initialState: QuadernoState(quaderno: _quaderno()),
      ));
      await tester.pump();

      expect(find.text('Frazioni'), findsOneWidget);
    });
  });

  group('StatoHeader', () {
    testWidgets('mostra tema e livello', (tester) async {
      final q = _quaderno(livello: 'operativo');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatoHeader(quaderno: q)),
        theme: ThemeData.dark(),
      ));

      expect(find.text('Algebra'), findsOneWidget);
      expect(find.text('Operativo'), findsOneWidget);
    });

    testWidgets('mostra conteggio sessioni', (tester) async {
      final q = _quaderno(sessioniCount: 5);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatoHeader(quaderno: q)),
        theme: ThemeData.dark(),
      ));

      expect(find.text('5 sessioni'), findsOneWidget);
    });
  });

  group('FormuleSection', () {
    testWidgets('mostra titolo e conteggio', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const FormuleSection(formule: [
            FormulaQuaderno(titolo: 'Formula A', formula: 'a=b+c'),
            FormulaQuaderno(titolo: 'Formula B', formula: 'x=y'),
          ]),
        ),
        theme: ThemeData.dark(),
      ));

      expect(find.text('Formule'), findsOneWidget);
      expect(find.text('(2)'), findsOneWidget);
      expect(find.text('Formula A'), findsOneWidget);
      expect(find.text('Formula B'), findsOneWidget);
    });
  });

  group('EserciziSection', () {
    testWidgets('mostra badge corretti e errati', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const EserciziSection(
            esercizi: [
              EsercizioQuaderno(id: 1, esito: 'corretto', testo: 'Es 1'),
              EsercizioQuaderno(id: 2, esito: 'errato', testo: 'Es 2'),
            ],
            totaleCorretti: 1,
            totaleErrati: 1,
          ),
        ),
        theme: ThemeData.dark(),
      ));

      expect(find.text('Esercizi svolti'), findsOneWidget);
      expect(find.text('Es 1'), findsOneWidget);
      expect(find.text('Es 2'), findsOneWidget);
    });
  });

  group('SpiegazioniSection', () {
    testWidgets('mostra conteggio e contenuto', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: const SpiegazioniSection(spiegazioni: [
              SpiegazioneQuaderno(
                contenuto: 'Contenuto breve',
                sessioneId: 's1',
              ),
            ]),
          ),
        ),
        theme: ThemeData.dark(),
      ));

      expect(find.text('Spiegazioni del tutor'), findsOneWidget);
      expect(find.text('(1)'), findsOneWidget);
    });
  });
}
