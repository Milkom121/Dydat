// Helper per la gestione singolare/plurale in italiano.
// Usato nei widget per evitare stringhe tipo "1 sessioni".

String sessione(int n) => n == 1 ? '$n sessione' : '$n sessioni';

String giorno(int n) => n == 1 ? '$n giorno' : '$n giorni';

String esercizio(int n) => n == 1 ? '$n esercizio' : '$n esercizi';

String nodo(int n) => n == 1 ? '$n nodo' : '$n nodi';

String ripasso(int n) => n == 1 ? '$n ripasso' : '$n ripassi';
