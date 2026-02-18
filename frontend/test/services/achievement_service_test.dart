import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/services/achievement_service.dart';
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
  late AchievementService achievementService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    achievementService = AchievementService(client: client);
  });

  group('AchievementService', () {
    test('getAll returns AchievementResponse', () async {
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

      final response = await achievementService.getAll();
      expect(response.sbloccati.length, 1);
      expect(response.sbloccati[0].id, 'primo_nodo');
      expect(response.sbloccati[0].sbloccatoAt, '2026-02-18T10:00:00');
      expect(response.prossimi.length, 1);
      expect(response.prossimi[0].progresso.corrente, 1);
      expect(response.prossimi[0].progresso.richiesto, 5);
    });

    test('getAll with empty lists', () async {
      dioAdapter.onGet(
        '/achievement/',
        (server) => server.reply(200, {
          'sbloccati': [],
          'prossimi': [],
        }),
      );

      final response = await achievementService.getAll();
      expect(response.sbloccati, isEmpty);
      expect(response.prossimi, isEmpty);
    });
  });
}
