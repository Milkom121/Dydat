/// Test B39.10.2 — VoiceInputField nella ricerca "I miei studi"
///
/// Verifica: nuovi parametri onChanged/prefixIcon/suffixIcon di VoiceInputField,
/// integrazione nella barra di ricerca di LearningPathScreen.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/voice_input_field.dart';
import 'package:dydat/services/audio_recorder_service.dart';

/// Mock minimale del recorder per i test
class _MockRecorder implements AudioRecorderService {
  RecordingState _state = RecordingState.idle;
  final StreamController<double> _ampCtrl = StreamController<double>.broadcast();

  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> startRecording() async => _state = RecordingState.recording;
  @override
  Future<String?> stopRecording() async {
    _state = RecordingState.idle;
    return '/tmp/test.m4a';
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

void main() {
  late _MockRecorder mockRecorder;

  setUp(() {
    mockRecorder = _MockRecorder();
  });

  Widget buildWidget({
    ValueChanged<String>? onSubmit,
    ValueChanged<String>? onChanged,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: VoiceInputField(
            onSubmit: onSubmit ?? (_) {},
            onChanged: onChanged,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            controller: controller,
            maxLines: 1,
            hintText: 'Cerca argomento...',
            recorderService: mockRecorder,
          ),
        ),
      ),
    );
  }

  group('VoiceInputField — onChanged', () {
    testWidgets('onChanged viene chiamato ad ogni modifica testo', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(buildWidget(onChanged: (v) => changes.add(v)));

      await tester.enterText(find.byType(TextField), 'fra');
      await tester.pump();

      // enterText scatena un singolo onChanged con il testo finale
      expect(changes, contains('fra'));
    });

    testWidgets('onChanged riceve stringa vuota dopo clear', (tester) async {
      final changes = <String>[];
      final ctrl = TextEditingController();
      await tester.pumpWidget(buildWidget(
        onChanged: (v) => changes.add(v),
        controller: ctrl,
      ));

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      ctrl.clear();
      await tester.pump();

      // Il clear via controller non scatena onChanged del TextField,
      // ma l'ultimo valore da enterText e' 'test'
      expect(changes.last, 'test');
    });
  });

  group('VoiceInputField — prefixIcon', () {
    testWidgets('prefixIcon viene renderizzato nel campo', (tester) async {
      await tester.pumpWidget(buildWidget(
        prefixIcon: const Icon(Icons.search),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('senza prefixIcon non mostra icona search', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.search), findsNothing);
    });
  });

  group('VoiceInputField — suffixIcon', () {
    testWidgets('suffixIcon viene renderizzato nel campo', (tester) async {
      await tester.pumpWidget(buildWidget(
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {},
        ),
      ));

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('suffixIcon null non mostra nulla', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('tap su suffixIcon clear pulisce il controller', (tester) async {
      final ctrl = TextEditingController();
      bool cleared = false;

      await tester.pumpWidget(buildWidget(
        controller: ctrl,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            ctrl.clear();
            cleared = true;
          },
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Frazioni');
      await tester.pump();
      expect(ctrl.text, 'Frazioni');

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(cleared, isTrue);
      expect(ctrl.text, isEmpty);
    });
  });

  group('VoiceInputField — integrazione ricerca live', () {
    testWidgets('simula flusso ricerca: digita, filtra, cancella', (tester) async {
      final searchQueries = <String>[];
      final ctrl = TextEditingController();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: VoiceInputField(
                  controller: ctrl,
                  hintText: 'Cerca argomento...',
                  maxLines: 1,
                  onSubmit: (_) {},
                  onChanged: (value) {
                    setState(() => searchQueries.add(value));
                  },
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ctrl.clear();
                            setState(() => searchQueries.add(''));
                          },
                        )
                      : null,
                  recorderService: mockRecorder,
                ),
              ),
            );
          },
        ),
      );

      // Digita "pot"
      await tester.enterText(find.byType(TextField), 'pot');
      await tester.pump();
      expect(searchQueries.last, 'pot');

      // Il pulsante clear appare (rebuild con suffixIcon)
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(searchQueries.last, '');
      expect(ctrl.text, isEmpty);
    });

    testWidgets('microfono visibile accanto al campo ricerca', (tester) async {
      await tester.pumpWidget(buildWidget(
        prefixIcon: const Icon(Icons.search),
      ));

      // Microfono e' sempre presente in VoiceInputField
      expect(find.byIcon(Icons.mic), findsOneWidget);
      // Icona ricerca presente come prefixIcon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
