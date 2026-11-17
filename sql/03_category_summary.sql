-- Category roll-up with share of total sales and profit.
SELECT
    product_category AS category,
    ROUND(SUM(sales)) AS sales,
    ROUND(SUM(profit)) AS profit,
    ROUND(100 * SUM(profit) / SUM(sales), 1) AS margin_pct,
    ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER (), 1) AS share_of_sales_pct,
    ROUND(100 * SUM(profit) / SUM(SUM(profit)) OVER (), 1) AS share_of_profit_pct
FROM stg_lines
GROUP BY ALL
ORDER BY margin_pct DESC;
