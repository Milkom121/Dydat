# ============================================================================
# DYDAT - Script di Avvio Frontend
# ============================================================================
# Questo script avvia l'applicazione Dydat in modalita sviluppo
# Uso: .\avvia-dydat.ps1
# ============================================================================

Write-Host "DYDAT - Avvio Applicazione Frontend" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Controlla se siamo nella directory corretta
if (-not (Test-Path "apps/frontend")) {
    Write-Host "ERRORE: Esegui questo script dalla directory root del progetto Dydat" -ForegroundColor Red
    Write-Host "Directory corrente: $PWD" -ForegroundColor Yellow
    Write-Host "Directory richiesta: quella che contiene la cartella 'apps/frontend'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Premi Enter per uscire"
    exit 1
}

# Naviga nella directory frontend
Write-Host "Navigazione in apps/frontend..." -ForegroundColor Yellow
Set-Location "apps/frontend"

# Controlla se node_modules esiste
if (-not (Test-Path "node_modules")) {
    Write-Host "Installazione dipendenze..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRORE: durante l'installazione delle dipendenze" -ForegroundColor Red
        Read-Host "Premi Enter per uscire"
        exit 1
    }
}

# Controlla versioni
Write-Host "Controllo versioni..." -ForegroundColor Yellow
$nodeVersion = node --version
$npmVersion = npm --version
Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
Write-Host "npm: $npmVersion" -ForegroundColor Green
Write-Host ""

# Informazioni applicazione
Write-Host "INFORMAZIONI APPLICAZIONE" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "Nome: Dydat Frontend"
Write-Host "Framework: Next.js 14 + TypeScript"
Write-Host "Styling: Tailwind CSS"
Write-Host "URL: http://localhost:3000"
Write-Host ""

# Caratteristiche principali
Write-Host "CARATTERISTICHE PRINCIPALI" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host "- Sistema autenticazione con 7 ruoli" -ForegroundColor Green
Write-Host "- Gamification (livelli, XP, neuroni, badge)" -ForegroundColor Green
Write-Host "- Sistema corsi e marketplace" -ForegroundColor Green
Write-Host "- Sistema tutoring completo" -ForegroundColor Green
Write-Host "- Dark mode e temi personalizzabili" -ForegroundColor Green
Write-Host "- Design responsive e moderno" -ForegroundColor Green
Write-Host ""

# Utente di test
Write-Host "UTENTE DI TEST" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host "Email: marco.rossi@dydat.com"
Write-Host "Password: Non richiesta (mock data)"
Write-Host "Ruoli disponibili: Student, Creator, Tutor, Admin"
Write-Host "Neuroni: 2,847"
Write-Host "Livello: 12 (Neurone Quantico)"
Write-Host ""

Write-Host "Avvio dell'applicazione..." -ForegroundColor Yellow
Write-Host "Premi Ctrl+C per fermare il server" -ForegroundColor Gray
Write-Host "L'applicazione si aprira automaticamente nel browser" -ForegroundColor Gray
Write-Host ""

# Avvia l'applicazione
Start-Process -NoNewWindow -FilePath "npm" -ArgumentList "run", "dev" -Wait

Write-Host ""
Write-Host "Grazie per aver usato Dydat!" -ForegroundColor Green 