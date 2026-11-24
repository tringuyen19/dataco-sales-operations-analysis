# Nguồn dữ liệu và hướng dẫn chạy lại

## 1. Nguồn và ghi công

Project dùng bộ **DataCo SMART Supply Chain for Big Data Analysis**, tác giả Fabian Constante, Fernando Silva và António Pereira, Mendeley Data V5, công bố ngày 12/03/2019.

- [Trang nguồn chính và thông tin giấy phép](https://data.mendeley.com/datasets/8gx2fvg2k6/5).
- DOI: [10.17632/8gx2fvg2k6.5](https://doi.org/10.17632/8gx2fvg2k6.5).
- Trang nguồn công bố giấy phép CC BY 4.0. Khi sử dụng lại, ghi công nguồn và nêu các biến đổi đã thực hiện.

Trích dẫn nguồn: Constante, Fabian; Silva, Fernando; Pereira, António (2019), “DataCo SMART Supply Chain for Big Data Analysis”, Mendeley Data, V5.

| Tệp | Vai trò |
|---|---|
| `DataCoSupplyChainDataset.csv` | Dữ liệu giao dịch chính |
| `DescriptionDataCoSupplyChain.csv` | Mô tả biến của nguồn |
| `tokenized_access_logs.csv` | Nhật ký truy cập; chưa dùng trong phân tích này |
| `Dic.xlsx` | Từ điển tham khảo đang có trong repository; bản giải thích tiếng Việt nằm trong docs |

Các CSV bị `.gitignore` loại khỏi Git, dù đang tồn tại ở workspace cục bộ. PBIX được lưu trong repository và có thể chứa dữ liệu đã nhập; việc không đưa CSV lên Git không có nghĩa repository hoàn toàn không chứa dữ liệu nguồn.

## 2. Phiên bản dữ liệu đang dùng

Tệp cục bộ có **53 cột với tên snake_case**, ví dụ `order_id`, `order_item_total`; đây là một biến đổi so với tên tiêu đề gốc như `Order Id`, `Order Item Total`. Không gọi bản này là bản tải nguyên trạng.

Lưu bản tải ban đầu riêng. Nếu dùng bản khác, kiểm tra số cột, thứ tự, mã hóa, dấu phân cách, ngày và mã tệp trước khi so kết quả. Mã SHA-256 của bản đã rà soát được ghi trong [biên bản kiểm chứng](../docs/11_project_review_validation.md).

Project chưa có chương trình tự tải nguồn. Lấy CSV từ trang xuất bản và đặt ở:

```text
data/raw/DataCoSupplyChainDataset.csv
```

Không cần dùng nhật ký truy cập để chạy lại các kết quả hiện tại.

## 3. Những quy tắc phải giữ nhất quán

| Nội dung | Quy tắc |
|---|---|
| Một dòng | Một dòng sản phẩm trong đơn |
| Phạm vi A | 65,752 đơn, toàn bộ trạng thái |
| Phạm vi B | 62,897 đơn, loại `CANCELED` và `SUSPECTED_FRAUD` |
| Thời gian | 01/01/2015–31/01/2018 |
| Ngày trong CSV hiện có | Tháng/ngày/năm, ví dụ `1/31/2018 22:56` |
| Tiền | Làm tròn từng dòng về hai chữ số khi nạp staging |
| Doanh thu chính | Tổng `order_item_total`; không dựng lại từ tỷ lệ giảm giá |
| Đơn vị tiền | Chưa xác minh |
| Số đơn ở bảng dòng | `COUNT(DISTINCT order_id)` |

B vẫn chứa trạng thái chưa hoàn tất. Tài liệu không coi giá trị tài chính B là số kế toán đã được xác nhận.

## 4. Kiểm chứng nhanh mà chưa cần PostgreSQL

Chương trình dùng thư viện chuẩn Python 3.11 trở lên, không cần cài pandas hoặc thư viện bổ sung:

```powershell
python scripts/verify_analysis.py
```

Chạy từ thư mục gốc project. Chương trình nhận tên cột chuẩn của project hoặc bộ tên cột gốc theo đúng thứ tự; in mốc tổng và các phép kiểm tra. Mã thoát 0 nghĩa là các kiểm tra được lập trình đã khớp, chưa chứng minh độ đầy đủ nghiệp vụ.

Muốn lưu toàn bộ bảng tổng hợp, gồm số theo tháng/sản phẩm/giao hàng:

```powershell
python scripts/verify_analysis.py --output "$env:TEMP/dataco_metrics.json"
```

Nếu dùng tệp khác hoặc cách mã hóa khác:

```powershell
python scripts/verify_analysis.py --csv "C:/du-lieu/DataCoSupplyChainDataset.csv" --encoding latin-1
```

Bản hiện có dùng UTF-8. Chỉ chọn `latin-1` khi đã xác nhận cách mã hóa của bản tải, không áp dụng tùy ý để che lỗi ký tự.

## 5. Tạo bảng và nhập dữ liệu PostgreSQL

Cần PostgreSQL và một công cụ chạy SQL như psql hoặc pgAdmin. DDL bổ sung nằm tại [SQL 00](../sql/00_create_staging.sql).

Ví dụ nếu lệnh PostgreSQL đã có trong PATH:

```powershell
createdb -U postgres dataco_analytics
psql -U postgres -d dataco_analytics -v ON_ERROR_STOP=1 -f sql/00_create_staging.sql
psql -U postgres -d dataco_analytics
```

Nếu đã có cơ sở dữ liệu riêng, dùng tên tương ứng. DDL tạo bảng `stg_dataco` nếu chưa tồn tại; không xóa bảng cũ. Kiểm tra bảng đang trống trước khi nhập để tránh nạp hai lần.

Trong phiên psql, đặt quy tắc ngày và nhập CSV bằng đường dẫn thực tế:

```sql
SET datestyle = 'ISO, MDY';
SELECT COUNT(*) FROM stg_dataco;
```

Lệnh sau là lệnh riêng của psql, viết trên một dòng:

```text
\copy stg_dataco FROM 'C:/du-lieu/DataCoSupplyChainDataset.csv' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');
```

**Lưu ý quan trọng:** `HEADER TRUE` chỉ bỏ dòng tiêu đề; COPY ánh xạ dữ liệu **theo thứ tự cột**, không tự ghép theo tên. SQL 00 theo đúng thứ tự 53 cột DataCo. Kiểm tra tiêu đề bằng chương trình Python trước khi nhập. Nếu bản tải đổi thứ tự hoặc số cột, cần chuẩn hóa trước.

Khi dùng pgAdmin, tạo bảng bằng SQL 00 rồi nhập CSV với dấu phẩy, có tiêu đề và mã hóa phù hợp. Giữ ngày theo tháng/ngày/năm. Kiểm tra ngay sau nhập:

```sql
SELECT COUNT(*) AS rows,
       COUNT(DISTINCT order_item_id) AS items,
       COUNT(DISTINCT order_id) AS orders
FROM stg_dataco;
-- Kỳ vọng: 180519, 180519, 65752
```

## 6. Thứ tự chạy SQL

| Tệp | Nội dung |
|---|---|
| [00](../sql/00_create_staging.sql) | Tạo staging; sau đó nhập CSV |
| [01](../sql/01_profiling_and_grain.sql) | Quy mô, khóa và cấp dữ liệu |
| [02](../sql/02_data_quality_checks.sql) | Giá trị thiếu, ngày, nhãn và trạng thái |
| [03](../sql/03_financial_validation.sql) | Công thức tài chính và độ nhạy A/B |
| [04](../sql/04_cleaning_transformation.sql) | Kiểm tra kiểu, khoảng trắng, thuộc tính cấp đơn |
| [05](../sql/05_create_analysis_views.sql) | Tạo bốn view A/B và đối soát |
| [06](../sql/06_business_analysis_sales_product.sql) | Doanh thu, tháng, danh mục, sản phẩm |
| [07](../sql/07_business_analysis_customer_market_delivery.sql) | Khách, thị trường và giao hàng |
| [08](../sql/08_deeper_diagnostics.sql) | Phân rã, quy mô lỗ và chẩn đoán giao hàng |

Ví dụ chạy từng tệp:

```powershell
psql -U postgres -d dataco_analytics -v ON_ERROR_STOP=1 -f sql/01_profiling_and_grain.sql
```

Các tệp kiểm tra trả về nhiều bảng kết quả, cần đọc kết quả thay vì chỉ nhìn “chạy thành công”. SQL 07 tạo view khách **tạm trong phiên**, nên chạy cả tệp trong cùng một phiên; không mở riêng các truy vấn phía sau trong kết nối khác.

SQL 04 chủ yếu kiểm tra điều kiện trước biến đổi. Chuẩn hóa nhãn và các cột phân tích được thực hiện trong view ở SQL 05, không UPDATE/DELETE dữ liệu nguồn.

## 7. Mốc B để đối soát

| Chỉ số | Kỳ vọng |
|---|---:|
| Đơn / khách | 62,897 / 20,261 |
| Dòng / số lượng bán | 172,765 / 367,591 |
| Doanh thu thuần | 31,644,664.75 |
| Lợi nhuận | 3,806,420.63 |
| Biên | 12.03% |
| AOV | 503.12 |
| Trễ / đủ điều kiện | 36,048 / 62,897 |
| Tỷ lệ trễ | 57.31% |

Nếu lệch, kiểm tra theo thứ tự: tệp và số dòng → cột/thứ tự/mã hóa → kiểu và làm tròn tiền → ngày → phạm vi → phép tổng hợp. Không sửa mốc để khớp một kết quả chưa giải thích được.

## 8. Mở và làm mới Power BI

Mở [PBIX](../PowerBI/DataCo_Supply_Chain_Analytics.pbix) trong Power BI Desktop để xem dữ liệu đã lưu. Nếu cần làm mới, vào thiết lập nguồn của Power Query để xem và điều chỉnh máy chủ/cơ sở dữ liệu theo môi trường cục bộ; xác nhận các truy vấn trỏ tới hai view B.

Lần rà soát này chưa kiểm tra toàn bộ Power Query hoặc làm mới PBIX, nên chưa bảo đảm chỉ đổi kết nối là đủ. Sau khi làm mới, bỏ bộ lọc và đối chiếu mốc trên; kiểm tra thêm các tình huống trong [tài liệu 10](../docs/10_dashboard_requirements_and_wireframe.md).

## 9. Tài liệu cần đọc kèm

[Từ điển 53 trường](../docs/data_dictionary.md) giải thích ý nghĩa và kiểu staging. [Kiểm chứng tài chính](../docs/03_financial_field_validation.md) giải thích sai khác do làm tròn. [Biên bản rà soát](../docs/11_project_review_validation.md) ghi những gì đã chạy và phần Power BI chưa kiểm chứng. [Hướng dẫn thực hành](../docs/12_analysis_and_presentation_guide.md) giúp học cách phân tích từ các truy vấn.
