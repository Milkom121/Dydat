import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dydat/widgets/onboarding_pending_banner.dart';

void main() {
  Widget buildTestWidget({
    required OnboardingBannerStato stato,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: OnboardingPendingBanner(
            stato: stato,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );
  }

  group('OnboardingPendingBanner', () {
    testWidgets('renderizza correttamente con stato nonIniziato',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.nonIniziato,
      ));

      expect(find.text('Raccontami di te!'), findsOneWidget);
      expect(
        find.text(
            'Una breve chiacchierata per costruire il tuo percorso su misura.'),
        findsOneWidget,
      );
      expect(find.text('Inizia'), findsOneWidget);
      // Non deve mostrare testi di stato inCorso
      expect(find.text('Riprendi'), findsNothing);
    });

    testWidgets('renderizza correttamente con stato inCorso', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.inCorso,
      ));

      expect(find.text('Riprendiamo da dove eravamo'), findsOneWidget);
      expect(
        find.text('Mancano pochi passi per completare il tuo profilo.'),
        findsOneWidget,
      );
      expect(find.text('Riprendi'), findsOneWidget);
      // Non deve mostrare testi di stato nonIniziato
      expect(find.text('Inizia'), findsNothing);
    });

    testWidgets('tap su CTA invoca callback per nonIniziato', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.nonIniziato,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.text('Inizia'));
      expect(tapped, isTrue);
    });

    testWidgets('tap su CTA invoca callback per inCorso', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.inCorso,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.text('Riprendi'));
      expect(tapped, isTrue);
    });

    testWidgets('mostra icona waving_hand', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.nonIniziato,
      ));

      expect(find.byIcon(Icons.waving_hand_rounded), findsOneWidget);
    });

    testWidgets('usa DydatSurface.glowCard (ha Container con BoxDecoration)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.nonIniziato,
      ));

      // Verifica che il Container principale abbia una BoxDecoration con gradient
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OnboardingPendingBanner),
          matching: find.byType(Container).first,
        ),
      );
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
    });

    testWidgets('ha Semantics con label accessibilita per nonIniziato',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.nonIniziato,
      ));

      final allSemantics = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final bannerSemantics = allSemantics.where(
        (s) => s.properties.label != null && s.properties.label!.contains('configurazione'),
      );
      expect(bannerSemantics, isNotEmpty);
      expect(bannerSemantics.first.properties.label,
          'Inizia la configurazione del tuo percorso');
      expect(bannerSemantics.first.properties.button, isTrue);
    });

    testWidgets('ha Semantics con label accessibilita per inCorso',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.inCorso,
      ));

      final allSemantics = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final bannerSemantics = allSemantics.where(
        (s) => s.properties.label != null && s.properties.label!.contains('configurazione'),
      );
      expect(bannerSemantics, isNotEmpty);
      expect(bannerSemantics.first.properties.label,
          'Riprendi la configurazione del tuo percorso');
      expect(bannerSemantics.first.properties.button, isTrue);
    });

    testWidgets('FilledButton occupa tutta la larghezza', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stato: OnboardingBannerStato.nonIniziato,
      ));

      // Il FilledButton è dentro un SizedBox con width: double.infinity
      final sizedBoxes = tester.widgetList<SizedBox>(
        find.ancestor(
          of: find.byType(FilledButton),
          matching: find.byType(SizedBox),
        ),
      );
      final fullWidthBox = sizedBoxes.where(
        (sb) => sb.width == double.infinity,
      );
      expect(fullWidthBox, isNotEmpty);
    });
  });

  group('OnboardingBannerStato enum', () {
    test('ha esattamente 2 valori', () {
      expect(OnboardingBannerStato.values.length, 2);
    });

    test('valori corretti', () {
      expect(OnboardingBannerStato.values,
          contains(OnboardingBannerStato.nonIniziato));
      expect(OnboardingBannerStato.values,
          contains(OnboardingBannerStato.inCorso));
    });
  });
}
