import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dydat/theme/surface_decorations.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(body: child),
    );
  }

  group('DydatSurface', () {
    testWidgets('backgroundGradient produce RadialGradient', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.backgroundGradient(context);
          return const SizedBox();
        }),
      ));

      expect(decoration.gradient, isA<RadialGradient>());
      final gradient = decoration.gradient as RadialGradient;
      expect(gradient.colors.length, 2);
    });

    testWidgets('card produce LinearGradient con bordo e ombra', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.card(context);
          return const SizedBox();
        }),
      ));

      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.borderRadius, BorderRadius.circular(16.0));
      expect(decoration.border, isNotNull);
      // depthLevel 1 produce 2 ombre
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 2);
    });

    testWidgets('card depthLevel 0 produce zero ombre', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.card(context, depthLevel: 0);
          return const SizedBox();
        }),
      ));

      expect(decoration.boxShadow, isEmpty);
    });

    testWidgets('glowCard ha ombra glow + ombre profondita', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.glowCard(context);
          return const SizedBox();
        }),
      ));

      expect(decoration.gradient, isA<LinearGradient>());
      // 1 glow + 2 depth = 3 ombre
      expect(decoration.boxShadow!.length, 3);
    });

    testWidgets('glowCard con colore custom usa il colore fornito', (tester) async {
      late BoxDecoration decoration;
      const customColor = Colors.green;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.glowCard(
            context,
            glowColor: customColor,
          );
          return const SizedBox();
        }),
      ));

      // Il bordo deve usare il colore custom (verde)
      final border = decoration.border as Border;
      expect(border.top.color.g, greaterThan(border.top.color.r));
    });

    testWidgets('section produce gradiente con tint', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.section(context, tintColor: Colors.green);
          return const SizedBox();
        }),
      ));

      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, BorderRadius.circular(16.0));
    });

    testWidgets('glowCircle produce cerchio con ombre glow', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.glowCircle(
            context,
            nodeColor: Colors.amber,
          );
          return const SizedBox();
        }),
      ));

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 2);
      expect(decoration.border, isNotNull);
    });

    testWidgets('depthShadows livello 2 produce ombre piu intense', (tester) async {
      late List<BoxShadow> shadows1;
      late List<BoxShadow> shadows2;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          shadows1 = DydatSurface.depthShadows(context, level: 1);
          shadows2 = DydatSurface.depthShadows(context, level: 2);
          return const SizedBox();
        }),
      ));

      expect(shadows1.length, 2);
      expect(shadows2.length, 2);
      // Livello 2 ha blur maggiore
      expect(shadows2[0].blurRadius, greaterThan(shadows1[0].blurRadius));
    });

    testWidgets('depthShadows livello 0 produce lista vuota', (tester) async {
      late List<BoxShadow> shadows;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          shadows = DydatSurface.depthShadows(context, level: 0);
          return const SizedBox();
        }),
      ));

      expect(shadows, isEmpty);
    });

    testWidgets('card con borderRadius custom', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(buildTestWidget(
        Builder(builder: (context) {
          decoration = DydatSurface.card(context, borderRadius: 8.0);
          return const SizedBox();
        }),
      ));

      expect(decoration.borderRadius, BorderRadius.circular(8.0));
    });
  });
}
