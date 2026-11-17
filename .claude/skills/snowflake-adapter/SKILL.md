---
name: snowflake-adapter
description: Adapt the discovery and validation steps when the source is Snowflake instead of Databricks. Use only when the brief says the platform is Snowflake.
---

# Snowflake adapter (optional)

## Purpose
Reuse the same workflow with Snowflake as the data source.

## What changes
- **MCP:** Snowflake offers a managed MCP server (created with `CREATE MCP SERVER`, OAuth; use a read-only role). A separate entry is needed in `.mcp.json`. TODO(verify): get the URL format and auth setup from the Snowflake docs; do not guess.
- **SQL differences to watch:**
  - Metadata: `INFORMATION_SCHEMA` views per database; `SHOW DATABASES/SCHEMAS/TABLES` instead of `SHOW CATALOGS`; `DESCRIBE TABLE` output differs.
  - Approximate distinct: `APPROX_COUNT_DISTINCT` (Snowflake also has `HLL`).
  - Date functions: `DATE_TRUNC`, `DATEADD`, `DATEDIFF` argument order differs from Databricks.
  - Identifiers are upper-case unless quoted.
- **Power BI:** connects through the Snowflake connector.

## Unchanged
Mockup, design spec, semantic model, DAX validation, and report steps, plus all hard rules in `CLAUDE.md` (read-only, aggregates only, no secrets).
