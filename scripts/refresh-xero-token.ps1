param(
  [string]$ClientId,
  [string]$ClientSecret,
  [string]$RefreshToken
)

$ErrorActionPreference = "Stop"

if (-not $ClientId) {
  $ClientId = Read-Host "Enter Xero Client ID"
}

if (-not $ClientSecret) {
  $ClientSecret = Read-Host "Enter Xero Client Secret"
}

if (-not $RefreshToken) {
  $RefreshToken = Read-Host "Enter Xero Refresh Token"
}

$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$ClientId`:$ClientSecret"))

$token = Invoke-RestMethod -Method Post -Uri "https://identity.xero.com/connect/token" -Headers @{
  Authorization = "Basic $basic"
  "Content-Type" = "application/x-www-form-urlencoded"
} -Body "grant_type=refresh_token&refresh_token=$([uri]::EscapeDataString($RefreshToken))"

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
