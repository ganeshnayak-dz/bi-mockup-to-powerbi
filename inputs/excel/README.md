# Excel / CSV data inputs

Drop data files here when some or all of the report data lives in spreadsheets instead of Databricks.
Claude profiles them, computes KPIs from them, and loads them into the Power BI semantic model
(see the `excel-adapter` skill).

## What to put here
- `.xlsx`, `.xlsm`, or `.csv` files. One folder level only (no subfolders).
- **One table per sheet.** Row 1 is the header row; data starts on row 2.
- No merged cells, blank header cells, subtotal rows, or notes below the data.
- Keep a stable column name for every key used to join tables (e.g. `franchiseID` in both the fact sheet and the franchise sheet).
- Dates as real Excel dates (not text), numbers as numbers.

## Tell Claude what the files are
Fill in the **Excel inputs** table in `inputs/brief.md` (file, sheet, role: fact/dimension, grain, key).
If you leave it empty, Claude infers it during data discovery and asks you to confirm.

## Mixed sources
Some tables in Databricks and some in Excel is supported. Set `Platform: Mixed` in the brief and list
which tables come from where. Claude checks that join keys match across the two sources.

## Data policy
Use sample or already-anonymized data only. Do not place customer PII/PHI, secrets, or passwords in these files.
Claude never edits or overwrites files in this folder; it only reads them.

Data files in this folder are git-ignored; only this README is tracked.
