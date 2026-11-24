/* 1. Dataset overview: Determine dataset size and initial evidence of grain */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_item_id) AS total_order_items,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_card_id) AS total_products
FROM stg_dataco;

/* 2. Check whether order_id appears in multiple rows */
SELECT
    order_id,
    COUNT(*) AS number_of_rows
FROM stg_dataco
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY number_of_rows DESC
LIMIT 50;

/* 3. How many product lines per order? */
SELECT 
	order_id,
	count(*) AS number_of_lines,
	count(DISTINCT order_item_id) AS num_of_order_items,
	count(DISTINCT product_card_id) AS num_of_products,
	sum(order_item_quantity) AS total_quantity
FROM stg_dataco
GROUP BY order_id 
LIMIT 50;

/* 4. Phân phối số dòng sản phẩm (order lines) trên mỗi đơn hàng */
SELECT
	number_of_lines,
	count(*) AS num_of_orders
FROM
(
	SELECT 
		order_id,
		count(*) AS number_of_lines
	FROM stg_dataco sd 
	GROUP BY order_id
) t
GROUP BY number_of_lines 
ORDER BY number_of_lines;

/* 5. Order Item Id có duy nhất không?, có null ko ? */
/* 5.1. Validate order_item_id as the row-level key */

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS missing_order_item_id,
    COUNT(DISTINCT order_item_id) AS distinct_order_item_id,
    COUNT(*) - COUNT(DISTINCT order_item_id) AS duplicate_difference
FROM stg_dataco;

/* 5.2. List duplicated order_item_id values, if any */
SELECT
    order_item_id,
    COUNT(*) AS number_of_rows
FROM stg_dataco
GROUP BY order_item_id
HAVING COUNT(*) > 1
ORDER BY number_of_rows DESC;

/* 6. Một khách hàng có thể có nhiều đơn không? */
SELECT
	customer_id ,
	count(DISTINCT order_id) AS num_of_orders
FROM stg_dataco sd 
GROUP BY customer_id 
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY num_of_orders DESC
LIMIT 50;

/* 7. Các dòng cùng một đơn hàng, có cùng các thuộc tính? */
/* 7. Check consistency of order-level attributes */
SELECT
    order_id,
    COUNT(DISTINCT customer_id) AS customer_count,
    COUNT(DISTINCT order_date) AS order_date_count,
    COUNT(DISTINCT order_status) AS order_status_count,
    COUNT(DISTINCT customer_segment) AS customer_segment_count,
    COUNT(DISTINCT market) AS market_count,
    COUNT(DISTINCT order_region) AS order_region_count,
    COUNT(DISTINCT shipping_mode) AS shipping_mode_count,
    COUNT(DISTINCT delivery_status) AS delivery_status_count,
    COUNT(DISTINCT late_delivery_risk) AS late_delivery_risk_count,
    COUNT(DISTINCT order_country)  AS order_country_count

FROM stg_dataco
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1
    OR COUNT(DISTINCT order_date) > 1
    OR COUNT(DISTINCT order_status) > 1
    OR COUNT(DISTINCT customer_segment) > 1
    OR COUNT(DISTINCT market) > 1
    OR COUNT(DISTINCT order_region) > 1
    OR COUNT(DISTINCT shipping_mode) > 1
    OR COUNT(DISTINCT delivery_status) > 1
    OR COUNT(DISTINCT late_delivery_risk) > 1
    OR COUNT(DISTINCT order_country) > 1;


   /* 8.1. Profile order status and delivery status */
SELECT
    order_status,
    delivery_status,
    late_delivery_risk,
    COUNT(DISTINCT order_id) AS orders
FROM stg_dataco
GROUP BY order_status, delivery_status, late_delivery_risk
ORDER BY order_status, delivery_status, late_delivery_risk;

/* 8.2. Compare Scope A and Scope B order counts */
SELECT
    COUNT(DISTINCT order_id) AS scope_a_all_recorded_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status IS DISTINCT FROM 'CANCELED'
          AND order_status IS DISTINCT FROM 'SUSPECTED_FRAUD'
    ) AS scope_b_non_canceled_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
    ) AS excluded_canceled_or_fraud_orders
FROM stg_dataco;
