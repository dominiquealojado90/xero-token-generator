param(
  [string]$ClientId,
  [string]$ClientSecret,
  [string]$RefreshToken,
  [string]$TokenFile = "",
  [string]$Profile = "default",
  [switch]$Loop,
  [int]$LoopMinutes = 25
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ([string]::IsNullOrWhiteSpace($TokenFile)) {
  if ($Profile -eq "default") {
    $TokenFile = ".\\xero-tokens.json"
  }
  else {
    $TokenFile = ".\\xero-tokens.$Profile.json"
  }
}

if ($LoopMinutes -lt 1) {
  throw "LoopMinutes must be 1 or greater."
}

if (-not $ClientId) {
  $ClientId = Read-Host "Enter Xero Client ID"
}

if (-not $ClientSecret) {
  $ClientSecret = Read-Host "Enter Xero Client Secret"
}

if (-not $RefreshToken -and (Test-Path -LiteralPath $TokenFile)) {
  try {
    $saved = Get-Content -Raw -LiteralPath $TokenFile | ConvertFrom-Json
    if ($saved.refresh_token) {
      $RefreshToken = [string]$saved.refresh_token
      Write-Host "Using refresh token from $TokenFile"
    }
  }
  catch {
    Write-Host "Could not parse $TokenFile. Falling back to manual input."
  }
}

if (-not $RefreshToken) {
  $RefreshToken = Read-Host "Enter Xero Refresh Token"
}

$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$ClientId`:$ClientSecret"))

while ($true) {
  $token = Invoke-RestMethod -Method Post -Uri "https://identity.xero.com/connect/token" -Headers @{
    Authorization = "Basic $basic"
    "Content-Type" = "application/x-www-form-urlencoded"
  } -Body "grant_type=refresh_token&refresh_token=$([uri]::EscapeDataString($RefreshToken))"

  $expiresAtUtc = (Get-Date).ToUniversalTime().AddSeconds([int]$token.expires_in)
  $tokenPayload = [pscustomobject]@{
    access_token = $token.access_token
    refresh_token = $token.refresh_token
    expires_in_seconds = [int]$token.expires_in
    expires_at_utc = $expiresAtUtc.ToString("o")
  }
  $tokenPayload | ConvertTo-Json | Set-Content -LiteralPath $TokenFile -Encoding UTF8

  Write-Host ""
  Write-Host "SUCCESS"
  Write-Host "New Access Token (use as XERO_CLIENT_BEARER_TOKEN):"
  Write-Host $token.access_token
  Write-Host ""
  Write-Host "New Refresh Token (replace old one):"
  Write-Host $token.refresh_token
  Write-Host ""
  Write-Host "Expires in seconds:"
  Write-Host $token.expires_in
  Write-Host "Expires at (UTC):"
  Write-Host $expiresAtUtc.ToString("yyyy-MM-dd HH:mm:ss")
  Write-Host "Saved tokens to: $TokenFile"

  $RefreshToken = [string]$token.refresh_token

  if (-not $Loop) {
    break
  }

  Write-Host ""
  Write-Host "Loop mode enabled. Next refresh in $LoopMinutes minutes..."
  Start-Sleep -Seconds ($LoopMinutes * 60)
}
