@echo off
echo DYDAT - Avvio Applicazione Frontend
echo.

if not exist "apps\frontend" (
    echo ERRORE: Esegui dalla directory root del progetto
    pause
    exit /b 1
)

cd apps\frontend

if not exist "node_modules" (
    echo Installazione dipendenze...
    npm install
)

echo.
echo INFORMAZIONI:
echo - URL: http://localhost:3000
echo - Utente test: marco.rossi@dydat.com
echo - Ruoli: Student, Creator, Tutor, Admin
echo - Premi Ctrl+C per fermare
echo.

echo Avvio applicazione...
npm run dev 