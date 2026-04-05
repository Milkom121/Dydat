/// Test B29 — HomeViewWidget onRipassoTap.
///
/// Verifica che il bottone "Vai" nella sezione ripasso invochi [onRipassoTap]
/// quando il callback è fornito, e che la sezione ripasso sia visibile solo
/// quando [ripassoTotale] > 0.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dydat/presentation/studio_screen/widgets/home_view_widget.dart';

GoRouter _fakeRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SizedBox.shrink(),
      ),
    ],
  );
}

Widget _wrapWidget(Widget child) {
  return MaterialApp.router(
    routerConfig: _fakeRouter(),
    builder: (_, router) => Scaffold(body: child),
    theme: ThemeData.dark(),
  );
}

void main() {
  group('HomeViewWidget — sezione ripasso', () {
    testWidgets('sezione ripasso non visibile se ripassoTotale == 0', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        HomeViewWidget(
          showingHome: false,
          isActive: false,
          sessionHistory: const [],
          isLoadingHistory: false,
          ripassoTotale: 0,
        ),
      ));
      await tester.pumpAndSettle();

      // Il bottone "Vai" non deve essere presente
      expect(find.text('Vai'), findsNothing);
    });

    testWidgets('sezione ripasso visibile se ripassoTotale > 0', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        HomeViewWidget(
          showingHome: false,
          isActive: false,
          sessionHistory: const [],
          isLoadingHistory: false,
          ripassoTotale: 3,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Vai'), findsOneWidget);
      expect(find.text('3 nodi da ripassare'), findsOneWidget);
    });

    testWidgets('onRipassoTap invocato al tap sul bottone Vai', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(_wrapWidget(
        HomeViewWidget(
          showingHome: false,
          isActive: false,
          sessionHistory: const [],
          isLoadingHistory: false,
          ripassoTotale: 2,
          onRipassoTap: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vai'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('singolare "nodo" se ripassoTotale == 1', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        HomeViewWidget(
          showingHome: false,
          isActive: false,
          sessionHistory: const [],
          isLoadingHistory: false,
          ripassoTotale: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('1 nodo da ripassare'), findsOneWidget);
    });
  });
}
