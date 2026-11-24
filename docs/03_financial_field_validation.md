# Kiểm chứng doanh thu, giảm giá và lợi nhuận

## 1. Vì sao cần kiểm chứng tên trường?

Tên `sales_per_customer` dễ khiến người đọc tưởng đó là tổng doanh thu khách. Tên `order_profit_per_order` dễ bị hiểu là lợi nhuận cả đơn. Trong dữ liệu này, cả hai đều ở **cấp dòng sản phẩm**. Nếu hiểu sai, các chỉ số sẽ bị đếm trùng hoặc tổng hợp sai.

Kiểm tra dùng toàn bộ 180,519 dòng A. Tiền được nhập vào staging bằng `NUMERIC(12,2)`; dung sai so sánh mỗi dòng là **0.01**. “Khớp” trong bảng dưới đây không có nghĩa số thực bằng nhau tuyệt đối.

## 2. Kết quả kiểm chứng ở staging

| Quan hệ kiểm tra | Dòng khớp | Tỷ lệ | Diễn giải |
|---|---:|---:|---|
| `sales_amount ≈ order_item_product_price × order_item_quantity` | 180,519 | 100% | Doanh thu trước giảm giá của dòng |
| `order_item_discount ≈ sales_amount × order_item_discount_rate` | 170,490 | 94.44% | Tỷ lệ lưu sẵn bị làm tròn; không dùng để dựng lại số tiền |
| `order_item_total ≈ sales_amount − order_item_discount` | 180,519 | 100% | Doanh thu thuần của dòng |
| `sales_per_customer ≈ order_item_total` | 180,519 | 100% | Hai trường biểu diễn cùng giá trị dòng |
| `benefit_per_order ≈ order_profit_per_order` | 180,519 | 100% | Không cộng đồng thời hai trường lợi nhuận |
| Lợi nhuận khác nhau giữa các dòng trong cùng đơn | Có | — | Phải cộng lợi nhuận các dòng để ra lợi nhuận đơn |

`order_item_profit_ratio` gần với lợi nhuận dòng chia doanh thu thuần dòng theo dung sai kiểm tra trong [SQL 03](../sql/03_financial_validation.sql). Không suy ra chi phí nào đã được tính chỉ từ tỷ lệ này.

## 3. Quy tắc làm tròn ảnh hưởng kết quả thế nào?

CSV có số thập phân dài. Project **làm tròn từng giá trị tiền về 2 chữ số trước khi cộng**, tương ứng kiểu staging. [Chương trình kiểm chứng](../scripts/verify_analysis.py) dùng `Decimal` với `ROUND_HALF_UP`.

| Cách tính | Doanh thu thuần A |
|---|---:|
| Cộng các giá trị CSV chưa làm tròn, rồi làm tròn tổng | 33,054,402.38 |
| Làm tròn từng dòng, rồi cộng — quy tắc project | 33,054,402.04 |

Trên CSV chưa làm tròn, phép so sánh doanh thu thuần với doanh thu trước giảm giá trừ giảm giá chỉ khớp 179,295 dòng theo dung sai 0.01. Sau nhập staging, khớp cả 180,519 dòng.

**Chênh lệch tích lũy:** ở B, tổng doanh thu trước giảm giá trừ tổng giảm giá là 31,644,620.66, trong khi tổng `order_item_total` là 31,644,664.75, chênh 44.09. Các sai lệch nhỏ từng dòng có thể cộng dồn. Vì vậy:

- Doanh thu thuần chính lấy từ tổng `order_item_total`.
- Không thay trường nguồn bằng số tính lại rồi vẫn kỳ vọng cùng số đối soát.
- Khi đối soát bảng dòng sản phẩm với bảng đơn, cả hai phải cộng từ cùng trường đã chuẩn hóa nên chênh lệch phải bằng 0.

## 4. Định nghĩa tài chính được sử dụng

| Chỉ số | Công thức trên bảng dòng sản phẩm | Tên dễ hiểu |
|---|---|---|
| Gross Sales | `SUM(gross_sales)` | Doanh thu trước giảm giá |
| Total Discount | `SUM(discount_amount)` | Tổng tiền giảm giá |
| Net Sales | `SUM(net_sales)` | Doanh thu thuần ghi trong nguồn |
| Total Profit | `SUM(line_profit)` | Lợi nhuận ghi trong nguồn |
| Profit Margin | `SUM(line_profit) / NULLIF(SUM(net_sales),0)` | Biên lợi nhuận có trọng số |
| Discount Rate | `SUM(discount_amount) / NULLIF(SUM(gross_sales),0)` | Tỷ lệ giảm giá có trọng số |

Không lấy trung bình các tỷ lệ dòng để tính biên chung. Ví dụ minh họa: dòng bán 100 lãi 10 và dòng bán 900 lãi 180 có biên chung 190/1,000 = 19%; trung bình 10% và 20% thành 15% sẽ làm sai trọng số.

Lợi nhuận âm được giữ lại. Chưa có bảng giá vốn, hoàn trả hay phí vận hành chi tiết để giải thích chắc chắn tại sao một dòng bị lỗ.

## 5. Độ nhạy theo phạm vi báo cáo

| Chỉ số | A: toàn bộ nguồn | B: loại hủy/nghi gian lận | B − A |
|---|---:|---:|---:|
| Đơn hàng | 65,752 | 62,897 | -2,855 |
| Doanh thu thuần | 33,054,402.04 | 31,644,664.75 | -1,409,737.29 |
| Lợi nhuận | 3,966,902.97 | 3,806,420.63 | -160,482.34 |
| Biên lợi nhuận | 12.00% | 12.03% | +0.03 điểm phần trăm |

Nhóm bị loại chiếm 4.34% số đơn, 4.26% doanh thu và 4.05% lợi nhuận A. Biên tổng thay đổi ít nhưng thứ hạng chi tiết vẫn cần tính lại theo B.

## 6. Giới hạn diễn giải

Đơn vị tiền tệ chưa xác minh, do đó không gắn USD hay ký hiệu $. Doanh thu và lợi nhuận là giá trị trong dữ liệu phục vụ phân tích, chưa có bằng chứng về ghi nhận kế toán hay tác động tài chính thực tế của một giải pháp.

Xem [từ điển chỉ số](04_kpi_dictionary.md) và [biên bản kiểm chứng](11_project_review_validation.md).
