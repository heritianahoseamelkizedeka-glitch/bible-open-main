param(
    [switch]$NoBrowser,
    [switch]$ListOnly,
    [switch]$CheckOnly,
    [switch]$RequireCore,
    [switch]$StartApis,
    [string]$CoreApiUrl = $(if ($env:CORE_API_URL) { $env:CORE_API_URL } else { 'http://127.0.0.1:8085/api/v1' })
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'core-readiness.ps1')
$coreReady = $false
if ($CheckOnly -and $ListOnly) { throw 'Choisir CheckOnly ou ListOnly.' }
if (-not $ListOnly -and -not $StartApis) {
    $coreReady = Test-CoreReady -ApiUrl $CoreApiUrl
    if ($coreReady) { Write-Host 'OK - API Core prete (base et migrations).' -ForegroundColor Green }
    else { Write-Warning 'API Core non prete. Authentification et fonctions dependantes indisponibles. Demarrer/configurer Core et ses migrations.' }
    if ($CheckOnly) { if ($coreReady) { exit 0 } else { exit 1 } }
    if ($RequireCore -and -not $coreReady) { throw 'Demarrage annule : API Core non prete. Aucun processus arrete ou lance.' }
}
$mainRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workspaceRoot = Split-Path -Parent $mainRoot
$stateFile = Join-Path $PSScriptRoot '.dev-servers.json'
$configPath = Join-Path $mainRoot 'Frontend\web\public\config\applications.json'
$npmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue
$nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue

if (-not $npmCommand) {
    Write-Error 'npm est introuvable. Installez Node.js avec npm, puis relancez le launcher.'
    exit 1
}

$apps = @(
    [PSCustomObject]@{ Name = 'Bible Open Main'; Root = Join-Path $mainRoot 'Frontend\web'; Url = 'http://localhost:5174/'; Arguments = @('run', 'dev', '--', '--port', '5174', '--strictPort') },
    [PSCustomObject]@{ Name = 'Quizz Biblique'; Root = Join-Path $workspaceRoot 'APK Quizz Biblique BO v2\Frontend\web'; Url = 'http://localhost:5173/'; Arguments = @('run', 'dev', '--', '--port', '5173', '--strictPort') },
    [PSCustomObject]@{ Name = 'Study Bible'; Root = Join-Path $workspaceRoot 'Study-bible-open\Frontend\web'; Url = 'http://localhost:9891/'; Arguments = @('run', 'dev') }
)

function Test-AppReady {
    param([string]$Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3
        return $response.StatusCode -ge 200 -and $response.StatusCode -lt 400
    } catch { return $false }
}

if ($ListOnly) {
    Write-Host 'Applications configurees dans le launcher principal :' -ForegroundColor Cyan
    foreach ($app in $apps) {
        $available = Test-Path -LiteralPath (Join-Path $app.Root 'package.json')
        $status = if ($available) { 'MANIFESTE PRESENT' } else { 'NON CONSTRUITE' }
        $color = if ($available) { 'Green' } else { 'DarkYellow' }
        Write-Host " - [$status] $($app.Name) - $($app.Url)" -ForegroundColor $color
    }
    exit 0
}

if (Test-Path -LiteralPath $stateFile) { & (Join-Path $PSScriptRoot 'stop-app.ps1') }
$startedApps = @()

try {
    foreach ($app in $apps) {
        if (-not (Test-Path -LiteralPath $app.Root)) {
            throw "Dossier introuvable pour $($app.Name) : $($app.Root)"
        }

        if (Test-AppReady -Url $app.Url) {
            Write-Host "$($app.Name) est deja disponible sur $($app.Url)"
            $startedApps += [PSCustomObject]@{ Name = $app.Name; ProcessId = $null; Url = $app.Url }
            continue
        }

        if (-not (Test-Path -LiteralPath (Join-Path $app.Root 'node_modules'))) {
            Write-Host "Installation des dependances de $($app.Name)..."
            & $npmCommand.Source install --prefix $app.Root
            if ($LASTEXITCODE -ne 0) { throw "Echec de npm install pour $($app.Name)." }
        }

        Write-Host "Demarrage de $($app.Name)..."
        $process = Start-Process -FilePath $npmCommand.Source -ArgumentList $app.Arguments -WorkingDirectory $app.Root -WindowStyle Hidden -PassThru
        $startedApps += [PSCustomObject]@{ Name = $app.Name; ProcessId = $process.Id; Url = $app.Url }
        $startedApps | ConvertTo-Json | Set-Content -LiteralPath $stateFile -Encoding utf8
    }

    foreach ($startedApp in $startedApps) {
        $ready = $false
        $deadline = (Get-Date).AddSeconds(120)
        while ((Get-Date) -lt $deadline) {
            if ($startedApp.ProcessId -and -not (Get-Process -Id $startedApp.ProcessId -ErrorAction SilentlyContinue)) { throw "$($startedApp.Name) s'est arrete avant de repondre." }
            if (Test-AppReady -Url $startedApp.Url) { $ready = $true; break }
            Start-Sleep -Milliseconds 500
        }
        if (-not $ready) { throw "$($startedApp.Name) ne repond pas sur $($startedApp.Url) apres 120 secondes." }
        if ($startedApp.Name -eq 'Eglise Core API') { $coreReady = $true }
        Write-Host "OK - $($startedApp.Name) : $($startedApp.Url)"
    }
}
catch {
    $failure = $_
    if (Test-Path -LiteralPath $stateFile) { & (Join-Path $PSScriptRoot 'stop-app.ps1') }
    Write-Error $failure
    exit 1
}

Write-Host 'Les trois applications Bible Open sont disponibles.'
if (-not $NoBrowser) { Start-Process 'http://localhost:5174/' }
