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

Default scopes:
- `openid profile email offline_access accounting.transactions accounting.transactions.read accounting.invoices accounting.invoices.read accounting.payments accounting.payments.read accounting.banktransactions accounting.banktransactions.read accounting.manualjournals accounting.manualjournals.read accounting.reports.read accounting.reports.aged.read accounting.reports.balancesheet.read accounting.reports.profitandloss.read accounting.reports.trialbalance.read accounting.contacts accounting.settings payroll.settings payroll.employees payroll.timesheets`
- You can still choose your own scopes when running the script with `-Scopes "..."`
- Scope compatibility note: some scopes are deprecated or app-type dependent. If you get `invalid_scope`, remove unsupported scopes for your app in Xero Developer settings (notably around the March 2, 2026 to April 2026 migration period).

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
