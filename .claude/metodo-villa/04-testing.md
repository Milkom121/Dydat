# Strategia di Testing Completa

## Livelli di testing progressivi

### Livello 1 — Test unitari e di integrazione (sempre, automatici)

Questo è il livello minimo, obbligatorio per ogni progetto:
- Eseguiti automaticamente alla fine di ogni blocco di sviluppo
- Se falliscono, il ciclo si ferma — il blocco successivo NON parte
- Sono la condizione minima per dichiarare un blocco completato
- Comandi tipici: `pytest`, `go test`, `flutter test`, `npm test`, `cargo test`

Ogni progetto deve definire nel suo CLAUDE.md locale il comando esatto per eseguire i test L1 (vedi gate di uscita nella roadmap).

### Livello 2 — Test visuale/funzionale via browser (per web app)

Per i progetti con interfaccia web (BottegaLLM, Melo, SenilWatch dashboard, Dydat admin):
- Usa Claude in Chrome o strumenti simili per:
  - Navigare l'app deployata localmente
  - Verificare i flussi utente principali (login, navigazione, CRUD base)
  - Controllare regressioni visive (screenshot comparison tra sessioni)
  - Monitorare errori nella console browser
  - Verificare che le richieste di rete rispondano correttamente
- Può essere integrato nel ciclo continuo come "guardiano" tra i blocchi: dopo che L1 passa, il browser verifica che l'app funzioni ancora end-to-end

**Raccomandazione**: Definire una suite di "smoke test" visivi per ogni progetto web: i 3-5 flussi utente critici che devono sempre funzionare. Esempio per Melo: login admin → dashboard → lista ospiti → dettaglio ospite → logout. Se uno di questi flussi si rompe, il blocco non è completato.

### Livello 3 — Test mobile via emulatore (livello avanzato — opzionale)

Per i progetti con app mobile (SenilWatch mobile, Dydat frontend Flutter, BottegaLLM AppMobile), quando il progetto raggiunge maturità:
- Strumenti disponibili:
  - **Android Emulator Skill** — navigazione semantica dell'UI, test di accessibilità, visual regression su emulatore
  - **Appium Claude Android** — test in linguaggio naturale su dispositivi reali o emulati, senza scrivere codice di test
  - **Mobile App Tester Skill** — supporta framework multipli: Appium, Detox, XCUITest, Espresso
- Più complesso da configurare rispetto ai test browser — richiede emulatore attivo e setup dedicato

**Raccomandazione**: Implementare L3 solo dopo che L1 e L2 sono stabili e rodati. Il test mobile è costoso in termini di tempo e configurazione — meglio avere una base solida prima. L3 è per progetti maturi che vanno verso produzione, non per standard development.

**Decisione**: Flutter integration test nativi come standard per i progetti mobile (già usati in Dydat e SenilWatch). Framework aggiuntivi (Appium, Espresso) solo se emerge una necessità specifica non coperta dai test nativi Flutter.

### Livello 4 — Test E2E e performance (livello avanzato — opzionale)

Per progetti in fase di pre-produzione o produzione:
- Load testing e stress testing (quanti utenti concorrenti regge il sistema?)
- Test di sicurezza (penetration testing, OWASP top 10)
- Test di accessibilità (WCAG compliance)
- Monitoring continuo (uptime, tempi di risposta, errori in produzione)

**Raccomandazione**: Non automatizzare L4 nel ciclo continuo — eseguire come task schedulati separati (settimanali o pre-release). Includerli nel ciclo rallenterebbe troppo lo sviluppo senza beneficio proporzionale. L4 è per progetti maturi che vanno a produzione, non per standard development.

## Integrazione testing nel ciclo continuo

Il flusso completo, quando il ciclo continuo è attivo:

```
Blocco sviluppo
    → Test L1 (unitari/integrazione) — SEMPRE
    → [se web app] Test L2 (browser smoke test) — SE CONFIGURATO
    → [se mobile] Test L3 (emulatore) — SE CONFIGURATO
    → Checkpoint/Report
    → Blocco successivo (o stop se fallito)
```

### Regole di arresto:

- **L1 fallisce**: il ciclo si ferma. Il blocco successivo non parte. Il fallimento viene documentato nel handoff.
- **L2/L3 fallisce**: il ciclo si ferma e notifica Villa con screenshot e log dell'errore. Il test unitario potrebbe non catturare regressioni visive — serve l'occhio umano (o quello di Claude via browser).
- **Tutto passa**: il ciclo procede automaticamente al blocco successivo, oppure si ferma al checkpoint configurato (dipende dal livello di automazione scelto).

**Raccomandazione**: Per ogni progetto, definire esplicitamente nella roadmap quali livelli di test si applicano a ciascun blocco. Non tutti i blocchi richiedono L2/L3 — un blocco che tocca solo il backend non ha bisogno di test browser.
