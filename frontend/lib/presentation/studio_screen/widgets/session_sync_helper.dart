import 'package:flutter/material.dart';

import '../../../models/sse_events.dart';
import '../../../providers/session_provider.dart';
import './achievement_toast_widget.dart';
import './celebration_overlay.dart';
import './mascotte_widget.dart';

/// Tiene i contatori di sincronizzazione e lo stato celebration per la sessione.
/// Sostituisce i 6 campi separati in _StudioScreenState.
class SessionSyncState {
  int tutorCount;
  int actionsCount;
  int achievementsCount;
  EsitoEsercizioEvent? lastTriggeredEsito;
  PromozioneEvent? lastTriggeredPromotion;
  DateTime? lastCelebrationTime;

  SessionSyncState()
      : tutorCount = 0,
        actionsCount = 0,
        achievementsCount = 0;
}

/// Sincronizza messaggi tutor, azioni e achievement dal [sessionState] nella lista
/// [messages]. Aggiorna i contatori in [syncState] e mostra overlay/toast via callbacks.
void syncTutorMessages({
  required SessionScreenState sessionState,
  required List<Map<String, dynamic>> messages,
  required SessionSyncState syncState,
  required bool mounted,
  required BuildContext context,
  required VoidCallback onScrollToBottom,
  required VoidCallback onClearEsito,
  required VoidCallback onClearPromotion,
}) {
  final tutorMessages = sessionState.tutorMessages;
  if (tutorMessages.length > syncState.tutorCount) {
    for (int i = syncState.tutorCount; i < tutorMessages.length; i++) {
      messages.add({
        'type': 'tutor',
        'sender': 'tutor',
        'content': tutorMessages[i],
        'timestamp': DateTime.now(),
        'isStreaming': false,
      });
    }
    syncState.tutorCount = tutorMessages.length;
    onScrollToBottom();
  }

  final actions = sessionState.currentTurnActions;
  if (actions.length > syncState.actionsCount) {
    for (int i = syncState.actionsCount; i < actions.length; i++) {
      final action = actions[i];
      final itemType = switch (action.tipo) {
        'proponi_esercizio' => 'exercise',
        'mostra_formula' => 'formula',
        'suggerisci_backtrack' => 'backtrack',
        'chiudi_sessione' => 'chiudi',
        _ => null,
      };
      if (action.tipo == 'proponi_esercizio') {
        final ex = action.asProponiEsercizio;
        if (ex != null && ex.nessunoDisponibile) continue;
      }
      if (itemType != null) {
        messages.add({'type': itemType, 'data': action, 'timestamp': DateTime.now()});
      }
    }
    syncState.actionsCount = actions.length;
    onScrollToBottom();
  }

  final achievements = sessionState.currentTurnAchievements;
  if (achievements.length > syncState.achievementsCount) {
    for (int i = syncState.achievementsCount; i < achievements.length; i++) {
      final achievement = achievements[i];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showAchievementToast(context, achievement);
      });
    }
    syncState.achievementsCount = achievements.length;
  }

  final esito = sessionState.latestEsito;
  if (esito != null && esito != syncState.lastTriggeredEsito) {
    syncState.lastTriggeredEsito = esito;
    if (esito.corretto) syncState.lastCelebrationTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showCelebrationOverlay(context, esito);
        onClearEsito();
      }
    });
  }

  final promotion = sessionState.latestPromotion;
  if (promotion != null && promotion != syncState.lastTriggeredPromotion) {
    syncState.lastTriggeredPromotion = promotion;
    syncState.lastCelebrationTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showPromotionCelebration(context, promotion);
        onClearPromotion();
      }
    });
  }
}

/// Calcola lo stato visivo della mascotte in base alla sessione corrente.
MascotteState computeMascotteState(
  SessionScreenState sessionState,
  DateTime? lastCelebrationTime,
) {
  final session = sessionState.activeSession;
  final isActive = session != null && session.stato == 'attiva';
  if (!isActive) return MascotteState.sleeping;
  if (lastCelebrationTime != null &&
      DateTime.now().difference(lastCelebrationTime) < const Duration(seconds: 3)) {
    return MascotteState.celebrating;
  }
  if (sessionState.isStreaming) return MascotteState.thinking;
  return MascotteState.idle;
}
