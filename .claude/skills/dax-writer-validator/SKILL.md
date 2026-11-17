---
name: dax-writer-validator
description: Write DAX measures from the spec and validate each against Databricks SQL ground truth. Use after the semantic model exists, or when a number looks wrong.
---

# DAX writer and validator

## Purpose
Create measures and prove they match the source data.

## Inputs
`outputs/design-spec.json`, the semantic model.

## Steps
1. For each measure, write the DAX with a format string and display folder (Title Case names, no underscores).
2. Run it through the Authoring MCP, e.g. `EVALUATE ROW("v", [Measure])`, using the same filters as the SQL.
3. Run the matching ground-truth SQL on Databricks (read-only, poll async).
4. Compare: exact for counts; small relative tolerance for floating-point sums and ratios (state the tolerance).
5. Also validate at least one filtered slice and one time slice per KPI.
6. On mismatch, diagnose (join, filter context, grain, nulls), fix, re-test.

7. Save every check as a repeatable pair in `outputs/validation-queries.json`: `{kpiId, measure, dax, sql, slice, tolerance}`. Never store results there, only the queries.

## Re-validation mode (live data QC)
The model is DirectQuery, so after the user refreshes the report, they can ask Claude to "re-run QC". Then:
1. Read `outputs/validation-queries.json`; do not rewrite the queries.
2. Re-run each DAX query through the Authoring MCP and each SQL on Databricks, at the current time.
3. Write a fresh `outputs/validation-report.md` with a run timestamp, and compare with the previous run if one exists (flag any KPI whose status changed or whose source value moved).
4. A difference caused by data changing between the two queries (DAX and SQL run seconds apart) must be re-run once before it is called a mismatch.

## Outputs
`outputs/validation-report.md`: run timestamp, table with KPI id, measure, DAX value, SQL value, difference, status, notes. `outputs/validation-queries.json`: the repeatable queries.

## Rules
- Never mark a mismatch as passed; show the evidence.
- **GATE 4:** stop and ask the user to accept the validation result.
