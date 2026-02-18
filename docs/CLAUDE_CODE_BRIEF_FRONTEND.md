# Dydat — Brief per Claude Code: Integrazione Frontend

> Data: 18 febbraio 2026
> Priorità: ALTA — prossimo passo del progetto

---

## Cosa è successo

Rocket.new (AI coding agent per Flutter) ha costruito il frontend dell'app seguendo il brief `dydat_brief_rocket_new_v2.md`. Il codice Flutter risultante è stato messo **nella root del progetto**. Non è ancora sotto Git, non è stato testato, non è collegato al backend.

## Cosa devi fare — in ordine

### Passo 0: Inventario (PRIMA DI TUTTO)

Non toccare nulla. Prima capire lo stato:

```bash
# 1. Stato worktree
git worktree list
git status
git log --oneline -5

# 2. Cosa c'è nella root — dove sta il backend, dove sta il codice Flutter
ls -la
# Il codice Flutter di Rocket.new dovrebbe essere visibile (lib/, pubspec.yaml, android/, ios/, ecc.)

# 3. Ispeziona il codice Flutter
# Leggi la struttura prodotta da Rocket.new e confrontala con il brief
find . -name "*.dart" | head -50
cat pubspec.yaml
```

**Riporta al fondatore cosa hai trovato** prima di procedere. Non assumere nulla sulla struttura.

### Passo 1: Riorganizzazione in monorepo

Il progetto deve diventare un monorepo:

```
dydat/
├── backend/          ← codice Python/FastAPI (spostare qui da dove si trova ora)
├── frontend/         ← codice Flutter da Rocket.new (spostare qui)
├── docs/             ← file .md del progetto
├── .gitignore        ← aggiornato per Python + Flutter + .env
└── README.md
```

**REGOLE FERREE:**
- **ZERO commit** finché il fondatore non lo autorizza esplicitamente
- **ZERO push** — il repo resta locale
- **Gestisci i worktree**: verifica quali esistono, cosa contengono, e proponi come consolidarli PRIMA di agire. I worktree attivi non devono rompersi.
- Se la riorganizzazione è complessa, proponi il piano al fondatore e aspetta conferma.

### Passo 2: Analisi del codice Flutter

Rocket.new ha lavorato da un brief. Il codice potrebbe non essere perfetto. Serve un'analisi comparativa:

1. **`flutter pub get`** — le dipendenze si risolvono?
2. **`flutter analyze`** — errori statici?
3. **Struttura cartelle** — corrisponde a quella del brief? (lib/config/, lib/models/, lib/services/, lib/providers/, lib/screens/, lib/widgets/)
4. **Design tokens** — verifica colors.dart, typography.dart, spacing.dart. I valori devono corrispondere a quelli nel brief (darkBackground=#1A1A1E, amber=#D4A843, font=Plus Jakarta Sans, ecc.)
5. **Modelli dati** — i `fromJson` mappano correttamente le response API? Confronta con `dydat_api_reference.md` (la fonte di verità per le API). Attenzione a:
   - `Statistiche`: deve avere 3 periodi innestati (settimana/mese/sempre), ognuno con {minuti_studio, esercizi_svolti, esercizi_corretti, nodi_completati, giorni_attivi}
   - `Achievement`: tipo è `"sigillo" | "medaglia" | "costellazione"` (3 tipi, non 4)
   - `Utente`: `id` è String (UUID), `email` è nullable
   - `Sessione`: `attivitaCorrente` è nullable
6. **Routing** — il flusso /splash → /onboarding → /home → 3 tab funziona?
7. **Placeholder SSE** — sono marcati con `// TODO: Claude Code`? Sono strutturati in modo da poterci lavorare sopra?
8. **Preferenze tutor** — i valori inviati al backend sono corretti? (`"vai_al_sodo"`, `"spiegami_bene"`, `"lascia_decidere"` per velocità; `"molto"`, `"equilibrato"`, `"fatti"` per incoraggiamento)
9. **Gestione errore 409 sessione** — c'è? (quando `/sessione/inizia` ritorna 409 con `{sessione_id_esistente, messaggio}`)
10. **Impostazioni** — le voci senza endpoint backend (Elimina account, Esporta dati, Memoria tutor, Materie attive, Promemoria) sono disabilitate con label "Prossimamente"?

**Riporta i risultati al fondatore**: cosa funziona, cosa no, cosa manca, cosa è diverso dal brief.

### Passo 3: Collegare frontend al backend

Il frontend punta a `http://localhost:8000` (in `api_config.dart` o equivalente). Il backend gira su FastAPI con uvicorn sulla stessa porta.

Testare i flussi in ordine:

| # | Flusso | Endpoint | Cosa verificare |
|---|---|---|---|
| 1 | Health | `GET /health` | Il client HTTP funziona, CORS ok |
| 2 | Registrazione | `POST /auth/registrazione` | JWT ritornato e salvato |
| 3 | Login | `POST /auth/login` → `GET /utente/me` | JWT nell'header, profilo renderizzato |
| 4 | Tab Profilo | `GET /utente/me/statistiche`, `GET /achievement/` | Numeri e badge visibili |
| 5 | Tab Percorso | `GET /percorsi/`, `GET /temi/` | Sentiero con temi renderizzato |
| 6 | Onboarding | `POST /onboarding/inizia` | Almeno la POST parte senza crash (SSE è placeholder) |
| 7 | Sessione | `POST /sessione/inizia` | Almeno la POST parte (SSE è placeholder) |

**Problemi probabili da anticipare:**
- **CORS**: FastAPI potrebbe non avere `CORSMiddleware` configurato per il frontend Flutter in dev. Aggiungere se manca.
- **Android emulator**: usa `10.0.2.2` invece di `localhost`. Potrebbe servire una config condizionale.
- **Errori 422**: FastAPI ritorna `{detail: [{loc, msg, type}]}` per validation error Pydantic, diverso dal formato errore standard. Il frontend potrebbe non gestirli.
- **Campi JSON**: i nomi dei campi nella response reale potrebbero non matchare i `fromJson` del frontend. La fonte di verità è `dydat_api_reference.md`.

---

## Documenti di riferimento

| Documento | Cosa contiene | Quando consultarlo |
|---|---|---|
| `dydat_api_reference.md` | **Fonte di verità** per tutte le API — generata dal codice backend reale | Sempre, per verificare endpoint, payload, errori |
| `dydat_brief_rocket_new_v2.md` | Brief che Rocket.new ha ricevuto — cosa doveva costruire | Per confrontare con cosa ha effettivamente prodotto |
| `dydat_direzione_visiva_v2.md` | Palette, tipografia, mappa emotiva, celebrazioni, mascotte | Per verificare coerenza visiva |
| `dydat_digest.md` | Mappa completa del progetto, tutte le decisioni | Per contesto generale |

---

## Cosa NON fare in questa fase

- NON implementare il client SSE vero — per ora i placeholder bastano
- NON implementare il rendering LaTeX
- NON implementare animazioni o celebrazioni
- NON implementare la mascotte animata
- NON committare o pushare
- NON cambiare il backend (a meno di bug bloccanti come CORS mancante)

L'obiettivo è: **il frontend si avvia, si collega al backend, i dati fluiscono correttamente nelle schermate REST**. Tutto il resto viene dopo.
