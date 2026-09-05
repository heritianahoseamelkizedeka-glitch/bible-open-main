param(
    [switch]$NoBrowser,
    [switch]$ListOnly,
    [switch]$CheckOnly,
    [switch]$RequireCore,
    [string]$CoreApiUrl = $(if ($env:CORE_API_URL) { $env:CORE_API_URL } else { 'http://127.0.0.1:8085/api/v1' })
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'core-readiness.ps1')
if ($CheckOnly -and $ListOnly) { throw 'Choisir CheckOnly ou ListOnly.' }
if (-not $ListOnly) {
    $coreReady = Test-CoreReady -ApiUrl $CoreApiUrl
    if ($coreReady) { Write-Host 'OK - API Core prete (base et migrations).' -ForegroundColor Green }
    else { Write-Warning 'API Core non prete. Authentification et fonctions dependantes indisponibles. Demarrer/configurer Core et ses migrations.' }
    if ($CheckOnly) { if ($coreReady) { exit 0 } else { exit 1 } }
    if ($RequireCore -and -not $coreReady) { throw 'Demarrage annule : API Core non prete. Aucun processus arrete ou lance.' }
}
$mainRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workspaceRoot = Split-Path -Parent $mainRoot
$stateFile = Join-Path $PSScriptRoot '.dev-servers.json'
$npmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue

if (-not $npmCommand) {
    Write-Error 'npm est introuvable. Installez Node.js avec npm, puis relancez le launcher.'
    exit 1
}

$apps = @(
    [PSCustomObject]@{ Name = 'Bible Open Main'; Root = Join-Path $mainRoot 'Frontend\web'; Url = 'http://localhost:5174/'; Arguments = @('run', 'dev', '--', '--port', '5174', '--strictPort'); Required = $true },
    [PSCustomObject]@{ Name = 'Quizz Biblique'; Root = Join-Path $workspaceRoot 'APK Quizz Biblique BO v2\Frontend\web'; Url = 'http://localhost:5173/'; Arguments = @('run', 'dev', '--', '--port', '5173', '--strictPort'); Required = $true },
    [PSCustomObject]@{ Name = 'Study Bible'; Root = Join-Path $workspaceRoot 'Study-bible-open\Frontend\web'; Url = 'http://localhost:9891/'; Arguments = @('run', 'dev'); Required = $true },
    [PSCustomObject]@{ Name = 'Communaute Eglise'; Root = Join-Path $workspaceRoot 'communaute-eglise\Frontend\web'; Url = 'http://localhost:5180/'; Arguments = @('run', 'dev', '--', '--host', '0.0.0.0', '--port', '5180', '--strictPort'); Required = $true },
    [PSCustomObject]@{ Name = 'Intendance Eglise'; Root = Join-Path $workspaceRoot 'intendance-eglise\Frontend\web'; Url = 'http://localhost:5190/'; Arguments = @('run', 'dev', '--', '--host', '0.0.0.0', '--port', '5190', '--strictPort'); Required = $true },
    [PSCustomObject]@{ Name = 'Eglise Core'; Root = Join-Path $workspaceRoot 'eglise-core\Frontend\web'; Url = 'http://localhost:5181/'; Arguments = @('run', 'dev', '--', '--host', '0.0.0.0', '--port', '5181', '--strictPort'); Required = $false },
    [PSCustomObject]@{ Name = 'Communication Eglise'; Root = Join-Path $workspaceRoot 'communication-eglise\Frontend\web'; Url = 'http://localhost:5182/'; Arguments = @('run', 'dev', '--', '--host', '0.0.0.0', '--port', '5182', '--strictPort'); Required = $false },
    [PSCustomObject]@{ Name = 'Vie pastorale Eglise'; Root = Join-Path $workspaceRoot 'vie-pastorale-eglise\Frontend\web'; Url = 'http://localhost:5183/'; Arguments = @('run', 'dev', '--', '--host', '0.0.0.0', '--port', '5183', '--strictPort'); Required = $false }
)

function Test-AppReady {
    param([string]$Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3
        return $response.StatusCode -ge 200 -and $response.StatusCode -lt 500
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

if (Test-Path -LiteralPath $stateFile) {
    & (Join-Path $PSScriptRoot 'stop-app.ps1')
}

$startedApps = @()

try {
    foreach ($app in $apps) {
        $packageFile = Join-Path $app.Root 'package.json'
        if (-not (Test-Path -LiteralPath $packageFile)) {
            if ($app.Required) { throw "Application requise introuvable pour $($app.Name) : $packageFile" }
            Write-Host "NON DISPONIBLE - $($app.Name) (frontend pas encore construit)" -ForegroundColor DarkYellow
            continue
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
            if ($startedApp.ProcessId -and -not (Get-Process -Id $startedApp.ProcessId -ErrorAction SilentlyContinue)) {
                throw "$($startedApp.Name) s'est arrete avant de repondre."
            }
            if (Test-AppReady -Url $startedApp.Url) { $ready = $true; break }
            Start-Sleep -Milliseconds 500
        }
        if (-not $ready) { throw "$($startedApp.Name) ne repond pas sur $($startedApp.Url) apres 120 secondes." }
        Write-Host "OK - $($startedApp.Name) : $($startedApp.Url)"
    }
}
catch {
    $failure = $_
    if (Test-Path -LiteralPath $stateFile) { & (Join-Path $PSScriptRoot 'stop-app.ps1') }
    Write-Error $failure
    exit 1
}

Write-Host "`nFrontends Bible Open disponibles :" -ForegroundColor Green
if (-not $coreReady) { Write-Warning 'Mode degrade : API Core non prete lors du controle initial.' }
foreach ($startedApp in $startedApps) {
    Write-Host " - $($startedApp.Name) : $($startedApp.Url)" -ForegroundColor Green
}
if (-not $NoBrowser) { Start-Process 'http://localhost:5174/' }
