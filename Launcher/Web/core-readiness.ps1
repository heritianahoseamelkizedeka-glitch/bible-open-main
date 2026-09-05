function Test-CoreReady {
    param([Parameter(Mandatory = $true)][string]$ApiUrl)
    $baseUri = $null
    if (-not [Uri]::TryCreate($ApiUrl, [UriKind]::Absolute, [ref]$baseUri) -or
        $baseUri.Scheme -notin @('http', 'https') -or $baseUri.UserInfo -or
        $baseUri.Query -or $baseUri.Fragment) {
        throw 'CoreApiUrl doit etre une URL HTTP(S) absolue sans identifiants, query ou fragment.'
    }
    try {
        $response = Invoke-WebRequest -Uri ($ApiUrl.TrimEnd('/') + '/ready') -UseBasicParsing -TimeoutSec 10 -MaximumRedirection 0 -ErrorAction Stop
        if ($response.StatusCode -ne 200) { return $false }
        $body = $response.Content | ConvertFrom-Json -ErrorAction Stop
        return $body.status -ceq 'ready' -and $body.service -ceq 'eglise-core-api'
    } catch { return $false }
}
