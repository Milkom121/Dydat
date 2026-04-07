# Tono di Voce — Dydat

> Guida per la coerenza dei testi UI nell'app Dydat.
> Ultimo aggiornamento: 2026-04-07 (audit B35.11)

---

## Principi generali

1. **Dare del "tu"** — sempre informale, mai "Lei". Lo studente e un amico che aiutiamo.
2. **Tono caldo e incoraggiante** — nessun senso di colpa, nessun linguaggio punitivo.
3. **Italiano naturale** — evitare inglesismi quando esiste un equivalente italiano diffuso.
4. **Breve e chiaro** — frasi corte, verbi attivi, nessun gergo tecnico visibile all'utente.

---

## Terminologia standard

| Concetto | Termine UI | NON usare |
|----------|-----------|-----------|
| Giorni consecutivi di studio | **Serie** | Streak |
| Obiettivi/premi sbloccati | **Traguardi** | Achievement, Badge |
| Percorso di apprendimento | **Percorso** | Path, Learning path |
| Argomento del grafo | **Nodo** | Node |
| Gruppo di nodi | **Tema** | Topic |
| Sessione di studio | **Sessione** | Session |
| Ripetizione spaziata | **Ripasso** | Review, Spaced repetition |
| Assistente didattico | **Tutor** | Tutor (ok, universale) |
| Quaderno per nodo | **Quaderno** | Notebook |
| Indirizzo email | **Email** | (ok, universale in italiano) |
| Chiave di accesso | **Password** | (ok, universale in italiano) |
| Pagina iniziale | **Home** | (ok, universale in italiano) |

---

## Parole accettate in inglese

Alcuni termini inglesi sono talmente diffusi in italiano da non richiedere traduzione:

- **Email** — "Indirizzo email" solo se serve disambiguare
- **Password** — universale
- **Home** — usato come label nella bottom bar
- **Tutor** — usato anche in contesti educativi italiani

---

## Messaggi di errore

- Mai mostrare nomi di eccezioni (DioException, FormatException, ecc.)
- Mai mostrare codici HTTP (404, 500, ecc.)
- Usare `userFriendlyError()` da `utils/error_messages.dart`
- Tono: empatico, propositivo ("Qualcosa non ha funzionato. Riprova tra poco.")

---

## Bottoni e azioni

| Azione | Testo |
|--------|-------|
| Conferma primaria | **Inizia**, **Vai**, **Invia**, **Verifica** |
| Conferma secondaria | **Riprova**, **Riprendi** |
| Annullamento | **Annulla**, **Salta** |
| Uscita | **Esci**, **Termina** |
| Navigazione indietro | **Torna alla home** |

---

## Schermate vuote (empty states)

- Tono positivo e propositivo, mai "Non hai nulla"
- Suggerire la prossima azione ("Completa la tua prima sessione per...")
- Icona tematica + testo caldo

---

## Audit B35.11 — Fix applicati

| File | Prima | Dopo |
|------|-------|------|
| profile_screen.dart (stats) | `'Streak'` | `'Serie'` |
| profile_screen.dart (sezione) | `'Achievement'` | `'Traguardi'` |
| recap_session_screen.dart (stats) | `'Streak'` | `'Serie'` |

### Verifiche positive (nessun fix necessario)

- Uso coerente del "tu" in tutta l'app
- Messaggi errore gia in italiano tramite `userFriendlyError()`
- Empty states gia gestiti (B35.6)
- Terminologia nodi/sessioni/percorsi coerente
- Bottom bar: "Home", "I miei studi", "Profilo" — ok
- Form labels: Email, Password — universali, ok
