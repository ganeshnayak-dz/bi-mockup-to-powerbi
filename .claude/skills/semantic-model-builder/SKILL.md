---
name: semantic-model-builder
description: Create the Power BI semantic model (tables, relationships, hierarchies) from the design spec through the Power BI Authoring MCP. Use after the spec is approved.
---

# Semantic model builder

## Purpose
Build the star-schema semantic model that the measures and report will use.

## Inputs
`outputs/design-spec.json`.

## Steps
1. Confirm the target: local PBIP in `powerbi/` or a Fabric workspace. Default to local PBIP. Ask before touching a shared workspace.
2. Connect to the Power BI Authoring MCP.
3. Define data source partitions pointing to Databricks (Power BI Databricks connector). **Default to DirectQuery (live data) for every table, never Import**, so every refresh or visual interaction queries Databricks directly and the report is never a stale snapshot. Use Import (or Dual for small dimension tables used as slicers) only if the user explicitly asks, and state the choice and why in `outputs/model-notes.md`. Do not set `snapshotTimestamp` as a data-freshness claim in the model; the data is live.
   - DirectQuery constraints to respect: keep DAX DirectQuery-friendly (avoid heavy iterators over large tables), prefer a Databricks view/table for any pre-aggregation (read-only: do not create it, ask the user), and use a plain date column or a view-based date dimension if the connector can't fold a generated date table.
4. Create tables, columns, star-schema relationships, hierarchies, and a date table if needed.
5. Run the MCP's best-practice evaluation and apply safe fixes.
6. Save as a PBIP project with PBIR enabled.

## Databricks DirectQuery recipe (each rule below fixed a real Desktop error)
1. **Partition M: navigation only, never SQL.** Use exactly this shape and nothing else:
   ```
   let
     Source = Databricks.Catalogs(#"Databricks Server Hostname", #"Databricks HTTP Path", [Catalog = null, Database = null, EnableAutomaticProxyDiscovery = null]),
     c = Source{[Name = "<catalog>", Kind = "Database"]}[Data],
     s = c{[Name = "<schema>", Kind = "Schema"]}[Data],
     t = s{[Name = "<table>", Kind = "Table"]}[Data],
     Cols = Table.SelectColumns(t, {"colA", "colB"})
   in Cols
   ```
   - `Databricks.Query` / native SQL / `Value.NativeQuery` is **rejected in DirectQuery** ("DirectQuery may not be used with this data source"). `Databricks.Query` also takes only 2-3 arguments.
   - Do not put real values in the `Catalog`/`Database` options ("The key didn't match any rows") and do not pass `EnableAutomaticProxyDiscovery = false` (must be `null`).
   - `type date` casts of timestamp columns (`Table.TransformColumnTypes` then `Table.RenameColumns`) loaded without error in Desktop.
2. **No SQL joins or derived columns in the source.** Model each source table as its own table (e.g. Franchises and Suppliers separate, related many-to-one). Derive labels/sort keys as DAX **calculated columns** that only read plain columns of the same table. Unmatched dimension keys show as (Blank); do not promise an "Unknown" label.
3. **Connection parameters.** Create two M parameters (`named_expression_operations` `CreateParameter` needs `kind: "M"`): `Databricks Server Hostname` (host only, no `https://`, no path) and `Databricks HTTP Path` (`/sql/1.0/warehouses/<id>`). They are not secrets. Never write the token anywhere. The user signs in inside Desktop with a personal access token.
4. **No circular dependencies.** Never sort a column by a calculated column that depends on it. Pattern: hidden source column `X Code`; hidden calculated `X Order` from `X Code`; visible calculated `X = [X Code]` with `sortByColumn: X Order`. After renaming a column, clear any `sortByColumn` it kept (`sortByColumn: ""`) and confirm in the exported TMDL that only the visible column sorts.
5. **The model built through the MCP is offline.** DAX validation and refresh are unavailable until the user opens it in Desktop and connects. Say so; do not claim measures are validated.
6. **After every change:** list tables/relationships/measures to confirm (these MCP calls often return no output), run `database_operations ExportToTmdlFolder` into `powerbi/<Name>.SemanticModel/definition`, and grep the exported TMDL for the rules above. Tell the user to close the project in Desktop **without saving** before reopening, or Desktop overwrites the new files.

## Outputs
Model in `powerbi/`; short `outputs/model-notes.md` (choices, Import vs DirectQuery, open items).

## Rules
- Never hardcode credentials in the data source; flag anything the user must authenticate in Desktop.
- `TODO(verify)` any step whose MCP tool name or behavior is unclear; report it instead of guessing.
- Data-level behavior (folding, date casts, measure values) is only verified once Desktop loads the model; until then report it as untested.
