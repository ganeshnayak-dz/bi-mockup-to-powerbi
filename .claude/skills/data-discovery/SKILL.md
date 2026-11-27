---
name: data-discovery
description: Explore Databricks tables (and/or Excel/CSV files in inputs/excel) and produce a data profile. Use at the start of a report project or whenever the user asks what data is available.
---

> **Excel / mixed sources:** if the brief says `Platform: Excel` or `Mixed`, or `inputs/excel/` has data files, profile those with `scripts/excel_sql.py` following the `excel-adapter` skill. Same profile, same rules.

# Data discovery

## Purpose
Understand the real data (tables, grain, keys, quality) before proposing KPIs.

## Inputs
`inputs/brief.md` (catalog, schema, tables), or discovery of candidates when none are given.

## Steps
1. If no tables are given, run `SHOW CATALOGS`, `SHOW SCHEMAS IN <catalog>`, `SHOW TABLES IN <catalog>.<schema>` and propose candidates matching the business objective.
2. For each selected table: `DESCRIBE TABLE EXTENDED`; query `<catalog>.information_schema.columns` for types.
3. Profile with aggregate queries: row count, `approx_count_distinct` on candidate keys and dimensions, null percentage per column, `min`/`max` of date columns, top 10 values for low-cardinality dimensions (use `LIMIT`).
4. Infer each table's grain and candidate join keys (check key uniqueness and orphan rates with aggregate queries).
5. Classify columns as date, dimension, measure, or key.
6. Record data quality issues (nulls, duplicates, odd ranges).

## Outputs
`outputs/data-profile.md`: run timestamp, table summaries, column classification table, join key candidates, quality issues, and the SQL used.

## Rules
- Read-only: `SELECT`, `SHOW`, `DESCRIBE`, `EXPLAIN` only.
- Aggregates only in outputs.
- Databricks SQL is asynchronous: start the query, poll until complete.
- Never write secrets to files or chat.
