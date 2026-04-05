# Idee per il Progetto

Idee e intuizioni emerse durante le sessioni di sviluppo che non fanno parte del blocco corrente.
Ogni voce ha data e contesto. Verranno riprese in fase di pianificazione.

## 2026-02-19 - Mascotte "Creatura di Luce"
- **Contesto**: Discussione design mascotte durante Loop 2
- **Idea**: Mascotte animata tipo creatura di luce che reagisce allo stato dello studente. Richiede asset design (SVG/Rive). Attualmente placeholder circolare con animazioni stato-driven.

## 2026-02-27 - Voice Input per lo studente
- **Contesto**: Riflessione UX durante pianificazione Loop 4-7
- **Idea**: Permettere allo studente di rispondere a voce oltre che per testo. Speech-to-text integrato nel campo input. Utile soprattutto per spiegazioni Feynman (piu naturale parlare che scrivere).

## 2026-02-27 - Beat-aware canvas styling
- **Contesto**: Pianificazione Loop 7 (Atmosfera)
- **Idea**: Lo sfondo e i colori del canvas cambiano sottilmente in base al "ritmo" della sessione (focus, flow, review, celebrate). Gia pianificato come B34, ma potrebbe evolvere in qualcosa di piu sofisticato con audio/musica.

## 2026-02-27 - Mascotte asset con AI generativa
- **Contesto**: Pianificazione asset mascotte
- **Idea**: Usare Midjourney/DALL-E per generare i PNG della mascotte in vari stati, poi Flutter code per glow/transizioni. Track separato dal codice — serve sessione dedicata di design.

## 2026-04-05 - Widget test e integration test frontend
- **Contesto**: Audit completo del codice
- **Idea**: Aggiungere widget test per i flussi critici (login -> onboarding -> studio -> recap). Attualmente solo unit test per provider/servizi. I widget test richiederebbero un investimento significativo ma aumenterebbero la confidenza sui rilasci.

## 2026-04-05 - Paginazione storico sessioni
- **Contesto**: Audit performance frontend
- **Idea**: La session history carica tutto in una volta. Con molte sessioni (50+) potrebbe rallentare. Implementare paginazione lato backend (offset/limit) e lazy loading lato frontend.

## 2026-04-05 - Deep linking con parametri route
- **Contesto**: Audit routing frontend
- **Idea**: Aggiungere parametri dinamici alle route GoRouter (/studio/:sessionId, /percorso/:topicId) per supportare deep linking e restore dello stato. Utile se un giorno si aggiungono notifiche push con link diretti.
