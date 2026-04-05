# Gestione Scorciatoie e Checklist Pre-Produzione

## Principio: velocità in sviluppo, sicurezza in produzione

Durante la fase di sviluppo attivo è PERMESSO usare scorciatoie per velocizzare il lavoro. Questo è pragmatico e coerente con il principio "Funziona > È elegante". Scorciatoie tipiche:

- Credenziali hardcoded per login rapido
- Auto-login o bypass di autenticazione
- CORS permissivo (`*`)
- HTTPS disabilitato in locale
- Mock di servizi esterni
- Dati di test hardcoded
- Validazioni semplificate o disabilitate
- `console.log` / `print` di debug sparsi nel codice

La regola non è "non farlo" — è **"fallo, ma registralo"**.

## Regola obbligatoria: registrazione delle scorciatoie

OGNI scorciatoia presa durante lo sviluppo DEVE essere registrata immediatamente nel file `docs/dev-shortcuts.md` nella root del progetto. Il formato:

```
## [DATA] - [DESCRIZIONE BREVE]
- **File**: percorso del file modificato
- **Riga**: numero di riga approssimativo
- **Tipo**: credenziale-hardcoded | bypass-auth | cors-permissivo | https-disabilitato | mock-servizio | dati-test | validazione-disabilitata | debug-log | altro
- **Dettaglio**: cosa è stato fatto e perché
- **Priorità di risoluzione**: alta (sicurezza) | media (funzionalità) | bassa (pulizia)
```

### Esempio:

```
## 2026-03-15 - Password admin hardcoded per test rapido
- **File**: backend/app/config.py
- **Riga**: ~42
- **Tipo**: credenziale-hardcoded
- **Dettaglio**: password "admin123" per l'utente di test, evita di dover configurare .env ad ogni sessione
- **Priorità di risoluzione**: alta (sicurezza)

## 2026-03-15 - CORS aperto a tutti
- **File**: backend/app/main.py
- **Riga**: ~15
- **Tipo**: cors-permissivo
- **Dettaglio**: allow_origins=["*"] per non avere problemi durante lo sviluppo frontend
- **Priorità di risoluzione**: alta (sicurezza)
```

## Checkpoint pre-produzione

Prima di andare in produzione, esiste un checkpoint obbligatorio **NON bypassabile**:

1. Claude prende il file `docs/dev-shortcuts.md`
2. Verifica OGNI voce una per una
3. Per ogni scorciatoia: la risolve (es. sposta credenziali in `.env`, rimuove bypass auth, restringe CORS) oppure segnala che non è stata risolta e perché
4. Aggiorna `docs/dev-shortcuts.md` marcando ogni voce come ✅ risolta o ❌ da risolvere con motivazione
5. Il merge su `main` è **BLOCCATO** finché tutte le voci ad **alta priorità** non sono risolte
6. Le voci a media e bassa priorità vengono segnalate nella PR ma non bloccano il merge

**Raccomandazione**: Anche se non si va in produzione, fare una pulizia del `docs/dev-shortcuts.md` almeno una volta al mese per evitare che diventi ingestibile. Claude può proporre la pulizia a inizio sessione se il file ha più di 20 voci non risolte.
