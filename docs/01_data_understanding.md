# Data Understanding

## 1. Dataset overview

### Evidence

| Metric | Result |
|---|---:|
| Total rows | 180,519 |
| Distinct orders | 65,752 |
| Distinct order items | 180,519 |
| Distinct customers | 20,652 |
| Distinct products | 118 |

### Interpretation

Bảng có 180,519 dòng và cũng có 180,519 `order_item_id` khác nhau, trong khi chỉ có 65,752 `order_id` khác nhau. Điều này cho thấy một đơn hàng có thể xuất hiện ở nhiều dòng; mỗi dòng có khả năng là một order item.

## 2. Sample record review

Dữ liệu mẫu cho thấy một `order_id` có thể xuất hiện ở nhiều dòng với `product_card_id`, số lượng, doanh thu và lợi nhuận khác nhau. Các thuộc tính như khách hàng, ngày đặt hàng và trạng thái đơn cần được kiểm tra tính nhất quán ở các bước tiếp theo.

## 3. Order-level and item-level relationship

### 3.1. Repeated order IDs

**Result:** Có các `order_id` xuất hiện nhiều hơn một lần. Đơn có nhiều dòng nhất gồm `5` dòng.

**Interpretation:** Việc `order_id` lặp không được xem là duplicate. Nó phản ánh một đơn hàng có thể chứa nhiều dòng sản phẩm.

### 3.2. Order composition

Các đơn hàng có thể chứa nhiều `order_item_id` và nhiều sản phẩm khác nhau. `order_item_quantity` thể hiện số đơn vị bán trên một dòng sản phẩm; vì vậy quantity = 5 vẫn chỉ là một order item, không phải năm dòng dữ liệu.

**Implication:**  
- Số đơn hàng phải tính bằng `COUNT(DISTINCT order_id)`.
- Số dòng sản phẩm có thể tính bằng `COUNT(order_item_id)`.
- Số lượng bán có thể tính bằng `SUM(order_item_quantity)`.

### 3.3. Distribution of order lines

| Lines per order | Number of orders | Interpretation |
|---:|---:|---|
| 1 | 19,850 | Đơn có một dòng sản phẩm |
| 2 | 11,447 | Đơn có hai dòng sản phẩm |
| 3+ | 34,455 | Đơn có từ ba dòng sản phẩm trở lên |

Điều này cho thấy phần lớn đơn hàng là đơn nhiều dòng. Vì vậy,
các KPI cấp đơn không được tính trực tiếp bằng `COUNT(*)` trên
`stg_dataco`.

### 3.4. Order item key validation

| Check | Result |
|---|---:|
| Missing `order_item_id` | 0 |
| Duplicate `order_item_id` | 0 |
| Total rows | 180,519 |
| Distinct `order_item_id` | 180,519 |

**Conclusion:** `order_item_id` đủ điều kiện làm khóa duy nhất ở cấp dòng dữ liệu

### 3.5. Customer-to-order relationship

Có khách hàng xuất hiện trong nhiều `order_id` khác nhau.

**Conclusion:** Quan hệ dữ liệu là một khách hàng có thể tạo nhiều đơn hàng.

**Future analysis enabled:**

Dữ liệu cho phép phân tích:

- purchase frequency — tần suất mua trong khoảng dữ liệu;
- one-time và repeat customers;
- observed revenue per customer — doanh thu quan sát được trên mỗi khách hàng;
- customer revenue concentration;
- Recency, Frequency and Monetary segmentation, viết tắt là RFM,
  trong phạm vi thời gian của dataset.

Dữ liệu không đủ để tính Customer Lifetime Value thực sự vì không phản
ánh toàn bộ vòng đời của khách hàng trước và sau khoảng dữ liệu.

### 3.6. Consistency of order-level attributes

### 3.6. Consistency of order-level attributes

Không phát hiện `order_id` nào có nhiều giá trị khác nhau ở các
thuộc tính:

- `customer_id`;
- `order_date`;
- `order_status`;
- `customer_segment`;
- `market`;
- `order_region`;
- `shipping_mode`;
- `delivery_status`;
- `late_delivery_risk`;
- `order_country`.

**Conclusion:** Các trường trên được xác nhận là thuộc tính cấp đơn
và có thể lấy một giá trị đại diện khi xây dựng bảng hoặc view
order-level.
## 4. Reporting scope update

### 4.1. Why the reporting scope was reviewed

Trong lần kiểm tra delivery analytics, dữ liệu cho thấy các đơn có:

- `order_status = CANCELED`; hoặc
- `order_status = SUSPECTED_FRAUD`

đều có:

- `delivery_status = Shipping canceled`;
- `late_delivery_risk = 0`.

Nhóm này gồm 2,855 đơn hàng.

Điều này cho thấy Shipping canceled không được dataset đánh giá theo
cùng quy tắc giao trễ với các đơn không bị hủy.

### 4.2. Scope A — All recorded orders

Scope A bao gồm toàn bộ 65,752 đơn được ghi nhận trong dataset,
không phân biệt `order_status`.

Scope A được sử dụng cho:

- mô tả và profiling toàn bộ dữ liệu nguồn;
- reconciliation với dữ liệu nguồn;
- phân tích order status;
- phân tích canceled và suspected-fraud orders;
- sensitivity check giữa các reporting scope.

### 4.3. Scope B — Non-canceled orders

Scope B loại các đơn có:

- `order_status = CANCELED`;
- `order_status = SUSPECTED_FRAUD`.

Scope B còn lại 62,897 đơn và được sử dụng làm scope chính cho:

- sales và profit performance;
- monthly trend;
- category và product analysis;
- customer analysis;
- market và region analysis;
- delivery performance.

### 4.4. Important interpretation limitation

Scope B được gọi là `non-canceled orders`, không được gọi là
`completed orders`, `successful orders` hoặc `recognized revenue`.

Lý do là Scope B vẫn bao gồm các trạng thái như:

- `PENDING`;
- `PENDING_PAYMENT`;
- `PROCESSING`;
- `ON_HOLD`;
- `PAYMENT_REVIEW`.

Dataset cũng không cung cấp quy tắc kế toán để xác nhận recorded
net sales và recorded profit có phải doanh thu và lợi nhuận đã được
ghi nhận chính thức hay không.

### 4.5. Scope impact

So với Scope A, việc loại `CANCELED` và `SUSPECTED_FRAUD` làm:

- số đơn giảm `2,855`, tương ứng `4.34%`;
- recorded net sales giảm `1,409,737.29`, tương ứng `4.26%`;
- recorded profit giảm `160,482.34`, tương ứng `4.05%`;
- Profit Margin thay đổi nhẹ từ `12.00%` lên `12.03%`.

Do đó, các kết quả all-status trước đây không hoàn toàn sai, nhưng
chúng đại diện cho toàn bộ giao dịch được ghi nhận thay vì hiệu quả
của các đơn không bị hủy.


## 5. Final grain conclusion

The grain of `stg_dataco` is **order item**.

Each row represents one product line recorded within an order. `order_item_id` is the unique key at the row level. One `order_id` can contain multiple order items, and one `customer_id` can place multiple orders.

### Analytical implications

- Total source orders:
  `COUNT(DISTINCT order_id)` trên toàn bộ dữ liệu.

- Total non-canceled orders:
  `COUNT(DISTINCT order_id)` sau khi loại `CANCELED` và
  `SUSPECTED_FRAUD`.

- Total customers:
  `COUNT(DISTINCT customer_id)` trong đúng reporting scope.

- Total order items:
  `COUNT(order_item_id)`.

- Product quantity sold:
  `SUM(order_item_quantity)` trong đúng reporting scope.

- Order-level KPI, chẳng hạn Average Order Value và Late Delivery Rate,
  phải được tính từ bảng order-level để tránh nhân đôi đơn hàng.

- Mọi bảng được dùng để so sánh hoặc reconciliation phải áp dụng cùng
  một reporting scope.

- Customer summary phải được tạo lại theo từng scope vì việc loại đơn
  bị hủy có thể làm một repeat customer trở thành one-time customer.

**SQL reference:** `sql/01_profiling_and_grain.sql`