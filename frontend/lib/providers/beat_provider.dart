import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sse_events.dart';
import './session_provider.dart';

/// I beat emotivi della sessione, dalla direzione visiva v2.
/// Ogni beat corrisponde a un momento preciso del flusso di studio.
enum BeatState {
  /// Beat 1 — Apertura: "Bentornato a casa". Caldo, rilassato.
  accoglienza,

  /// Beat 2 — Spiegazione: "Sto imparando". Tutor streaming.
  spiegazione,

  /// Beat 3 — Transizione: "Ok, tocca a me". Passaggio passivo->attivo.
  transizione,

  /// Beat 3.5 — Preparazione: "Sta arrivando qualcosa". Tool_use senza testo.
  attesa,

  /// Beat 4 — Esercizio: "Ci sto provando". Studente protagonista.
  esercizio,

  /// Beat 5a — Corretto primo tentativo: "Ce l'ho fatta!". Burst rapido.
  esitoCorretto,

  /// Beat 5b — Errore: "Va bene, ragioniamoci". Morbido, mai punitivo.
  esitoErrato,

  /// Beat 5c — Corretto dopo guida: "Ce l'hai fatta, e l'hai capito". Caldo, lento.
  esitoDopoGuida,

  /// Beat 6 — Promozione: "Sto crescendo davvero". Momento piu grande.
  promozione,

  /// Beat 7 — Chiusura: "Ho fatto bene oggi". Calmo, conclusivo.
  chiusura,
}

/// Stato del beat provider: beat corrente + timestamp dell'ultimo cambio.
class BeatProviderState {
  final BeatState beat;

  /// Quando il beat e cambiato l'ultima volta (per gestire durata minima).
  final DateTime changedAt;

  const BeatProviderState({
    required this.beat,
    required this.changedAt,
  });

  BeatProviderState copyWith({BeatState? beat, DateTime? changedAt}) {
    return BeatProviderState(
      beat: beat ?? this.beat,
      changedAt: changedAt ?? this.changedAt,
    );
  }
}

/// Provider che calcola il beat emotivo corrente dalla sessione.
final beatProvider =
    StateNotifierProvider<BeatNotifier, BeatProviderState>((ref) {
  return BeatNotifier(ref);
});

class BeatNotifier extends StateNotifier<BeatProviderState> {
  final Ref _ref;

  /// Ultimo esito osservato (per non ri-triggerare lo stesso beat).
  EsitoEsercizioEvent? _lastSeenEsito;

  /// Ultima promozione osservata.
  PromozioneEvent? _lastSeenPromotion;

  /// Se c'e un'azione fullscreen attiva (esercizio/formula/backtrack).
  bool _hasFullscreenAction = false;

  BeatNotifier(this._ref)
      : super(BeatProviderState(
          beat: BeatState.accoglienza,
          changedAt: DateTime.now(),
        )) {
    // Ascolta i cambiamenti della sessione
    _ref.listen<SessionScreenState>(sessionProvider, (prev, next) {
      _computeBeat(next);
    });
  }

  /// Segnala che un'azione fullscreen e stata mostrata (esercizio, formula, backtrack).
  void setFullscreenActive(bool active) {
    _hasFullscreenAction = active;
    _computeBeat(_ref.read(sessionProvider));
  }

  /// Durate minime per beat transitori (evita flickering).
  static const _minDurations = {
    BeatState.esitoCorretto: Duration(seconds: 2),
    BeatState.esitoErrato: Duration(seconds: 1),
    BeatState.esitoDopoGuida: Duration(seconds: 3),
    BeatState.promozione: Duration(seconds: 3),
    BeatState.transizione: Duration(milliseconds: 500),
  };

  void _computeBeat(SessionScreenState sessionState) {
    final session = sessionState.activeSession;
    final isActive = session != null && session.stato == 'attiva';

    if (!isActive) {
      _setBeat(BeatState.accoglienza);
      return;
    }

    // Controlla durata minima del beat corrente
    final minDuration = _minDurations[state.beat];
    if (minDuration != null) {
      final elapsed = DateTime.now().difference(state.changedAt);
      if (elapsed < minDuration) return;
    }

    // Priorita 1: promozione (beat piu importante)
    final promotion = sessionState.latestPromotion;
    if (promotion != null && promotion != _lastSeenPromotion) {
      _lastSeenPromotion = promotion;
      _setBeat(BeatState.promozione);
      return;
    }

    // Priorita 2: esito esercizio
    final esito = sessionState.latestEsito;
    if (esito != null && esito != _lastSeenEsito) {
      _lastSeenEsito = esito;
      if (esito.corretto && esito.primoTentativo) {
        _setBeat(BeatState.esitoCorretto);
      } else if (esito.corretto && esito.conGuida) {
        _setBeat(BeatState.esitoDopoGuida);
      } else if (!esito.corretto) {
        _setBeat(BeatState.esitoErrato);
      } else {
        // corretto ma ne primoTentativo ne conGuida — tratta come corretto
        _setBeat(BeatState.esitoCorretto);
      }
      return;
    }

    // Priorita 3: azione fullscreen attiva (esercizio in corso)
    if (_hasFullscreenAction) {
      _setBeat(BeatState.esercizio);
      return;
    }

    // Priorita 4: chiusura sessione
    final hasChiusura = sessionState.currentTurnActions
        .any((a) => a.tipo == 'chiudi_sessione');
    if (hasChiusura) {
      _setBeat(BeatState.chiusura);
      return;
    }

    // Priorita 5: azione appena ricevuta (transizione verso esercizio)
    final hasNewAction = sessionState.currentTurnActions.any(
      (a) => const {'proponi_esercizio', 'mostra_formula', 'suggerisci_backtrack'}
          .contains(a.tipo),
    );
    if (hasNewAction && sessionState.isStreaming) {
      _setBeat(BeatState.attesa);
      return;
    }

    // Priorita 6: tutor sta parlando (streaming)
    if (sessionState.isStreaming) {
      _setBeat(BeatState.spiegazione);
      return;
    }

    // Default: accoglienza (sessione attiva, niente di speciale)
    _setBeat(BeatState.accoglienza);
  }

  void _setBeat(BeatState newBeat) {
    if (state.beat != newBeat) {
      state = BeatProviderState(beat: newBeat, changedAt: DateTime.now());
    }
  }
}
