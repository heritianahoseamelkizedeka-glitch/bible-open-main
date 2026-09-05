$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'core-readiness.ps1')
$script:calls = 0
function Invoke-WebRequest {
    param($Uri, [switch]$UseBasicParsing, $TimeoutSec, $MaximumRedirection, $ErrorAction)
    $script:calls++
    if ($Uri -ne 'http://127.0.0.1:8085/api/v1/ready') { throw 'Unexpected URL' }
    if ($script:scenario -eq 'offline') { throw 'Connection refused' }
    return $script:response
}
foreach ($case in @(
    @{ Name='ready'; Code=200; Body='{"status":"ready","service":"eglise-core-api"}'; Expected=$true },
    @{ Name='wrong service'; Code=200; Body='{"status":"ready","service":"other"}'; Expected=$false },
    @{ Name='health only'; Code=200; Body='{"status":"ok","service":"eglise-core-api"}'; Expected=$false },
    @{ Name='not ready'; Code=503; Body='{"status":"not_ready","service":"eglise-core-api"}'; Expected=$false },
    @{ Name='html'; Code=200; Body='<html>Other app</html>'; Expected=$false },
    @{ Name='redirect'; Code=302; Body='{}'; Expected=$false },
    @{ Name='offline'; Code=0; Body=''; Expected=$false }
)) {
    $script:scenario = $case.Name
    $script:response = @{ StatusCode=$case.Code; Content=$case.Body }
    if ((Test-CoreReady -ApiUrl 'http://127.0.0.1:8085/api/v1/') -ne $case.Expected) { throw "Failed: $($case.Name)" }
    Write-Output "PASS: $($case.Name)"
}
foreach ($invalid in @('file:///tmp', 'relative', 'http://user:password@localhost', 'http://localhost?x=1', 'http://localhost/#fragment')) {
    $before = $script:calls
    $rejected = $false
    try { Test-CoreReady -ApiUrl $invalid | Out-Null } catch { $rejected = $true }
    if (-not $rejected -or $script:calls -ne $before) { throw 'Invalid URL was not rejected before request' }
}
Write-Output 'PASS: invalid URLs rejected before request'
