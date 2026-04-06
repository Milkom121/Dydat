# Piano di Test Manuale — Fasi 7, 8, 9 (B33–B38)

> Data: 2026-04-06
> Scopo: validare su emulatore/device tutto il lavoro svolto da B33 a B38.
> Modalita: Villa esegue, Claude guida passo passo.

---

## Setup prima di iniziare

1. Backend acceso e popolato:
   ```
   cd backend
   docker compose up -d
   docker exec backend-backend-1 alembic upgrade head
   ```
   Verifica con `docker ps` che il container sia up.
2. Frontend avviato su emulatore/device:
   ```
   cd frontend
   flutter pub get
   flutter run
   ```
3. Account di test gia registrato con almeno un percorso creato e una sessione passata.
   Se non c'e: registrati, fai onboarding, fai una sessione breve.
4. Matita e foglio (o note nel telefono) per segnare anomalie.

---

## Scenario 1 — Avvio e Home calda (B31, B36)

**Obiettivo**: verificare che la Home mostri tutti gli elementi e che le superfici
(gradienti, glow) siano applicate senza colori hardcoded stonati.

**Passi**:
1. Apri l'app (gia loggato).
2. Arrivo su Home (tab 1).
3. Osserva nell'ordine:
   - **Welcome header** in alto con saluto contestuale (es. "Bentornato Villa")
   - **Mini-percorso visivo** (cerchi connessi — posizione attuale e prossimo nodo)
   - **Card streak** (streak giorni + esercizi settimanali)
   - **Sezione ripasso FSRS** se ci sono nodi da ripassare (badge arancione)
   - **Bottone "Riprendi a studiare"** in evidenza

**Atteso (superfici B36)**:
- Sfondo con gradiente sottile (non tinta unita piatta)
- Card con glow ambra ai bordi
- Profondita visibile (ombre leggere sotto le card)
- Nessun quadrato di colore "sbagliato" o colori evidentemente hardcoded

**Verifica in modalita scura/chiara**:
- Se possibile, cambia tema di sistema e verifica che i colori si adattino.

---

## Scenario 2 — Transizione Home → Studio (B33, B38)

**Obiettivo**: validare l'animazione di ingresso in sessione e la scelta obiettivo.

**Passi**:
1. Dalla Home, premi "Riprendi a studiare" (o equivalente).
2. Osserva l'**overlay di transizione** (~1.15 secondi):
   - La mascotte appare e scala in (dovrebbe ingrandirsi)
   - L'overlay fa un fade-out
3. Parte automaticamente una **transizione slide-up + fade** sulla route `/studio`.
4. **PRIMA** di entrare nella sessione, dovrebbe comparire il **SessionGoalPicker** (solo per sessioni tipo=media):
   - Dialog con 3 opzioni: Veloce (15 min), Normale (30 min), Approfondita (60 min)
   - Bottoni "Inizia" e "Salta"
5. Scegli "Normale" e premi "Inizia".

**Atteso**:
- Overlay di transizione fluido, nessuno scatto
- La mascotte (nuova forma CustomPainter) e un **blob organico**, NON un cerchio perfetto
- Dialog goal picker chiaro e leggibile
- Ingresso in sessione con "portale" (3 cerchi concentrici animati) — EntrancePortalPainter

**Se qualcosa non funziona**:
- L'overlay salta → screenshot + dimmi dove si blocca
- La mascotte e ancora un cerchio → problema rendering CustomPainter
- Il goal picker non appare → logica sessione tipo

---

## Scenario 3 — Sessione attiva, feed + beat overlay (B37, B38)

**Obiettivo**: validare i beat emotivi, l'overlay atmosferico e la reattivita della mascotte.

**Passi**:
1. Sei in sessione. Osserva il feed conversazionale del tutor.
2. Guarda la **mascotte**: dovrebbe avere **occhi espressivi** (sclera, pupilla, riflesso).
3. Osserva il **beat overlay** sullo sfondo:
   - Gradiente radiale molto sottile (opacita 0.03-0.15)
   - Cambia tono in base al momento (accoglienza, spiegazione, attesa, streaming)
4. Aspetta che il tutor completi una risposta (beat: streaming → attesa).
5. La mascotte dovrebbe **cambiare espressione** in modo fluido (transizione 500ms).
6. Invia un messaggio al tutor ("Fammi un esercizio su X").

**Atteso**:
- Overlay visibile ma NON invasivo (se da fastidio, opacita e sbagliata)
- Transizioni mascotte fluide, nessun salto brusco
- Gli occhi si muovono/chiudono in base al beat
- Nessun lag visibile (60 fps mantenuti)

---

## Scenario 4 — Esercizio fullscreen (B32) + esito + notifica pausa (B33)

**Obiettivo**: validare il modello ibrido (esercizio esce dal feed), recap compatto e snackbar pausa.

**Passi**:
1. Aspetta o chiedi un esercizio al tutor.
2. Quando arriva la proposta, l'**ExerciseCardWidget esce dal feed** e va **fullscreen**:
   - Transizione slide-up + fade
   - Il feed chat spare, focus totale sull'esercizio
3. Rispondi all'esercizio (testo o scelta multipla).
4. Osserva la transizione di ritorno al feed: l'esercizio deve lasciare un **record compatto** nel feed (CompactActionRecord).
5. Ripeti con una **formula** se il tutor ne mostra una (FormulaCardWidget → fullscreen → LaTeX).
6. **Test notifica pausa obiettivo (B33)**:
   - Lascia passare il tempo oltre i 30 min dell'obiettivo "Normale" (oppure accorcia il test ricordando che c'e un check)
   - Dovrebbe apparire una **snackbar gentile** (una sola volta) che suggerisce una pausa

**Atteso**:
- Esercizio fullscreen ben posizionato, leggibile
- Record compatto nel feed dopo completamento
- Formula con rendering LaTeX corretto
- Snackbar pausa una sola volta, non invasiva

**Se qualcosa non funziona**:
- L'esercizio resta inline nel feed → B32 non applicato
- La snackbar non appare mai → logica `_checkGoalExceeded` rotta
- La snackbar appare piu volte → problema stato flag

---

## Scenario 5 — Chiusura sessione e recap narrativo (B33)

**Obiettivo**: validare che il recap mostri prima la narrativa tutor e poi i numeri.

**Passi**:
1. Esci dalla sessione (bottone back o controllo sessione).
2. Arriva al **RecapSessionScreen**.
3. Osserva:
   - **In cima**: commento narrativo del tutor ("Oggi hai lavorato su X, la prossima volta vedremo Y")
   - **Sotto**: card con le statistiche (durata, esercizi, nodi)

**Atteso**:
- La narrativa e leggibile, ha un tono caldo
- I numeri vengono DOPO, non prima
- Nessuno stile stonato

---

## Scenario 6 — Tab "I miei studi": mappa + zoom + ricerca (B34)

**Obiettivo**: validare la nuova LearningPathScreen.

**Passi**:
1. Torna alla Home, poi vai al tab "I miei studi" (tab 2).
2. Vedi la **mappa lineare** (nodi come cerchi collegati, NON lista card).
3. Scorri verticalmente lungo il percorso.
4. Verifica che lo **stato dei nodi** sia distinguibile per colore/bordo:
   - Da iniziare (neutro)
   - In corso (evidenziato)
   - Operativo (bordato)
   - Comprensivo (pieno)
5. Trova il bottone/gesture per **zoom out** → passa a vista grafo completo (InteractiveViewer).
6. Fai pinch/zoom e panoramica sul grafo.
7. Torna alla vista lineare.
8. Usa la **barra di ricerca** in alto: digita il nome di un nodo.
9. La lista/mappa deve filtrare o evidenziare i match.
10. **Tap su un nodo** → deve aprire il **quaderno** (B35, non piu placeholder).

**Atteso**:
- Mappa lineare leggibile, stati chiari
- Zoom grafo funziona senza crash
- Ricerca filtra in tempo reale
- Tap su nodo naviga al quaderno

**Se qualcosa non funziona**:
- Vedi ancora le card vecchie → B34 non applicato
- Zoom crasha → problema CustomPainter/InteractiveViewer
- Ricerca non filtra → logica filter rotta

---

## Scenario 7 — Quaderno per nodo (B35)

**Obiettivo**: validare aggregazione dati quaderno per nodo.

**Passi**:
1. Dal tab "I miei studi", tap su un nodo che hai gia studiato.
2. Si apre **NodoQuadernoScreen** (route `/quaderno/:nodoId`).
3. Osserva le 4 sezioni:
   - **StatoHeader** (stato del nodo in alto)
   - **FormuleSection** (formule viste, deduplicate, con LaTeX)
   - **EserciziSection** (esercizi svolti con badge esito corretto/sbagliato)
   - **SpiegazioniSection** (spiegazioni chiave del tutor, espandibili)
4. Espandi una spiegazione e verifica che il testo sia completo.
5. Verifica che le formule abbiano rendering LaTeX corretto.
6. Torna indietro → devi tornare al tab "I miei studi", non altrove.

**Atteso**:
- Dati aggregati reali dal backend (`GET /quaderno/{nodo_id}`)
- LaTeX renderizzato
- Badge esito corretti (verde/rosso)
- Navigazione back pulita

**Se qualcosa non funziona**:
- Schermata vuota o errore → endpoint backend o modello frontend
- LaTeX non renderizza → flutter_math_fork
- Dati duplicati → deduplicazione rotta

---

## Scenario 8 — Promozione nodo e celebrazione (B38 PromotionBurst)

**Obiettivo**: validare l'animazione di celebrazione alla promozione.

**Passi**:
1. Torna in una sessione e fai esercizi corretti consecutivi finche il tutor promuove un nodo.
2. Alla promozione, osserva:
   - **PromotionBurstPainter**: 12 raggi di luce + cerchio di espansione attorno alla mascotte
   - La mascotte fa un'espressione di "celebrazione"

**Atteso**:
- Animazione evidente ma breve
- Nessun crash
- Feed riceve il messaggio di promozione

---

## Scenario 9 — Sessione ripasso FSRS (B28, B29)

**Obiettivo**: verificare che la sezione ripasso in Home funzioni e avvii una sessione ripasso.

**Passi**:
1. Se in Home c'e la sezione "Nodi da ripassare", tap sul bottone "Vai".
2. Si avvia una **sessione tipo=ripasso** (non goal picker, perche solo per media).
3. Il tutor dovrebbe lavorare sui nodi SR scaduti.
4. Completa un paio di esercizi e chiudi.

**Atteso**:
- Sessione parte con nodi di ripasso
- Nessun goal picker (solo per media)
- Badge ripasso in home aggiornato dopo la sessione

---

## Scenario 10 — Tab Profilo (B36 superfici)

**Obiettivo**: verificare che il Profilo abbia le nuove superfici.

**Passi**:
1. Tab "Profilo" (tab 3).
2. Osserva gradienti e glow applicati.
3. Scorri le sezioni (account, impostazioni, statistiche).

**Atteso**:
- Coerenza visiva con Home e I miei studi
- Nessun colore hardcoded stonato

---

## Raccolta feedback

Per ogni scenario:
- ✅ OK = tutto come atteso
- ⚠️ PARZIALE = funziona ma ha qualcosa di strano (specificare)
- ❌ ROTTO = non funziona (screenshot + descrizione)

Alla fine, Villa comunica a Claude l'esito per ogni scenario.
Claude raccoglie, crea issue in `.claude/handoff.md` con i bug, e propone blocco di fix mirato.

---

## Note tecniche per Claude

- Se un bug emerge in B33/B34/B35/B36/B37/B38, NON fare un blocco monstre di fix.
  Fare un mini-blocco di fix separato per ciascun problema grave.
- Bug cosmetici minori vanno in `.claude/ideas.md` con priorita bassa.
- Prima di rilasciare fix, sempre: leggi il file, fai la modifica minima, test.
