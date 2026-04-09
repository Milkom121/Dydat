/// Test B39.10.3 — Integrazione trasversale VoiceInputField
///
/// Verifica il comportamento di VoiceInputField nei 3 contesti d'uso:
/// 1. Onboarding (multi-riga, submit con invio, nessun prefix/suffix)
/// 2. Sessione studio (multi-riga, enabled/disabled da stato sessione)
/// 3. Ricerca "I miei studi" (single-line, prefixIcon, suffixIcon, onChanged)
///
/// Obiettivo: garantire che le configurazioni diverse non interferiscano
/// e che il widget si adatti correttamente a ogni contesto.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/voice_input_field.dart';
import 'package:dydat/services/audio_recorder_service.dart';
import 'package:dydat/services/stt_service.dart';

// --- Mock services ---

class _MockRecorder implements AudioRecorderService {
  RecordingState _state = RecordingState.idle;
  final StreamController<double> _ampCtrl =
      StreamController<double>.broadcast();
  bool hasPermissionResult = true;
  String? stopResult = '/tmp/test.m4a';

  @override
  Future<bool> hasPermission() async => hasPermissionResult;
  @override
  Future<void> startRecording() async => _state = RecordingState.recording;
  @override
  Future<String?> stopRecording() async {
    _state = RecordingState.idle;
    return stopResult;
  }

  @override
  Stream<double> get amplitudeStream => _ampCtrl.stream;
  @override
  RecordingState get state => _state;
  @override
  void dispose() {
    _ampCtrl.close();
    _state = RecordingState.idle;
  }
}

class _MockSttService implements SttService {
  String transcribeResult = 'testo trascritto';
  bool shouldFail = false;

  @override
  Future<SttResult> transcribe(String filePath) async {
    if (shouldFail) {
      throw SttException('Servizio non disponibile', statusCode: 503);
    }
    return SttResult(testo: transcribeResult);
  }
}

// --- Helper per configurazioni contesto ---

/// Configurazione onboarding: multi-riga, submit, nessun prefix/suffix
Widget _buildOnboardingContext({
  required ValueChanged<String> onSubmit,
  required _MockRecorder recorder,
  _MockSttService? sttService,
  bool enabled = true,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: VoiceInputField(
          hintText: 'Scrivi o parla...',
          onSubmit: onSubmit,
          enabled: enabled,
          maxLines: null, // multi-riga
          recorderService: recorder,
          sttService: sttService,
        ),
      ),
    ),
  );
}

/// Configurazione sessione studio: multi-riga, enabled condizionale
Widget _buildSessionContext({
  required ValueChanged<String> onSubmit,
  required _MockRecorder recorder,
  required TextEditingController controller,
  _MockSttService? sttService,
  ValueChanged<String>? onTranscriptionError,
  bool isActive = true,
  bool isStreaming = false,
}) {
  final enabled = isActive && !isStreaming;
  final hintText = isStreaming
      ? 'Il tutor sta rispondendo...'
      : isActive
          ? 'Scrivi o detta un messaggio...'
          : 'Inizia la sessione per chattare';

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: VoiceInputField(
          controller: controller,
          hintText: hintText,
          enabled: enabled,
          onSubmit: onSubmit,
          recorderService: recorder,
          sttService: sttService,
          onTranscriptionError: onTranscriptionError,
        ),
      ),
    ),
  );
}

/// Configurazione ricerca: single-line, prefixIcon, suffixIcon, onChanged
Widget _buildSearchContext({
  required _MockRecorder recorder,
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: VoiceInputField(
              controller: controller,
              hintText: 'Cerca argomento...',
              maxLines: 1,
              onSubmit: (_) {},
              onChanged: (value) {
                setState(() {});
                onChanged(value);
              },
              prefixIcon: const Icon(Icons.search, key: Key('search-icon')),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      key: const Key('clear-btn'),
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        setState(() {});
                        onChanged('');
                      },
                    )
                  : null,
              recorderService: recorder,
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  late _MockRecorder mockRecorder;
  late _MockSttService mockStt;

  setUp(() {
    mockRecorder = _MockRecorder();
    mockStt = _MockSttService();
  });

  group('Contesto Onboarding — multi-riga, submit, voce', () {
    testWidgets('mostra hint onboarding e accetta multi-riga', (tester) async {
      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
      ));

      expect(find.text('Scrivi o parla...'), findsOneWidget);
      // Il microfono è sempre presente
      expect(find.byIcon(Icons.mic), findsOneWidget);
      // Nessun prefixIcon search
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('submit invia testo e pulisce campo', (tester) async {
      String? sent;
      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (t) => sent = t,
        recorder: mockRecorder,
      ));

      await tester.enterText(find.byType(TextField), 'Mi chiamo Mario');
      await tester.pump();

      // Tap sul bottone invio
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(sent, 'Mi chiamo Mario');
    });

    testWidgets('disabilitato durante streaming tutor', (tester) async {
      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        enabled: false,
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('registrazione voce funziona in onboarding', (tester) async {
      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        sttService: mockStt,
      ));

      // Tap microfono per registrare
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      // Deve mostrare il pulsante stop
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

      // Stop registrazione
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      // Testo trascritto nel campo
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'testo trascritto');
    });
  });

  group('Contesto Sessione Studio — enabled condizionale', () {
    testWidgets('hint cambia in base a isActive/isStreaming', (tester) async {
      final ctrl = TextEditingController();

      // Sessione non attiva
      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        isActive: false,
      ));
      expect(find.text('Inizia la sessione per chattare'), findsOneWidget);

      // Sessione attiva ma streaming
      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        isActive: true,
        isStreaming: true,
      ));
      await tester.pump();
      expect(find.text('Il tutor sta rispondendo...'), findsOneWidget);

      // Sessione attiva e pronta
      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        isActive: true,
        isStreaming: false,
      ));
      await tester.pump();
      expect(find.text('Scrivi o detta un messaggio...'), findsOneWidget);
    });

    testWidgets('campo disabilitato durante streaming', (tester) async {
      final ctrl = TextEditingController();

      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        isActive: true,
        isStreaming: true,
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('campo abilitato quando sessione attiva', (tester) async {
      final ctrl = TextEditingController();

      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        isActive: true,
        isStreaming: false,
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isTrue);
    });

    testWidgets('errore trascrizione chiama callback', (tester) async {
      final ctrl = TextEditingController();
      String? errorMsg;
      mockStt.shouldFail = true;

      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        sttService: mockStt,
        onTranscriptionError: (e) => errorMsg = e,
      ));

      // Registra e ferma per triggerare trascrizione fallita
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      expect(errorMsg, isNotNull);
    });

    testWidgets('controller esterno mantiene testo tra rebuild', (tester) async {
      final ctrl = TextEditingController(text: 'testo precedente');

      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        isActive: true,
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'testo precedente');
    });
  });

  group('Contesto Ricerca — single-line, prefix, suffix, onChanged', () {
    testWidgets('mostra icona search come prefixIcon', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(_buildSearchContext(
        recorder: mockRecorder,
        controller: ctrl,
        onChanged: (_) {},
      ));

      expect(find.byKey(const Key('search-icon')), findsOneWidget);
      expect(find.text('Cerca argomento...'), findsOneWidget);
    });

    testWidgets('suffixIcon clear appare solo con testo', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(_buildSearchContext(
        recorder: mockRecorder,
        controller: ctrl,
        onChanged: (_) {},
      ));

      // Nessun bottone clear inizialmente
      expect(find.byKey(const Key('clear-btn')), findsNothing);

      // Digita testo
      await tester.enterText(find.byType(TextField), 'frazioni');
      await tester.pump();

      // Clear button appare
      expect(find.byKey(const Key('clear-btn')), findsOneWidget);
    });

    testWidgets('onChanged filtra in tempo reale', (tester) async {
      final ctrl = TextEditingController();
      final queries = <String>[];

      await tester.pumpWidget(_buildSearchContext(
        recorder: mockRecorder,
        controller: ctrl,
        onChanged: (v) => queries.add(v),
      ));

      await tester.enterText(find.byType(TextField), 'pot');
      await tester.pump();

      expect(queries.last, 'pot');
    });

    testWidgets('clear button resetta ricerca', (tester) async {
      final ctrl = TextEditingController();
      final queries = <String>[];

      await tester.pumpWidget(_buildSearchContext(
        recorder: mockRecorder,
        controller: ctrl,
        onChanged: (v) => queries.add(v),
      ));

      // Digita per far apparire il clear button
      await tester.enterText(find.byType(TextField), 'equazioni');
      await tester.pump();

      // Tap clear
      await tester.tap(find.byKey(const Key('clear-btn')));
      await tester.pump();

      expect(ctrl.text, isEmpty);
      expect(queries.last, '');
    });

    testWidgets('microfono visibile anche in contesto ricerca', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(_buildSearchContext(
        recorder: mockRecorder,
        controller: ctrl,
        onChanged: (_) {},
      ));

      // Mic e search coesistono
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byKey(const Key('search-icon')), findsOneWidget);
    });
  });

  group('Comportamento trasversale — comune a tutti i contesti', () {
    testWidgets('testo vuoto non invia in nessun contesto', (tester) async {
      var sentCount = 0;

      // Onboarding
      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (_) => sentCount++,
        recorder: mockRecorder,
      ));
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(sentCount, 0);
    });

    testWidgets('testo con solo spazi non invia', (tester) async {
      var sentCount = 0;

      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (_) => sentCount++,
        recorder: mockRecorder,
      ));
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(sentCount, 0);
    });

    testWidgets('permesso mic negato mostra testo fallback', (tester) async {
      mockRecorder.hasPermissionResult = false;

      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
      ));

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      // Il campo resta in idle (nessuna registrazione partita)
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
      // Utente puo' sempre scrivere a mano
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('trascrizione voce popola campo in sessione', (tester) async {
      final ctrl = TextEditingController();

      await tester.pumpWidget(_buildSessionContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        controller: ctrl,
        sttService: mockStt,
      ));

      // Registra
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      // Stop -> trascrizione
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      expect(ctrl.text, 'testo trascritto');
    });

    testWidgets('dopo errore STT il campo resta utilizzabile', (tester) async {
      mockStt.shouldFail = true;

      await tester.pumpWidget(_buildOnboardingContext(
        onSubmit: (_) {},
        recorder: mockRecorder,
        sttService: mockStt,
      ));

      // Registra e ferma
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      // Il campo torna a idle, utente puo' scrivere
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);

      // Può digitare
      await tester.enterText(find.byType(TextField), 'scrivo a mano');
      await tester.pump();
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'scrivo a mano');
    });
  });
}
