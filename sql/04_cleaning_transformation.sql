/* =========================================================
Day 3 - Cleaning and transformation checks

Scope decision:
- Không DELETE hoặc UPDATE các order CANCELED/SUSPECTED_FRAUD.
- stg_dataco và hai analysis view gốc tiếp tục đại diện Scope A.
- Scope B được tạo bằng các filtered views trong
  05_create_analysis_views.sql.
========================================================= */

/* 1. Kiểm tra kiểu dữ liệu hiện tại */
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'stg_dataco'
  AND column_name IN (
      'order_date',
      'shipping_date',
      'order_item_quantity',
      'sales_amount',
      'order_item_discount',
      'order_item_total',
      'order_profit_per_order',
      'late_delivery_risk',
      'days_for_shipping_real',
      'days_for_shipment_scheduled'
  )
ORDER BY ordinal_position;

/* 2. Kiểm tra các thuộc tính cấp đơn có nhất quán trong cùng order_id
   Kết quả kỳ vọng: 0 dòng.
   Kiểm tra này phải pass trước khi dùng MIN()/MAX() để tạo order view. */
SELECT
    order_id,
    COUNT(DISTINCT customer_id) AS customer_id_values,
    COUNT(DISTINCT customer_segment) AS customer_segment_values,
    COUNT(DISTINCT market) AS market_values,
    COUNT(DISTINCT order_region) AS order_region_values,
    COUNT(DISTINCT order_country) AS order_country_values,
    COUNT(DISTINCT shipping_mode) AS shipping_mode_values,
    COUNT(DISTINCT order_status) AS order_status_values,
    COUNT(DISTINCT late_delivery_risk) AS late_risk_values,
    COUNT(DISTINCT delivery_status) AS delivery_status_values,
    COUNT(DISTINCT days_for_shipping_real) AS actual_shipping_day_values,
    COUNT(DISTINCT days_for_shipment_scheduled) AS scheduled_day_values
FROM stg_dataco
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1
    OR COUNT(DISTINCT customer_segment) > 1
    OR COUNT(DISTINCT market) > 1
    OR COUNT(DISTINCT order_region) > 1
    OR COUNT(DISTINCT order_country) > 1
    OR COUNT(DISTINCT shipping_mode) > 1
    OR COUNT(DISTINCT order_status) > 1
    OR COUNT(DISTINCT late_delivery_risk) > 1
    OR COUNT(DISTINCT delivery_status) > 1
    OR COUNT(DISTINCT days_for_shipping_real) > 1
    OR COUNT(DISTINCT days_for_shipment_scheduled) > 1;

/* 3. Kiểm tra ảnh hưởng của khoảng trắng và chuỗi rỗng
   View chỉ chuẩn hóa text bằng BTRIM và NULLIF; không đổi nhãn nghiệp vụ. */
SELECT
    COUNT(*) FILTER (
        WHERE order_status IS NOT NULL
          AND order_status <> BTRIM(order_status)
    ) AS order_status_with_outer_spaces,

    COUNT(*) FILTER (
        WHERE shipping_mode IS NOT NULL
          AND shipping_mode <> BTRIM(shipping_mode)
    ) AS shipping_mode_with_outer_spaces,

    COUNT(*) FILTER (
        WHERE customer_segment IS NOT NULL
          AND customer_segment <> BTRIM(customer_segment)
    ) AS customer_segment_with_outer_spaces,

    COUNT(*) FILTER (
        WHERE BTRIM(COALESCE(order_status, '')) = ''
    ) AS blank_order_status_rows
FROM stg_dataco;

/* 4. Profiling theo order status
   Đây là profiling Scope A, không phải query KPI chính. */
SELECT
    order_status,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    ROUND(SUM(order_item_total), 2) AS net_sales,
    ROUND(SUM(order_profit_per_order), 2) AS total_profit,
    ROUND(
        SUM(order_profit_per_order)
        / NULLIF(SUM(order_item_total), 0), 4
    ) AS profit_margin
FROM stg_dataco
GROUP BY order_status
ORDER BY total_orders DESC;
