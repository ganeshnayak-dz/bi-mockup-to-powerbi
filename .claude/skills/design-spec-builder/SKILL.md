---
name: design-spec-builder
description: Convert the approved mockup and KPIs into a structured design spec (JSON) that drives the Power BI build. Use after the design is approved.
---

# Design spec builder

## Purpose
Produce the handoff contract between the mockup phase and the Power BI build.

## Inputs
Approved `outputs/mockup/index.html`, `outputs/kpis.md`, feedback notes, and `outputs/wireframe-layout.json` when a wireframe was provided (keep its visual ids and positions).

## Steps
1. Extract pages, visuals (type, title, fields, measures, position and size on a grid), slicers, filters, and theme (colors, fonts).
2. Extract KPI definitions with ground-truth SQL.
3. Define the target model: tables, grain, columns, relationships.
4. Follow the schema in `docs/design-spec.example.json`.
5. Validate: every visual references defined fields/measures; every KPI has an id; JSON parses.

## Outputs
`outputs/design-spec.json`.

## Rules
- Do not add fields or KPIs that were not in the approved mockup/KPI list.
- **Excel tables** use `"source": {"platform": "excel", "file", "sheet"}` and `"storageMode": "Import"` (see `excel-adapter`). Set `dataSource.platform` to `excel` or `mixed` accordingly.
- **Databricks model tables are direct Databricks tables.** Do not specify `nativeQuery`, SQL joins, or SQL-derived columns: DirectQuery rejects them for Databricks. Keep each source table as its own model table (dimensions related many-to-one) and describe derived columns (labels, sort order, display names) as DAX calculated columns.
- Avoid sort-by cycles: if a visible column needs a custom sort, spec a hidden `X Code`, a calculated `X Order` from it, and a visible calculated `X` sorted by `X Order` (see `semantic-model-builder`).
- Use `cardVisual` (not the legacy `card`) as the card visual type in `pages[].visuals`.
- Unmatched dimension keys appear as (Blank); spec them that way instead of an "Unknown" label.
- **GATE 3:** stop and ask the user to approve the spec.
