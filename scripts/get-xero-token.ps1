param(
  [string]$ClientId,
  [string]$ClientSecret,
  [string]$RedirectUri = "http://localhost:8080/callback",
  [string]$Scopes = "openid profile email offline_access accounting.transactions accounting.transactions.read accounting.invoices accounting.invoices.read accounting.payments accounting.payments.read accounting.banktransactions accounting.banktransactions.read accounting.manualjournals accounting.manualjournals.read accounting.reports.read accounting.reports.aged.read accounting.reports.balancesheet.read accounting.reports.profitandloss.read accounting.reports.trialbalance.read accounting.contacts accounting.settings payroll.settings payroll.employees payroll.timesheets"
)

$ErrorActionPreference = "Stop"

if (-not $ClientId) {
  $ClientId = Read-Host "Enter Xero Client ID"
}

if (-not $ClientSecret) {
  $ClientSecret = Read-Host "Enter Xero Client Secret"
}

$authUrl = "https://login.xero.com/identity/connect/authorize?response_type=code&client_id=$ClientId&redirect_uri=$([uri]::EscapeDataString($RedirectUri))&scope=$([uri]::EscapeDataString($Scopes))&state=abc123"

Write-Host ""
Write-Host "1) Opening Xero consent page in your browser..."
Start-Process $authUrl

Write-Host ""
Write-Host "2) After you click Allow, copy the FULL callback URL from browser address bar."
$callbackUrl = Read-Host "Paste callback URL here"

$parsedUri = [uri]$callbackUrl
$queryPairs = @{}
if ($parsedUri.Query.Length -gt 1) {
  $rawQuery = $parsedUri.Query.TrimStart('?')
  foreach ($pair in ($rawQuery -split '&')) {
    if ([string]::IsNullOrWhiteSpace($pair)) { continue }
    $kv = $pair -split '=', 2
    $key = [System.Uri]::UnescapeDataString($kv[0])
    $value = if ($kv.Length -gt 1) { [System.Uri]::UnescapeDataString($kv[1]) } else { "" }
    $queryPairs[$key] = $value
  }
}

$code = $queryPairs["code"]

if (-not $code) {
  throw "Could not find code= in the callback URL."
}

Write-Host ""
Write-Host "3) Exchanging authorization code for tokens..."

$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$ClientId`:$ClientSecret"))

$token = Invoke-RestMethod -Method Post -Uri "https://identity.xero.com/connect/token" -Headers @{
  Authorization = "Basic $basic"
  "Content-Type" = "application/x-www-form-urlencoded"
} -Body "grant_type=authorization_code&code=$([uri]::EscapeDataString($code))&redirect_uri=$([uri]::EscapeDataString($RedirectUri))"

Write-Host ""
Write-Host "SUCCESS"
Write-Host "Access Token (use as XERO_CLIENT_BEARER_TOKEN):"
Write-Host $token.access_token
Write-Host ""
Write-Host "Refresh Token (save this somewhere safe):"
Write-Host $token.refresh_token
Write-Host ""
Write-Host "Expires in seconds:"
Write-Host $token.expires_in
