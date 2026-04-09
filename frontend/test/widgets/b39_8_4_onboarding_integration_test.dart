import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/onboarding.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/providers/onboarding_provider.dart';
import 'package:dydat/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/sse_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/widgets/voice_input_field.dart';
import '../helpers/fake_secure_storage.dart';

/// Mock OnboardingService con stream controllati e complete mockato
class _MockOnboardingService extends OnboardingService {
  StreamController<SseEvent>? _startController;
  final List<StreamController<SseEvent>> _turnControllers = [];
  int _turnIndex = 0;

  /// Traccia le chiamate sendTurnStream per verifica
  final List<String> sentMessages = [];

  /// Risposta per complete()
  OnboardingCompletaResponse? completeResponse;

  /// Se non-null, complete() lancia questo errore
  DioException? completeError;

  /// Risposta per getResumeState() (usato da resumeOnboarding).
  /// Default: sessione vuota coerente con sess-1/temp-1 usati nei test.
  OnboardingRipresaResponse? resumeResponse;

  /// Se non-null, getResumeState() lancia questo errore
  DioException? resumeError;

  _MockOnboardingService({
    required super.client,
    required super.sseClient,
  });

  StreamController<SseEvent> get startController {
    _startController ??= StreamController<SseEvent>();
    return _startController!;
  }

  /// Crea e restituisce un nuovo turn controller per il prossimo sendTurnStream
  StreamController<SseEvent> createTurnController() {
    final controller = StreamController<SseEvent>();
    _turnControllers.add(controller);
    return controller;
  }

  @override
  Stream<SseEvent> startStream() => startController.stream;

  @override
  Stream<SseEvent> sendTurnStream({
    required String sessioneId,
    required String messaggio,
  }) {
    sentMessages.add(messaggio);
    if (_turnIndex < _turnControllers.length) {
      return _turnControllers[_turnIndex++].stream;
    }
    // Fallback: crea controller al volo
    final controller = createTurnController();
    _turnIndex++;
    return controller.stream;
  }

  @override
  Future<OnboardingCompletaResponse> complete({
    required String sessioneId,
    Map<String, dynamic>? contestoPersonale,
    Map<String, dynamic>? preferenzeTutor,
  }) async {
    if (completeError != null) throw completeError!;
    return completeResponse ??
        const OnboardingCompletaResponse(
          percorsoId: 1,
          nodoIniziale: 'nodo-1',
          nodiInizializzati: 10,
        );
  }

  @override
  Future<OnboardingRipresaResponse> getResumeState({
    required String utenteId,
  }) async {
    if (resumeError != null) throw resumeError!;
    return resumeResponse ??
        const OnboardingRipresaResponse(
          sessioneId: 'sess-1',
          faseCorrente: 'conoscenza',
          campiCompleti: 0,
          turni: [],
        );
  }

  void dispose() {
    _startController?.close();
    for (final c in _turnControllers) {
      c.close();
    }
  }
}

late StorageService _storageService;
late ProviderContainer _container;

_MockOnboardingService _createMockService() {
  _storageService = StorageService(storage: FakeSecureStorage());
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  final dioClient = DioClient(storageService: _storageService, dio: dio);
  final sseClient = SseClient(storageService: _storageService);
  return _MockOnboardingService(client: dioClient, sseClient: sseClient);
}

Widget _buildTestWidget(_MockOnboardingService mockService) {
  _container = ProviderContainer(
    overrides: [
      onboardingProvider.overrideWith(
        (ref) => OnboardingNotifier(
          onboardingService: mockService,
          storageService: _storageService,
        ),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: _container,
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

Future<void> _tearDown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

/// Emette onboarding_iniziato + testo + turno_completo e processa i frame
Future<void> _emitFirstTurnAndSettle(
  WidgetTester tester,
  _MockOnboardingService mock, {
  String text = 'Ciao, raccontami di te!',
}) async {
  mock.startController.add(const OnboardingIniziatoEvent(
    sessioneId: 'sess-1',
    utenteTempId: 'temp-1',
  ));
  mock.startController.add(TextDeltaEvent(testo: text));
  mock.startController.add(const TurnoCompletoEvent(turnoId: 1));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
}

/// Simula invio messaggio utente tramite il provider (bypassa UI per affidabilita)
Future<void> _sendUserMessage(
  WidgetTester tester,
  String message,
) async {
  _container.read(onboardingProvider.notifier).sendMessage(message);
  await tester.pump();
}

void main() {
  group('Integrazione — utente collaborativo (flusso completo)', () {
    testWidgets(
        'accoglienza -> conoscenza -> placement -> conclusione -> completa',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      // === Fase 1: Accoglienza — tutor saluta ===
      expect(find.text('Benvenuto'), findsOneWidget);

      await _emitFirstTurnAndSettle(tester, mock,
          text: 'Ciao! Sono Dydat, il tuo tutor. Raccontami di te!');

      expect(find.textContaining('Sono Dydat'), findsOneWidget);
      expect(find.byType(VoiceInputField), findsOneWidget);

      // === Fase 2: Conoscenza — utente risponde ===
      final turn1 = mock.createTurnController();
      await _sendUserMessage(tester,
          'Sono Marco, studio matematica per l\'esame');

      expect(mock.sentMessages.length, 1);

      // Backend risponde con testo + decisione (conoscenza, 2 campi)
      turn1.add(const TextDeltaEvent(
          testo: 'Ottimo Marco! Che tipo di studio preferisci?'));
      turn1.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo_mancante',
        campoDaChiedere: 'stile_cognitivo',
        motivo: 'campo mancante',
        faseCorrente: 'conoscenza',
        campiCompleti: 2,
      ));
      turn1.add(const TurnoCompletoEvent(turnoId: 2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Etichetta fase aggiornata
      expect(find.text('Conosciamoci'), findsOneWidget);
      final state1 = _container.read(onboardingProvider);
      expect(state1.faseCorrente, OnboardingFase.conoscenza);
      expect(state1.campiCompleti, 2);

      // === Turno 3: utente risponde ancora ===
      final turn2 = mock.createTurnController();
      await _sendUserMessage(tester, 'Preferisco esempi pratici e concreti');

      turn2.add(const TextDeltaEvent(
          testo: 'Perfetto! Quanto tempo hai?'));
      turn2.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo_mancante',
        campoDaChiedere: 'tempo_disponibile',
        motivo: 'campo mancante',
        faseCorrente: 'conoscenza',
        campiCompleti: 3,
      ));
      turn2.add(const TurnoCompletoEvent(turnoId: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(_container.read(onboardingProvider).campiCompleti, 3);

      // === Turno 4: chiusura narrativa -> placement ===
      final turn3 = mock.createTurnController();
      await _sendUserMessage(tester, 'Ho circa un\'ora al giorno');

      turn3.add(const TextDeltaEvent(
          testo: 'Ora facciamo una breve valutazione!'));
      turn3.add(const DecisioneOnboardingEvent(
        azione: 'chiudi_narrativa',
        faseCorrente: 'placement',
        campiCompleti: 5,
      ));
      turn3.add(const TurnoCompletoEvent(turnoId: 4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Valutazione'), findsOneWidget);
      expect(_container.read(onboardingProvider).faseCorrente,
          OnboardingFase.placement);

      // === Fase conclusione ===
      final turn4 = mock.createTurnController();
      await _sendUserMessage(tester, 'Algebra mi sento forte');

      turn4.add(const TextDeltaEvent(
          testo: 'Il tuo percorso è pronto!'));
      turn4.add(const DecisioneOnboardingEvent(
        azione: 'chiudi_narrativa',
        faseCorrente: 'conclusione',
        campiCompleti: 5,
      ));
      turn4.add(const TurnoCompletoEvent(turnoId: 5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Pronti a partire'), findsOneWidget);
      expect(find.text('Inizia il tuo percorso!'), findsOneWidget);
      expect(find.byType(VoiceInputField), findsNothing);

      // === Completa via provider (evita GoRouter assente in test) ===
      mock.completeResponse = const OnboardingCompletaResponse(
        percorsoId: 42,
        nodoIniziale: 'equazioni-primo-grado',
        nodiInizializzati: 15,
      );

      await _container
          .read(onboardingProvider.notifier)
          .completeOnboarding();
      await tester.pump();

      final finalState = _container.read(onboardingProvider);
      expect(finalState.isCompleted, isTrue);
      expect(finalState.result?.percorsoId, 42);
      expect(finalState.result?.nodiInizializzati, 15);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('Integrazione — utente taciturno (chiusura forzata al tetto turni)',
      () {
    testWidgets('risposte minime -> forza_chiusura_tetto_turni -> placement',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      // Tutor saluta
      await _emitFirstTurnAndSettle(tester, mock,
          text: 'Ciao! Raccontami qualcosa di te.');

      // L'utente risponde con frasi minime per 5 turni
      for (int i = 0; i < 5; i++) {
        final turnCtrl = mock.createTurnController();
        await _sendUserMessage(tester, 'Boh');

        turnCtrl.add(TextDeltaEvent(
            testo: 'Capisco, dimmi di più... (turno ${i + 2})'));
        turnCtrl.add(DecisioneOnboardingEvent(
          azione: 'chiedi_campo_mancante',
          campoDaChiedere: 'motivo',
          motivo: 'campo mancante',
          faseCorrente: 'conoscenza',
          campiCompleti: i < 3 ? i : i - 1,
        ));
        turnCtrl.add(TurnoCompletoEvent(turnoId: i + 2));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
      }

      // Ancora in conoscenza
      expect(_container.read(onboardingProvider).faseCorrente,
          OnboardingFase.conoscenza);

      // Turno 7: il decisore forza la chiusura
      final turnForza = mock.createTurnController();
      await _sendUserMessage(tester, 'Non so');

      turnForza.add(const TextDeltaEvent(
          testo: 'Va bene, proseguiamo con quello che abbiamo!'));
      turnForza.add(const DecisioneOnboardingEvent(
        azione: 'forza_chiusura_tetto_turni',
        faseCorrente: 'placement',
        campiCompleti: 2,
      ));
      turnForza.add(const TurnoCompletoEvent(turnoId: 8));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verifica transizione a placement
      expect(find.text('Valutazione'), findsOneWidget);
      final stateAfterForce = _container.read(onboardingProvider);
      expect(stateAfterForce.faseCorrente, OnboardingFase.placement);
      expect(stateAfterForce.ultimaAzioneDecisore,
          'forza_chiusura_tetto_turni');
      expect(stateAfterForce.campiCompleti, 2);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('Integrazione — skip e ripresa', () {
    testWidgets('skip dopo primo turno preserva sessioneId',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      // Verifica utenteTempId
      expect(_container.read(onboardingProvider).utenteTempId, 'temp-1');

      // Skip via provider (per evitare GoRouter in test)
      _container.read(onboardingProvider.notifier).skipOnboarding();

      final stateSkip = _container.read(onboardingProvider);
      expect(stateSkip.isSkipped, isTrue);
      expect(stateSkip.isStreaming, isFalse);
      expect(stateSkip.isLoading, isFalse);
      expect(stateSkip.sessioneId, 'sess-1');
      expect(stateSkip.utenteTempId, 'temp-1');

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('skip senza utenteTempId imposta isSkipped', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      // Skip prima che arrivi onboarding_iniziato
      _container.read(onboardingProvider.notifier).skipOnboarding();

      final stateSkip = _container.read(onboardingProvider);
      expect(stateSkip.isSkipped, isTrue);
      expect(stateSkip.utenteTempId, isNull);
      expect(stateSkip.sessioneId, isNull);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('resume cancella skip e preserva sessioneId', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      _container.read(onboardingProvider.notifier).skipOnboarding();
      expect(_container.read(onboardingProvider).isSkipped, isTrue);

      await _container.read(onboardingProvider.notifier).resumeOnboarding();
      final stateResume = _container.read(onboardingProvider);
      expect(stateResume.isSkipped, isFalse);
      expect(stateResume.sessioneId, 'sess-1');

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('skip interrompe streaming in corso', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      // Inizia streaming (senza turno_completo)
      mock.startController.add(const OnboardingIniziatoEvent(
        sessioneId: 'sess-1',
        utenteTempId: 'temp-1',
      ));
      mock.startController
          .add(const TextDeltaEvent(testo: 'Ciao, sto parlando...'));
      await tester.pump();

      expect(_container.read(onboardingProvider).isStreaming, isTrue);

      // Skip interrompe lo streaming
      _container.read(onboardingProvider.notifier).skipOnboarding();
      final state = _container.read(onboardingProvider);
      expect(state.isSkipped, isTrue);
      expect(state.isStreaming, isFalse);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('Integrazione — gestione errori', () {
    testWidgets('errore SSE aggiorna stato con messaggio user-friendly',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      // Simula errore durante turno
      final turnErr = mock.createTurnController();
      await _sendUserMessage(tester, 'test');
      turnErr.addError('Connessione persa');
      await tester.pump();

      final errorState = _container.read(onboardingProvider);
      expect(errorState.error, isNotNull);
      expect(errorState.isStreaming, isFalse);

      // Banner errore con riprova visibile
      expect(find.text('Riprova'), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('ErroreEvent dal backend aggiorna stato errore',
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

      mock.startController.add(const ErroreEvent(
        codice: 'errore_sessione',
        messaggio: 'Sessione non trovata',
      ));
      await tester.pump();

      final state = _container.read(onboardingProvider);
      expect(state.error, isNotNull);
      expect(state.isStreaming, isFalse);
      expect(state.isLoading, isFalse);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('errore complete imposta errore ma non isCompleted',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      // Vai a conclusione
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiudi',
        faseCorrente: 'conclusione',
        campiCompleti: 5,
      ));
      await tester.pump();

      // Imposta errore per complete()
      mock.completeError = DioException(
        requestOptions: RequestOptions(path: '/onboarding/completa'),
        message: 'Errore server',
      );

      await tester.tap(find.text('Inizia il tuo percorso!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final state = _container.read(onboardingProvider);
      expect(state.isCompleted, isFalse);
      expect(state.error, isNotNull);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('Integrazione — domande strutturate nel flusso', () {
    testWidgets('domanda scelta_singola -> risposta -> turno successivo',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      // Il tutor pone una domanda strutturata
      mock.startController.add(AzioneEvent(
        tipo: 'onboarding_domanda',
        params: {
          'tipo_input': 'scelta_singola',
          'domanda': 'Cosa studi?',
          'opzioni': ['Matematica', 'Fisica', 'Chimica'],
        },
      ));
      await tester.pump();

      // La domanda è visibile, VoiceInputField nascosto
      expect(find.text('Cosa studi?'), findsOneWidget);
      expect(find.text('Matematica'), findsOneWidget);
      expect(find.byType(VoiceInputField), findsNothing);

      // L'utente risponde cliccando l'opzione
      final turnReply = mock.createTurnController();
      await tester.tap(find.text('Matematica'));
      await tester.pump();

      // Verifica che il messaggio è stato inviato
      expect(mock.sentMessages.contains('Matematica'), isTrue);

      // Il tutor risponde
      turnReply.add(const TextDeltaEvent(
          testo: 'Matematica, ottima scelta!'));
      turnReply.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo_mancante',
        campoDaChiedere: 'motivo',
        motivo: 'campo mancante',
        faseCorrente: 'conoscenza',
        campiCompleti: 1,
      ));
      turnReply.add(const TurnoCompletoEvent(turnoId: 2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // La domanda strutturata è sparita (no SceltaSingolaWidget)
      final state = _container.read(onboardingProvider);
      expect(state.currentQuestion, isNull);
      // VoiceInputField torna
      expect(find.byType(VoiceInputField), findsOneWidget);

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('domanda scala viene mostrata correttamente', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock);

      mock.startController.add(AzioneEvent(
        tipo: 'onboarding_domanda',
        params: {
          'tipo_input': 'scala',
          'domanda': 'Quanto ti senti sicuro?',
          'scala_min': 1,
          'scala_max': 5,
          'scala_labels': ['Per niente', 'Molto'],
        },
      ));
      await tester.pump();

      // Domanda visibile
      expect(find.text('Quanto ti senti sicuro?'), findsOneWidget);
      expect(find.byType(VoiceInputField), findsNothing);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('Integrazione — progresso corretto nelle transizioni', () {
    testWidgets('progresso cresce con le fasi', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      // Accoglienza: 0.0
      expect(_container.read(onboardingProvider).progress, 0.0);

      await _emitFirstTurnAndSettle(tester, mock);

      // Conoscenza con 0 campi: 0.1
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo_mancante',
        faseCorrente: 'conoscenza',
        campiCompleti: 0,
      ));
      await tester.pump();
      expect(_container.read(onboardingProvider).progress,
          closeTo(0.1, 0.001));

      // Conoscenza con 5 campi: 0.4
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiudi_narrativa',
        faseCorrente: 'conoscenza',
        campiCompleti: 5,
      ));
      await tester.pump();
      expect(_container.read(onboardingProvider).progress,
          closeTo(0.4, 0.001));

      // Placement: 0.5
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiudi_narrativa',
        faseCorrente: 'placement',
        campiCompleti: 5,
      ));
      await tester.pump();
      expect(_container.read(onboardingProvider).progress, 0.5);

      // Piano: 0.7
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'test',
        faseCorrente: 'piano',
        campiCompleti: 5,
      ));
      await tester.pump();
      expect(_container.read(onboardingProvider).progress, 0.7);

      // Conclusione: 0.9
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'test',
        faseCorrente: 'conclusione',
        campiCompleti: 5,
      ));
      await tester.pump();
      expect(_container.read(onboardingProvider).progress, 0.9);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('Integrazione — streaming e accumulazione testo', () {
    testWidgets('text_delta multipli si accumulano nello streaming',
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

      // Multipli text_delta
      mock.startController.add(const TextDeltaEvent(testo: 'Ciao '));
      mock.startController.add(const TextDeltaEvent(testo: 'Marco, '));
      mock.startController.add(const TextDeltaEvent(testo: 'benvenuto!'));
      await tester.pump();

      expect(_container.read(onboardingProvider).currentTutorText,
          'Ciao Marco, benvenuto!');

      // turno_completo finalizza
      mock.startController.add(const TurnoCompletoEvent(turnoId: 1));
      await tester.pump();

      expect(_container.read(onboardingProvider).tutorMessages,
          ['Ciao Marco, benvenuto!']);
      expect(_container.read(onboardingProvider).currentTutorText, '');

      mock.dispose();
      await _tearDown(tester);
    });

    testWidgets('turni multipli accumulano messaggi finali', (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      await _emitFirstTurnAndSettle(tester, mock, text: 'Primo turno');

      // Secondo turno
      final turn2 = mock.createTurnController();
      await _sendUserMessage(tester, 'Risposta');

      turn2.add(const TextDeltaEvent(testo: 'Secondo turno'));
      turn2.add(const TurnoCompletoEvent(turnoId: 2));
      await tester.pump();

      final state = _container.read(onboardingProvider);
      expect(state.tutorMessages.length, 2);
      expect(state.tutorMessages[0], 'Primo turno');
      expect(state.tutorMessages[1], 'Secondo turno');
      expect(state.turnsCompleted, 2);

      mock.dispose();
      await _tearDown(tester);
    });
  });

  group('Integrazione — flusso completo con tutti gli eventi', () {
    testWidgets(
        'sequenza completa: iniziato -> delta -> decisione -> turno -> delta -> completo',
        (tester) async {
      _setup(tester);
      final mock = _createMockService();
      await tester.pumpWidget(_buildTestWidget(mock));
      await tester.pump();

      // Evento iniziale
      mock.startController.add(const OnboardingIniziatoEvent(
        sessioneId: 'sess-full',
        utenteTempId: 'temp-full',
      ));
      await tester.pump();

      expect(_container.read(onboardingProvider).sessioneId, 'sess-full');
      expect(_container.read(onboardingProvider).isStreaming, isTrue);

      // Testo + decisione + turno_completo nella stessa raffica
      mock.startController.add(const TextDeltaEvent(testo: 'Benvenuto!'));
      mock.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo_mancante',
        campoDaChiedere: 'chi_e',
        motivo: 'primo turno',
        faseCorrente: 'conoscenza',
        campiCompleti: 0,
      ));
      mock.startController.add(const TurnoCompletoEvent(turnoId: 1));
      await tester.pump();

      final stateAfter = _container.read(onboardingProvider);
      expect(stateAfter.tutorMessages, ['Benvenuto!']);
      expect(stateAfter.faseCorrente, OnboardingFase.conoscenza);
      expect(stateAfter.isStreaming, isFalse);
      expect(stateAfter.turnsCompleted, 1);

      mock.dispose();
      await _tearDown(tester);
    });
  });
}
