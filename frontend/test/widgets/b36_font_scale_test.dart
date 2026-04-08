/// Test B36 — UI dimensione font nel Profilo.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dydat/providers/auth_provider.dart';
import 'package:dydat/providers/user_provider.dart';
import 'package:dydat/providers/stats_provider.dart';
import 'package:dydat/providers/achievement_provider.dart';
import 'package:dydat/presentation/profile_screen/profile_screen.dart';

/// Stub minimale per i provider richiesti da ProfileScreen.
/// noSuchMethod deve restituire `Future<void>` per i metodi async.
class _StubAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _StubAuthNotifier() : super(AuthState());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _StubUserNotifier extends StateNotifier<UserState>
    implements UserNotifier {
  _StubUserNotifier() : super(UserState());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _StubStatsNotifier extends StateNotifier<StatsState>
    implements StatsNotifier {
  _StubStatsNotifier() : super(StatsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _StubAchievementNotifier extends StateNotifier<AchievementState>
    implements AchievementNotifier {
  _StubAchievementNotifier() : super(AchievementState());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

Widget _wrapProfile() {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((_) => _StubAuthNotifier()),
      userProvider.overrideWith((_) => _StubUserNotifier()),
      statsProvider.overrideWith((_) => _StubStatsNotifier()),
      achievementProvider.overrideWith((_) => _StubAchievementNotifier()),
    ],
    child: MaterialApp(
      home: const ProfileScreen(),
      theme: ThemeData.dark(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('B36: sezione Aspetto nel Profilo', () {
    testWidgets('mostra le 4 opzioni di dimensione testo', (tester) async {
      await tester.pumpWidget(_wrapProfile());
      await tester.pumpAndSettle();

      expect(find.text('Aspetto'), findsOneWidget);
      expect(find.text('Dimensione testo'), findsOneWidget);
      expect(find.text('Piccolo'), findsOneWidget);
      expect(find.text('Normale'), findsOneWidget);
      expect(find.text('Grande'), findsOneWidget);
      expect(find.text('Molto grande'), findsOneWidget);
    });

    testWidgets('tap su Grande cambia la selezione', (tester) async {
      await tester.pumpWidget(_wrapProfile());
      await tester.pumpAndSettle();

      // Scorri giu per rendere visibile la sezione Aspetto
      await tester.scrollUntilVisible(
        find.text('Grande'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Grande'));
      await tester.pumpAndSettle();

      // Verifica che la selezione sia cambiata controllando il ChoiceChip
      final grandeChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Grande'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(grandeChip.selected, isTrue);
    });

    testWidgets('mostra anteprima live', (tester) async {
      await tester.pumpWidget(_wrapProfile());
      await tester.pumpAndSettle();

      // Scorri per rendere visibile l'anteprima
      await tester.scrollUntilVisible(
        find.textContaining('Anteprima:'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.textContaining('Anteprima:'),
        findsOneWidget,
      );
    });
  });
}
