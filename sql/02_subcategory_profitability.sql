-- Sales, profit, and margin by category and sub-category, ranked by profit.
SELECT
    product_category AS category,
    product_sub_category AS sub_category,
    ROUND(SUM(sales)) AS sales,
    ROUND(SUM(profit)) AS profit,
    ROUND(100 * SUM(profit) / SUM(sales), 1) AS margin_pct,
    ROUND(100 * AVG(is_loss::INT), 1) AS loss_line_pct,
    RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
FROM stg_lines
GROUP BY ALL
ORDER BY profit DESC;
