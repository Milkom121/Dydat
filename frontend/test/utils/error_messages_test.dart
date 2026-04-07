import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/utils/error_messages.dart';

void main() {
  group('userFriendlyError', () {
    test('null restituisce messaggio generico', () {
      expect(
        userFriendlyError(null),
        'Si è verificato un problema. Riprova tra poco.',
      );
    });

    test('stringa vuota restituisce messaggio generico', () {
      expect(
        userFriendlyError(''),
        'Si è verificato un problema. Riprova tra poco.',
      );
    });

    test('timeout viene tradotto', () {
      expect(
        userFriendlyError('TimeoutException after 30s'),
        'Il server sta impiegando troppo tempo. Riprova tra poco.',
      );
    });

    test('SocketException viene tradotto', () {
      expect(
        userFriendlyError(
            'SocketException: Connection refused (OS Error: Connection refused)'),
        'Impossibile raggiungere il server. Controlla la connessione.',
      );
    });

    test('Failed host lookup viene tradotto', () {
      expect(
        userFriendlyError('Failed host lookup: api.dydat.it'),
        'Impossibile raggiungere il server. Controlla la connessione.',
      );
    });

    test('401 viene tradotto', () {
      expect(
        userFriendlyError('401 Unauthorized'),
        'Sessione scaduta. Effettua di nuovo l\'accesso.',
      );
    });

    test('403 viene tradotto', () {
      expect(
        userFriendlyError('403 Forbidden'),
        'Non hai i permessi per questa azione.',
      );
    });

    test('404 viene tradotto', () {
      expect(
        userFriendlyError('Not found'),
        'Risorsa non trovata. Potrebbe essere stata rimossa.',
      );
    });

    test('500 viene tradotto', () {
      expect(
        userFriendlyError('Internal Server Error'),
        'Il server ha riscontrato un problema. Riprova tra poco.',
      );
    });

    test('DioException viene tradotto', () {
      expect(
        userFriendlyError(
            'DioException [connection timeout]: The connection has timed out'),
        'Il server sta impiegando troppo tempo. Riprova tra poco.',
      );
    });

    test('FormatException viene tradotto', () {
      expect(
        userFriendlyError(
            'FormatException: Unexpected character (at character 1)'),
        'Si è verificato un errore imprevisto. Riprova.',
      );
    });

    test('Errore stream generico viene pulito', () {
      expect(
        userFriendlyError('Errore stream: SocketException: Connection reset'),
        'Impossibile raggiungere il server. Controlla la connessione.',
      );
    });

    test('Connessione persa con timeout viene tradotto come timeout', () {
      // "timeout" ha priorità più alta nella catena di match
      expect(
        userFriendlyError('Connessione persa (timeout)'),
        'Il server sta impiegando troppo tempo. Riprova tra poco.',
      );
    });

    test('Connessione persa senza dettagli viene semplificato', () {
      expect(
        userFriendlyError('Connessione persa: errore di rete'),
        'Connessione persa. Riprova tra poco.',
      );
    });

    test('Errore di connessione generico viene semplificato', () {
      expect(
        userFriendlyError('Errore di connessione: some_technical_detail'),
        'Errore di connessione. Controlla la rete e riprova.',
      );
    });

    test('messaggio gia user-friendly passa inalterato', () {
      const msg = 'Errore caricamento percorsi';
      expect(userFriendlyError(msg), msg);
    });

    test('messaggio italiano semplice passa inalterato', () {
      const msg = 'Errore invio messaggio';
      expect(userFriendlyError(msg), msg);
    });

    test('tipo con apice viene tradotto', () {
      expect(
        userFriendlyError("type 'Null' is not a subtype of type 'String'"),
        'Si è verificato un errore imprevisto. Riprova.',
      );
    });
  });
}
