param([switch]$NoBrowser)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$webRoot = Join-Path $repoRoot 'Frontend\web'
$pidFile = Join-Path $PSScriptRoot '.dev-server.pid'
$appUrl = 'http://localhost:5174'

$npmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue
if (-not $npmCommand) {
    Write-Error 'npm est introuvable. Installez Node.js avec npm, puis relancez le lanceur.'
    exit 1
}

if (Test-Path -LiteralPath $pidFile) {
    & (Join-Path $PSScriptRoot 'stop-app.ps1')
}

if (-not (Test-Path -LiteralPath (Join-Path $webRoot 'node_modules'))) {
    Write-Host 'Installation des dépendances npm...'
    & $npmCommand.Source install --prefix $webRoot
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$process = Start-Process -FilePath $npmCommand.Source -ArgumentList @('run', 'dev', '--', '--port', '5174', '--strictPort') -WorkingDirectory $webRoot -WindowStyle Hidden -PassThru
$process.Id | Set-Content -LiteralPath $pidFile
$ready = $false
$deadline = (Get-Date).AddSeconds(30)

while ((Get-Date) -lt $deadline) {
    if ($process.HasExited) {
        Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
        Write-Error "Le serveur s'est arrêté avant son démarrage (code $($process.ExitCode))."
        exit $process.ExitCode
    }
    try {
        $response = Invoke-WebRequest -Uri $appUrl -UseBasicParsing -TimeoutSec 1
        if ($response.StatusCode -eq 200) { $ready = $true; break }
    } catch { Start-Sleep -Milliseconds 300 }
}

if (-not $ready) {
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
    Write-Error 'Le serveur ne répond pas sur le port 5174 après 30 secondes.'
    exit 1
}

Write-Host "Bible Open Main démarré sur $appUrl (PID $($process.Id))."
if (-not $NoBrowser) { Start-Process $appUrl }
