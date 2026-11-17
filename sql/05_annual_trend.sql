-- Year-over-year sales, profit, and margin.
WITH yearly AS (
    SELECT order_year, SUM(sales) AS sales, SUM(profit) AS profit, COUNT(DISTINCT order_id) AS orders
    FROM stg_lines
    GROUP BY ALL
)
SELECT
    order_year,
    orders,
    ROUND(sales) AS sales,
    ROUND(profit) AS profit,
    ROUND(100 * profit / sales, 1) AS margin_pct,
    ROUND(100 * (sales / LAG(sales) OVER (ORDER BY order_year) - 1), 1) AS sales_yoy_pct,
    ROUND(sales / orders) AS avg_order_value
FROM yearly
ORDER BY order_year;
