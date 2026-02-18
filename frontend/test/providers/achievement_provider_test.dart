import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/providers/achievement_provider.dart';
import 'package:dydat/services/achievement_service.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/storage_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late AchievementNotifier achievementNotifier;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    achievementNotifier = AchievementNotifier(
      achievementService: AchievementService(client: client),
    );
  });

  group('AchievementNotifier', () {
    test('initial state is empty', () {
      expect(achievementNotifier.state.unlocked, isEmpty);
      expect(achievementNotifier.state.next, isEmpty);
      expect(achievementNotifier.state.isLoading, false);
    });

    test('load sets unlocked and next', () async {
      dioAdapter.onGet(
        '/achievement/',
        (server) => server.reply(200, {
          'sbloccati': [
            {
              'id': 'primo_nodo',
              'nome': 'Primo passo!',
              'tipo': 'sigillo',
              'descrizione': null,
              'sbloccato_at': '2026-02-18T10:00:00',
            },
          ],
          'prossimi': [
            {
              'id': 'cinque_nodi',
              'nome': 'Cinque su cinque',
              'tipo': 'sigillo',
              'descrizione': null,
              'condizione': {'tipo': 'nodi_completati', 'valore': 5},
              'progresso': {'corrente': 1, 'richiesto': 5},
            },
          ],
        }),
      );

      await achievementNotifier.load();

      expect(achievementNotifier.state.unlocked.length, 1);
      expect(achievementNotifier.state.unlocked[0].id, 'primo_nodo');
      expect(achievementNotifier.state.next.length, 1);
      expect(achievementNotifier.state.next[0].progresso.corrente, 1);
      expect(achievementNotifier.state.isLoading, false);
    });

    test('load on error sets error', () async {
      dioAdapter.onGet(
        '/achievement/',
        (server) => server.reply(401, {'detail': 'Token non valido'}),
      );

      await achievementNotifier.load();

      expect(achievementNotifier.state.unlocked, isEmpty);
      expect(achievementNotifier.state.error, 'Token non valido');
    });

    test('unreadCount returns unlocked count', () async {
      dioAdapter.onGet(
        '/achievement/',
        (server) => server.reply(200, {
          'sbloccati': [
            {
              'id': 'a',
              'nome': 'A',
              'tipo': 'sigillo',
              'descrizione': null,
              'sbloccato_at': null,
            },
            {
              'id': 'b',
              'nome': 'B',
              'tipo': 'medaglia',
              'descrizione': null,
              'sbloccato_at': null,
            },
          ],
          'prossimi': [],
        }),
      );

      await achievementNotifier.load();
      expect(achievementNotifier.state.unreadCount, 2);
    });

    test('clear resets state', () async {
      dioAdapter.onGet(
        '/achievement/',
        (server) => server.reply(200, {
          'sbloccati': [
            {
              'id': 'a',
              'nome': 'A',
              'tipo': 'sigillo',
              'descrizione': null,
              'sbloccato_at': null,
            },
          ],
          'prossimi': [],
        }),
      );
      await achievementNotifier.load();

      achievementNotifier.clear();

      expect(achievementNotifier.state.unlocked, isEmpty);
      expect(achievementNotifier.state.next, isEmpty);
    });
  });
}
