import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/services/session_service.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/sse_client.dart';
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
    final sseClient = SseClient(storageService: storageService);
    sessionService = SessionService(client: client, sseClient: sseClient);
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
    test('start makes POST to /sessione/inizia and parses SSE', () async {
      // DioAdapter JSON-encodes response data, which escapes newlines and
      // breaks plain-text SSE parsing. Use a Dio interceptor instead to
      // return the raw SSE text for the POST and JSON for the follow-up GET.
      const sseText = 'event: sessione_creata\n'
          'data: {"sessione_id":"session-uuid-1","nodo_id":"derivata_definizione","nodo_nome":"Definizione di Derivata"}\n\n';

      dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/sessione/inizia')) {
              return handler.resolve(Response(
                data: sseText,
                statusCode: 200,
                requestOptions: options,
              ));
            }
            if (options.path.contains('/sessione/session-uuid-1') &&
                options.method == 'GET') {
              return handler.resolve(Response(
                data: sessionJson,
                statusCode: 200,
                requestOptions: options,
              ));
            }
            return handler.next(options);
          },
        ),
      );

      final session =
          await sessionService.start(tipo: 'media', durataPrevistaMin: 30);
      expect(session.id, 'session-uuid-1');
      expect(session.stato, 'attiva');
      expect(session.nodoFocaleNome, 'Definizione di Derivata');
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

    test('listSessions returns list of SessioneListItem', () async {
      dioAdapter.onGet(
        '/sessione/',
        (server) => server.reply(200, [
          {
            'id': 'session-1',
            'stato': 'completata',
            'tipo': 'media',
            'nodo_focale_id': 'nodo_1',
            'nodo_focale_nome': 'Numeri naturali',
            'durata_effettiva_min': 15,
            'nodi_lavorati': ['nodo_1', 'nodo_2'],
            'created_at': '2026-02-19T10:00:00',
            'completed_at': '2026-02-19T10:15:00',
          },
          {
            'id': 'session-2',
            'stato': 'sospesa',
            'tipo': 'media',
            'nodo_focale_id': 'nodo_3',
            'nodo_focale_nome': null,
            'durata_effettiva_min': 5,
            'nodi_lavorati': ['nodo_3'],
            'created_at': '2026-02-18T14:00:00',
            'completed_at': null,
          },
        ]),
        queryParameters: {'limit': 10, 'offset': 0},
      );

      final sessions = await sessionService.listSessions();
      expect(sessions, hasLength(2));
      expect(sessions[0].id, 'session-1');
      expect(sessions[0].stato, 'completata');
      expect(sessions[0].nodoFocaleNome, 'Numeri naturali');
      expect(sessions[0].durataEffettivaMin, 15);
      expect(sessions[0].nodiLavorati, ['nodo_1', 'nodo_2']);
      expect(sessions[0].createdAt, '2026-02-19T10:00:00');
      expect(sessions[0].completedAt, '2026-02-19T10:15:00');
      expect(sessions[1].id, 'session-2');
      expect(sessions[1].stato, 'sospesa');
      expect(sessions[1].completedAt, isNull);
    });

    test('listSessions returns empty list', () async {
      dioAdapter.onGet(
        '/sessione/',
        (server) => server.reply(200, []),
        queryParameters: {'limit': 10, 'offset': 0},
      );

      final sessions = await sessionService.listSessions();
      expect(sessions, isEmpty);
    });

    test('listSessions passes limit and offset', () async {
      dioAdapter.onGet(
        '/sessione/',
        (server) => server.reply(200, [
          {
            'id': 'session-3',
            'stato': 'completata',
            'tipo': 'media',
            'nodo_focale_id': null,
            'nodo_focale_nome': null,
            'durata_effettiva_min': null,
            'nodi_lavorati': null,
            'created_at': '2026-02-17T08:00:00',
            'completed_at': null,
          },
        ]),
        queryParameters: {'limit': 5, 'offset': 10},
      );

      final sessions =
          await sessionService.listSessions(limit: 5, offset: 10);
      expect(sessions, hasLength(1));
      expect(sessions[0].id, 'session-3');
    });
  });
}
