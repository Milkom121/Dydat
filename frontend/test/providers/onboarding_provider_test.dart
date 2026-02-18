import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/providers/onboarding_provider.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/storage_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late StorageService storageService;
  late OnboardingNotifier onboardingNotifier;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    onboardingNotifier = OnboardingNotifier(
      onboardingService: OnboardingService(client: client),
      storageService: storageService,
    );
  });

  group('OnboardingNotifier', () {
    test('initial state', () {
      expect(onboardingNotifier.state.sessioneId, isNull);
      expect(onboardingNotifier.state.utenteTempId, isNull);
      expect(onboardingNotifier.state.messages, isEmpty);
      expect(onboardingNotifier.state.isCompleted, false);
    });

    test('setIds stores sessioneId and utenteTempId', () async {
      onboardingNotifier.setIds(
        sessioneId: 'session-1',
        utenteTempId: 'temp-uuid',
      );

      expect(onboardingNotifier.state.sessioneId, 'session-1');
      expect(onboardingNotifier.state.utenteTempId, 'temp-uuid');
      expect(await storageService.getUtenteTempId(), 'temp-uuid');
    });

    test('addTutorMessage appends to messages', () {
      onboardingNotifier.addTutorMessage('Ciao!');
      onboardingNotifier.addTutorMessage('Come stai?');

      expect(onboardingNotifier.state.messages, ['Ciao!', 'Come stai?']);
    });

    test('sendMessage calls API and clears loading', () async {
      onboardingNotifier.setIds(
        sessioneId: 'session-1',
        utenteTempId: 'temp-uuid',
      );

      dioAdapter.onPost(
        '/onboarding/turno',
        (server) => server.reply(200, ''),
        data: Matchers.any,
      );

      await onboardingNotifier.sendMessage('Voglio ripassare le derivate');

      expect(onboardingNotifier.state.isLoading, false);
      expect(onboardingNotifier.state.error, isNull);
    });

    test('sendMessage without sessioneId does nothing', () async {
      await onboardingNotifier.sendMessage('test');
      expect(onboardingNotifier.state.isLoading, false);
    });

    test('complete sets isCompleted and result', () async {
      onboardingNotifier.setIds(
        sessioneId: 'session-1',
        utenteTempId: 'temp-uuid',
      );

      dioAdapter.onPost(
        '/onboarding/completa',
        (server) => server.reply(200, {
          'percorso_id': 1,
          'nodo_iniziale': 'derivata_definizione',
          'nodi_inizializzati': 42,
        }),
        data: Matchers.any,
      );

      await onboardingNotifier.complete(
        contestoPersonale: {'obiettivo': 'esame'},
      );

      expect(onboardingNotifier.state.isCompleted, true);
      expect(onboardingNotifier.state.result?.percorsoId, 1);
      expect(
        onboardingNotifier.state.result?.nodoIniziale,
        'derivata_definizione',
      );
    });

    test('complete on error sets error', () async {
      onboardingNotifier.setIds(
        sessioneId: 'session-1',
        utenteTempId: 'temp-uuid',
      );

      dioAdapter.onPost(
        '/onboarding/completa',
        (server) =>
            server.reply(404, {'detail': 'Sessione non trovata'}),
        data: Matchers.any,
      );

      await onboardingNotifier.complete();

      expect(onboardingNotifier.state.isCompleted, false);
      expect(onboardingNotifier.state.error, 'Sessione non trovata');
    });

    test('clear resets state', () {
      onboardingNotifier.setIds(
        sessioneId: 'session-1',
        utenteTempId: 'temp-uuid',
      );
      onboardingNotifier.addTutorMessage('Hello');

      onboardingNotifier.clear();

      expect(onboardingNotifier.state.sessioneId, isNull);
      expect(onboardingNotifier.state.messages, isEmpty);
    });
  });
}
