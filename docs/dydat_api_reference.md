# Dydat API Reference

> **Generato dal codice sorgente** — worktree `nostalgic-hertz` (working directory, post-fix).
> Questo documento descrive l'implementazione reale, non il design originale.
> Data generazione: 2026-02-18

**Base URL**: `http://<host>:8000`
**API prefix**: nessun prefisso `/api/v1` — i router montano direttamente su `/auth`, `/utente`, ecc.

---

## Indice

1. [Autenticazione](#1-autenticazione)
2. [Endpoint](#2-endpoint)
   - [Health](#health)
   - [Auth](#auth)
   - [Utente](#utente)
   - [Onboarding](#onboarding)
   - [Sessione](#sessione)
   - [Percorsi](#percorsi)
   - [Temi](#temi)
   - [Achievement](#achievement)
3. [Eventi SSE](#3-eventi-sse)
4. [Schema Dati Sintetico](#4-schema-dati-sintetico)
5. [Flussi E2E](#5-flussi-e2e)
6. [Note per il Frontend](#6-note-per-il-frontend)
7. [Discrepanze](#7-discrepanze)

---

## 1. Autenticazione

### Come funziona

Il sistema usa **JWT (HS256)** tramite la libreria `python-jose`.

- **Hashing password**: bcrypt diretto (non passlib)
- **Algoritmo JWT**: HS256
- **Claim nel token**: `sub` = UUID utente (stringa), `exp` = scadenza
- **Scadenza token**: **720 ore** (30 giorni) — configurabile via `JWT_EXPIRE_HOURS`
- **Secret**: variabile d'ambiente `JWT_SECRET` (default: `"change-me-in-production"`)

### Come ottenere il JWT

1. **Registrazione** → `POST /auth/registrazione` → ritorna `access_token`
2. **Login** → `POST /auth/login` → ritorna `access_token`

### Header Authorization

```
Authorization: Bearer <token>
```

Il middleware (`app/api/deps.py:get_utente_corrente`) verifica:
1. L'header inizia con `"Bearer "`
2. Il token è decodificabile e non scaduto
3. Il claim `sub` contiene un UUID valido
4. L'utente esiste nel database

### Errori autenticazione

| Situazione | Status | Detail |
|---|---|---|
| Header mancante | 422 | (FastAPI validation: field required) |
| Formato sbagliato (no "Bearer ") | 401 | `"Formato Authorization non valido"` |
| Token scaduto/invalido | 401 | `"Token non valido"` |
| UUID nel token non parsabile | 401 | `"Token non valido"` |
| Utente non trovato nel DB | 401 | `"Utente non trovato"` |

### Endpoint che NON richiedono auth

- `GET /health`
- `POST /auth/registrazione`
- `POST /auth/login`
- `POST /onboarding/inizia`
- `POST /onboarding/turno`
- `POST /onboarding/completa`

Tutti gli altri endpoint richiedono il header `Authorization: Bearer <token>`.

---

## 2. Endpoint

---

### Health

#### GET /health

**Descrizione**: Health check dell'applicazione.

**Autenticazione**: non richiesta

**Response 200**:
```json
{
  "status": "ok"
}
```

---

### Auth

#### POST /auth/registrazione

**Descrizione**: Registra un nuovo utente e ritorna un JWT. Se `utente_temp_id` è fornito, converte l'utente temporaneo (creato durante l'onboarding) in utente registrato — tutti i dati (percorso, sessioni, stato nodi) restano collegati allo stesso UUID.

**Autenticazione**: non richiesta

**Request body**:
```json
{
  "email": "string — email valida (EmailStr Pydantic)",
  "password": "string — password in chiaro",
  "nome": "string — nome dell'utente",
  "utente_temp_id": "uuid | null — ID utente temporaneo da convertire (opzionale, default null)"
}
```

**Response 201**:
```json
{
  "access_token": "string — JWT token",
  "token_type": "bearer"
}
```

**Errori (flusso standard, senza utente_temp_id)**:
- 409: `"Email gia' registrata"` — l'email esiste già nel database
- 422: Validation error Pydantic — campi mancanti o email malformata

**Errori (flusso conversione, con utente_temp_id)**:
- 404: `"Utente temporaneo non trovato"` — l'UUID fornito non esiste
- 400: `"Utente gia' registrato"` — l'utente ha già un'email (non è temporaneo)
- 409: `"Email gia' registrata"` — l'email è già usata da un altro utente
- 422: Validation error Pydantic — campi mancanti o email malformata

---

#### POST /auth/login

**Descrizione**: Login con email e password, ritorna un JWT.

**Autenticazione**: non richiesta

**Request body**:
```json
{
  "email": "string — email registrata (EmailStr)",
  "password": "string — password in chiaro"
}
```

**Response 200**:
```json
{
  "access_token": "string — JWT token",
  "token_type": "bearer"
}
```

**Errori**:
- 401: `"Credenziali non valide"` — email non trovata O password errata
- 422: Validation error Pydantic — campi mancanti o email malformata

---

### Utente

#### GET /utente/me

**Descrizione**: Ritorna il profilo dell'utente autenticato.

**Autenticazione**: richiesta

**Response 200**:
```json
{
  "id": "uuid — UUID dell'utente",
  "email": "string | null — email (null per utenti temporanei)",
  "nome": "string | null — nome",
  "preferenze_tutor": "dict | null — es. {\"input\": \"voce\", \"velocita\": \"lento\"}",
  "contesto_personale": "dict | null — info raccolte durante onboarding",
  "materie_attive": "list[string] | null — es. [\"matematica\"]",
  "obiettivo_giornaliero_min": "int — minuti/giorno, default 20"
}
```

---

#### PUT /utente/me/preferenze

**Descrizione**: Aggiorna le preferenze del tutor. Merge incrementale con le preferenze esistenti.

**Autenticazione**: richiesta

**Request body** (tutti i campi opzionali):
```json
{
  "input": "string | null — tipo di input preferito",
  "velocita": "string | null — velocità del tutor",
  "incoraggiamento": "string | null — livello di incoraggiamento"
}
```

**Response 200**: stesso formato di `GET /utente/me`

**Errori**:
- 400: messaggio variabile (da `ValueError` di `aggiorna_profilo`) — campo non ammesso o utente non trovato

---

#### GET /utente/me/statistiche

**Descrizione**: Statistiche aggregate dell'utente: settimana, mese, sempre.

**Autenticazione**: richiesta

**Response 200**:
```json
{
  "streak": "int — giorni consecutivi con obiettivo raggiunto",
  "nodi_completati": "int — totale nodi a livello operativo (non presunti)",
  "sessioni_completate": "int — totale sessioni con stato=completata",
  "settimana": {
    "minuti_studio": "int",
    "esercizi_svolti": "int",
    "esercizi_corretti": "int",
    "nodi_completati": "int",
    "giorni_attivi": "int"
  },
  "mese": {
    "minuti_studio": "int",
    "esercizi_svolti": "int",
    "esercizi_corretti": "int",
    "nodi_completati": "int",
    "giorni_attivi": "int"
  },
  "sempre": {
    "minuti_studio": "int",
    "esercizi_svolti": "int",
    "esercizi_corretti": "int",
    "nodi_completati": "int",
    "giorni_attivi": "int"
  }
}
```

---

### Onboarding

L'onboarding NON richiede autenticazione. Il flusso crea un utente temporaneo e usa il `sessione_id` come identificativo.

#### POST /onboarding/inizia

**Descrizione**: Crea utente temporaneo + sessione onboarding + primo turno SSE.

**Autenticazione**: non richiesta

**Request body**: nessuno

**Response**: `text/event-stream` (SSE)

Il primo evento è `onboarding_iniziato`, seguito dagli eventi del primo turno tutor (vedi [sezione SSE](#3-eventi-sse)).

---

#### POST /onboarding/turno

**Descrizione**: Invia un messaggio studente durante l'onboarding. Risposta in SSE streaming.

**Autenticazione**: non richiesta

**Request body**:
```json
{
  "sessione_id": "uuid — ID sessione onboarding",
  "messaggio": "string — testo del messaggio studente"
}
```

**Response**: `text/event-stream` (SSE) — eventi del turno tutor

**Errori**:
- 404: `"Sessione non trovata"` — sessione_id non esiste
- 400: `"Non è una sessione onboarding"` — il tipo sessione non è "onboarding"
- 400: `"Sessione onboarding non attiva (stato=<stato>)"` — sessione non in stato "attiva"

---

#### POST /onboarding/completa

**Descrizione**: Finalizza l'onboarding — salva profilo, crea percorso, inizializza stato nodi.

**Autenticazione**: non richiesta

**Request body**:
```json
{
  "sessione_id": "uuid — ID sessione onboarding",
  "contesto_personale": "dict | null — info sul profilo studente",
  "preferenze_tutor": "dict | null — preferenze di interazione"
}
```

**Response 200**:
```json
{
  "percorso_id": "int — ID del percorso creato",
  "nodo_iniziale": "string | null — ID nodo di partenza personalizzato (se trovato)",
  "nodi_inizializzati": "int — numero di nodi inizializzati in stato_nodi_utente"
}
```

**Errori**:
- 404: `"Sessione non trovata"` — sessione_id non esiste
- 400: `"Non è una sessione onboarding"` — tipo sessione sbagliato
- 400: `"Sessione onboarding non attiva (stato=<stato>)"` — sessione non attiva
- 404: `"Utente non trovato"` — utente associato alla sessione non esiste

---

### Sessione

#### POST /sessione/inizia

**Descrizione**: Avvia una sessione di studio. Riprende automaticamente una sessione sospesa se presente. Sceglie il nodo focale (nodo in_corso → path planner). Ritorna SSE streaming.

**Autenticazione**: richiesta

**Request body** (opzionale — il body può essere omesso):
```json
{
  "tipo": "string — default 'media'",
  "durata_prevista_min": "int | null — durata prevista in minuti"
}
```

**Response**: `text/event-stream` (SSE)

Il primo evento è `sessione_creata`, seguito dagli eventi del primo turno tutor.

**Errori**:
- 409: corpo strutturato — sessione attiva con meno di 5 minuti di inattività:
```json
{
  "sessione_id_esistente": "uuid — ID della sessione attiva",
  "messaggio": "Sessione attiva esistente con meno di 5 minuti di inattività"
}
```

**Nota**: se la sessione attiva ha > 5 minuti di inattività (calcolata dall'ultimo turno di conversazione, non dalla creazione sessione), viene auto-sospesa e si crea una nuova sessione normalmente.

---

#### POST /sessione/{sessione_id}/turno

**Descrizione**: Messaggio studente → SSE stream risposta tutor.

**Autenticazione**: richiesta

**Path params**: `sessione_id` (uuid)

**Request body**:
```json
{
  "messaggio": "string — testo del messaggio studente"
}
```

**Response**: `text/event-stream` (SSE) — eventi del turno tutor

**Errori**:
- 404: `"Sessione non trovata"` — sessione non esiste o non appartiene all'utente
- 400: `"Sessione non attiva (stato=<stato>)"` — sessione non in stato "attiva"

---

#### POST /sessione/{sessione_id}/sospendi

**Descrizione**: Sospende la sessione salvando lo stato orchestratore.

**Autenticazione**: richiesta

**Path params**: `sessione_id` (uuid)

**Request body**: nessuno

**Response 200**:
```json
{
  "id": "uuid",
  "stato": "sospesa",
  "tipo": "string | null",
  "nodo_focale_id": "string | null",
  "nodo_focale_nome": "string | null",
  "attivita_corrente": "string | null",
  "durata_prevista_min": "int | null",
  "durata_effettiva_min": "int | null",
  "nodi_lavorati": "list[string] | null"
}
```

**Errori**:
- 404: `"Sessione non trovata"` — sessione non esiste o non appartiene all'utente
- 400: `"Sessione <id> non è attiva (stato=<stato>)"` — sessione non è in stato "attiva"

---

#### POST /sessione/{sessione_id}/termina

**Descrizione**: Termina la sessione. Aggiorna statistiche giornaliere e verifica achievement.

**Autenticazione**: richiesta

**Path params**: `sessione_id` (uuid)

**Request body**: nessuno

**Response 200**: stesso formato di `/sospendi` con `stato: "completata"`

**Errori**:
- 404: `"Sessione non trovata"` — sessione non esiste o non appartiene all'utente
- 400: `"Sessione <id> non può essere terminata (stato=<stato>)"` — stato non è "attiva" o "sospesa"

**Nota**: dopo la terminazione il backend esegue `aggiorna_statistiche_giornaliere` e `verifica_achievement` in modo non bloccante (errori loggati ma non propagati al client).

---

#### GET /sessione/{sessione_id}

**Descrizione**: Legge lo stato corrente di una sessione.

**Autenticazione**: richiesta

**Path params**: `sessione_id` (uuid)

**Response 200**:
```json
{
  "id": "uuid",
  "stato": "string — attiva | sospesa | completata",
  "tipo": "string | null — media | onboarding",
  "nodo_focale_id": "string | null — ID nodo nel grafo",
  "nodo_focale_nome": "string | null — nome leggibile del nodo",
  "attivita_corrente": "string | null — spiegazione | esercizio | feynman | ripasso_sr",
  "durata_prevista_min": "int | null",
  "durata_effettiva_min": "int | null",
  "nodi_lavorati": "list[string] | null — ID nodi completati in questa sessione"
}
```

**Errori**:
- 404: `"Sessione non trovata"` — sessione non esiste o non appartiene all'utente

---

### Percorsi

#### GET /percorsi/

**Descrizione**: Lista percorsi dell'utente autenticato.

**Autenticazione**: richiesta

**Response 200**:
```json
[
  {
    "id": "int — ID auto-increment",
    "tipo": "string — es. 'binario_1'",
    "materia": "string — es. 'matematica'",
    "nome": "string | null — es. 'Percorso Matematica'",
    "stato": "string — 'attivo'",
    "nodo_iniziale_override": "string | null — ID nodo personalizzato",
    "created_at": "string | null — ISO 8601"
  }
]
```

---

#### GET /percorsi/{percorso_id}/mappa

**Descrizione**: Mappa nodi del percorso con stato utente per visualizzazione mappa.

**Autenticazione**: richiesta

**Path params**: `percorso_id` (int)

**Response 200**:
```json
{
  "percorso_id": "int",
  "materia": "string",
  "nodo_iniziale_override": "string | null",
  "nodi": [
    {
      "id": "string — ID nodo nel grafo",
      "nome": "string — nome leggibile",
      "tipo": "string — standard",
      "tema_id": "string | null — ID del tema associato",
      "livello": "string — non_iniziato | in_corso | operativo | comprensivo | connesso",
      "presunto": "bool — true se livello presunto (skip da onboarding)",
      "spiegazione_data": "bool — true se la spiegazione è stata completata",
      "esercizi_completati": "int — numero esercizi completati su questo nodo"
    }
  ]
}
```

**Errori**:
- 404: `"Percorso non trovato"` — percorso non esiste o non appartiene all'utente

**Nota**: ritorna **tutti i nodi operativi** (no tipo_nodo="contesto"), non solo quelli del percorso specifico. La query non filtra per materia/percorso.

---

### Temi

#### GET /temi/

**Descrizione**: Lista tutti i temi con progresso sintetico dell'utente.

**Autenticazione**: richiesta

**Response 200**:
```json
[
  {
    "id": "string — ID del tema",
    "nome": "string — nome leggibile",
    "materia": "string — es. 'matematica'",
    "descrizione": "string | null",
    "nodi_totali": "int — nodi operativi nel tema",
    "nodi_completati": "int — nodi a livello operativo dell'utente",
    "completato": "bool — true se nodi_completati >= nodi_totali"
  }
]
```

---

#### GET /temi/{tema_id}

**Descrizione**: Dettaglio tema con elenco nodi e progresso per ciascun nodo.

**Autenticazione**: richiesta

**Path params**: `tema_id` (string)

**Response 200**:
```json
{
  "id": "string",
  "nome": "string",
  "materia": "string",
  "descrizione": "string | null",
  "nodi_totali": "int",
  "nodi_completati": "int",
  "completato": "bool",
  "nodi": [
    {
      "id": "string",
      "nome": "string",
      "tipo": "string",
      "livello": "string — non_iniziato | in_corso | operativo",
      "presunto": "bool",
      "spiegazione_data": "bool",
      "esercizi_completati": "int"
    }
  ]
}
```

**Errori**:
- 404: `"Tema non trovato"` — tema_id non esiste

---

### Achievement

#### GET /achievement/

**Descrizione**: Achievement sbloccati + prossimi con progresso corrente.

**Autenticazione**: richiesta

**Response 200**:
```json
{
  "sbloccati": [
    {
      "id": "string — es. 'primo_nodo'",
      "nome": "string — es. 'Primo passo!'",
      "tipo": "string — sigillo | medaglia | costellazione",
      "descrizione": "string | null",
      "sbloccato_at": "string | null — ISO 8601"
    }
  ],
  "prossimi": [
    {
      "id": "string — es. 'cinque_nodi'",
      "nome": "string — es. 'Cinque su cinque'",
      "tipo": "string — sigillo | medaglia | costellazione",
      "descrizione": "string | null",
      "condizione": {
        "tipo": "string — nodi_completati | esercizi_risolti | streak | tema_completato | esercizi_consecutivi_ok | sessioni_completate",
        "valore": "int — soglia richiesta"
      },
      "progresso": {
        "corrente": "int — valore attuale",
        "richiesto": "int — valore soglia"
      }
    }
  ]
}
```

**Achievement definiti nel codice** (seed all'avvio):

| ID | Nome | Tipo | Condizione | Valore |
|---|---|---|---|---|
| `primo_nodo` | Primo passo! | sigillo | nodi_completati | 1 |
| `cinque_nodi` | Cinque su cinque | sigillo | nodi_completati | 5 |
| `dieci_esercizi` | Pratica costante | sigillo | esercizi_risolti | 10 |
| `streak_3` | Tre giorni! | medaglia | streak | 3 |
| `streak_7` | Una settimana! | medaglia | streak | 7 |
| `primo_tema` | Tema completato | costellazione | tema_completato | 1 |
| `perfetto_5` | Cinque di fila! | medaglia | esercizi_consecutivi_ok | 5 |
| `prima_sessione` | Si parte! | sigillo | sessioni_completate | 1 |

---

## 3. Eventi SSE

Tutti gli endpoint che ritornano SSE usano `sse-starlette` (`EventSourceResponse`). Il frontend riceve un `text/event-stream` con eventi nel formato:

```
event: <tipo_evento>
data: <json_payload>

```

### 3.1 Evento: `onboarding_iniziato`

**Quando**: primo evento dello stream `POST /onboarding/inizia`

**Payload**:
```json
{
  "utente_temp_id": "uuid — ID utente temporaneo creato",
  "sessione_id": "uuid — ID sessione onboarding"
}
```

**Esempio**:
```
event: onboarding_iniziato
data: {"utente_temp_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890", "sessione_id": "f0e1d2c3-b4a5-6789-0abc-def123456789"}
```

### 3.2 Evento: `sessione_creata`

**Quando**: primo evento dello stream `POST /sessione/inizia`

**Payload**:
```json
{
  "sessione_id": "string — UUID sessione",
  "nodo_id": "string | null — ID nodo focale scelto",
  "nodo_nome": "string | null — nome leggibile del nodo"
}
```

**Esempio**:
```
event: sessione_creata
data: {"sessione_id": "f0e1d2c3-b4a5-6789-0abc-def123456789", "nodo_id": "derivata_definizione", "nodo_nome": "Definizione di Derivata"}
```

### 3.3 Evento: `text_delta`

**Quando**: durante la generazione streaming del testo del tutor. Multipli eventi per turno.

**Payload**:
```json
{
  "testo": "string — frammento di testo incrementale"
}
```

**Esempio**:
```
event: text_delta
data: {"testo": "Ciao! Oggi parliamo di "}

event: text_delta
data: {"testo": "derivate. La derivata è..."}
```

**Nota per il frontend**: concatenare tutti i `text_delta` per ottenere il messaggio completo del tutor.

### 3.4 Evento: `azione`

**Quando**: il tutor invoca un'azione via tool use. Il backend la esegue e inoltra il risultato al frontend.

**Payload** — struttura variabile per tipo:

#### Azione `proponi_esercizio`
```json
{
  "tipo": "proponi_esercizio",
  "params": {
    "esercizio_id": "string — ID esercizio dal banco dati",
    "testo": "string — testo dell'esercizio",
    "difficolta": "int — 1-5",
    "nodo_id": "string — nodo focale"
  }
}
```

Se nessun esercizio disponibile:
```json
{
  "tipo": "proponi_esercizio",
  "params": {
    "nodo_id": "string",
    "nessun_esercizio_disponibile": true
  }
}
```

#### Azione `mostra_formula`
```json
{
  "tipo": "mostra_formula",
  "params": {
    "latex": "string — espressione LaTeX",
    "etichetta": "string — opzionale"
  }
}
```

#### Azione `suggerisci_backtrack`
```json
{
  "tipo": "suggerisci_backtrack",
  "params": {
    "nodo_id": "string — nodo a cui tornare",
    "motivo": "string — spiegazione"
  }
}
```

#### Azione `chiudi_sessione`
```json
{
  "tipo": "chiudi_sessione",
  "params": {
    "riepilogo": "string — riepilogo sessione",
    "prossimi_passi": "string — opzionale"
  }
}
```

**Esempio completo**:
```
event: azione
data: {"tipo": "proponi_esercizio", "params": {"esercizio_id": "es_deriv_01", "testo": "Calcola la derivata di f(x) = 3x² + 2x", "difficolta": 2, "nodo_id": "derivata_definizione"}}
```

### 3.5 Evento: `achievement`

**Quando**: un achievement viene sbloccato durante il post-processing del turno.

**Payload**:
```json
{
  "id": "string — es. 'primo_nodo'",
  "nome": "string — es. 'Primo passo!'",
  "tipo": "string — sigillo | medaglia | costellazione"
}
```

**Esempio**:
```
event: achievement
data: {"id": "primo_nodo", "nome": "Primo passo!", "tipo": "sigillo"}
```

### 3.6 Evento: `turno_completo`

**Quando**: ultimo evento di ogni turno (dopo text_delta, azioni, achievement).

**Payload**:
```json
{
  "turno_id": "int — ID progressivo del turno nella sessione",
  "nodo_focale": "string | null — ID nodo focale corrente (può cambiare dopo promozione)"
}
```

**Esempio**:
```
event: turno_completo
data: {"turno_id": 5, "nodo_focale": "derivata_definizione"}
```

### 3.7 Evento: `errore`

**Quando**: errore durante l'esecuzione del turno (assemblaggio contesto, LLM, timeout).

**Payload**:
```json
{
  "codice": "string — context_error | llm_error",
  "messaggio": "string — descrizione dell'errore"
}
```

**Codici errore**:
- `context_error` — errore nell'assemblaggio del contesto (utente/sessione non trovata)
- `llm_error` — errore nella chiamata LLM (timeout, API error, stream incompleto)

**Esempio**:
```
event: errore
data: {"codice": "llm_error", "messaggio": "Timeout dopo 60s"}
```

### 3.8 Ordine degli eventi in un turno tipico

```
1. [sessione_creata | onboarding_iniziato]  — solo al primo turno
2. text_delta (N volte)                       — testo streaming del tutor
3. azione (0-N volte)                         — azioni fire-and-forget
4. achievement (0-N volte)                    — achievement appena sbloccati
5. turno_completo                             — fine turno
```

Oppure, in caso di errore:
```
1. errore                                     — stop immediato
```

---

## 4. Schema Dati Sintetico

### Utente

| Campo | Tipo | Note |
|---|---|---|
| id | UUID | PK, generato dal DB |
| email | string \| null | Unica. Null per utenti temporanei (onboarding) |
| password_hash | string \| null | bcrypt. Null per utenti temporanei |
| nome | string \| null | |
| preferenze_tutor | JSONB \| null | `{input, velocita, incoraggiamento, stile_cognitivo, ...}` |
| contesto_personale | JSONB \| null | Informazioni raccolte durante onboarding |
| profilo_sintetizzato | JSONB \| null | Profilo generato da AI (non esposto da API dirette) |
| materie_attive | array(text) \| null | Es. `["matematica"]` |
| obiettivo_giornaliero_min | int | Default 20 |
| impostazioni_promemoria | JSONB \| null | Non esposto da API |

### Sessione

| Campo | Tipo | Note |
|---|---|---|
| id | UUID | PK |
| utente_id | UUID | FK → utenti |
| tipo | string \| null | `"media"` \| `"onboarding"` |
| stato | string | `"attiva"` → `"sospesa"` → `"completata"` |
| durata_prevista_min | int \| null | |
| durata_effettiva_min | int \| null | Calcolato alla sospensione/terminazione |
| nodi_lavorati | array(text) \| null | ID nodi completati nella sessione |
| stato_orchestratore | JSONB \| null | Stato interno del motore (vedi sotto) |
| riepilogo | string \| null | Generato da azione `chiudi_sessione` |
| completed_at | timestamp \| null | Impostato alla terminazione/completamento |

**Transizioni di stato**:
```
attiva → sospesa    (POST /sessione/{id}/sospendi, o auto-sospensione per inattività > 5 min)
attiva → completata (POST /sessione/{id}/termina, o azione chiudi_sessione dal tutor)
sospesa → attiva    (POST /sessione/inizia — ripresa automatica)
sospesa → completata (POST /sessione/{id}/termina)
```

**stato_orchestratore** (struttura interna, non esposta direttamente):
```json
{
  "nodo_focale_id": "string | null",
  "attivita_corrente": "spiegazione | esercizio | feynman | ripasso_sr | null",
  "ripresa": "bool — true se la sessione è stata appena ripresa",
  "attivita_al_momento_sospensione": "string (solo per sessioni riprese)",
  "dettaglio_sospensione": "string (annotazione alla sospensione)",
  "fase_onboarding": "accoglienza | conoscenza | conclusione (solo sessioni onboarding)",
  "turni_conoscenza": "int (solo onboarding)",
  "esercizio_corrente_id": "string",
  "esercizio_corrente_testo": "string",
  "esercizio_corrente_soluzione": "dict",
  "numero_tentativo": "int",
  "tentativi_bc": "int",
  "punto_partenza_suggerito": "string (solo onboarding)",
  "punto_partenza_motivazione": "string (solo onboarding)",
  "promozione_appena_avvenuta": "{nodo_id, nodo_nome} | null",
  "prossimo_passo": "dict | null"
}
```

### Percorso Utente

| Campo | Tipo | Note |
|---|---|---|
| id | int | PK auto-increment |
| utente_id | UUID | FK → utenti |
| tipo | string | Es. `"binario_1"` |
| materia | string | Es. `"matematica"` |
| nome | string \| null | Es. `"Percorso Matematica"` |
| descrizione_obiettivo | string \| null | |
| nodi_target | array(text) \| null | |
| stato | string | Default `"attivo"` |
| nodo_iniziale_override | string \| null | Nodo di partenza personalizzato |

### Nodo (Knowledge Graph)

| Campo | Tipo | Note |
|---|---|---|
| id | string | PK — es. `"derivata_definizione"` |
| nome | string | Es. `"Definizione di Derivata"` |
| materia | string | Es. `"matematica"` |
| tipo | string | Default `"standard"` |
| tipo_nodo | string | `"operativo"` \| `"contesto"` |
| definizioni_formali | JSONB \| null | |
| formule_proprieta | JSONB \| null | |
| errori_comuni | JSONB \| null | |
| esempi_applicazione | JSONB \| null | |
| parole_chiave | JSONB \| null | |
| embedding | JSONB \| null | |

### Stato Nodo Utente

| Campo | Tipo | Note |
|---|---|---|
| utente_id | UUID | PK (composita) |
| nodo_id | string | PK (composita) |
| livello | string | `non_iniziato` → `in_corso` → `operativo` → `comprensivo` → `connesso` |
| presunto | bool | True se il livello è stato assunto (skip da onboarding) |
| spiegazione_data | bool | True se la spiegazione del concetto è stata completata |
| esercizi_completati | int | Contatore esercizi fatti su questo nodo |
| errori_in_corso | int | Contatore errori non risolti |
| esercizi_consecutivi_ok | int \| null | Serie corrente di esercizi al primo tentativo |
| sr_prossimo_ripasso | timestamp \| null | Spaced Repetition (Loop 2 — predisposto) |
| sr_intervallo_giorni | float \| null | SR |
| sr_facilita | float | Default 2.5 (SR) |
| sr_ripetizioni | int \| null | SR |
| sr_stabilita | float \| null | SR |
| sr_difficolta | float \| null | SR |
| feynman_superato | bool \| null | Loop 3 — predisposto |
| feynman_data | timestamp \| null | Loop 3 |

**Livelli e transizioni**:
```
non_iniziato → in_corso     (segnale concetto_spiegato)
in_corso → operativo         (promozione: spiegazione_data=true + esercizi>=3 + almeno 1 primo_tentativo)
operativo → comprensivo      (Loop 3 — non implementato)
comprensivo → connesso       (Loop 3 — non implementato)
```

### Achievement

| Campo | Tipo | Note |
|---|---|---|
| id | string | PK — es. `"primo_nodo"` |
| nome | string | Es. `"Primo passo!"` |
| tipo | string | `sigillo` \| `medaglia` \| `costellazione` |
| condizione | JSONB | `{tipo: "...", valore: N}` |
| descrizione | string \| null | |
| rarita | string \| null | |

### Statistiche Giornaliere

| Campo | Tipo | Note |
|---|---|---|
| utente_id | UUID | PK (composita) |
| data | date | PK (composita) |
| minuti_studio | int | |
| nodi_completati | int | |
| esercizi_svolti | int | |
| esercizi_corretti | int | |
| obiettivo_raggiunto | bool | `minuti_studio >= obiettivo_giornaliero_min` |

### Storico Esercizi

| Campo | Tipo | Note |
|---|---|---|
| id | int | PK auto-increment |
| utente_id | UUID | FK → utenti |
| nodo_focale_id | string | FK → nodi |
| esercizio_id | string \| null | FK → esercizi |
| esito | string | `primo_tentativo` \| `con_guida` \| `non_risolto` |
| nodo_causa_id | string \| null | FK → nodi |
| nodi_coinvolti | array(text) \| null | |
| tipo_errore | string \| null | |
| tempo_risposta_sec | int \| null | |
| sessione_id | UUID \| null | FK → sessioni |

---

## 5. Flussi E2E

### 5.1 Registrazione → Login → JWT

```
1. POST /auth/registrazione
   Body: {"email": "mario@test.com", "password": "secret123", "nome": "Mario"}
   → 201: {"access_token": "eyJ...", "token_type": "bearer"}

2. POST /auth/login
   Body: {"email": "mario@test.com", "password": "secret123"}
   → 200: {"access_token": "eyJ...", "token_type": "bearer"}

3. Tutti i successivi: Header: Authorization: Bearer eyJ...
```

### 5.2 Onboarding completo con conversione utente

```
1. POST /onboarding/inizia
   Body: (vuoto)
   → SSE stream:
     event: onboarding_iniziato
     data: {"utente_temp_id": "<uuid>", "sessione_id": "<uuid>"}
     ↓ (seguono text_delta del primo messaggio tutor)
     event: text_delta
     data: {"testo": "Ciao! Sono il tuo tutor..."}
     event: turno_completo
     data: {"turno_id": 1, "nodo_focale": null}

   → IL FRONTEND SALVA: utente_temp_id e sessione_id

2. POST /onboarding/turno  (N volte, fase accoglienza → conoscenza → conclusione)
   Body: {"sessione_id": "<uuid>", "messaggio": "Ciao, voglio ripassare le derivate"}
   → SSE stream:
     event: text_delta  (N volte)
     event: turno_completo

   Le fasi si aggiornano automaticamente:
   - Fase accoglienza: primo turno (tutor saluta)
   - Fase conoscenza: dal 2° turno (tutor esplora conoscenze)
   - Fase conclusione: dopo 8 turni in conoscenza (tutor chiude)

3. POST /onboarding/completa
   Body: {
     "sessione_id": "<uuid>",
     "contesto_personale": {"obiettivo": "esame analisi 1", "anno": "primo"},
     "preferenze_tutor": {"velocita": "normale", "incoraggiamento": "alto"}
   }
   → 200: {
     "percorso_id": 1,
     "nodo_iniziale": "derivata_definizione",
     "nodi_inizializzati": 42
   }

   → ORA l'utente temporaneo ha un percorso.

4. POST /auth/registrazione  (conversione utente temporaneo → registrato)
   Body: {
     "email": "mario@test.com",
     "password": "secret123",
     "nome": "Mario",
     "utente_temp_id": "<uuid dal passo 1>"
   }
   → 201: {"access_token": "eyJ...", "token_type": "bearer"}

   → L'utente temporaneo è ora registrato.
     Percorso, sessioni e stato nodi restano collegati allo stesso UUID.
     Il JWT contiene lo stesso UUID dell'utente temporaneo.
```

### 5.3 Sessione di studio

```
1. POST /sessione/inizia
   Headers: Authorization: Bearer <token>
   Body: {"tipo": "media", "durata_prevista_min": 30}
   → SSE stream:
     event: sessione_creata
     data: {"sessione_id": "<uuid>", "nodo_id": "derivata_definizione", "nodo_nome": "Definizione di Derivata"}
     event: text_delta (N volte — prima spiegazione del tutor)
     event: turno_completo
     data: {"turno_id": 1, "nodo_focale": "derivata_definizione"}

   → IL FRONTEND SALVA: sessione_id

2. POST /sessione/{sessione_id}/turno  (N volte)
   Headers: Authorization: Bearer <token>
   Body: {"messaggio": "Ok capito, passiamo a un esercizio"}
   → SSE stream:
     event: text_delta (N volte — tutor propone esercizio)
     event: azione
     data: {"tipo": "proponi_esercizio", "params": {"esercizio_id": "es_01", "testo": "...", "difficolta": 2, "nodo_id": "..."}}
     event: turno_completo

3. POST /sessione/{sessione_id}/turno  (studente risponde all'esercizio)
   Body: {"messaggio": "La derivata è 6x + 2"}
   → SSE stream:
     event: text_delta (tutor valuta e commenta)
     event: achievement  (opzionale — se sbloccato)
     data: {"id": "primo_nodo", "nome": "Primo passo!", "tipo": "sigillo"}
     event: turno_completo

4a. POST /sessione/{sessione_id}/sospendi  (se l'utente esce)
    → 200: {"id": "...", "stato": "sospesa", ...}

4b. POST /sessione/{sessione_id}/termina  (se l'utente chiude)
    → 200: {"id": "...", "stato": "completata", ...}
    (il backend verifica achievement e aggiorna statistiche)
```

### 5.4 Sospensione e ripresa

```
1. (Sessione in corso, utente esce dall'app)
   POST /sessione/{sessione_id}/sospendi
   → 200: stato="sospesa"

2. (Utente riapre l'app più tardi)
   POST /sessione/inizia
   → Il backend trova la sessione sospesa e la riprende automaticamente
   → SSE stream con sessione_creata (stesso sessione_id) + turno con direttiva di ripresa
```

### 5.5 Lettura dati

```
GET /utente/me                     → profilo utente
GET /utente/me/statistiche         → streak, nodi, esercizi, periodi
GET /percorsi/                     → lista percorsi
GET /percorsi/{id}/mappa           → mappa nodi con stato
GET /temi/                         → lista temi con progresso
GET /temi/{id}                     → dettaglio tema con nodi
GET /achievement/                  → sbloccati + prossimi
GET /sessione/{id}                 → stato singola sessione
```

---

## 6. Note per il Frontend

### Timeout consigliati

| Operazione | Timeout suggerito |
|---|---|
| Chiamate REST normali | 10 secondi |
| Stream SSE (turno) | 90 secondi (il backend ha timeout LLM di 60s + overhead) |
| Stream SSE (primo turno) | 120 secondi (il primo turno include assemblaggio contesto) |

### Gestione SSE

- **Libreria SSE**: i dati arrivano come `text/event-stream` con campo `event` e `data`
- **Concatenamento testo**: concatenare tutti i `text_delta.testo` per il messaggio completo
- **Fine turno**: attendere `turno_completo` per sapere che il turno è finito
- **Errori**: se arriva `errore`, lo stream è terminato — mostrare il messaggio all'utente
- **Achievement inline**: possono arrivare 0-N eventi `achievement` prima di `turno_completo`

### Riconnessione SSE

Il backend **non implementa** retry/reconnect SSE lato server. Se la connessione cade:

1. Il turno corrente è perso (il testo parziale non viene salvato)
2. Il frontend deve rifare `POST /{sessione_id}/turno` con lo stesso messaggio
3. Oppure chiamare `GET /sessione/{sessione_id}` per verificare lo stato

### Rate limiting

**Non implementato** nel codice corrente. Nessun middleware di rate limiting.

### Constraint per il frontend

1. **Un'unica sessione attiva per utente** — se l'utente tenta di iniziare una sessione con una già attiva e < 5 min di inattività, riceve 409
2. **L'onboarding non è autenticato** — usare `sessione_id` come identificativo in tutti i turni
3. **Il tipo sessione "media" è il default** — il campo `tipo` nel body di inizia può essere omesso
4. **I messaggi di errore sono in italiano** — possono essere mostrati direttamente all'utente
5. **UUID come stringhe** — tutti gli UUID nelle risposte JSON sono stringhe (non binary)
6. **Il nodo_focale può cambiare** — dopo una promozione, `turno_completo.nodo_focale` può essere diverso dal precedente
7. **Azioni tool use sono fire-and-forget** — il backend NON rimanda tool_result a Claude. Ogni turno = una singola chiamata LLM
8. **Conversazione troncata a 50 turni** — i primi 2 e gli ultimi 20 vengono mantenuti, il resto omesso
9. **Conversione utente temp → registrato** — dopo l'onboarding, il frontend deve inviare `utente_temp_id` nella registrazione per collegare i dati
10. **Inattività calcolata dall'ultimo turno** — la soglia di 5 minuti è calcolata dal timestamp dell'ultimo turno di conversazione (non dalla creazione sessione)

---

## 7. Discrepanze

Discrepanze tra l'implementazione reale e il design originale (brief):

1. **Nessun prefisso `/api/v1/`** — i router montano direttamente su `/auth`, `/utente`, `/onboarding`, ecc. Il frontend deve usare questi path senza prefisso.

2. **Loop 2 (Spaced Repetition) e Loop 3 (Feynman/Connessioni)** — I campi nel DB e gli schema tool sono predisposti ma le implementazioni sono stub. I livelli `comprensivo` e `connesso` non sono raggiungibili.

3. **Azioni Loop 2-3** — `mostra_visualizzazione`, `avvia_feynman`, `mostra_connessione`, `mostra_percorso` sono incluse negli schema tool inviati a Claude ma marcate come `[NON ANCORA ATTIVO]`. Se Claude le invoca, vengono loggate e ritornano con `"stub": true`.

4. **Mappa nodi non filtrata per percorso** — `GET /percorsi/{id}/mappa` verifica che il percorso appartenga all'utente, ma poi ritorna **tutti** i nodi operativi del grafo, non solo quelli del percorso specifico.

5. **Nessun endpoint per lista sessioni** — Non esiste un `GET /sessione/` per elencare le sessioni passate dell'utente. Solo `GET /sessione/{id}` per sessione singola.

6. **Nessun endpoint per note utente** — Il modello `NotaUtente` esiste nel DB ma non ha endpoint API.

7. **Nessun endpoint per stato tema utente** — Il modello `StatoTemaUtente` esiste nel DB ma non ha endpoint API.

8. **JWT scadenza 720 ore (30 giorni)** — Molto lungo. Non c'è meccanismo di refresh token.

### Discrepanze risolte (rispetto alla versione precedente del documento)

1. **~~Esito esercizio "con_guida" vs "con_aiuto"~~** — **RISOLTO**. `gamification.py` ora usa correttamente `con_guida` (coerente con lo schema tool `risposta_esercizio`). Sia il conteggio `esercizi_risolti` per achievement che le `statistiche_giornaliere.esercizi_corretti` filtrano per `["primo_tentativo", "con_guida"]`.

2. **~~Utente temporaneo → registrato (nessun endpoint di conversione)~~** — **RISOLTO**. `POST /auth/registrazione` ora accetta il campo opzionale `utente_temp_id`. Se fornito, converte l'utente temporaneo in registrato (aggiunge email, password_hash, nome) mantenendo lo stesso UUID e tutti i dati collegati (percorso, sessioni, stato nodi).
