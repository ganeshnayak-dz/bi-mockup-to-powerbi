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

## Outputs
`outputs/validation-report.md`: table with KPI id, measure, DAX value, SQL value, difference, status, notes.

## Rules
- Never mark a mismatch as passed; show the evidence.
- **GATE 4:** stop and ask the user to accept the validation result.
