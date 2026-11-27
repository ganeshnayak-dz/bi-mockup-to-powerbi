# Wireframe inputs (optional)

If the report layout is already decided, put the wireframe here and Claude builds the mockup and the
Power BI pages to follow it (see the `wireframe-intake` skill).

## Accepted formats
- **PDF** (one page per report page works best)
- **Images**: `.png`, `.jpg`, `.jpeg` (screenshots, exported slides, legible hand sketches)
- **HTML** (an existing mockup or prototype page)
- **PowerPoint** `.pptx` (each slide = one report page)

## Tips for a clean result
- Name files in page order, e.g. `01-overview.pdf`, `02-franchise-detail.png`.
- Label every visual with what it shows (e.g. "Revenue by month, line chart") and every card with its KPI.
- Mark slicers/filters and their fields.
- Note brand colors and fonts if they matter, or add a separate `notes.md` in this folder.

## If this folder is empty
Claude asks whether you want to add a wireframe here or let Claude design one from the data, the
business objective, and the approved KPIs.

## What Claude can and cannot match
Claude matches page structure, visual types, KPIs, fields, slicers, ordering, and approximate position
and size. It does not promise pixel-perfect fidelity. Visuals the data cannot support, and deprecated
visuals (Q&A, Bing map, filled map), are flagged with an alternative instead of being faked.
