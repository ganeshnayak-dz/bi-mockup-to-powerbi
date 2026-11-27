---
name: mockup-generator
description: Build an interactive HTML report mockup from real Databricks query results. Use after KPIs are approved, or to revise the mockup from stakeholder feedback.
---

# Mockup generator

## Purpose
Give stakeholders a realistic, data-grounded preview so the design is approved before the Power BI build.

## Inputs
`outputs/kpis.md`, `outputs/data-profile.md`, brief (audience, filters, branding).

## Steps
1. **Layout source.** If `outputs/wireframe-decision.md` says mode `provided`, follow `outputs/wireframe-layout.json` (from `wireframe-intake`): same pages, visual order, grid positions, chart types and theme; show unsupported visuals as labelled placeholders with the gap. Otherwise plan pages and visuals (KPI cards, trends, breakdowns, tables) that fit the audience. State the layout in a short plan first.
2. Run aggregate queries per visual. For client-side filters, aggregate by the filter dimensions (e.g. month x region x product) and embed that result.
3. Generate **one self-contained HTML file**: inline CSS and vanilla JS, charts as inline SVG, no external requests or CDNs, data embedded as a JSON constant. Working filters/slicers and page tabs. Responsive layout.
4. Give every visual a `data-kpi-id` (or `data-visual-id`) attribute. Footer shows the source `catalog.schema`, the snapshot timestamp, and a note that numbers are a snapshot.
5. Save the queries used in `outputs/mockup/queries.sql`.
6. On feedback, change the mockup and list what changed.

## Excel sources
Query Excel tables with `scripts/excel_sql.py --out <file>.json` and build from those JSON files (no hand copying, so the chunking below is not needed for them). Footer source: `inputs/excel/<file> [<sheet>]`. See `excel-adapter`.

## Embedding data reliably
Query results exist only in the conversation, so embedded data must be copied by hand and **long copies silently lose rows** (a 2,995-row copy came back with 2,830).
- Ask the query to return each cube as a compact fixed-width base36 string in chunks of at most about 1,000 cells, plus checksums (cell count, sums of every measure, a key checksum).
- Write each chunk to a scratch file, decode it with a small script, and compare with the query's checksums before building the HTML. Fix a chunk until it matches.
- After building, run the page script headless (Node with a minimal DOM stub) and compare KPI cards, breakdowns and one filtered slice with the queried values.
- On Windows the Bash tool may fail; use PowerShell and the Write tool.

## Outputs
`outputs/mockup/index.html`, `outputs/mockup/queries.sql`.

## Rules
- No number without a query; aggregates only.
- Do not claim the mockup is live.
- **GATE 2:** stop and ask the user to approve the design. With a provided wireframe, ask whether the mockup matches it and list the gaps.
