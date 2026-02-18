import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/models/utente.dart';
import 'package:dydat/providers/user_provider.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/services/user_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late UserNotifier userNotifier;

  final userJson = {
    'id': 'uuid-123',
    'email': 'mario@test.com',
    'nome': 'Mario',
    'preferenze_tutor': {'velocita': 'normale'},
    'contesto_personale': null,
    'materie_attive': ['matematica'],
    'obiettivo_giornaliero_min': 20,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    userNotifier = UserNotifier(userService: UserService(client: client));
  });

  group('UserNotifier', () {
    test('initial state has no profile', () {
      expect(userNotifier.state.profile, isNull);
      expect(userNotifier.state.isLoading, false);
    });

    test('loadProfile sets profile', () async {
      dioAdapter.onGet('/utente/me', (server) => server.reply(200, userJson));

      await userNotifier.loadProfile();

      expect(userNotifier.state.profile?.nome, 'Mario');
      expect(userNotifier.state.isLoading, false);
    });

    test('loadProfile on error sets error message', () async {
      dioAdapter.onGet(
        '/utente/me',
        (server) => server.reply(401, {'detail': 'Token non valido'}),
      );

      await userNotifier.loadProfile();

      expect(userNotifier.state.profile, isNull);
      expect(userNotifier.state.error, 'Token non valido');
    });

    test('updatePreferences returns updated profile', () async {
      dioAdapter.onPut(
        '/utente/me/preferenze',
        (server) => server.reply(200, {
          ...userJson,
          'preferenze_tutor': {'velocita': 'lento'},
        }),
        data: Matchers.any,
      );

      await userNotifier
          .updatePreferences(const PreferenzeStudio(velocita: 'lento'));

      expect(
        userNotifier.state.profile?.preferenzeTutor?['velocita'],
        'lento',
      );
    });

    test('clear resets state', () async {
      dioAdapter.onGet('/utente/me', (server) => server.reply(200, userJson));
      await userNotifier.loadProfile();
      expect(userNotifier.state.profile, isNotNull);

      userNotifier.clear();
      expect(userNotifier.state.profile, isNull);
    });
  });
}
