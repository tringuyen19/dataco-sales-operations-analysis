# Aggregation Rules

| Metric / Field | Grain | Correct calculation | Do not use | Reason |
|---|---|---|---|---|
| Total Orders | Order | `COUNT(DISTINCT order_id)` | `COUNT(*)` | Một đơn có nhiều dòng sản phẩm |
| Total Customers | Customer | `COUNT(DISTINCT customer_id)` | `COUNT(*)` | Khách hàng xuất hiện ở nhiều đơn |
| Net Sales | Order item | `SUM(order_item_total)` | `SUM(sales_amount)` nếu cần doanh thu sau giảm giá | `sales_amount` là doanh thu trước giảm giá |
| Gross Sales | Order item | `SUM(sales_amount)` | — | Doanh thu trước giảm giá |
| Total Discount | Order item | `SUM(order_item_discount)` | — | Tiền giảm giá từng dòng |
| Total Profit | Order item | `SUM(order_profit_per_order)` | Chỉ dùng sau khi kiểm chứng | Tên cột gây hiểu nhầm |
| Profit Margin | Order item | `SUM(profit) / SUM(net_sales)` | `AVG(profit_ratio)` | Cần tỷ suất có trọng số |
| Late Delivery Rate | Order | Tính trên bảng một dòng mỗi đơn | Trung bình trực tiếp ở bảng line item | Tránh đơn nhiều dòng bị tính nhiều lần |
| Total Units Sold    | Order item | `SUM(order_item_quantity)`                         | `COUNT(order_item_id)`          | Một line item có thể bán nhiều hơn 1 sản phẩm.               |
| Average Order Value | Order      | `SUM(order_item_total) / COUNT(DISTINCT order_id)` | `AVG(order_item_total)`         | Trung bình line item không phải giá trị trung bình đơn hàng. |
| Discount Rate       | Order item | `SUM(order_item_discount) / SUM(sales_amount)`     | `AVG(order_item_discount_rate)` | Tỷ lệ gốc bị làm tròn; cần tỷ lệ có trọng số.                |

> Late Delivery Rate được tính từ bảng order-level (một dòng mỗi `order_id`).
> Trước khi tính, cần xác nhận `late_delivery_risk` nhất quán giữa các line item trong cùng một đơn.