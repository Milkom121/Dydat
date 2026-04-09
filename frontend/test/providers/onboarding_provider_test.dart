import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/providers/onboarding_provider.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/sse_client.dart';
import 'package:dydat/services/storage_service.dart';
import '../helpers/fake_secure_storage.dart';

/// OnboardingService mock che restituisce stream controllati.
class MockOnboardingService extends OnboardingService {
  StreamController<SseEvent>? _startController;
  StreamController<SseEvent>? _turnController;

  MockOnboardingService({
    required super.client,
    required super.sseClient,
  });

  /// Stream per startOnboarding.
  StreamController<SseEvent> get startController {
    _startController ??= StreamController<SseEvent>();
    return _startController!;
  }

  /// Stream per sendMessage.
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

void main() {
  late StorageService storageService;
  late OnboardingNotifier onboardingNotifier;

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    final sseClient = SseClient(storageService: storageService);
    onboardingNotifier = OnboardingNotifier(
      onboardingService: OnboardingService(
        client: client,
        sseClient: sseClient,
      ),
      storageService: storageService,
    );
  });

  group('OnboardingScreenState', () {
    test('initial state has correct defaults', () {
      expect(onboardingNotifier.state.sessioneId, isNull);
      expect(onboardingNotifier.state.utenteTempId, isNull);
      expect(onboardingNotifier.state.tutorMessages, isEmpty);
      expect(onboardingNotifier.state.isCompleted, false);
      expect(onboardingNotifier.state.isStreaming, false);
      expect(onboardingNotifier.state.currentTutorText, '');
      expect(onboardingNotifier.state.turnsCompleted, 0);
      expect(onboardingNotifier.state.faseCorrente, OnboardingFase.accoglienza);
      expect(onboardingNotifier.state.campiCompleti, 0);
      expect(onboardingNotifier.state.isSkipped, false);
      expect(onboardingNotifier.state.ultimaAzioneDecisore, isNull);
    });

    test('sendMessage without sessioneId does nothing', () async {
      await onboardingNotifier.sendMessage('test');
      expect(onboardingNotifier.state.isStreaming, false);
    });

    test('completeOnboarding without sessioneId does nothing', () async {
      await onboardingNotifier.completeOnboarding(
        contestoPersonale: {'obiettivo': 'esame'},
      );
      expect(onboardingNotifier.state.isCompleted, false);
    });

    test('copyWith preserves defaults', () {
      const state = OnboardingScreenState();
      final newState = state.copyWith(sessioneId: 'abc');

      expect(newState.sessioneId, 'abc');
      expect(newState.utenteTempId, isNull);
      expect(newState.tutorMessages, isEmpty);
      expect(newState.isStreaming, false);
      expect(newState.turnsCompleted, 0);
      expect(newState.faseCorrente, OnboardingFase.accoglienza);
      expect(newState.campiCompleti, 0);
      expect(newState.isSkipped, false);
    });

    test('copyWith clearError works', () {
      final state = const OnboardingScreenState(error: 'some error');
      final newState = state.copyWith(clearError: true);
      expect(newState.error, isNull);
    });

    test('copyWith with new fields', () {
      const state = OnboardingScreenState();
      final updated = state.copyWith(
        faseCorrente: OnboardingFase.conoscenza,
        campiCompleti: 3,
        isSkipped: true,
        ultimaAzioneDecisore: 'chiedi_campo_mancante',
      );
      expect(updated.faseCorrente, OnboardingFase.conoscenza);
      expect(updated.campiCompleti, 3);
      expect(updated.isSkipped, true);
      expect(updated.ultimaAzioneDecisore, 'chiedi_campo_mancante');
    });

    test('copyWith clearUltimaAzione works', () {
      final state = const OnboardingScreenState(
        ultimaAzioneDecisore: 'chiudi_narrativa',
      );
      final cleared = state.copyWith(clearUltimaAzione: true);
      expect(cleared.ultimaAzioneDecisore, isNull);
    });

    test('copyWith preserves faseCorrente when not specified', () {
      final state = const OnboardingScreenState(
        faseCorrente: OnboardingFase.placement,
      );
      final updated = state.copyWith(isStreaming: true);
      expect(updated.faseCorrente, OnboardingFase.placement);
    });

    test('clear resets state including new fields', () {
      onboardingNotifier.clear();

      expect(onboardingNotifier.state.sessioneId, isNull);
      expect(onboardingNotifier.state.tutorMessages, isEmpty);
      expect(onboardingNotifier.state.currentTutorText, '');
      expect(onboardingNotifier.state.turnsCompleted, 0);
      expect(onboardingNotifier.state.currentQuestion, isNull);
      expect(onboardingNotifier.state.faseCorrente, OnboardingFase.accoglienza);
      expect(onboardingNotifier.state.campiCompleti, 0);
      expect(onboardingNotifier.state.isSkipped, false);
      expect(onboardingNotifier.state.ultimaAzioneDecisore, isNull);
    });
  });

  group('OnboardingFase', () {
    test('onboardingFaseFromString parses valid values', () {
      expect(onboardingFaseFromString('accoglienza'), OnboardingFase.accoglienza);
      expect(onboardingFaseFromString('conoscenza'), OnboardingFase.conoscenza);
      expect(onboardingFaseFromString('placement'), OnboardingFase.placement);
      expect(onboardingFaseFromString('piano'), OnboardingFase.piano);
      expect(onboardingFaseFromString('conclusione'), OnboardingFase.conclusione);
    });

    test('onboardingFaseFromString fallback on unknown value', () {
      expect(onboardingFaseFromString('unknown'), OnboardingFase.accoglienza);
      expect(onboardingFaseFromString(''), OnboardingFase.accoglienza);
    });
  });

  group('progress', () {
    test('accoglienza progress is 0.0', () {
      const state = OnboardingScreenState(
        faseCorrente: OnboardingFase.accoglienza,
      );
      expect(state.progress, 0.0);
    });

    test('conoscenza progress scales with campiCompleti', () {
      const state0 = OnboardingScreenState(
        faseCorrente: OnboardingFase.conoscenza,
        campiCompleti: 0,
      );
      expect(state0.progress, closeTo(0.1, 0.001));

      const state3 = OnboardingScreenState(
        faseCorrente: OnboardingFase.conoscenza,
        campiCompleti: 3,
      );
      expect(state3.progress, closeTo(0.28, 0.001));

      const state5 = OnboardingScreenState(
        faseCorrente: OnboardingFase.conoscenza,
        campiCompleti: 5,
      );
      expect(state5.progress, closeTo(0.4, 0.001));
    });

    test('placement progress is 0.5', () {
      const state = OnboardingScreenState(
        faseCorrente: OnboardingFase.placement,
      );
      expect(state.progress, 0.5);
    });

    test('piano progress is 0.7', () {
      const state = OnboardingScreenState(
        faseCorrente: OnboardingFase.piano,
      );
      expect(state.progress, 0.7);
    });

    test('conclusione progress is 0.9', () {
      const state = OnboardingScreenState(
        faseCorrente: OnboardingFase.conclusione,
      );
      expect(state.progress, 0.9);
    });

    test('isCompleted overrides progress to 1.0', () {
      const state = OnboardingScreenState(
        faseCorrente: OnboardingFase.conoscenza,
        campiCompleti: 2,
        isCompleted: true,
      );
      expect(state.progress, 1.0);
    });
  });

  group('skipOnboarding', () {
    test('sets isSkipped and stops streaming', () {
      onboardingNotifier.skipOnboarding();

      expect(onboardingNotifier.state.isSkipped, true);
      expect(onboardingNotifier.state.isLoading, false);
      expect(onboardingNotifier.state.isStreaming, false);
    });
  });

  group('resumeOnboarding', () {
    test('without sessioneId starts fresh onboarding', () async {
      // Senza sessioneId, resumeOnboarding chiama startOnboarding
      await onboardingNotifier.resumeOnboarding();
      // Verifichiamo che isSkipped sia false
      expect(onboardingNotifier.state.isSkipped, false);
    });
  });

  group('currentQuestion', () {
    test('starts null', () {
      expect(onboardingNotifier.state.currentQuestion, isNull);
    });

    test('copyWith with currentQuestion', () {
      final question = OnboardingDomandaAction(
        tipoInput: 'scelta_singola',
        domanda: 'Chi sei?',
        opzioni: ['Studente', 'Autodidatta'],
      );
      final state = const OnboardingScreenState().copyWith(
        currentQuestion: question,
      );
      expect(state.currentQuestion, isNotNull);
      expect(state.currentQuestion!.tipoInput, 'scelta_singola');
      expect(state.currentQuestion!.domanda, 'Chi sei?');
      expect(state.currentQuestion!.opzioni, ['Studente', 'Autodidatta']);
    });

    test('copyWith clearQuestion removes currentQuestion', () {
      final question = OnboardingDomandaAction(
        tipoInput: 'testo_libero',
        domanda: 'Cosa vuoi?',
      );
      final state = const OnboardingScreenState().copyWith(
        currentQuestion: question,
      );
      expect(state.currentQuestion, isNotNull);

      final cleared = state.copyWith(clearQuestion: true);
      expect(cleared.currentQuestion, isNull);
    });

    test('copyWith preserves currentQuestion when not clearing', () {
      final question = OnboardingDomandaAction(
        tipoInput: 'scala',
        domanda: 'Livello?',
        scalaMin: 1,
        scalaMax: 5,
      );
      final state = const OnboardingScreenState().copyWith(
        currentQuestion: question,
      );
      final updated = state.copyWith(isStreaming: true);
      expect(updated.currentQuestion, isNotNull);
      expect(updated.currentQuestion!.tipoInput, 'scala');
    });
  });

  group('DecisioneOnboardingEvent', () {
    test('fromJson parses correctly', () {
      final event = DecisioneOnboardingEvent.fromJson({
        'azione': 'chiedi_campo_mancante',
        'campo_da_chiedere': 'motivo',
        'motivo': 'campo mancante',
        'fase_corrente': 'conoscenza',
        'campi_completi': 3,
      });
      expect(event.azione, 'chiedi_campo_mancante');
      expect(event.campoDaChiedere, 'motivo');
      expect(event.motivo, 'campo mancante');
      expect(event.faseCorrente, 'conoscenza');
      expect(event.campiCompleti, 3);
    });

    test('fromJson with null optional fields', () {
      final event = DecisioneOnboardingEvent.fromJson({
        'azione': 'chiudi_narrativa',
        'campo_da_chiedere': null,
        'motivo': null,
        'fase_corrente': 'placement',
        'campi_completi': 5,
      });
      expect(event.azione, 'chiudi_narrativa');
      expect(event.campoDaChiedere, isNull);
      expect(event.motivo, isNull);
      expect(event.faseCorrente, 'placement');
    });

    test('fromJson defaults campiCompleti to 0 when missing', () {
      final event = DecisioneOnboardingEvent.fromJson({
        'azione': 'chiudi_narrativa',
        'fase_corrente': 'conoscenza',
      });
      expect(event.campiCompleti, 0);
    });

    test('parsed via SseEvent.fromRawEvent', () {
      final event = SseEvent.fromRawEvent(
        'decisione_onboarding',
        '{"azione":"chiedi_campo_mancante","campo_da_chiedere":"chi_e","motivo":"test","fase_corrente":"conoscenza","campi_completi":2}',
      );
      expect(event, isA<DecisioneOnboardingEvent>());
      final decisione = event as DecisioneOnboardingEvent;
      expect(decisione.azione, 'chiedi_campo_mancante');
      expect(decisione.campoDaChiedere, 'chi_e');
      expect(decisione.campiCompleti, 2);
    });
  });

  group('OnboardingFase enum', () {
    test('all 5 phases exist', () {
      expect(OnboardingFase.values.length, 5);
      expect(OnboardingFase.values, contains(OnboardingFase.accoglienza));
      expect(OnboardingFase.values, contains(OnboardingFase.conoscenza));
      expect(OnboardingFase.values, contains(OnboardingFase.placement));
      expect(OnboardingFase.values, contains(OnboardingFase.piano));
      expect(OnboardingFase.values, contains(OnboardingFase.conclusione));
    });
  });

  group('SSE event handling (mock service)', () {
    late MockOnboardingService mockService;
    late OnboardingNotifier notifier;

    setUp(() {
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      final storage = StorageService(storage: FakeSecureStorage());
      final client = DioClient(storageService: storage, dio: dio);
      final sseClient = SseClient(storageService: storage);
      mockService = MockOnboardingService(
        client: client,
        sseClient: sseClient,
      );
      notifier = OnboardingNotifier(
        onboardingService: mockService,
        storageService: storage,
      );
    });

    tearDown(() {
      notifier.dispose();
      mockService.dispose();
    });

    test('startOnboarding resets phase to accoglienza', () async {
      await notifier.startOnboarding();
      expect(notifier.state.faseCorrente, OnboardingFase.accoglienza);
      expect(notifier.state.campiCompleti, 0);
      expect(notifier.state.isSkipped, false);
      expect(notifier.state.ultimaAzioneDecisore, isNull);
    });

    test('OnboardingIniziatoEvent sets sessioneId', () async {
      await notifier.startOnboarding();
      mockService.startController.add(const OnboardingIniziatoEvent(
        utenteTempId: 'temp-123',
        sessioneId: 'sess-456',
      ));
      await Future.delayed(Duration.zero);

      expect(notifier.state.sessioneId, 'sess-456');
      expect(notifier.state.utenteTempId, 'temp-123');
      expect(notifier.state.isStreaming, true);
    });

    test('DecisioneOnboardingEvent updates fase and campiCompleti', () async {
      await notifier.startOnboarding();
      // Simula evento iniziale
      mockService.startController.add(const OnboardingIniziatoEvent(
        utenteTempId: 'temp-1',
        sessioneId: 'sess-1',
      ));
      await Future.delayed(Duration.zero);

      // Simula decisione
      mockService.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiedi_campo_mancante',
        campoDaChiedere: 'motivo',
        motivo: 'mancante',
        faseCorrente: 'conoscenza',
        campiCompleti: 3,
      ));
      await Future.delayed(Duration.zero);

      expect(notifier.state.faseCorrente, OnboardingFase.conoscenza);
      expect(notifier.state.campiCompleti, 3);
      expect(notifier.state.ultimaAzioneDecisore, 'chiedi_campo_mancante');
    });

    test('DecisioneOnboardingEvent chiudi_narrativa transitions to placement', () async {
      await notifier.startOnboarding();
      mockService.startController.add(const OnboardingIniziatoEvent(
        utenteTempId: 'temp-1',
        sessioneId: 'sess-1',
      ));
      await Future.delayed(Duration.zero);

      mockService.startController.add(const DecisioneOnboardingEvent(
        azione: 'chiudi_narrativa',
        faseCorrente: 'placement',
        campiCompleti: 5,
      ));
      await Future.delayed(Duration.zero);

      expect(notifier.state.faseCorrente, OnboardingFase.placement);
      expect(notifier.state.campiCompleti, 5);
      expect(notifier.state.ultimaAzioneDecisore, 'chiudi_narrativa');
    });

    test('skip preserves sessioneId from stream', () async {
      await notifier.startOnboarding();
      mockService.startController.add(const OnboardingIniziatoEvent(
        utenteTempId: 'temp-1',
        sessioneId: 'sess-skip',
      ));
      await Future.delayed(Duration.zero);

      notifier.skipOnboarding();

      expect(notifier.state.isSkipped, true);
      expect(notifier.state.sessioneId, 'sess-skip');
    });

    test('resume with existing sessioneId clears skip', () async {
      await notifier.startOnboarding();
      mockService.startController.add(const OnboardingIniziatoEvent(
        utenteTempId: 'temp-1',
        sessioneId: 'sess-resume',
      ));
      await Future.delayed(Duration.zero);

      notifier.skipOnboarding();
      expect(notifier.state.isSkipped, true);

      await notifier.resumeOnboarding();
      expect(notifier.state.isSkipped, false);
      expect(notifier.state.sessioneId, 'sess-resume');
    });

    test('text delta and turno completo still work with new state', () async {
      await notifier.startOnboarding();
      mockService.startController.add(const OnboardingIniziatoEvent(
        utenteTempId: 'temp-1',
        sessioneId: 'sess-1',
      ));
      await Future.delayed(Duration.zero);

      mockService.startController.add(const TextDeltaEvent(testo: 'Ciao '));
      mockService.startController.add(const TextDeltaEvent(testo: 'studente!'));
      await Future.delayed(Duration.zero);

      expect(notifier.state.currentTutorText, 'Ciao studente!');

      mockService.startController.add(const TurnoCompletoEvent(turnoId: 1));
      await Future.delayed(Duration.zero);

      expect(notifier.state.tutorMessages, ['Ciao studente!']);
      expect(notifier.state.currentTutorText, '');
      expect(notifier.state.turnsCompleted, 1);
    });

    test('error event updates state', () async {
      await notifier.startOnboarding();
      mockService.startController.add(const ErroreEvent(
        codice: 'errore_generico',
        messaggio: 'Qualcosa è andato storto',
      ));
      await Future.delayed(Duration.zero);

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.isStreaming, false);
    });

    test('forza_chiusura_tetto_turni transitions to placement', () async {
      await notifier.startOnboarding();
      mockService.startController.add(const OnboardingIniziatoEvent(
        utenteTempId: 'temp-1',
        sessioneId: 'sess-1',
      ));
      await Future.delayed(Duration.zero);

      mockService.startController.add(const DecisioneOnboardingEvent(
        azione: 'forza_chiusura_tetto_turni',
        faseCorrente: 'placement',
        campiCompleti: 2,
      ));
      await Future.delayed(Duration.zero);

      expect(notifier.state.faseCorrente, OnboardingFase.placement);
      expect(notifier.state.ultimaAzioneDecisore, 'forza_chiusura_tetto_turni');
    });
  });
}

