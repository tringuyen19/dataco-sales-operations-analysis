# Data Understanding

## 1. Dataset overview

### Evidence

| Metric | Result |
|---|---:|
| Total rows | 180519 |
| Distinct orders | 65752 |
| Distinct order items | 180519 |
| Distinct customers | 20652 |
| Distinct products | 118 |

### Interpretation

Bảng có 180,519 dòng và cũng có 180,519 `order_item_id` khác nhau, trong khi chỉ có 65,765 `order_id` khác nhau. Điều này cho thấy một đơn hàng có thể xuất hiện ở nhiều dòng; mỗi dòng có khả năng là một order item.

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
| 1 | 19850 | Đơn một dòng sản phẩm |
| 2 | 11447 | Đơn gồm hai dòng sản phẩm |
| 3+ | ~ 34000 | Đơn gồm nhiều dòng sản phẩm |

Phần lớn đơn hàng là [một dòng/nhiều dòng]. Tuy nhiên, do tồn tại đơn nhiều dòng, các KPI cấp đơn không được tính trực tiếp bằng `COUNT(*)`.

### 3.4. Order item key validation

| Check | Result |
|---|---:|
| Missing `order_item_id` | 0 |
| Duplicate `order_item_id` | 0 |
| Total rows | 180519 |
| Distinct `order_item_id` | 180519 |

### 3.5. Customer-to-order relationship

Có khách hàng xuất hiện trong nhiều `order_id` khác nhau.

**Conclusion:** Quan hệ dữ liệu là một khách hàng có thể tạo nhiều đơn hàng.

**Future analysis enabled:** Có thể tính purchase frequency, returning customers, customer lifetime value và RFM segmentation.

**Conclusion:** `order_item_id` đủ điều kiện làm khóa duy nhất ở cấp dòng dữ liệu

### 3.6. Consistency of order-level attributes

Không phát hiện `order_id` nào có nhiều giá trị khác nhau ở các thuộc tính: `customer_id`, `order_date`, `order_status`, `shipping_mode` và `order_country`.

**Conclusion:** Các trường trên được xác nhận là thuộc tính cấp đơn hàng và có thể lấy một giá trị đại diện khi tạo bảng order-level.

## 4. Final grain conclusion

The grain of `stg_dataco` is **order item**.

Each row represents one product line recorded within an order. `order_item_id` is the unique key at the row level. One `order_id` can contain multiple order items, and one `customer_id` can place multiple orders.

### Analytical implications

- Total orders: `COUNT(DISTINCT order_id)`
- Total customers: `COUNT(DISTINCT customer_id)`
- Total order items: `COUNT(order_item_id)`
- Product quantity sold: `SUM(order_item_quantity)`
- Order-level KPIs, such as late delivery rate, must be calculated from an order-level table to avoid double counting.

**SQL reference:** `sql/01_profiling_and_grain.sql`

