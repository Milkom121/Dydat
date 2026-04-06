STATUS: PHASE_COMPLETE
PHASE: 9
BLOCK: B38
SUMMARY: B38 completato (S35). Mascotte evoluta da cerchio ambra a forma organica con CustomPainter. MascottePainter: blob con 8 punti di controllo Bezier cubici, deformazione animata (wobble), gradiente radiale per profondita, glow luminescente esterno. Occhi espressivi: sclera ovale, pupilla con riflesso di luce, apertura controllata da eyeOpenness (linea quando quasi chiusi). MascotteVisuals con lerp() per transizioni smooth 500ms tra stati. EntrancePortalPainter per animazione ingresso sessione (3 cerchi concentrici sfalsati). PromotionBurstPainter per celebrazione promozione (12 raggi + cerchio espansione). Studio screen integrato con showEntrance e showPromotionBurst. 28 nuovi test (2 file), 448 totale frontend, analyze 0. Fase 9 (Atmosfera e Mascotte) COMPLETATA.
NEXT: B39 - Onboarding con Momento Wow (Fase 10)
DECISIONS_NEEDED: PR develop->main per chiusura Fase 9? (da confermare con Villa)
FILES_MODIFIED: mascotte_painter.dart (nuovo), mascotte_widget.dart (riscrittura), studio_screen.dart, docs/dev-shortcuts.md, mascotte_painter_test.dart (nuovo), mascotte_widget_test.dart (nuovo)
TESTS: PASS (448 frontend, flutter analyze 0)
VERIFICATION: flutter analyze 0, flutter test 448 verdi (da 420 baseline +28 nuovi). Backend invariato (341 test).

---

## Contesto dettagliato

### Cosa e stato fatto
- Creato mascotte_painter.dart con 3 CustomPainter:
  - MascottePainter: blob organico (Bezier cubiche, 8 punti), glow radiale, occhi espressivi
  - PromotionBurstPainter: 12 raggi di luce + cerchio espansione per promozione
  - EntrancePortalPainter: 3 cerchi concentrici sfalsati per ingresso sessione
- Creato MascotteVisuals: parametri visivi interpolabili (blobDeformation, scale, eyeOpenness, pupilOffsetY, glowRadius, glowOpacity)
- visualsForState() mappa MascotteState -> MascotteVisuals secondo direzione visiva v2
- Riscritto mascotte_widget.dart: usa CustomPaint con MascottePainter, TickerProviderStateMixin per animazioni multiple (pulse, wobble, transition, entrance, promotion)
- Transizioni animate 500ms tra stati con MascotteVisuals.lerp()
- Animazione ingresso (elasticOut 1000ms): mascotte scala da 0 a 1.0 con bounce
- Studio screen: _showMascotteEntrance e _showPromotionBurst integrati
- Registrato colore pupilla hardcoded in dev-shortcuts.md

### Stato del progetto
- 448 test frontend verdi, flutter analyze 0
- Backend invariato (341 test)
- Fase 9 completata (B36 Superfici + B37 Beat + B38 Mascotte)

### Prossimo passo - B39: Onboarding con Momento Wow (Fase 10)
1. Momento wow (30-60s): domanda curiosa + visualizzazione animata
2. Domande rapide: eta, cosa studi, perche sei qui (scelta multipla)
3. Poi il flusso attuale (conversazione tutor + costruzione percorso)
4. Registrazione alla fine, non all'inizio
5. La mascotte compare qui per la prima volta

### File da leggere
1. CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md, .claude/handoff.md
2. docs/dydat-ux-redesign-concept-v1.1.docx (sezione 4 Onboarding)
3. frontend/lib/presentation/onboarding/ (flusso onboarding attuale)
4. frontend/lib/presentation/studio_screen/widgets/mascotte_widget.dart (mascotte evoluta)
5. frontend/lib/presentation/studio_screen/widgets/mascotte_painter.dart (painters)
