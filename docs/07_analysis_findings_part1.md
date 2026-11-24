# Kết quả phân tích doanh thu và sản phẩm

## 1. Phạm vi và bằng chứng

Tất cả kết quả dưới đây dùng **B**, giai đoạn 01/01/2015–31/01/2018. Tiền được làm tròn từng dòng về hai chữ số trước khi cộng. SQL và phép kiểm chứng Python đã được chạy trong lần rà soát này; không còn dùng các số A làm số B.

Nguồn: [SQL 06](../sql/06_business_analysis_sales_product.sql), [SQL chẩn đoán 08](../sql/08_deeper_diagnostics.sql), [biên bản kiểm chứng](11_project_review_validation.md).

## 2. Mốc kinh doanh toàn kỳ

| Chỉ số | Kết quả |
|---|---:|
| Đơn | 62,897 |
| Khách | 20,261 |
| Dòng sản phẩm | 172,765 |
| Số lượng bán | 367,591 |
| Doanh thu trước giảm giá | 35,214,428.98 |
| Tiền giảm giá | 3,569,808.32 |
| Doanh thu thuần | 31,644,664.75 |
| Lợi nhuận | 3,806,420.63 |
| Biên lợi nhuận | 12.03% |
| AOV | 503.12 |

Doanh thu và lợi nhuận dương cho biết quy mô tổng thể. Chúng chưa trả lời sản phẩm nào có vấn đề hoặc dịch vụ giao hàng có đáp ứng thời gian dự kiến hay không.

## 3. Doanh thu tháng 03/2015 tăng chủ yếu cùng số đơn, nhưng cần đọc theo số ngày

| Chỉ số | 02/2015 | 03/2015 | Thay đổi |
|---|---:|---:|---:|
| Doanh thu thuần | 792,251.44 | 905,104.93 | +14.24% |
| Số đơn | 1,505 | 1,702 | +197 |
| Số lượng bán | 9,912 | 11,526 | +1,614 |
| AOV | 526.41 | 531.79 | +1.02% |
| Lợi nhuận | 93,009.96 | 107,401.92 | Tăng |
| Biên lợi nhuận | 11.74% | 11.87% | Tăng nhẹ |
| Số ngày có dữ liệu | 28 | 31 | +3 ngày |

Đẳng thức doanh thu = số đơn × AOV cho phép phân rã mức tăng 112,853.49:

- Phần gắn với thay đổi số đơn, giữ AOV kỳ trước: **103,703.34**, tương đương 91.89% mức tăng.
- Phần gắn với thay đổi AOV, dùng số đơn kỳ hiện tại: **9,150.15**.

Đây là phân rã số học theo kỳ gốc. Không phải kết luận số đơn hay một chiến dịch đã “gây ra” tăng trưởng.

**Điểm cần kiểm tra trước khi kể câu chuyện tăng trưởng:** tháng 03 dài hơn tháng 02. Sau chia theo số ngày có dữ liệu, doanh thu/ngày chỉ tăng **3.19%**, số đơn/ngày tăng **2.15%**. Vì vậy, không nên dùng riêng mức tăng 14.24% để khẳng định nhu cầu tăng mạnh. Chưa có lịch ngày làm việc, khuyến mãi và bằng chứng mùa vụ.

## 4. Cuối 2017 có thay đổi cấu trúc giỏ hàng cần điều tra

| Tháng | Đơn | Dòng sản phẩm | Số lượng bán | Doanh thu thuần | AOV |
|---|---:|---:|---:|---:|---:|
| 09/2017 | 1,640 | 4,931 | 9,934 | 976,907.91 | 595.68 |
| 10/2017 | 2,019 | 2,169 | 2,404 | 926,038.01 | 458.66 |
| 11/2017 | 1,956 | 1,956 | 1,956 | 538,206.29 | 275.16 |
| 12/2017 | 2,031 | 2,031 | 2,031 | 432,004.27 | 212.71 |
| 01/2018 | 2,037 | 2,037 | 2,037 | 284,672.01 | 139.75 |

09/2017 có doanh thu cao nhất; 01/2018 thấp nhất trong B. Tuy nhiên, số đơn cuối kỳ không giảm tương ứng. Từ 11/2017, mỗi đơn trong nguồn chỉ có một dòng và một đơn vị sản phẩm. AOV giảm rõ rệt.

**Ý nghĩa:** cần kiểm tra sự thay đổi danh mục, giá trị sản phẩm và phạm vi trích xuất trước khi quy doanh thu giảm cho việc mất khách. Dữ liệu quan sát cho thấy thay đổi cơ cấu đơn; chưa xác định đó là thay đổi kinh doanh thật hay đặc điểm bộ dữ liệu.

01/2018 có giao dịch từ ngày 1 đến 31 và đủ 31 ngày quan sát. Điều này sửa nhận định quá đơn giản rằng “tháng cuối chắc chắn chưa đủ tháng”, nhưng chưa xác nhận dữ liệu đầy đủ về mặt nghiệp vụ.

## 5. Quy mô danh mục và biên lợi nhuận là hai góc nhìn khác nhau

| Danh mục | Doanh thu thuần | Lợi nhuận | Biên | Số đơn chứa danh mục |
|---|---:|---:|---:|---:|
| Fishing | 5,964,765.28 | 731,576.18 | 12.26% | 14,527 |
| Golf Bags & Carts | 9,403.79 | 1,810.07 | 19.25% | 61 |

Fishing tạo 18.85% tổng doanh thu và dẫn đầu về quy mô. Golf Bags & Carts có biên cao nhất nhưng doanh thu chỉ khoảng 0.03% tổng số, trên 61 đơn.

**Ý nghĩa:** không lấy danh mục có tỷ lệ cao nhất làm ưu tiên mở rộng ngay. Cần kết hợp doanh thu, lợi nhuận tuyệt đối, số đơn và khả năng tăng quy mô. Tồn kho, nhu cầu và năng lực cung ứng chưa có trong project.

## 6. Mười sản phẩm tạo gần 90% doanh thu

Trong 118 sản phẩm, 10 sản phẩm dẫn đầu tạo **89.99% doanh thu thuần**; 108 sản phẩm còn lại tạo 10.01%. Tập 10 sản phẩm dẫn đầu theo doanh thu trùng với tập dẫn đầu theo lợi nhuận tuyệt đối, không có nghĩa thứ hạng hai bảng giống nhau.

Sản phẩm đứng đầu doanh thu là `Field & Stream Sportsman 16 Gun Fire Safe`.

**Ý nghĩa:** một thay đổi nhỏ ở nhóm đóng góp lớn có thể đáng quan tâm hơn một tỷ lệ bất thường ở sản phẩm rất nhỏ. Ưu tiên theo dõi doanh thu, lợi nhuận, biên và tồn kho của nhóm này; chưa có dữ liệu tồn kho để kết luận đã xảy ra thiếu hàng.

## 7. Hai sản phẩm bị lỗ, quy mô ảnh hưởng nhỏ

| Sản phẩm | Đơn/dòng | Doanh thu thuần | Lợi nhuận | Biên |
|---|---:|---:|---:|---:|
| SOLE E35 Elliptical | 15 | 26,409.85 | -965.12 | -3.65% |
| SOLE E25 Elliptical | 10 | 9,414.90 | -169.56 | -1.80% |

SOLE E35 chỉ chiếm khoảng **0.0835% doanh thu B**; khoản lỗ tương đương khoảng **0.0254% lợi nhuận toàn kỳ**. Đây là một ngoại lệ để học cách đào sâu, có độ ưu tiên tài chính thấp hơn việc theo dõi 10 sản phẩm chủ lực.

| SOLE E35 theo tháng | Đơn | Doanh thu | Lợi nhuận | Tỷ lệ giảm giá |
|---|---:|---:|---:|---:|
| 09/2017 | 6 | 9,779.94 | -724.47 | 18.50% |
| 10/2017 | 9 | 16,629.91 | -240.65 | 7.61% |

Tháng giảm giá nhiều hơn cũng lỗ nhiều hơn, nhưng chỉ có 15 đơn thuộc hai tháng. Chi phí, hoàn trả và điều kiện bán chưa đủ để kết luận giảm giá gây lỗ hoặc nên ngừng bán sản phẩm.

## 8. Hành động phân tích tiếp theo

1. Kiểm tra cơ cấu sản phẩm và phạm vi nguồn từ 10/2017.
2. Theo dõi định kỳ 10 sản phẩm chủ lực bằng cả quy mô và biên.
3. Kiểm tra 25 đơn thuộc hai sản phẩm lỗ, bổ sung chi phí và hoàn trả.
4. Với phân tích tháng, đọc cả tổng kỳ và bình quân/ngày trước khi kể câu chuyện tăng trưởng.

Kết luận quản trị và người phụ trách đề xuất nằm tại [tài liệu 09](09_final_insights_recommendations.md).
