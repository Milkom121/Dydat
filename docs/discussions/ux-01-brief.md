# UX-01 — Primo turno caldo del tutor

> Brief autocontenuto per discussione strategica in Cowork.
> Generato da: Claude Code (sessione di sviluppo Dydat)
> Data: 2026-04-08
> Fondatore: Villa
>
> **Cosa fare con questo file**: copiare l'intero contenuto e incollarlo come primo messaggio in una nuova conversazione Cowork. La discussione produrra in output una mini-spec di blocco di sviluppo che verra poi convertita in un vero blocco del Metodo Villa.

---

## 0. Contesto del prodotto (per chi non conosce Dydat)

**Dydat** e un tutor AI adattivo per matematica, fisica e chimica. App mobile Flutter + backend FastAPI + Claude API. L'utente:

1. Si registra e fa un **onboarding conversazionale** col tutor (5-8 turni): chi e, che livello ha, perche studia, stile preferito, da dove vuole partire
2. Il sistema costruisce un **percorso personalizzato** sulla base di un knowledge graph di concetti (Algebra1+Algebra2 = 183 nodi, 1470 esercizi)
3. L'utente entra in una **sessione di studio** col tutor: il tutor spiega concetti, propone esercizi, valuta risposte, gestisce errori col metodo "Botte e Carota"
4. Le sessioni hanno una "intenzione di tempo" scelta dall'utente (Veloce 15min, Normale 30min, Approfondita 60min)

L'esperienza e progettata per essere "calda", personale, conversazionale. Il tutor **deve sentirsi come una persona che ti accompagna**, non come una macchina che spara contenuti.

---

## 1. Il problema osservato

Durante un test manuale del 2026-04-06, Villa ha registrato un nuovo utente, ha completato l'onboarding rispondendo a domande tipo:

- "Sto riprendendo dopo tanto tempo"
- Materia: Matematica
- "Studio per curiosita personale"
- Ultimo argomento ricordato: Operazioni base e frazioni
- Confidenza con frazioni: 4/5
- Stile preferito: "Partire da esempi concreti, poi formalizzare"
- "Fammi fare un test per capire il punto giusto"

Dopo l'onboarding, ha avviato la **prima sessione di studio** scegliendo "Normale 30 min". Nodo di partenza: **Potenza di un numero relativo**.

**Il primo turno del tutor e stato** (testo reale, screenshot allegato sotto):

```
Ciao! 😊
Immagina di avere una scatola di cioccolatini. Se ne prendi 2 alla volta
per 3 giorni consecutivi, alla fine hai raccolto 2 × 2 × 2 = 8 cioccolatini.
Scrivere questa moltiplicazione ripetuta puo diventare lungo: per questo
usiamo le potenze.

Ma cosa succede se invece di avere +2 cioccolatini al giorno, ne perdi 2
(quindi -2)?

Quanto avresti dopo 3 giorni? E se lo facessi per 2 giorni invece di 3,
cambierebbe qualcosa?
```

**Osservazione di Villa** (testuale): *"quella che vedi e la prima interazione dell'utente con il tutor, mi sembra che sia un po' troppo immediato come approccio, bisognerebbe forse fare qualche riflessione sul flusso reale dell'utente"*.

### Cosa manca, in dettaglio

1. **Continuita con l'onboarding**: l'utente ha appena fatto una conversazione di 8 turni col tutor durante l'onboarding. Il tutor adesso non riprende NULLA di quel contesto esplicitamente. Nessun "Bentornato Verdan, stai riprendendo dopo una pausa, partiamo dolcemente". L'utente ha l'impressione che il tutor "non si ricordi di lui".

2. **Presentazione del nodo**: il tutor non dice MAI "Oggi affrontiamo: Potenza di un numero relativo. Ti propongo di vedere insieme X, Y, Z, in circa 30 minuti". Parte dritto con l'esempio dei cioccolatini. L'utente non ha nessuna mappa di cosa stia per accadere.

3. **Warm-up esplorativo**: l'utente ha dichiarato "sicurezza 4/5 sulle operazioni base". Sarebbe stato naturale aprire con qualcosa di esplorativo: "Raccontami cosa ricordi delle potenze normali, poi vediamo come cambiano col segno". Invece il tutor parte con un esempio espositivo.

4. **Ponte conversazionale caldo**: manca completamente un saluto contestualizzato. Niente "Bentornato", niente uso del nome.

5. **Riconoscimento del ritmo scelto**: l'utente ha scelto "Normale 30 min". Il tutor non lo riconosce ne lo usa per modulare il ritmo ("Abbiamo 30 minuti, ti propongo di usarli cosi: 5 min di ripasso veloce, 15 di concetto nuovo, 10 di esercizio pratico").

### Severita

Villa la classifica come **issue strategica UX-01**, severita **ALTA**. Non e un bug tecnico, e un problema di **design conversazionale del tutor** che impatta la prima impressione e il senso di "tutor che ti conosce".

---

## 2. Cosa fa il tutor adesso (codice reale)

### 2.1 — System prompt globale (sempre presente)

File: `backend/app/llm/prompts/system_prompt.py`

```python
SYSTEM_PROMPT = """\
Sei il tutor personale di Dydat, un sistema di apprendimento adattivo per matematica, fisica e chimica.

## CHI SEI

Sei un insegnante esperto, paziente e incoraggiante. Il tuo obiettivo e costruire comprensione profonda, non dare risposte. Preferisci guidare il ragionamento piuttosto che spiegare direttamente.

Caratteristiche:
- Paziente: non ti frustri mai, ogni errore e un'opportunita di apprendimento
- Incoraggiante: celebri i progressi, anche piccoli
- Curioso: fai domande per capire come pensa lo studente
- Adattivo: cambi approccio se qualcosa non funziona
- Onesto: se non sai qualcosa, lo dici

## METODO DIDATTICO

### Flusso Concreto -> Problema -> Formale
Per ogni concetto nuovo:
1. Parti da un esempio concreto dalla vita reale
2. Poni un problema che richiede il concetto
3. Costruisci insieme la formalizzazione

### Approccio B+C (Botte e Carota)
Quando lo studente sbaglia:
1. NON dare la risposta
2. Fai una domanda che punta al punto di rottura
3. Se non arriva, dai un hint piu esplicito
4. Dopo 2-3 tentativi senza progresso, spiega direttamente e proponi un passo indietro
5. Chiudi SEMPRE con un successo o un apprendimento concreto, mai con un fallimento nudo

[... regole su esercizi, contenuto formale, limiti, tono ...]

### Ritmo e brevita
- OGNI messaggio deve essere BREVE: massimo 3-4 righe di testo.
- NON comprimere una lezione intera in un unico messaggio.
- Il flusso Concreto -> Problema -> Formale va distribuito su PIU turni, non in uno solo.
- Fai UNA cosa per turno: O un esempio, O una domanda, O un esercizio.
- Dopo ogni blocco di 3-4 righe, fermati e aspetta la risposta dello studente.
- Lo studente deve sentire una conversazione, non un monologo.
"""
```

**Osservazione**: il system prompt e gia abbastanza buono come carattere ("paziente, incoraggiante, curioso, adattivo, onesto"). Il problema NON e qui — questo prompt e generico e si applica sempre.

### 2.2 — Direttiva di spiegazione (la VERA causa del problema)

File: `backend/app/llm/prompts/direttive.py`

Ad ogni turno, oltre al system prompt, il backend genera una **direttiva** specifica per la situazione corrente. Per il primo turno di studio di un nodo viene chiamata `direttiva_spiegazione`:

```python
def direttiva_spiegazione(
    *,
    nodo_nome: str,
    nodo_id: str,
    prerequisiti_completati: list[str],
    livello_materia: str,
    definizioni_formali: Any,
    formule_proprieta: Any,
    errori_comuni: Any,
    stile_cognitivo: str | None = None,
    esempi_preferiti: str | None = None,
    minuti_rimasti: int | None = None,
) -> str:
    """Direttiva per spiegazione di un concetto nuovo."""
    righe = [
        "ATTIVITA: Spiegazione nuovo concetto",
        f"NODO: {nodo_nome} ({nodo_id})",
        f"STATO STUDENTE: Ha completato i prerequisiti {prereq_str}. Livello generale: {livello_materia}.",
        "",
        "CONTENUTO FORMALE:",
        _formatta_json(definizioni_formali),
        _formatta_json(formule_proprieta),
        "",
        "ERRORI COMUNI DA PREVENIRE:",
        _formatta_json(errori_comuni),
        "",
        f"PREFERENZE STUDENTE: {stile}. Preferisce esempi da: {esempi}.",
        "",
        (
            "ISTRUZIONI:\n"
            "- Questo e il PRIMO turno: parti con un esempio concreto "
            "dalla vita reale (2-3 frasi) e chiudi con una domanda "
            "per coinvolgere lo studente.\n"
            "- NON spiegare tutto subito. Il flusso Concreto -> Problema -> "
            "Formale si sviluppa su PIU turni.\n"
            "- Massimo 4-5 righe per questo turno. Lo studente "
            "deve rispondere prima di proseguire.\n"
            "- Al termine del percorso (non adesso), proponi un esercizio."
        ),
    ]
    return "\n".join(righe)
```

**QUESTA E LA RADICE DEL PROBLEMA**. La direttiva istruisce esplicitamente il tutor a "**partire con un esempio concreto dalla vita reale (2-3 frasi)**" come PRIMA cosa. Senza presentazione, senza saluto, senza ponte.

Le PREFERENZE_STUDENTE (stile cognitivo, esempi preferiti) sono passate ma il tutor non ha istruzioni esplicite su come usarle nel primo turno.

Manca anche qualunque riferimento al **nome utente**, all'**onboarding fatto**, al **ritmo della sessione**.

### 2.3 — Profilo utente disponibile

File: `backend/app/core/contesto.py`, funzione `_blocco_profilo_utente`

```python
def _blocco_profilo_utente(utente: Utente) -> str:
    """Blocco 3 del context package: profilo utente."""
    parti = []
    pref = utente.preferenze_tutor   # JSONB: stile_cognitivo, esempi_preferiti, ecc.
    if pref:
        parti.append(f"Preferenze tutor: {json.dumps(pref, ensure_ascii=False)}")
    ctx = utente.contesto_personale  # JSONB: chi e, urgenza, motivo, ecc.
    if ctx:
        parti.append(f"Contesto personale: {json.dumps(ctx, ensure_ascii=False)}")
    profilo = utente.profilo_sintetizzato  # JSONB: sintesi narrativa generata dall'onboarding
    if profilo:
        parti.append(f"Profilo sintetizzato: {json.dumps(profilo, ensure_ascii=False)}")
    if not parti:
        parti.append("(nessuna informazione disponibile sul profilo)")
    return "<profilo_utente>\n" + "\n".join(parti) + "\n</profilo_utente>"
```

**Importante**: il profilo utente E gia incluso nel context package del tutor ad ogni turno (Blocco 3 dei 6 blocchi XML). Quindi il tutor LO SA, lo VEDE, ma **la direttiva di spiegazione non gli dice di usarlo nel primo turno**. Risultato: ignora silenziosamente quei dati.

Il campo `utenti.nome` (es. "Verdan") e nella tabella utenti ma non e attualmente passato esplicitamente alla direttiva.

### 2.4 — Come l'onboarding raccoglie le info

L'onboarding ha 5 fasi: `accoglienza`, `conoscenza`, `placement`, `piano`, `conclusione`. Durante queste fasi il tutor chiama un tool `onboarding_domanda` che presenta domande strutturate (scelta singola, scala 1-5, testo libero). Le risposte vengono accumulate e alla fine il sistema:

1. Sintetizza tutto in un **`profilo_sintetizzato`** (JSONB salvato su `utenti.profilo_sintetizzato`)
2. Estrae le **`preferenze_tutor`** (es. `{"stile_cognitivo": "esempi prima poi teoria", "ritmo": "rilassato"}`)
3. Estrae il **`contesto_personale`** (es. `{"chi_e": "adulto che riprende", "motivo": "curiosita", "urgenza": "nessuna"}`)
4. Inizializza il percorso col primo nodo da affrontare

Questi dati sono **gia disponibili al tutor** dal primo turno della prima sessione. **Nessun dato manca**. Manca solo l'istruzione di usarli nel primo turno.

### 2.5 — Direttiva di ripresa sessione (per confronto)

Esiste gia una `direttiva_ripresa_sessione` che si attiva quando l'utente riprende una sessione interrotta. Estratto:

```python
def direttiva_ripresa_sessione(
    *,
    nodo_nome: str,
    attivita_precedente: str,
    ultima_interazione_min: int,
    ...
) -> str:
    return f"""
ATTIVITA: Ripresa sessione interrotta
NODO: {nodo_nome}
ULTIMA ATTIVITA: {attivita_precedente}
TEMPO DALL'ULTIMA INTERAZIONE: {ultima_interazione_min} minuti

ISTRUZIONI:
- Saluta brevemente lo studente e riprendi da dove eravate ('Bentornato! Stavamo lavorando su X...')
- Sii caldo ma vai dritto al punto, non perdere tempo
- Massimo 2-3 righe
"""
```

Quindi il pattern "saluto + ponte" gia esiste per la ripresa, ma **non per il primo turno assoluto**.

---

## 3. Vincoli architetturali (cose da rispettare)

Importanti per non proporre soluzioni infattibili.

1. **Tre layer rigidi**: Knowledge Graph (deterministico) — Orchestratore (Python) — Tutor LLM (Claude). Layer 1 e Layer 3 non si parlano direttamente. Tutto passa per l'orchestratore.

2. **Fire-and-forget**: ogni turno e UNA singola chiamata `messages.create()` con streaming. Il tutor riceve il context package (6 blocchi XML) + la direttiva, risponde, e il sistema processa. NON c'e dialogo a piu round per generare un singolo turno.

3. **Prompt in file separati**: i prompt vivono in `backend/app/llm/prompts/`. Mai hardcoded nella logica. Quindi il fix sara una **modifica della funzione `direttiva_spiegazione`** (e potenzialmente l'aggiunta di una nuova `direttiva_primo_turno`).

4. **Conversazione**: i `turni_conversazione.contenuto` salvano SOLO testo visibile. Niente JSON. Le azioni del tutor vanno in un campo `azioni` separato (JSONB).

5. **Streaming SSE**: il frontend riceve il messaggio del tutor chunk by chunk. Tempo di latenza percepito = ~200-500ms al primo token, poi streaming continuo. Quindi il primo turno PUO essere multi-paragrafo, ma non deve essere lunghissimo (vedi regola "messaggi brevi" del system prompt).

6. **Modelli LLM configurabili**: tutor usa Sonnet 4.5, pipeline (sintesi/estrazione) usa Haiku 4.5. Non hardcoded. Si puo eventualmente usare Sonnet con un prompt piu strutturato per il primo turno senza preoccuparsi di latenza/costo eccessivi.

7. **Modello deterministico parziale**: e accettabile (e gia fatto in altri punti) avere "scaffolding" deterministico nel testo del tutor — es. il sistema puo iniettare un prefisso o un saluto base e poi lasciare libero il modello sul resto. Vedi l'esempio gia esistente in `_genera_direttiva` linea 430:

   ```python
   if nodo_completato:
       prefisso = (
           f'il nodo "{nodo_completato}" — riconoscilo brevemente prima di '
           ...
       )
       direttiva = prefisso + direttiva
   ```

8. **Testabilita**: ogni nuova logica va coperta con pytest. La direttiva e una funzione pura che ritorna stringhe — testarla e banale.

---

## 4. Cosa NON e in scope di questa discussione

Per non perdere fuoco:

- **Ridisegno dell'onboarding**: gia in pianificazione come blocco B39 "Onboarding Wow". Diverso problema. Non toccarlo qui.
- **Mascotte / animazioni**: qui parliamo di TESTO del tutor, non di componenti visivi.
- **Aggiungere domande all'onboarding**: il dato e gia abbondante. Il problema e che non viene usato.
- **Cambiare modello LLM**: si lavora sul prompt, non sul modello.

---

## 5. Domande aperte per la discussione

Cowork dovrebbe affrontare queste domande in ordine. Le risposte costituiranno la spec del blocco di sviluppo.

### D1 — Struttura del primo turno
Il primo turno di una sessione dovrebbe essere **monolitico** (un singolo messaggio che fa tutto: saluto + presentazione + warm-up) oppure **diviso in piu turni** (turno 1: solo accoglienza + presentazione, turno 2: warm-up esplorativo, turno 3: inizio del concreto)?

Trade-off:
- Monolitico = utente vede subito qualcosa di sostanzioso, ma rischia muri di testo
- Multi-turno = piu conversazionale ma richiede 2-3 risposte dell'utente prima di entrare nel merito (frustrante per chi vuole "imparare subito")

### D2 — Quanto deterministico e quanto LLM
Il primo turno dovrebbe essere:
- **(a)** Completamente generato dall'LLM con istruzioni dettagliate nella direttiva
- **(b)** Parzialmente deterministico: il sistema inietta un saluto fisso ("Bentornato {nome}! Iniziamo con {nodo_nome}.") e poi l'LLM continua liberamente
- **(c)** Template strutturato: blocchi fissi con slot ({saluto}, {ponte}, {presentazione}, {warm_up}) riempiti meccanicamente

Trade-off: piu deterministico = piu prevedibile e robusto, meno "vivo". Piu LLM = piu naturale ma meno controllato.

### D3 — Quali dati del profilo usare e come
Il profilo utente contiene 3 fonti (`preferenze_tutor`, `contesto_personale`, `profilo_sintetizzato`). Ognuna ha campi diversi. Quali sono i 3-5 elementi PIU IMPORTANTI da menzionare/usare nel primo turno? E come inquadrarli nel testo (citazione esplicita "Hai detto X" o riferimento implicito)?

### D4 — Presentazione del nodo
Il nodo nel database ha: `definizioni_formali`, `formule_proprieta`, `esempi_applicazione`, `errori_comuni`, `parole_chiave`. Il tutor usa gia queste cose, ma sparse nel corso della spiegazione. Nel primo turno dovrebbe **anticipare un piccolo "indice"** ("Vedremo cosa sono le potenze, come si comportano col segno, e faremo alcuni esempi") oppure no (rovinerebbe la sorpresa pedagogica)?

### D5 — Riconoscimento del ritmo
L'utente sceglie "Veloce 15 / Normale 30 / Approfondita 60". Il tutor dovrebbe:
- **(a)** Citare esplicitamente il tempo ("Abbiamo 30 minuti, ti propongo X")
- **(b)** Modularne il ritmo silenziosamente (piu rapido se Veloce, piu approfondito se Approfondita)
- **(c)** Entrambi

E come dovrebbe il sistema **strutturare** la sessione di 30 minuti? Manca completamente un concetto di "piano della sessione". Il tutor procede passo passo senza una mappa temporale.

### D6 — Gestione del primo turno per nodi gia "presunti padroneggiati"
Caso edge: durante l'onboarding il placement test puo marcare alcuni nodi come "presunti padroneggiati". Quando l'utente entra in sessione su un nodo presunto, il tutor dovrebbe avere un primo turno DIVERSO (verifica veloce invece di spiegazione completa)? Oppure trattare uguale?

### D7 — Coerenza con gli altri primi turni
Esistono altre situazioni di "primo turno" oltre alla spiegazione di un nuovo nodo:
- Primo esercizio su un nodo gia spiegato
- Primo turno di una sessione di ripasso (ripasso_sr)
- Primo turno dopo una pausa lunga

Le decisioni prese qui vanno applicate solo al primo turno di spiegazione, oppure servono "primi turni caldi" anche per gli altri casi?

---

## 6. Cosa Cowork deve produrre alla fine della discussione

Una **mini-spec di blocco di sviluppo** (chiamato candidato `B33.5 — Primo turno caldo`) con questa struttura:

```
## B33.5 — Primo turno caldo (UX-01)

### Obiettivo
[2-3 righe sul perche e il cosa]

### Decisioni di design (risposte alle 7 domande sopra)
- D1: ...
- D2: ...
- D3: ...
- D4: ...
- D5: ...
- D6: ...
- D7: ...

### File da modificare
- backend/app/llm/prompts/direttive.py (modifica direttiva_spiegazione)
- backend/app/core/contesto.py (eventuale passaggio nuovi parametri)
- [eventuali nuovi file]

### Modifica concreta della direttiva
[Pseudo-codice o testo della nuova istruzione che andra nella direttiva_spiegazione, con le sezioni: PROFILO RICONOSCIUTO, PRESENTAZIONE NODO, ISTRUZIONI PRIMO TURNO]

### Test
- [test 1: ...]
- [test 2: ...]
- [test manuale: chiede a Villa di fare nuovo test E2E con utente fresco]

### Gate di uscita
- ...

### Vincoli rispettati
- [conferma che la spec rispetta i 7 vincoli architetturali del paragrafo 3]

### NON fare
- ...
```

Questa spec verra poi consegnata a **Claude Code** (la sessione di sviluppo) che la convertira in handoff per il runner del Metodo Villa, che generera il codice + test.

---

## 7. Stile della discussione richiesto

- **Italiano** (Villa preferisce italiano, anche se l'output e codice/spec)
- **Concreto, no muri di testo**: Villa ha esplicitamente chiesto durante questa sessione di sviluppo di evitare risposte verbose. Andare al punto.
- **Decisioni in formato chiaro**: per ogni domanda, una raccomandazione + 1-2 righe di motivazione + alternative scartate brevemente
- **Pensare al test E2E**: ogni decisione deve essere testabile manualmente da Villa nel mondo reale (registrare un utente, fare onboarding, entrare in sessione, vedere il primo turno). Niente decisioni che "in teoria funzionano" ma non si possono verificare.
- **Tenere fede al tono Dydat**: caldo ma non smielato, professionale ma non freddo, italiano corretto, "tu" all'utente

---

## 8. Sintesi rapida (TL;DR)

- **Problema**: il tutor al primo turno parte a bomba con un esempio, senza salutare, senza riconoscere l'utente, senza presentare il nodo, senza usare il profilo onboarding (che pure ha disponibile).
- **Causa codice**: la direttiva `direttiva_spiegazione` istruisce esplicitamente a "partire con un esempio concreto" come prima cosa.
- **Vincoli**: prompt in file separato, modifica chirurgica, single LLM call per turno, tutto testabile.
- **Cosa serve**: una nuova versione della direttiva (o una nuova `direttiva_primo_turno`) che produca un primo turno **caldo, contestualizzato, presentato**.
- **Output discussione**: una mini-spec di blocco B33.5 da consegnare a Claude Code per implementazione tramite il runner Metodo Villa.

---

**Cowork: inizia rispondendo a D1, poi procediamo in ordine. Se serve un chiarimento, chiedimi prima di decidere — sono Villa, fondatore di Dydat, e questa decisione la prendo io.**
