import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/services/session_service.dart';
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
  late SessionService sessionService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    sessionService = SessionService(client: client);
  });

  final sessionJson = {
    'id': 'session-uuid-1',
    'stato': 'attiva',
    'tipo': 'media',
    'nodo_focale_id': 'derivata_definizione',
    'nodo_focale_nome': 'Definizione di Derivata',
    'attivita_corrente': 'spiegazione',
    'durata_prevista_min': 30,
    'durata_effettiva_min': null,
    'nodi_lavorati': null,
  };

  group('SessionService', () {
    test('start makes POST to /sessione/inizia', () async {
      dioAdapter.onPost(
        '/sessione/inizia',
        (server) => server.reply(200, ''),
        data: Matchers.any,
      );

      await sessionService.start(tipo: 'media', durataPrevistaMin: 30);
    });

    test('sendTurn makes POST to /sessione/{id}/turno', () async {
      dioAdapter.onPost(
        '/sessione/session-uuid-1/turno',
        (server) => server.reply(200, ''),
        data: Matchers.any,
      );

      await sessionService.sendTurn(
        sessioneId: 'session-uuid-1',
        messaggio: 'Capito, grazie!',
      );
    });

    test('suspend returns Sessione with stato sospesa', () async {
      dioAdapter.onPost(
        '/sessione/session-uuid-1/sospendi',
        (server) => server.reply(200, {
          ...sessionJson,
          'stato': 'sospesa',
        }),
      );

      final session = await sessionService.suspend('session-uuid-1');
      expect(session.id, 'session-uuid-1');
      expect(session.stato, 'sospesa');
    });

    test('end returns Sessione with stato completata', () async {
      dioAdapter.onPost(
        '/sessione/session-uuid-1/termina',
        (server) => server.reply(200, {
          ...sessionJson,
          'stato': 'completata',
          'durata_effettiva_min': 25,
        }),
      );

      final session = await sessionService.end('session-uuid-1');
      expect(session.stato, 'completata');
      expect(session.durataEffettivaMin, 25);
    });

    test('get returns Sessione', () async {
      dioAdapter.onGet(
        '/sessione/session-uuid-1',
        (server) => server.reply(200, sessionJson),
      );

      final session = await sessionService.get('session-uuid-1');
      expect(session.id, 'session-uuid-1');
      expect(session.nodoFocaleId, 'derivata_definizione');
      expect(session.attivitaCorrente, 'spiegazione');
    });

    test('get throws DioException on 404', () async {
      dioAdapter.onGet(
        '/sessione/nonexistent',
        (server) =>
            server.reply(404, {'detail': 'Sessione non trovata'}),
      );

      expect(
        () => sessionService.get('nonexistent'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
