$ErrorActionPreference = 'Stop'
$stateFile = Join-Path $PSScriptRoot '.dev-servers.json'

function Stop-ProcessTree {
    param([int]$ProcessId)
    $children = @(Get-CimInstance Win32_Process -Filter "ParentProcessId = $ProcessId" -ErrorAction SilentlyContinue)
    foreach ($child in $children) { Stop-ProcessTree -ProcessId $child.ProcessId }
    Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
}

if (-not (Test-Path -LiteralPath $stateFile)) {
    Write-Host 'Aucun serveur lance par le launcher principal.'
    exit 0
}

$servers = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
foreach ($server in $servers) {
    if (-not $server.ProcessId) { continue }

    $process = Get-Process -Id ([int]$server.ProcessId) -ErrorAction SilentlyContinue
    if (-not $process) { continue }

    if ($server.StartedAt) {
        $recordedStart = [DateTimeOffset]::Parse([string]$server.StartedAt)
        $actualStart = [DateTimeOffset]$process.StartTime
        if ([Math]::Abs(($actualStart - $recordedStart).TotalSeconds) -gt 2) {
            Write-Warning "PID $($server.ProcessId) reutilise par un autre processus ; arret ignore pour $($server.Name)."
            continue
        }
    }

    Stop-ProcessTree -ProcessId ([int]$server.ProcessId)
    Write-Host "$($server.Name) arrete (PID $($server.ProcessId))."
}

Remove-Item -LiteralPath $stateFile -ErrorAction SilentlyContinue
