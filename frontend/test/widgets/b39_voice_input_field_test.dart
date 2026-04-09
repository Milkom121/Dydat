import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/voice_input_field.dart';

void main() {
  Widget buildTestWidget({
    ValueChanged<String>? onSubmit,
    bool enabled = true,
    String hintText = 'Scrivi qui...',
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: VoiceInputField(
            onSubmit: onSubmit ?? (_) {},
            enabled: enabled,
            hintText: hintText,
            controller: controller,
          ),
        ),
      ),
    );
  }

  group('VoiceInputField — rendering base', () {
    testWidgets('renderizza campo testo, microfono e invio', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Campo testo presente
      expect(find.byType(TextField), findsOneWidget);

      // Icona microfono presente
      expect(find.byIcon(Icons.mic), findsOneWidget);

      // Icona invio presente
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('mostra hintText personalizzato', (tester) async {
      await tester.pumpWidget(buildTestWidget(hintText: 'Raccontami di te...'));

      expect(find.text('Raccontami di te...'), findsOneWidget);
    });

    testWidgets('pulsante microfono è disabilitato', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Trova l'IconButton del microfono
      final micButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.mic),
          matching: find.byType(IconButton),
        ),
      );

      expect(micButton.onPressed, isNull);
    });

    testWidgets('tooltip microfono presente', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final micButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.mic),
          matching: find.byType(IconButton),
        ),
      );

      expect(micButton.tooltip, 'Voce — prossimamente');
    });
  });

  group('VoiceInputField — interazione', () {
    testWidgets('invio con pulsante send chiama onSubmit', (tester) async {
      String? submitted;
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (text) => submitted = text,
      ));

      await tester.enterText(find.byType(TextField), 'Ciao tutor');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(submitted, 'Ciao tutor');
    });

    testWidgets('invio con tastiera (onSubmitted) chiama onSubmit',
        (tester) async {
      String? submitted;
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (text) => submitted = text,
      ));

      await tester.enterText(find.byType(TextField), 'Test tastiera');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      expect(submitted, 'Test tastiera');
    });

    testWidgets('campo si svuota dopo invio', (tester) async {
      await tester.pumpWidget(buildTestWidget(onSubmit: (_) {}));

      await tester.enterText(find.byType(TextField), 'Testo da pulire');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('testo vuoto non invoca onSubmit', (tester) async {
      bool called = false;
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (_) => called = true,
      ));

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(called, false);
    });

    testWidgets('testo solo spazi non invoca onSubmit', (tester) async {
      bool called = false;
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (_) => called = true,
      ));

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(called, false);
    });
  });

  group('VoiceInputField — stato disabilitato', () {
    testWidgets('campo disabilitato non accetta input', (tester) async {
      await tester.pumpWidget(buildTestWidget(enabled: false));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('pulsante invio disabilitato quando enabled=false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(enabled: false));

      final sendButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send_rounded),
          matching: find.byType(IconButton),
        ),
      );

      expect(sendButton.onPressed, isNull);
    });
  });

  group('VoiceInputField — controller esterno', () {
    testWidgets('usa controller esterno se fornito', (tester) async {
      final externalController = TextEditingController(text: 'Precompilato');
      await tester.pumpWidget(buildTestWidget(controller: externalController));

      expect(find.text('Precompilato'), findsOneWidget);

      externalController.dispose();
    });

    testWidgets('controller esterno riceve il testo digitato', (tester) async {
      final externalController = TextEditingController();
      await tester.pumpWidget(buildTestWidget(controller: externalController));

      await tester.enterText(find.byType(TextField), 'Digitato');
      expect(externalController.text, 'Digitato');

      externalController.dispose();
    });
  });

  group('VoiceInputField — accessibilità', () {
    testWidgets('Semantics label sul microfono', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(
        find.bySemanticsLabel('Microfono — non ancora disponibile'),
        findsOneWidget,
      );
    });
  });
}
