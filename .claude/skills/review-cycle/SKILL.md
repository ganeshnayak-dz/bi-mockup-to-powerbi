---
name: review-cycle
description: Final review of the whole build: verify every workflow step and gate was executed correctly, that artifacts are consistent, hard rules were respected, and the dashboard matches the wireframe. Use after qa-handoff, before the analyst publishes, or any time the user asks to audit the run.
---

# Review cycle

## Purpose
An independent audit of the finished run. It answers: were all required steps done, in order, with the
gates honoured; do the artifacts agree with each other; were the hard rules followed; and how closely does the
dashboard match the wireframe. It reports; it does not silently fix.

## Inputs
Everything in `outputs/` and `powerbi/`, `inputs/`, `CLAUDE.md`, `outputs/gate-log.md`.

## Steps
1. **Applicability.** Read `outputs/wireframe-decision.md` and the brief. Mark each check below `N/A` with a
   reason when the step legitimately did not apply (e.g. no wireframe, no Excel, no Databricks, the analyst
   supplied that artifact or skipped the step on purpose). A step that was skipped without a recorded reason is a finding.
2. **Step and gate audit.** For each workflow step, check the artifact exists, is non-empty, is newer than its
   inputs, and the gate was recorded:
   | Step | Evidence | Gate record |
   |------|----------|-------------|
   | Brief read, source and wireframe mode decided | `wireframe-decision.md` | - |
   | Data discovery | `data-profile.md`, `outputs/sql/*` | - |
   | KPI feasibility | `kpis.md`, `business-rules.md` | GATE 1 in `gate-log.md` |
   | Wireframe extraction | `wireframe-layout.md/json` | - |
   | Mockup | `mockup/index.html`, `data.json`, `queries.sql` | GATE 2 |
   | Design spec | `design-spec.json` | GATE 3 |
   | Semantic model | `powerbi/*.SemanticModel`, `model-notes.md` | - |
   | DAX and validation | `validation-queries.json`, `validation-report.md` | GATE 4 |
   | Report pages | PBIR pages, `report-build-notes.md` | - |
   | Handoff | `qa-handoff.md` | GATE 5 (human) |
   A gate with no entry in `gate-log.md`, or approved with open items, is a finding.
3. **Consistency checks.**
   - KPI ids: the same set in `kpis.md`, mockup `data-kpi-id`, `design-spec.json`, `validation-queries.json`,
     `validation-report.md`. List ids missing from any artifact.
   - Visual ids (`V-xx`) consistent across wireframe layout, mockup, spec and build notes.
   - Every KPI in the spec has a business rule entry; no rule left `Open` or `Claude-proposed` without a
     recorded user decision.
   - Every number shown in the mockup/KPI list traces to a recorded query (`queries.sql`, `outputs/sql/`).
   - Mockup shows the data source and timestamp; goals shown match the brief's goals table.
4. **Hard-rule checks** (scan files, do not trust memory):
   - No write SQL (`INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP|TRUNCATE|GRANT`) in any recorded query.
   - No secrets or tokens in `outputs/`, `powerbi/`, or chat history files (search for token-like strings, `dapi`).
   - Databricks sources use `Databricks.Catalogs` navigation only (no native SQL / `Databricks.Query`).
   - Measure names are Title Case, no underscores; no circular sort-by dependencies; no deprecated visuals
     (Q&A, Bing map, filled map).
   - Files in `inputs/` were not modified (compare modified times with the earliest output).
   - Power BI items marked untested are still labelled untested.
5. **Validation integrity.** Re-read `validation-report.md`: every KPI has a DAX value, SQL value, tolerance
   and status; no mismatch marked as passed; at least one filtered and one time slice per KPI; run timestamp present.
6. **Wireframe match.** If mode is `provided`, run skill `wireframe-compare` (target: both) and include the
   overall score and top differences. In `generate` mode mark `N/A`.
7. **Write `outputs/review-report.md`:** run timestamp; overall verdict (`Ready for analyst review`,
   `Ready with accepted deviations`, or `Not ready`); a checklist table with status `Pass`, `Fail`,
   `Warning` or `N/A` per check, each with evidence (file and line or query) ; wireframe score; findings
   ranked by severity (blocker, should fix, note) with a proposed fix and owner (`Claude` or `analyst`); and
   what could not be verified (anything needing Power BI Desktop).
8. Present the findings to the user and ask which to fix. Fix only what they approve, then re-run the
   affected checks and update the report (this is the review cycle: review, fix, re-review until no blockers
   remain or the user accepts the remainder).

## Rules
- Report failures and uncertainty plainly; never mark a check `Pass` without evidence.
- Do not modify artifacts during the audit itself; fixes happen only after the user approves them.
- Do not publish; GATE 5 stays with the analyst.
