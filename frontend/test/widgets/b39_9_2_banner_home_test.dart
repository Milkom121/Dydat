/// Test B39.9.2 — Integrazione OnboardingPendingBanner in HomeScreen.
///
/// Verifica che il banner appaia/scompaia condizionalmente in base a
/// onboarding_stato dell'utente (not_started, in_progress, completed).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dydat/models/utente.dart';
import 'package:dydat/presentation/home_screen/home_screen.dart';
import 'package:dydat/providers/path_provider.dart';
import 'package:dydat/providers/ripasso_provider.dart';
import 'package:dydat/providers/session_provider.dart';
import 'package:dydat/providers/stats_provider.dart';
import 'package:dydat/providers/user_provider.dart';
import 'package:dydat/widgets/onboarding_pending_banner.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeUserNotifier extends StateNotifier<UserState>
    implements UserNotifier {
  _FakeUserNotifier(super.initial);
  @override
  Future<void> loadProfile() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSessionNotifier extends StateNotifier<SessionScreenState>
    implements SessionNotifier {
  _FakeSessionNotifier() : super(const SessionScreenState());
  @override
  Future<void> loadSessionHistory({int limit = 10, int offset = 0}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePathNotifier extends StateNotifier<PathState>
    implements PathNotifier {
  _FakePathNotifier() : super(const PathState());
  @override
  Future<void> loadPaths() async {}
  @override
  Future<void> loadMap(int percorsoId) async {}
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

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Utente _utente({String onboardingStato = 'not_started'}) => Utente(
      id: 'user-1',
      email: 'test@test.it',
      nome: 'Mario',
      onboardingStato: onboardingStato,
    );

Widget _wrapHome({required UserState userState}) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const Scaffold(body: Text('Onboarding')),
      ),
      GoRoute(
        path: '/studio',
        builder: (_, __) => const Scaffold(body: Text('Studio')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      userProvider.overrideWith((_) => _FakeUserNotifier(userState)),
      sessionProvider.overrideWith((_) => _FakeSessionNotifier()),
      pathProvider.overrideWith((_) => _FakePathNotifier()),
      ripassoProvider.overrideWith((_) => _FakeRipassoNotifier()),
      statsProvider.overrideWith((_) => _FakeStatsNotifier()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.dark(useMaterial3: true),
    ),
  );
}

// ---------------------------------------------------------------------------
// Test
// ---------------------------------------------------------------------------

void main() {
  group('Banner onboarding in HomeScreen — B39.9.2', () {
    testWidgets('mostra banner con CTA "Inizia" se onboarding not_started',
        (tester) async {
      await tester.pumpWidget(_wrapHome(
        userState: UserState(profile: _utente(onboardingStato: 'not_started')),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPendingBanner), findsOneWidget);
      expect(find.text('Inizia'), findsOneWidget);
      expect(find.text('Raccontami di te!'), findsOneWidget);
    });

    testWidgets('mostra banner con CTA "Riprendi" se onboarding in_progress',
        (tester) async {
      await tester.pumpWidget(_wrapHome(
        userState: UserState(profile: _utente(onboardingStato: 'in_progress')),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPendingBanner), findsOneWidget);
      expect(find.text('Riprendi'), findsOneWidget);
      expect(find.text('Riprendiamo da dove eravamo'), findsOneWidget);
    });

    testWidgets('NON mostra banner se onboarding completed', (tester) async {
      await tester.pumpWidget(_wrapHome(
        userState: UserState(profile: _utente(onboardingStato: 'completed')),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPendingBanner), findsNothing);
    });

    testWidgets('NON mostra banner se profilo non caricato (null)',
        (tester) async {
      await tester.pumpWidget(_wrapHome(
        userState: const UserState(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPendingBanner), findsNothing);
    });

    testWidgets('tap su banner naviga a /onboarding', (tester) async {
      await tester.pumpWidget(_wrapHome(
        userState: UserState(profile: _utente(onboardingStato: 'not_started')),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inizia'));
      await tester.pumpAndSettle();

      // Verifica navigazione avvenuta (la route /onboarding mostra 'Onboarding')
      expect(find.text('Onboarding'), findsOneWidget);
    });
  });

  group('Modello Utente — campo onboardingStato', () {
    test('default onboardingStato è not_started', () {
      const utente = Utente(id: 'u1');
      expect(utente.onboardingStato, 'not_started');
    });

    test('fromJson deserializza onboarding_stato', () {
      final json = {
        'id': 'u1',
        'email': 'test@t.it',
        'nome': 'Test',
        'obiettivo_giornaliero_min': 20,
        'onboarding_stato': 'in_progress',
      };
      final utente = Utente.fromJson(json);
      expect(utente.onboardingStato, 'in_progress');
    });

    test('fromJson usa default se onboarding_stato mancante', () {
      final json = {
        'id': 'u2',
        'obiettivo_giornaliero_min': 15,
      };
      final utente = Utente.fromJson(json);
      expect(utente.onboardingStato, 'not_started');
    });

    test('toJson serializza onboarding_stato', () {
      final utente = _utente(onboardingStato: 'completed');
      final json = utente.toJson();
      expect(json['onboarding_stato'], 'completed');
    });
  });
}
