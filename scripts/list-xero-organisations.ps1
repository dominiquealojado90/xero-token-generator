param(
  [string]$AccessToken
)

$ErrorActionPreference = "Stop"

if (-not $AccessToken) {
  $AccessToken = Read-Host "Enter Xero Access Token (XERO_CLIENT_BEARER_TOKEN)"
}

$connections = Invoke-RestMethod -Method Get -Uri "https://api.xero.com/connections" -Headers @{
  Authorization = "Bearer $AccessToken"
  Accept = "application/json"
}

if (-not $connections -or $connections.Count -eq 0) {
  Write-Host "No connected organisations were found for this token."
  exit 0
}

Write-Host ""
Write-Host "Connected organisations:"
$connections | Select-Object tenantName, tenantId, tenantType, createdDateUtc | Format-Table -AutoSize
