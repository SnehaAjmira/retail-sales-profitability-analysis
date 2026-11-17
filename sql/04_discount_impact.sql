-- Margin and share of loss-making lines by discount band.
SELECT
    discount_band,
    COUNT(*) AS order_lines,
    ROUND(SUM(sales)) AS sales,
    ROUND(100 * SUM(profit) / SUM(sales), 1) AS margin_pct,
    ROUND(100 * AVG(is_loss::INT), 1) AS loss_line_pct
FROM stg_lines
GROUP BY ALL
ORDER BY discount_band;
