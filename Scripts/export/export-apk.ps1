param(
    [ValidateSet('debug','release')][string]$BuildType = 'debug',
    [string]$StudyServerUrl
)

$ErrorActionPreference = 'Stop'
$mainRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workspaceRoot = Split-Path -Parent $mainRoot
$configPath = Join-Path $mainRoot 'Frontend\web\public\config\applications.json'
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

function Get-CommitSha([string]$RepositoryRoot) {
    try {
        $sha = (& git -C $RepositoryRoot rev-parse HEAD 2>$null).Trim()
        if ($LASTEXITCODE -eq 0 -and $sha) { return $sha }
    } catch {}
    return $null
}

$quizRoot = Resolve-AppRepositoryRoot $config.applications.quiz
$studyRoot = Resolve-AppRepositoryRoot $config.applications.study
$quizWeb = Join-Path $quizRoot $config.applications.quiz.webPath
$destination = Join-Path $mainRoot "Artifacts\exports\APK\Bible-Open-APK_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"

if (-not (Test-Path $quizWeb) -or -not (Test-Path $studyRoot)) { throw 'Un des deux dépôts liés est introuvable.' }
New-Item -ItemType Directory -Path $destination -Force | Out-Null

Write-Host ">> APK Quizz Biblique ($BuildType)..." -ForegroundColor Cyan
$quizBuilder = Join-Path $quizWeb 'scripts\build\build-apk.ps1'
if (-not (Test-Path -LiteralPath $quizBuilder)) { throw "Script de build Quizz introuvable : $quizBuilder" }
& $quizBuilder -BuildType $BuildType
if ($LASTEXITCODE -ne 0) { throw 'Export APK Quizz échoué.' }
$quizApk = Join-Path $quizWeb "dist-exports\android-apk\quizz-biblique-v2-$BuildType.apk"
if (-not (Test-Path $quizApk)) { throw "APK Quizz introuvable : $quizApk" }
Copy-Item $quizApk (Join-Path $destination "Quizz-Biblique-$BuildType.apk") -Force

Write-Host '>> APK Study Bible...' -ForegroundColor Cyan
$studyExporter = Join-Path $studyRoot 'Scripts\export\export-android.ps1'
if (-not (Test-Path -LiteralPath $studyExporter)) { throw "Script d'export Study Bible introuvable : $studyExporter" }
$studyArgs = @{}
if ($StudyServerUrl) { $studyArgs.ServerUrl = $StudyServerUrl }
& $studyExporter @studyArgs
if ($LASTEXITCODE -ne 0) { throw 'Export APK Study Bible échoué.' }
$studyApk = Get-ChildItem (Join-Path $studyRoot 'Artifacts\exports\Android\apk') -Filter '*.apk' |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $studyApk) { throw 'APK Study Bible introuvable.' }
Copy-Item $studyApk.FullName (Join-Path $destination 'Study-Bible.apk') -Force

@{
    generated_at = (Get-Date).ToString('o')
    schema_version = 1
    build_type = $BuildType
    study_server_url = $StudyServerUrl
    commits = @{ quiz = Get-CommitSha $quizRoot; study = Get-CommitSha $studyRoot }
    files = @('Quizz-Biblique-' + $BuildType + '.apk', 'Study-Bible.apk')
} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $destination 'export-manifest.json') -Encoding utf8

Write-Host "Export APK lié terminé : $destination" -ForegroundColor Green
Get-ChildItem $destination -Filter '*.apk' | ForEach-Object { Write-Host " - $($_.Name) ($([math]::Round($_.Length / 1MB, 1)) Mo)" -ForegroundColor Green }
