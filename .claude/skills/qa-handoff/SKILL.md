---
name: qa-handoff
description: Produce the final QA and handoff pack for the analyst. Use at the end of a build.
---

# QA and handoff

## Purpose
Give the analyst everything needed to review, refine, and publish.

## Steps
1. Summarize what was built (model, measures, pages).
2. List measures with definitions and validation status (from `outputs/validation-report.md`).
3. List known gaps versus the mockup (from `outputs/report-build-notes.md`).
4. Write an analyst checklist: open the `.pbip` in Desktop, refresh credentials, check each page, check slicers, check performance, confirm theme, then publish.
5. Document the data source, snapshot date, and sensitivity notes (columns excluded).

## Output
`outputs/qa-handoff.md`.

## Rules
- Report unvalidated or failed items plainly.
- **GATE 5:** the human publishes; do not publish for them.
