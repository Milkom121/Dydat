import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/sse_client.dart';
import 'package:dydat/services/storage_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late OnboardingService onboardingService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    final sseClient = SseClient(storageService: storageService);
    onboardingService = OnboardingService(
      client: client,
      sseClient: sseClient,
    );
  });

  group('OnboardingService', () {
    test('startStream returns a Stream', () {
      final stream = onboardingService.startStream();
      expect(stream, isA<Stream>());
    });

    test('sendTurnStream returns a Stream', () {
      final stream = onboardingService.sendTurnStream(
        sessioneId: 'session-uuid',
        messaggio: 'Ciao tutor',
      );
      expect(stream, isA<Stream>());
    });

    test('complete returns OnboardingCompletaResponse', () async {
      dioAdapter.onPost(
        '/onboarding/completa',
        (server) => server.reply(200, {
          'percorso_id': 1,
          'nodo_iniziale': 'derivata_definizione',
          'nodi_inizializzati': 42,
        }),
        data: Matchers.any,
      );

      final response = await onboardingService.complete(
        sessioneId: 'session-uuid',
        contestoPersonale: {'obiettivo': 'esame'},
        preferenzeTutor: {'velocita': 'normale'},
      );
      expect(response.percorsoId, 1);
      expect(response.nodoIniziale, 'derivata_definizione');
      expect(response.nodiInizializzati, 42);
    });

    test('complete with null optional fields', () async {
      dioAdapter.onPost(
        '/onboarding/completa',
        (server) => server.reply(200, {
          'percorso_id': 2,
          'nodo_iniziale': null,
          'nodi_inizializzati': 30,
        }),
        data: Matchers.any,
      );

      final response = await onboardingService.complete(
        sessioneId: 'session-uuid',
      );
      expect(response.percorsoId, 2);
      expect(response.nodoIniziale, isNull);
    });
  });
}
