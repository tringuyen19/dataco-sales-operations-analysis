# Kết quả phân tích khách hàng, thị trường và giao hàng

## 1. Phạm vi và nguồn

Dùng phạm vi B: 62,897 đơn, 20,261 khách, doanh thu thuần 31,644,664.75 và lợi nhuận 3,806,420.63. Thời gian: 01/01/2015–31/01/2018.

Nguồn: [SQL 07](../sql/07_business_analysis_customer_market_delivery.sql), [SQL 08](../sql/08_deeper_diagnostics.sql), [kiểm chứng độc lập](../scripts/verify_analysis.py).

## 2. Consumer đóng góp hơn nửa doanh thu

| Phân khúc nguồn | Đơn | Doanh thu thuần | Lợi nhuận | Biên | Tỷ lệ trễ |
|---|---:|---:|---:|---:|---:|
| Consumer | 32,614 | 16,417,549.44 | 1,982,863.62 | 12.08% | 57.25% |
| Corporate | 19,017 | 9,621,051.58 | 1,157,821.04 | 12.03% | 57.16% |
| Home Office | 11,266 | 5,606,063.73 | 665,735.97 | 11.88% | 57.74% |

Consumer tạo 51.88% doanh thu. Đây là nhóm lớn cần được theo dõi, nhưng biên và tỷ lệ trễ khá gần các nhóm khác. Chưa có bằng chứng rằng phân khúc là nguyên nhân khác biệt về vận hành.

## 3. Khách mua lặp lại đóng góp lớn, nhưng chưa đo được giữ chân khách

| Chỉ số | Mua một lần | Mua lặp lại |
|---|---:|---:|
| Khách | 8,617 | 11,644 |
| Tỷ trọng khách | 42.53% | 57.47% |
| Tỷ trọng doanh thu | 7.79% | 92.21% |
| Doanh thu/khách | 286.25 | 2,505.85 |

Doanh thu/khách của nhóm mua lặp lại cao khoảng 8.75 lần nếu làm tròn tỷ số về hai chữ số. Đây là một mô tả có ích về nguồn doanh thu.

**Giới hạn quan trọng:** nhóm mua lặp lại được định nghĩa bằng số đơn, nên việc có doanh thu cộng dồn lớn hơn một phần xuất phát ngay từ định nghĩa. Khách xuất hiện sớm có nhiều thời gian mua lại hơn khách mới xuất hiện cuối kỳ. Số 92.21% chưa chứng minh chương trình giữ chân hiệu quả, khách trung thành hay lợi tức đầu tư CRM.

Bước tiếp theo là chia khách theo tháng đầu tiên quan sát, cho mỗi nhóm cùng thời gian theo dõi và tính lần mua thứ hai. Không gọi lần xuất hiện đầu tiên trong dữ liệu là lần mua đầu tiên trong đời khách.

## 4. Tập trung doanh thu theo khách khác với theo sản phẩm

| Nhóm | Quy mô nhóm | Tỷ trọng doanh thu |
|---|---:|---:|
| 10 khách đứng đầu | 10 khách | 0.26% |
| 10% khách đứng đầu | 2,027 khách | 29.08% |
| 10 sản phẩm đứng đầu | 10/118 sản phẩm | 89.99% |

Kết quả cho thấy sự tập trung theo sản phẩm lớn hơn nhiều so với sự phụ thuộc vào vài khách riêng lẻ. Hai cách chia này có đơn vị khác nhau, nên không dùng để xây thang “rủi ro” chung. Khi trình bày, luôn phân biệt **10 khách** với **10% khách**.

## 5. Thị trường: Europe lớn nhất, tỷ lệ trễ khá gần nhau

| Thị trường | Đơn | Doanh thu thuần | Biên | Đơn trễ | Tỷ lệ trễ |
|---|---:|---:|---:|---:|---:|
| Europe | 17,763 | 9,348,369.23 | 12.11% | 10,199 | 57.42% |
| LATAM | 16,414 | 8,829,847.07 | 12.11% | 9,339 | 56.90% |
| Pacific Asia | 16,853 | 7,137,290.21 | 11.58% | 9,720 | 57.68% |
| USCA | 8,178 | 4,346,978.39 | 12.40% | 4,704 | 57.52% |
| Africa | 3,689 | 1,982,179.85 | 12.11% | 2,086 | 56.55% |

Có 36,048 đơn trễ trên 62,897 đơn đủ điều kiện, bằng 57.31%. Cả 23 khu vực đều có ít nhất 50% đơn bị gắn trễ; tỷ lệ nhỏ nhất 52.58%, trung vị 57.28%, lớn nhất 60.04%.

Giao trễ phân bố rộng trong dữ liệu, chưa phải vấn đề của riêng một khu vực. Mốc 50% mô tả “đa số đơn”, không phải chỉ tiêu dịch vụ chính thức.

Truy vấn 06B của SQL 07 chọn nhóm doanh thu từ trung vị trở lên và tỷ lệ trễ từ mức tổng thể trở lên. Theo quy tắc đó, các khu vực cần xem kỹ gồm Western Europe, Southeast Asia, South Asia, Eastern Asia và East of USA. Đây là quy tắc sàng lọc nội bộ, chưa phải thứ tự ưu tiên đã được doanh nghiệp duyệt.

## 6. Phương thức vận chuyển: tỷ lệ, số đơn và thời gian dự kiến cho những góc nhìn khác nhau

| Phương thức | Đơn trễ / đủ điều kiện | Tỷ lệ trễ | Ngày thực tế TB | Ngày dự kiến TB |
|---|---:|---:|---:|---:|
| First Class | 9,602 / 9,602 | 100.00% | 2.00 | 1.00 |
| Second Class | 9,803 / 12,256 | 79.99% | 4.00 | 2.00 |
| Same Day | 1,648 / 3,407 | 48.37% | 0.48 | 0.00 |
| Standard Class | 14,995 / 37,632 | 39.85% | 3.99 | 4.00 |

**Phát hiện:** First Class có tỷ lệ trễ cao nhất nhưng không có thời gian thực tế dài nhất. Standard Class có tỷ lệ trễ thấp hơn nhưng số đơn trễ lớn nhất, chiếm 41.60% toàn bộ đơn trễ.

**Diễn giải:** tỷ lệ trễ đo mức đáp ứng thời gian dự kiến của từng dịch vụ. Chưa thể gọi First Class là “chậm nhất”, hay đề xuất chuyển tất cả sang Standard Class để cải thiện trải nghiệm.

Trên dữ liệu B, cờ trễ khớp điều kiện số ngày thực tế > số ngày dự kiến ở mọi đơn. Đây là kiểm chứng tính nhất quán của nhãn trong nguồn, chưa phải xác minh độc lập bằng sự kiện khách nhận hàng.

**Bước tiếp theo:** kiểm tra quy tắc thời gian dự kiến, sau đó phân tích khu vực × phương thức với số đơn trễ và dữ liệu nhà vận chuyển/kho.

Ví dụ Europe:

| Phương thức | Đơn trễ / đủ điều kiện | Tỷ lệ trễ | Doanh thu các đơn thuộc phương thức |
|---|---:|---:|---:|
| First Class | 2,753 / 2,753 | 100.00% | 1,470,916.54 |
| Second Class | 2,773 / 3,459 | 80.17% | 1,819,173.15 |

Doanh thu trong bảng là giá trị các đơn thuộc tổ hợp, không phải khoản doanh thu đã mất.

## 7. So sánh đơn trễ với không trễ

| Chỉ số | Trễ | Không trễ |
|---|---:|---:|
| Đơn | 36,048 | 26,849 |
| Doanh thu thuần | 18,082,555.11 | 13,562,109.64 |
| Lợi nhuận | 2,140,051.68 | 1,666,368.95 |
| AOV | 501.62 | 505.13 |
| Biên lợi nhuận | 11.83% | 12.29% |

Các tổng tiền hai nhóm khớp mốc B. Biên nhóm trễ thấp hơn 0.46 điểm phần trăm nhưng chưa đủ để quy chênh lệch lợi nhuận cho giao trễ.

| Phương thức | Tỷ trọng trong nhóm trễ | Tỷ trọng trong nhóm không trễ |
|---|---:|---:|
| First Class | 26.64% | 0.00% |
| Second Class | 27.19% | 9.14% |
| Standard Class | 41.60% | 84.31% |
| Same Day | 4.57% | 6.55% |

Tỷ trọng 26.64% nghĩa là trong 36,048 đơn trễ có 26.64% thuộc First Class. Nó khác tỷ lệ trễ 100% bên trong First Class.

Cơ cấu phương thức hai nhóm khác nhau rõ. Muốn đánh giá mối liên hệ với lợi nhuận hay hành vi mua tiếp, cần kiểm soát ít nhất thời gian, thị trường, sản phẩm và thời gian dự kiến.

## 8. Kiểm tra phạm vi A được giữ riêng

Có 1,650 đơn hủy/nghi gian lận ghi ngày thực tế > dự kiến nhưng cờ trễ 0. Chúng thuộc nhóm giao hàng bị hủy, được giữ cho đối soát A và loại khỏi B.

Kết quả tổng hợp khách, thị trường, khu vực và nhóm giao hàng đã được đối soát về cùng mốc B. Xem [biên bản kiểm chứng](11_project_review_validation.md); việc kiểm tra tương tác và công thức trong Power BI vẫn còn cần thực hiện.
