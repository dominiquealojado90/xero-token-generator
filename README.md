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
- `accounting.transactions accounting.transactions.read accounting.invoices accounting.invoices.read accounting.payments accounting.payments.read accounting.banktransactions accounting.banktransactions.read accounting.manualjournals accounting.manualjournals.read accounting.reports.read accounting.reports.aged.read accounting.reports.balancesheet.read accounting.reports.profitandloss.read accounting.reports.trialbalance.read accounting.contacts accounting.settings payroll.settings payroll.employees payroll.timesheets`
- You can still choose your own scopes when running the script with `-Scopes "..."`
- Scope compatibility note: some scopes are deprecated or app-type dependent. If you get `invalid_scope`, remove unsupported scopes for your app in Xero Developer settings (notably around the March 2, 2026 to April 2026 migration period).

Requested scope set (exact):
- `accounting.transactions` (Deprecated)
- `accounting.transactions.read` (Deprecated)
- `accounting.invoices`
- `accounting.invoices.read`
- `accounting.payments`
- `accounting.payments.read`
- `accounting.banktransactions`
- `accounting.banktransactions.read`
- `accounting.manualjournals`
- `accounting.manualjournals.read`
- `accounting.reports.read` (Deprecated)
- `accounting.reports.aged.read`
- `accounting.reports.balancesheet.read`
- `accounting.reports.profitandloss.read`
- `accounting.reports.trialbalance.read`
- `accounting.contacts`
- `accounting.settings`
- `payroll.settings`
- `payroll.employees`
- `payroll.timesheets`

Supported MCP operations:
- `list-accounts`: Retrieve a list of accounts
- `list-contacts`: Retrieve a list of contacts from Xero
- `list-credit-notes`: Retrieve a list of credit notes
- `list-invoices`: Retrieve a list of invoices
- `list-items`: Retrieve a list of items
- `list-manual-journals`: Retrieve a list of manual journals
- `list-organisation-details`: Retrieve details about an organisation
- `list-profit-and-loss`: Retrieve a profit and loss report
- `list-quotes`: Retrieve a list of quotes
- `list-tax-rates`: Retrieve a list of tax rates
- `list-payments`: Retrieve a list of payments
- `list-trial-balance`: Retrieve a trial balance report
- `list-bank-transactions`: Retrieve a list of bank account transactions
- `list-payroll-employees`: Retrieve a list of Payroll Employees
- `list-report-balance-sheet`: Retrieve a balance sheet report
- `list-payroll-employee-leave`: Retrieve a Payroll Employee's leave records
- `list-payroll-employee-leave-balances`: Retrieve a Payroll Employee's leave balances
- `list-payroll-employee-leave-types`: Retrieve a list of Payroll leave types
- `list-payroll-leave-periods`: Retrieve a list of a Payroll Employee's leave periods
- `list-payroll-leave-types`: Retrieve a list of all available leave types in Xero Payroll
- `list-timesheets`: Retrieve a list of Payroll Timesheets
- `list-aged-receivables-by-contact`: Retrieves aged receivables for a contact
- `list-aged-payables-by-contact`: Retrieves aged payables for a contact
- `list-contact-groups`: Retrieve a list of contact groups
- `list-tracking-categories`: Retrieve a list of tracking categories
- `create-bank-transaction`: Create a new bank transaction
- `create-contact`: Create a new contact
- `create-credit-note`: Create a new credit note
- `create-invoice`: Create a new invoice
- `create-item`: Create a new item
- `create-manual-journal`: Create a new manual journal
- `create-payment`: Create a new payment
- `create-quote`: Create a new quote
- `create-payroll-timesheet`: Create a new Payroll Timesheet
- `create-tracking-category`: Create a new tracking category
- `create-tracking-option`: Create a new tracking option
- `update-bank-transaction`: Update an existing bank transaction
- `update-contact`: Update an existing contact
- `update-invoice`: Update an existing draft invoice
- `update-item`: Update an existing item
- `update-manual-journal`: Update an existing manual journal
- `update-quote`: Update an existing draft quote
- `update-credit-note`: Update an existing draft credit note
- `update-tracking-category`: Update an existing tracking category
- `update-tracking-options`: Update tracking options
- `update-payroll-timesheet-line`: Update a line on an existing Payroll Timesheet
- `approve-payroll-timesheet`: Approve a Payroll Timesheet
- `revert-payroll-timesheet`: Revert an approved Payroll Timesheet
- `add-payroll-timesheet-line`: Add new line on an existing Payroll Timesheet
- `delete-payroll-timesheet`: Delete an existing Payroll Timesheet
- `get-payroll-timesheet`: Retrieve an existing Payroll Timesheet

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
