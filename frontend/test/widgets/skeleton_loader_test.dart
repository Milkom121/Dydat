import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dydat/widgets/skeleton_loader.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
      theme: ThemeData.dark(useMaterial3: true),
    );

void main() {
  group('SkeletonBox', () {
    testWidgets('renderizza con dimensioni specificate', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShimmerGroup(
          child: Center(child: SkeletonBox(width: 100, height: 50)),
        ),
      ));

      expect(find.byType(SkeletonBox), findsOneWidget);
    });

    testWidgets('funziona senza ShimmerGroup (statico)', (tester) async {
      await tester.pumpWidget(_wrap(
        const Center(child: SkeletonBox(width: 80, height: 30)),
      ));

      expect(find.byType(SkeletonBox), findsOneWidget);
      // Nessun errore, il box statico viene renderizzato
    });
  });

  group('SkeletonLine', () {
    testWidgets('renderizza come SkeletonBox sottile', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShimmerGroup(
          child: Center(child: SkeletonLine(width: 200)),
        ),
      ));

      expect(find.byType(SkeletonLine), findsOneWidget);
      expect(find.byType(SkeletonBox), findsOneWidget);
    });
  });

  group('SkeletonCard', () {
    testWidgets('renderizza con linee interne', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShimmerGroup(
          child: Center(child: SkeletonCard(height: 120)),
        ),
      ));

      expect(find.byType(SkeletonCard), findsOneWidget);
      // Contiene 3 SkeletonLine dentro
      expect(find.byType(SkeletonLine), findsNWidgets(3));
    });
  });

  group('ShimmerGroup', () {
    testWidgets('crea animazione shimmer', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShimmerGroup(
          child: Column(
            children: [
              SkeletonBox(width: 100, height: 20),
              SkeletonLine(width: 80),
            ],
          ),
        ),
      ));

      // L'animazione parte
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShimmerGroup), findsOneWidget);
      expect(find.byType(SkeletonBox), findsNWidgets(2)); // 1 box + 1 da line
    });

    testWidgets('dispose non causa errori', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShimmerGroup(
          child: SkeletonBox(width: 50, height: 50),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Rimuovi il widget — testa che dispose() non crashia
      await tester.pumpWidget(_wrap(const SizedBox()));
      expect(find.byType(ShimmerGroup), findsNothing);
    });
  });

  group('Layout skeleton pre-composti', () {
    testWidgets('LearningPathSkeleton renderizza 5 righe nodo', (tester) async {
      await tester.pumpWidget(_wrap(
        const SingleChildScrollView(child: LearningPathSkeleton()),
      ));

      expect(find.byType(LearningPathSkeleton), findsOneWidget);
      expect(find.byType(ShimmerGroup), findsOneWidget);
      // 5 cerchi nodo (borderRadius 28 = cerchio da 56px)
      // Ogni riga ha 1 SkeletonBox (cerchio) + 2 SkeletonLine
      // Totale SkeletonBox da cerchi: 5
      // SkeletonLine: 5*2 = 10
      expect(find.byType(SkeletonLine), findsNWidgets(10));
    });

    testWidgets('QuadernoSkeleton renderizza sezioni', (tester) async {
      await tester.pumpWidget(_wrap(const QuadernoSkeleton()));

      expect(find.byType(QuadernoSkeleton), findsOneWidget);
      expect(find.byType(ShimmerGroup), findsOneWidget);
      // Contiene SkeletonBox, SkeletonLine, SkeletonCard
      expect(find.byType(SkeletonCard), findsNWidgets(2));
    });

    testWidgets('RecapSkeleton renderizza narrativa e stats', (tester) async {
      await tester.pumpWidget(_wrap(
        const SingleChildScrollView(child: RecapSkeleton()),
      ));

      expect(find.byType(RecapSkeleton), findsOneWidget);
      expect(find.byType(ShimmerGroup), findsOneWidget);
    });

    testWidgets('ProfileSkeleton renderizza card e sezioni', (tester) async {
      await tester.pumpWidget(_wrap(const ProfileSkeleton()));

      expect(find.byType(ProfileSkeleton), findsOneWidget);
      expect(find.byType(ShimmerGroup), findsOneWidget);
    });

    testWidgets('shimmer anima correttamente', (tester) async {
      await tester.pumpWidget(_wrap(
        const SingleChildScrollView(child: LearningPathSkeleton()),
      ));

      // Avanza animazione — nessun errore
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.byType(LearningPathSkeleton), findsOneWidget);
    });
  });
}
