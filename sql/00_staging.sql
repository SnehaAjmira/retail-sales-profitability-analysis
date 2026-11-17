-- Staging: load processed order lines, drop empty rows, standardize values, derive fields.
CREATE OR REPLACE TABLE raw_lines AS
SELECT * FROM read_csv_auto('data/processed/superstore_sales.csv');

CREATE OR REPLACE TABLE stg_lines AS
SELECT
    CAST(row_id AS INTEGER) AS row_id,
    CAST(order_id AS INTEGER) AS order_id,
    order_date,
    ship_date,
    YEAR(order_date) AS order_year,
    ship_mode,
    customer_name,
    customer_segment,
    CASE WHEN region = 'Prarie' THEN 'Prairie' ELSE region END AS region,  -- source typo
    product_category,
    product_sub_category,
    order_quantity,
    sales,
    discount,
    profit,
    profit < 0 AS is_loss,
    CASE
        WHEN discount < 0.03 THEN '0-2%'
        WHEN discount < 0.06 THEN '3-5%'
        WHEN discount < 0.09 THEN '6-8%'
        ELSE '9% and above'
    END AS discount_band
FROM raw_lines
WHERE order_date IS NOT NULL;
