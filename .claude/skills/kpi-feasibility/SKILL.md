---
name: kpi-feasibility
description: Capture the analyst's business KPI definitions and rules, confirm every unclear formula with the user, then check whether the data can support each KPI with real values. Use after data discovery or when the user asks what metrics are possible.
---

# KPI feasibility

## Purpose
The analyst owns the business meaning of every KPI. Claude's job is to record those definitions exactly,
make sure the analyst knows what each KPI means and which rules apply, and only then test whether the data
can deliver it. Claude never invents a business rule.

## Inputs
`inputs/brief.md`, `outputs/data-profile.md`, and optionally `inputs/kpi-definitions.md` (analyst-written;
template: `docs/kpi-definitions.template.md`), plus the wireframe if one was provided.

## Step 0: who defines the KPIs? (this step is not always needed in full)
Check what the analyst already supplied, then pick the path:
- **Analyst supplied definitions** (`inputs/kpi-definitions.md`, or the brief/wireframe lists formulas): use them
  as written. Skip step 1; go to step 2 and only ask about gaps.
- **Analyst supplied names only** (brief/wireframe lists metrics, no formulas): go to step 1 for those.
- **Nothing supplied:** ask the analyst (AskUserQuestion) whether they will provide KPIs/definitions or want
  Claude to propose a first draft from the business objective. A draft is always marked `Proposed` until confirmed.

## Steps
1. **Analyst interview (only for KPIs without a full definition).** For each KPI collect, in the analyst's words:
   business meaning and decision it supports; formula (numerator, denominator); filters and inclusions/exclusions
   (e.g. which statuses count, test records, cancelled rows); time logic (period, rolling, YTD, vs prior period);
   grain and the dimensions it must be sliceable by; goal/target and where it comes from; display format and
   direction (higher is better?). Ask in batches (max 4 questions per call), never one tiny question at a time.
2. **Clarify before computing. Ask, never assume.** If any of these is unclear, STOP and ask the user:
   a formula or rule is ambiguous or has two reasonable readings; a column could mean two things; a date field
   could drive the period (which one?); a goal conflicts with another source; the same metric appears with
   different definitions; a rule needs a business threshold (e.g. "active" = how many days). Offer the
   plausible options with their consequences. Record the answer; do not proceed on a guess.
3. Write the **Business rules register** `outputs/business-rules.md`: one row per rule with id (`BR-01`...),
   KPI id(s), rule in plain language, source (`analyst`, `wireframe`, `brief`, `Claude-proposed`), and status
   (`Confirmed by <user> on <date>` or `Open`). Claude-proposed rules are never treated as confirmed until the
   user says so.
4. Write and run the SQL (read-only, poll async); capture the value. For Excel tables run it with
   `scripts/excel_sql.py` (`excel-adapter` skill) and tag the engine next to the SQL. If a wireframe was
   provided (`outputs/wireframe-decision.md` mode `provided`), include every metric it shows so GATE 1 covers them.
5. Mark status: **Supported**, **Partial** (say what is missing), or **Not supported** (say why). Suggest
   alternatives for unsupported ones; the analyst chooses.
6. Assign ids `KPI-01`, `KPI-02`, ... and keep them stable from here on.
7. **Analyst awareness summary:** at the gate, present a short plain-language recap per KPI ("this counts X
   divided by Y, excluding Z, for the latest full month") and list every open or assumed rule, so the analyst
   signs off on what the numbers mean, not just on the numbers.

## Outputs
- `outputs/kpis.md`: table with id, name, business meaning, definition (formula + filters + time logic), goal,
  SQL, current value, status, definition source (`analyst` / `proposed`), linked rule ids, notes.
- `outputs/business-rules.md`: the rules register (step 3).

## Rules
- No number without a query; record the SQL.
- Aggregates only; read-only.
- A KPI with an unconfirmed definition may be shown as `Proposed` but cannot pass the gate until confirmed.
- **GATE 1:** stop and ask the user to approve the KPI list and the business rules. Append the decision to
  `outputs/gate-log.md` (gate, date, what was approved, open items).
