import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/voice_input_field.dart';
import 'package:dydat/services/audio_recorder_service.dart';
import 'package:dydat/services/stt_service.dart';

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

  /// Controller per emettere ampiezza nei test
  final StreamController<double> amplitudeController =
      StreamController<double>.broadcast();

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
  Stream<double> get amplitudeStream => amplitudeController.stream;

  @override
  RecordingState get state => _state;

  @override
  void dispose() {
    disposeCalled = true;
    amplitudeController.close();
    _state = RecordingState.idle;
  }
}

/// Mock del servizio STT per i test
class MockSttService implements SttService {
  /// Testo che verrà ritornato dalla trascrizione
  String transcribedText = 'Testo trascritto dal mock';

  /// Tracker chiamate
  bool transcribeCalled = false;
  String? lastFilePath;

  /// Simula errori
  bool shouldThrow = false;
  String errorMessage = 'Errore trascrizione';

  /// Completer per controllare il timing della trascrizione nei test
  Completer<SttResult>? _completer;

  /// Se impostato, la trascrizione attende questo completer
  void useCompleter(Completer<SttResult> completer) {
    _completer = completer;
  }

  @override
  Future<SttResult> transcribe(String filePath) async {
    transcribeCalled = true;
    lastFilePath = filePath;

    if (_completer != null) {
      return _completer!.future;
    }

    if (shouldThrow) {
      throw SttException(errorMessage);
    }

    return SttResult(testo: transcribedText);
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
    SttService? sttService,
    ValueChanged<String>? onTranscriptionError,
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
            sttService: sttService,
            onTranscriptionError: onTranscriptionError,
          ),
        ),
      ),
    );
  }

  /// Helper: avvia registrazione e pompa un frame per processare lo stato.
  /// Non usa pumpAndSettle perché le animazioni repeat non si fermano mai.
  Future<void> startRecording(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// Helper: ferma registrazione e pompa per processare lo stato.
  Future<void> stopRecording(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
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

      await startRecording(tester);

      expect(mockRecorder.startCalled, true);
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

      await startRecording(tester);
      await stopRecording(tester);

      expect(mockRecorder.stopCalled, true);
      expect(recordedPath, '/tmp/test_audio.m4a');
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('campo testo nascosto durante registrazione', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      expect(find.byType(TextField), findsOneWidget);

      await startRecording(tester);

      // Durante registrazione: TextField sostituito dall'indicatore
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('pulsante invio disabilitato durante registrazione',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

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
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('errore su start non cambia stato', (tester) async {
      mockRecorder.shouldThrowOnStart = true;
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('errore su stop torna in idle', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      mockRecorder.shouldThrowOnStop = true;
      await stopRecording(tester);

      // Torna in idle — pumpAndSettle sicuro perché animazioni fermate
      await tester.pumpAndSettle();
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

      await startRecording(tester);
      await stopRecording(tester);

      expect(called, false);
    });
  });

  group('VoiceInputField — UI registrazione', () {
    testWidgets('mostra timer 00:00 all\'avvio registrazione', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('timer avanza dopo 1 secondo', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('00:01'), findsOneWidget);
    });

    testWidgets('timer avanza a 00:05 dopo 5 secondi', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text('00:05'), findsOneWidget);
    });

    testWidgets('timer mostra formato mm:ss per > 60 secondi',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      for (int i = 0; i < 65; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text('01:05'), findsOneWidget);
    });

    testWidgets('timer si resetta quando si ferma la registrazione',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:03'), findsOneWidget);

      await stopRecording(tester);

      expect(find.text('00:03'), findsNothing);
      expect(find.text('00:00'), findsNothing);
    });

    testWidgets('sfondo indicatore registrazione ha bordo arrotondato',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('00:00'),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border, isNotNull);
    });

    testWidgets('wave CustomPaint è presente durante registrazione',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('pulsante stop ha animazione scale (Transform)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      expect(
        find.ancestor(
          of: find.byIcon(Icons.stop_rounded),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );
    });

    testWidgets('ampiezza reagisce allo stream', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      mockRecorder.amplitudeController.add(0.7);
      await tester.pump();

      final state =
          tester.state<VoiceInputFieldState>(find.byType(VoiceInputField));
      expect(state.currentAmplitude, 0.7);
    });

    testWidgets('ampiezza si resetta a 0 dopo stop', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      mockRecorder.amplitudeController.add(0.8);
      await tester.pump();

      await stopRecording(tester);

      final state =
          tester.state<VoiceInputFieldState>(find.byType(VoiceInputField));
      expect(state.currentAmplitude, 0.0);
    });

    testWidgets('pallino rosso registrazione è visibile', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      // Il pallino rosso è un Container 8x8 con BoxShape.circle
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
        if (c.decoration is BoxDecoration) {
          final dec = c.decoration as BoxDecoration;
          return dec.shape == BoxShape.circle;
        }
        return false;
      });
      expect(containers.isNotEmpty, true);
    });

    testWidgets('elapsedSeconds esposto correttamente', (tester) async {
      await tester.pumpWidget(buildTestWidget(recorderService: mockRecorder));

      await startRecording(tester);

      final state =
          tester.state<VoiceInputFieldState>(find.byType(VoiceInputField));
      expect(state.elapsedSeconds, 0);

      await tester.pump(const Duration(seconds: 2));
      expect(state.elapsedSeconds, 2);
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

      await startRecording(tester);

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
      await startRecording(tester);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

      // 2. Ferma
      await stopRecording(tester);
      expect(recordedPath, '/tmp/test_audio.m4a');

      // 3. Scrivi testo e invia
      await tester.enterText(find.byType(TextField), 'Dopo la voce');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(submitted, 'Dopo la voce');
    });
  });

  group('VoiceInputField — trascrizione STT', () {
    late MockSttService mockStt;

    setUp(() {
      mockStt = MockSttService();
    });

    testWidgets('dopo stop chiama sttService.transcribe', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();

      expect(mockStt.transcribeCalled, true);
      expect(mockStt.lastFilePath, '/tmp/test_audio.m4a');
    });

    testWidgets('mostra spinner durante trascrizione', (tester) async {
      final completer = Completer<SttResult>();
      mockStt.useCompleter(completer);

      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();

      // Stato transcribing: spinner visibile
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Trascrizione in corso...'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      // Completa la trascrizione
      completer.complete(SttResult(testo: 'Testo'));
      await tester.pump();
      await tester.pump();

      // Torna a idle
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('testo trascritto popola il campo input', (tester) async {
      mockStt.transcribedText = 'Ciao, sono Mario';

      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();
      await tester.pump();

      expect(find.text('Ciao, sono Mario'), findsOneWidget);

      final state =
          tester.state<VoiceInputFieldState>(find.byType(VoiceInputField));
      expect(state.controller.text, 'Ciao, sono Mario');
    });

    testWidgets('pulsante invio disabilitato durante trascrizione',
        (tester) async {
      final completer = Completer<SttResult>();
      mockStt.useCompleter(completer);

      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();

      final sendButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(sendButton.onPressed, isNull);

      completer.complete(SttResult(testo: 'Ok'));
      await tester.pump();
      await tester.pump();
    });

    testWidgets('pulsante mic disabilitato durante trascrizione',
        (tester) async {
      final completer = Completer<SttResult>();
      mockStt.useCompleter(completer);

      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();

      final micButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.mic),
          matching: find.byType(IconButton),
        ),
      );
      expect(micButton.onPressed, isNull);

      completer.complete(SttResult(testo: 'Ok'));
      await tester.pump();
      await tester.pump();
    });

    testWidgets('errore STT chiama onTranscriptionError e torna idle',
        (tester) async {
      mockStt.shouldThrow = true;
      mockStt.errorMessage = 'Nessun parlato riconosciuto';
      String? errorMsg;

      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
        onTranscriptionError: (msg) => errorMsg = msg,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();
      await tester.pump();

      expect(errorMsg, 'Nessun parlato riconosciuto');
      expect(find.byType(TextField), findsOneWidget);

      final state =
          tester.state<VoiceInputFieldState>(find.byType(VoiceInputField));
      expect(state.recordingState, RecordingState.idle);
    });

    testWidgets('senza sttService stopRecording torna direttamente idle',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
      ));

      await startRecording(tester);
      await stopRecording(tester);

      final state =
          tester.state<VoiceInputFieldState>(find.byType(VoiceInputField));
      expect(state.recordingState, RecordingState.idle);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Semantics label durante trascrizione', (tester) async {
      final completer = Completer<SttResult>();
      mockStt.useCompleter(completer);

      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();

      expect(
        find.bySemanticsLabel('Trascrizione in corso'),
        findsOneWidget,
      );

      completer.complete(SttResult(testo: 'Ok'));
      await tester.pump();
      await tester.pump();
    });

    testWidgets('onAudioRecorded chiamato prima della trascrizione',
        (tester) async {
      String? recordedPath;
      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
        onAudioRecorded: (path) => recordedPath = path,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();

      // onAudioRecorded chiamato anche quando c'è STT
      expect(recordedPath, '/tmp/test_audio.m4a');
      expect(mockStt.transcribeCalled, true);
    });

    testWidgets('ciclo completo: registra -> trascrivi -> modifica -> invia',
        (tester) async {
      mockStt.transcribedText = 'Testo dalla voce';
      String? submitted;

      await tester.pumpWidget(buildTestWidget(
        onSubmit: (text) => submitted = text,
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      // 1. Registra
      await startRecording(tester);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

      // 2. Stop → trascrizione
      await stopRecording(tester);
      await tester.pump();
      await tester.pump();

      // 3. Il testo trascritto è nel campo
      expect(find.text('Testo dalla voce'), findsOneWidget);

      // 4. L'utente può modificare e inviare
      // (enterText sostituisce il contenuto)
      await tester.enterText(find.byType(TextField), 'Testo modificato');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(submitted, 'Testo modificato');
    });

    testWidgets('stopPath null non avvia trascrizione', (tester) async {
      mockRecorder.stopPath = null;

      await tester.pumpWidget(buildTestWidget(
        recorderService: mockRecorder,
        sttService: mockStt,
      ));

      await startRecording(tester);
      await stopRecording(tester);
      await tester.pump();

      expect(mockStt.transcribeCalled, false);

      final state =
          tester.state<VoiceInputFieldState>(find.byType(VoiceInputField));
      expect(state.recordingState, RecordingState.idle);
    });
  });
}
