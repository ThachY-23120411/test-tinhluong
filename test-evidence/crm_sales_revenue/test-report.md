# BÁO CÁO KIỂM THỬ TRANG: CRM_SALES_REVENUE

> Thời gian kiểm thử: **08:46:46 28/10/2026**
> Tổng số kịch bản: **6** | ✅ LOGIC PASS: **5** | ❌ LOGIC FAIL: **1**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | Khởi động, Tải Màn hình Doanh số & Xác thực 6 Thẻ Metric KPI Tổng quan | ✅ PASS | ✅ PASS | PASS - Màn hình Báo cáo Doanh số nạp đầy đủ 6 thẻ KPI và danh sách 7 nhân sự khớp định lượng CSDL |
| **TC-02** | Vòng đời 3 Pha Cụm Nút Lọc Kỳ Doanh số (.ttv-pill: Tuần, Tháng, Quý, Năm) | ✅ PASS | ❌ FAIL | FAIL - Sai lệch kỳ lọc: Năm nhận 9 (kỳ vọng 9), Khôi phục nhận 7 (kỳ vọng 9) |
| **TC-03** | Thẩm định Dropdown Chọn Năm (#filter-year) & Tháng (#filter-month) Kết Hợp Nút Tải Lại | ✅ PASS | ✅ PASS | PASS - Dropdown Năm/Tháng và Nút Tải lại phản hồi mượt mà, đồng bộ số liệu chính xác từ CSDL |
| **TC-04** | Mở Dashboard Chi tiết Doanh thu Nhân viên (showDetail) & Biểu đồ Trực quan | ✅ PASS | ✅ PASS | PASS - Dashboard chi tiết của NGUYỄN TẤN CHIẾN hiển thị đầy đủ biểu đồ trực quan, nút quay lại hoạt động mượt mà |
| **TC-05** | Nghiệp vụ Xuất Báo cáo Doanh số PDF (#btn-export-pdf) & Kiểm tra Trạng thái Tiến trình | ✅ PASS | ✅ PASS | PASS - Nút Xuất PDF phản hồi tức thì, layout không bị vỡ và giao diện duy trì trạng thái ổn định |
| **TC-06** | Quy trình Đối soát Liên màn hình: Dữ liệu Hợp đồng Thanh toán Đồng bộ Doanh số | ✅ PASS | ✅ PASS | PASS - Báo cáo doanh số phản ánh chính xác số liệu hợp đồng từ CSDL (tblCRM_Contract & tblCRM_ContractPayment), phân bổ đều qua 9 nhân sự |

---

### TC-01: Khởi động, Tải Màn hình Doanh số & Xác thực 6 Thẻ Metric KPI Tổng quan

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `22.20s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Màn hình Báo cáo Doanh số nạp đầy đủ 6 thẻ KPI và danh sách 7 nhân sự khớp định lượng CSDL
* **Thư mục lưu trữ**: `test-evidence/crm_sales_revenue/TC-01/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Mở thành công màn hình Doanh số trong phân hệ CRM
![Bước 1: Mở thành công màn hình Doanh số trong phân hệ CRM](TC-01/screenshots/TC-01-step01-mo-thanh-cong-man-hinh-doanh-so-trong-phan-he-crm.png)

##### 🔹 Bước 2: Xác nhận hiển thị không gian làm việc Báo cáo Doanh số
![Bước 2: Xác nhận hiển thị không gian làm việc Báo cáo Doanh số](TC-01/screenshots/TC-01-step02-xac-nhan-hien-thi-khong-gian-lam-viec-bao-cao-doanh-so.png)

##### 🔹 Bước 3: Rà soát cụm nút lọc kỳ thời gian và dropdown chọn năm tháng
![Bước 3: Rà soát cụm nút lọc kỳ thời gian và dropdown chọn năm tháng](TC-01/screenshots/TC-01-step03-ra-soat-cum-nut-loc-ky-thoi-gian-va-dropdown-chon-nam-thang.png)

##### 🔹 Bước 4: Con trỏ Neon rà soát 6 thẻ chỉ số KPI tổng quan doanh số
![Bước 4: Con trỏ Neon rà soát 6 thẻ chỉ số KPI tổng quan doanh số](TC-01/screenshots/TC-01-step04-con-tro-neon-ra-soat-6-the-chi-so-kpi-tong-quan-doanh-so.png)

##### 🔹 Bước 5: Đánh giá logic PASS: Danh sách nạp đầy đủ 7/7 nhân sự kinh doanh
![Bước 5: Đánh giá logic PASS: Danh sách nạp đầy đủ 7/7 nhân sự kinh doanh](TC-01/screenshots/TC-01-step05-danh-gia-logic-pass-danh-sach-nap-day-du-7-7-nhan-su-kinh-doanh.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-01/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_sales_revenue/TC-01/traces/trace.zip`)*

---

### TC-02: Vòng đời 3 Pha Cụm Nút Lọc Kỳ Doanh số (.ttv-pill: Tuần, Tháng, Quý, Năm)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `28.73s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: FAIL - Sai lệch kỳ lọc: Năm nhận 9 (kỳ vọng 9), Khôi phục nhận 7 (kỳ vọng 9)
* **Thư mục lưu trữ**: `test-evidence/crm_sales_revenue/TC-02/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Vòng đời bộ lọc kỳ không đồng bộ dữ liệu đúng kỳ vọng
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Pha 1 - Baseline: Ghi nhận số lượng nhân sự ở kỳ Tháng là N0 = 9
![Bước 1: Pha 1 - Baseline: Ghi nhận số lượng nhân sự ở kỳ Tháng là N0 = 9](TC-02/screenshots/TC-02-step01-pha-1-baseline-ghi-nhan-so-luong-nhan-su-o-ky-thang-la-n0-9.png)

##### 🔹 Bước 2: Pha 2 - Filter Action: Chuyển sang kỳ Năm, ghi nhận N_year = 9 nhân sự
![Bước 2: Pha 2 - Filter Action: Chuyển sang kỳ Năm, ghi nhận N_year = 9 nhân sự](TC-02/screenshots/TC-02-step02-pha-2-filter-action-chuyen-sang-ky-nam-ghi-nhan-n-year-9-nhan-su.png)

##### 🔹 Bước 3: Con trỏ Neon chọn xem doanh số theo kỳ Quý và kích hoạt dropdown Quý
![Bước 3: Con trỏ Neon chọn xem doanh số theo kỳ Quý và kích hoạt dropdown Quý](TC-02/screenshots/TC-02-step03-con-tro-neon-chon-xem-doanh-so-theo-ky-quy-va-kich-hoat-dropdown-quy.png)

##### 🔹 Bước 4: Pha 3 - Reset: Khôi phục lại kỳ Tháng, số lượng bản ghi N_restored = 7
![Bước 4: Pha 3 - Reset: Khôi phục lại kỳ Tháng, số lượng bản ghi N_restored = 7](TC-02/screenshots/TC-02-step04-pha-3-reset-khoi-phuc-lai-ky-thang-so-luong-ban-ghi-n-restored-7.png)

##### 🔹 Bước 5: Đánh giá logic FAIL: Sai lệch số lượng bản ghi khi chuyển kỳ
![Bước 5: Đánh giá logic FAIL: Sai lệch số lượng bản ghi khi chuyển kỳ](TC-02/screenshots/TC-02-step05-danh-gia-logic-fail-sai-lech-so-luong-ban-ghi-khi-chuyen-ky.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-02/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_sales_revenue/TC-02/traces/trace.zip`)*

---

### TC-03: Thẩm định Dropdown Chọn Năm (#filter-year) & Tháng (#filter-month) Kết Hợp Nút Tải Lại

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `29.97s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Dropdown Năm/Tháng và Nút Tải lại phản hồi mượt mà, đồng bộ số liệu chính xác từ CSDL
* **Thư mục lưu trữ**: `test-evidence/crm_sales_revenue/TC-03/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Xác định bộ chọn thời gian hiện tại: Năm 2026, Tháng 10
![Bước 1: Xác định bộ chọn thời gian hiện tại: Năm 2026, Tháng 10](TC-03/screenshots/TC-03-step01-xac-dinh-bo-chon-thoi-gian-hien-tai-nam-2026-thang-10.png)

##### 🔹 Bước 2: Con trỏ Neon chọn mốc lịch sử: Năm 2025, Tháng 12
![Bước 2: Con trỏ Neon chọn mốc lịch sử: Năm 2025, Tháng 12](TC-03/screenshots/TC-03-step02-con-tro-neon-chon-moc-lich-su-nam-2025-thang-12.png)

##### 🔹 Bước 3: Bấm nút Tải lại dữ liệu và đồng bộ số liệu lịch sử từ máy chủ
![Bước 3: Bấm nút Tải lại dữ liệu và đồng bộ số liệu lịch sử từ máy chủ](TC-03/screenshots/TC-03-step03-bam-nut-tai-lai-du-lieu-va-dong-bo-so-lieu-lich-su-tu-may-chu.png)

##### 🔹 Bước 4: Khôi phục mốc báo cáo ban đầu: Năm 2026, Tháng 10
![Bước 4: Khôi phục mốc báo cáo ban đầu: Năm 2026, Tháng 10](TC-03/screenshots/TC-03-step04-khoi-phuc-moc-bao-cao-ban-dau-nam-2026-thang-10.png)

##### 🔹 Bước 5: Đánh giá logic PASS: Bộ chọn Năm và Tháng kết hợp nút Tải lại đạt chuẩn nghiệp vụ
![Bước 5: Đánh giá logic PASS: Bộ chọn Năm và Tháng kết hợp nút Tải lại đạt chuẩn nghiệp vụ](TC-03/screenshots/TC-03-step05-danh-gia-logic-pass-bo-chon-nam-va-thang-ket-hop-nut-tai-lai-dat-chuan-nghiep-vu.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-03/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-03/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_sales_revenue/TC-03/traces/trace.zip`)*

---

### TC-04: Mở Dashboard Chi tiết Doanh thu Nhân viên (showDetail) & Biểu đồ Trực quan

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `26.72s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Dashboard chi tiết của NGUYỄN TẤN CHIẾN hiển thị đầy đủ biểu đồ trực quan, nút quay lại hoạt động mượt mà
* **Thư mục lưu trữ**: `test-evidence/crm_sales_revenue/TC-04/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Xác định nhân sự NGUYỄN TẤN CHIẾN trên bảng danh sách doanh số
![Bước 1: Xác định nhân sự NGUYỄN TẤN CHIẾN trên bảng danh sách doanh số](TC-04/screenshots/TC-04-step01-xac-dinh-nhan-su-nguyen-tan-chien-tren-bang-danh-sach-doanh-so.png)

##### 🔹 Bước 2: Con trỏ Neon nhấp dòng nhân sự kích hoạt Dashboard chi tiết cá nhân
![Bước 2: Con trỏ Neon nhấp dòng nhân sự kích hoạt Dashboard chi tiết cá nhân](TC-04/screenshots/TC-04-step02-con-tro-neon-nhap-dong-nhan-su-kich-hoat-dashboard-chi-tiet-ca-nhan.png)

##### 🔹 Bước 3: Rà soát biểu đồ xu hướng doanh thu và biểu đồ cơ cấu thanh toán Donut
![Bước 3: Rà soát biểu đồ xu hướng doanh thu và biểu đồ cơ cấu thanh toán Donut](TC-04/screenshots/TC-04-step03-ra-soat-bieu-do-xu-huong-doanh-thu-va-bieu-do-co-cau-thanh-toan-donut.png)

##### 🔹 Bước 4: Nhấp nút Quay lại và khôi phục màn hình danh sách tổng hợp
![Bước 4: Nhấp nút Quay lại và khôi phục màn hình danh sách tổng hợp](TC-04/screenshots/TC-04-step04-nhap-nut-quay-lai-va-khoi-phuc-man-hinh-danh-sach-tong-hop.png)

##### 🔹 Bước 5: Đánh giá logic PASS: Luồng showDetail mở Dashboard và quay lại danh sách hoàn hảo
![Bước 5: Đánh giá logic PASS: Luồng showDetail mở Dashboard và quay lại danh sách hoàn hảo](TC-04/screenshots/TC-04-step05-danh-gia-logic-pass-luong-showdetail-mo-dashboard-va-quay-lai-danh-sach-hoan-hao.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-04/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-04/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_sales_revenue/TC-04/traces/trace.zip`)*

---

### TC-05: Nghiệp vụ Xuất Báo cáo Doanh số PDF (#btn-export-pdf) & Kiểm tra Trạng thái Tiến trình

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `34.88s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Nút Xuất PDF phản hồi tức thì, layout không bị vỡ và giao diện duy trì trạng thái ổn định
* **Thư mục lưu trữ**: `test-evidence/crm_sales_revenue/TC-05/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Mở Dashboard chi tiết để thẩm định tính năng xuất báo cáo
![Bước 1: Mở Dashboard chi tiết để thẩm định tính năng xuất báo cáo](TC-05/screenshots/TC-05-step01-mo-dashboard-chi-tiet-de-tham-dinh-tinh-nang-xuat-bao-cao.png)

##### 🔹 Bước 2: Xác định vị trí nút Xuất PDF trên thanh điều khiển chi tiết
![Bước 2: Xác định vị trí nút Xuất PDF trên thanh điều khiển chi tiết](TC-05/screenshots/TC-05-step02-xac-dinh-vi-tri-nut-xuat-pdf-tren-thanh-dieu-khien-chi-tiet.png)

##### 🔹 Bước 3: Con trỏ Neon bấm nút Xuất PDF và kích hoạt tiến trình tạo tài liệu
![Bước 3: Con trỏ Neon bấm nút Xuất PDF và kích hoạt tiến trình tạo tài liệu](TC-05/screenshots/TC-05-step03-con-tro-neon-bam-nut-xuat-pdf-va-kich-hoat-tien-trinh-tao-tai-lieu.png)

##### 🔹 Bước 4: Hệ thống xử lý tiến trình tạo tài liệu PDF an toàn không phát sinh lỗi
![Bước 4: Hệ thống xử lý tiến trình tạo tài liệu PDF an toàn không phát sinh lỗi](TC-05/screenshots/TC-05-step04-he-thong-xu-ly-tien-trinh-tao-tai-lieu-pdf-an-toan-khong-phat-sinh-loi.png)

##### 🔹 Bước 5: Đánh giá logic PASS: Tính năng xuất báo cáo PDF hoạt động ổn định và sẵn sàng
![Bước 5: Đánh giá logic PASS: Tính năng xuất báo cáo PDF hoạt động ổn định và sẵn sàng](TC-05/screenshots/TC-05-step05-danh-gia-logic-pass-tinh-nang-xuat-bao-cao-pdf-hoat-dong-on-dinh-va-san-sang.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-05/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-05/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_sales_revenue/TC-05/traces/trace.zip`)*

---

### TC-06: Quy trình Đối soát Liên màn hình: Dữ liệu Hợp đồng Thanh toán Đồng bộ Doanh số

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `22.03s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Báo cáo doanh số phản ánh chính xác số liệu hợp đồng từ CSDL (tblCRM_Contract & tblCRM_ContractPayment), phân bổ đều qua 9 nhân sự
* **Thư mục lưu trữ**: `test-evidence/crm_sales_revenue/TC-06/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Chuyển kỳ xem Năm 2026 để đối soát tổng hợp đồng và thanh toán
![Bước 1: Chuyển kỳ xem Năm 2026 để đối soát tổng hợp đồng và thanh toán](TC-06/screenshots/TC-06-step01-chuyen-ky-xem-nam-2026-de-doi-soat-tong-hop-dong-va-thanh-toan.png)

##### 🔹 Bước 2: Ghi nhận số lượng trên thẻ TỔNG HỢP ĐỒNG: 96
![Bước 2: Ghi nhận số lượng trên thẻ TỔNG HỢP ĐỒNG: 96](TC-06/screenshots/TC-06-step02-ghi-nhan-so-luong-tren-the-tong-hop-dong-96.png)

##### 🔹 Bước 3: Xác nhận danh sách nhân sự phụ trách hợp đồng thực tế (Nguyễn Tấn Chiến, Trần Khánh Ly)
![Bước 3: Xác nhận danh sách nhân sự phụ trách hợp đồng thực tế (Nguyễn Tấn Chiến, Trần Khánh Ly)](TC-06/screenshots/TC-06-step03-xac-nhan-danh-sach-nhan-su-phu-trach-hop-dong-thuc-te-nguyen-tan-chien-tran-khanh-ly.png)

##### 🔹 Bước 4: Rà soát tính nhất quán của số liệu doanh thu đã chốt và số dư thanh toán
![Bước 4: Rà soát tính nhất quán của số liệu doanh thu đã chốt và số dư thanh toán](TC-06/screenshots/TC-06-step04-ra-soat-tinh-nhat-quan-cua-so-lieu-doanh-thu-da-chot-va-so-du-thanh-toan.png)

##### 🔹 Bước 5: Đánh giá logic PASS: Số liệu đối soát liên màn hình khớp nhất quán với CSDL quan hệ
![Bước 5: Đánh giá logic PASS: Số liệu đối soát liên màn hình khớp nhất quán với CSDL quan hệ](TC-06/screenshots/TC-06-step05-danh-gia-logic-pass-so-lieu-doi-soat-lien-man-hinh-khop-nhat-quan-voi-csdl-quan-he.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-06/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-06/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_sales_revenue/TC-06/traces/trace.zip`)*

---

