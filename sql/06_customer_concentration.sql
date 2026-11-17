-- Customer concentration: cumulative share of sales and profit by customer decile.
WITH customers AS (
    SELECT customer_name, SUM(sales) AS sales, SUM(profit) AS profit
    FROM stg_lines
    GROUP BY ALL
),
deciles AS (
    SELECT *, NTILE(10) OVER (ORDER BY sales DESC) AS sales_decile
    FROM customers
)
SELECT
    sales_decile,
    COUNT(*) AS customers,
    ROUND(SUM(sales)) AS sales,
    ROUND(SUM(profit)) AS profit,
    ROUND(100 * SUM(SUM(sales)) OVER (ORDER BY sales_decile) / SUM(SUM(sales)) OVER (), 1) AS cumulative_sales_pct,
    ROUND(100 * SUM(SUM(profit)) OVER (ORDER BY sales_decile) / SUM(SUM(profit)) OVER (), 1) AS cumulative_profit_pct
FROM deciles
GROUP BY sales_decile
ORDER BY sales_decile;
