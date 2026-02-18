import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/services/auth_service.dart';
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
  late AuthService authService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    authService = AuthService(client: client);
  });

  group('AuthService', () {
    test('login returns LoginResponse on success', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, {
          'access_token': 'jwt-abc',
          'token_type': 'bearer',
        }),
        data: Matchers.any,
      );

      final response = await authService.login(
        email: 'test@test.com',
        password: 'password123',
      );
      expect(response.accessToken, 'jwt-abc');
      expect(response.tokenType, 'bearer');
    });

    test('register returns LoginResponse on success', () async {
      dioAdapter.onPost(
        '/auth/registrazione',
        (server) => server.reply(201, {
          'access_token': 'jwt-def',
          'token_type': 'bearer',
        }),
        data: Matchers.any,
      );

      final response = await authService.register(
        email: 'new@test.com',
        password: 'password123',
        nome: 'Mario',
      );
      expect(response.accessToken, 'jwt-def');
      expect(response.tokenType, 'bearer');
    });

    test('register with utenteTempId includes it in request', () async {
      dioAdapter.onPost(
        '/auth/registrazione',
        (server) => server.reply(201, {
          'access_token': 'jwt-ghi',
          'token_type': 'bearer',
        }),
        data: Matchers.any,
      );

      final response = await authService.register(
        email: 'new@test.com',
        password: 'password123',
        nome: 'Mario',
        utenteTempId: 'uuid-temp-123',
      );
      expect(response.accessToken, 'jwt-ghi');
    });

    test('login throws DioException on 401', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(401, {'detail': 'Credenziali non valide'}),
        data: Matchers.any,
      );

      expect(
        () => authService.login(email: 'bad@test.com', password: 'wrong'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
