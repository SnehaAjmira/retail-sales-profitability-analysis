-- Margin by shipping mode, with the furniture share that explains the gap.
SELECT
    ship_mode,
    COUNT(*) AS order_lines,
    ROUND(SUM(sales)) AS sales,
    ROUND(100 * SUM(profit) / SUM(sales), 1) AS margin_pct,
    ROUND(100 * SUM(sales) FILTER (WHERE product_category = 'Furniture') / SUM(sales), 1) AS furniture_sales_pct,
    ROUND(AVG(ship_date - order_date), 1) AS avg_days_to_ship
FROM stg_lines
GROUP BY ALL
ORDER BY margin_pct;
