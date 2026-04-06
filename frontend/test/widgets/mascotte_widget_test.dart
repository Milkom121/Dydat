import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dydat/presentation/studio_screen/widgets/mascotte_widget.dart';

void main() {
  Widget buildTestWidget({
    MascotteState state = MascotteState.idle,
    bool showEntrance = false,
    bool showPromotionBurst = false,
    VoidCallback? onTap,
    VoidCallback? onEntranceComplete,
  }) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: MascotteWidget(
            theme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.amber,
                brightness: Brightness.dark,
              ),
            ),
            onTap: onTap ?? () {},
            mascotteState: state,
            showEntrance: showEntrance,
            onEntranceComplete: onEntranceComplete,
            showPromotionBurst: showPromotionBurst,
          ),
        ),
      ),
    );
  }

  group('MascotteWidget', () {
    testWidgets('renderizza senza errori con stato idle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.byType(MascotteWidget), findsOneWidget);
    });

    testWidgets('renderizza per ogni MascotteState', (tester) async {
      for (final state in MascotteState.values) {
        await tester.pumpWidget(buildTestWidget(state: state));
        await tester.pump();
        expect(find.byType(MascotteWidget), findsOneWidget);
      }
    });

    testWidgets('tap chiama onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('transizione tra stati non lancia errori', (tester) async {
      await tester.pumpWidget(buildTestWidget(state: MascotteState.idle));
      await tester.pump();

      await tester.pumpWidget(buildTestWidget(state: MascotteState.celebrating));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(MascotteWidget), findsOneWidget);
    });

    testWidgets('animazione ingresso si completa e chiama callback', (tester) async {
      var entranceCompleted = false;
      await tester.pumpWidget(buildTestWidget(
        showEntrance: true,
        onEntranceComplete: () => entranceCompleted = true,
      ));

      // Pompa abbastanza frame per completare l'animazione (1000ms + elasticOut)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 200));

      expect(entranceCompleted, isTrue);
    });

    testWidgets('celebrazione promozione renderizza senza errori', (tester) async {
      await tester.pumpWidget(buildTestWidget(showPromotionBurst: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MascotteWidget), findsOneWidget);
    });

    testWidgets('sleeping ha opacita ridotta', (tester) async {
      await tester.pumpWidget(buildTestWidget(state: MascotteState.sleeping));
      await tester.pump();

      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, 0.5);
    });

    testWidgets('non-sleeping ha opacita piena', (tester) async {
      await tester.pumpWidget(buildTestWidget(state: MascotteState.idle));
      await tester.pump();

      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, 1.0);
    });

    testWidgets('badge notifica presente', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Il badge e un Container con shape circle dentro Positioned
      expect(find.byType(Positioned), findsWidgets);
    });
  });
}
