/* 1. Missing values in critical fields */
SELECT 
	count(*) AS total_rows ,
	count(*) filter(WHERE order_item_id IS NULL) AS missin_order_item_id ,
	count(*) filter(WHERE order_id IS NULL) AS missin_order_id ,
	count(*) filter(WHERE customer_id IS NULL) AS missin_customer_id ,
	count(*) filter(WHERE product_card_id IS NULL) AS missin_product_card_id ,
	count(*) filter(WHERE order_date IS NULL) AS missin_order_date 
FROM stg_dataco sd

/* 2. Duplicate checks */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT stg_dataco.*) AS distinct_rows,
    COUNT(*) - COUNT(DISTINCT stg_dataco.*) AS duplicate_rows
FROM stg_dataco;

/* 3. Date quality checks */
SELECT
    order_date
FROM stg_dataco
WHERE order_date IS NOT NULL
LIMIT 50;

SELECT
    order_id,
    order_date,
    shipping_date
FROM stg_dataco
WHERE shipping_date < order_date 

/* 4. Numeric validity checks */
SELECT * FROM stg_dataco
WHERE order_item_quantity <= 0
   OR order_item_product_price < 0
   OR sales_amount < 0
   OR order_item_discount < 0
   OR order_item_discount_rate < 0
   OR order_item_discount_rate > 1
   OR order_item_discount > sales_amount;

/* 5. Category consistency checks */
SELECT
    LOWER(TRIM(order_status)) AS normalized_status,
    ARRAY_AGG(DISTINCT order_status) AS original_values,
    COUNT(*) AS number_of_rows
FROM stg_dataco
GROUP BY LOWER(TRIM(order_status))
ORDER BY normalized_status;

SELECT
    LOWER(TRIM(delivery_status)) AS normalized_delivery_status,
    ARRAY_AGG(DISTINCT delivery_status) AS original_values,
    COUNT(*) AS number_of_rows
FROM stg_dataco
GROUP BY LOWER(TRIM(delivery_status))
ORDER BY normalized_delivery_status;

SELECT
    LOWER(TRIM(shipping_mode)) AS normalized_shipping_mode,
    ARRAY_AGG(DISTINCT shipping_mode) AS original_values,
    COUNT(*) AS number_of_rows
FROM stg_dataco
GROUP BY LOWER(TRIM(shipping_mode))
ORDER BY normalized_shipping_mode;

SELECT
    LOWER(TRIM(customer_segment)) AS normalized_customer_segment,
    ARRAY_AGG(DISTINCT customer_segment) AS original_values,
    COUNT(*) AS number_of_rows
FROM stg_dataco
GROUP BY LOWER(TRIM(customer_segment))
ORDER BY normalized_customer_segment;