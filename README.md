# Xero Token Helper (No MCP Required)

This folder helps users generate and manage Xero tokens easily.

## Quick Start

Open PowerShell in this folder:

```powershell
cd C:\Users\Developer\Desktop\tools\xero-connector
```

## 1) Get First Token

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\get-xero-token.ps1
```

What it does:
- asks for Client ID and Client Secret
- uses default callback URL: `http://localhost:8080/callback` (you can choose a different callback URL)
- opens Xero login/consent page
- asks you to paste callback URL
- prints:
  - `access_token` (use as `XERO_CLIENT_BEARER_TOKEN`)
  - `refresh_token`

Note: If browser shows `localhost:8080 can't connect`, that is normal.  
Just copy the full URL from address bar and paste into PowerShell.

## 2) Refresh Expired Token

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\refresh-xero-token.ps1
```

## 3) List Connected Organisations

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\list-xero-organisations.ps1
```

## 4) Revoke / Disconnect

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\revoke-xero-token.ps1
```

Menu options:
- `1` Disconnect one organisation
- `2` Revoke a refresh token

## Multiple Organisations

If one token can access multiple orgs, list orgs first, then choose the correct `tenantId` for your app config.

## Security

- Never share `client_secret`, `access_token`, or `refresh_token`.
- If exposed, rotate secrets/tokens immediately in Xero Developer settings.
