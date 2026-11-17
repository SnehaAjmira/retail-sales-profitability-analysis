-- Scenario: company margin if the two loss-making furniture sub-categories broke even.
WITH base AS (
    SELECT SUM(sales) AS sales, SUM(profit) AS profit FROM stg_lines
),
losers AS (
    SELECT SUM(profit) AS profit FROM stg_lines
    WHERE product_sub_category IN ('Tables', 'Bookcases')
)
SELECT
    ROUND(base.profit) AS current_profit,
    ROUND(100 * base.profit / base.sales, 1) AS current_margin_pct,
    ROUND(-losers.profit) AS profit_recovered,
    ROUND(base.profit - losers.profit) AS scenario_profit,
    ROUND(100 * (base.profit - losers.profit) / base.sales, 1) AS scenario_margin_pct,
    ROUND(100 * -losers.profit / base.profit, 1) AS profit_uplift_pct
FROM base, losers;
