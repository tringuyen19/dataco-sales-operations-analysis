# Final Insights and Recommendations

## 1. Business Objective and Stakeholders

### 1.1. Business objective

Phân tích hỗ trợ **Sales & Operations Manager** đánh giá hiệu quả kinh doanh và xác định các ưu tiên hành động dựa trên dữ liệu. Các mục tiêu chính gồm:

- Theo dõi quy mô và hiệu quả kinh doanh qua **Sales, Profit, Profit Margin, Orders** và **Average Order Value (AOV)**.
- Xác định category, product, customer group và market đóng góp phần lớn giá trị kinh doanh.
- Phát hiện product có Sales cao nhưng Profit thấp hoặc âm để ưu tiên review.
- Đánh giá vai trò của repeat customers và mức độ tập trung doanh thu.
- Xác định Region và Shipping Mode cần ưu tiên điều tra về delivery performance.
- Chuyển kết quả SQL thành hành động có owner, KPI theo dõi và guardrail rõ ràng.

> **Phạm vi kết luận:** Phân tích mang tính mô tả, không dùng để suy luận quan hệ nhân quả. Recorded Net Sales và Recorded Profit cũng không đại diện cho recognized revenue hoặc realized profit theo chuẩn kế toán nếu chưa được Finance xác nhận.

### 1.2. Stakeholders and responsibilities

| Vai trò | Trách nhiệm chính |
|---|---|
| **Sales & Operations Manager** | Primary stakeholder; theo dõi kết quả kinh doanh và operational risk, xác định ưu tiên và điều phối hành động |
| Operations Manager | Điều tra delivery performance và cải thiện vận hành |
| Sales Manager / Sales & Product Manager | Bảo vệ nhóm tạo doanh thu chính và review product exceptions |
| CRM / Customer Management team | Phân tích sâu và thử nghiệm retention |
| Logistics / Fulfillment team | Điều tra Region và Shipping Mode có delivery risk cao |
| Finance / Accounting team | Xác nhận định nghĩa doanh thu, lợi nhuận và quy tắc ghi nhận |

## 2. Reporting Scope and Data Period

### 2.1. Data period

| Nội dung | Giá trị |
|---|---:|
| Khoảng thời gian | 2015-01-01 đến 2018-01-31 |
| Số tháng có đơn hàng | 37 tháng |

> **Lưu ý:** 2018-01 là tháng cuối của dataset. Không giả định xu hướng quan sát tại thời điểm này tiếp tục duy trì sau kỳ dữ liệu.

### 2.2. Reporting scopes

| Scope | Definition | Orders | Main use |
|---|---|---:|---|
| **Scope A — All recorded orders** | Bao gồm tất cả `order_status` | 65,752 | Audit, reconciliation, cancellation và sensitivity analysis |
| **Scope B — Non-canceled orders** | Loại `CANCELED` và `SUSPECTED_FRAUD` | 62,897 | Phạm vi phân tích kinh doanh chính |

Scope B là **non-canceled scope**, không phải completed-order scope. Phạm vi này vẫn gồm các trạng thái chưa hoàn tất: `PENDING`, `PROCESSING`, `ON_HOLD`, `PAYMENT_REVIEW` và `PENDING_PAYMENT`.

Vì vậy, **Recorded Net Sales** không được gọi là **recognized revenue** nếu chưa có business rule hoặc xác nhận từ Finance.

### 2.3. Scope comparison

| KPI | Scope A | Scope B | Difference |
|---|---:|---:|---:|
| Orders | 65,752 | 62,897 | -2,855 |
| Recorded Net Sales | 33,054,402.04 | 31,644,664.75 | -1,409,737.29 |
| Recorded Profit | 3,966,902.97 | 3,806,420.63 | -160,482.34 |
| Profit Margin | 12.00% | 12.03% | +0.03 điểm % |
| Average Order Value | 502.71 | 503.12 | +0.41 |

Nhóm bị loại khỏi Scope B chiếm **4.34% Orders**, **4.26% Recorded Net Sales** và **4.05% Recorded Profit** của Scope A. Quy mô Sales và Profit giảm khoảng 4%, trong khi Profit Margin chỉ tăng **0.03 điểm phần trăm**.

### 2.4. Analysis grain and source views

| Nội dung phân tích | Source view | Grain |
|---|---|---|
| Orders, AOV, Customer, Segment, Market, Region và Delivery | `vw_order_analysis_non_canceled` | Một dòng / order |
| Category, Product, Units, Discount, Net Sales và line Profit | `vw_order_item_analysis_non_canceled` | Một dòng / order item |
| Repeat và One-time customers | Customer summary từ order view | Một dòng / customer |

**Nguyên tắc tổng hợp**

- Tính số Orders ở order grain; khi dùng item view phải áp dụng `COUNT(DISTINCT order_id)`.
- Tính Profit Margin bằng `SUM(profit) / SUM(net_sales)`.
- Tính AOV bằng Net Sales chia distinct Orders.
- Không nối order view với order-item view rồi cộng lại Sales hoặc Profit.
- Tính ratio từ tổng tử số và tổng mẫu số, không lấy trung bình ratio cấp dòng.

### 2.5. Currency

Gross Sales, Discount, Net Sales và Profit sử dụng đơn vị tiền tệ gốc của dataset. Metadata hiện chưa xác nhận mã tiền tệ cụ thể.

## 3. Final KPI Baseline

### 3.1. Executive KPI baseline — Scope B

| KPI | Result | Definition |
|---|---:|---|
| Total Orders | 62,897 | Distinct non-canceled orders |
| Total Customers | 20,261 | Customers có ít nhất một Scope B order |
| Recorded Net Sales | 31,644,664.75 | Tổng recorded Net Sales |
| Recorded Profit | 3,806,420.63 | Tổng recorded Profit |
| Profit Margin | 12.03% | Profit / Net Sales |
| Average Order Value | 503.12 | Net Sales / Orders |
| Late Orders | 36,048 | Orders có `late_delivery_risk = 1` |
| Late Delivery Rate | 57.31% | Late Orders / Scope B Orders |

### 3.2. Supporting customer KPIs

| KPI | Result |
|---|---:|
| Repeat Customers | 11,644 |
| Repeat Customer Rate | 57.47% |
| Repeat Revenue Share | 92.21% |
| Revenue per Repeat Customer | 2,505.85 |
| Revenue per One-time Customer | 286.25 |
| Top 10 Customer Revenue Share | 0.26% |
| Top 10% Customer Revenue Share | 29.08% |

### 3.3. Interpretation notes

- Recorded Net Sales và Recorded Profit phản ánh giá trị trong dataset, chưa mặc định là giá trị được Finance ghi nhận.
- Late Delivery Rate dùng toàn bộ **62,897 Scope B Orders** làm mẫu số theo logic dữ liệu hiện tại.
- Repeat Customer Rate chỉ phản ánh hành vi trong giai đoạn dữ liệu quan sát được.
- Revenue per Customer không phải Customer Lifetime Value (CLV).

## 4. Sales and Time Insights

### Insight 1 — Monthly growth was primarily associated with higher sales volume

Recorded Net Sales tháng 03-2015 tăng **14.24%** so với tháng trước. Các chỉ số cùng kỳ cho thấy mức tăng chủ yếu đi cùng sự mở rộng về volume:

| Chỉ số | Thay đổi so với tháng trước |
|---|---:|
| Orders | +197 |
| Units Sold | +1,614 |
| Average Order Value | +0.86% |

Số Orders và Units Sold tăng rõ rệt trong khi AOV gần như ổn định. Vì vậy, tăng trưởng tháng 03-2015 chủ yếu gắn với **nhiều đơn hàng và sản phẩm bán ra hơn**, thay vì giá trị trung bình mỗi đơn tăng mạnh.

**Supporting observations**

- Tháng có Recorded Net Sales cao nhất: **09-2017 — 976,907.91**.
- Tháng có Recorded Net Sales thấp nhất: **01-2018 — 289,456.78**.
- Kết quả theo tháng cần được đọc cùng Orders, Units Sold, AOV, Profit và Profit Margin.
- 01-2018 là kỳ cuối dataset nên cần được chú thích khi so sánh xu hướng.

**Business implication:** Dashboard nên hiển thị đồng thời Monthly Net Sales, Monthly Profit, Total Orders, AOV và Profit Margin để phân biệt tăng trưởng từ quy mô, giá trị đơn hàng hay hiệu quả lợi nhuận.

> **Giới hạn:** Đây là so sánh giữa hai tháng. Dataset chưa có campaign, seasonality, promotion calendar hoặc external market data để xác định nguyên nhân volume tăng.

**SQL reference:** [`06_business_analysis_sales_product.sql`](../sql/06_business_analysis_sales_product.sql) — Monthly Performance và Month-over-Month Analysis.

## 5. Product and Category Insights

### Insight 2 — Category dẫn đầu Sales không phải category có Margin cao nhất

| Category | Recorded Net Sales | Sales Share | Recorded Profit | Profit Margin | Vai trò |
|---|---:|---:|---:|---:|---|
| Fishing | 5,964,765.28 | 18.85% | 731,576.18 | 12.26% | Dẫn đầu về quy mô |
| Golf Bags & Carts | — | — | — | 19.25% | Dẫn đầu về hiệu quả margin |

Kết quả cho thấy cần tách hai mục tiêu quản lý category:

- **Scale:** bảo vệ category tạo Sales và Profit tuyệt đối lớn.
- **Efficiency:** đánh giá khả năng mở rộng category có Profit Margin cao.

Fishing cần được bảo vệ về quy mô; Golf Bags & Carts cần được đánh giá thêm về khả năng mở rộng mà không làm giảm Margin.

> **Giới hạn:** Chưa có inventory, demand, stockout, capacity và benchmark margin để kết luận nên chuyển ngân sách hoặc nguồn lực giữa hai category.

### Insight 3 — Business performance tập trung vào một nhóm product nhỏ

| Chỉ số tập trung | Kết quả |
|---|---:|
| Tổng số products | 118 |
| Top 10 Product Sales Share | 89.99% |
| Sales Share của 108 products còn lại | 10.01% |
| Mức trùng giữa Top 10 theo Sales và theo Total Profit | 10/10 |

Top 10 products tạo phần lớn Sales và Profit tuyệt đối. Nhóm này cần được theo dõi định kỳ qua Net Sales, Total Profit, Profit Margin, Discount Rate, Units Sold, Distinct Orders và Sales Share.

Mức tập trung cao chưa tự động đồng nghĩa với business risk khi chưa có threshold chính thức. Tuy nhiên, sự suy giảm của một vài products trong Top 10 có thể ảnh hưởng đáng kể đến kết quả tổng thể.

### Insight 4 — SOLE E35 là product exception cần review riêng

| KPI | Kết quả |
|---|---:|
| Product | SOLE E35 Elliptical |
| Recorded Net Sales | 26,409.85 |
| Recorded Profit | -965.12 |
| Số tháng có Profit âm | 2 |
| Tháng có Profit thấp nhất | 09-2017 |
| Tháng có Discount Rate cao nhất | 09-2017 |

Cần drill-down exception này theo Month, Market, Region, Order Status, Discount, Product Cost, Returns và Fulfillment Cost.

> **Giới hạn:** Discount Rate cao và Profit âm chỉ có quan hệ association. Profit còn có thể bị ảnh hưởng bởi cost, returns, shipping và product mix.

**SQL reference:** [`06_business_analysis_sales_product.sql`](../sql/06_business_analysis_sales_product.sql) — Category Performance, Product Concentration và Product Exception.

## 6. Customer and Market Insights

### Insight 5 — Repeat customers tạo phần lớn giá trị nhưng doanh thu không phụ thuộc vào vài khách hàng riêng lẻ

| KPI | Kết quả |
|---|---:|
| Repeat Customers | 11,644 / 20,261 |
| Repeat Customer Rate | 57.47% |
| Repeat Revenue Share | 92.21% |
| Revenue per Repeat Customer | 2,505.85 |
| Revenue per One-time Customer | 286.25 |
| Chênh lệch Revenue per Customer | 8.76 lần |
| Top 10 Customer Revenue Share | 0.26% |
| Top 10% Customer Revenue Share | 29.08% |

Doanh thu phụ thuộc vào **repeat-customer base theo nghĩa rộng**, nhưng không tập trung quá mức vào một vài khách hàng riêng lẻ. Vì vậy, customer management nên ưu tiên trải nghiệm của toàn bộ repeat base thay vì chỉ tập trung vào một số key accounts.

> **Giới hạn:** Repeat chỉ có nghĩa là customer có ít nhất hai observed orders trong dataset period. `first_observed_order` có thể không phải đơn đầu tiên trong toàn bộ lịch sử; kết quả không chứng minh loyalty. Dataset cũng chưa có churn, campaign exposure, acquisition cost hoặc retention cost, và Revenue per Customer không phải CLV.

### Insight 6 — Consumer là segment quan trọng nhất nhưng delivery performance còn yếu

| KPI | Consumer |
|---|---:|
| Recorded Net Sales | 16,417,549.44 |
| Sales Share | 51.88% |
| Recorded Profit | 1,982,863.62 |
| Profit Margin | 12.08% |
| Average Order Value | 503.39 |
| Chênh lệch Net Sales với segment thứ hai | 6,555,497.86 |
| Late Orders | 18,672 |
| Evaluable Orders | 32,614 |
| Late Delivery Rate | 57.25% |

Consumer tạo hơn một nửa Recorded Net Sales, nên biến động Sales hoặc Delivery của segment này có thể ảnh hưởng lớn đến kết quả chung.

> **Giới hạn:** Chưa có satisfaction, complaint, next-purchase behavior hoặc churn để đo tác động thực tế của giao trễ đến khả năng khách hàng quay lại.

### Market observation

Europe dẫn đầu về Recorded Net Sales trong Scope B. Tuy nhiên, thứ hạng Sales chưa đủ để xác định ưu tiên. Việc đánh giá Market cần kết hợp Net Sales, Sales Share, Total Profit, Profit Margin, Total Orders, Late Orders, Late Delivery Rate và Shipping Mode mix.

**SQL reference:** [`07_business_analysis_customer_market_delivery.sql`](../sql/07_business_analysis_customer_market_delivery.sql) — Customer, Segment, Market và Delivery Analysis.

## 7. Delivery Insights

### Insight 7 — Giao trễ là vấn đề vận hành trên toàn network

| KPI | Kết quả |
|---|---:|
| Late Orders | 36,048 |
| Total Orders | 62,897 |
| Late Delivery Rate | 57.31% |
| Regions có Late Delivery Rate ≥ 50% | 23 / 23 |

| Phân phối theo Region | Late Delivery Rate |
|---|---:|
| Minimum | 52.58% |
| Median | 57.28% |
| Maximum | 60.04% |

Giao trễ xuất hiện rộng trên toàn network, không chỉ ở một vài khu vực. Các Region ưu tiên điều tra dựa trên sự kết hợp giữa business value, late-order volume và Late Delivery Rate gồm:

- Western Europe
- Southeast Asia
- South Asia
- Eastern Asia
- East of USA

> Mốc 50% chỉ mô tả rằng đa số orders trong Region bị đánh dấu late; đây không phải SLA hoặc business target chính thức.

### Shipping Mode observation

First Class có delivery performance quan sát yếu nhất:

| KPI | First Class |
|---|---:|
| Late Orders | 9,602 |
| Evaluable Orders | 9,602 |
| Late Delivery Rate | 100% |
| Average Actual Shipping Days | 2 |
| Average Scheduled Shipping Days | 1 |
| Average Delay Days | 1 |
| Recorded Net Sales | 4,860,949.70 |
| Profit Margin | 12.68% |

Tại Europe, First Class có Late Delivery Rate **100%** và Second Class đạt **80.17%**. Hai tổ hợp **Europe × First Class** và **Europe × Second Class** cần được ưu tiên điều tra vì đồng thời có substantial Net Sales và late-order volume cao.

> **Giới hạn:** Kết quả không chứng minh Shipping Mode gây ra giao trễ. Khác biệt có thể liên quan đến geography, carrier, warehouse, product mix, route hoặc service-level definition.

### Late versus Not Late composition

Market và Region composition của hai nhóm tương đối giống nhau ở các nhóm dẫn đầu, trong khi Shipping Mode mix khác biệt rõ rệt:

| Shipping Mode | Share trong Late | Share trong Not Late | Difference |
|---|---:|---:|---:|
| Standard Class | 41.60% | 84.31% | -42.71 điểm % |
| Second Class | 27.19% | 9.14% | +18.05 điểm % |
| First Class | 26.64% | 0.00% | +26.64 điểm % |
| Same Day | 4.57% | 6.55% | -1.98 điểm % |

Shipping Mode là tín hiệu phân loại mạnh nhất được quan sát giữa hai nhóm. Đây là cơ sở để drill-down, không phải bằng chứng về causation.

### Scope A delivery audit

Scope A có **1,650 orders** thuộc `CANCELED` hoặc `SUSPECTED_FRAUD` với Actual Shipping Days lớn hơn Scheduled Shipping Days nhưng `late_delivery_risk = 0`; các orders này map tới `Shipping canceled`.

Nhóm này được giữ để audit nhưng không đưa vào Scope B delivery KPI. Shipping-duration fields không chứng minh canceled orders đã được giao thành công.

**SQL reference:** [`07_business_analysis_customer_market_delivery.sql`](../sql/07_business_analysis_customer_market_delivery.sql) — Region, Shipping Mode và Late-versus-Not-Late Analysis.

## 8. Prioritized Recommendations

### 8.1. Priority summary

| Priority | Recommendation | Owner | Main KPI | Guardrail |
|---:|---|---|---|---|
| 1 | Điều tra delivery process theo Region × Shipping Mode | Operations Manager | Late Rate, Late Orders, Avg Delay | Orders, Net Sales, Profit Margin |
| 2 | Phân rã repeat base và thiết kế retention test nhỏ | Sales / CRM Manager | Repeat Rate, Repeat Revenue Share | Margin, Discount Rate |
| 3 | Review Top 10 products và product exceptions | Sales / Product Manager | Sales, Profit, Margin | Units, Orders, Sales Share |
| 4 | Quản lý category theo hai mục tiêu scale và margin | Sales Manager | Sales, Profit, Margin | Orders, Units, Discount Rate |
| 5 | Theo dõi Consumer bằng KPI Sales và Delivery | Sales & Operations Manager | Segment Sales, Late Rate | Margin, AOV |

### 8.2. Recommendation 1 — Investigate delivery process

**Owner:** Operations Manager  
**Action:** Điều tra delivery process theo Region × Shipping Mode, ưu tiên Western Europe, Southeast Asia, South Asia, Eastern Asia, East of USA, Europe × First Class và Europe × Second Class.  
**KPI:** Late Delivery Rate, Late Orders, Average Delay Days, Average Actual Shipping Days và Average Scheduled Shipping Days.  
**Guardrail:** Total Orders, Recorded Net Sales và Profit Margin.  
**Decision gate:** Chưa thay đổi toàn bộ shipping policy trước khi có carrier, warehouse, route, distance và shipping-cost data.

### 8.3. Recommendation 2 — Analyze repeat customers before retention investment

**Owner:** Sales / CRM Manager  
**Action:** Phân rã repeat base theo Customer Segment, Market, Region, product/category mix, order frequency, recency trong observed period và delivery experience; sau đó thiết kế retention test quy mô nhỏ.  
**KPI:** Repeat Customer Rate, Repeat Revenue Share, Orders per Customer và Revenue per Customer.  
**Guardrail:** Profit Margin, Discount Rate và Cost per Retained Customer khi có dữ liệu.  
**Decision gate:** Chưa triển khai khuyến mãi cho toàn bộ repeat base khi chưa có churn, campaign exposure, acquisition cost và retention cost.

### 8.4. Recommendation 3 — Protect key products and review exceptions

**Owner:** Sales / Product Manager  
**Action:** Thiết lập review định kỳ cho Top 10 products; drill-down SOLE E35 Elliptical và các products có Sales dương nhưng Profit thấp hoặc âm theo Month, Market, Region, Discount, Order Status, Returns và Fulfillment Cost.  
**KPI:** Net Sales, Total Profit, Profit Margin và Discount Rate.  
**Guardrail:** Units Sold, Distinct Orders và Sales Share.  
**Decision gate:** Chưa ngừng bán product chỉ dựa trên Profit hiện tại khi chưa có cost breakdown, inventory, returns và fulfillment cost.

### 8.5. Recommendation 4 — Separate category scale and margin decisions

**Owner:** Sales Manager  
**Action:** Bảo vệ category tạo Sales lớn và đánh giá khả năng mở rộng category có Margin tốt.  
**KPI:** Net Sales, Total Profit và Profit Margin.  
**Guardrail:** Orders, Units Sold và Discount Rate.  
**Decision gate:** Chưa phân bổ lại ngân sách trước khi có inventory, demand, stockout, capacity và benchmark margin.

### 8.6. Recommendation 5 — Monitor Consumer through business and delivery KPIs

**Owner:** Sales & Operations Manager  
**Action:** Theo dõi Consumer bằng cả KPI kinh doanh và vận hành.  
**KPI:** Consumer Net Sales, Consumer Profit, Late Orders và Late Delivery Rate.  
**Guardrail:** Profit Margin, AOV và Total Orders.  
**Decision gate:** Cần bổ sung satisfaction, complaint, next purchase và churn data để đánh giá tác động của giao trễ đến hành vi khách hàng.

## 9. Limitations

- Scope B loại `CANCELED` và `SUSPECTED_FRAUD` nhưng vẫn chứa một số order status chưa hoàn tất.
- Recorded Net Sales và Recorded Profit không tự động đồng nghĩa với recognized revenue hoặc realized profit theo chuẩn kế toán.
- Metadata chưa xác nhận currency code của các financial fields.
- 01-2018 là kỳ cuối dataset và cần được chú thích khi phân tích xu hướng.
- Chưa có target hoặc benchmark chính thức cho Profit Margin, Discount Rate và Late Delivery Rate.
- Repeat customer chỉ dựa trên observed orders trong dataset period; kết quả không chứng minh loyalty.
- Revenue per Customer không phải Customer Lifetime Value.
- Chưa có carrier, warehouse, route, distance, shipping cost, returns, complaints và customer satisfaction.
- Chưa có campaign exposure, acquisition cost, retention cost và churn để tính retention ROI.
- Association giữa Shipping Mode, Discount, Delivery và financial outcomes không chứng minh quan hệ nhân quả.
- Product Profit chưa được phân rã đầy đủ theo product cost, fulfillment cost và returns.
- Market và Region là analytical dimensions, không phải nguyên nhân trực tiếp gây ra Sales hoặc Delivery performance.
- Mức tập trung Sales chưa thể được gọi là business risk khi chưa có threshold chính thức.
- Scope A có 1,650 canceled/fraud orders với Actual Shipping Days lớn hơn Scheduled Shipping Days nhưng risk bằng 0. Đây là data-quality audit item, không phải Scope B delivery finding.

## 10. Next Data Needed

| Câu hỏi tiếp theo | Dữ liệu cần bổ sung | Mục đích |
|---|---|---|
| Vì sao orders bị giao trễ? | Carrier, warehouse, route, distance, processing time, promised và delivered timestamps | Phân rã nguyên nhân delivery |
| Shipping Mode có thực sự ảnh hưởng lateness không? | Carrier, Region, route, product mix, service-level rules | Kiểm soát biến nhiễu |
| Giao trễ ảnh hưởng customer không? | Complaint, satisfaction, next purchase, churn | Đo business impact |
| Có nên đầu tư retention không? | Campaign, acquisition cost, retention cost, churn, incentive | Tính retention ROI |
| Vì sao SOLE E35 bị lỗ? | Cost breakdown, returns, fulfillment cost, promotions | Xác định profit driver |
| Category Margin cao có mở rộng được không? | Inventory, demand, stockout, capacity, lead time | Đánh giá khả năng scale |
| Recorded Sales có phải recognized revenue không? | Payment, invoice, fulfillment và accounting status | Xác nhận financial scope |
| Target Delivery và Margin là bao nhiêu? | SLA và business benchmark chính thức | Thiết lập KPI target |
| Customer có thực sự trung thành không? | Lịch sử trước/sau dataset period, churn, cohort data | Đo retention và CLV |
| Tác động của discount là gì? | Campaign purpose, promotion type, unit cost và control group | Đánh giá discount effectiveness |

## 11. SQL Traceability

| Report item | KPI / Finding | Source view | Grain | SQL reference | Expected result |
|---|---|---|---|---|---|
| Total Orders | Distinct Scope B orders | `vw_order_analysis_non_canceled` | Order | Scope/model validation | 62,897 |
| Total Customers | Distinct customer ID | `vw_order_analysis_non_canceled` | Order | `02_CUSTOMER_SUMMARY` | 20,261 |
| Net Sales | Sum order Net Sales | Order view; reconcile item view | Order | Final reconciliation | 31,644,664.75 |
| Total Profit | Sum order Profit | Order view; reconcile item view | Order | Final reconciliation | 3,806,420.63 |
| Profit Margin | Profit / Net Sales | Order view | Order | Business overview | 12.03% |
| Average Order Value | Net Sales / Orders | Order view | Order | Business overview | 503.12 |
| Monthly performance | Sales, Profit, Orders và AOV theo tháng | Order view | Order-month | Day 4 monthly/MoM section | Scope B monthly output |
| Category performance | Sales, Profit và Margin theo category | `vw_order_item_analysis_non_canceled` | Order item | Day 4 category section | Fishing dẫn đầu Sales |
| Product concentration | Cumulative Product Sales Share | Item view | Product | Day 4 product concentration | Top 10 = 89.99% |
| Product exception | Sales dương, Profit thấp/âm | Item view | Product-month | Day 4 exception section | SOLE E35 Profit = -965.12 |
| Segment performance | Sales, Profit, AOV và Late Rate | Order view | Segment | `01_CUSTOMER_SEGMENT_PERFORMANCE` | Consumer dẫn đầu |
| Repeat contribution | Repeat customers và Sales Share | Customer summary | Customer | `02_CUSTOMER_SUMMARY`, `03_REPEAT_CUSTOMER_RATE` | 57.47%; 92.21% |
| Customer concentration | Ranked cumulative Sales Share | Customer summary | Customer | `04_CUSTOMER_REVENUE_CONCENTRATION` | Top 10% = 29.08% |
| Market performance | Sales, Profit và Late Rate theo Market | Order view | Market | `05_MARKET_ANALYSIS` | Europe dẫn đầu Sales |
| Region performance | Sales, Late Orders và Late Rate | Order view | Region | `06_REGION_ANALYSIS` | 23/23 Regions ≥ 50% |
| Overall delivery | Late Orders / Scope B Orders | Order view | Order | `08_OVERALL_DELIVERY_KPI` | 36,048 / 62,897 |
| Scope A delivery audit | Canceled/fraud duration inconsistency | `vw_order_analysis` | Order | `07A`, `09A` | 1,650 audit records |
| Shipping Mode | Late Rate và delay theo mode | Order view | Shipping Mode | `10_SHIPPING_MODE_PERFORMANCE` | First Class = 100% |
| Market × Shipping Mode | Delivery priority combinations | Order view | Market-mode | `11_MARKET_AND_SHIPPING_MODE` | Europe × First/Second Class |
| Late vs Not Late | Composition comparison | Order view | Delivery group | `12_LATE_VERSUS_NOT_LATE` | Shipping Mode mix differs |
| Final reconciliation | Dimension totals về baseline | Order/customer summaries | Multiple | `13_FINAL_RECONCILIATION` | Differences = 0 |

**Source files:** [`06_business_analysis_sales_product.sql`](../sql/06_business_analysis_sales_product.sql), [`07_business_analysis_customer_market_delivery.sql`](../sql/07_business_analysis_customer_market_delivery.sql) và [`08_final_validation_and_dashboard_dataset.sql`](../sql/08_final_validation_and_dashboard_dataset.sql).
