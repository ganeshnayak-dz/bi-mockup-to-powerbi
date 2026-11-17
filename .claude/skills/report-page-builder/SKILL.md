---
name: report-page-builder
description: Generate Power BI report pages and visuals as PBIR files from the design spec. Use after measures are validated.
---

# Report page builder

## Purpose
Write the approved design as a PBIR report inside the PBIP project. The Authoring MCP does not do this; the Microsoft report authoring skills do.

## Inputs
`outputs/design-spec.json`, validated model in `powerbi/`.

## Steps
1. Read the report authoring skills installed by the `powerbi-authoring` plugin (e.g. `powerbi-report-cli`) and follow them for PBIR structure and validation.
2. Make sure Power BI Desktop is closed.
3. Build **one page first** and validate it with the skill's validation steps; then build the rest.
4. Apply the theme and positions from the spec; bind visuals to the validated measures; add slicers/filters from the spec.
5. Avoid Q&A, Bing map, and filled map visuals.
6. If the Desktop Bridge is available, use it to reload and capture screenshots. TODO(verify): exact usage in Microsoft's docs.

## Outputs
PBIR report in `powerbi/`; `outputs/report-build-notes.md` listing pages built, visuals not built exactly as designed, and why.

## Rules
- Be honest about gaps versus the mockup; never claim pixel-perfect fidelity.
- Ask before publishing or changing a shared Fabric workspace.
