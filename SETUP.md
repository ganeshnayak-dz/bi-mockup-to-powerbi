# New-user setup (clone to working in about 10 minutes)

## 1. Install these first
| Need | Why | Get it |
|---|---|---|
| Git | clone the repo | https://git-scm.com |
| Claude Code | runs the workflow | https://claude.com/claude-code |
| Node.js 18+ (includes `npx`) | launches the Power BI Modeling MCP | https://nodejs.org (LTS) |
| Power BI Desktop (Windows) | review and publish the report | Microsoft Store or https://aka.ms/pbidesktop |
| Databricks access (read-only) | data source | `USE CATALOG`, `USE SCHEMA`, `SELECT`, `CAN USE` on a SQL warehouse |

In Power BI Desktop: *File > Options > Preview features*. Enable **Power BI Project (.pbip)** and the **PBIR** report format, then restart.

## 2. Clone
```
git clone <repo-url>
cd bi-mockup-to-powerbi
```

## 3. Set Databricks credentials (environment variables, never in files)
Use a **read-only** principal. The host has **no** `https://`.
```powershell
setx DATABRICKS_HOST  "adb-xxxxxxxx.x.azuredatabricks.net"
setx DATABRICKS_TOKEN "<your-read-only-token>"
```
**Close and reopen the terminal** afterwards (`setx` only affects new terminals).

**Alternative:** copy `.env.example` to `.env`, fill it in, and start Claude with `.\scripts\start.ps1`. The script loads `.env` into that session and launches `claude`. Claude Code does not read `.env` files itself, so plain `claude` won't see them.

## 4. Run the setup script
```powershell
.\scripts\setup.ps1
```
It checks every prerequisite above and installs the **powerbi-authoring** plugin
(marketplace `microsoft/skills-for-fabric`). The marketplace and plugin are also pre-declared in
`.claude/settings.json`, so Claude Code offers to install them when you trust the folder.
Use `-CheckOnly` to verify without installing anything.

## 5. Start and verify
```
claude
```
1. Trust the project, and approve the project MCP server (`databricks`) and the plugin when asked.
2. Run `/mcp`. Both must show **connected**:
   - `databricks` (SQL over HTTP, defined in `.mcp.json`)
   - `plugin:powerbi-authoring:powerbi-modeling-mcp` (Power BI Modeling MCP, provided by the plugin; first use may ask you to accept a EULA)
3. Run `/skills`. The 9 project skills (data-discovery through qa-handoff) must be listed.
4. Smoke test: ask Claude to run `SHOW CATALOGS`.

## 6. Use it
Fill in `inputs/brief.md`, then say: **"Start the workflow in CLAUDE.md."**

## Troubleshooting
| Symptom | Fix |
|---|---|
| `ENOTFOUND https://${DATABRICKS_HOST}` | The env var isn't visible to Claude. Set it, open a **new** terminal, restart `claude`. |
| `403 Invalid access token` | Token expired, wrong, or for another workspace. Regenerate it. Also remove any user-level `databricks-sql` server that hard-codes an old token. |
| Power BI MCP missing in `/mcp` | Run `claude plugin install powerbi-authoring@fabric-collection --scope project`, then restart `claude`. |
| `npx` not found | Install Node.js 18+ and reopen the terminal. |
| Report changes don't show | Close Power BI Desktop while files are written, then reopen the `.pbip`. |
