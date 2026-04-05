STATUS: CONTINUE
PHASE: 5
BLOCK: B26
SUMMARY: Blocco 4.5.3 completato (S22). iconMap reso static const in custom_icon_widget.dart. studio_screen.dart ridotto da 1207 a 480 righe con split in 6 nuovi file. Fase 4.5 COMPLETATA.
NEXT: Blocco B26 — Algoritmo FSRS (Backend)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: frontend/lib/widgets/custom_icon_widget.dart, frontend/lib/presentation/studio_screen/studio_screen.dart, +6 nuovi widget in presentation/studio_screen/widgets/
TESTS: PASS (210 frontend, flutter analyze 0 issues)
VERIFICATION: flutter analyze 0 issues, flutter test 210/210, studio_screen.dart 480 righe, iconMap static const verificato

---

## Contesto dettagliato

### Cosa e stato fatto
- custom_icon_widget.dart: iconMap spostato da build() a static const a livello di classe (9000+ voci, elimina ricreazione ad ogni rebuild)
- studio_screen.dart: da 1207 a 480 righe tramite split in:
  - chat_view_widget.dart: messaggi, streaming bubble, typing indicator, amber cursor, _buildChatItem
  - home_view_widget.dart: vista home con storico sessioni
  - session_header_widget.dart: header nodo corrente + bottoni Inizia/Riprendi
  - session_input_bar_widget.dart: barra input messaggi (StatefulWidget per colore bottone send)
  - session_sync_helper.dart: SessionSyncState + syncTutorMessages() + computeMascotteState()
  - studio_dialogs.dart: showResumeSessionDialog() + showEndSessionDialog()
- Commit: bbf1a1a su develop

### Stato del progetto
- Backend: COMPLETO e STABILE (282 test)
- Frontend: Fase 4.5 COMPLETA (480 righe studio_screen, 210 test verdi, analyze 0 issues)
- Branch: develop
- Docker: verificare avvio prima di lavorare sul backend (cd backend && docker compose up -d)

### Prossimo passo concreto
Blocco B26 — Algoritmo FSRS Backend:
1. Aggiungere libreria fsrs a backend/requirements.txt e rebuild Docker
2. Creare backend/app/grafo/fsrs.py con calcola_prossimo_ripasso() e get_nodi_da_ripassare()
3. Integrare in elaborazione.py dopo update contatori esercizio
4. Gate: FSRS implementato, campi SR aggiornati dopo esercizi, get_nodi_da_ripassare funziona, pytest verde

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (sezione Fase 5, B26)
4. .claude/handoff.md
5. backend/app/grafo/ (struttura grafo esistente)
6. backend/app/core/elaborazione.py (dove integrare FSRS)
7. docs/dydat_api_reference.md (campi SR esistenti)
