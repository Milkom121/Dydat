import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/services/path_service.dart';
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
  late PathService pathService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    pathService = PathService(client: client);
  });

  group('PathService', () {
    test('getPaths returns list of Percorso', () async {
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
            'created_at': '2026-02-18T10:00:00',
          },
        ]),
      );

      final paths = await pathService.getPaths();
      expect(paths.length, 1);
      expect(paths[0].materia, 'matematica');
      expect(paths[0].tipo, 'binario_1');
    });

    test('getMap returns MappaPercorso with nodi', () async {
      dioAdapter.onGet(
        '/percorsi/1/mappa',
        (server) => server.reply(200, {
          'percorso_id': 1,
          'materia': 'matematica',
          'nodo_iniziale_override': null,
          'nodi': [
            {
              'id': 'derivata_definizione',
              'nome': 'Definizione di Derivata',
              'tipo': 'standard',
              'tema_id': 'tema_derivate',
              'livello': 'non_iniziato',
              'presunto': false,
              'spiegazione_data': false,
              'esercizi_completati': 0,
            },
            {
              'id': 'derivata_calcolo',
              'nome': 'Calcolo Derivate',
              'tipo': 'standard',
              'tema_id': 'tema_derivate',
              'livello': 'in_corso',
              'presunto': false,
              'spiegazione_data': true,
              'esercizi_completati': 2,
            },
          ],
        }),
      );

      final map = await pathService.getMap(1);
      expect(map.percorsoId, 1);
      expect(map.nodi.length, 2);
      expect(map.nodi[0].id, 'derivata_definizione');
      expect(map.nodi[1].spiegazioneData, true);
    });

    test('getTopics returns list of Tema', () async {
      dioAdapter.onGet(
        '/temi/',
        (server) => server.reply(200, [
          {
            'id': 'tema_derivate',
            'nome': 'Derivate',
            'materia': 'matematica',
            'descrizione': 'Concetti sulle derivate',
            'nodi_totali': 5,
            'nodi_completati': 2,
            'completato': false,
          },
        ]),
      );

      final topics = await pathService.getTopics();
      expect(topics.length, 1);
      expect(topics[0].nome, 'Derivate');
      expect(topics[0].nodiCompletati, 2);
    });

    test('getTopicDetail returns TemaDettaglio with nodi', () async {
      dioAdapter.onGet(
        '/temi/tema_derivate',
        (server) => server.reply(200, {
          'id': 'tema_derivate',
          'nome': 'Derivate',
          'materia': 'matematica',
          'descrizione': null,
          'nodi_totali': 2,
          'nodi_completati': 1,
          'completato': false,
          'nodi': [
            {
              'id': 'derivata_definizione',
              'nome': 'Definizione di Derivata',
              'tipo': 'standard',
              'tema_id': 'tema_derivate',
              'livello': 'operativo',
              'presunto': false,
              'spiegazione_data': true,
              'esercizi_completati': 3,
            },
          ],
        }),
      );

      final detail = await pathService.getTopicDetail('tema_derivate');
      expect(detail.nome, 'Derivate');
      expect(detail.nodi.length, 1);
      expect(detail.nodi[0].livello, 'operativo');
    });
  });
}
