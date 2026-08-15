param([string]$Name = 'Bible-Open-Suite')

$ErrorActionPreference = 'Stop'
$mainRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workspaceRoot = Split-Path -Parent $mainRoot
$mainWeb = Join-Path $mainRoot 'Frontend\web'
$quizWeb = Join-Path $workspaceRoot 'APK Quizz Biblique BO v2\Frontend\web'
$studyRoot = Join-Path $workspaceRoot 'Study-bible-open'
$studyExporter = Join-Path $studyRoot 'Scripts\export\export-web.ps1'
$exportRoot = Join-Path $mainRoot 'Artifacts\exports\Web'
$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$destination = Join-Path $exportRoot "$Name`_$timestamp"

function Invoke-NpmBuild([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Dépôt lié introuvable pour $Label : $Path" }
    Write-Host ">> Build $Label..." -ForegroundColor Cyan
    Push-Location $Path
    try {
        if (-not (Test-Path 'node_modules')) { & npm install }
        if ($LASTEXITCODE -ne 0) { throw "Installation npm échouée pour $Label." }
        & npm run build
        if ($LASTEXITCODE -ne 0) { throw "Build échoué pour $Label." }
    } finally { Pop-Location }
}

New-Item -ItemType Directory -Path $destination -Force | Out-Null
Invoke-NpmBuild $mainWeb 'Bible Open Main'
Invoke-NpmBuild $quizWeb 'Quizz Biblique'

Write-Host '>> Export autonome Study Bible...' -ForegroundColor Cyan
$before = @(Get-ChildItem (Join-Path $studyRoot 'Artifacts\exports\Web') -Directory -ErrorAction SilentlyContinue | ForEach-Object FullName)
& $studyExporter -Name 'Study-Bible-Open'
if ($LASTEXITCODE -ne 0) { throw 'Export Web de Study Bible échoué.' }
$studyExport = Get-ChildItem (Join-Path $studyRoot 'Artifacts\exports\Web') -Directory |
    Where-Object { $_.FullName -notin $before } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $studyExport) { throw 'Le nouvel export Study Bible est introuvable.' }

New-Item -ItemType Directory -Path (Join-Path $destination 'portal'), (Join-Path $destination 'quiz') -Force | Out-Null
Copy-Item (Join-Path $mainWeb 'dist\*') (Join-Path $destination 'portal') -Recurse -Force
Copy-Item (Join-Path $quizWeb 'dist\*') (Join-Path $destination 'quiz') -Recurse -Force
Move-Item -LiteralPath $studyExport.FullName -Destination (Join-Path $destination 'study')

$server = @'
const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const root = __dirname;
const types = {'.html':'text/html; charset=utf-8','.js':'text/javascript','.css':'text/css','.json':'application/json','.png':'image/png','.svg':'image/svg+xml','.ico':'image/x-icon','.woff2':'font/woff2'};
function serve(folder, port) { http.createServer((req,res) => { const clean = decodeURIComponent(req.url.split('?')[0]); let file = path.join(root, folder, clean === '/' ? 'index.html' : clean); if (!file.startsWith(path.join(root, folder))) { res.writeHead(403); return res.end(); } if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) file = path.join(root, folder, 'index.html'); fs.readFile(file,(err,data)=>{ if(err){res.writeHead(404);return res.end('Introuvable');} res.writeHead(200,{'Content-Type':types[path.extname(file)]||'application/octet-stream'});res.end(data); }); }).listen(port,'127.0.0.1'); }
serve('portal', 5174); serve('quiz', 5173);
const studyDir = path.join(root, 'study');
const study = spawn(path.join(studyDir, 'node.exe'), [path.join(studyDir, 'app', 'Frontend', 'web', 'server.js')], { cwd: studyDir, env: {...process.env, PORT:'9891', HOSTNAME:'127.0.0.1'}, stdio:'inherit' });
process.on('SIGINT',()=>{study.kill();process.exit();});
console.log('Bible Open Main : http://localhost:5174'); console.log('Quizz Biblique : http://localhost:5173'); console.log('Study Bible : http://localhost:9891');
'@
Set-Content -LiteralPath (Join-Path $destination 'suite-server.cjs') -Value $server -Encoding utf8

$launcher = @'
@echo off
setlocal
title Bible Open Suite
cd /d "%~dp0"
start "" /min powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Start-Process 'http://localhost:5174'"
"%~dp0study\node.exe" "%~dp0suite-server.cjs"
pause
'@
Set-Content -LiteralPath (Join-Path $destination 'start-all.bat') -Value $launcher -Encoding ascii

@{
    generated_at = (Get-Date).ToString('o')
    repositories = @{ main = $mainRoot; quiz = $quizWeb; study = $studyRoot }
    applications = @{ portal = 'http://localhost:5174'; quiz = 'http://localhost:5173'; study = 'http://localhost:9891' }
} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $destination 'export-manifest.json') -Encoding utf8

Write-Host "Export Web lié terminé : $destination" -ForegroundColor Green
Write-Host 'Lancez start-all.bat pour démarrer les trois applications.' -ForegroundColor Green
