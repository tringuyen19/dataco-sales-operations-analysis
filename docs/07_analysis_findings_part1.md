# SQL Business Analysis — Part 1

## 0. Reporting scope and data period

### 0.1. Data period

Dataset bao phủ khoảng thời gian từ `2015-01-01` đến `2018-01-31`,
tương ứng 37 tháng có phát sinh đơn hàng.

### 0.2. Reporting scopes

Project phân biệt hai reporting scopes:

| Scope | Definition | Orders | Main use |
|---|---|---:|---|
| Scope A — All recorded orders | Bao gồm tất cả `order_status` | 65,752 | Source reconciliation, status, cancellation và sensitivity |
| Scope B — Non-canceled orders | Loại `CANCELED` và `SUSPECTED_FRAUD` | 62,897 | Primary business-performance analysis |

Scope B là non-canceled scope, không phải completed-order scope vì vẫn chứa
các trạng thái chưa hoàn tất khác.

### 0.3. Analysis grain and source views

- Baseline, monthly và order-level analysis sử dụng
  `vw_order_analysis_non_canceled`.
- Category và product analysis sử dụng
  `vw_order_item_analysis_non_canceled`.
- Số orders trong item view được tính bằng
  `COUNT(DISTINCT order_id)`.
- Financial totals được cộng trước; các ratio được tính từ tổng tử số và tổng
  mẫu số.
- Hai view Scope A cũ được giữ để reconciliation và sensitivity.

### 0.4. Currency

Gross Sales, Discount, Net Sales và Profit được trình bày theo đơn vị tiền tệ
gốc của dataset. Metadata hiện chưa xác nhận mã tiền tệ cụ thể.

### 0.5. Revalidation status

Tài liệu này đã được chuyển sang cấu trúc Scope B. Các số liệu chỉ được ghi là
Scope B khi đã có query hoặc phép đối soát chứng minh. Monthly, category và
product results phải được chạy lại trước khi đánh dấu findings tương ứng là
final.

## 1. Business overview

### 1.1. Scope comparison

| KPI | Scope A | Scope B | Difference |
|---|---:|---:|---:|
| Orders | 65,752 | 62,897 | -2,855 |
| Net Sales | 33,054,402.04 | 31,644,664.75 | -1,409,737.29 |
| Total Profit | 3,966,902.97 | 3,806,420.63 | -160,482.34 |
| Profit Margin | 12.00% | 12.03% | +0.03 percentage point |
| Average Order Value | 502.71 | 503.12 | +0.41 |

Canceled/fraud orders chiếm:

- 4.34% recorded orders;
- 4.26% recorded Net Sales;
- 4.05% recorded Profit.

Loại nhóm này làm Net Sales và Profit giảm khoảng 4%, trong khi Profit Margin
tổng thể chỉ tăng nhẹ từ 12.00% lên 12.03%.

### 1.2. Scope B baseline

Primary baseline hiện được xác nhận gồm:

- Core Orders: 62,897;
- Core Net Sales: 31,644,664.75;
- Core Total Profit: 3,806,420.63;
- Profit Margin: 12.03%;
- Average Order Value: 503.12.

Gross Sales, Total Discount, Units Sold, Total Customers và Discount Rate của
Scope B phải được cập nhật sau khi chạy lại Day 4 queries. Không sử dụng các số
Scope A cũ cho những KPI này.

## 2. Monthly performance revalidation

### 2.1. Previous Scope A reference

| Check | Previous Scope A result | Scope B status |
|---|---|---|
| Highest Net Sales month | 09-2017 — 1,027,111.72 | 09-2017 — 976,907.91 |
| Lowest Net Sales month | 01-2018 — 297,952.05 | 01-2018 — 289,456.78 |
| March 2015 MoM Net Sales | +13.33% | 14.24% |
| March 2015 order increase | +196 orders |  197 orders |
| March 2015 Units Sold increase | +1,624 units | +1,614 units |

Các giá trị Scope A trên chỉ được giữ làm reference. Không mô tả chúng là
Scope B cho đến khi chạy query từ `vw_order_analysis_non_canceled`.

### 2.2. Required Scope B checks

Phải xác nhận:

1. Tháng Net Sales cao nhất và thấp nhất có đổi không.
2. Tháng tăng và giảm mạnh nhất có đổi không.
3. Hướng biến động của tháng 03-2015 có giữ nguyên không.
4. Thay đổi Net Sales đến từ Core Orders, Average Order Value hay Units Sold.
5. Profit Margin theo tháng có thay đổi đủ lớn để sửa interpretation không.

### 2.3. Finding decision rule

Nếu ranking và hướng biến động không đổi, ghi:

> Monthly results were revalidated under the non-canceled scope. Major
> directional findings remained stable.

Nếu có thay đổi, chỉ sửa tháng hoặc finding bị ảnh hưởng; không xóa toàn bộ
monthly analysis.

## 3. Category performance revalidation

### 3.1. Previous Scope A reference

| Check | Previous Scope A result | Scope B status |
|---|---|---|
| Top category by Net Sales | Fishing — 6,226,935.12 | Fishing — 5,964,765.28 |
| Fishing Net Sales share | 18.84% | 18.85% |
| Highest-margin category | Golf Bags & Carts — 19.25% | Golf Bags & Carts — 19.25% |
| Top 10 category share | 90.23% | 90.24% |

### 3.2. Required Scope B checks

Phải xác nhận:

1. Top category có đổi không.
2. Net Sales share của Fishing có đổi đáng kể không.
3. Highest-margin category có đổi không.
4. Top 10 category contribution có đổi không.
5. Median Net Sales và median Profit Margin có thay đổi không.
6. Category nào đổi nhóm High/Low sau khi tính lại median.

Không được giữ nguyên four-group classification bằng median Scope A vì chính
benchmark median cũng thay đổi khi scope thay đổi.

## 4. Product exceptions and concentration revalidation

### 4.1. Previous Scope A reference

| Check | Previous Scope A result | Scope B status |
|---|---|---|
| Top product by Net Sales | Field & Stream Sportsman 16 Gun Fire Safe | Field & Stream Sportsman 16 Gun Fire Safe |
| Top 10 Sales/Profit overlap | 10/10 products | 10/10 products |
| High-sales negative-profit exception | SOLE E35 Elliptical | SOLE E35 Elliptical |
| Top 10 product Net Sales share | 89.98% | 89.99% |
| Total distinct products | 118 | 118 |

### 4.2. Required Scope B checks

Phải xác nhận:

1. Top 10 products có đổi thành viên hoặc thứ hạng không.
2. Sales/Profit overlap có còn là 10/10 không.
3. `SOLE E35 Elliptical` có còn trên median Net Sales và Profit âm không.
4. Hai tháng Profit âm của sản phẩm này có còn giữ nguyên không.
5. Top 1, Top 3, Top 5 và Top 10 concentration shares có đổi không.
6. Tổng số products xuất hiện trong Scope B có còn là 118 không.

## 5. Findings status

### Finding 01 — Scope B business baseline

Scope B gồm `62,897` non-canceled orders, tạo ra Core Net Sales
`31,644,664.75` và Core Total Profit `3,806,420.63`, tương ứng Profit Margin
`12.03%`.

So với Scope A, loại `2,855` canceled/fraud orders làm Net Sales giảm
`1,409,737.29` và Profit giảm `160,482.34`. Profit Margin chỉ tăng `0.03` điểm phần
trăm, cho thấy margin tổng thể tương đối ổn định nhưng không đảm bảo monthly,
category hoặc product rankings giữ nguyên.

### Finding 02 — Scope B Monthly growth driver

Net Sales tháng `03-2015` tăng `14.24%` so với tháng trước, từ
`833,012.42` lên `944,050.10`.

Trong khi AOV chỉ tăng nhẹ `0.86%`, số đơn tăng `197` đơn và Units Sold
tăng `1,614` units. Total Profit và Profit Margin cũng tăng, cho thấy
tăng trưởng trong tháng này đi cùng với cải thiện về cả quy mô bán hàng
và hiệu quả lợi nhuận.

### Finding 03 — Category scale versus margin

`Fishing` là category có Net Sales cao nhất, đạt `5,964,765.28`, đóng
góp `18.8%` tổng Net Sales. Category này cũng tạo ra Total Profit
`731,576.18`, với Profit Margin `12.26%`.

Tuy nhiên, `Golf Bags & Carts` có Profit Margin cao nhất là `19.25%`.
Do đó, category dẫn đầu về doanh thu không đồng nghĩa là category hiệu
quả nhất về tỷ suất lợi nhuận.


### Finding 04 — Product revenue concentration

Trong tổng số `118` sản phẩm, Top 10 đóng góp `89.99%` tổng Net Sales;
108 sản phẩm còn lại chỉ đóng góp `10.01%`.

Điều này cho thấy kết quả doanh thu tổng thể phụ thuộc đáng kể vào hiệu quả của
một nhóm sản phẩm nhỏ, nên nhóm này cần được ưu tiên theo dõi về Sales,
Profit Margin và Discount Rate.

### Finding 05 — High-sales negative-profit product

`SOLE E35 Elliptical` đạt Net Sales `26,409.85` nhưng ghi nhận Total
Profit âm `-965.12`.

Drill-down cho thấy product này có Profit âm trong `2` tháng; tháng
`09-2017` đồng thời là tháng có Profit thấp nhất và Discount Rate cao
nhất. Đây là dấu hiệu cần kiểm tra sâu hơn theo order status, market,
region và các yếu tố liên quan đến discount trước khi kết luận nguyên
nhân gây lỗ.

## 6. Limitations

1. Scope B loại rõ ràng canceled/fraud orders nhưng vẫn chứa các status như
   `PENDING`, `PROCESSING`, `ON_HOLD` và `PAYMENT_REVIEW`.
2. Recorded Net Sales và Profit không tự động đồng nghĩa với recognized revenue
   hoặc realized profit theo chuẩn kế toán.
3. Dataset chưa cung cấp target hoặc benchmark chính thức; category groups và
   product exceptions vẫn là đánh giá tương đối.
4. Quan hệ giữa Discount Rate và Profit không chứng minh quan hệ nhân quả.
5. Currency code chưa được xác nhận trong metadata.
6. Monthly, category và product findings chưa được đánh dấu final cho đến khi
   Scope B queries được chạy và đối soát.

## 7. Questions carried to Day 5

1. Customer segment nào đóng góp Core Net Sales, Core Total Profit và Profit
   Margin lớn nhất?
2. Market và region nào có Core Net Sales cao nhưng Profit Margin thấp?
3. Revenue có tập trung vào một nhóm nhỏ customers tương tự product không?
4. `SOLE E35 Elliptical` có Profit âm tập trung ở market hoặc region cụ thể
   nào dưới Scope B không?
5. Delivery performance khác nhau thế nào theo market, region và shipping mode
   sau khi canceled/fraud orders đã được loại?










