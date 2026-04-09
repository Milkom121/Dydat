/// Test B35.7 — Pull-to-refresh sulle liste principali.
///
/// Verifica che HomeScreen e LearningPathScreen abbiano
/// meccanismi di refresh (RefreshIndicator / bottone).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dydat/presentation/home_screen/home_screen.dart';
import 'package:dydat/presentation/learning_path_screen/learning_path_screen.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/providers/path_provider.dart';
import 'package:dydat/providers/ripasso_provider.dart';
import 'package:dydat/providers/session_provider.dart';
import 'package:dydat/providers/stats_provider.dart';
import 'package:dydat/providers/user_provider.dart';

// ---------------------------------------------------------------------------
// Fake notifiers — non fanno chiamate reali
// ---------------------------------------------------------------------------

class _FakeSessionNotifier extends StateNotifier<SessionScreenState>
    implements SessionNotifier {
  _FakeSessionNotifier() : super(const SessionScreenState());
  @override
  Future<void> loadSessionHistory({int limit = 10, int offset = 0}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRipassoNotifier extends StateNotifier<RipassoState>
    implements RipassoNotifier {
  _FakeRipassoNotifier() : super(const RipassoState());
  @override
  Future<void> carica() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStatsNotifier extends StateNotifier<StatsState>
    implements StatsNotifier {
  _FakeStatsNotifier() : super(const StatsState());
  @override
  Future<void> load() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserNotifier extends StateNotifier<UserState>
    implements UserNotifier {
  _FakeUserNotifier() : super(const UserState());
  @override
  Future<void> loadProfile() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePathNotifier extends StateNotifier<PathState>
    implements PathNotifier {
  _FakePathNotifier([PathState? initial]) : super(initial ?? const PathState());
  @override
  Future<void> loadPaths() async {}
  @override
  Future<void> loadMap(int percorsoId) async {}
  @override
  Future<void> loadTopics() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Helper per wrappare widget con ProviderScope + MaterialApp
// ---------------------------------------------------------------------------

Widget _wrapHome() {
  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith((_) => _FakeSessionNotifier()),
      ripassoProvider.overrideWith((_) => _FakeRipassoNotifier()),
      statsProvider.overrideWith((_) => _FakeStatsNotifier()),
      pathProvider.overrideWith((_) => _FakePathNotifier()),
      userProvider.overrideWith((_) => _FakeUserNotifier()),
    ],
    child: MaterialApp(
      home: const HomeScreen(),
      theme: ThemeData.dark(useMaterial3: true),
    ),
  );
}

Widget _wrapLearningPath({PathState? pathState}) {
  return ProviderScope(
    overrides: [
      pathProvider.overrideWith((_) => _FakePathNotifier(pathState)),
      ripassoProvider.overrideWith((_) => _FakeRipassoNotifier()),
    ],
    child: MaterialApp(
      home: const LearningPathScreen(),
      theme: ThemeData.dark(useMaterial3: true),
    ),
  );
}

// ---------------------------------------------------------------------------
// Test
// ---------------------------------------------------------------------------

void main() {
  group('HomeScreen pull-to-refresh', () {
    testWidgets('contiene RefreshIndicator', (tester) async {
      await tester.pumpWidget(_wrapHome());
      await tester.pumpAndSettle();

      // Verifica che RefreshIndicator sia presente nel widget tree
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('SingleChildScrollView ha AlwaysScrollableScrollPhysics',
        (tester) async {
      await tester.pumpWidget(_wrapHome());
      await tester.pumpAndSettle();

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.physics, isA<AlwaysScrollableScrollPhysics>());
    });
  });

  group('LearningPathScreen refresh', () {
    testWidgets('AppBar contiene bottone refresh', (tester) async {
      await tester.pumpWidget(_wrapLearningPath());
      await tester.pumpAndSettle();

      // Cerca il bottone refresh tramite tooltip
      expect(find.byTooltip('Aggiorna'), findsOneWidget);
    });

    testWidgets('vista lineare ha RefreshIndicator quando ci sono nodi',
        (tester) async {
      // Stato con nodi per mostrare la vista lineare
      final pathState = PathState(
        currentMap: MappaPercorso(
          percorsoId: 1,
          materia: 'matematica',
          nodi: [
            NodoMappa(
              id: 'n1',
              nome: 'Numeri relativi',
              tipo: 'concetto',
              livello: 'non_iniziato',
            ),
            NodoMappa(
              id: 'n2',
              nome: 'Frazioni',
              tipo: 'concetto',
              livello: 'non_iniziato',
            ),
          ],
        ),
      );

      await tester.pumpWidget(_wrapLearningPath(pathState: pathState));
      await tester.pumpAndSettle();

      // Vista lineare default ha RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
