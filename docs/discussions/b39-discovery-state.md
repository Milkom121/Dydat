# Discovery State — B39 Onboarding Narrativo (Dydat)

## Fase corrente
Fase 3 — Intervista strutturata

## Decisioni già prese (pre-intervista)
- **Scope IN**: ridisegno onboarding narrativo ibrido, estrazione profilo, fix salvataggio profilo (ONB-01), fix persistenza turni (ONB-02), erogazione vera del test di posizionamento (PRE-01).
- **Scope IN aggiunto da Villa**: **dettatura vocale** (non chat vocale completa) — pulsante microfono che apre registrazione, utente parla, chiude, API speech-to-text, trascrizione nel campo testo. Risolve il problema "quarantenne che scrive lento".
- **Scope FUORI**: chat vocale completa bidirezionale (l'AI che parla), Login dev fix (DEV-01 va in altro blocco), rework di B33.5 (va preservato compatibile con lo schema profilo scelto).
- **Scope DA DECIDERE**: modifiche al system prompt del tutor (Villa valuta dopo).
- **Obiettivo finale**: sostituire l'attuale onboarding a questionario strutturato con un flusso narrativo dove l'utente si racconta e l'AI estrae il profilo, per produrre un `profilo_sintetizzato` ricco che B33.5 possa davvero parafrase.

## Gap aperti (da colmare con l'intervista)
Vedi `b39-discovery-notes.md` sezione "Gap".

## File prodotti
- `docs/discussions/b39-discovery-state.md` (questo file)
- `docs/discussions/b39-discovery-notes.md`

## Prossimo passo
Intervista Villa una domanda alla volta, partendo dall'area più strategica (struttura del flusso narrativo), poi voce, poi placement test, poi estrazione, poi edge case.
