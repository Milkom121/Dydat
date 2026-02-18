@echo off
echo ========================================
echo   Dydat Backend - Avvio
echo ========================================
echo.

cd /d "%~dp0backend"

echo Avvio Docker Compose...
docker compose up --build -d

echo.
echo Attendo che il backend sia pronto...
timeout /t 5 /nobreak >nul

echo Verifico health check...
curl -s http://localhost:8000/health

echo.
echo ========================================
echo   Backend avviato su http://localhost:8000
echo   Per fermare: docker compose down
echo ========================================
pause
