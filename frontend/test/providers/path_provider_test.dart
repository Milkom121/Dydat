import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/providers/path_provider.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/path_service.dart';
import 'package:dydat/services/storage_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late PathNotifier pathNotifier;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    pathNotifier = PathNotifier(pathService: PathService(client: client));
  });

  group('PathNotifier', () {
    test('initial state is empty', () {
      expect(pathNotifier.state.paths, isEmpty);
      expect(pathNotifier.state.topics, isEmpty);
      expect(pathNotifier.state.currentMap, isNull);
    });

    test('loadPaths sets paths', () async {
      dioAdapter.onGet(
        '/percorsi/',
        (server) => server.reply(200, [
          {
            'id': 1,
            'tipo': 'binario_1',
            'materia': 'matematica',
            'nome': 'Percorso Matematica',
            'stato': 'attivo',
            'nodo_iniziale_override': null,
            'created_at': null,
          },
        ]),
      );

      await pathNotifier.loadPaths();

      expect(pathNotifier.state.paths.length, 1);
      expect(pathNotifier.state.paths[0].materia, 'matematica');
    });

    test('loadMap sets currentMap', () async {
      dioAdapter.onGet(
        '/percorsi/1/mappa',
        (server) => server.reply(200, {
          'percorso_id': 1,
          'materia': 'matematica',
          'nodo_iniziale_override': null,
          'nodi': [
            {
              'id': 'nodo1',
              'nome': 'Nodo 1',
              'tipo': 'standard',
              'tema_id': null,
              'livello': 'non_iniziato',
              'presunto': false,
              'spiegazione_data': false,
              'esercizi_completati': 0,
            },
          ],
        }),
      );

      await pathNotifier.loadMap(1);

      expect(pathNotifier.state.currentMap?.percorsoId, 1);
      expect(pathNotifier.state.currentMap?.nodi.length, 1);
    });

    test('loadTopics sets topics', () async {
      dioAdapter.onGet(
        '/temi/',
        (server) => server.reply(200, [
          {
            'id': 'tema1',
            'nome': 'Derivate',
            'materia': 'matematica',
            'descrizione': null,
            'nodi_totali': 5,
            'nodi_completati': 2,
            'completato': false,
          },
        ]),
      );

      await pathNotifier.loadTopics();

      expect(pathNotifier.state.topics.length, 1);
      expect(pathNotifier.state.topics[0].nodiTotali, 5);
    });

    test('loadTopicDetail sets currentTopicDetail', () async {
      dioAdapter.onGet(
        '/temi/tema1',
        (server) => server.reply(200, {
          'id': 'tema1',
          'nome': 'Derivate',
          'materia': 'matematica',
          'descrizione': null,
          'nodi_totali': 1,
          'nodi_completati': 0,
          'completato': false,
          'nodi': [
            {
              'id': 'nodo1',
              'nome': 'Nodo 1',
              'tipo': 'standard',
              'tema_id': 'tema1',
              'livello': 'non_iniziato',
              'presunto': false,
              'spiegazione_data': false,
              'esercizi_completati': 0,
            },
          ],
        }),
      );

      await pathNotifier.loadTopicDetail('tema1');

      expect(pathNotifier.state.currentTopicDetail?.nome, 'Derivate');
      expect(pathNotifier.state.currentTopicDetail?.nodi.length, 1);
    });

    test('refresh loads both paths and topics', () async {
      dioAdapter.onGet(
        '/percorsi/',
        (server) => server.reply(200, [
          {
            'id': 1,
            'tipo': 'binario_1',
            'materia': 'matematica',
            'nome': null,
            'stato': 'attivo',
            'nodo_iniziale_override': null,
            'created_at': null,
          },
        ]),
      );
      dioAdapter.onGet(
        '/temi/',
        (server) => server.reply(200, [
          {
            'id': 'tema1',
            'nome': 'Derivate',
            'materia': 'matematica',
            'descrizione': null,
            'nodi_totali': 3,
            'nodi_completati': 1,
            'completato': false,
          },
        ]),
      );

      await pathNotifier.refresh();

      expect(pathNotifier.state.paths.length, 1);
      expect(pathNotifier.state.topics.length, 1);
      expect(pathNotifier.state.isLoading, false);
    });

    test('loadPaths on error sets error', () async {
      dioAdapter.onGet(
        '/percorsi/',
        (server) =>
            server.reply(401, {'detail': 'Token non valido'}),
      );

      await pathNotifier.loadPaths();

      expect(pathNotifier.state.paths, isEmpty);
      expect(pathNotifier.state.error, 'Token non valido');
    });

    test('clear resets state', () async {
      dioAdapter.onGet(
        '/percorsi/',
        (server) => server.reply(200, [
          {
            'id': 1,
            'tipo': 'binario_1',
            'materia': 'matematica',
            'nome': null,
            'stato': 'attivo',
            'nodo_iniziale_override': null,
            'created_at': null,
          },
        ]),
      );
      await pathNotifier.loadPaths();

      pathNotifier.clear();

      expect(pathNotifier.state.paths, isEmpty);
      expect(pathNotifier.state.currentMap, isNull);
    });
  });
}
