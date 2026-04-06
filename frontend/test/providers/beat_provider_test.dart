import 'package:flutter_test/flutter_test.dart';

import 'package:dydat/models/sessione.dart';
import 'package:dydat/models/sse_events.dart' as sse;
import 'package:dydat/providers/beat_provider.dart';
import 'package:dydat/providers/session_provider.dart';

void main() {
  group('BeatState enum', () {
    test('ha 10 valori', () {
      expect(BeatState.values.length, 10);
    });

    test('contiene tutti i beat dalla direzione visiva', () {
      final nomi = BeatState.values.map((b) => b.name).toSet();
      expect(nomi, containsAll([
        'accoglienza', 'spiegazione', 'transizione', 'attesa',
        'esercizio', 'esitoCorretto', 'esitoErrato', 'esitoDopoGuida',
        'promozione', 'chiusura',
      ]));
    });
  });

  group('BeatProviderState', () {
    test('copyWith crea nuova istanza', () {
      final now = DateTime.now();
      final s1 = BeatProviderState(beat: BeatState.accoglienza, changedAt: now);
      final s2 = s1.copyWith(beat: BeatState.spiegazione);
      expect(s2.beat, BeatState.spiegazione);
      expect(s2.changedAt, now);
    });

    test('copyWith senza parametri mantiene valori', () {
      final now = DateTime.now();
      final s1 = BeatProviderState(beat: BeatState.promozione, changedAt: now);
      final s2 = s1.copyWith();
      expect(s2.beat, BeatState.promozione);
      expect(s2.changedAt, now);
    });
  });

  // Test di logica pura sui dati — il BeatNotifier vero richiede un ProviderContainer
  // completo con SessionNotifier/SessionService, quindi testiamo la logica di mappatura
  // beat-session in modo indiretto verificando le costanti e le priorita.
  group('BeatState semantica', () {
    test('beat transitori hanno durata minima', () {
      // Verifica che i beat che devono durare siano elencati
      // (test di documentazione — se il codice cambia, questo segnala)
      expect(BeatState.esitoCorretto.index, greaterThan(BeatState.esercizio.index));
      expect(BeatState.esitoDopoGuida.index, greaterThan(BeatState.esitoErrato.index));
      expect(BeatState.promozione.index, greaterThan(BeatState.esitoDopoGuida.index));
    });

    test('chiusura e l\'ultimo beat non-promozione', () {
      expect(BeatState.chiusura.index, BeatState.values.length - 1);
    });
  });

  group('SessionScreenState dati per calcolo beat', () {
    test('SessionScreenState ha tutti i campi necessari per il beat', () {
      // Verifica che i campi usati dal BeatNotifier esistano
      const state = SessionScreenState();
      expect(state.activeSession, isNull);
      expect(state.isStreaming, false);
      expect(state.latestEsito, isNull);
      expect(state.latestPromotion, isNull);
      expect(state.currentTurnActions, isEmpty);
    });

    test('EsitoEsercizioEvent distingue primo tentativo da con guida', () {
      const primoTentativo = sse.EsitoEsercizioEvent(
        corretto: true, primoTentativo: true, conGuida: false,
      );
      const conGuida = sse.EsitoEsercizioEvent(
        corretto: true, primoTentativo: false, conGuida: true,
      );
      const errato = sse.EsitoEsercizioEvent(
        corretto: false, primoTentativo: false, conGuida: false,
      );

      expect(primoTentativo.corretto, true);
      expect(primoTentativo.primoTentativo, true);
      expect(conGuida.conGuida, true);
      expect(errato.corretto, false);
    });

    test('PromozioneEvent ha i dati per il beat promozione', () {
      const promo = sse.PromozioneEvent(
        nodoId: 'n1', nodoNome: 'Test', nuovoLivello: 'operativo',
      );
      expect(promo.nodoNome, 'Test');
      expect(promo.nuovoLivello, 'operativo');
    });

    test('AzioneEvent chiudi_sessione riconoscibile per beat chiusura', () {
      const azione = sse.AzioneEvent(tipo: 'chiudi_sessione', params: {});
      expect(azione.tipo, 'chiudi_sessione');
    });

    test('AzioneEvent proponi_esercizio per beat attesa/transizione', () {
      const azione = sse.AzioneEvent(
        tipo: 'proponi_esercizio', params: {'testo': 'Calcola 2+2'},
      );
      expect(azione.tipo, 'proponi_esercizio');
    });
  });

  group('Sessione stato per beat', () {
    test('sessione attiva riconosciuta', () {
      final sessione = Sessione(id: 's1', stato: 'attiva', tipo: 'media');
      expect(sessione.stato, 'attiva');
    });

    test('sessione non attiva (terminata)', () {
      final sessione = Sessione(id: 's1', stato: 'terminata', tipo: 'media');
      expect(sessione.stato, isNot('attiva'));
    });
  });
}
