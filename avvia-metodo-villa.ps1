$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$gitBash = @("C:\Program Files\Git\bin\bash.exe","C:\Program Files (x86)\Git\bin\bash.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($gitBash) {
    Write-Host "Avvio Metodo Villa Runner..." -ForegroundColor Green
    & $gitBash -c "cd '$($scriptDir -replace '\\','/')' && chmod +x metodo-villa-runner.sh && ./metodo-villa-runner.sh --max-blocks 20 --timeout 60 --verbose"
} elseif (Get-Command wsl -ErrorAction SilentlyContinue) {
    Write-Host "Uso WSL..." -ForegroundColor Yellow
    wsl bash -c "cd '$($scriptDir -replace '\\','/' -replace '^C:','/mnt/c')' && chmod +x metodo-villa-runner.sh && ./metodo-villa-runner.sh --max-blocks 20 --timeout 60 --verbose"
} else { Write-Host "Nessun bash trovato! Installa Git for Windows." -ForegroundColor Red }
Read-Host "Premi Invio per chiudere"
