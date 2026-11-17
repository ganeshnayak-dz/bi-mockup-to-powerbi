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
1. Plan pages and visuals (KPI cards, trends, breakdowns, tables) that fit the audience. State the layout in a short plan first.
2. Run aggregate queries per visual. For client-side filters, aggregate by the filter dimensions (e.g. month x region x product) and embed that result.
3. Generate **one self-contained HTML file**: inline CSS and vanilla JS, charts as inline SVG, no external requests or CDNs, data embedded as a JSON constant. Working filters/slicers and page tabs. Responsive layout.
4. Give every visual a `data-kpi-id` (or `data-visual-id`) attribute. Footer shows the source `catalog.schema`, the snapshot timestamp, and a note that numbers are a snapshot.
5. Save the queries used in `outputs/mockup/queries.sql`.
6. On feedback, change the mockup and list what changed.

## Outputs
`outputs/mockup/index.html`, `outputs/mockup/queries.sql`.

## Rules
- No number without a query; aggregates only.
- Do not claim the mockup is live.
- **GATE 2:** stop and ask the user to approve the design.
