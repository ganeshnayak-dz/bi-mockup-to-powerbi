---
name: design-spec-builder
description: Convert the approved mockup and KPIs into a structured design spec (JSON) that drives the Power BI build. Use after the design is approved.
---

# Design spec builder

## Purpose
Produce the handoff contract between the mockup phase and the Power BI build.

## Inputs
Approved `outputs/mockup/index.html`, `outputs/kpis.md`, feedback notes.

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
- **GATE 3:** stop and ask the user to approve the spec.
