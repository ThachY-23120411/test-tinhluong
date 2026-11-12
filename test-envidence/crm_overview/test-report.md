# BÁO CÁO KIỂM THỬ TRANG: CRM_OVERVIEW

> Thời gian kiểm thử: **11:11:11 19/10/2026**
> Tổng số kịch bản: **4** | ✅ LOGIC PASS: **4** | ❌ LOGIC FAIL: **0**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | Thẩm định Giao diện Dashboard KPI, Thẻ Chỉ số & Bảng Kết quả Chi tiết | ✅ PASS | ✅ PASS | PASS - Màn hình Tổng quan CRM nạp đầy đủ các widget và bảng KPI chi tiết |
| **TC-02** | Thẩm định Bộ lọc Kỳ dữ liệu (#filterType, #filterDate) & Nút Tính toán lại (#btnRecalculate) | ✅ PASS | ✅ PASS | PASS - Các bộ lọc thời gian và nút Tính toán lại phản hồi tốt, dữ liệu đồng bộ |
| **TC-03** | Thẩm định Nút Thiết lập (#btnSettings) & Đóng/Mở Modal Cấu hình KPI | ✅ PASS | ✅ PASS | PASS - Modal Cấu hình KPI mở và đóng mượt mà, đầy đủ các trường thiết lập |
| **TC-04** | Thẩm định Nút Thêm Lead (#btnCreateLead) & Modal Tạo Mới Lead Nhanh | ✅ PASS | ✅ PASS | PASS - Nút Thêm Lead mở đúng modal tạo khách hàng, các trường nhập liệu phản hồi tốt |

---

### TC-01: Thẩm định Giao diện Dashboard KPI, Thẻ Chỉ số & Bảng Kết quả Chi tiết

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `21.82s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Màn hình Tổng quan CRM nạp đầy đủ các widget và bảng KPI chi tiết
* **Thư mục lưu trữ**: `test-evidence/crm_overview/TC-01/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Mở thành công màn hình Tổng quan CRM
![Bước 1: Mở thành công màn hình Tổng quan CRM](TC-01/screenshots/TC-01-step01-mo-thanh-cong-man-hinh-tong-quan-crm.png)

##### 🔹 Bước 2: Xác nhận hiển thị khu vực Dashboard KPI và các thẻ chỉ số
![Bước 2: Xác nhận hiển thị khu vực Dashboard KPI và các thẻ chỉ số](TC-01/screenshots/TC-01-step02-xac-nhan-hien-thi-khu-vuc-dashboard-kpi-va-cac-the-chi-so.png)

##### 🔹 Bước 3: Bảng kết quả KPI chi tiết nạp đầy đủ danh sách nhân viên
![Bước 3: Bảng kết quả KPI chi tiết nạp đầy đủ danh sách nhân viên](TC-01/screenshots/TC-01-step03-bang-ket-qua-kpi-chi-tiet-nap-day-du-danh-sach-nhan-vien.png)

##### 🔹 Bước 4: Con trỏ Neon rà soát các cột chỉ số Yêu cầu Thực tế và Đạt được
![Bước 4: Con trỏ Neon rà soát các cột chỉ số Yêu cầu Thực tế và Đạt được](TC-01/screenshots/TC-01-step04-con-tro-neon-ra-soat-cac-cot-chi-so-yeu-cau-thuc-te-va-dat-duoc.png)

##### 🔹 Bước 5: Dashboard KPI nạp dữ liệu thành công đạt chuẩn
![Bước 5: Dashboard KPI nạp dữ liệu thành công đạt chuẩn](TC-01/screenshots/TC-01-step05-dashboard-kpi-nap-du-lieu-thanh-cong-dat-chuan.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-01/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_overview/TC-01/traces/trace.zip`)*

---

### TC-02: Thẩm định Bộ lọc Kỳ dữ liệu (#filterType, #filterDate) & Nút Tính toán lại (#btnRecalculate)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `28.51s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Các bộ lọc thời gian và nút Tính toán lại phản hồi tốt, dữ liệu đồng bộ
* **Thư mục lưu trữ**: `test-evidence/crm_overview/TC-02/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Kiểm tra dropdown chọn loại thời gian theo tuần tháng năm
![Bước 1: Kiểm tra dropdown chọn loại thời gian theo tuần tháng năm](TC-02/screenshots/TC-02-step01-kiem-tra-dropdown-chon-loai-thoi-gian-theo-tuan-thang-nam.png)

##### 🔹 Bước 2: Kiểm tra ô chọn kỳ tuần hiện tại
![Bước 2: Kiểm tra ô chọn kỳ tuần hiện tại](TC-02/screenshots/TC-02-step02-kiem-tra-o-chon-ky-tuan-hien-tai.png)

##### 🔹 Bước 3: Thay đổi tùy chọn số dòng hiển thị trên bảng
![Bước 3: Thay đổi tùy chọn số dòng hiển thị trên bảng](TC-02/screenshots/TC-02-step03-thay-doi-tuy-chon-so-dong-hien-thi-tren-bang.png)

##### 🔹 Bước 4: Con trỏ Neon bấm nút Tính toán lại và bắt phản hồi hệ thống
![Bước 4: Con trỏ Neon bấm nút Tính toán lại và bắt phản hồi hệ thống](TC-02/screenshots/TC-02-step04-con-tro-neon-bam-nut-tinh-toan-lai-va-bat-phan-hoi-he-thong.png)

##### 🔹 Bước 5: Dữ liệu được tính toán lại thành công không bị gián đoạn
![Bước 5: Dữ liệu được tính toán lại thành công không bị gián đoạn](TC-02/screenshots/TC-02-step05-du-lieu-duoc-tinh-toan-lai-thanh-cong-khong-bi-gian-doan.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-02/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_overview/TC-02/traces/trace.zip`)*

---

### TC-03: Thẩm định Nút Thiết lập (#btnSettings) & Đóng/Mở Modal Cấu hình KPI

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `23.01s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Modal Cấu hình KPI mở và đóng mượt mà, đầy đủ các trường thiết lập
* **Thư mục lưu trữ**: `test-evidence/crm_overview/TC-03/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Xác định vị trí nút Thiết lập cấu hình KPI
![Bước 1: Xác định vị trí nút Thiết lập cấu hình KPI](TC-03/screenshots/TC-03-step01-xac-dinh-vi-tri-nut-thiet-lap-cau-hinh-kpi.png)

##### 🔹 Bước 2: Modal Cấu hình KPI hiển thị trực quan trên màn hình
![Bước 2: Modal Cấu hình KPI hiển thị trực quan trên màn hình](TC-03/screenshots/TC-03-step02-modal-cau-hinh-kpi-hien-thi-truc-quan-tren-man-hinh.png)

##### 🔹 Bước 3: Kiểm tra các trường thiết lập tỷ lệ và tiêu chí KPI
![Bước 3: Kiểm tra các trường thiết lập tỷ lệ và tiêu chí KPI](TC-03/screenshots/TC-03-step03-kiem-tra-cac-truong-thiet-lap-ty-le-va-tieu-chi-kpi.png)

##### 🔹 Bước 4: Con trỏ Neon bấm nút Đóng modal cấu hình KPI
![Bước 4: Con trỏ Neon bấm nút Đóng modal cấu hình KPI](TC-03/screenshots/TC-03-step04-con-tro-neon-bam-nut-dong-modal-cau-hinh-kpi.png)

##### 🔹 Bước 5: Modal đóng an toàn không để lại overlay chắn giao diện
![Bước 5: Modal đóng an toàn không để lại overlay chắn giao diện](TC-03/screenshots/TC-03-step05-modal-dong-an-toan-khong-de-lai-overlay-chan-giao-dien.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-03/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-03/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_overview/TC-03/traces/trace.zip`)*

---

### TC-04: Thẩm định Nút Thêm Lead (#btnCreateLead) & Modal Tạo Mới Lead Nhanh

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `24.28s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Nút Thêm Lead mở đúng modal tạo khách hàng, các trường nhập liệu phản hồi tốt
* **Thư mục lưu trữ**: `test-evidence/crm_overview/TC-04/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Xác định vị trí nút Thêm Lead màu xanh lá
![Bước 1: Xác định vị trí nút Thêm Lead màu xanh lá](TC-04/screenshots/TC-04-step01-xac-dinh-vi-tri-nut-them-lead-mau-xanh-la.png)

##### 🔹 Bước 2: Modal Thêm LEAD mở lên với đầy đủ các trường nhập liệu
![Bước 2: Modal Thêm LEAD mở lên với đầy đủ các trường nhập liệu](TC-04/screenshots/TC-04-step02-modal-them-lead-mo-len-voi-day-du-cac-truong-nhap-lieu.png)

##### 🔹 Bước 3: Kiểm tra khả năng nhập liệu trực quan vào ô Tên khách hàng
![Bước 3: Kiểm tra khả năng nhập liệu trực quan vào ô Tên khách hàng](TC-04/screenshots/TC-04-step03-kiem-tra-kha-nang-nhap-lieu-truc-quan-vao-o-ten-khach-hang.png)

##### 🔹 Bước 4: Con trỏ Neon bấm nút Đóng modal Thêm Lead
![Bước 4: Con trỏ Neon bấm nút Đóng modal Thêm Lead](TC-04/screenshots/TC-04-step04-con-tro-neon-bam-nut-dong-modal-them-lead.png)

##### 🔹 Bước 5: Màn hình Tổng quan CRM phục hồi nguyên vẹn sau khi đóng modal
![Bước 5: Màn hình Tổng quan CRM phục hồi nguyên vẹn sau khi đóng modal](TC-04/screenshots/TC-04-step05-man-hinh-tong-quan-crm-phuc-hoi-nguyen-ven-sau-khi-dong-modal.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-04/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-04/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_overview/TC-04/traces/trace.zip`)*

---

