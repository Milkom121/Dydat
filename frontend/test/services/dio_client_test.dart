import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) _store[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store.remove(key);

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store.clear();
}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late StorageService storageService;
  late DioClient client;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    storageService = StorageService(storage: FakeSecureStorage());
    client = DioClient(storageService: storageService, dio: dio);
  });

  group('DioClient', () {
    test('adds Authorization header when token exists', () async {
      await storageService.saveAccessToken('jwt-token-123');

      dioAdapter.onGet(
        '/health',
        (server) => server.reply(200, {'status': 'ok'}),
      );

      final response = await client.dio.get('/health');
      expect(response.statusCode, 200);
    });

    test('does not add Authorization header when no token', () async {
      dioAdapter.onGet(
        '/health',
        (server) => server.reply(200, {'status': 'ok'}),
      );

      final response = await client.dio.get('/health');
      expect(response.statusCode, 200);
    });

    test('transforms error response with detail field to ApiException',
        () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(401, {'detail': 'Credenziali non valide'}),
        data: Matchers.any,
      );

      try {
        await client.dio.post('/auth/login', data: {});
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiException>());
        final apiError = e.error as ApiException;
        expect(apiError.statusCode, 401);
        expect(apiError.message, 'Credenziali non valide');
      }
    });

    test('transforms 409 conflict error correctly', () async {
      dioAdapter.onPost(
        '/auth/registrazione',
        (server) => server.reply(409, {'detail': "Email gia' registrata"}),
        data: Matchers.any,
      );

      try {
        await client.dio.post('/auth/registrazione', data: {});
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiException>());
        final apiError = e.error as ApiException;
        expect(apiError.statusCode, 409);
        expect(apiError.message, "Email gia' registrata");
      }
    });
  });
}
