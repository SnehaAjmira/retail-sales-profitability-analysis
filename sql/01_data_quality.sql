-- Data quality profile reported in the README.
SELECT 'Raw rows' AS check_name, COUNT(*)::VARCHAR AS result FROM raw_lines
UNION ALL SELECT 'Empty rows removed', ((SELECT COUNT(*) FROM raw_lines) - (SELECT COUNT(*) FROM stg_lines))::VARCHAR
UNION ALL SELECT 'Order lines analyzed', COUNT(*)::VARCHAR FROM stg_lines
UNION ALL SELECT 'Distinct orders', COUNT(DISTINCT order_id)::VARCHAR FROM stg_lines
UNION ALL SELECT 'Distinct customers', COUNT(DISTINCT customer_name)::VARCHAR FROM stg_lines
UNION ALL SELECT 'Date range', MIN(order_date)::VARCHAR || ' to ' || MAX(order_date)::VARCHAR FROM stg_lines
UNION ALL SELECT 'Duplicate row IDs', (COUNT(*) - COUNT(DISTINCT row_id))::VARCHAR FROM stg_lines
UNION ALL SELECT 'Ship date before order date', COUNT(*)::VARCHAR FROM stg_lines WHERE ship_date < order_date
UNION ALL SELECT 'Region values corrected (Prarie to Prairie)', COUNT(*)::VARCHAR FROM raw_lines WHERE region = 'Prarie'
UNION ALL SELECT 'Null sales or profit', COUNT(*)::VARCHAR FROM stg_lines WHERE sales IS NULL OR profit IS NULL;
