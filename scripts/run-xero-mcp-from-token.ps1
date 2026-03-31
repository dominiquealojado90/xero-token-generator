param(
  [string]$TokenFile = "",
  [string]$Profile = "default",
  [string]$ClientId = "",
  [string]$ClientSecret = "",
  [int]$RefreshSkewMinutes = 5
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ([string]::IsNullOrWhiteSpace($TokenFile)) {
  if ($Profile -eq "default") {
    $TokenFile = "$PSScriptRoot\..\xero-tokens.json"
  }
  else {
    $TokenFile = "$PSScriptRoot\..\xero-tokens.$Profile.json"
  }
}

if (-not (Test-Path -LiteralPath $TokenFile)) {
  throw "Token file not found: $TokenFile. Run get-xero-token.ps1 first."
}

$tokenData = Get-Content -Raw -LiteralPath $TokenFile | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($ClientId)) {
  $ClientId = $env:XERO_CLIENT_ID
}
if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
  $ClientSecret = $env:XERO_CLIENT_SECRET
}

$needsRefresh = $false
if ($tokenData.expires_at_utc) {
  try {
    $expiresAt = [DateTime]::Parse([string]$tokenData.expires_at_utc).ToUniversalTime()
    $threshold = (Get-Date).ToUniversalTime().AddMinutes($RefreshSkewMinutes)
    if ($expiresAt -le $threshold) {
      $needsRefresh = $true
    }
  }
  catch {
    $needsRefresh = $true
  }
}

if (-not $tokenData.access_token) {
  $needsRefresh = $true
}

if ($needsRefresh -and $tokenData.refresh_token -and $ClientId -and $ClientSecret) {
  try {
    $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$ClientId`:$ClientSecret"))
    $refreshed = Invoke-RestMethod -Method Post -Uri "https://identity.xero.com/connect/token" -Headers @{
      Authorization = "Basic $basic"
      "Content-Type" = "application/x-www-form-urlencoded"
    } -Body "grant_type=refresh_token&refresh_token=$([uri]::EscapeDataString([string]$tokenData.refresh_token))"

    $expiresAtUtc = (Get-Date).ToUniversalTime().AddSeconds([int]$refreshed.expires_in)
    $tokenData = [pscustomobject]@{
      access_token = $refreshed.access_token
      refresh_token = $refreshed.refresh_token
      expires_in_seconds = [int]$refreshed.expires_in
      expires_at_utc = $expiresAtUtc.ToString("o")
    }
    $tokenData | ConvertTo-Json | Set-Content -LiteralPath $TokenFile -Encoding UTF8
  }
  catch {
    # Do not kill MCP startup if refresh endpoint has a transient failure.
    if (-not $tokenData.access_token) {
      throw
    }
  }
}

$accessToken = [string]$tokenData.access_token

if ([string]::IsNullOrWhiteSpace($accessToken)) {
  throw "access_token missing/expired and auto-refresh could not run. Provide XERO_CLIENT_ID and XERO_CLIENT_SECRET in config, then retry."
}

$env:XERO_CLIENT_BEARER_TOKEN = $accessToken

# Avoid Windows/AppData permission issues by using a project-local npm cache.
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$npmCache = Join-Path $projectRoot ".npm-cache"
New-Item -ItemType Directory -Force -Path $npmCache | Out-Null
$env:npm_config_cache = $npmCache
$env:npm_config_loglevel = "error"
$env:npm_config_update_notifier = "false"
$env:npm_config_fund = "false"

& npx.cmd --yes --cache $npmCache --loglevel=error @xeroapi/xero-mcp-server@latest
