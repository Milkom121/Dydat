# 🚀 AVVIO RAPIDO - DYDAT FRONTEND

## 📋 Panoramica

Questo è il frontend dell'applicazione **Dydat**, una piattaforma educativa completa con sistema di gamification, marketplace corsi e tutoring.

## ⚡ Avvio Veloce

### Opzione 1: Script PowerShell Semplice (Raccomandato)
```powershell
.\avvia-dydat-semplice.ps1
```

### Opzione 2: Script Batch
```cmd
start.bat
```

### Opzione 3: Comando Diretto
```cmd
cd apps\frontend && npm run dev
```

### Opzione 4: Manuale Passo-Passo
```bash
cd apps/frontend
npm install
npm run dev
```

## 🌐 Accesso all'Applicazione

- **URL**: http://localhost:3000
- **Porta**: 3000 (di default)
- L'applicazione si avvia automaticamente e sarà disponibile nel browser

## 👤 Utente di Test

L'applicazione include dati mock per il testing:

- **Nome**: Marco Rossi
- **Email**: marco.rossi@dydat.com
- **Password**: Non richiesta (mock data)
- **Ruoli**: Student, Creator, Tutor, Admin
- **Livello**: 12 (Neurone Quantico)
- **XP**: 11,250
- **Neuroni**: 2,847

## 🎭 Sistema Ruoli

| Ruolo | Descrizione | Colore |
|-------|-------------|--------|
| **Guest** | Accesso limitato alle funzionalità pubbliche | Grigio |
| **Student** | Accesso completo ai corsi e apprendimento | Blu |
| **Creator** | Può creare e pubblicare corsi | Viola |
| **Tutor** | Può offrire sessioni di tutoraggio | Verde |
| **Member** | Membro organizzazione con contenuti privati | Ambra |
| **Manager** | Gestisce organizzazione e membri | Arancione |
| **Admin** | Accesso completo a tutte le funzionalità | Rosso |

## ✨ Funzionalità Disponibili

### 🔐 Autenticazione
- Sistema ruoli avanzato con 7 livelli
- Gestione permessi granulare
- Switch ruolo in tempo reale (dropdown in alto a destra)

### 🎮 Gamification
- **Livelli**: Sistema progressivo da 1 a 50+
- **XP**: Punti esperienza per azioni
- **Neuroni**: Valuta virtuale Dydat (visibile in header)
- **Badge**: Achievement system con rarità

### 📚 Dashboard
- Statistiche personalizzate per ruolo
- Cards responsive con metriche
- Progresso livello con barra animata
- Quick actions basate su permessi

### 🎨 Design System
- **Colori Brand**: Dydat Amber (#F59E0B) e Orange (#F97316)
- **Font**: Inter
- **Framework**: Tailwind CSS
- **Dark Mode**: Toggle in header (icona luna/sole)

## 🛠️ Tecnologie

- **Framework**: Next.js 14
- **Linguaggio**: TypeScript
- **Styling**: Tailwind CSS
- **Icone**: Lucide React
- **State Management**: Zustand
- **Build Tool**: Next.js

## 🔧 Comandi Disponibili

```bash
# Sviluppo
npm run dev

# Build produzione
npm run build

# Avvio produzione
npm run start

# Linting
npm run lint
```

## 🌟 Caratteristiche Implementate

### ✅ Completato
- [x] Setup Next.js 14 + TypeScript
- [x] Design system Tailwind con colori Dydat
- [x] Sistema tipi completo per ruoli e permessi
- [x] Layout Header, Sidebar e componenti principali
- [x] Dashboard multi-ruolo con statistiche
- [x] Dark mode toggle funzionante
- [x] Sistema gamification UI completo
- [x] Mock data ricchi per testing
- [x] Build ottimizzato per produzione

### 🚧 Prossimi Sviluppi
- [ ] Sistema corsi completo
- [ ] Marketplace tutoring
- [ ] API backend integration
- [ ] Database setup
- [ ] Sistema notifiche

## 🎯 Come Testare

1. **Avvia l'applicazione** con uno degli script
2. **Apri il browser** su http://localhost:3000
3. **Testa il cambio ruolo**:
   - Clicca sul dropdown ruolo in alto a destra
   - Seleziona diversi ruoli (Student, Creator, Tutor, Admin)
   - Osserva come cambiano le statistiche e i permessi
4. **Testa il dark mode**:
   - Clicca l'icona luna/sole in header
   - Verifica la transizione smooth tra temi
5. **Esplora la sidebar**:
   - Osserva come le voci cambiano in base al ruolo
   - Testa la funzione collapse/expand
6. **Controlla la responsività**:
   - Ridimensiona il browser
   - Testa su dispositivi mobili

## 🐛 Risoluzione Problemi

### Script PowerShell non funziona
```powershell
# Usa lo script semplificato
.\avvia-dydat-semplice.ps1

# O cambia policy se necessario
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Errore: "Cannot find module"
```bash
cd apps/frontend
npm install
```

### Errore: "Port 3000 already in use"
```bash
# Su Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Build non funziona
```bash
cd apps/frontend
npm run build
# Controlla errori TypeScript
```

## 📞 Supporto

Per problemi:
- Usa lo script `avvia-dydat-semplice.ps1` (più compatibile)
- Controlla la console del browser per errori
- Verifica Node.js v18+ installato
- Assicurati di essere nella directory root del progetto

---

**🎉 Buon testing con Dydat!** L'applicazione è completamente funzionale con un'interfaccia moderna e responsive. 