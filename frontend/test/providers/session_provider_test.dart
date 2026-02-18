import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dydat/models/sessione.dart';
import 'package:dydat/providers/session_provider.dart';
import 'package:dydat/services/dio_client.dart';
import 'package:dydat/services/session_service.dart';
import 'package:dydat/services/storage_service.dart';
import '../helpers/fake_secure_storage.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late SessionNotifier sessionNotifier;

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

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dioAdapter = DioAdapter(dio: dio);
    final storageService = StorageService(storage: FakeSecureStorage());
    final client = DioClient(storageService: storageService, dio: dio);
    sessionNotifier = SessionNotifier(
      sessionService: SessionService(client: client),
    );
  });

  group('SessionNotifier', () {
    test('initial state has no session', () {
      expect(sessionNotifier.state.activeSession, isNull);
      expect(sessionNotifier.state.tutorMessages, isEmpty);
      expect(sessionNotifier.state.isLoading, false);
    });

    test('setActiveSession sets the session', () {
      final session = Sessione.fromJson(sessionJson);
      sessionNotifier.setActiveSession(session);

      expect(sessionNotifier.state.activeSession?.id, 'session-uuid-1');
      expect(sessionNotifier.state.activeSession?.stato, 'attiva');
    });

    test('addTutorMessage adds to list', () {
      sessionNotifier.addTutorMessage('Ciao!');
      sessionNotifier.addTutorMessage(' Come');

      expect(sessionNotifier.state.tutorMessages, ['Ciao!', ' Come']);
    });

    test('sendTurn calls API', () async {
      sessionNotifier.setActiveSession(Sessione.fromJson(sessionJson));

      dioAdapter.onPost(
        '/sessione/session-uuid-1/turno',
        (server) => server.reply(200, ''),
        data: Matchers.any,
      );

      await sessionNotifier.sendTurn('La derivata è 6x + 2');

      expect(sessionNotifier.state.isLoading, false);
      expect(sessionNotifier.state.error, isNull);
    });

    test('sendTurn without active session does nothing', () async {
      await sessionNotifier.sendTurn('test');
      expect(sessionNotifier.state.isLoading, false);
    });

    test('suspend updates session state', () async {
      sessionNotifier.setActiveSession(Sessione.fromJson(sessionJson));

      dioAdapter.onPost(
        '/sessione/session-uuid-1/sospendi',
        (server) => server.reply(200, {...sessionJson, 'stato': 'sospesa'}),
      );

      await sessionNotifier.suspend();

      expect(sessionNotifier.state.activeSession?.stato, 'sospesa');
      expect(sessionNotifier.state.isLoading, false);
    });

    test('endSession updates session state', () async {
      sessionNotifier.setActiveSession(Sessione.fromJson(sessionJson));

      dioAdapter.onPost(
        '/sessione/session-uuid-1/termina',
        (server) => server.reply(200, {
          ...sessionJson,
          'stato': 'completata',
          'durata_effettiva_min': 25,
        }),
      );

      await sessionNotifier.endSession();

      expect(sessionNotifier.state.activeSession?.stato, 'completata');
      expect(sessionNotifier.state.activeSession?.durataEffettivaMin, 25);
    });

    test('loadSession loads by ID', () async {
      dioAdapter.onGet(
        '/sessione/session-uuid-1',
        (server) => server.reply(200, sessionJson),
      );

      await sessionNotifier.loadSession('session-uuid-1');

      expect(sessionNotifier.state.activeSession?.id, 'session-uuid-1');
      expect(
        sessionNotifier.state.activeSession?.nodoFocaleNome,
        'Definizione di Derivata',
      );
    });

    test('loadSession on 404 sets error', () async {
      dioAdapter.onGet(
        '/sessione/bad-uuid',
        (server) => server.reply(404, {'detail': 'Sessione non trovata'}),
      );

      await sessionNotifier.loadSession('bad-uuid');

      expect(sessionNotifier.state.activeSession, isNull);
      expect(sessionNotifier.state.error, 'Sessione non trovata');
    });

    test('clear resets state', () {
      sessionNotifier.setActiveSession(Sessione.fromJson(sessionJson));
      sessionNotifier.addTutorMessage('text');

      sessionNotifier.clear();

      expect(sessionNotifier.state.activeSession, isNull);
      expect(sessionNotifier.state.tutorMessages, isEmpty);
    });
  });
}
