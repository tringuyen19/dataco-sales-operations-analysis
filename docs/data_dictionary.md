# Từ điển dữ liệu DataCo

## 1. Cách sử dụng

Tài liệu giải thích **53 trường staging** theo nhóm nghiệp vụ. Tên cột giữ nguyên dạng kỹ thuật để đối chiếu SQL. Kiểu dữ liệu là kiểu thực sự khai báo trong [SQL 00](../sql/00_create_staging.sql), không phải cam kết về ý nghĩa nghiệp vụ.

Bảng staging chưa đặt ràng buộc NOT NULL/UNIQUE để có thể phát hiện lỗi nguồn. Các quy tắc dưới đây là điều kiện kiểm tra hoặc cách sử dụng, không mặc nhiên là ràng buộc đã triển khai.

Trường tiền dùng `NUMERIC(12,2)`: làm tròn từng giá trị khi nhập. Trường chữ dùng `TEXT`; các mã bưu chính cũng là chữ để bảo toàn số 0 đầu. Nguồn mô tả biến là `DescriptionDataCoSupplyChain.csv`; một số tên tài chính đã được diễn giải lại sau kiểm chứng thực tế.

## 2. Thanh toán và vận chuyển — 7 trường

| Trường | Kiểu staging | Ý nghĩa và quy tắc sử dụng |
|---|---|---|
| `order_type` | TEXT | Loại giao dịch/phương thức thanh toán; tên gốc Type, ví dụ DEBIT |
| `days_for_shipping_real` | INTEGER | Số ngày vận chuyển thực tế được nguồn ghi nhận; không đủ để xác minh khách đã nhận hàng |
| `days_for_shipment_scheduled` | INTEGER | Số ngày vận chuyển dự kiến theo nguồn; dùng để so với số ngày thực tế |
| `delivery_status` | TEXT | Nhãn Advance shipping, Late delivery, Shipping canceled hoặc Shipping on time |
| `late_delivery_risk` | INTEGER | Cờ 0/1; 1 là trễ theo nguồn. Nhóm giao hàng bị hủy cũng có cờ 0 nên cần lọc phạm vi |
| `shipping_date` | TIMESTAMP | Ngày giờ vận chuyển; tên gốc shipping date (DateOrders). Không tự gọi là ngày nhận hàng |
| `shipping_mode` | TEXT | Phương thức dịch vụ: First Class, Second Class, Same Day, Standard Class; giữ nhãn để đối chiếu |

## 3. Doanh thu, giảm giá và lợi nhuận — 10 trường

| Trường | Kiểu staging | Ý nghĩa và quy tắc sử dụng |
|---|---|---|
| `benefit_per_order` | NUMERIC(12,2) | Lợi nhuận dòng, khớp trường lợi nhuận bên dưới theo kiểm chứng; không cộng hai trường |
| `sales_per_customer` | NUMERIC(12,2) | Khớp doanh thu thuần của dòng; không phải doanh thu tổng của khách |
| `order_item_discount` | NUMERIC(12,2) | Số tiền giảm giá thực tế của dòng; dùng để tính tổng giảm giá |
| `order_item_discount_rate` | NUMERIC(6,4) | Tỷ lệ giảm giá nguồn đã làm tròn; kỳ vọng trong [0,1], không dùng dựng lại chính xác tiền giảm |
| `order_item_product_price` | NUMERIC(12,2) | Đơn giá sản phẩm trên dòng giao dịch; kỳ vọng không âm |
| `order_item_profit_ratio` | NUMERIC(8,4) | Tỷ lệ lợi nhuận của dòng theo nguồn; có thể âm, không dùng AVG để tính biên tổng |
| `order_item_quantity` | INTEGER | Số đơn vị sản phẩm trong dòng; phải lớn hơn 0 để tính số lượng bán |
| `sales_amount` | NUMERIC(12,2) | Doanh thu trước giảm giá của dòng; tên gốc Sales |
| `order_item_total` | NUMERIC(12,2) | Doanh thu thuần của dòng theo nguồn; chỉ số doanh thu chính |
| `order_profit_per_order` | NUMERIC(12,2) | Lợi nhuận dòng dù tên có “per order”; cộng các dòng để ra lợi nhuận đơn. Chưa có chi tiết cấu phần chi phí |

Các quan hệ công thức được kiểm tra với dung sai từng dòng 0.01. Tổng doanh thu trước giảm giá trừ tổng giảm giá có thể lệch tổng doanh thu thuần do sai lệch nhỏ tích lũy. Xem [kiểm chứng tài chính](03_financial_field_validation.md).

## 4. Danh mục và bộ phận — 4 trường

| Trường | Kiểu staging | Ý nghĩa và quy tắc sử dụng |
|---|---|---|
| `category_id` | INTEGER | Mã danh mục trên giao dịch |
| `category_name` | TEXT | Tên danh mục; bỏ khoảng trắng ngoài trước khi tổng hợp |
| `department_id` | INTEGER | Mã bộ phận/nhóm kinh doanh của nguồn |
| `department_name` | TEXT | Tên bộ phận/nhóm kinh doanh |

## 5. Khách hàng và vị trí tham khảo — 13 trường

| Trường | Kiểu staging | Ý nghĩa và quy tắc sử dụng |
|---|---|---|
| `customer_id` | INTEGER | Mã khách; có thể có nhiều đơn |
| `customer_first_name` | TEXT | Tên khách theo nguồn; không dùng thay khóa khách |
| `customer_last_name` | TEXT | Họ khách; thiếu 8 dòng trong tệp hiện có |
| `customer_email` | TEXT | Email được che trong dữ liệu chia sẻ; không dùng trong phân tích |
| `customer_password` | TEXT | Trường mật khẩu đã che; không dùng trong phân tích |
| `customer_segment` | TEXT | Phân khúc nguồn: Consumer, Corporate, Home Office |
| `customer_city` | TEXT | Thành phố gắn với thông tin khách trong nguồn; chưa mặc định là đích giao đơn |
| `customer_country` | TEXT | Quốc gia gắn với thông tin khách; phân biệt với order_country |
| `customer_state` | TEXT | Bang/tỉnh gắn với thông tin khách |
| `customer_street` | TEXT | Địa chỉ đường/phố khách; không cần cho kết luận hiện tại |
| `customer_zipcode` | TEXT | Mã bưu chính khách; thiếu 3 dòng, giữ dạng chữ |
| `latitude` | NUMERIC(10,7) | Vĩ độ trong nguồn, kỳ vọng [-90,90]; cần xác minh đối tượng vị trí trước khi lập bản đồ |
| `longitude` | NUMERIC(10,7) | Kinh độ trong nguồn, kỳ vọng [-180,180]; chưa dùng để suy ra tuyến vận chuyển |

Mô tả nguồn gọi tọa độ là vị trí cửa hàng; project chưa xác minh với dữ liệu địa lý độc lập. Không tự diễn giải chúng thành tọa độ nhận hàng hoặc dùng tính khoảng cách giao hàng.

## 6. Thị trường và đơn hàng — 11 trường

| Trường | Kiểu staging | Ý nghĩa và quy tắc sử dụng |
|---|---|---|
| `market` | TEXT | Thị trường giao hàng cấp lớn: Africa, Europe, LATAM, Pacific Asia, USCA |
| `order_id` | INTEGER | Mã đơn, lặp hợp lệ ở staging do có nhiều dòng sản phẩm |
| `order_customer_id` | INTEGER | Mã khách trên đơn; kiểm tra bằng customer_id |
| `order_date` | TIMESTAMP | Ngày giờ đặt; tên gốc order date (DateOrders); CSV hiện có dùng tháng/ngày/năm |
| `order_status` | TEXT | Trạng thái xử lý/thanh toán; B loại CANCELED và SUSPECTED_FRAUD |
| `order_city` | TEXT | Thành phố đích đơn hàng theo nguồn |
| `order_country` | TEXT | Quốc gia đích; dùng cho phân tích giao hàng |
| `order_region` | TEXT | Khu vực đích; có 23 giá trị trong phân tích B |
| `order_state` | TEXT | Bang/tỉnh ở đích đơn hàng |
| `order_zipcode` | TEXT | Mã bưu chính đơn; thiếu 155,679 dòng, chưa dùng cho phân tích địa lý |
| `order_item_id` | INTEGER | Khóa dòng sản phẩm: không thiếu, không trùng trong dữ liệu hiện có |

`order_item_id` được đặt ở nhóm này để đủ cấu trúc bảng tóm tắt; cấp dữ liệu của trường vẫn là dòng sản phẩm, không phải đơn.

## 7. Sản phẩm — 8 trường

| Trường | Kiểu staging | Ý nghĩa và quy tắc sử dụng |
|---|---|---|
| `order_item_cardprod_id` | INTEGER | Mã sản phẩm trên dòng; kiểm tra bằng product_card_id |
| `product_card_id` | INTEGER | Mã sản phẩm dùng để nhóm và đối chiếu |
| `product_category_id` | INTEGER | Mã danh mục trong thông tin sản phẩm; kiểm tra bằng category_id |
| `product_name` | TEXT | Tên sản phẩm; dùng mã cùng tên khi tổng hợp, bỏ khoảng trắng ngoài |
| `product_description` | TEXT | Mô tả sản phẩm; thiếu toàn bộ 180,519 dòng trong tệp hiện có |
| `product_image` | TEXT | Đường dẫn hình ảnh; chưa sử dụng hoặc xác minh tính hoạt động |
| `product_price` | NUMERIC(12,2) | Giá trong thông tin sản phẩm; phân biệt với đơn giá dòng giao dịch |
| `product_status` | INTEGER | Mã trạng thái sản phẩm. Mô tả nguồn: 1 không có sẵn, 0 có sẵn; không thay thế lịch sử tồn kho |

Tổng số trường: 7 + 10 + 4 + 13 + 11 + 8 = **53**.

## 8. Ánh xạ sang bảng dòng sản phẩm phân tích

`vw_order_item_analysis` giữ toàn bộ phạm vi A, một dòng/`order_item_id`.

| Nguồn staging | Trường phân tích | Ý nghĩa |
|---|---|---|
| order_item_id, order_id, customer_id, product_card_id | Giữ tên | Khóa dòng, đơn, khách, sản phẩm |
| order_date | order_datetime | Thời điểm đặt |
| order_date | order_date | Chuyển sang DATE |
| order_date | order_month, order_quarter, order_year | Tháng, quý và năm |
| category_name, product_name | Giữ tên | Nhãn đã BTRIM và chuyển chuỗi rỗng thành NULL |
| customer_segment, market, order_region, order_country | Giữ tên | Thuộc tính khách/địa lý đã chuẩn hóa chữ |
| shipping_mode, order_status, delivery_status | Giữ tên | Nhãn nghiệp vụ đã chuẩn hóa chữ |
| late_delivery_risk | Giữ tên | Cờ trễ |
| days_for_shipping_real | actual_shipping_days | Ngày thực tế |
| days_for_shipment_scheduled | scheduled_shipping_days | Ngày dự kiến |
| order_item_quantity | quantity | Số lượng bán |
| sales_amount | gross_sales | Doanh thu trước giảm giá |
| order_item_discount | discount_amount | Tiền giảm giá |
| order_item_total | net_sales | Doanh thu thuần |
| order_profit_per_order | line_profit | Lợi nhuận dòng |

Cột tính thêm:

- `actual_discount_rate = discount_amount / NULLIF(gross_sales,0)`.
- `line_profit_margin = line_profit / NULLIF(net_sales,0)`.
- Tháng/quý tạo bằng `DATE_TRUNC`, năm bằng `EXTRACT`.

## 9. Ánh xạ sang bảng đơn

`vw_order_analysis` tổng hợp A thành một dòng/`order_id`.

| Nhóm trường | Cách tạo |
|---|---|
| Khách, ngày, phân khúc, địa lý, phương thức, trạng thái và ngày vận chuyển | Lấy MIN sau khi xác nhận nhất quán trong cùng đơn |
| order_line_count | COUNT(*) dòng sản phẩm |
| distinct_product_count | COUNT(DISTINCT product_card_id) |
| total_quantity | SUM(quantity) |
| gross_sales, discount_amount, net_sales | Cộng từng trường tương ứng của các dòng |
| order_profit | SUM(line_profit) |
| order_profit_margin | SUM(line_profit) / NULLIF(SUM(net_sales),0) |

Hai view B kế thừa cột từ view A tương ứng và thêm điều kiện:

```sql
WHERE order_status IS DISTINCT FROM 'CANCELED'
  AND order_status IS DISTINCT FROM 'SUSPECTED_FRAUD'
```

`IS DISTINCT FROM` không âm thầm loại trạng thái NULL. Nếu có NULL trong dữ liệu mới, vẫn cần kiểm tra và xử lý riêng; hiện nguồn không thiếu trạng thái trọng yếu.

## 10. Chọn nguồn tính chỉ số

| Câu hỏi | Nguồn mặc định |
|---|---|
| Sản phẩm, danh mục, số lượng, giảm giá, lợi nhuận dòng | vw_order_item_analysis_non_canceled |
| Đơn, khách, AOV, thị trường/khu vực, giao hàng | vw_order_analysis_non_canceled |
| Mua một lần/lặp lại, mức tập trung theo khách | Tổng hợp một dòng/khách từ bảng đơn B |
| Đối soát và phân tích trạng thái/hủy | Hai view A |

[Từ điển chỉ số](04_kpi_dictionary.md) quy định công thức và mẫu số. [Kiểm chứng mô hình](06_analysis_model_validation.md) giải thích đối soát giữa các cấp. Không dùng tên cột để suy ra cấp dữ liệu khi chưa kiểm tra.
