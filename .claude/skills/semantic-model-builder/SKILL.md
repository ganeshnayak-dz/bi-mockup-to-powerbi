---
name: semantic-model-builder
description: Create the Power BI semantic model (tables, relationships, hierarchies) from the design spec through the Power BI Authoring MCP. Use after the spec is approved.
---

# Semantic model builder

## Purpose
Build the star-schema semantic model that the measures and report will use.

## Inputs
`outputs/design-spec.json`.

## Steps
1. Confirm the target: local PBIP in `powerbi/` or a Fabric workspace. Default to local PBIP. Ask before touching a shared workspace.
2. Connect to the Power BI Authoring MCP.
3. Define data source partitions pointing to Databricks (Power BI Databricks connector). Choose Import or DirectQuery based on the spec and state the choice.
4. Create tables, columns, star-schema relationships, hierarchies, and a date table if needed.
5. Run the MCP's best-practice evaluation and apply safe fixes.
6. Save as a PBIP project with PBIR enabled.

## Outputs
Model in `powerbi/`; short `outputs/model-notes.md` (choices, Import vs DirectQuery, open items).

## Rules
- Never hardcode credentials in the data source; flag anything the user must authenticate in Desktop.
- `TODO(verify)` any step whose MCP tool name or behavior is unclear; report it instead of guessing.
- Known risk: Databricks as the model's source when created via the MCP is untested; report honestly.
