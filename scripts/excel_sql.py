"""Read-only SQL over the Excel/CSV files in inputs/excel (DuckDB, in memory).

Every sheet becomes a DuckDB view, so discovery, KPI and validation queries for Excel
sources are real, repeatable SQL (the "no number without a query" rule).

Usage (from the project root):
  python scripts/excel_sql.py --list                     # files, sheets, view names, columns, row counts
  python scripts/excel_sql.py --sql "SELECT COUNT(*) AS n FROM sales"
  python scripts/excel_sql.py --file outputs/q.sql --out outputs/r.json

View naming: the sheet name, lower-case, non-alphanumerics -> "_".
If two files share a sheet name, the view is <file>_<sheet>. A CSV's view is its file name.

The source files are never modified. Only SELECT / WITH / DESCRIBE / SHOW / SUMMARIZE run.
Requires: pip install duckdb pandas openpyxl
"""
import argparse
import json
import re
import sys
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_DIR = ROOT / "inputs" / "excel"
ALLOWED = re.compile(r"^\s*(select|with|describe|show|summarize|from)\b", re.I)


def clean(name: str) -> str:
    n = re.sub(r"[^0-9a-zA-Z]+", "_", name).strip("_").lower()
    return n if n and not n[0].isdigit() else f"t_{n}"


def load_frames(folder: Path):
    try:
        import pandas as pd
    except ImportError:
        sys.exit("Missing packages. Run: python -m pip install duckdb pandas openpyxl")
    items = []  # (file, sheet, dataframe)
    for f in sorted(folder.iterdir()):
        if f.name.startswith(("~$", ".")) or not f.is_file():
            continue
        ext = f.suffix.lower()
        if ext in (".xlsx", ".xlsm"):
            for sheet, df in pd.read_excel(f, sheet_name=None, engine="openpyxl").items():
                items.append((f.name, sheet, df))
        elif ext == ".csv":
            items.append((f.name, None, pd.read_csv(f)))
    sheet_counts = {}
    for _, sheet, _ in items:
        if sheet is not None:
            sheet_counts[clean(sheet)] = sheet_counts.get(clean(sheet), 0) + 1
    out = []
    for fname, sheet, df in items:
        if sheet is None:
            view = clean(Path(fname).stem)
        elif sheet_counts[clean(sheet)] > 1:
            view = f"{clean(Path(fname).stem)}_{clean(sheet)}"
        else:
            view = clean(sheet)
        out.append({"file": fname, "sheet": sheet, "view": view, "df": df})
    return out


def connect(tables):
    try:
        import duckdb
    except ImportError:
        sys.exit("Missing packages. Run: python -m pip install duckdb pandas openpyxl")
    con = duckdb.connect(":memory:")
    for t in tables:
        con.register(t["view"], t["df"])
    return con


def to_json(v):
    if isinstance(v, (datetime, date)):
        return v.isoformat()
    if isinstance(v, Decimal):
        return float(v)
    return v


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dir", default=str(DEFAULT_DIR), help="folder with the data files")
    ap.add_argument("--list", action="store_true", help="list files, sheets, views, columns")
    ap.add_argument("--sql", help="one SQL statement")
    ap.add_argument("--file", help="file holding one SQL statement")
    ap.add_argument("--out", help="write JSON result here instead of stdout")
    ap.add_argument("--max-rows", type=int, default=1000,
                    help="refuse results larger than this (aggregates only); default 1000")
    a = ap.parse_args()

    folder = Path(a.dir)
    if not folder.is_dir():
        sys.exit(f"Folder not found: {folder}")
    tables = load_frames(folder)
    if not tables:
        sys.exit(f"No .xlsx/.xlsm/.csv files in {folder}")

    if a.list:
        con = connect(tables)
        report = []
        for t in tables:
            cols = con.execute(f'DESCRIBE "{t["view"]}"').fetchall()
            report.append({
                "file": t["file"], "sheet": t["sheet"], "view": t["view"],
                "rows": int(len(t["df"])),
                "columns": [{"name": c[0], "type": c[1]} for c in cols],
            })
        result = report
    else:
        sql = a.sql or (Path(a.file).read_text(encoding="utf-8") if a.file else None)
        if not sql:
            sys.exit("Give --list, --sql or --file")
        sql = sql.strip().rstrip(";")
        if ";" in sql or not ALLOWED.match(sql):
            sys.exit("Only one read-only statement (SELECT/WITH/DESCRIBE/SHOW/SUMMARIZE) is allowed.")
        con = connect(tables)
        cur = con.execute(sql)
        cols = [d[0] for d in cur.description]
        rows = cur.fetchmany(a.max_rows + 1)
        if len(rows) > a.max_rows:
            sys.exit(f"Result has more than {a.max_rows} rows. Aggregate further or raise --max-rows deliberately.")
        result = {"sql": sql, "columns": cols, "rows": [[to_json(v) for v in r] for r in rows]}

    text = json.dumps(result, indent=2, default=str)
    if a.out:
        Path(a.out).parent.mkdir(parents=True, exist_ok=True)
        Path(a.out).write_text(text, encoding="utf-8")
        print(f"Wrote {a.out}")
    else:
        print(text)


if __name__ == "__main__":
    main()
