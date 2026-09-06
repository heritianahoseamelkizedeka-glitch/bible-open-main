param([switch]$NoBrowser)

$ErrorActionPreference = 'Stop'
$mainRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workspaceRoot = Split-Path -Parent $mainRoot
$stateFile = Join-Path $PSScriptRoot '.dev-servers.json'
$configPath = Join-Path $mainRoot 'Frontend\web\public\config\applications.json'
$npmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue

if (-not $npmCommand) {
    Write-Error 'npm est introuvable. Installez Node.js avec npm, puis relancez le launcher.'
    exit 1
}
if (-not (Test-Path -LiteralPath $configPath)) { throw "Configuration introuvable : $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json

function Resolve-AppRepositoryRoot {
    param($App)
    if ($App.rootEnv) {
        $override = [Environment]::GetEnvironmentVariable([string]$App.rootEnv)
        if ($override) { return $override }
    }
    if ($App.rootType -eq 'main') { return [System.IO.Path]::GetFullPath((Join-Path $mainRoot $App.rootPath)) }
    return [System.IO.Path]::GetFullPath((Join-Path $workspaceRoot $App.rootPath))
}

$portalRepo = Resolve-AppRepositoryRoot $config.applications.portal
$quizRepo = Resolve-AppRepositoryRoot $config.applications.quiz
$studyRepo = Resolve-AppRepositoryRoot $config.applications.study

$apps = @(
    [PSCustomObject]@{ Name = $config.applications.portal.name; Root = Join-Path $portalRepo $config.applications.portal.webPath; Url = $config.applications.portal.localUrl; Arguments = @('run', 'dev', '--', '--port', [string]$config.applications.portal.port, '--strictPort') },
    [PSCustomObject]@{ Name = $config.applications.quiz.name; Root = Join-Path $quizRepo $config.applications.quiz.webPath; Url = $config.applications.quiz.localUrl; Arguments = @('run', 'dev', '--', '--port', [string]$config.applications.quiz.port, '--strictPort') },
    [PSCustomObject]@{ Name = $config.applications.study.name; Root = Join-Path $studyRepo $config.applications.study.webPath; Url = $config.applications.study.localUrl; Arguments = @('run', 'dev') }
)

function Test-AppReady {
    param([string]$Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3
        return $response.StatusCode -ge 200 -and $response.StatusCode -lt 400
    } catch { return $false }
}

if (Test-Path -LiteralPath $stateFile) { & (Join-Path $PSScriptRoot 'stop-app.ps1') }
$startedApps = @()

try {
    foreach ($app in $apps) {
        if (-not (Test-Path -LiteralPath $app.Root)) { throw "Dossier introuvable pour $($app.Name) : $($app.Root)" }

        if (Test-AppReady -Url $app.Url) {
            Write-Host "$($app.Name) est deja disponible sur $($app.Url)"
            $startedApps += [PSCustomObject]@{ Name = $app.Name; ProcessId = $null; Url = $app.Url; StartedAt = $null }
            continue
        }

        if (-not (Test-Path -LiteralPath (Join-Path $app.Root 'node_modules'))) {
            Write-Host "Installation des dependances de $($app.Name)..."
            & $npmCommand.Source install --prefix $app.Root
            if ($LASTEXITCODE -ne 0) { throw "Echec de npm install pour $($app.Name)." }
        }

        Write-Host "Demarrage de $($app.Name)..."
        $process = Start-Process -FilePath $npmCommand.Source -ArgumentList $app.Arguments -WorkingDirectory $app.Root -WindowStyle Hidden -PassThru
        $startedApps += [PSCustomObject]@{ Name = $app.Name; ProcessId = $process.Id; Url = $app.Url; StartedAt = $process.StartTime.ToString('o') }
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
        Write-Host "OK - $($startedApp.Name) : $($startedApp.Url)"
    }
}
catch {
    $failure = $_
    if (Test-Path -LiteralPath $stateFile) { & (Join-Path $PSScriptRoot 'stop-app.ps1') }
    Write-Error $failure
    exit 1
}

Write-Host 'Les applications Bible Open configurees sont disponibles.'
if (-not $NoBrowser) { Start-Process $config.applications.portal.localUrl }
