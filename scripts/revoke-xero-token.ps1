param(
  [ValidateSet("disconnect_org", "revoke_refresh")]
  [string]$Mode,
  [string]$AccessToken,
  [string]$ConnectionId,
  [string]$ClientId,
  [string]$ClientSecret,
  [string]$RefreshToken
)

$ErrorActionPreference = "Stop"

function Require-Value([string]$value, [string]$prompt) {
  if (-not $value) {
    return (Read-Host $prompt)
  }
  return $value
}

function Disconnect-Org {
  param(
    [string]$Token,
    [string]$SelectedConnectionId
  )

  $Token = Require-Value $Token "Enter Xero Access Token"

  if (-not $SelectedConnectionId) {
    $connections = Invoke-RestMethod -Method Get -Uri "https://api.xero.com/connections" -Headers @{
      Authorization = "Bearer $Token"
      Accept = "application/json"
    }

    if (-not $connections -or $connections.Count -eq 0) {
      Write-Host "No active connections found for this token."
      return
    }

    Write-Host ""
    Write-Host "Choose organisation to disconnect:"
    for ($i = 0; $i -lt $connections.Count; $i++) {
      $c = $connections[$i]
      Write-Host "[$($i+1)] $($c.tenantName)  (connectionId: $($c.id), tenantId: $($c.tenantId))"
    }

    $pick = Read-Host "Enter number"
    $index = [int]$pick - 1
    if ($index -lt 0 -or $index -ge $connections.Count) {
      throw "Invalid selection."
    }

    $SelectedConnectionId = $connections[$index].id
  }

  Invoke-RestMethod -Method Delete -Uri "https://api.xero.com/connections/$SelectedConnectionId" -Headers @{
    Authorization = "Bearer $Token"
    Accept = "application/json"
  }

  Write-Host ""
  Write-Host "SUCCESS: Disconnected connectionId $SelectedConnectionId"
}

function Revoke-RefreshToken {
  param(
    [string]$Id,
    [string]$Secret,
    [string]$Token
  )

  $Id = Require-Value $Id "Enter Xero Client ID"
  $Secret = Require-Value $Secret "Enter Xero Client Secret"
  $Token = Require-Value $Token "Enter Refresh Token to revoke"

  $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Id`:$Secret"))

  Invoke-RestMethod -Method Post -Uri "https://identity.xero.com/connect/revocation" -Headers @{
    Authorization = "Basic $basic"
    "Content-Type" = "application/x-www-form-urlencoded"
  } -Body "token=$([uri]::EscapeDataString($Token))&token_type_hint=refresh_token" | Out-Null

  Write-Host ""
  Write-Host "SUCCESS: Refresh token revoked."
}

if (-not $Mode) {
  Write-Host "What do you want to do?"
  Write-Host "[1] Disconnect one organisation"
  Write-Host "[2] Revoke a refresh token"
  $choice = Read-Host "Enter 1 or 2"
  if ($choice -eq "1") { $Mode = "disconnect_org" }
  elseif ($choice -eq "2") { $Mode = "revoke_refresh" }
  else { throw "Invalid choice." }
}

if ($Mode -eq "disconnect_org") {
  Disconnect-Org -Token $AccessToken -SelectedConnectionId $ConnectionId
} else {
  Revoke-RefreshToken -Id $ClientId -Secret $ClientSecret -Token $RefreshToken
}
