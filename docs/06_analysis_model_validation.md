# Kiểm chứng lớp phân tích và thiết kế mô hình

## 1. Bốn view SQL

| View | Phạm vi | Một dòng đại diện cho | Khóa | Mục đích |
|---|---|---|---|---|
| `vw_order_item_analysis` | A | Dòng sản phẩm | `order_item_id` | Đối soát nguồn và trạng thái |
| `vw_order_analysis` | A | Đơn hàng | `order_id` | Đối soát đơn và trạng thái |
| `vw_order_item_analysis_non_canceled` | B | Dòng sản phẩm | `order_item_id` | Sản phẩm, danh mục, giảm giá |
| `vw_order_analysis_non_canceled` | B | Đơn hàng | `order_id` | Khách, số đơn, AOV, giao hàng |

B chỉ loại `CANCELED` và `SUSPECTED_FRAUD`. View chuẩn hóa nhãn bằng `BTRIM` và `NULLIF`, tạo cột ngày/tháng/quý/năm và tỷ lệ dòng. Không xóa dữ liệu nguồn.

## 2. Kết quả đối soát đã thực hiện

| Kiểm tra | A | B |
|---|---:|---:|
| Dòng sản phẩm | 180,519 | 172,765 |
| Mã dòng sản phẩm duy nhất | 180,519 | 172,765 |
| Dòng đơn hàng | 65,752 | 62,897 |
| Mã đơn duy nhất | 65,752 | 62,897 |
| Số lượng bán | 384,079 | 367,591 |
| Doanh thu trước giảm giá | 36,784,734.31 | 35,214,428.98 |
| Tiền giảm giá | 3,730,378.40 | 3,569,808.32 |
| Doanh thu thuần | 33,054,402.04 | 31,644,664.75 |
| Lợi nhuận | 3,966,902.97 | 3,806,420.63 |

Trong từng phạm vi, tổng số lượng và các giá trị tài chính của bảng dòng khớp bảng đơn: chênh lệch bằng 0. Trạng thái bị loại còn trong B: 0. Không phát hiện mâu thuẫn thuộc tính cấp đơn.

Các kiểm tra tổng theo phân khúc, thị trường, khu vực và tổng hợp khách trong SQL 07 đều đối soát về mốc B. Số nhóm giao hàng cộng về 62,897 đơn. Xem [biên bản kiểm chứng](11_project_review_validation.md) để biết cách chạy và giới hạn.

## 3. Vì sao cần hai bảng dữ kiện?

Tổng hợp dữ liệu nguồn thành bảng đơn giúp tránh tính một đơn nhiều lần khi đánh giá giao hàng. Bảng dòng vẫn cần thiết vì một đơn có thể chứa nhiều sản phẩm/danh mục.

Thiết kế dành cho Power BI:

| Bảng | Cấp dữ liệu | Chỉ số phù hợp |
|---|---|---|
| `FactOrder` | Một dòng/đơn | Số đơn, khách, AOV, thời gian và tỷ lệ trễ |
| `FactOrderItem` | Một dòng sản phẩm | Sản phẩm, danh mục, số lượng, giảm giá, lợi nhuận dòng |
| Các bảng chiều | Một dòng/khóa chiều | Ngày, khách, địa lý, sản phẩm, vận chuyển |

Dùng bảng chiều chung để lọc hai bảng dữ kiện khi phù hợp, quan hệ một–nhiều và hướng lọc từ chiều sang dữ kiện. Tránh nối trực tiếp hai bảng dữ kiện rồi cộng lại doanh thu đơn.

Đây là **thiết kế cần tuân thủ**, chưa phải xác nhận đã kiểm tra từng quan hệ và công thức DAX trong PBIX. Lần rà soát này đọc được cấu trúc trang và sơ đồ bố trí bảng, chưa giải mã toàn bộ mô hình dữ liệu bên trong.

## 4. Tình huống bộ lọc phải kiểm tra

| Tình huống | Hành vi cần có |
|---|---|
| Bỏ mọi bộ lọc | Khớp mốc B |
| Chọn tháng và thị trường | Chỉ số doanh thu, đơn và trễ cùng tập đơn |
| Chọn danh mục/sản phẩm | Chỉ số dùng bảng dòng phải thay đổi đúng |
| Chọn khách/phân khúc | Nhóm mua lặp lại được tính theo quy ước đã ghi |
| Không có dữ liệu | Tỷ lệ trả trống, không giả thành 0% |
| Bấm biểu đồ để lọc chéo | Tử số và mẫu số cùng thay đổi |
| Đặt lại bộ lọc | Trở về mốc toàn kỳ |

**Điểm dễ sai:** chiều sản phẩm thường chỉ lọc `FactOrderItem`. Một thẻ đếm đơn từ `FactOrder` sẽ không tự phản ứng với bộ lọc sản phẩm nếu chỉ có quan hệ một chiều như thiết kế. Trên trang sản phẩm, dùng `DISTINCTCOUNT(FactOrderItem[order_id])` khi cần số đơn chứa sản phẩm được chọn. Nếu cần chỉ số giao hàng của các đơn chứa sản phẩm, phải thiết kế phép chuyển tập mã đơn và kiểm chứng riêng.

## 5. Cách chạy lại

1. Nạp staging theo [hướng dẫn dữ liệu](../data/README.md).
2. Chạy [SQL 04](../sql/04_cleaning_transformation.sql) để kiểm tra tính nhất quán.
3. Chạy [SQL 05](../sql/05_create_analysis_views.sql) để tạo view và đối soát.
4. Chạy [SQL 06](../sql/06_business_analysis_sales_product.sql), [SQL 07](../sql/07_business_analysis_customer_market_delivery.sql), [SQL 08](../sql/08_deeper_diagnostics.sql).
5. So sánh với kết quả trên rồi mới làm mới Power BI.

SQL và Python đã được chạy với dữ liệu tại workspace. Việc làm mới PBIX, thao tác bộ lọc và đối soát DAX vẫn cần kiểm tra trong Power BI Desktop.
