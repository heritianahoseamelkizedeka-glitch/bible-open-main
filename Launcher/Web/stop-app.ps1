$ErrorActionPreference = 'Stop'
$pidFile = Join-Path $PSScriptRoot '.dev-server.pid'

if (-not (Test-Path -LiteralPath $pidFile)) {
    Write-Host 'Aucun serveur lancé par ce lanceur.'
    exit 0
}

$serverProcessId = [int](Get-Content -LiteralPath $pidFile -Raw)
$process = Get-Process -Id $serverProcessId -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Id $serverProcessId -Force
    Write-Host "Serveur Bible Open Main arrêté (PID $serverProcessId)."
}
Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
