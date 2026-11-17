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

## Practical notes (from a real build)
- **CLI:** `powerbi-report-author` may be missing. Install with `npm install -g @microsoft/powerbi-report-authoring-cli@latest` (needs Node 20+). Scaffold with `powerbi-report-author scaffold <powerbi dir> --name <Report> --model-path ../<Model>.SemanticModel --page-name <first page>`; it creates the `.pbip` and a valid first page.
- **Generate from the spec with a script**, not by hand: loop over `pages[]`, write `page.json` and `visual.json` files, then rewrite `pages/pages.json` (`pageOrder`, `activePageName`). Look up roles with `powerbi-report-author catalog describe <type>` first. Use `cardVisual` with the `Data` role; the legacy `card` fails validation.
- **Layout:** map the spec grid onto 1280 x 720 (16 px margin, 8 px gutters); a Between date slicer needs about 104 px height, dropdowns 80 px.
- **Regenerating:** the script deletes old page folders. If Windows returns EPERM, remove the folders with PowerShell `Remove-Item -Recurse -Force`, then re-run. Never leave `pages.json` pointing at missing folders.
- **Validate:** `powerbi-report-author validate <.Report folder>` must succeed. Rendering/screenshot needs Desktop: if `preview` returns `HOST_UNAVAILABLE` / `DESKTOP_EXE_NOT_FOUND`, stop (the skill treats it as terminal), set `PBI_DESKTOP_PATH` or ask the user to open the `.pbip`, and report screenshot validation as blocked, not done.
- **Model changes after the report exists:** if a column moves tables or is renamed, repoint the visuals (walk the `visual.json` files) and re-validate.

## Outputs
PBIR report in `powerbi/`; `outputs/report-build-notes.md` listing pages built, visuals not built exactly as designed, and why.

## Rules
- Be honest about gaps versus the mockup; never claim pixel-perfect fidelity.
- Ask before publishing or changing a shared Fabric workspace.
