@echo off
chcp 65001 >nul
cls

echo.
echo 🎯 DYDAT - Avvio Applicazione Frontend
echo =======================================
echo.

REM Controlla se siamo nella directory corretta
if not exist "apps\frontend" (
    echo ❌ Errore: Esegui questo script dalla directory root del progetto Dydat
    echo    Directory corrente: %CD%
    echo    Directory richiesta: quella che contiene la cartella 'apps\frontend'
    echo.
    pause
    exit /b 1
)

REM Naviga nella directory frontend
echo 📁 Navigazione in apps\frontend...
cd apps\frontend

REM Controlla se node_modules esiste
if not exist "node_modules" (
    echo 📦 Installazione dipendenze...
    call npm install
    if errorlevel 1 (
        echo ❌ Errore durante l'installazione delle dipendenze
        pause
        exit /b 1
    )
)

echo.
echo 📋 INFORMAZIONI APPLICAZIONE
echo ==============================
echo 🏷️  Nome: Dydat Frontend
echo 🛠️  Framework: Next.js 14 + TypeScript
echo 🎨 Styling: Tailwind CSS
echo 🔧 Stato: Sviluppo
echo 🌐 URL: http://localhost:3000
echo.

echo ✨ CARATTERISTICHE PRINCIPALI
echo ==============================
echo 🔐 Sistema autenticazione con 7 ruoli
echo 🎮 Gamification (livelli, XP, neuroni, badge)
echo 📚 Sistema corsi e marketplace
echo 👨‍🏫 Sistema tutoring completo
echo 🌙 Dark mode e temi personalizzabili
echo 📱 Design responsive e moderno
echo.

echo 👤 UTENTE DI TEST
echo ==================
echo 📧 Email: marco.rossi@dydat.com
echo 🔑 Password: Non richiesta (mock data)
echo 🎭 Ruoli disponibili: Student, Creator, Tutor, Admin
echo 🧠 Neuroni: 2,847
echo ⭐ Livello: 12 (Neurone Quantico)
echo.

echo 🚀 Avvio dell'applicazione...
echo    Premi Ctrl+C per fermare il server
echo    L'applicazione si aprirà automaticamente nel browser
echo.

REM Avvia l'applicazione
call npm run dev

echo.
echo 👋 Grazie per aver usato Dydat!
pause 