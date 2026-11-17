"""Run the SQL pipeline in DuckDB, export result tables, and render figures.

Usage (from the repository root):
    python src/prepare_data.py
    python src/run_analysis.py
"""
from pathlib import Path

import duckdb
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

import style

ROOT = Path(__file__).resolve().parents[1]
SQL = ROOT / "sql"
TABLES = ROOT / "outputs" / "tables"
FIGURES = ROOT / "outputs" / "figures"
SOURCE = "Superstore Sales sample dataset (Canada, 2009 to 2012)"


def run_sql(con):
    con.execute((SQL / "00_staging.sql").read_text())
    results = {}
    for path in sorted(SQL.glob("0[1-9]_*.sql")):
        df = con.execute(path.read_text()).df()
        df.to_csv(TABLES / f"{path.stem}.csv", index=False)
        results[path.stem] = df
    return results


def fig_subcategory(df):
    d = df.sort_values("profit")
    fig, ax = plt.subplots(figsize=(8, 6))
    colors = [style.SERIES[1] if p < 0 else style.SERIES[0] for p in d.profit]
    ax.barh(d.sub_category, d.profit / 1000, color=colors, height=0.65)
    ax.axvline(0, color=style.TEXT_2, linewidth=0.8)
    for y, (p, m) in enumerate(zip(d.profit, d.margin_pct)):
        x = p / 1000
        ax.text(x + (6 if p >= 0 else -6), y, f"{m:.1f}%", va="center",
                ha="left" if p >= 0 else "right", fontsize=8, color=style.TEXT_2)
    ax.xaxis.set_major_formatter(mtick.StrMethodFormatter("${x:,.0f}K"))
    ax.set_xlim(-160, 380)
    ax.grid(axis="y", visible=False)
    ax.tick_params(axis="y", labelsize=9)
    ax.set_title("Profit by sub-category (labels show margin; orange: loss-making)")
    style.finish(fig, FIGURES / "01_subcategory_profit.png", SOURCE)


def fig_discount(df):
    fig, ax = plt.subplots(figsize=(8, 3.8))
    ax.bar(df.discount_band, df.margin_pct, color=style.SERIES[0], width=0.55)
    for x, (m, l) in enumerate(zip(df.margin_pct, df.loss_line_pct)):
        ax.text(x, m + 0.3, f"{m:.1f}% margin\n{l:.0f}% of lines at a loss", ha="center",
                fontsize=8, color=style.TEXT)
    ax.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    ax.set_ylim(0, 16)
    ax.set_xlabel("Discount band")
    ax.grid(axis="x", visible=False)
    ax.set_title("Margin drops from 12.4% to 7.5% as discount depth increases")
    style.finish(fig, FIGURES / "02_discount_impact.png", SOURCE)


def fig_customers(df):
    x = [d * 10 for d in df.sales_decile]
    fig, ax = plt.subplots(figsize=(8, 4.2))
    ax.plot([0] + x, [0] + list(df.cumulative_sales_pct), color=style.SERIES[0], marker="o",
            markersize=4, label="Cumulative share of sales")
    ax.plot([0] + x, [0] + list(df.cumulative_profit_pct), color=style.SERIES[1], marker="o",
            markersize=4, label="Cumulative share of profit")
    ax.plot([0, 100], [0, 100], color=style.NEUTRAL, linewidth=1, linestyle="--", label="Equal distribution")
    ax.annotate(f"Top 20% of customers:\n{df.cumulative_profit_pct[1]:.0f}% of profit",
                xy=(20, df.cumulative_profit_pct[1]), xytext=(32, 52), fontsize=9,
                color=style.TEXT, arrowprops=dict(arrowstyle="-", color=style.TEXT_2, lw=0.8))
    ax.xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    ax.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    ax.set_xlabel("Customers, ranked by sales")
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 105)
    ax.legend(loc="lower right")
    ax.set_title("Customer concentration: sales and profit")
    style.finish(fig, FIGURES / "03_customer_concentration.png", SOURCE)


def main():
    style.apply()
    TABLES.mkdir(parents=True, exist_ok=True)
    FIGURES.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect()
    r = run_sql(con)
    fig_subcategory(r["02_subcategory_profitability"])
    fig_discount(r["04_discount_impact"])
    fig_customers(r["06_customer_concentration"])
    print("Tables:", ", ".join(r))


if __name__ == "__main__":
    main()
