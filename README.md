# Mockup-to-Power-BI

## 1. What this project does
Report mockups are usually drawn by hand from vague requirements, without the real data, so layouts and KPIs may not be supportable. This project runs inside Claude Code: Claude explores your Databricks tables, proposes KPIs the data can support, and generates an interactive mockup with real numbers for stakeholder review. After the design is approved, Claude builds the Power BI semantic model, writes DAX measures validated against Databricks SQL, and generates report pages that match the approved design. The analyst reviews, refines, and publishes.

## 2. Architecture
```
Brief -> Databricks discovery -> KPI approval -> HTML mockup -> design approval
      -> design spec (JSON) -> semantic model + DAX validation -> PBIR report
      -> review and publish in Power BI Desktop
```
Approval gates: KPIs, design, spec, validation, publish. See `CLAUDE.md` for the full workflow and rules.

> **New to this repo? Follow [SETUP.md](SETUP.md)** and run `.\scripts\setup.ps1`. It checks all prerequisites and installs the Power BI plugin.

## 3. Prerequisites
- Claude Code
- Node.js 18+
- Git
- Power BI Desktop (Windows) with PBIP/PBIR enabled
- A Databricks workspace with Unity Catalog and a SQL warehouse
- The `powerbi-authoring` plugin (see Setup)

## 4. Access to request
- Databricks read-only: `USE CATALOG`, `USE SCHEMA`, `SELECT` on the demo tables, `CAN USE` on a SQL warehouse.
- Power BI / Fabric workspace access.
- Admin approval of the Power BI tenant setting if you use the hosted Authoring MCP.

## 5. Setup
1. Clone this repo and open a terminal in it.
2. Set environment variables (never commit them). `DATABRICKS_HOST` is the workspace hostname without `https://`.
   - PowerShell: `$env:DATABRICKS_HOST = "<workspace-host>"; $env:DATABRICKS_TOKEN = "<token>"`
   - bash: `export DATABRICKS_HOST=<workspace-host> DATABRICKS_TOKEN=<token>`
   - Use a principal with SELECT-only rights. `.mcp.json` reads both values via `${VAR}` expansion, which Claude Code supports in `url` and `headers` for `.mcp.json`. TODO(verify): re-check against the current Claude Code MCP docs and the Databricks MCP docs (transport `http` for `/api/2.0/mcp/sql`).
3. Install the `powerbi-authoring` plugin (it provides the Power BI Modeling MCP). The marketplace is pre-declared in `.claude/settings.json`; to install manually: `claude plugin marketplace add microsoft/skills-for-fabric`, then `claude plugin install powerbi-authoring@fabric-collection --scope project`, or just run `.\scripts\setup.ps1`.
   - The local Power BI Modeling MCP is launched via `npx` (Node.js 18+), may require accepting a EULA on first use, and works against Power BI Desktop and PBIP files.
4. Run `claude` in this folder.
5. Run `/mcp` and confirm both `databricks` and `powerbi-modeling-mcp` are connected.
6. Run the smoke test below.

## 6. Smoke test
Ask Claude to: run `SHOW CATALOGS`; list tables in one schema; profile one table; compute 3 KPIs; then verify one KPI by hand in the Databricks SQL editor.

## 7. How to use
Fill in `inputs/brief.md`, then tell Claude: "Start the workflow in CLAUDE.md." Claude stops at each gate and waits for you:
1. KPI list approved
2. Mockup design approved
3. Design spec approved
4. DAX measures reconcile with Databricks
5. You publish from Power BI Desktop

Outputs land in `outputs/`; the Power BI project lands in `powerbi/`.

## 8. Demo data guidance
This demo uses sample data from our own Databricks account (for example the `samples` catalog: TPC-H or NYC taxi). It does not use client data.

## 9. Security and data handling
- Use a read-only principal; the project rules forbid write statements.
- Outputs use aggregated results.
- No secrets in the repo; credentials come from environment variables.
- Query results are sent to the model as context. The demo uses sample data only. If this is ever pointed at real data, the people with access to that data decide the handling rules.

## 10. Known limitations
- The mockup is a data snapshot, not live.
- The report matches the mockup's layout, KPIs, and chart types, not pixel-for-pixel.
- Power BI Desktop has no live canvas API, so pages are written as PBIR files and reopened in Desktop. The Authoring MCP covers the semantic model only.
- Windows is the main supported environment for local Power BI tooling.
- Untested early risks: Databricks as the model's data source when created via the Authoring MCP; PBIR generation quality; Desktop Bridge screenshots.

## 11. Optional: Snowflake
See the `snowflake-adapter` skill in `.claude/skills/`.
