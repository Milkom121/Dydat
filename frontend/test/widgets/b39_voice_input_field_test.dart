import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/voice_input_field.dart';
import 'package:dydat/services/audio_recorder_service.dart';

/// Mock del servizio di registrazione audio per i test
class MockAudioRecorderService implements AudioRecorderService {
  bool _hasPermission = true;
  RecordingState _state = RecordingState.idle;

  /// Path ritornato da stopRecording
  String? stopPath = '/tmp/test_audio.m4a';

  /// Tracker chiamate
  bool startCalled = false;
  bool stopCalled = false;
  bool disposeCalled = false;

  /// Simula errori
  bool shouldThrowOnStart = false;
  bool shouldThrowOnStop = false;

  set hasPermissionResult(bool value) => _hasPermission = value;

  @override
  Future<bool> hasPermission() async => _hasPermission;

  @override
  Future<void> startRecording() async {
    if (shouldThrowOnStart) throw Exception('Start failed');
    startCalled = true;
    _state = RecordingState.recording;
  }

  @override
  Future<String?> stopRecording() async {
    if (shouldThrowOnStop) throw Exception('Stop failed');
    stopCalled = true;
    _state = RecordingState.idle;
    return stopPath;
  }

  @override
  RecordingState get state => _state;

  @override
  void dispose() {
    disposeCalled = true;
    _state = RecordingState.idle;
  }
}

void main() {
  late MockAudioRecorderService mockRecorder;

  setUp(() {
    mockRecorder = MockAudioRecorderService();
  });

  Widget buildTestWidget({
    ValueChanged<String>? onSubmit,
    bool enabled = true,
    String hintText = 'Scrivi qui...',
    TextEditingController? controller,
    ValueChanged<String>? onAudioRecorded,
    AudioRecorderService? recorderService,
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
            onAudioRecorded: onAudioRecorded,
            recorderService: recorderService,
          ),
        ),
      ),
    );
  }

  group('VoiceInputField — rendering base', () {
    testWidgets('renderizza campo testo, microfono e invio', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('mostra hintText personalizzato', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        hintText: 'Raccontami di te...',
        recorderService: mockRecorder,
      ));

      expect(find.text('Raccontami di te...'), findsOneWidget);
    });

    testWidgets('pulsante microfono è abilitato quando enabled=true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      final micButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.mic),
          matching: find.byType(IconButton),
        ),
      );

      expect(micButton.onPressed, isNotNull);
    });

    testWidgets('tooltip microfono mostra "Registra voce"', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      final micButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.mic),
          matching: find.byType(IconButton),
        ),
      );

      expect(micButton.tooltip, 'Registra voce');
    });
  });

  group('VoiceInputField — interazione testo', () {
    testWidgets('invio con pulsante send chiama onSubmit', (tester) async {
      String? submitted;
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (text) => submitted = text,
        recorderService: mockRecorder,
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
        recorderService: mockRecorder,
      ));

      await tester.enterText(find.byType(TextField), 'Test tastiera');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      expect(submitted, 'Test tastiera');
    });

    testWidgets('campo si svuota dopo invio', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(onSubmit: (_) {}, recorderService: mockRecorder));

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
        recorderService: mockRecorder,
      ));

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(called, false);
    });

    testWidgets('testo solo spazi non invoca onSubmit', (tester) async {
      bool called = false;
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (_) => called = true,
        recorderService: mockRecorder,
      ));

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(called, false);
    });
  });

  group('VoiceInputField — registrazione audio', () {
    testWidgets('tap microfono avvia registrazione', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      expect(mockRecorder.startCalled, true);
      // Icona cambia a stop
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('tap stop ferma registrazione e chiama onAudioRecorded',
        (tester) async {
      String? recordedPath;
      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        onAudioRecorded: (path) => recordedPath = path,
      ));

      // Avvia
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Ferma
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      expect(mockRecorder.stopCalled, true);
      expect(recordedPath, '/tmp/test_audio.m4a');
      // Torna icona mic
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('hintText cambia durante registrazione', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      expect(find.text('Registrazione in corso...'), findsOneWidget);
    });

    testWidgets('campo testo disabilitato durante registrazione',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('pulsante invio disabilitato durante registrazione',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      final sendButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('permesso negato non avvia registrazione', (tester) async {
      mockRecorder.hasPermissionResult = false;
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      expect(mockRecorder.startCalled, false);
      // Resta icona mic (non passa a stop)
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('errore su start non cambia stato', (tester) async {
      mockRecorder.shouldThrowOnStart = true;
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Resta in idle (icona mic)
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('errore su stop torna in idle', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      // Avvia con successo
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Stop con errore
      mockRecorder.shouldThrowOnStop = true;
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      // Torna in idle
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('stopRecording null non chiama onAudioRecorded',
        (tester) async {
      mockRecorder.stopPath = null;
      bool called = false;
      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        onAudioRecorded: (_) => called = true,
      ));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      expect(called, false);
    });
  });

  group('VoiceInputField — stato disabilitato', () {
    testWidgets('campo disabilitato non accetta input', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(enabled: false, recorderService: mockRecorder));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('pulsante invio disabilitato quando enabled=false',
        (tester) async {
      await tester.pumpWidget(
          buildTestWidget(enabled: false, recorderService: mockRecorder));

      final sendButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send_rounded),
          matching: find.byType(IconButton),
        ),
      );

      expect(sendButton.onPressed, isNull);
    });

    testWidgets('pulsante microfono disabilitato quando enabled=false',
        (tester) async {
      await tester.pumpWidget(
          buildTestWidget(enabled: false, recorderService: mockRecorder));

      final micButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.mic),
          matching: find.byType(IconButton),
        ),
      );

      expect(micButton.onPressed, isNull);
    });
  });

  group('VoiceInputField — controller esterno', () {
    testWidgets('usa controller esterno se fornito', (tester) async {
      final externalController = TextEditingController(text: 'Precompilato');
      await tester.pumpWidget(buildTestWidget(
        controller: externalController,
        recorderService: mockRecorder,
      ));

      expect(find.text('Precompilato'), findsOneWidget);

      externalController.dispose();
    });

    testWidgets('controller esterno riceve il testo digitato', (tester) async {
      final externalController = TextEditingController();
      await tester.pumpWidget(buildTestWidget(
        controller: externalController,
        recorderService: mockRecorder,
      ));

      await tester.enterText(find.byType(TextField), 'Digitato');
      expect(externalController.text, 'Digitato');

      externalController.dispose();
    });
  });

  group('VoiceInputField — accessibilità', () {
    testWidgets('Semantics label microfono in stato idle', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      expect(
        find.bySemanticsLabel('Registra messaggio vocale'),
        findsOneWidget,
      );
    });

    testWidgets('Semantics label cambia durante registrazione',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Ferma registrazione'),
        findsOneWidget,
      );
    });

    testWidgets('Semantics label permesso negato', (tester) async {
      mockRecorder.hasPermissionResult = false;
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Microfono — permesso negato'),
        findsOneWidget,
      );
    });
  });

  group('VoiceInputField — ciclo completo', () {
    testWidgets('registra -> ferma -> scrivi -> invia', (tester) async {
      String? submitted;
      String? recordedPath;
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (text) => submitted = text,
        onAudioRecorded: (path) => recordedPath = path,
        recorderService: mockRecorder,
      ));

      // 1. Registra audio
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

      // 2. Ferma
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();
      expect(recordedPath, '/tmp/test_audio.m4a');

      // 3. Scrivi testo e invia
      await tester.enterText(find.byType(TextField), 'Dopo la voce');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(submitted, 'Dopo la voce');
    });
  });
}
