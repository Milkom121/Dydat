# DYDAT - Script di Avvio Frontend
# Uso: .\avvia-dydat-semplice.ps1

Write-Host "DYDAT - Avvio Applicazione Frontend" -ForegroundColor Cyan
Write-Host ""

# Controlla directory
if (-not (Test-Path "apps\frontend")) {
    Write-Host "ERRORE: Esegui questo script dalla directory root del progetto" -ForegroundColor Red
    Write-Host "Directory corrente: " -NoNewline
    Write-Host (Get-Location) -ForegroundColor Yellow
    pause
    exit 1
}

# Vai in frontend
Write-Host "Navigazione in apps\frontend..." -ForegroundColor Yellow
Set-Location "apps\frontend"

# Installa dipendenze se necessario
if (-not (Test-Path "node_modules")) {
    Write-Host "Installazione dipendenze..." -ForegroundColor Yellow
    npm install
}

Write-Host ""
Write-Host "INFORMAZIONI:" -ForegroundColor Cyan
Write-Host "- URL: http://localhost:3000 (o 3001/3002 se 3000 occupata)"
Write-Host "- Utente test: marco.rossi@dydat.com"
Write-Host "- Ruoli: Student, Creator, Tutor, Admin"
Write-Host "- Dashboard completa con widget"
Write-Host "- Premi Ctrl+C per fermare"
Write-Host ""
Write-Host "CORREZIONI APPLICATE:" -ForegroundColor Green
Write-Host "- Risolto errore Hydration Error" -ForegroundColor Green
Write-Host "- Dashboard completa con tutti i widget" -ForegroundColor Green
Write-Host "- Dark mode senza conflitti server/client" -ForegroundColor Green
Write-Host ""

Write-Host "Avvio applicazione..." -ForegroundColor Green
npm run dev 