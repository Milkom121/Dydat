// Helper centralizzato per convertire messaggi di errore tecnici
// in stringhe italiane user-friendly.
//
// Usato dai widget e provider per evitare che dettagli tecnici
// (DioException, stack trace, codici HTTP) raggiungano l'utente.

/// Converte un messaggio di errore grezzo in un messaggio
/// comprensibile per l'utente finale.
///
/// Se il messaggio è già user-friendly (italiano, senza dettagli tecnici),
/// lo restituisce così com'è.
String userFriendlyError(String? raw) {
  if (raw == null || raw.isEmpty) {
    return 'Si è verificato un problema. Riprova tra poco.';
  }

  final lower = raw.toLowerCase();

  // --- Timeout ---
  if (lower.contains('timeout') || lower.contains('timedout')) {
    return 'Il server sta impiegando troppo tempo. Riprova tra poco.';
  }

  // --- Rete / connessione ---
  if (lower.contains('socketexception') ||
      lower.contains('connection refused') ||
      lower.contains('connection reset') ||
      lower.contains('network is unreachable') ||
      lower.contains('no address associated') ||
      lower.contains('failed host lookup')) {
    return 'Impossibile raggiungere il server. Controlla la connessione.';
  }

  // --- HTTP 401 / 403 ---
  if (lower.contains('401') || lower.contains('unauthorized')) {
    return 'Sessione scaduta. Effettua di nuovo l\'accesso.';
  }
  if (lower.contains('403') || lower.contains('forbidden')) {
    return 'Non hai i permessi per questa azione.';
  }

  // --- HTTP 404 ---
  if (lower.contains('404') || lower.contains('not found')) {
    return 'Risorsa non trovata. Potrebbe essere stata rimossa.';
  }

  // --- HTTP 409 ---
  if (lower.contains('409') || lower.contains('conflict')) {
    return 'C\'è un conflitto con un\'altra operazione in corso. Riprova.';
  }

  // --- HTTP 500+ ---
  if (lower.contains('500') ||
      lower.contains('internal server error') ||
      lower.contains('502') ||
      lower.contains('503') ||
      lower.contains('bad gateway') ||
      lower.contains('service unavailable')) {
    return 'Il server ha riscontrato un problema. Riprova tra poco.';
  }

  // --- DioException / FormatException / Exception generiche ---
  if (lower.contains('dioexception') ||
      lower.contains('dio error') ||
      lower.contains('formatexception') ||
      lower.contains('type \'') ||
      lower.contains('stacktrace') ||
      lower.contains('exception:') ||
      lower.contains('error:') && lower.contains('at ')) {
    return 'Si è verificato un errore imprevisto. Riprova.';
  }

  // --- Connessione persa (SSE) ---
  if (lower.contains('connessione persa')) {
    return 'Connessione persa. Riprova tra poco.';
  }

  // --- Errore stream generico ---
  if (lower.startsWith('errore stream:')) {
    return 'Connessione interrotta. Riprova.';
  }

  // --- Errore di connessione generico ---
  if (lower.startsWith('errore di connessione:')) {
    return 'Errore di connessione. Controlla la rete e riprova.';
  }

  // Se il messaggio sembra già user-friendly (italiano, senza dettagli tecnici),
  // lo restituiamo così com'è.
  return raw;
}
