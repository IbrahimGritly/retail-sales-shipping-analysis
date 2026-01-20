-- To check the number of rows
SELECT COUNT(*) AS total_rows FROM orders;

SELECT * FROM orders LIMIT 5;

-- How many unique values in the categorical columns
SELECT COUNT(DISTINCT customer_segment) AS segments, 
	COUNT(DISTINCT category_name) AS categories,
    COUNT(DISTINCT order_region) AS regions
FROM orders;

-- Check for null values in numerical columns
SELECT 
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN profit_per_order IS NULL THEN 1 ELSE 0 END) AS null_profit,
    SUM(CASE WHEN sales_per_customer IS NULL THEN 1 ELSE 0 END) AS null_salesper,
    SUM(CASE WHEN order_item_discount IS NULL THEN 1 ELSE 0 END) AS null_dc,
	SUM(CASE WHEN order_item_profit_ratio IS NULL THEN 1 ELSE 0 END) AS null_profitratio,
	SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
	SUM(CASE WHEN order_item_total IS NULL THEN 1 ELSE 0 END) AS null_itemtotal,
	SUM(CASE WHEN profit_per_order IS NULL THEN 1 ELSE 0 END) AS null_profitperorder,
    SUM(CASE WHEN product_price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN order_item_discount_percentage IS NULL THEN 1 ELSE 0 END) AS null_dcperc,
    SUM(CASE WHEN late_delivery IS NULL THEN 1 ELSE 0 END) AS null_latedelivery
FROM orders;




#####          Aggregations & Views          #####

-- (View 1) Core KPI's
CREATE VIEW vw_core_kpis AS
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit_per_order), 2) AS total_profit,
    ROUND(SUM(profit_per_order) / NULLIF(SUM(sales), 0), 3) AS profit_margin
FROM orders;

SELECT * FROM vw_core_kpis;

-- (View 2) Sales & Profit Monthly
CREATE VIEW vw_sales_profit_monthly AS
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit_per_order), 2) AS total_profit
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

SELECT * FROM vw_sales_profit_monthly;

-- (View 3) Region Performance
CREATE VIEW vw_region_performance AS
SELECT
    order_region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit_per_order), 2) AS total_profit
FROM orders
GROUP BY order_region
ORDER BY total_sales DESC;

SELECT * FROM vw_region_performance;

-- (View 4) Customer Segment Performance*=
CREATE VIEW vw_customer_segment_performance AS
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit_per_order), 2) AS total_profit
FROM orders
GROUP BY customer_segment
ORDER BY total_sales DESC;

SELECT * FROM vw_customer_segment_performance;

-- (View 5) Category Performance
CREATE VIEW vw_category_performance AS
SELECT
    category_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit_per_order), 2) AS total_profit,
    ROUND(AVG(order_item_discount_percentage), 2) AS avg_discount_percentage
FROM orders
GROUP BY category_name
ORDER BY total_sales DESC;

SELECT * FROM vw_category_performance;

-- (View 6) Actual Shipping vs Scheduled Shipping
CREATE VIEW vw_shipping_days_comparison AS
SELECT
    ROUND(AVG(actual_shipping_days), 2) AS avg_actual_shipping_days,
    ROUND(AVG(scheduled_shipping_days), 2) AS avg_scheduled_shipping_days
FROM orders;

SELECT * FROM vw_shipping_days_comparison;

-- (View 7) Delivery Reliability by Shipping Mode
CREATE VIEW vw_delivery_status_by_shipping_mode AS
SELECT
    shipping_mode,
    delivered_on_time,
    COUNT(*) AS total_orders
FROM orders
GROUP BY shipping_mode, delivered_on_time;

SELECT * FROM vw_delivery_status_by_shipping_mode;


-- (View 8) Shipping Mode Sales
CREATE VIEW vw_shipping_mode_performance AS
SELECT
    shipping_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(actual_shipping_days), 2) AS avg_shipping_days
FROM orders
GROUP BY shipping_mode
ORDER BY total_orders DESC;

SELECT * FROM vw_shipping_mode_performance;


-- (View 9) Top Products by Profit
CREATE VIEW vw_top_products_by_profit AS
SELECT
    product_name,
    category_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit_per_order), 2) AS total_profit
FROM orders
GROUP BY product_name, category_name
ORDER BY total_profit DESC;

SELECT * FROM vw_top_products_by_profit;



-- (View 10) High-Volume Customers x Profitability
CREATE VIEW vw_customer_volume_profitability AS
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_item_quantity) AS total_items_purchased,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit_per_order), 2) AS total_profit
FROM orders
GROUP BY customer_id
ORDER BY total_items_purchased DESC;

SELECT * FROM vw_customer_volume_profitability LIMIT 20;


-- How many customers have purchased from you
SELECT COUNT(DISTINCT customer_id) FROM orders;


SELECT * FROM vw_core_kpis;
SELECT * FROM vw_sales_profit_monthly;
SELECT * FROM vw_region_performance;
SELECT * FROM vw_customer_segment_performance;
SELECT * FROM vw_category_performance;
SELECT * FROM vw_shipping_mode_performance;
SELECT * FROM vw_delivery_status_by_shipping_mode;
SELECT * FROM vw_customer_volume_profitability;
SELECT * FROM vw_shipping_days_comparison;
SELECT * FROM vw_top_products_by_profit;
