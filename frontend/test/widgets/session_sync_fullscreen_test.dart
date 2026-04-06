/// Test B32 — syncTutorMessages: verifica che azioni fullscreen vengano deviate al callback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sse_events.dart';
import 'package:dydat/providers/session_provider.dart';
import 'package:dydat/presentation/studio_screen/widgets/session_sync_helper.dart';

void main() {
  group('syncTutorMessages — fullscreen callback', () {
    testWidgets('azione esercizio viene deviata a onShowFullscreen', (tester) async {
      final messages = <Map<String, dynamic>>[];
      final syncState = SessionSyncState();
      final fullscreenCalls = <(String, AzioneEvent)>[];

      final sessionState = SessionScreenState(
        tutorMessages: const [],
        currentTurnActions: [
          const AzioneEvent(
            tipo: 'proponi_esercizio',
            params: {'testo': 'Calcola 5+3', 'difficolta': 2, 'esercizio_id': 'e1'},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            syncTutorMessages(
              sessionState: sessionState,
              messages: messages,
              syncState: syncState,
              mounted: true,
              context: context,
              onScrollToBottom: () {},
              onClearEsito: () {},
              onClearPromotion: () {},
              onShowFullscreen: (type, action) => fullscreenCalls.add((type, action)),
            );
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      // L'esercizio NON deve finire nei messaggi inline
      expect(messages.where((m) => m['type'] == 'exercise').length, 0);
      // Deve essere stato passato al callback fullscreen
      expect(fullscreenCalls.length, 1);
      expect(fullscreenCalls.first.$1, 'exercise');
    });

    testWidgets('azione chiudi_sessione resta inline', (tester) async {
      final messages = <Map<String, dynamic>>[];
      final syncState = SessionSyncState();
      final fullscreenCalls = <(String, AzioneEvent)>[];

      final sessionState = SessionScreenState(
        tutorMessages: const [],
        currentTurnActions: [
          const AzioneEvent(
            tipo: 'chiudi_sessione',
            params: {'riepilogo': 'Ottimo lavoro!'},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            syncTutorMessages(
              sessionState: sessionState,
              messages: messages,
              syncState: syncState,
              mounted: true,
              context: context,
              onScrollToBottom: () {},
              onClearEsito: () {},
              onClearPromotion: () {},
              onShowFullscreen: (type, action) => fullscreenCalls.add((type, action)),
            );
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      // chiudi_sessione resta inline
      expect(messages.where((m) => m['type'] == 'chiudi').length, 1);
      // Non deve andare al fullscreen
      expect(fullscreenCalls.length, 0);
    });

    testWidgets('azione formula viene deviata a onShowFullscreen', (tester) async {
      final messages = <Map<String, dynamic>>[];
      final syncState = SessionSyncState();
      final fullscreenCalls = <(String, AzioneEvent)>[];

      final sessionState = SessionScreenState(
        tutorMessages: const [],
        currentTurnActions: [
          const AzioneEvent(
            tipo: 'mostra_formula',
            params: {'latex': 'x^2', 'etichetta': 'Quadrato'},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            syncTutorMessages(
              sessionState: sessionState,
              messages: messages,
              syncState: syncState,
              mounted: true,
              context: context,
              onScrollToBottom: () {},
              onClearEsito: () {},
              onClearPromotion: () {},
              onShowFullscreen: (type, action) => fullscreenCalls.add((type, action)),
            );
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(messages.where((m) => m['type'] == 'formula').length, 0);
      expect(fullscreenCalls.length, 1);
      expect(fullscreenCalls.first.$1, 'formula');
    });

    testWidgets('azione backtrack viene deviata a onShowFullscreen', (tester) async {
      final messages = <Map<String, dynamic>>[];
      final syncState = SessionSyncState();
      final fullscreenCalls = <(String, AzioneEvent)>[];

      final sessionState = SessionScreenState(
        tutorMessages: const [],
        currentTurnActions: [
          const AzioneEvent(
            tipo: 'suggerisci_backtrack',
            params: {'nodo_id': 'n1', 'motivo': 'Ripassare frazioni'},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            syncTutorMessages(
              sessionState: sessionState,
              messages: messages,
              syncState: syncState,
              mounted: true,
              context: context,
              onScrollToBottom: () {},
              onClearEsito: () {},
              onClearPromotion: () {},
              onShowFullscreen: (type, action) => fullscreenCalls.add((type, action)),
            );
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(messages.where((m) => m['type'] == 'backtrack').length, 0);
      expect(fullscreenCalls.length, 1);
      expect(fullscreenCalls.first.$1, 'backtrack');
    });

    testWidgets('senza callback onShowFullscreen le azioni restano inline (retrocompat)', (tester) async {
      final messages = <Map<String, dynamic>>[];
      final syncState = SessionSyncState();

      final sessionState = SessionScreenState(
        tutorMessages: const [],
        currentTurnActions: [
          const AzioneEvent(
            tipo: 'proponi_esercizio',
            params: {'testo': 'Test', 'difficolta': 1, 'esercizio_id': 'e2'},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            syncTutorMessages(
              sessionState: sessionState,
              messages: messages,
              syncState: syncState,
              mounted: true,
              context: context,
              onScrollToBottom: () {},
              onClearEsito: () {},
              onClearPromotion: () {},
              // Nessun onShowFullscreen: fallback inline
            );
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      // L'azione deve restare inline come prima
      expect(messages.where((m) => m['type'] == 'exercise').length, 1);
    });

    testWidgets('esercizio nessunoDisponibile viene saltato', (tester) async {
      final messages = <Map<String, dynamic>>[];
      final syncState = SessionSyncState();
      final fullscreenCalls = <(String, AzioneEvent)>[];

      final sessionState = SessionScreenState(
        tutorMessages: const [],
        currentTurnActions: [
          const AzioneEvent(
            tipo: 'proponi_esercizio',
            params: {'nessun_esercizio_disponibile': true},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            syncTutorMessages(
              sessionState: sessionState,
              messages: messages,
              syncState: syncState,
              mounted: true,
              context: context,
              onScrollToBottom: () {},
              onClearEsito: () {},
              onClearPromotion: () {},
              onShowFullscreen: (type, action) => fullscreenCalls.add((type, action)),
            );
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(messages.length, 0);
      expect(fullscreenCalls.length, 0);
    });
  });
}
