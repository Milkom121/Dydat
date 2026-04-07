# Piano di Test Manuale — Nottata B35.5.1 → B35.13

> Data: 2026-04-07
> Branch in test: `wip/notte-quaderno-polish-2026-04-07`
> Scopo: validare su emulatore i 13 blocchi eseguiti dal runner nella nottata
> Modalita: Villa esegue, Claude guida scenario per scenario, registra bug in `.claude/test-findings-nottata.md`

---

## Setup

1. **Backend**: gia up da `backend/docker compose up -d`
2. **Frontend**: riavvia `flutter run` (o hot-restart con R maiuscola) sull'emulatore per caricare le ultime modifiche
3. **Utente**: usa quello gia in DB (`mariomattiadimuro@gmail.com` / Verdan / matematica). Non serve reset.
4. **Nota**: il backend in B35.12 ora fa validazione secrets all'avvio. Se docker non parte o da errore sulla chiave API Anthropic, segnalamelo.

---

## Priorita test (ordinata per impatto)

| # | Scenario | Blocco testato | Priorita |
|---|---|---|---|
| 1 | **Quaderno Enciclopedico** (il piu grande) | B35.5.1-B35.5.5 | CRITICA |
| 2 | **Pull-to-refresh** | B35.7 | ALTA |
| 3 | **Loading skeleton** (scorgere nei primi secondi di caricamento) | B35.9 | ALTA |
| 4 | **Errori user-friendly** (forzare un errore) | B35.8 | MEDIA |
| 5 | **Search con parole chiave** | B35.10 | MEDIA |
| 6 | **Testi "Serie" / "Traguardi"** nel profilo | B35.11 | BASSA |
| 7 | **Polish empty states** (utente con zero dati) | B35.6 | BASSA |
| 8 | **Accessibilita** (lo testiamo solo come "niente si e rotto") | B35.13 | BASSA |

Note: B35.12 (backend secrets) non e testabile manualmente dall'utente, verifichiamo solo che il backend sia partito.

---

## Scenario 1 — Quaderno Enciclopedico (il piatto forte)

**Passi**:
1. Home → tab "I miei studi"
2. Tocca un nodo a scelta (es. "Potenza di un numero relativo", il primo)
3. Dal bottom sheet, tocca il bottone "Quaderno"
4. Si apre la `NodoQuadernoScreen` riscritta

**Cosa deve esserci (dall'alto in basso)**:
- [ ] Header con back e nome nodo
- [ ] Breadcrumb con nome tema + chip stato ("Da iniziare", "In corso", ecc.)
- [ ] Chip parole chiave in riga orizzontale (es. "potenza", "esponente", "base")
- [ ] Sezione **"Cosa imparerai"**: testo lungo con preview 3 righe e bottone "Leggi tutto"
- [ ] Sezione **"Formule chiave"**: card con formule LaTeX renderizzate (es. `a^n = a · a · ...`)
- [ ] Sezione **"Esempi"**: lista di esempi calcolati
- [ ] Sezione **"Attenzione a..."**: card rosse con errori comuni (tipo errore + descrizione + esempio sbagliato + come evitarlo)
- [ ] Sezione **"Le mie note"**: textfield vuoto con bottone Salva
- [ ] Separator "— I tuoi appunti —" (o simile)
- [ ] Sezioni log personale (esercizi svolti, formule viste, spiegazioni)

**Test funzionali**:
1. Tap su "Leggi tutto" sulla definizione → si espande
2. Scrivi qualcosa nelle "Le mie note" → aspetta 1 secondo → verifica che compaia "Salvato ✓" (autosave debounced)
3. Chiudi il quaderno, riaprilo → la nota deve essere ancora lì
4. Prova su un secondo nodo: le note devono essere indipendenti

**Possibili problemi da cercare**:
- LaTeX non renderizza (si vede codice grezzo invece della formula)
- Card errori comuni non mostrano tutti i campi
- Nota non si salva (nessun indicatore o errore)
- Sezioni vuote non gestite bene

---

## Scenario 2 — Pull-to-refresh

**Passi**:
1. Home → **trascina dall'alto verso il basso** con il dito (gesto pull-to-refresh)
2. Dovrebbe comparire l'indicatore circolare e ricaricare i dati
3. Ripeti su tab "I miei studi"

**Possibili problemi**:
- Niente indicatore / gesto ignorato
- Crash durante refresh
- Dati non aggiornati dopo refresh

---

## Scenario 3 — Loading skeleton

**Passi**:
1. Chiudi completamente l'app (swipe via dall'elenco app)
2. Riapri l'app fresca
3. **Guarda attentamente i primi 1-2 secondi** quando la Home si carica
4. Cerca placeholder grigi animati al posto dei spinner circolari
5. Stessa cosa al primo ingresso in "I miei studi" dopo hot-restart
6. Stessa cosa all'apertura di un Quaderno

**Possibili problemi**:
- Vedi ancora spinner circolari (skeleton non applicato)
- Skeleton non anima (statico grigio)
- Skeleton troppo grande / piccolo / in posti strani

---

## Scenario 4 — Errori user-friendly

**Come forzare un errore**:
- Spegni il WiFi / dati mobili dell'emulatore
- Fai un'azione che richieda rete (refresh, caricamento quaderno, avvio sessione)
- Riaccendi la rete quando hai finito

**Cosa cercare**:
- Messaggi errore in italiano, gentili
- NON deve apparire "DioException", "SocketException", stack trace
- Esempio buono: "Connessione assente. Controlla la rete e riprova."

**Possibili problemi**:
- Errori tecnici ancora mostrati all'utente
- Messaggi italiani ma poco chiari

---

## Scenario 5 — Search con parole chiave

**Passi**:
1. Tab "I miei studi"
2. Barra di ricerca in alto
3. Cerca una **parola chiave** che NON e nel nome del nodo (es. "esponente" mentre il nodo si chiama "Potenza di un numero relativo")
4. Verifica che il nodo compaia filtrato

**Possibili problemi**:
- Search solo su nome (parole chiave ignorate)
- Case sensitive quando non dovrebbe
- Lista non filtra / filtra male

---

## Scenario 6 — Testi "Serie" e "Traguardi"

**Passi**:
1. Tab Profilo
2. Verifica che nelle statistiche ci sia scritto **"Serie"** (non "Streak")
3. Verifica che nella sezione achievement ci sia scritto **"Traguardi"** (non "Achievement")
4. Guarda anche il recap di una sessione passata se possibile

**Possibili problemi**:
- Testo inglese ancora presente in qualche punto
- Rotture di layout per testi piu lunghi

---

## Scenario 7 — Empty states vari

**Passi**:
1. Tab Profilo con utente appena registrato (poche statistiche)
2. Tab Home e verifica la sezione ripasso (probabilmente vuota)
3. "I miei studi" → search con un termine che NON matcha nessun nodo (es. "pippozinfandel")
4. Verifica che ogni stato vuoto abbia un messaggio gentile, non uno spazio bianco

**Possibili problemi**:
- Empty state mancante (schermata vuota)
- Messaggio generico o tecnico

---

## Scenario 8 — Accessibilita (solo non-regression)

**Passi**:
1. **Test TextScaler**: vai nelle impostazioni del sistema operativo dell'emulatore e aumenta la dimensione testo (es. da 100% a 130%)
2. Torna su Dydat e vedi se i testi si scalano (prima non lo facevano perche era bloccato)
3. Verifica che niente si rompa visivamente

**Possibili problemi**:
- Testi troncati se scalati
- Overflow
- Pulsanti troppo piccoli per toccabilita

---

## Raccolta feedback

Per ogni scenario:
- ✅ OK = tutto come atteso
- ⚠️ PARZIALE = funziona ma c'e qualcosa di strano
- ❌ ROTTO = non funziona o crasha

Claude raccoglie i findings in `.claude/test-findings-nottata.md`, poi li consolida in un eventuale blocco di fix (tipo B38.5 dell'altra volta).
