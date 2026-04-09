import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/onboarding.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/providers/onboarding_provider.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/sse_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/presentation/onboarding_screen/onboarding_screen.dart';

import '../helpers/fake_secure_storage.dart';

// ===================================================================
// Mock OnboardingService con controllo stream + resume
// ===================================================================

class _MockOnboardingService extends OnboardingService {
  StreamController<SseEvent>? _startController;
  final List<StreamController<SseEvent>> _turnControllers = [];
  int _turnIndex = 0;
  final List<String> sentMessages = [];

  OnboardingRipresaResponse? resumeResponse;
  DioException? resumeError;

  OnboardingCompletaResponse? completeResponse;

  _MockOnboardingService({
    required super.client,
    required super.sseClient,
  });

  StreamController<SseEvent> get startController {
    _startController ??= StreamController<SseEvent>();
    return _startController!;
  }

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
    return const Stream.empty();
  }

  @override
  Future<OnboardingRipresaResponse> getResumeState({
    required String utenteId,
  }) async {
    if (resumeError != null) throw resumeError!;
    return resumeResponse!;
  }

  @override
  Future<OnboardingCompletaResponse> complete({
    required String sessioneId,
    Map<String, dynamic>? contestoPersonale,
    Map<String, dynamic>? preferenzeTutor,
  }) async {
    return completeResponse ??
        const OnboardingCompletaResponse(
          percorsoId: 1,
          nodoIniziale: 'nodo_test',
          nodiInizializzati: 10,
        );
  }

  void dispose() {
    _startController?.close();
    for (final c in _turnControllers) {
      c.close();
    }
  }
}

// ===================================================================
// Test
// ===================================================================

void main() {
  late StorageService storageService;
  late _MockOnboardingService mockService;

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    final sseClient = SseClient(storageService: storageService);
    mockService = _MockOnboardingService(
      client: client,
      sseClient: sseClient,
    );
  });

  tearDown(() {
    mockService.dispose();
  });

  group('Modello OnboardingRipresaResponse', () {
    test('fromJson deserializza correttamente', () {
      final json = {
        'sessione_id': 'abc-123',
        'fase_corrente': 'conoscenza',
        'campi_completi': 2,
        'turni': [
          {'ruolo': 'assistant', 'contenuto': 'Ciao!'},
          {'ruolo': 'user', 'contenuto': 'Ciao'},
        ],
      };

      final resp = OnboardingRipresaResponse.fromJson(json);
      expect(resp.sessioneId, 'abc-123');
      expect(resp.faseCorrente, 'conoscenza');
      expect(resp.campiCompleti, 2);
      expect(resp.turni.length, 2);
      expect(resp.turni[0].ruolo, 'assistant');
      expect(resp.turni[0].contenuto, 'Ciao!');
    });

    test('fromJson con turni vuoti', () {
      final json = {
        'sessione_id': 'abc',
        'fase_corrente': 'accoglienza',
        'campi_completi': 0,
        'turni': [],
      };

      final resp = OnboardingRipresaResponse.fromJson(json);
      expect(resp.turni, isEmpty);
    });

    test('toJson roundtrip', () {
      final original = OnboardingRipresaResponse(
        sessioneId: 'xyz',
        faseCorrente: 'placement',
        campiCompleti: 4,
        turni: [
          const TurnoRipresa(ruolo: 'assistant', contenuto: 'Test'),
        ],
      );

      final json = original.toJson();
      final restored = OnboardingRipresaResponse.fromJson(json);
      expect(restored.sessioneId, original.sessioneId);
      expect(restored.faseCorrente, original.faseCorrente);
      expect(restored.campiCompleti, original.campiCompleti);
      expect(restored.turni.length, 1);
    });

    test('TurnoRipresa contenuto nullo', () {
      final json = {'ruolo': 'assistant', 'contenuto': null};
      final turno = TurnoRipresa.fromJson(json);
      expect(turno.contenuto, isNull);
    });
  });

  group('OnboardingNotifier.resumeOnboarding', () {
    test('ripresa con sessione attiva carica conversazione', () async {
      // Pre-salva utenteTempId nello storage
      await storageService.saveUtenteTempId('utente-temp-123');

      mockService.resumeResponse = const OnboardingRipresaResponse(
        sessioneId: 'sessione-ripresa',
        faseCorrente: 'conoscenza',
        campiCompleti: 2,
        turni: [
          TurnoRipresa(ruolo: 'assistant', contenuto: 'Ciao!'),
          TurnoRipresa(ruolo: 'user', contenuto: 'Ciao'),
          TurnoRipresa(ruolo: 'assistant', contenuto: 'Come stai?'),
        ],
      );

      final notifier = OnboardingNotifier(
        onboardingService: mockService,
        storageService: storageService,
      );

      await notifier.resumeOnboarding();

      expect(notifier.state.sessioneId, 'sessione-ripresa');
      expect(notifier.state.utenteTempId, 'utente-temp-123');
      expect(notifier.state.faseCorrente, OnboardingFase.conoscenza);
      expect(notifier.state.campiCompleti, 2);
      expect(notifier.state.tutorMessages.length, 2); // 2 messaggi assistant
      expect(notifier.state.tutorMessages[0], 'Ciao!');
      expect(notifier.state.tutorMessages[1], 'Come stai?');
      expect(notifier.state.turnsCompleted, 2); // 2 turni assistant
      expect(notifier.state.isLoading, false);
      expect(notifier.state.isSkipped, false);
      // resumedConversation esposta per lo screen
      expect(notifier.state.resumedConversation, isNotNull);
      expect(notifier.state.resumedConversation!.length, 3);
    });

    test('senza utenteTempId ricomincia da capo', () async {
      // Storage vuoto, nessun utenteTempId
      final notifier = OnboardingNotifier(
        onboardingService: mockService,
        storageService: storageService,
      );

      await notifier.resumeOnboarding();

      // startOnboarding viene chiamato → isLoading true (stream non emette)
      expect(notifier.state.isLoading, true);
      expect(notifier.state.sessioneId, isNull);
    });

    test('404 dal backend ricomincia da capo', () async {
      await storageService.saveUtenteTempId('utente-fantasma');

      mockService.resumeError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      final notifier = OnboardingNotifier(
        onboardingService: mockService,
        storageService: storageService,
      );

      await notifier.resumeOnboarding();

      // Fallback a startOnboarding → isLoading true
      expect(notifier.state.isLoading, true);
    });

    test('errore generico mostra messaggio', () async {
      await storageService.saveUtenteTempId('utente-123');

      mockService.resumeError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      final notifier = OnboardingNotifier(
        onboardingService: mockService,
        storageService: storageService,
      );

      await notifier.resumeOnboarding();

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.isLoading, false);
    });

    test('resume persiste sessioneId nello storage', () async {
      await storageService.saveUtenteTempId('utente-123');

      mockService.resumeResponse = const OnboardingRipresaResponse(
        sessioneId: 'sessione-persistita',
        faseCorrente: 'accoglienza',
        campiCompleti: 0,
        turni: [],
      );

      final notifier = OnboardingNotifier(
        onboardingService: mockService,
        storageService: storageService,
      );

      await notifier.resumeOnboarding();

      final savedId = await storageService.getOnboardingSessioneId();
      expect(savedId, 'sessione-persistita');
    });

    test('dopo resume invia messaggi con sessioneId corretto', () async {
      await storageService.saveUtenteTempId('utente-123');

      mockService.resumeResponse = const OnboardingRipresaResponse(
        sessioneId: 'sessione-abc',
        faseCorrente: 'conoscenza',
        campiCompleti: 1,
        turni: [
          TurnoRipresa(ruolo: 'assistant', contenuto: 'Ciao!'),
        ],
      );

      final notifier = OnboardingNotifier(
        onboardingService: mockService,
        storageService: storageService,
      );

      await notifier.resumeOnboarding();
      expect(notifier.state.sessioneId, 'sessione-abc');

      // Crea un controller per il prossimo turno
      mockService.createTurnController();
      await notifier.sendMessage('Continuo la conversazione');

      expect(mockService.sentMessages, contains('Continuo la conversazione'));
    });
  });

  group('OnboardingScreen parametro resume', () {
    test('OnboardingScreen accetta resume=true', () {
      // Verifica che il widget accetti il parametro senza errori
      const screen = OnboardingScreen(resume: true);
      expect(screen.resume, true);
    });

    test('OnboardingScreen default resume=false', () {
      const screen = OnboardingScreen();
      expect(screen.resume, false);
    });
  });

  group('StorageService sessione_id', () {
    test('salva e recupera onboarding sessione_id', () async {
      final storage = StorageService(storage: FakeSecureStorage());

      expect(await storage.getOnboardingSessioneId(), isNull);

      await storage.saveOnboardingSessioneId('test-sessione-id');
      expect(await storage.getOnboardingSessioneId(), 'test-sessione-id');

      await storage.deleteOnboardingSessioneId();
      expect(await storage.getOnboardingSessioneId(), isNull);
    });
  });
}
