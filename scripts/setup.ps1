<#
 One-time setup / verification for new clones (Windows PowerShell).
 Usage:  .\scripts\setup.ps1             # check everything, install the Power BI plugin
         .\scripts\setup.ps1 -CheckOnly  # only check, change nothing
 Never prints or stores secrets.
#>
param([switch]$CheckOnly)
$script:ok = $true
function Check($name, $pass, $fix) {
  if ($pass) { Write-Host "[ OK ] $name" -ForegroundColor Green }
  else { Write-Host "[FAIL] $name -> $fix" -ForegroundColor Red; $script:ok = $false }
}

Write-Host "`n== Tools =="
Check "git"         ([bool](Get-Command git -ErrorAction SilentlyContinue))    "Install Git: https://git-scm.com"
Check "Claude Code" ([bool](Get-Command claude -ErrorAction SilentlyContinue)) "Install: https://claude.com/claude-code"
$nodeOk = $false
if (Get-Command node -ErrorAction SilentlyContinue) { $nodeOk = ([int]((node -v).TrimStart('v').Split('.')[0])) -ge 18 }
Check "Node.js 18+ (the Power BI MCP is launched via npx)" $nodeOk "Install Node LTS: https://nodejs.org"
Check "npx"         ([bool](Get-Command npx -ErrorAction SilentlyContinue))    "Comes with Node.js"
$pbiPaths = @("$env:ProgramFiles\Microsoft Power BI Desktop", "${env:ProgramFiles(x86)}\Microsoft Power BI Desktop") | Where-Object { Test-Path $_ }
$pbiStore = Get-AppxPackage -Name "Microsoft.MicrosoftPowerBIDesktop" -ErrorAction SilentlyContinue
Check "Power BI Desktop" ([bool]($pbiPaths -or $pbiStore)) "Install from Microsoft Store or https://aka.ms/pbidesktop (enable PBIP + PBIR preview features)"

Write-Host "`n== Databricks credentials (environment variables) =="
Check "DATABRICKS_HOST set"  ([bool]$env:DATABRICKS_HOST)  'setx DATABRICKS_HOST "<host-without-https>"  then open a NEW terminal'
Check "DATABRICKS_TOKEN set" ([bool]$env:DATABRICKS_TOKEN) 'setx DATABRICKS_TOKEN "<read-only-token>"  then open a NEW terminal'
if ($env:DATABRICKS_HOST -match '^https?://') { Check "DATABRICKS_HOST has no https://" $false "Remove the https:// prefix" }

if (-not $CheckOnly -and (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Host "`n== Power BI authoring plugin =="
  claude plugin marketplace add microsoft/skills-for-fabric
  claude plugin install powerbi-authoring@fabric-collection --scope project
}

Write-Host ""
if ($script:ok) { Write-Host "All checks passed. Run 'claude' here, then '/mcp' to confirm databricks and powerbi-modeling-mcp are connected." -ForegroundColor Green }
else { Write-Host "Fix the FAIL items above, open a NEW terminal, and re-run this script." -ForegroundColor Yellow }
