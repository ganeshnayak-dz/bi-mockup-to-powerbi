# Demo script (5 to 7 minutes)

Use sample data from our own Databricks account (for example the `samples` catalog). Have a pre-built report ready as a fallback.

## 1. The problem (30 s)
Report mockups are drawn by hand from vague requirements, without the real data. KPIs may not be supportable, stakeholders react to placeholder visuals, and after approval the Power BI build starts almost from scratch.

## 2. Live: data discovery (60 s)
- Show `inputs/brief.md` (catalog/schema, objective).
- Claude connects to Databricks through the SQL MCP and profiles the sample schema.
- Show `outputs/data-profile.md`: grain, keys, column classes, quality notes.

## 3. Live: KPI feasibility (60 s)
- Show `outputs/kpis.md`: each KPI with definition, SQL, real value, and status (Supported / Partial / Not supported).
- Approve the KPI list (Gate 1).

## 4. Live: interactive mockup (90 s)
- Open `outputs/mockup/index.html`: real numbers, working filters, page tabs.
- Give one piece of "stakeholder feedback" (e.g. move a chart, add a slicer) and show Claude revise it.
- Approve the design (Gate 2).

## 5. Live: semantic model and measures (90 s)
- Claude builds the design spec, then the semantic model and DAX measures through the Power BI Authoring MCP.
- Show `outputs/validation-report.md`: DAX value equals SQL value for each KPI.

## 6. Report pages in Power BI Desktop (60 s)
- Pages are generated as PBIR files, then opened in Power BI Desktop.
- Note: the Authoring MCP covers the semantic model only; pages come from PBIR file authoring.
- **Fallback:** if generation misbehaves, open the pre-built report instead.

## 7. Close (30 s)
- Benefits: faster delivery, less rework, design and data aligned from the start, analysts focus on insight.
- Limitations: mockup is a snapshot, not live; same layout/KPIs/chart types, not pixel-perfect; the analyst still reviews and publishes.
