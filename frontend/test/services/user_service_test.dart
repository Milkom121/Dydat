import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/models/utente.dart';
import 'package:dydat/services/user_service.dart';
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
  late UserService userService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    userService = UserService(client: client);
  });

  group('UserService', () {
    test('getMe returns Utente', () async {
      dioAdapter.onGet(
        '/utente/me',
        (server) => server.reply(200, {
          'id': 'uuid-123',
          'email': 'mario@test.com',
          'nome': 'Mario',
          'preferenze_tutor': {'velocita': 'normale'},
          'contesto_personale': null,
          'materie_attive': ['matematica'],
          'obiettivo_giornaliero_min': 30,
        }),
      );

      final utente = await userService.getMe();
      expect(utente.id, 'uuid-123');
      expect(utente.email, 'mario@test.com');
      expect(utente.nome, 'Mario');
      expect(utente.materieAttive, ['matematica']);
      expect(utente.obiettvoGiornalieroMin, 30);
    });

    test('updatePreferences returns updated Utente', () async {
      dioAdapter.onPut(
        '/utente/me/preferenze',
        (server) => server.reply(200, {
          'id': 'uuid-123',
          'email': 'mario@test.com',
          'nome': 'Mario',
          'preferenze_tutor': {'velocita': 'lento', 'incoraggiamento': 'alto'},
          'contesto_personale': null,
          'materie_attive': ['matematica'],
          'obiettivo_giornaliero_min': 20,
        }),
        data: Matchers.any,
      );

      final utente = await userService.updatePreferences(
        const PreferenzeStudio(velocita: 'lento', incoraggiamento: 'alto'),
      );
      expect(utente.preferenzeTutor?['velocita'], 'lento');
    });

    test('getStats returns StatisticheUtente', () async {
      dioAdapter.onGet(
        '/utente/me/statistiche',
        (server) => server.reply(200, {
          'streak': 5,
          'nodi_completati': 12,
          'sessioni_completate': 8,
          'settimana': {
            'minuti_studio': 120,
            'esercizi_svolti': 30,
            'esercizi_corretti': 25,
            'nodi_completati': 3,
            'giorni_attivi': 5,
          },
          'mese': {
            'minuti_studio': 480,
            'esercizi_svolti': 100,
            'esercizi_corretti': 80,
            'nodi_completati': 12,
            'giorni_attivi': 18,
          },
          'sempre': {
            'minuti_studio': 480,
            'esercizi_svolti': 100,
            'esercizi_corretti': 80,
            'nodi_completati': 12,
            'giorni_attivi': 18,
          },
        }),
      );

      final stats = await userService.getStats();
      expect(stats.streak, 5);
      expect(stats.nodiCompletati, 12);
      expect(stats.settimana.minutiStudio, 120);
    });
  });
}
