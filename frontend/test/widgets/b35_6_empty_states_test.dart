import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dydat/presentation/learning_path_screen/widgets/empty_state_widget.dart';
import 'package:dydat/presentation/studio_screen/widgets/session_history_widget.dart';
import 'package:dydat/providers/achievement_provider.dart';
import 'package:dydat/providers/auth_provider.dart';
import 'package:dydat/providers/stats_provider.dart';
import 'package:dydat/providers/theme_provider.dart';
import 'package:dydat/providers/user_provider.dart';
import 'package:dydat/presentation/profile_screen/profile_screen.dart';
import 'package:dydat/models/statistiche.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
      theme: ThemeData.dark(useMaterial3: true),
    );

// ---------------------------------------------------------------------------
// Fake notifiers per ProfileScreen
// ---------------------------------------------------------------------------

class FakeUserNotifier extends StateNotifier<UserState>
    implements UserNotifier {
  FakeUserNotifier() : super(const UserState());
  @override
  Future<void> loadProfile() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStatsNotifier extends StateNotifier<StatsState>
    implements StatsNotifier {
  FakeStatsNotifier(super.initial);
  @override
  Future<void> load() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAchievementNotifier extends StateNotifier<AchievementState>
    implements AchievementNotifier {
  FakeAchievementNotifier(super.initial);
  @override
  Future<void> load() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeThemeNotifier extends StateNotifier<ThemeMode>
    implements ThemeNotifier {
  FakeThemeNotifier() : super(ThemeMode.dark);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  FakeAuthNotifier() : super(const AuthState());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrapProfile({
  StatsState? statsState,
  AchievementState? achievementState,
}) {
  return ProviderScope(
    overrides: [
      userProvider.overrideWith((_) => FakeUserNotifier()),
      statsProvider.overrideWith((_) => FakeStatsNotifier(
            statsState ?? const StatsState(),
          )),
      achievementProvider.overrideWith((_) => FakeAchievementNotifier(
            achievementState ?? const AchievementState(),
          )),
      themeProvider.overrideWith((_) => FakeThemeNotifier()),
      authProvider.overrideWith((_) => FakeAuthNotifier()),
    ],
    child: MaterialApp(
      home: const ProfileScreen(),
      theme: ThemeData.dark(useMaterial3: true),
    ),
  );
}

// ---------------------------------------------------------------------------
// EmptyStateWidget — I miei studi senza percorso
// ---------------------------------------------------------------------------

void main() {
  group('EmptyStateWidget (I miei studi)', () {
    testWidgets('mostra icona e testo motivazionale', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(EmptyStateWidget(onStartLearning: () => tapped = true)),
      );
      await tester.pumpAndSettle();

      // Nessun URL Unsplash o immagine esterna
      expect(find.byType(Image), findsNothing);

      // Icona nativa presente
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);

      // Testo caldo
      expect(find.text('Il tuo percorso ti aspetta'), findsOneWidget);
      expect(
        find.textContaining('Inizia una sessione di studio'),
        findsOneWidget,
      );

      // Bottone funziona
      expect(find.text('Inizia a studiare'), findsOneWidget);
      await tester.tap(find.text('Inizia a studiare'));
      expect(tapped, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // SessionHistoryWidget — storico sessioni vuoto
  // ---------------------------------------------------------------------------

  group('SessionHistoryWidget empty state', () {
    testWidgets('mostra messaggio quando lista sessioni vuota', (tester) async {
      await tester.pumpWidget(
        _wrap(SessionHistoryWidget(
          sessions: const [],
          isLoading: false,
          onSessionTap: (_) {},
        )),
      );
      await tester.pumpAndSettle();

      // Mostra icona e messaggio
      expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);
      expect(
        find.text('Le tue sessioni appariranno qui'),
        findsOneWidget,
      );

      // Non mostra titolo "Sessioni recenti"
      expect(find.text('Sessioni recenti'), findsNothing);
    });

    testWidgets('mostra spinner durante il caricamento', (tester) async {
      await tester.pumpWidget(
        _wrap(SessionHistoryWidget(
          sessions: const [],
          isLoading: true,
          onSessionTap: (_) {},
        )),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Non mostra empty state durante loading
      expect(
        find.text('Le tue sessioni appariranno qui'),
        findsNothing,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // ProfileScreen — achievement e stats per utente nuovo
  // ---------------------------------------------------------------------------

  group('ProfileScreen empty states', () {
    testWidgets('utente nuovo vede messaggio guida nelle stats', (tester) async {
      await tester.pumpWidget(_wrapProfile(
        statsState: StatsState(
          stats: StatisticheUtente(
            streak: 0,
            nodiCompletati: 0,
            sessioniCompletate: 0,
            settimana: const PeriodoStats(),
            mese: const PeriodoStats(),
            sempre: const PeriodoStats(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Messaggio guida per utente nuovo
      expect(
        find.textContaining('Completa la tua prima sessione'),
        findsOneWidget,
      );

      // Non mostra la riga "Streak / Nodi / Sessioni"
      expect(find.text('Streak'), findsNothing);
    });

    testWidgets('utente con sessioni vede stats numeriche', (tester) async {
      await tester.pumpWidget(_wrapProfile(
        statsState: StatsState(
          stats: StatisticheUtente(
            streak: 3,
            nodiCompletati: 5,
            sessioniCompletate: 2,
            settimana: const PeriodoStats(minutiStudio: 45, eserciziSvolti: 10, giorniAttivi: 3),
            mese: const PeriodoStats(),
            sempre: const PeriodoStats(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Mostra numeri (streak=3 appare anche in giorniAttivi=3)
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Sessioni'), findsOneWidget);
      expect(find.text('Questa settimana'), findsOneWidget);

      // Non mostra messaggio guida
      expect(
        find.textContaining('Completa la tua prima sessione'),
        findsNothing,
      );
    });

    testWidgets('achievement vuoti mostrano messaggio motivazionale', (tester) async {
      await tester.pumpWidget(_wrapProfile(
        achievementState: const AchievementState(),
      ));
      await tester.pumpAndSettle();

      // Icona e messaggio caldo
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
      expect(
        find.textContaining('I tuoi traguardi appariranno qui'),
        findsOneWidget,
      );
    });
  });
}
