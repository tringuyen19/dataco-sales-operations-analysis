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
LIMIT 50

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
ORDER BY number_of_lines

/* 5. Order Item Id có duy nhất không?, có null ko ? */
SELECT 
	order_item_id,
	count(*) AS num_of_rows
FROM stg_dataco sd 
GROUP BY order_item_id 
HAVING COUNT(*) > 1
ORDER BY num_of_rows DESC

SELECT 
	order_item_id,
	count(*) AS num_of_rows
FROM stg_dataco sd 
GROUP BY order_item_id 
HAVING COUNT(*) > 1
ORDER BY num_of_rows DESC

/* 6. Một khách hàng có thể có nhiều đơn không? */
SELECT
	customer_id ,
	count(DISTINCT order_id) AS num_of_orders
FROM stg_dataco sd 
GROUP BY customer_id 
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY num_of_orders DESC
LIMIT 50

/* 7. Các dòng cùng một đơn hàng, có cùng các thuộc tính? */
SELECT
    order_id,
    COUNT(DISTINCT customer_id) AS customer_count,
    COUNT(DISTINCT order_date) AS order_date_count,
    COUNT(DISTINCT order_status) AS status_count,
    COUNT(DISTINCT shipping_mode) AS shipping_mode_count,
    COUNT(DISTINCT order_country) AS country_count
FROM stg_dataco
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1
    OR COUNT(DISTINCT order_date) > 1
    OR COUNT(DISTINCT order_status) > 1
    OR COUNT(DISTINCT shipping_mode) > 1
    OR COUNT(DISTINCT order_country) > 1;