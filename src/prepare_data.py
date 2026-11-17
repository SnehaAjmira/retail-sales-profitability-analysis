"""Convert the raw Superstore export into a clean UTF-8 CSV.

The raw file uses legacy Mac (CR) line endings and Latin-1 encoding, which most
SQL engines cannot read directly. This step changes encoding and column names
only. No rows are filtered or modified here; all business rules live in SQL.
"""
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw" / "superstoreSales.csv"
OUT = ROOT / "data" / "processed" / "superstore_sales.csv"


def main():
    df = pd.read_csv(RAW, encoding="latin-1", lineterminator="\r")
    df.columns = [c.strip().lower().replace(" ", "_").replace("-", "_") for c in df.columns]
    for col in ["order_date", "ship_date"]:
        df[col] = pd.to_datetime(df[col], format="%m/%d/%Y", errors="coerce")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUT, index=False)
    print(f"{len(df):,} rows written to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
