# Report brief

Fill in this file before starting. Leave a field blank if you don't know it yet; Claude asks for missing key fields at step 1.
A filled-in example is in `inputs/examples/brief-bakehouse-databricks.md`.

## Data source
- Platform:   <!-- Databricks | Excel | Mixed (some tables in Databricks, some in inputs/excel/) -->
- Data status:   <!-- sample / synthetic / anonymized. Do not use customer PII or PHI. -->

### Databricks tables (if Platform is Databricks or Mixed)
- Catalog / schema:
- Tables to use:
  -

### Excel inputs (if Platform is Excel or Mixed; files go in inputs/excel/)
<!-- Roles, grain and keys can be guesses; data discovery confirms or corrects them. -->
| File | Sheet | Role (fact / dimension) | Grain (one row per...) | Key column(s) | Joins to |
|------|-------|-------------------------|------------------------|---------------|----------|
|      |       |                         |                        |               |          |

## Wireframe
- Wireframe:   <!-- provided (files in inputs/wireframe/) | generate (Claude designs it) | ask (Claude asks at the start) -->
- File(s):
- Must match:   <!-- e.g. page order, visual types, KPIs, slicers/toggles, relative layout -->
- Scope:

## Business objective
- Question the report must answer:
- Decisions it should support:

## Audience
- Who will use it:
- Level of detail (executive summary / analyst deep dive):

## KPIs
- <!-- List your KPIs with formulas, or point to inputs/kpi-definitions.md (template: docs/kpi-definitions.template.md), or write "Propose KPIs for me". -->
- Reference period on cards:   <!-- e.g. latest full month, with vs previous month -->

## Goals (optional targets; never computed from data)
| Metric | Goal |
|--------|------|
|        |      |

## Filters and slicers
-

## Time range and granularity
-

## Branding
-   <!-- e.g. follow the wireframe, company colours, or a clean default -->

## Constraints
- Columns to exclude:
- Metric definitions that must be followed:
- Anonymization needed? (yes/no):
