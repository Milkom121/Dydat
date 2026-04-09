import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/providers/onboarding_provider.dart';
import 'package:dydat/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/sse_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/widgets/voice_input_field.dart';
import '../helpers/fake_secure_storage.dart';

/// Mock OnboardingService con stream controllati
class _MockOnboardingService extends OnboardingService {
  StreamController<SseEvent>? _startController;
  StreamController<SseEvent>? _turnController;

  _MockOnboardingService({
    required super.client,
    required super.sseClient,
  });

  StreamController<SseEvent> get startController {
    _startController ??= StreamController<SseEvent>();
    return _startController!;
  }

  StreamController<SseEvent> get turnController {
    _turnController ??= StreamController<SseEvent>();
    return _turnController!;
  }

  @override
  Stream<SseEvent> startStream() => startController.stream;

  @override
  Stream<SseEvent> sendTurnStream({
    required String sessioneId,
    required String messaggio,
  }) => turnController.stream;

  void dispose() {
    _startController?.close();
    _turnController?.close();
  }
}

late StorageService _storageService;

_MockOnboardingService _createMockService() {
  _storageService = StorageService(storage: FakeSecureStorage());
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  final dioClient = DioClient(storageService: _storageService, dio: dio);
  final sseClient = SseClient(storageService: _storageService);
  return _MockOnboardingService(client: dioClient, sseClient: sseClient);
}

Widget _buildTestWidget(_MockOnboardingService mockService) {
  return ProviderScope(
    overrides: [
      onboardingProvider.overrideWith(
        (ref) => OnboardingNotifier(
          onboardingService: mockService,
          storageService: _storageService,
        ),
      ),
    ],
    child: MaterialApp(
      home: const OnboardingScreen(),
      theme: ThemeData.dark(),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
      ),
    ),
  );
}

void _setup(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
}

/// Chiude il widget tree e consuma timer pendenti
/// (MascotteWidget.repeat + _scrollToBottom.Future.delayed)
Future<void> _tearDown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Consuma Future.delayed e animation timer residui
  await tester.pump(const Duration(seconds: 1));
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

/// Emette onboarding_iniziato + testo + turno_completo e processa i frame
Future<void> _emitFirstTurnAndSettle(
  WidgetTester tester,
  _MockOnboardingService mock, {
  String text = 'Ciao!',
}) async {
  mock.startController.add(const OnboardingIniziatoEvent(
    sessioneId: 'sess-1',
    utenteTempId: 'temp-1',
  ));
  mock.startController.add(TextDeltaEvent(testo: text));
  mock.startController.add(const TurnoCompletoEvent(turnoId: 1));
  await tester.pump(); // processa eventi SSE
  await tester.pump(const Duration(milliseconds: 150)); // attesa scrollToBottom
}

void main() {
  group('OnboardingScreen — rendering base', () {
    testWidgets('mostra barra progresso e etichetta fase', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      expect(find.text('Benvenuto'), findsOneWidget);
      expect(find.text('Salta per ora'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('mostra spinner iniziale prima dei messaggi', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('mostra VoiceInputField dopo primo messaggio tutor',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      expect(find.byType(VoiceInputField), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('OnboardingScreen — bottone skip', () {
    testWidgets('bottone "Salta per ora" è visibile fin dall\'inizio',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      expect(find.text('Salta per ora'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('skip imposta isSkipped nel provider (no utenteTempId)',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      // Usa GoRouter mock per catturare la navigazione
      late ProviderContainer container;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container = ProviderContainer(
            overrides: [
              onboardingProvider.overrideWith(
                (ref) => OnboardingNotifier(
                  onboardingService: mock,
                  storageService: _storageService,
                ),
              ),
            ],
          ),
          child: MaterialApp(
            home: const OnboardingScreen(),
            theme: ThemeData.dark(),
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Text('Route: ${settings.name}')),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verifica che skip imposti lo stato corretto nel provider
      final notifier = container.read(onboardingProvider.notifier);
      notifier.skipOnboarding();
      expect(container.read(onboardingProvider).isSkipped, isTrue);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('skip con utenteTempId imposta isSkipped', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      late ProviderContainer container;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container = ProviderContainer(
            overrides: [
              onboardingProvider.overrideWith(
                (ref) => OnboardingNotifier(
                  onboardingService: mock,
                  storageService: _storageService,
                ),
              ),
            ],
          ),
          child: MaterialApp(
            home: const OnboardingScreen(),
            theme: ThemeData.dark(),
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Text('Route: ${settings.name}')),
            ),
          ),
        ),
      );
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);
      expect(container.read(onboardingProvider).utenteTempId, 'temp-1');

      final notifier = container.read(onboardingProvider.notifier);
      notifier.skipOnboarding();
      expect(container.read(onboardingProvider).isSkipped, isTrue);
      expect(container.read(onboardingProvider).isStreaming, isFalse);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('OnboardingScreen — fasi e progresso', () {
    testWidgets('etichetta fase si aggiorna con decisione_onboarding',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      expect(find.text('Benvenuto'), findsOneWidget);

      mock.startController.add(const OnboardingIniziatoEvent(
        sessioneId: 'sess-1',
        utenteTempId: 'temp-1',
      ));
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo',
        campoDaChiedere: 'chi_e',
        motivo: 'campo mancante',
        faseCorrente: 'conoscenza',
        campiCompleti: 0,
      ));
      await tester.pump();

      expect(find.text('Conosciamoci'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('bottone completa appare in fase conclusione', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiudi_narrativa',
        faseCorrente: 'conclusione',
        campiCompleti: 5,
      ));
      await tester.pump();

      expect(find.text('Inizia il tuo percorso!'), findsOneWidget);
      expect(find.byType(VoiceInputField), findsNothing);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('bottone completa NON appare in fase conoscenza',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo',
        faseCorrente: 'conoscenza',
        campiCompleti: 2,
      ));
      await tester.pump();

      expect(find.text('Inizia il tuo percorso!'), findsNothing);
      expect(find.byType(VoiceInputField), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('OnboardingScreen — interazione messaggi', () {
    testWidgets('messaggio tutor appare nella bolla streaming', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      mock.startController.add(const OnboardingIniziatoEvent(
        sessioneId: 'sess-1',
        utenteTempId: 'temp-1',
      ));
      mock.startController
          .add(const TextDeltaEvent(testo: 'Ciao, sono il tuo tutor!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Ciao, sono il tuo tutor!'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('indicatore digitazione visibile durante streaming senza testo',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      mock.startController.add(const OnboardingIniziatoEvent(
        sessioneId: 'sess-1',
        utenteTempId: 'temp-1',
      ));
      await tester.pump();

      expect(find.text('Il tutor sta scrivendo...'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('VoiceInputField hint text è "Scrivi o parla..."',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      expect(find.text('Scrivi o parla...'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('OnboardingScreen — banner errore', () {
    testWidgets('mostra banner errore con bottone riprova', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      mock.startController.addError('Connessione persa');
      await tester.pump();

      expect(find.text('Riprova'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('OnboardingScreen — domande strutturate', () {
    testWidgets('nasconde VoiceInputField quando c\'è una scelta singola',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock, text: 'Scegli:');

      mock.startController.add(AzioneEvent(
        tipo: 'onboarding_domanda',
        params: {
          'tipo_input': 'scelta_singola',
          'domanda': 'Quale materia ti interessa?',
          'opzioni': ['Matematica', 'Fisica', 'Chimica'],
        },
      ));
      await tester.pump();

      expect(find.text('Quale materia ti interessa?'), findsOneWidget);
      expect(find.text('Matematica'), findsOneWidget);
      expect(find.byType(VoiceInputField), findsNothing);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('OnboardingScreen — etichette fase', () {
    testWidgets('tutte le etichette fase sono corrette', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      expect(find.text('Benvenuto'), findsOneWidget);

      mock.startController.add(const OnboardingIniziatoEvent(
        sessioneId: 's1',
        utenteTempId: 't1',
      ));

      for (final entry in {
        'conoscenza': 'Conosciamoci',
        'placement': 'Valutazione',
        'piano': 'Il tuo percorso',
        'conclusione': 'Pronti a partire',
      }.entries) {
        mock.startController.add(DecisioneOnboardingEvent(
          azione: 'test',
          faseCorrente: entry.key,
          campiCompleti: 3,
        ));
        await tester.pump();
        expect(find.text(entry.value), findsOneWidget);
      }

      mock.dispose();
      await _tearDown(tester);
    });
  });
}
