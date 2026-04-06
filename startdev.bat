@echo off
title Dydat - Backend
echo ========================================
echo   Dydat - Avvio Ambiente di Sviluppo
echo ========================================
echo.

cd /d "%~dp0backend"

REM --- Chiudo eventuali istanze precedenti ---
echo Controllo se il backend e' gia' avviato...
docker compose down >nul 2>&1
echo Tutto pulito.
echo.

REM --- Avvio da zero ---
echo Avvio in corso... (prima volta puo' richiedere 1-2 minuti)
echo.
echo Quando vedi i log scorrere, il backend e' pronto.
echo Backend su porta 8001 (per evitare conflitti con altri programmi).
echo Puoi avviare l'app da Android Studio.
echo.
echo PER SPEGNERE: chiudi questa finestra.
echo ========================================
echo.

docker compose up --build
