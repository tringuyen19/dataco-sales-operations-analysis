# KPI Dictionary

## 1. Purpose

This KPI framework supports the Sales & Operations Manager in monitoring
commercial performance, profitability and delivery performance.

The dataset is recorded at order-item grain. KPI calculations must therefore
use the correct analysis view and reporting scope to avoid double counting or
including canceled shipments in the primary business baseline.

## 2. Reporting scopes

### Scope A — All recorded orders

- Includes all order statuses.
- Contains 65,752 recorded orders.
- Uses `vw_order_analysis` and `vw_order_item_analysis`.
- Used for source reconciliation, order-status analysis, cancellation analysis
  and sensitivity checks.

### Scope B — Non-canceled orders

- Excludes `CANCELED` and `SUSPECTED_FRAUD`.
- Contains 62,897 orders.
- Uses `vw_order_analysis_non_canceled` and
  `vw_order_item_analysis_non_canceled`.
- Used as the default scope for primary business and delivery analysis.

Scope B is called `non-canceled orders`, not `completed orders`, because other
unresolved statuses remain included. Recorded financial values are not assumed
to be recognized accounting revenue.

## 3. KPI classification

### Recorded and reconciliation KPIs

1. Recorded Orders
2. Recorded Net Sales
3. Recorded Total Profit
4. Cancellation Rate

### Primary outcome KPIs

1. Core Orders
2. Core Net Sales
3. Core Total Profit
4. Profit Margin

### Operational KPI / guardrail

1. Late Delivery Rate

### Driver and diagnostic metrics

- Gross Sales
- Total Discount
- Discount Rate
- Units Sold
- Average Order Value
- Total Customers
- Repeat Customer Rate
- Average Actual Delivery Days

## 4. KPI definitions

| KPI | Type | Business meaning | Formula | Grain / source | Default scope | Important limitation |
|---|---|---|---|---|---|---|
| Recorded Orders | Reconciliation | Tổng số đơn được ghi nhận trong nguồn | `COUNT(*)` | Order — `vw_order_analysis` | Scope A | Bao gồm canceled/fraud orders |
| Recorded Net Sales | Reconciliation | Tổng Net Sales được ghi trong nguồn | `SUM(net_sales)` | Order item — `vw_order_item_analysis` | Scope A | Không đồng nghĩa recognized revenue |
| Recorded Total Profit | Reconciliation | Tổng Profit được ghi trong nguồn | `SUM(line_profit)` | Order item — `vw_order_item_analysis` | Scope A | Bao gồm financial values của canceled/fraud orders |
| Cancellation Rate | Operational / scope | Tỷ lệ đơn thuộc nhóm bị loại khỏi Scope B | Orders with `order_status IN ('CANCELED', 'SUSPECTED_FRAUD')` / Recorded Orders | Order — `vw_order_analysis` | Scope A | `SUSPECTED_FRAUD` được tính vì nhóm này map sang `Shipping canceled`; phải ghi rõ định nghĩa |
| Core Orders | Primary driver | Số non-canceled orders trong baseline chính | `COUNT(*)` | Order — `vw_order_analysis_non_canceled` | Scope B | Không đồng nghĩa completed orders |
| Core Net Sales | Primary outcome | Net Sales của non-canceled orders | `SUM(net_sales)` | Order item — `vw_order_item_analysis_non_canceled` | Scope B | Là recorded value trong analytical scope, không phải accounting recognition |
| Core Total Profit | Primary outcome | Profit của non-canceled order items | `SUM(line_profit)` | Order item — `vw_order_item_analysis_non_canceled` | Scope B | `line_profit` lấy từ `order_profit_per_order` đã được kiểm chứng ở item grain |
| Profit Margin | Primary outcome | Profit tạo ra trên một đơn vị Net Sales | `SUM(line_profit) / NULLIF(SUM(net_sales), 0)` | Nhóm phân tích | Scope B; Scope A chỉ dùng sensitivity | Không dùng `AVG(order_item_profit_ratio)` |
| Late Delivery Rate | Operational guardrail | Tỷ lệ non-canceled orders có cờ giao trễ | Orders with `late_delivery_risk = 1` / orders with non-NULL risk | Order — `vw_order_analysis_non_canceled` | Scope B | Không tính trực tiếp trên order-item view; luôn hiển thị tử số và mẫu số |
| Gross Sales | Driver | Doanh thu trước giảm giá | `SUM(gross_sales)` | Order item | Scope B | Scope A chỉ dùng reconciliation/sensitivity |
| Total Discount | Driver | Tổng số tiền giảm giá thực tế | `SUM(discount_amount)` | Order item | Scope B | Không tính lại từ discount rate đã làm tròn |
| Discount Rate | Driver | Tỷ lệ giảm giá có trọng số trên Gross Sales | `SUM(discount_amount) / NULLIF(SUM(gross_sales), 0)` | Nhóm phân tích | Scope B | Không dùng `AVG(order_item_discount_rate)` |
| Units Sold | Driver | Tổng quantity được ghi nhận | `SUM(quantity)` | Order item | Scope B | Không dùng số order-item rows thay cho quantity |
| Average Order Value | Driver | Core Net Sales trung bình mỗi non-canceled order | `SUM(net_sales) / NULLIF(COUNT(*), 0)` | Order — `vw_order_analysis_non_canceled` | Scope B | Không dùng `AVG(order_item_total)` |
| Total Customers | Driver | Số khách hàng duy nhất có non-canceled order | `COUNT(DISTINCT customer_id)` | Order | Scope B | Không dùng số dòng hoặc số đơn |
| Repeat Customer Rate | Customer | Tỷ lệ khách hàng có từ hai non-canceled orders trở lên | Repeat customers / total customers | Customer summary built from order view | Scope B | Chỉ phản ánh hành vi quan sát được trong giai đoạn dữ liệu |
| Average Actual Delivery Days | Diagnostic | Số ngày giao thực tế trung bình mỗi non-canceled order | `AVG(actual_shipping_days)` | Order — `vw_order_analysis_non_canceled` | Scope B | Chỉ dùng cho orders có giá trị shipping days hợp lệ |

## 5. KPI hierarchy

### Core Net Sales

Possible drivers:

- Core Orders
- Average Order Value
- Units Sold
- Customer count
- Product and market mix

### Core Total Profit and Profit Margin

Possible drivers:

- Core Net Sales
- Discount Rate
- Product mix
- Market and region mix
- Negative-profit order items

### Late Delivery Rate

Possible drivers:

- Shipping Mode
- Market
- Order Region
- Actual Shipping Days
- Scheduled Shipping Days

## 6. Target decision

No formal KPI targets are set in this phase because the project does not yet
have an approved business target or historical benchmark.

Day 4 and later analyses establish dataset baselines. Any target shown later
must be labeled as provisional unless supported by a business requirement or
external benchmark.
