# Status Checkpoint — Dydat Frontend

> Aggiornato da ogni sessione. La sessione successiva legge questo per sapere da dove partire.

## Stato Corrente

**Ultimo aggiornamento**: 2026-02-18
**Ultima sessione**: S0 (setup iniziale)
**Branch attivo**: main
**Prossima sessione**: S1 (Blocchi 1+2)

## Blocchi Completati

| Blocco | Stato | Sessione | Note |
|--------|-------|----------|------|
| B0 — Setup monorepo | DONE | S0 | Monorepo creato, sizer sostituito con sizer_extensions.dart |
| B1 — Dipendenze + Config | TODO | S1 | |
| B2 — Modelli dati | TODO | S1 | |
| B3 — Servizi API | TODO | S2 | |
| B4 — Provider Riverpod | TODO | S2 | |
| B5 — GoRouter + Shell | TODO | S3 | |
| B6 — Schermate Auth | TODO | S4 | |
| B7 — Tab Percorso | TODO | S4 | |
| B8 — Tab Profilo | TODO | S5 | |
| B9 — Tab Studio | TODO | S5 | |
| B10 — Test E2E | TODO | S6 | |

## Problemi Aperti

- `flutter analyze` ha 6 warning pre-esistenti (variabili non usate, dead code) — non bloccanti
- `custom_error_widget.dart` ha colori hardcoded — da fixare in futuro
- Profilo screen non esiste ancora (referenziato in routing ma non implementato)

## Cosa Esiste Gia

### UI funzionante (da Rocket.new)
- Theme completo (light + dark, 690 righe)
- SplashScreen, OnboardingScreen, LoginScreen, RegistrationScreen
- LearningPathScreen + widget (tema_card, tema_detail, empty_state)
- StudioScreen + widget (exercise, formula, backtrack, mascotte, tools_tray, tutor_message, tutor_panel)
- CustomAppBar (3 varianti), CustomBottomBar (3 tab), CustomImageWidget, CustomIconWidget

### Architettura assente
- Zero modelli Dart
- Zero servizi API
- Zero provider Riverpod
- Zero GoRouter (solo route statiche)
- Zero flutter_secure_storage
- Tutto hardcodato con dati finti

## Decisioni Prese

| Data | Decisione | Motivo |
|------|-----------|--------|
| 2026-02-18 | Sostituito sizer con sizer_extensions.dart custom | sizer ^2.0.15 incompatibile con Flutter 3.41/Dart 3.11 |
| 2026-02-18 | Rimossi web e universal_html dal pubspec | Non necessari per app mobile, causavano conflitti |
| 2026-02-18 | Rimosso wrapper Sizer() da main.dart | Non necessario con estensioni custom |
| 2026-02-18 | Pipeline 6 sessioni da 1-2 blocchi | Preservare contesto pulito per ogni sessione |
