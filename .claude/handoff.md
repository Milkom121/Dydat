STATUS: CONTINUE
PHASE: 9
BLOCK: B38
SUMMARY: B37 completato (S34). BeatState enum con 10 stati emotivi dalla mappa emotiva v2. BeatNotifier (Riverpod) calcola il beat corrente dalla sessione con priorita (promozione > esito > fullscreen > chiusura > attesa > streaming > accoglienza) e durate minime per beat transitori. BeatOverlayWidget renderizza gradiente radiale animato sotto il contenuto (opacita 0.03-0.15, mai invasivo). mascotteStateFromBeat() mappa beat->MascotteState secondo tabella direzione visiva. Studio screen integrato: overlay + mascotte reagisce ai beat. 31 nuovi test (3 file), 420 totale frontend, analyze 0.
NEXT: B38 - Mascotte CustomPainter (Fase 9)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: beat_provider.dart (nuovo), beat_overlay_widget.dart (nuovo), studio_screen.dart, session_sync_helper.dart, beat_provider_test.dart (nuovo), beat_overlay_test.dart (nuovo), mascotte_beat_mapping_test.dart (nuovo)
TESTS: PASS (420 frontend, flutter analyze 0)
VERIFICATION: flutter analyze 0, flutter test 420 verdi (da 389 baseline +31 nuovi)

---

## Contesto dettagliato

### Cosa e stato fatto
- Creato beat_provider.dart con enum BeatState (10 stati) e BeatNotifier
- BeatNotifier ascolta sessionProvider e calcola beat con priorita e durate minime
- Creato beat_overlay_widget.dart con gradiente radiale animato per ogni beat
- Integrato BeatOverlayWidget in studio_screen.dart (Positioned.fill sotto contenuto)
- Aggiunto mascotteStateFromBeat() in session_sync_helper.dart
- MascotteWidget ora usa beat per determinare il suo stato (non piu computeMascotteState)
- Studio screen segnala al beatProvider quando azioni fullscreen sono attive/inattive

### Stato del progetto
- 420 test frontend verdi, flutter analyze 0
- Backend invariato (341 test)

### Prossimo passo - B38: Mascotte CustomPainter
1. CustomPainter per forma morbida, organica (blob con curve di Bezier)
2. Occhi espressivi che riflettono il beat corrente
3. Transizioni di forma/espressione per ogni beat
4. Mantenere tap per tools tray
5. Animazione la mascotte ti apre la porta (Beat 1, ingresso sessione)
6. Celebrazione speciale per promozione

### File da leggere
1. CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md, .claude/handoff.md
2. docs/dydat_direzione_visiva_v2.md (sezione 5 Mascotte)
3. frontend/lib/presentation/studio_screen/widgets/mascotte_widget.dart
4. frontend/lib/providers/beat_provider.dart
5. frontend/lib/presentation/studio_screen/widgets/beat_overlay_widget.dart
