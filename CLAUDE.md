# Mockup-to-Power-BI (Claude Code project)

Goal: turn a business request plus real Databricks data into (1) an interactive, data-grounded report mockup, then (2) a validated Power BI semantic model and report, built faster and with less rework.

## Tools in this project
- Databricks SQL MCP (server name: `databricks`): explore tables, profile data, run KPI and validation SQL. READ-ONLY by policy.
- Power BI Authoring MCP (registered by the `powerbi-authoring` plugin): create the semantic model, relationships, measures; run and validate DAX. It does NOT create report pages or visuals.
- Microsoft Power BI report authoring skills (from the `powerbi-authoring` plugin): write report pages and visuals as PBIR files.
- Power BI Desktop (Windows): used by the human to open, review, and publish.

## Workflow (follow in order; STOP at every gate and wait for the user)
1. Read `inputs/brief.md`. If key fields are missing, ask once, concisely.
2. Run skill `data-discovery` -> `outputs/data-profile.md`.
3. Run skill `kpi-feasibility` -> `outputs/kpis.md`. **GATE 1: user approves the KPI list.**
4. Run skill `mockup-generator` -> `outputs/mockup/index.html`. Iterate on feedback. **GATE 2: user approves the design.**
5. Run skill `design-spec-builder` -> `outputs/design-spec.json`. **GATE 3: user approves the spec.**
6. Run skill `semantic-model-builder` (model + relationships in `powerbi/`).
7. Run skill `dax-writer-validator` -> measures + `outputs/validation-report.md`. **GATE 4: all measures reconcile with Databricks (or differences are explained and accepted).**
8. Run skill `report-page-builder` -> PBIR pages in `powerbi/`. Build one page first, then the rest.
9. Run skill `qa-handoff` -> `outputs/qa-handoff.md`.
10. Tell the user to open the `.pbip` in Power BI Desktop to review, refine, and publish. **GATE 5: human publishes.**

## Hard rules
- **No number without a query.** Every figure in the mockup, KPI list, or documentation must come from a query you ran. Record the SQL.
- **Databricks is read-only.** Only `SELECT`, `SHOW`, `DESCRIBE`, and `EXPLAIN`. Never run `INSERT`, `UPDATE`, `DELETE`, `MERGE`, `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `GRANT`, or any write.
- **Aggregates only.** Mockups and KPIs use aggregated results. Use `LIMIT` on exploration queries.
- **Demo scope: sample data only.** This demo runs on sample data from our own Databricks account, not client data. Do not add PII/PHI classification, exclusion, or anonymization steps. If real data is ever connected, that is a separate decision made by the people with access to that data and its policies.
- **Never write secrets** (tokens, passwords, secrets) to files or the chat. Credentials come from environment variables.
- **Databricks DirectQuery sources use catalog/schema/table navigation only** (`Databricks.Catalogs`), never native SQL, `Databricks.Query`, or SQL joins; derive columns in DAX. Full recipe and the errors it prevents: `.claude/skills/semantic-model-builder/SKILL.md`.
- The Databricks host and SQL warehouse path are not secrets; the token is. Ask before opening `.mcp.json` to read the host, read only the host, and use the token in memory only (for example to list warehouses). The user signs in to Databricks inside Power BI Desktop.
- Avoid circular dependencies: never sort a column by a calculated column that depends on it.
- Anything not yet loaded in Power BI Desktop (DAX values, query folding, rendering) is untested; say so.
- Databricks SQL runs asynchronously: start the query, then poll until it completes.
- Do not claim the Power BI MCP creates report pages. Pages come from PBIR file authoring.
- Power BI Desktop must be **closed** while report files are written; the user reopens it to view the result.
- Avoid Q&A, Bing map, and filled map visuals (being deprecated).
- Ask before changing anything in a shared Fabric workspace.
- Report failures and uncertainty honestly. Never fake a validation result.
- All generated files go in `outputs/` (or `powerbi/` for the Power BI project).

## Conventions
- Measure names: Title Case, no underscores, grouped by display folder (e.g. `Revenue`, `Revenue YoY %`).
- Every KPI has an id (`KPI-01`...) used consistently in `kpis.md`, the mockup (`data-kpi-id` attribute), `design-spec.json`, and `validation-report.md`.
- Mockup data snapshot always shows the source (catalog.schema) and the timestamp.
