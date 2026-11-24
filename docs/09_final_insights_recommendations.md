# Kết luận phân tích và đề xuất hành động

## 1. Câu hỏi quản trị và kết luận chính

Project mô phỏng nhu cầu của quản lý Kinh doanh và Vận hành: **nên tập trung điều tra ở đâu để theo dõi doanh thu, lợi nhuận và chất lượng giao hàng?**

Ba kết luận có giá trị quản trị nhất:

1. **Giao hàng cần được kiểm tra ở quy mô toàn hệ thống.** Có 36,048/62,897 đơn trễ. Phân biệt vấn đề đáp ứng thời gian dự kiến của First Class với lượng đơn trễ lớn ở Standard Class.
2. **Doanh thu tập trung vào một nhóm sản phẩm nhỏ.** Mười trong 118 sản phẩm tạo 89.99% doanh thu; theo dõi nhóm này có ý nghĩa quy mô lớn hơn hai sản phẩm lỗ rất nhỏ.
3. **Khách có nhiều đơn tạo phần lớn doanh thu, nhưng chưa đủ để đề xuất đầu tư giữ chân đại trà.** Cần phân tích khách theo cùng thời gian quan sát và đo lần mua tiếp theo trước khi thử nghiệm.

Một vấn đề dữ liệu cần xử lý trước khi kể câu chuyện xu hướng là cấu trúc giỏ hàng thay đổi mạnh từ cuối 2017. Kết quả mô tả được điều xảy ra trong nguồn; chưa xác định nguyên nhân kinh doanh.

## 2. Mốc đối chiếu

Phạm vi **B** loại `CANCELED` và `SUSPECTED_FRAUD`, giai đoạn 01/01/2015–31/01/2018.

| Chỉ số | Kết quả |
|---|---:|
| Đơn | 62,897 |
| Khách | 20,261 |
| Số lượng bán | 367,591 |
| Doanh thu thuần | 31,644,664.75 |
| Lợi nhuận | 3,806,420.63 |
| Biên lợi nhuận | 12.03% |
| AOV | 503.12 |
| Đơn trễ / đủ điều kiện | 36,048 / 62,897 |
| Tỷ lệ trễ | 57.31% |

Tiền dùng đơn vị nguồn chưa xác minh. B vẫn có các trạng thái chưa hoàn tất, nên đây là giá trị giao dịch ghi trong dữ liệu, chưa phải doanh thu kế toán được xác nhận. Quy tắc làm tròn: từng dòng về hai chữ số trước khi cộng.

## 3. Giao hàng: cùng tỷ lệ trễ nhưng ưu tiên hành động khác nhau

**Bằng chứng:** First Class trễ 100% trên 9,602 đơn; thực tế trung bình 2 ngày so với dự kiến 1 ngày. Standard Class trễ 39.85% trên 37,632 đơn, tương ứng 14,995 đơn trễ — nhiều nhất và chiếm 41.60% tổng đơn trễ. Cả 23 khu vực có tỷ lệ trễ từ 50% trở lên.

**Diễn giải:** First Class đáng kiểm tra vì mức đáp ứng thời gian dự kiến bất thường. Standard Class đáng kiểm tra vì lượng đơn bị ảnh hưởng lớn. First Class thực tế nhanh hơn Standard Class, nên xếp hạng tỷ lệ trễ không phải xếp hạng tốc độ tuyệt đối.

**Đề xuất:** bộ phận Vận hành xác minh định nghĩa số ngày dự kiến và cờ trễ, rồi lập bảng khu vực × phương thức theo số đơn trễ, tỷ lệ trễ và doanh thu liên quan. Dùng Europe × First Class (2,753/2,753 đơn trễ) và Europe × Second Class (2,773/3,459) làm ví dụ đào sâu; đồng thời không bỏ qua Standard Class.

**Đo sau khi can thiệp:** tỷ lệ và số đơn trễ trong cùng nhóm dịch vụ, thời gian thực tế, mức trễ của các đơn thực sự trễ, chi phí giao hàng và phản hồi khách.

**Giới hạn:** chưa có dữ liệu nhà vận chuyển, kho, tuyến, sự kiện nhận hàng và chi phí. Doanh thu gắn với đơn trễ là giá trị liên quan, không phải khoản thất thoát. Chưa có căn cứ đổi toàn bộ chính sách vận chuyển.

## 4. Sản phẩm: phân biệt quy mô đóng góp và ngoại lệ nhỏ

**Bằng chứng:** 10/118 sản phẩm tạo 89.99% doanh thu. Tập này cũng là tập dẫn đầu theo lợi nhuận tuyệt đối. Hai sản phẩm lỗ là SOLE E35 (-965.12, 15 đơn) và SOLE E25 (-169.56, 10 đơn).

SOLE E35 tạo 26,409.85 doanh thu, chỉ khoảng 0.0835% doanh thu B; khoản lỗ bằng khoảng 0.0254% lợi nhuận toàn kỳ.

**Diễn giải:** tổng lợi nhuận dương có thể che sản phẩm bị lỗ, nhưng dấu âm chưa quyết định độ ưu tiên. Mức ảnh hưởng của ngoại lệ này rất nhỏ so với nhóm sản phẩm chủ lực.

**Đề xuất:** bộ phận Sản phẩm theo dõi định kỳ nhóm đóng góp lớn; kiểm tra riêng giá, giảm giá, chi phí và hoàn trả của 25 đơn thuộc hai sản phẩm lỗ. Chỉ đề xuất điều chỉnh giá hoặc danh mục khi đã biết cấu phần chi phí và nhu cầu.

**Đo theo dõi:** doanh thu, lợi nhuận, biên, số lượng, số đơn, tỷ trọng doanh thu; bổ sung tồn kho và thiếu hàng khi có nguồn.

**Giới hạn:** số quan sát của sản phẩm lỗ nhỏ. Tháng 09/2017 của SOLE E35 có giảm giá cao hơn và lỗ nhiều hơn tháng 10, chưa chứng minh giảm giá gây lỗ.

## 5. Danh mục: biên cao nhất chưa chắc là cơ hội lớn nhất

Fishing dẫn đầu doanh thu với 5,964,765.28, chiếm 18.85%, biên 12.26%. Golf Bags & Carts có biên cao nhất 19.25% nhưng chỉ 9,403.79 doanh thu trên 61 đơn.

**Đề xuất:** xem quy mô và biên cùng nhau. Bảo vệ nhóm đóng góp lớn; đánh giá nhu cầu và khả năng cung ứng của nhóm biên cao trước khi phân bổ thêm nguồn lực. Chưa có căn cứ chuyển ngân sách chỉ dựa trên thứ hạng biên.

## 6. Khách hàng: cần chuyển từ “mua nhiều” sang câu hỏi “có quay lại không?”

**Bằng chứng:** 11,644/20,261 khách có ít nhất hai đơn, chiếm 57.47% khách và 92.21% doanh thu. Doanh thu/khách nhóm này là 2,505.85 so với 286.25 của nhóm một đơn. Mười khách lớn nhất chỉ tạo 0.26% doanh thu; 10% khách lớn nhất tạo 29.08%.

**Diễn giải:** doanh thu đến từ một tập khách mua nhiều lần tương đối rộng. Số 92.21% một phần gắn với cách định nghĩa nhóm có nhiều giao dịch và thời gian họ được quan sát. Chưa phải kết quả đo giữ chân hay lòng trung thành.

**Đề xuất:** bộ phận quản lý khách hàng chia nhóm theo tháng đầu tiên quan sát, dùng cửa sổ theo dõi bằng nhau, tính tỷ lệ có đơn thứ hai trong khoảng thời gian định trước. Sau đó mới thiết kế thử nghiệm chăm sóc có nhóm đối chứng và chi phí cụ thể.

**Đo theo dõi:** tỷ lệ mua lần hai trong cửa sổ đủ điều kiện, thời gian đến đơn tiếp theo, lợi nhuận sau ưu đãi và chi phí liên hệ. Đây là kế hoạch mở rộng; project chưa thực hiện các phép đo này.

Consumer tạo 51.88% doanh thu với tỷ lệ trễ 57.25%, nên cần theo dõi cùng cả kinh doanh lẫn giao hàng. Chưa có phân tích chứng minh giao trễ khiến Consumer không quay lại.

## 7. Thời gian: tránh kể quá mức từ biến động doanh thu

Tháng 03/2015 tăng doanh thu 14.24% so với 02/2015. Phân rã số học cho thấy 91.89% mức tăng gắn với phần thay đổi số đơn khi giữ AOV kỳ trước. Nhưng tháng 03 có 31 ngày so với 28 ngày: doanh thu/ngày chỉ tăng 3.19%.

Cuối 2017, doanh thu và AOV giảm mạnh trong khi số đơn vẫn gần 2,000/tháng. Từ 11/2017, mỗi đơn chỉ có một dòng và một đơn vị trong nguồn.

**Đề xuất:** người phụ trách dữ liệu xác minh phạm vi trích xuất và cơ cấu sản phẩm trước khi diễn giải thành mất khách hay suy giảm nhu cầu. Tháng 01/2018 có dữ liệu đủ 31 ngày; độ đầy đủ nghiệp vụ chưa được xác nhận.

## 8. Thứ tự thực hiện đề xuất

Các vai trò dưới đây là đề xuất trong bối cảnh giả định, chưa phải phân công đã được doanh nghiệp nhận.

| Ưu tiên | Việc cụ thể | Vai trò đề xuất | Đầu ra để quyết định bước tiếp | Chỉ số cần giữ trong tầm theo dõi |
|---:|---|---|---|---|
| 1 | Xác minh nhãn và thời gian dự kiến; xem khu vực × phương thức | Vận hành, Vận chuyển, Dữ liệu | Bảng nhóm có số đơn, tỷ lệ, thời gian và sự kiện giải thích | Chi phí, tốc độ thực tế, khiếu nại |
| 2 | Kiểm tra thay đổi cấu trúc đơn từ 10/2017 | Dữ liệu, Kinh doanh | Xác nhận nguồn và cơ cấu theo tháng | Số đơn, dòng/đơn, số lượng/đơn, AOV |
| 3 | Theo dõi 10 sản phẩm chủ lực, xem riêng hai sản phẩm lỗ | Sản phẩm, Tài chính | Bảng đóng góp và hồ sơ chi phí của ngoại lệ | Biên, số lượng, tỷ trọng, tồn kho |
| 4 | Phân tích nhóm khách với cửa sổ quan sát bằng nhau | Quản lý khách hàng, Dữ liệu | Kết quả mua lần hai để thiết kế thử nghiệm | Lợi nhuận sau ưu đãi, chi phí |

Ưu tiên dựa trên quy mô tín hiệu và khả năng kiểm chứng, không dựa trên lợi ích tài chính dự báo chưa có bằng chứng.

## 9. Bằng chứng và giới hạn của lần rà soát

| Nội dung | Tài liệu/truy vấn |
|---|---|
| Hiểu cấp dữ liệu, phạm vi A/B | [Tài liệu 01](01_data_understanding.md), [tài liệu 02](02_data_quality_report.md) |
| Kiểm chứng tiền và định nghĩa KPI | [Tài liệu 03](03_financial_field_validation.md), [tài liệu 04](04_kpi_dictionary.md) |
| Thời gian, danh mục, sản phẩm | [Tài liệu 07](07_analysis_findings_part1.md), [SQL 06](../sql/06_business_analysis_sales_product.sql) |
| Khách, địa lý, giao hàng | [Tài liệu 08](08_analysis_findings_part2.md), [SQL 07](../sql/07_business_analysis_customer_market_delivery.sql) |
| Phân rã, quy mô lỗ, tổ hợp giao hàng | [SQL 08](../sql/08_deeper_diagnostics.sql) |
| Kiểm chứng đã thực hiện và phần còn lại | [Biên bản 11](11_project_review_validation.md) |
| Cách tự phân tích và thuyết trình | [Hướng dẫn 12](12_analysis_and_presentation_guide.md) |

SQL đã chạy trên bản dữ liệu trong workspace. Ảnh chụp và cấu trúc trang PBIX đã được đọc; chưa thao tác làm mới báo cáo, kiểm tra toàn bộ DAX hoặc mọi trạng thái bộ lọc. Không có giải pháp kinh doanh nào được triển khai hay đo tác động trong project.
