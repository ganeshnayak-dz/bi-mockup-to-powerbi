---
name: excel-adapter
description: Use Excel/CSV files from inputs/excel as a data source (alone or mixed with Databricks) for discovery, KPIs, the mockup, the Power BI semantic model, and DAX validation. Use when the brief says Platform Excel or Mixed, or when inputs/excel contains data files.
---

# Excel adapter

## Purpose
Run the same workflow when some or all tables live in spreadsheets. Every number still comes from a
recorded query: for Excel sources the query engine is DuckDB over the files, through `scripts/excel_sql.py`.

## When it applies
- `inputs/brief.md` has `Platform: Excel` or `Platform: Mixed`, **or**
- `inputs/excel/` contains `.xlsx`, `.xlsm` or `.csv` files (ignore `README.md`, `~$*` lock files).
If files are present but the brief says Databricks only, ask once whether to use them.

## Setup check (once per session)
1. `python --version` (3.9+).
2. `python -c "import duckdb, pandas, openpyxl"`. If it fails, **ask the user** before installing:
   `python -m pip install duckdb pandas openpyxl`.
3. Tell the user to close any workbook open in Excel (open files are locked on Windows).

## The query tool
```
python scripts/excel_sql.py --list
python scripts/excel_sql.py --sql "SELECT COUNT(*) AS rows FROM sales"
python scripts/excel_sql.py --file outputs/sql/kpi-01.sql --out outputs/sql/kpi-01.result.json
```
- Each sheet is a view named after the sheet (lower-case, `_` for other characters); `--list` shows the
  exact names. A CSV's view is its file name.
- Read-only by construction: files are loaded into memory; only `SELECT`/`WITH`/`DESCRIBE`/`SHOW`/`SUMMARIZE` run.
- Results above 1,000 rows are refused (aggregates only). Raise `--max-rows` only for the mockup data cube, and say so.
- Write queries in DuckDB SQL. Record each query in the output file that uses its number, tagged
  `-- engine: excel (duckdb) | file: <file> | sheet: <sheet>`.

## Step-by-step changes to the workflow

### data-discovery
1. Run `--list`. Check against the **Excel inputs** table in the brief; if the table is empty, propose roles
   (fact/dimension), grain and keys and ask the user to confirm.
2. Profile with aggregate SQL exactly like Databricks: row count, `approx_count_distinct`, null %, min/max of dates,
   top 10 values of low-cardinality columns, key uniqueness, orphan rates.
3. Excel-specific checks, reported as quality issues: numbers stored as text, dates stored as text or serial
   numbers, leading/trailing spaces in keys, blank rows, duplicate header names (pandas renames them `col.1`),
   subtotal/total rows inside the data, mixed types in one column.
4. **Mixed sources:** for every join between an Excel table and a Databricks table, compare the key sets
   (distinct counts on each side; match rate computed from an aggregate on each side, e.g. counts per key
   prefix or the distinct key list when it is small enough, under 1,000). Report the match rate and key type
   differences (e.g. `INT` vs `VARCHAR`).
5. Add a **Sources** section to `outputs/data-profile.md`: file, sheet, view, rows, file modified time.

### kpi-feasibility, mockup-generator
- Same steps; the SQL runs through `excel_sql.py`. A KPI that needs data from both sources is computed with
  one query per source plus the combination shown explicitly, or marked **Partial** if it cannot be combined
  with aggregates only.
- Mockup data: write cube results straight to JSON with `--out` and build the page from those files. No hand
  copying is needed for Excel sources. Still check totals against the KPI queries.
- Mockup footer source: `inputs/excel/<file> [<sheet>]` (plus `catalog.schema` for Databricks tables) and the
  snapshot timestamp.

### design-spec-builder
For Excel tables use:
```json
{ "name": "Sales", "source": { "platform": "excel", "file": "sales.xlsx", "sheet": "Sales" },
  "storageMode": "Import", "grain": "one row per transaction", "columns": ["..."] }
```
and in `dataSource` set `"platform": "excel"` or `"mixed"`.

### semantic-model-builder (Power BI)
1. **Storage mode: Import.** Excel and CSV do not support DirectQuery. In a mixed model, Databricks tables stay
   DirectQuery and Excel tables are Import: this is a **composite model**. Record it in `outputs/model-notes.md`.
2. **Folder parameter.** Create an M parameter `Excel Folder Path` (`kind: "M"`), the absolute path of
   `inputs\excel\` with a trailing backslash. Not a secret. Never hardcode the path inside a partition.
3. **Partition M for a sheet** (navigation by sheet name, then promote headers, then set types):
   ```
   let
     Source = Excel.Workbook(File.Contents(#"Excel Folder Path" & "<file>.xlsx"), null, true),
     Sheet = Source{[Item = "<Sheet>", Kind = "Sheet"]}[Data],
     Headers = Table.PromoteHeaders(Sheet, [PromoteAllScalars = true]),
     Typed = Table.TransformColumnTypes(Headers, {{"orderDate", type date}, {"amount", type number}, {"franchiseID", Int64.Type}})
   in Typed
   ```
   For a CSV:
   ```
   let
     Source = Csv.Document(File.Contents(#"Excel Folder Path" & "<file>.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
     Headers = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
     Typed = Table.TransformColumnTypes(Headers, {...})
   in Typed
   ```
   - Always set explicit types for every column used in a relationship or measure; do not rely on auto-detect.
   - If discovery found text keys with spaces, add `Table.TransformColumns(..., {{"key", Text.Trim, type text}})`.
   - Keep each sheet its own table; derive labels and sort keys as DAX calculated columns, same as Databricks.
4. **Relationships.** Key columns must have the same data type on both sides. In a composite model a relationship
   between an Import (Excel) table and a DirectQuery (Databricks) table is a *limited* relationship: no blank row
   for unmatched keys and `RELATED` does not work across it. Prefer measures that do not depend on it, and say so.
5. **Refresh and publishing.** Import data is a snapshot as of the last refresh in Desktop. A published report
   reading a local file needs an on-premises data gateway; storing the files in SharePoint/OneDrive avoids that
   (switch the source to `SharePoint.Files` / `Web.Contents` only if the user asks). Put this in `model-notes.md`.
6. The user refreshes in Desktop; no credentials are needed for local files (privacy levels may prompt in mixed models:
   tell the user to set both sources to Organizational).

### dax-writer-validator
- Ground truth for Excel measures is the DuckDB SQL from `excel_sql.py`. Add `"engine": "excel-duckdb"` (or
  `"databricks"`) to each entry in `outputs/validation-queries.json`.
- Expect small differences from type inference (pandas vs Power Query): validate row counts per table first,
  then sums. Explain any difference by its cause (e.g. a text value Power Query typed as error and dropped).
- Re-validation mode: re-run after the user edits the workbook and refreshes in Desktop; record the file modified time.

## Rules
- Never modify, move, or save over files in `inputs/excel/`. Write derived files only to `outputs/`.
- Aggregates only in outputs; no row-level dumps into the chat or the mockup.
- Data in `inputs/excel/` must be sample or already-anonymized data (org policy: no customer PII/PHI). If a column
  looks like personal data (names, emails, phone numbers), stop and ask before using it.
- Import-mode numbers are a snapshot: never call the Excel part of the model "live".
