# BÁO CÁO KIỂM THỬ TRANG: QUY_TRINH_TINH_LUONG_NV_MOI

> Thời gian kiểm thử: **12:05:49 9/11/2026**
> Tổng số kịch bản: **13** | ✅ LOGIC PASS: **13** | ❌ LOGIC FAIL: **0**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | fix-4 | TC-01: Tạo mới hồ sơ nhân viên Nguyễn Văn Test (Role: cuong.vu) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-02** | fix-4 | TC-02: Thiết lập HĐLĐ và Mức lương 10,000,000 VNĐ (Role: cuong.vu) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-03** | fix-4 | TC-03: Đăng ký 1 Người phụ thuộc giảm trừ gia cảnh (Role: cuong.vu) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-04** | fix-4 | TC-04: Phân ca làm việc hành chính chuẩn cho NV 099 (Role: cuong.vu) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-05** | fix-4 | TC-05: Cấp tài khoản đăng nhập ESS Portal test.nv (Role: cuong.vu) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-10** | fix-6 | TC-10: Quản lý ThanhLong phê duyệt Cấp 1 đơn Nghỉ phép AL 24/10 (Role: ThanhLong) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-11** | fix-6 | TC-11: Quản lý LongKa phê duyệt Cấp 1 đơn Tăng ca OT 20/10 (Role: LongKa) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-12** | fix-6 | TC-12: Giám đốc cuong.vu phê duyệt chặng cuối CẢ 2 ĐƠN + Đơn bù công 15/10 (Role: cuong.vu) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-13** | fix-6 | TC-13: Đối soát chốt chặn Delta After công ngày 15/10 và tổng công tháng (Role: cuong.vu) | ✅ PASS | ✅ PASS | Đạt yêu cầu logic nghiệp vụ mong đợi |
| **TC-14** | fix-7 | TC-14: Kế toán chien.nguyen nạp Thưởng KPI 1,000,000 VNĐ Tháng 10/2026 (Role: chien.nguyen) | ✅ PASS | ✅ PASS | PASS - Kế toán trưởng chien.nguyen đã nạp Thưởng KPI 1.000.000 VNĐ cho nhân viên 099 trong kỳ Tháng 10/2026 trên MnuPRL036 (tblSal_Adjustment). |
| **TC-15** | fix-7 | TC-15: Kế toán chien.nguyen nạp Tạm ứng lương 2,000,000 VNĐ và Khóa phiếu (Role: chien.nguyen) | ✅ PASS | ✅ PASS | PASS - Kế toán trưởng chien.nguyen đã nạp Tạm ứng 2.000.000 VNĐ và Khóa phiếu (IsLock = TRUE) cho nhân viên 099 trong kỳ Tháng 10/2026 trên MnuPRL070. |
| **TC-16** | fix-7 | TC-16: Kế toán kích hoạt Tính tiền lương tự động toàn công ty (Role: chien.nguyen) | ✅ PASS | ✅ PASS | PASS - Thủ tục tính lương tự động SALCAL_MAIN Tháng 10/2026 đã được kích hoạt thành công trên MnuPRL040. CSDL tblSal_Sal đã ghi nhận Lương cơ bản = 10.000.000 VNĐ cho nhân viên 099. |
| **TC-17** | fix-7 | TC-17: Kế toán thực hiện Khóa sổ kỳ lương Tháng 10/2026 (Role: chien.nguyen) | ✅ PASS | ✅ PASS | PASS - Kỳ lương Tháng 10/2026 đã được niêm phong thành công trong tblSal_Lock (LockCount >= 1). Hoàn tất bàn giao cho fix-8 nghiệm thu Phiếu lương! |

---

### TC-01: fix-4 | TC-01: Tạo mới hồ sơ nhân viên Nguyễn Văn Test (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `31.96s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-01/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)

---

### TC-02: fix-4 | TC-02: Thiết lập HĐLĐ và Mức lương 10,000,000 VNĐ (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `30.15s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-02/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)

---

### TC-03: fix-4 | TC-03: Đăng ký 1 Người phụ thuộc giảm trừ gia cảnh (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `21.41s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-03/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-03/videos/video.webm)

---

### TC-04: fix-4 | TC-04: Phân ca làm việc hành chính chuẩn cho NV 099 (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `18.70s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-04/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-04/videos/video.webm)

---

### TC-05: fix-4 | TC-05: Cấp tài khoản đăng nhập ESS Portal test.nv (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `19.83s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-05/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-05/videos/video.webm)

---

### TC-10: fix-6 | TC-10: Quản lý ThanhLong phê duyệt Cấp 1 đơn Nghỉ phép AL 24/10 (Role: ThanhLong)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `40.79s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-10/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-10/videos/video.webm)

---

### TC-11: fix-6 | TC-11: Quản lý LongKa phê duyệt Cấp 1 đơn Tăng ca OT 20/10 (Role: LongKa)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `41.67s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-11/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-11/videos/video.webm)

---

### TC-12: fix-6 | TC-12: Giám đốc cuong.vu phê duyệt chặng cuối CẢ 2 ĐƠN + Đơn bù công 15/10 (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `17.28s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-12/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-12/videos/video.webm)

---

### TC-13: fix-6 | TC-13: Đối soát chốt chặn Delta After công ngày 15/10 và tổng công tháng (Role: cuong.vu)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `29.51s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Đạt yêu cầu logic nghiệp vụ mong đợi
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-13/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-13/videos/video.webm)

---

### TC-14: fix-7 | TC-14: Kế toán chien.nguyen nạp Thưởng KPI 1,000,000 VNĐ Tháng 10/2026 (Role: chien.nguyen)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `30.90s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Kế toán trưởng chien.nguyen đã nạp Thưởng KPI 1.000.000 VNĐ cho nhân viên 099 trong kỳ Tháng 10/2026 trên MnuPRL036 (tblSal_Adjustment).
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-14/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Dang nhap tai khoan ke toan truong chien nguyen
![Bước 1: Dang nhap tai khoan ke toan truong chien nguyen](TC-14/screenshots/TC-14-step01-dang-nhap-tai-khoan-ke-toan-truong-chien-nguyen.png)

##### 🔹 Bước 2: Man hinh thu nhap khong co dinh mnuprl036 thang 10 2026
![Bước 2: Man hinh thu nhap khong co dinh mnuprl036 thang 10 2026](TC-14/screenshots/TC-14-step02-man-hinh-thu-nhap-khong-co-dinh-mnuprl036-thang-10-2026.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-14/videos/video.webm)

---

### TC-15: fix-7 | TC-15: Kế toán chien.nguyen nạp Tạm ứng lương 2,000,000 VNĐ và Khóa phiếu (Role: chien.nguyen)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `29.08s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Kế toán trưởng chien.nguyen đã nạp Tạm ứng 2.000.000 VNĐ và Khóa phiếu (IsLock = TRUE) cho nhân viên 099 trong kỳ Tháng 10/2026 trên MnuPRL070.
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-15/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Man hinh tam ung luong mnuprl070 thang 10 2026
![Bước 1: Man hinh tam ung luong mnuprl070 thang 10 2026](TC-15/screenshots/TC-15-step01-man-hinh-tam-ung-luong-mnuprl070-thang-10-2026.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-15/videos/video.webm)

---

### TC-16: fix-7 | TC-16: Kế toán kích hoạt Tính tiền lương tự động toàn công ty (Role: chien.nguyen)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `28.11s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Thủ tục tính lương tự động SALCAL_MAIN Tháng 10/2026 đã được kích hoạt thành công trên MnuPRL040. CSDL tblSal_Sal đã ghi nhận Lương cơ bản = 10.000.000 VNĐ cho nhân viên 099.
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-16/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Truoc khi nhap tinh tien luong mnuprl040
![Bước 1: Truoc khi nhap tinh tien luong mnuprl040](TC-16/screenshots/TC-16-step01-truoc-khi-nhap-tinh-tien-luong-mnuprl040.png)

##### 🔹 Bước 2: Hoan tat tinh tien luong mnuprl040
> *(Giao diện giữ nguyên, không phát sinh thay đổi so với Bước 1)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-16/videos/video.webm)

---

### TC-17: fix-7 | TC-17: Kế toán thực hiện Khóa sổ kỳ lương Tháng 10/2026 (Role: chien.nguyen)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `28.78s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Kỳ lương Tháng 10/2026 đã được niêm phong thành công trong tblSal_Lock (LockCount >= 1). Hoàn tất bàn giao cho fix-8 nghiệm thu Phiếu lương!
* **Thư mục lưu trữ**: `test-evidence/quy_trinh_tinh_luong_nv_moi/TC-17/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Truoc khi khoa luong thang 10 2026 tai mnuprl080
![Bước 1: Truoc khi khoa luong thang 10 2026 tai mnuprl080](TC-17/screenshots/TC-17-step01-truoc-khi-khoa-luong-thang-10-2026-tai-mnuprl080.png)

##### 🔹 Bước 2: Sau khi khoa luong thang 10 2026 tai mnuprl080
> *(Giao diện giữ nguyên, không phát sinh thay đổi so với Bước 1)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):

---

