<#
 Loads .env into this PowerShell session, then starts Claude Code.
 Usage:  .\scripts\start.ps1
 (Claude Code does not read .env itself; .mcp.json expands ${DATABRICKS_HOST}/${DATABRICKS_TOKEN} from the environment.)
#>
$envFile = Join-Path $PSScriptRoot "..\.env"
if (-not (Test-Path $envFile)) { Write-Host ".env not found. Copy .env.example to .env and fill it in." -ForegroundColor Red; exit 1 }

Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$' -and $_ -notmatch '^\s*#') {
    [Environment]::SetEnvironmentVariable($matches[1], $matches[2].Trim('"').Trim("'"), 'Process')
  }
}

if (-not $env:DATABRICKS_HOST -or $env:DATABRICKS_HOST -like '<*' -or -not $env:DATABRICKS_TOKEN -or $env:DATABRICKS_TOKEN -like '<*') {
  Write-Host "Fill in real DATABRICKS_HOST and DATABRICKS_TOKEN in .env first." -ForegroundColor Yellow; exit 1
}
if ($env:DATABRICKS_HOST -match '^https?://') { Write-Host "Remove https:// from DATABRICKS_HOST in .env." -ForegroundColor Yellow; exit 1 }

Set-Location (Join-Path $PSScriptRoot "..")
claude
