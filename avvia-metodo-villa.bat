@echo off
chcp 65001 >nul
title Metodo Villa Runner
echo.
echo ========================================
echo    Metodo Villa Runner - Avvio
echo ========================================
echo.
set "GITBASH="
if exist "C:\Program Files\Git\bin\bash.exe" set "GITBASH=C:\Program Files\Git\bin\bash.exe"
if exist "C:\Program Files (x86)\Git\bin\bash.exe" set "GITBASH=C:\Program Files (x86)\Git\bin\bash.exe"
if defined GITBASH (
    echo Trovato Git Bash: %GITBASH%
    echo Avvio runner...
    echo.
    "%GITBASH%" -c "cd '%~dp0' && chmod +x metodo-villa-runner.sh && ./metodo-villa-runner.sh --max-blocks 20 --timeout 60 --verbose"
    echo.
    echo === Runner terminato ===
    pause
) else (
    echo ERRORE: Git Bash non trovato!
    echo Installa Git for Windows: https://git-scm.com/download/win
    pause
)
