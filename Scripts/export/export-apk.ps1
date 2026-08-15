param(
    [ValidateSet('debug','release')][string]$BuildType = 'debug',
    [string]$StudyServerUrl
)

$ErrorActionPreference = 'Stop'
$mainRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workspaceRoot = Split-Path -Parent $mainRoot
$quizWeb = Join-Path $workspaceRoot 'APK Quizz Biblique BO v2\Frontend\web'
$studyRoot = Join-Path $workspaceRoot 'Study-bible-open'
$destination = Join-Path $mainRoot "Artifacts\exports\APK\Bible-Open-APK_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"

if (-not (Test-Path $quizWeb) -or -not (Test-Path $studyRoot)) { throw 'Un des deux dépôts liés est introuvable.' }
New-Item -ItemType Directory -Path $destination -Force | Out-Null

Write-Host ">> APK Quizz Biblique ($BuildType)..." -ForegroundColor Cyan
& (Join-Path $quizWeb 'scripts\build\build-apk.ps1') -BuildType $BuildType
if ($LASTEXITCODE -ne 0) { throw 'Export APK Quizz échoué.' }
$quizApk = Join-Path $quizWeb "dist-exports\android-apk\quizz-biblique-v2-$BuildType.apk"
if (-not (Test-Path $quizApk)) { throw "APK Quizz introuvable : $quizApk" }
Copy-Item $quizApk (Join-Path $destination "Quizz-Biblique-$BuildType.apk") -Force

Write-Host '>> APK Study Bible...' -ForegroundColor Cyan
$studyArgs = @{}
if ($StudyServerUrl) { $studyArgs.ServerUrl = $StudyServerUrl }
& (Join-Path $studyRoot 'Scripts\export\export-android.ps1') @studyArgs
if ($LASTEXITCODE -ne 0) { throw 'Export APK Study Bible échoué.' }
$studyApk = Get-ChildItem (Join-Path $studyRoot 'Artifacts\exports\Android\apk') -Filter '*.apk' |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $studyApk) { throw 'APK Study Bible introuvable.' }
Copy-Item $studyApk.FullName (Join-Path $destination 'Study-Bible.apk') -Force

@{
    generated_at = (Get-Date).ToString('o')
    build_type = $BuildType
    study_server_url = $StudyServerUrl
    repositories = @{ main = $mainRoot; quiz = $quizWeb; study = $studyRoot }
    files = @('Quizz-Biblique-' + $BuildType + '.apk', 'Study-Bible.apk')
} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $destination 'export-manifest.json') -Encoding utf8

Write-Host "Export APK lié terminé : $destination" -ForegroundColor Green
Get-ChildItem $destination -Filter '*.apk' | ForEach-Object { Write-Host " - $($_.Name) ($([math]::Round($_.Length / 1MB, 1)) Mo)" -ForegroundColor Green }
