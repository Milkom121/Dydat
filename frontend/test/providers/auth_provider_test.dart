import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/providers/auth_provider.dart';
import 'package:dydat/services/auth_service.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/services/user_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late StorageService storageService;
  late AuthNotifier authNotifier;

  final userJson = {
    'id': 'uuid-123',
    'email': 'mario@test.com',
    'nome': 'Mario',
    'preferenze_tutor': null,
    'contesto_personale': null,
    'materie_attive': ['matematica'],
    'obiettivo_giornaliero_min': 20,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    authNotifier = AuthNotifier(
      authService: AuthService(client: client),
      userService: UserService(client: client),
      storageService: storageService,
    );
  });

  group('AuthNotifier', () {
    test('initial state is unauthenticated', () {
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.user, isNull);
      expect(authNotifier.state.isLoading, false);
    });

    test('login sets token and loads user', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, {
          'access_token': 'jwt-token',
          'token_type': 'bearer',
        }),
        data: Matchers.any,
      );
      dioAdapter.onGet(
        '/utente/me',
        (server) => server.reply(200, userJson),
      );

      await authNotifier.login(email: 'mario@test.com', password: 'pass');

      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.token, 'jwt-token');
      expect(authNotifier.state.user?.nome, 'Mario');
      expect(authNotifier.state.isLoading, false);
    });

    test('login with invalid credentials sets error', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(401, {'detail': 'Credenziali non valide'}),
        data: Matchers.any,
      );

      await authNotifier.login(email: 'bad@test.com', password: 'wrong');

      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.error, 'Credenziali non valide');
      expect(authNotifier.state.isLoading, false);
    });

    test('register sets token and loads user', () async {
      dioAdapter.onPost(
        '/auth/registrazione',
        (server) => server.reply(201, {
          'access_token': 'jwt-new',
          'token_type': 'bearer',
        }),
        data: Matchers.any,
      );
      dioAdapter.onGet(
        '/utente/me',
        (server) => server.reply(200, userJson),
      );

      await authNotifier.register(
        email: 'new@test.com',
        password: 'pass123',
        nome: 'Mario',
      );

      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.token, 'jwt-new');
      expect(authNotifier.state.user?.email, 'mario@test.com');
    });

    test('checkAuth with stored token loads user', () async {
      await storageService.saveAccessToken('stored-token');
      dioAdapter.onGet(
        '/utente/me',
        (server) => server.reply(200, userJson),
      );

      await authNotifier.checkAuth();

      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.user?.nome, 'Mario');
    });

    test('checkAuth without token stays unauthenticated', () async {
      await authNotifier.checkAuth();
      expect(authNotifier.state.isAuthenticated, false);
    });

    test('checkAuth with expired token clears state', () async {
      await storageService.saveAccessToken('expired-token');
      dioAdapter.onGet(
        '/utente/me',
        (server) => server.reply(401, {'detail': 'Token non valido'}),
      );

      await authNotifier.checkAuth();

      expect(authNotifier.state.isAuthenticated, false);
      expect(await storageService.getAccessToken(), isNull);
    });

    test('logout clears everything', () async {
      // First login
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, {
          'access_token': 'jwt-token',
          'token_type': 'bearer',
        }),
        data: Matchers.any,
      );
      dioAdapter.onGet(
        '/utente/me',
        (server) => server.reply(200, userJson),
      );
      await authNotifier.login(email: 'mario@test.com', password: 'pass');
      expect(authNotifier.state.isAuthenticated, true);

      // Then logout
      await authNotifier.logout();

      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.user, isNull);
      expect(await storageService.getAccessToken(), isNull);
    });

    test('clearError resets error state', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(401, {'detail': 'Credenziali non valide'}),
        data: Matchers.any,
      );
      await authNotifier.login(email: 'bad@test.com', password: 'wrong');
      expect(authNotifier.state.error, isNotNull);

      authNotifier.clearError();
      expect(authNotifier.state.error, isNull);
    });
  });
}
