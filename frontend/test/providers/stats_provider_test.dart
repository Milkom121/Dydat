import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/providers/stats_provider.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/services/user_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late StatsNotifier statsNotifier;

  final statsJson = {
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
      'minuti_studio': 960,
      'esercizi_svolti': 200,
      'esercizi_corretti': 160,
      'nodi_completati': 12,
      'giorni_attivi': 30,
    },
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    statsNotifier = StatsNotifier(userService: UserService(client: client));
  });

  group('StatsNotifier', () {
    test('initial state has no stats', () {
      expect(statsNotifier.state.stats, isNull);
      expect(statsNotifier.state.isLoading, false);
    });

    test('load sets stats', () async {
      dioAdapter.onGet(
        '/utente/me/statistiche',
        (server) => server.reply(200, statsJson),
      );

      await statsNotifier.load();

      expect(statsNotifier.state.stats?.streak, 5);
      expect(statsNotifier.state.stats?.nodiCompletati, 12);
      expect(statsNotifier.state.stats?.settimana.minutiStudio, 120);
      expect(statsNotifier.state.stats?.mese.eserciziSvolti, 100);
      expect(statsNotifier.state.isLoading, false);
    });

    test('load on error sets error', () async {
      dioAdapter.onGet(
        '/utente/me/statistiche',
        (server) => server.reply(401, {'detail': 'Token non valido'}),
      );

      await statsNotifier.load();

      expect(statsNotifier.state.stats, isNull);
      expect(statsNotifier.state.error, 'Token non valido');
    });

    test('clear resets state', () async {
      dioAdapter.onGet(
        '/utente/me/statistiche',
        (server) => server.reply(200, statsJson),
      );
      await statsNotifier.load();

      statsNotifier.clear();

      expect(statsNotifier.state.stats, isNull);
    });
  });
}
