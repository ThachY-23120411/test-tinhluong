# BÁO CÁO KIỂM THỬ TRANG: CRM_SERVICE_TRACKING

> Thời gian kiểm thử: **12:41:04 16/10/2026**
> Tổng số kịch bản: **4** | ✅ LOGIC PASS: **3** | ❌ LOGIC FAIL: **1**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | Khởi động, Điều hướng và Thẩm định API Nạp Danh sách Dịch vụ/Hợp đồng | ✅ PASS | ✅ PASS | PASS - Màn hình Theo dõi dịch vụ nạp danh sách hợp đồng thông suốt với đầy đủ dữ liệu |
| **TC-02** | Thẩm định Checkbox Lọc Dữ liệu Cá nhân (#toolbarIsOnlyUser) & Bắt API Lọc | ✅ PASS | ✅ PASS | PASS - Checkbox lọc cá nhân phản hồi mượt mà, chu kỳ khôi phục dữ liệu đạt 100% |
| **TC-03** | Thẩm định Ô Tìm kiếm Nhanh, Lọc Tức thì & Khôi phục Danh sách | ✅ PASS | ❌ FAIL | FAIL - Lỗi cú pháp SQL Backend khi tìm kiếm: Incorrect syntax near ')'. |
| **TC-04** | Thẩm định Nút Chọn Cột Hiển thị (Column Chooser Panel) | ✅ PASS | ✅ PASS | PASS - Tính năng Column Chooser hoạt động mượt mà, hiển thị đầy đủ danh mục cột |

---

### TC-01: Khởi động, Điều hướng và Thẩm định API Nạp Danh sách Dịch vụ/Hợp đồng

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `26.38s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Màn hình Theo dõi dịch vụ nạp danh sách hợp đồng thông suốt với đầy đủ dữ liệu
* **Thư mục lưu trữ**: `test-evidence/crm_service_tracking/TC-01/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Mở thành công màn hình Theo dõi dịch vụ trong CRM
![Bước 1: Mở thành công màn hình Theo dõi dịch vụ trong CRM](TC-01/screenshots/TC-01-step01-mo-thanh-cong-man-hinh-theo-doi-dich-vu-trong-crm.png)

##### 🔹 Bước 2: DataGrid nạp đầy đủ danh sách hợp đồng dịch vụ khách hàng
![Bước 2: DataGrid nạp đầy đủ danh sách hợp đồng dịch vụ khách hàng](TC-01/screenshots/TC-01-step02-datagrid-nap-day-du-danh-sach-hop-dong-dich-vu-khach-hang.png)

##### 🔹 Bước 3: Xác nhận hiển thị đầy đủ các cột nghiệp vụ trọng tâm
![Bước 3: Xác nhận hiển thị đầy đủ các cột nghiệp vụ trọng tâm](TC-01/screenshots/TC-01-step03-xac-nhan-hien-thi-day-du-cac-cot-nghiep-vu-trong-tam.png)

##### 🔹 Bước 4: Con trỏ Neon rà soát và chọn dòng dịch vụ đầu tiên
![Bước 4: Con trỏ Neon rà soát và chọn dòng dịch vụ đầu tiên](TC-01/screenshots/TC-01-step04-con-tro-neon-ra-soat-va-chon-dong-dich-vu-dau-tien.png)

##### 🔹 Bước 5: Danh sách dịch vụ nạp hoàn chỉnh đạt chuẩn
![Bước 5: Danh sách dịch vụ nạp hoàn chỉnh đạt chuẩn](TC-01/screenshots/TC-01-step05-danh-sach-dich-vu-nap-hoan-chinh-dat-chuan.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-01/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_service_tracking/TC-01/traces/trace.zip`)*

---

### TC-02: Thẩm định Checkbox Lọc Dữ liệu Cá nhân (#toolbarIsOnlyUser) & Bắt API Lọc

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `26.74s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Checkbox lọc cá nhân phản hồi mượt mà, chu kỳ khôi phục dữ liệu đạt 100%
* **Thư mục lưu trữ**: `test-evidence/crm_service_tracking/TC-02/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Xác định vị trí checkbox Lọc dữ liệu cá nhân
![Bước 1: Xác định vị trí checkbox Lọc dữ liệu cá nhân](TC-02/screenshots/TC-02-step01-xac-dinh-vi-tri-checkbox-loc-du-lieu-ca-nhan.png)

##### 🔹 Bước 2: Con trỏ Neon nhấp đổi trạng thái checkbox lọc dữ liệu cá nhân
![Bước 2: Con trỏ Neon nhấp đổi trạng thái checkbox lọc dữ liệu cá nhân](TC-02/screenshots/TC-02-step02-con-tro-neon-nhap-doi-trang-thai-checkbox-loc-du-lieu-ca-nhan.png)

##### 🔹 Bước 3: DataGrid cập nhật danh sách theo tiêu chí phân quyền cá nhân
![Bước 3: DataGrid cập nhật danh sách theo tiêu chí phân quyền cá nhân](TC-02/screenshots/TC-02-step03-datagrid-cap-nhat-danh-sach-theo-tieu-chi-phan-quyen-ca-nhan.png)

##### 🔹 Bước 4: Khôi phục lại checkbox ban đầu và thẩm định tính toàn vẹn danh sách
![Bước 4: Khôi phục lại checkbox ban đầu và thẩm định tính toàn vẹn danh sách](TC-02/screenshots/TC-02-step04-khoi-phuc-lai-checkbox-ban-dau-va-tham-dinh-tinh-toan-ven-danh-sach.png)

##### 🔹 Bước 5: Hệ thống khôi phục dữ liệu nguyên vẹn sau chu kỳ lọc
![Bước 5: Hệ thống khôi phục dữ liệu nguyên vẹn sau chu kỳ lọc](TC-02/screenshots/TC-02-step05-he-thong-khoi-phuc-du-lieu-nguyen-ven-sau-chu-ky-loc.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-02/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_service_tracking/TC-02/traces/trace.zip`)*

---

### TC-03: Thẩm định Ô Tìm kiếm Nhanh, Lọc Tức thì & Khôi phục Danh sách

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `26.58s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: FAIL - Lỗi cú pháp SQL Backend khi tìm kiếm: Incorrect syntax near ')'.
* **Thư mục lưu trữ**: `test-evidence/crm_service_tracking/TC-03/`

> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)
>
> * **Vấn đề / Mã lỗi**: DataGrid hiển thị "Không có dữ liệu" khi tìm kiếm dù từ khóa có thật trong danh sách
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Khi tìm kiếm "NIDEC" hoặc "CÔNG TY", hệ thống phải trả về các bản ghi khớp với từ khóa
> * **Thực tế hệ thống (Actual Output)**: Server IIS trả HTTP 200 nhưng payload trả lỗi SQL nội bộ: "Incorrect syntax near ')'.", làm mảng data rỗng []
> * **Nguyên nhân cốt lõi (Root Cause)**: Stored Procedure hoặc câu lệnh SQL động phía Backend xử lý tham số tìm kiếm bị sai cú pháp (Incorrect syntax near ")")
> * **Đề xuất khắc phục (Recommendation)**: Đội ngũ Backend cần kiểm tra lại câu lệnh SQL ghép chuỗi tìm kiếm trong Stored Procedure của menu Theo dõi dịch vụ

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Trích xuất từ khóa thực tế từ dòng 1: CÔNG
![Bước 1: Trích xuất từ khóa thực tế từ dòng 1: CÔNG](TC-03/screenshots/TC-03-step01-trich-xuat-tu-khoa-thuc-te-tu-dong-1-cong-ty-tnhh-nidec-instruments-viet-nam.png)

##### 🔹 Bước 1: Trích xuất từ khóa thực tế từ dòng 1: CÔNG
![Bước 1: Trích xuất từ khóa thực tế từ dòng 1: CÔNG](TC-03/screenshots/TC-03-step01-trich-xuat-tu-khoa-thuc-te-tu-dong-1-cong.png)

##### 🔹 Bước 2: Con trỏ Neon focus vào ô tìm kiếm nhanh
![Bước 2: Con trỏ Neon focus vào ô tìm kiếm nhanh](TC-03/screenshots/TC-03-step02-con-tro-neon-focus-vao-o-tim-kiem-nhanh.png)

##### 🔹 Bước 3: Gõ từ khóa tìm kiếm và quan sát DataGrid lọc tức thì
![Bước 3: Gõ từ khóa tìm kiếm và quan sát DataGrid lọc tức thì](TC-03/screenshots/TC-03-step03-go-tu-khoa-tim-kiem-va-quan-sat-datagrid-loc-tuc-thi.png)

##### 🔹 Bước 4: Phát hiện lỗi Backend SQL làm DataGrid rỗng dữ liệu khi tìm kiếm
![Bước 4: Phát hiện lỗi Backend SQL làm DataGrid rỗng dữ liệu khi tìm kiếm](TC-03/screenshots/TC-03-step04-phat-hien-loi-backend-sql-lam-datagrid-rong-du-lieu-khi-tim-kiem.png)

##### 🔹 Bước 5: Xóa ô tìm kiếm và khôi phục nguyên vẹn 100% số bản ghi ban đầu
![Bước 5: Xóa ô tìm kiếm và khôi phục nguyên vẹn 100% số bản ghi ban đầu](TC-03/screenshots/TC-03-step05-xoa-o-tim-kiem-va-khoi-phuc-nguyen-ven-100-so-ban-ghi-ban-dau.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-03/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-03/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_service_tracking/TC-03/traces/trace.zip`)*

---

### TC-04: Thẩm định Nút Chọn Cột Hiển thị (Column Chooser Panel)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `23.50s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Tính năng Column Chooser hoạt động mượt mà, hiển thị đầy đủ danh mục cột
* **Thư mục lưu trữ**: `test-evidence/crm_service_tracking/TC-04/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Xác định vị trí icon Chọn cột hiển thị trên toolbar
![Bước 1: Xác định vị trí icon Chọn cột hiển thị trên toolbar](TC-04/screenshots/TC-04-step01-xac-dinh-vi-tri-icon-chon-cot-hien-thi-tren-toolbar.png)

##### 🔹 Bước 2: Bảng chọn cột hiển thị (Column Chooser) mở ra trực quan
![Bước 2: Bảng chọn cột hiển thị (Column Chooser) mở ra trực quan](TC-04/screenshots/TC-04-step02-bang-chon-cot-hien-thi-column-chooser-mo-ra-truc-quan.png)

##### 🔹 Bước 3: Rà soát các tùy chọn bật/tắt hiển thị từng cột dữ liệu
![Bước 3: Rà soát các tùy chọn bật/tắt hiển thị từng cột dữ liệu](TC-04/screenshots/TC-04-step03-ra-soat-cac-tuy-chon-bat-tat-hien-thi-tung-cot-du-lieu.png)

##### 🔹 Bước 4: Con trỏ Neon bấm đóng panel Column Chooser
![Bước 4: Con trỏ Neon bấm đóng panel Column Chooser](TC-04/screenshots/TC-04-step04-con-tro-neon-bam-dong-panel-column-chooser.png)

##### 🔹 Bước 5: Panel chọn cột đóng an toàn không gây crash giao diện
![Bước 5: Panel chọn cột đóng an toàn không gây crash giao diện](TC-04/screenshots/TC-04-step05-panel-chon-cot-dong-an-toan-khong-gay-crash-giao-dien.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-04/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-04/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_service_tracking/TC-04/traces/trace.zip`)*

---

