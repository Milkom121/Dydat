import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/services/onboarding_service.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _store = {};
  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async => _store[key];
  @override
  Future<void> write({required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async { if (value != null) _store[key] = value; }
  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async => _store.remove(key);
  @override
  Future<void> deleteAll({IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async => _store.clear();
}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late OnboardingService onboardingService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    onboardingService = OnboardingService(client: client);
  });

  group('OnboardingService', () {
    test('start makes POST to /onboarding/inizia', () async {
      dioAdapter.onPost(
        '/onboarding/inizia',
        (server) => server.reply(200, ''),
      );

      await onboardingService.start();
    });

    test('sendTurn makes POST to /onboarding/turno', () async {
      dioAdapter.onPost(
        '/onboarding/turno',
        (server) => server.reply(200, ''),
        data: Matchers.any,
      );

      await onboardingService.sendTurn(
        sessioneId: 'session-uuid',
        messaggio: 'Ciao tutor',
      );
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
