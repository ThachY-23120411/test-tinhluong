# BÁO CÁO KIỂM THỬ TRANG: CHAM_CONG_TINH_LUONG_TOAN_DIEN

> Thời gian kiểm thử: **11:49:54 4/11/2026**
> Tổng số kịch bản: **8** | ✅ LOGIC PASS: **8** | ❌ LOGIC FAIL: **0**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | Kiểm tra kiểm soát ràng buộc và tạo đơn Xin bù công (Role: tai.dang) | ✅ PASS | ✅ PASS | PASS - Tạo và gửi đơn xin bù công thành công, xác thực CSDL đã lưu bản ghi IdentityID: 01A1A4E0-968F-7D0E-BC4F-9C1924459647 (Token: 535718) |
| **TC-02** | Nhân viên đối soát tab Lịch sử đơn bù công (Role: tai.dang) | ✅ PASS | ✅ PASS | PASS - Đơn bù công hiển thị chuẩn xác trong Tab Lịch sử với trạng thái "Đang chờ duyệt" (Khớp CSDL Approve_Status: 1) |
| **TC-03** | Quản lý cấp duyệt thẩm định và duyệt đơn bù công 2 cấp (Role: ThanhLong & cuong.vu) | ✅ PASS | ✅ PASS | PASS - Quy trình phê duyệt liên hoàn 2 cấp (ThanhLong Cấp 1 -> cuong.vu Cấp 2) hoàn tất chuẩn xác, xác thực CSDL đã duyệt thành công |
| **TC-04** | Nhân sự C&B kiểm tra công ngày và tổng hợp công tháng (Role: cuong.vu) | ✅ PASS | ✅ PASS | PASS - Bảng công ngày hiển thị chính xác bản ghi công của nhân viên 046 (Khớp CSDL tblHasTA) |
| **TC-05** | Kế toán chạy tính toán lương tự động (Role: chien.nguyen) | ✅ PASS | ✅ PASS | PASS - Bảng lương công ty tổng hợp đầy đủ chỉ tiêu lương cho nhân viên 046 (Khớp CSDL tblSal_Sal) |
| **TC-06** | Kế toán thẩm định chốt chặn màn hình Khóa lương (Role: chien.nguyen) | ✅ PASS | ✅ PASS | PASS - Xác nhận kỳ lương Tháng 08/2026 đã được Khóa an toàn trong tblSal_Lock. Cổng chốt chặn Khóa lương hợp lệ, sẵn sàng phát hành Phiếu lương cá nhân ra Cổng thông tin nhân viên. |
| **TC-07** | Nhân viên đối soát định lượng từng trường trên Phiếu lương cá nhân (Role: tai.dang) | ✅ PASS | ✅ PASS | PASS - Đối soát định lượng khớp 100% từng trường trên Phiếu lương (11/11 chỉ tiêu khớp CSDL). Kỳ lương: 08/2026, Giảm trừ gia cảnh: 0 VNĐ, Thực lĩnh: 0 VNĐ.

| STT | Trường chỉ tiêu trên Phiếu lương | Giá trị trên UI | Giá trị đối ứng trong CSDL | Trạng thái so khớp |
| :---: | :--- | :--- | :--- | :---: |
| 1 | Mã nhân viên (psEmpID) | 046 | 046 | ✅ KHỚP 100% |
| 2 | Họ và tên (psFullName) | Đặng Minh Tài | Đặng Minh Tài | ✅ KHỚP 100% |
| 3 | Ngày vào làm (psHireDate) | 15/07/2025 | 15/07/2025 | ✅ KHỚP 100% |
| 4 | Kỳ lương Tháng/Năm (psMonthYear) | Tháng/Năm: 08/2026 | 08/2026 | ✅ KHỚP 100% |
| 5 | Công chuẩn (psStdDays) | 23 ngày | 23 ngày | ✅ KHỚP 100% |
| 6 | Công thực tế (psActDays) | 23 ngày | 23 ngày | ✅ KHỚP 100% |
| 7 | Lương cơ bản (psBasicSalary) | 0 | 0 | ✅ KHỚP 100% |
| 8 | Người phụ thuộc (psDependents) | *(Trống)* | *(Trống)* | ✅ KHỚP 100% |
| 9 | Giảm trừ gia cảnh (psDepTax) | 0 | 0 | ✅ KHỚP 100% |
| 10 | Tổng thu nhập (psTotalIncome) | 0 | 0 | ✅ KHỚP 100% |
| 11 | Thực lĩnh / Lương thực nhận (psNetSalary) | 0 | 0 | ✅ KHỚP 100% | |
| **TC-08** | Đối soát Tab Lịch sử phiếu lương và 3 Modal chi tiết Tăng ca, Ngày nghỉ, Đi trễ (Role: tai.dang) | ✅ PASS | ✅ PASS | PASS - Tab Lịch sử phiếu lương nạp danh sách kỳ lương đã khóa chuẩn xác. Ba Modal popup tương tác chi tiết (👁️ Tăng ca, 👁️ Ngày nghỉ, 👁️ Đi trễ về sớm) render bảng số liệu chi tiết và đóng mở an toàn 100% không vỡ DOM. |

---

### TC-01: Kiểm tra kiểm soát ràng buộc và tạo đơn Xin bù công (Role: tai.dang)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `34.14s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Tạo và gửi đơn xin bù công thành công, xác thực CSDL đã lưu bản ghi IdentityID: 01A1A4E0-968F-7D0E-BC4F-9C1924459647 (Token: 535718)
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-01/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Nhan vien tai dang dang nhap he thong
![Bước 1: Nhan vien tai dang dang nhap he thong](TC-01/screenshots/TC-01-step01-nhan-vien-tai-dang-dang-nhap-he-thong.png)

##### 🔹 Bước 2: Mo menu Xin bu cong
![Bước 2: Mo menu Xin bu cong](TC-01/screenshots/TC-01-step02-mo-menu-xin-bu-cong.png)

##### 🔹 Bước 3: Dien thong tin ngay lam viec gio vao va ly do giai trinh
![Bước 3: Dien thong tin ngay lam viec gio vao va ly do giai trinh](TC-01/screenshots/TC-01-step03-dien-thong-tin-ngay-lam-viec-gio-vao-va-ly-do-giai-trinh.png)

##### 🔹 Bước 4: Popup Xac nhan dang ky hien thi yeu cau xac thuc
![Bước 4: Popup Xac nhan dang ky hien thi yeu cau xac thuc](TC-01/screenshots/TC-01-step04-popup-xac-nhan-dang-ky-hien-thi-yeu-cau-xac-thuc.png)

##### 🔹 Bước 5: Danh gia logic PASS: Don bu cong duoc luu vao CSDL thanh cong
![Bước 5: Danh gia logic PASS: Don bu cong duoc luu vao CSDL thanh cong](TC-01/screenshots/TC-01-step05-danh-gia-logic-pass-don-bu-cong-duoc-luu-vao-csdl-thanh-cong.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)

---

### TC-02: Nhân viên đối soát tab Lịch sử đơn bù công (Role: tai.dang)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `23.55s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Đơn bù công hiển thị chuẩn xác trong Tab Lịch sử với trạng thái "Đang chờ duyệt" (Khớp CSDL Approve_Status: 1)
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-02/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Nhan vien mo giao dien Xin bu cong
![Bước 1: Nhan vien mo giao dien Xin bu cong](TC-02/screenshots/TC-02-step01-nhan-vien-mo-giao-dien-xin-bu-cong.png)

##### 🔹 Bước 2: Di chuot Neon nhap tab Lich su
![Bước 2: Di chuot Neon nhap tab Lich su](TC-02/screenshots/TC-02-step02-di-chuot-neon-nhap-tab-lich-su.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)

---

### TC-03: Quản lý cấp duyệt thẩm định và duyệt đơn bù công 2 cấp (Role: ThanhLong & cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `61.83s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Quy trình phê duyệt liên hoàn 2 cấp (ThanhLong Cấp 1 -> cuong.vu Cấp 2) hoàn tất chuẩn xác, xác thực CSDL đã duyệt thành công
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-03/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Quan ly truc tiep ThanhLong dang nhap he thong
![Bước 1: Quan ly truc tiep ThanhLong dang nhap he thong](TC-03/screenshots/TC-03-step01-quan-ly-truc-tiep-thanhlong-dang-nhap-he-thong.png)

##### 🔹 Bước 2: ThanhLong mo man hinh Danh sach phe duyet
![Bước 2: ThanhLong mo man hinh Danh sach phe duyet](TC-03/screenshots/TC-03-step02-thanhlong-mo-man-hinh-danh-sach-phe-duyet.png)

##### 🔹 Bước 3: Cap 1 ThanhLong phe duyet don bu cong
![Bước 3: Cap 1 ThanhLong phe duyet don bu cong](TC-03/screenshots/TC-03-step03-cap-1-thanhlong-phe-duyet-don-bu-cong.png)

##### 🔹 Bước 4: Danh gia logic PASS: Don da duoc ca 2 cap phe duyet hoan tat
![Bước 4: Danh gia logic PASS: Don da duoc ca 2 cap phe duyet hoan tat](TC-03/screenshots/TC-03-step04-danh-gia-logic-pass-don-da-duoc-ca-2-cap-phe-duyet-hoan-tat.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-03/videos/video.webm)

---

### TC-04: Nhân sự C&B kiểm tra công ngày và tổng hợp công tháng (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `25.64s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Bảng công ngày hiển thị chính xác bản ghi công của nhân viên 046 (Khớp CSDL tblHasTA)
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-04/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Nhan su CB cuong vu dang nhap he thong
![Bước 1: Nhan su CB cuong vu dang nhap he thong](TC-04/screenshots/TC-04-step01-nhan-su-cb-cuong-vu-dang-nhap-he-thong.png)

##### 🔹 Bước 2: Mo bang cham cong hang ngay phan he TAD
![Bước 2: Mo bang cham cong hang ngay phan he TAD](TC-04/screenshots/TC-04-step02-mo-bang-cham-cong-hang-ngay-phan-he-tad.png)

##### 🔹 Bước 3: Loc thong tin cham cong cua nhan vien 046
![Bước 3: Loc thong tin cham cong cua nhan vien 046](TC-04/screenshots/TC-04-step03-loc-thong-tin-cham-cong-cua-nhan-vien-046.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-04/videos/video.webm)

---

### TC-05: Kế toán chạy tính toán lương tự động (Role: chien.nguyen)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `24.07s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Bảng lương công ty tổng hợp đầy đủ chỉ tiêu lương cho nhân viên 046 (Khớp CSDL tblSal_Sal)
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-05/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Ban giam doc chien nguyen dang nhap he thong
![Bước 1: Ban giam doc chien nguyen dang nhap he thong](TC-05/screenshots/TC-05-step01-ban-giam-doc-chien-nguyen-dang-nhap-he-thong.png)

##### 🔹 Bước 2: Mo bang tinh luong phan he PRL
![Bước 2: Mo bang tinh luong phan he PRL](TC-05/screenshots/TC-05-step02-mo-bang-tinh-luong-phan-he-prl.png)

##### 🔹 Bước 3: Kiem tra chi tieu luong cua nhan vien 046
![Bước 3: Kiem tra chi tieu luong cua nhan vien 046](TC-05/screenshots/TC-05-step03-kiem-tra-chi-tieu-luong-cua-nhan-vien-046.png)

##### 🔹 Bước 4: Danh gia logic PASS: Bang luong co mat nhan vien 046
![Bước 4: Danh gia logic PASS: Bang luong co mat nhan vien 046](TC-05/screenshots/TC-05-step04-danh-gia-logic-pass-bang-luong-co-mat-nhan-vien-046.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-05/videos/video.webm)

---

### TC-06: Kế toán thẩm định chốt chặn màn hình Khóa lương (Role: chien.nguyen)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `43.50s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Xác nhận kỳ lương Tháng 08/2026 đã được Khóa an toàn trong tblSal_Lock. Cổng chốt chặn Khóa lương hợp lệ, sẵn sàng phát hành Phiếu lương cá nhân ra Cổng thông tin nhân viên.
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-06/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Ke toan chien nguyen dang nhap he thong
![Bước 1: Ke toan chien nguyen dang nhap he thong](TC-06/screenshots/TC-06-step01-ke-toan-chien-nguyen-dang-nhap-he-thong.png)

##### 🔹 Bước 2: Mo man hinh Khoa luong kiem soat cong chot chan ky luong
![Bước 2: Mo man hinh Khoa luong kiem soat cong chot chan ky luong](TC-06/screenshots/TC-06-step02-mo-man-hinh-khoa-luong-kiem-soat-cong-chot-chan-ky-luong.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-06/videos/video.webm)

---

### TC-07: Nhân viên đối soát định lượng từng trường trên Phiếu lương cá nhân (Role: tai.dang)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `30.27s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Đối soát định lượng khớp 100% từng trường trên Phiếu lương (11/11 chỉ tiêu khớp CSDL). Kỳ lương: 08/2026, Giảm trừ gia cảnh: 0 VNĐ, Thực lĩnh: 0 VNĐ.

| STT | Trường chỉ tiêu trên Phiếu lương | Giá trị trên UI | Giá trị đối ứng trong CSDL | Trạng thái so khớp |
| :---: | :--- | :--- | :--- | :---: |
| 1 | Mã nhân viên (psEmpID) | 046 | 046 | ✅ KHỚP 100% |
| 2 | Họ và tên (psFullName) | Đặng Minh Tài | Đặng Minh Tài | ✅ KHỚP 100% |
| 3 | Ngày vào làm (psHireDate) | 15/07/2025 | 15/07/2025 | ✅ KHỚP 100% |
| 4 | Kỳ lương Tháng/Năm (psMonthYear) | Tháng/Năm: 08/2026 | 08/2026 | ✅ KHỚP 100% |
| 5 | Công chuẩn (psStdDays) | 23 ngày | 23 ngày | ✅ KHỚP 100% |
| 6 | Công thực tế (psActDays) | 23 ngày | 23 ngày | ✅ KHỚP 100% |
| 7 | Lương cơ bản (psBasicSalary) | 0 | 0 | ✅ KHỚP 100% |
| 8 | Người phụ thuộc (psDependents) | *(Trống)* | *(Trống)* | ✅ KHỚP 100% |
| 9 | Giảm trừ gia cảnh (psDepTax) | 0 | 0 | ✅ KHỚP 100% |
| 10 | Tổng thu nhập (psTotalIncome) | 0 | 0 | ✅ KHỚP 100% |
| 11 | Thực lĩnh / Lương thực nhận (psNetSalary) | 0 | 0 | ✅ KHỚP 100% |
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-07/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Nhan vien tai dang dang nhap he thong
![Bước 1: Nhan vien tai dang dang nhap he thong](TC-07/screenshots/TC-07-step01-nhan-vien-tai-dang-dang-nhap-he-thong.png)

##### 🔹 Bước 2: Giao dien phieu luong ca nhan day du cac truong chi tieu
![Bước 2: Giao dien phieu luong ca nhan day du cac truong chi tieu](TC-07/screenshots/TC-07-step02-giao-dien-phieu-luong-ca-nhan-day-du-cac-truong-chi-tieu.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-07/videos/video.webm)

---

### TC-08: Đối soát Tab Lịch sử phiếu lương và 3 Modal chi tiết Tăng ca, Ngày nghỉ, Đi trễ (Role: tai.dang)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `32.87s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Tab Lịch sử phiếu lương nạp danh sách kỳ lương đã khóa chuẩn xác. Ba Modal popup tương tác chi tiết (👁️ Tăng ca, 👁️ Ngày nghỉ, 👁️ Đi trễ về sớm) render bảng số liệu chi tiết và đóng mở an toàn 100% không vỡ DOM.
* **Thư mục lưu trữ**: `test-evidence/cham_cong_tinh_luong_toan_dien/TC-08/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Nhan vien mo giao dien Phieu luong ca nhan
![Bước 1: Nhan vien mo giao dien Phieu luong ca nhan](TC-08/screenshots/TC-08-step01-nhan-vien-mo-giao-dien-phieu-luong-ca-nhan.png)

##### 🔹 Bước 2: Chuyen sang Tab Lich su kiem tra danh sach ky luong da khoa
![Bước 2: Chuyen sang Tab Lich su kiem tra danh sach ky luong da khoa](TC-08/screenshots/TC-08-step02-chuyen-sang-tab-lich-su-kiem-tra-danh-sach-ky-luong-da-khoa.png)

##### 🔹 Bước 3: Modal Chi tiet Tang ca hien thi bang gio lam them
![Bước 3: Modal Chi tiet Tang ca hien thi bang gio lam them](TC-08/screenshots/TC-08-step03-modal-chi-tiet-tang-ca-hien-thi-bang-gio-lam-them.png)

##### 🔹 Bước 4: Modal Chi tiet Ngay nghi hien thi loai phep va gio nghi
![Bước 4: Modal Chi tiet Ngay nghi hien thi loai phep va gio nghi](TC-08/screenshots/TC-08-step04-modal-chi-tiet-ngay-nghi-hien-thi-loai-phep-va-gio-nghi.png)

##### 🔹 Bước 5: Modal Chi tiet Di tre ve som hien thi gio quet the va phut tru
![Bước 5: Modal Chi tiet Di tre ve som hien thi gio quet the va phut tru](TC-08/screenshots/TC-08-step05-modal-chi-tiet-di-tre-ve-som-hien-thi-gio-quet-the-va-phut-tru.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-08/videos/video.webm)

---

