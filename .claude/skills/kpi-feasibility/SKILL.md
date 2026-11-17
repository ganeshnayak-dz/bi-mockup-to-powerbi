---
name: kpi-feasibility
description: Propose KPIs for a report and check whether the data can support each one, with real values. Use after data discovery or when the user asks what metrics are possible.
---

# KPI feasibility

## Purpose
Only promise KPIs the data can deliver, and show real values early.

## Inputs
`inputs/brief.md`, `outputs/data-profile.md`.

## Steps
1. Propose KPIs from the business objective, or take the user's list.
2. Define each precisely: numerator, denominator, filters, grain, time logic.
3. Write and run the SQL (read-only, poll async); capture the value.
4. Mark status: **Supported**, **Partial** (say what is missing), or **Not supported** (say why). Suggest alternatives for unsupported ones.
5. Assign ids `KPI-01`, `KPI-02`, ...

## Outputs
`outputs/kpis.md`: table with id, name, business meaning, definition, SQL, current value, status, notes.

## Rules
- No number without a query; record the SQL.
- Aggregates only; read-only.
- **GATE 1:** stop and ask the user to approve the KPI list.
