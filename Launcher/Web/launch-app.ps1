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

if ($CheckOnly -and $ListOnly) { throw 'Choisir CheckOnly ou ListOnly.' }

$mainRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workspaceRoot = Split-Path -Parent $mainRoot
$stateFile = Join-Path $PSScriptRoot '.dev-servers.json'
$configPath = Join-Path $mainRoot 'Frontend\web\public\config\applications.json'
$npmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue

if (-not $npmCommand) {
    Write-Error 'npm est introuvable. Installez Node.js avec npm, puis relancez le launcher.'
    exit 1
}

if (-not (Test-Path -LiteralPath $configPath)) {
    Write-Error "Registre d'applications introuvable : $configPath"
    exit 1
}

$registry = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
if (-not $registry.applications) {
    Write-Error 'Le registre des applications est invalide : section applications absente.'
    exit 1
}

function Resolve-RepositoryRoot {
    param($Definition)

    if ([string]$Definition.rootType -eq 'main') { return $mainRoot }

    if ($Definition.rootEnv) {
        $override = [Environment]::GetEnvironmentVariable([string]$Definition.rootEnv)
        if (-not [string]::IsNullOrWhiteSpace($override)) { return $override }
    }

    return Join-Path $workspaceRoot ([string]$Definition.rootPath)
}

function Resolve-WebRoot {
    param([string]$RepositoryRoot, [string]$WebPath)
    if ([string]::IsNullOrWhiteSpace($WebPath) -or $WebPath -eq '.') { return $RepositoryRoot }
    return Join-Path $RepositoryRoot $WebPath
}

function Test-HttpReady {
    param([string]$Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3 -MaximumRedirection 0 -ErrorAction Stop
        return $response.StatusCode -ge 200 -and $response.StatusCode -lt 400
    } catch { return $false }
}

if ($CheckOnly) {
    $coreReady = Test-CoreReady -ApiUrl $CoreApiUrl
    if ($coreReady) {
        Write-Host 'OK - API Core prete (base et migrations).' -ForegroundColor Green
        exit 0
    }
    Write-Warning 'API Core non prete.'
    exit 1
}

$apps = @()
foreach ($property in $registry.applications.PSObject.Properties) {
    $appId = [string]$property.Name
    $definition = $property.Value
    $repoRoot = Resolve-RepositoryRoot -Definition $definition
    $webRoot = Resolve-WebRoot -RepositoryRoot $repoRoot -WebPath ([string]$definition.webPath)
    $port = [int]$definition.port

    $arguments = if ($appId -eq 'study') {
        @('run', 'dev')
    } else {
        @('run', 'dev', '--', '--host', '0.0.0.0', '--port', [string]$port, '--strictPort')
    }

    $apps += [PSCustomObject]@{
        Id = $appId
        Name = [string]$definition.name
        Root = $webRoot
        Url = [string]$definition.localUrl
        Arguments = $arguments
        Required = [bool]$definition.required
        Kind = 'frontend'
    }
}

$apis = @()
if ($StartApis) {
    $apis = @(
        [PSCustomObject]@{ Id = 'core-api'; Name = 'Eglise Core API'; Root = Join-Path $workspaceRoot 'eglise-core\Backend'; Url = ($CoreApiUrl.TrimEnd('/') + '/ready'); Arguments = @('run', 'dev'); Required = $RequireCore; Kind = 'core-api' },
        [PSCustomObject]@{ Id = 'communication-api'; Name = 'Communication Eglise API'; Root = Join-Path $workspaceRoot 'communication-eglise\Backend'; Url = 'http://127.0.0.1:8082/api/v1/communication/health'; Arguments = @('run', 'dev'); Required = $false; Kind = 'api' },
        [PSCustomObject]@{ Id = 'pastoral-api'; Name = 'Vie pastorale Eglise API'; Root = Join-Path $workspaceRoot 'vie-pastorale-eglise\Backend'; Url = 'http://127.0.0.1:8083/api/v1/pastoral/health'; Arguments = @('run', 'dev'); Required = $false; Kind = 'api' },
        [PSCustomObject]@{ Id = 'worship-api'; Name = 'Louange Eglise API'; Root = Join-Path $workspaceRoot 'louange-eglise\Backend'; Url = 'http://127.0.0.1:8086/api/v1/louange/health'; Arguments = @('run', 'dev'); Required = $false; Kind = 'api' }
    )
}

if ($ListOnly) {
    Write-Host 'Applications configurees dans le launcher principal :' -ForegroundColor Cyan
    foreach ($target in @($apis) + @($apps)) {
        $available = Test-Path -LiteralPath (Join-Path $target.Root 'package.json')
        $status = if ($available) { 'MANIFESTE PRESENT' } else { 'NON CONSTRUITE' }
        $color = if ($available) { 'Green' } else { 'DarkYellow' }
        Write-Host " - [$status] $($target.Name) - $($target.Url)" -ForegroundColor $color
    }
    exit 0
}

if (-not $StartApis) {
    $coreReady = Test-CoreReady -ApiUrl $CoreApiUrl
    if ($coreReady) {
        Write-Host 'OK - API Core prete (base et migrations).' -ForegroundColor Green
    } else {
        Write-Warning 'API Core non prete. Authentification et fonctions dependantes seront indisponibles.'
        if ($RequireCore) { throw 'Demarrage annule : API Core non prete.' }
    }
}

if (Test-Path -LiteralPath $stateFile) {
    & (Join-Path $PSScriptRoot 'stop-app.ps1')
}

$startedTargets = @()

function Save-LauncherState {
    $startedTargets | ConvertTo-Json | Set-Content -LiteralPath $stateFile -Encoding utf8
}

function Start-Target {
    param($Target)

    $packageFile = Join-Path $Target.Root 'package.json'
    if (-not (Test-Path -LiteralPath $packageFile)) {
        if ($Target.Required) { throw "Application requise introuvable pour $($Target.Name) : $packageFile" }
        Write-Host "NON DISPONIBLE - $($Target.Name)" -ForegroundColor DarkYellow
        return
    }

    $alreadyReady = if ($Target.Kind -eq 'core-api') {
        Test-CoreReady -ApiUrl $CoreApiUrl
    } else {
        Test-HttpReady -Url $Target.Url
    }

    if ($alreadyReady) {
        Write-Host "$($Target.Name) est deja disponible sur $($Target.Url)"
        $script:startedTargets += [PSCustomObject]@{ Name = $Target.Name; ProcessId = $null; StartedAt = $null; Url = $Target.Url; Kind = $Target.Kind }
        return
    }

    if (-not (Test-Path -LiteralPath (Join-Path $Target.Root 'node_modules'))) {
        Write-Host "Installation des dependances de $($Target.Name)..."
        & $npmCommand.Source install --prefix $Target.Root
        if ($LASTEXITCODE -ne 0) { throw "Echec de npm install pour $($Target.Name)." }
    }

    Write-Host "Demarrage de $($Target.Name)..."
    $process = Start-Process -FilePath $npmCommand.Source -ArgumentList $Target.Arguments -WorkingDirectory $Target.Root -WindowStyle Hidden -PassThru
    $process.Refresh()
    $script:startedTargets += [PSCustomObject]@{
        Name = $Target.Name
        ProcessId = $process.Id
        StartedAt = $process.StartTime.ToUniversalTime().ToString('o')
        Url = $Target.Url
        Kind = $Target.Kind
    }
    Save-LauncherState
}

try {
    foreach ($api in $apis) { Start-Target -Target $api }
    foreach ($app in $apps) { Start-Target -Target $app }

    foreach ($startedTarget in $startedTargets) {
        $ready = $false
        $deadline = (Get-Date).AddSeconds(120)
        while ((Get-Date) -lt $deadline) {
            if ($startedTarget.ProcessId -and -not (Get-Process -Id $startedTarget.ProcessId -ErrorAction SilentlyContinue)) {
                throw "$($startedTarget.Name) s'est arrete avant de repondre."
            }

            $ready = if ($startedTarget.Kind -eq 'core-api') {
                Test-CoreReady -ApiUrl $CoreApiUrl
            } else {
                Test-HttpReady -Url $startedTarget.Url
            }

            if ($ready) { break }
            Start-Sleep -Milliseconds 500
        }

        if (-not $ready) { throw "$($startedTarget.Name) ne repond pas sur $($startedTarget.Url) apres 120 secondes." }
        Write-Host "OK - $($startedTarget.Name) : $($startedTarget.Url)" -ForegroundColor Green
    }
}
catch {
    $failure = $_
    if (Test-Path -LiteralPath $stateFile) { & (Join-Path $PSScriptRoot 'stop-app.ps1') }
    Write-Error $failure
    exit 1
}

Write-Host "`nBible Open est disponible :" -ForegroundColor Green
foreach ($startedTarget in $startedTargets) {
    Write-Host " - $($startedTarget.Name) : $($startedTarget.Url)" -ForegroundColor Green
}

if (-not $StartApis -and -not $coreReady) {
    Write-Warning 'Mode degrade : API Core non prete.'
}

if (-not $NoBrowser) {
    $portal = $registry.applications.portal
    Start-Process ([string]$portal.localUrl)
}
