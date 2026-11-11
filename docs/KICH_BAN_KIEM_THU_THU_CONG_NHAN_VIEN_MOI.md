# SỔ TAY HƯỚNG DẪN KIỂM THỬ THỦ CÔNG LIÊN HOÀN (MANUAL TESTING RUNBOOK)
## TOÀN TRÌNH TẠO MỚI NHÂN VIÊN ➔ CHẤM CÔNG ➔ DUYỆT ĐƠN ➔ TÍNH LƯƠNG & NGHIỆM THU PHIẾU LƯƠNG

> **DÀNH CHO**: Tester / Developer kiểm thử trực tiếp trên trình duyệt Web thật.  
> **MÔI TRƯỜNG TEST**: `https://paradisehrm.com/Tai3/#` (Login: `https://paradisehrm.com/Tai3/`)  
> **KỲ CÔNG & LƯƠNG TEST**: **Tháng 10/2026** (`10/2026`)  
> **MẬT KHẨU MẶC ĐỊNH CHO TẤT CẢ TÀI KHOẢN**: **`123`**  
> **MÃ NHÂN VIÊN MỚI THỬ NGHIỆM**: **`099`** *(hoặc mã mới bạn tự chọn: `098`, `NV99`...)*  
> **TÀI KHOẢN PORTAL NHÂN VIÊN MỚI**: **`test.nv`** / `123`

---

## 🧭 BẢN ĐỒ VAI TRÒ & TÀI KHOẢN SỬ DỤNG TRONG QUY TRÌNH

| Khâu | Vai trò (Role) | Tài khoản (`Username`) | Mật khẩu | Nhiệm vụ chính trong phiên test thủ công |
|:---:|:---|:---:|:---:|:---|
| **0** | **HR Admin / Giám đốc** | `cuong.vu` | `123` | Tạo hồ sơ NV mới 099, HĐLĐ lương 10tr, khai 1 NPT, gán ca HC, cấp user `test.nv`. |
| **1** | **Nhân viên mới (ESS)** | `test.nv` | `123` | Khảo sát Before ngày 15/10; Nộp 3 đơn: Bù công 15/10, Phép năm 24/10, Tăng ca 20/10. |
| **2** | **Quản lý Phép (Cấp 1)** | `ThanhLong` | `123` | Thẩm định và Bấm Duyệt Cấp 1 đơn Xin nghỉ phép năm AL ngày 24/10. |
| **3** | **Quản lý Tăng ca (Cấp 1)** | `LongKa` | `123` | Thẩm định và Bấm Duyệt Cấp 1 đơn Xin làm thêm giờ OT ngày 20/10. |
| **4** | **HR Admin / Giám đốc** | `cuong.vu` | `123` | Duyệt chặng cuối CẢ 2 ĐƠN + Bù công; Soi After: ngày 15/10 có công, tổng công đủ 23 ngày. |
| **5** | **Kế toán tiền lương** | `chien.nguyen` | `123` | Nạp thưởng KPI 1tr, nạp tạm ứng 2tr (Khóa phiếu), bấm Tính lương, bấm Khóa sổ Tháng 10. |
| **6** | **Nhân viên mới (ESS)** | `test.nv` | `123` | Mở Phiếu lương Tháng 10/2026: Đối soát 17 chỉ tiêu, bấm 3 modal con mắt 👁️ và xem Lịch sử. |

---

## 📋 GIAI ĐOẠN 0: KHỞI TẠO TIỀN ĐỀ HỒ SƠ NHÂN SỰ & TÀI KHOẢN (PRE-SEED SQL)

> [!NOTE]
> **THAY ĐỔI QUY TRÌNH (TIẾT KIỆM THỜI GIAN & CHỐNG BUG GIAO DIỆN MnuSCR608)**:  
> Màn hình Quản lý người dùng (`MnuSCR608`) hiện đang có bug lưu ghi đè tài khoản quản trị và đang được dev phụ trách xử lý riêng.  
> Để không bị nghẽn tiến độ, **Hồ sơ nhân viên 099** và **Tài khoản ESS Portal `test.nv` / `123`** được **insert thẳng vào CSDL bằng SQL Script**, không cần thực hiện trên giao diện Web!

### ▫️ Bước 0.1: Chạy Script SQL tạo Hồ sơ & Tài khoản test.nv trên SSMS
- [ ] Mở SQL Server Management Studio (SSMS), kết nối Database đang test (ví dụ: `Vietinsoft_ForTest3` hoặc `Vietinsoft_ForTest_Tai2`).
- [ ] Mở file [`scripts/seed_test_employee_099.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/seed_test_employee_099.sql) hoặc copy đoạn script sau và bấm **`F5`**:

```sql
-- Khởi tạo Hồ sơ NV 099 và cấp tài khoản test.nv / 123
UPDATE tblSC_Login SET LoginName = 'cuong.vu', PassWord = '123', IsDisable = 0 WHERE EmployeeID = '014';
UPDATE tblSC_Login SET LoginName = 'chien.nguyen', PassWord = '123', IsDisable = 0 WHERE EmployeeID = '013';

IF NOT EXISTS (SELECT 1 FROM tblEmployee WHERE EmployeeID = '099')
    INSERT INTO tblEmployee (EmployeeID, FullName, HireDate, Birthday, Sex, ID_Number)
    VALUES ('099', N'Nguyễn Văn Test', '2026-10-01', '1995-05-15', 1, '079099888999');

IF NOT EXISTS (SELECT 1 FROM tblDivDepSecPos WHERE EmployeeID = '099')
    INSERT INTO tblDivDepSecPos (EmployeeID, DivisionID, DepartmentID, ChangedDate)
    VALUES ('099', 1, 3, '2026-10-01');

DELETE FROM tblSC_Right_Stored WHERE LoginID IN (SELECT LoginID FROM tblSC_Login WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014'));
DELETE FROM tblSC_Login WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014');

INSERT INTO tblSC_Login (LoginName, PassWord, EmployeeID, ParentLoginID, UseGroupRightOnly, NeedEncryptPassWordColumnList, IsDisable, IsGroup)
VALUES ('test.nv', '123', '099', '9', 1, 'PassWord', 0, 0);

INSERT INTO tblSC_Right_Stored (ObjectID, LoginID, FullAccess)
SELECT 70, LoginID, 32 FROM tblSC_Login WHERE LoginName = 'test.nv';
```
- [ ] Kết quả kiểm tra hiển thị dòng: `EmployeeID: 099`, `FullName: Nguyễn Văn Test`, `LoginName: test.nv` $\rightarrow$ Sẵn sàng 100%!

### ▫️ Bước 0.2: Đăng nhập HR Admin trên Web
- [ ] Mở trình duyệt Chrome, vào đường link: `https://paradisehrm.com/Tai3/` (hoặc `https://paradisehrm.com/Tai2/`, `https://paradisehrm.com/Vietinsoft_ForTest3/`)
- [ ] Nhập Tên đăng nhập: `cuong.vu` | Mật khẩu: `123` $\rightarrow$ Bấm **Đăng nhập**.

### ▫️ Bước 0.3: Thiết lập HĐLĐ & Mức lương 10,000,000 VNĐ (`MnuHRS145`)
- [ ] Nhìn lên thanh Dock ngang: Nhấp vào **Icon thứ 2 (Hình chiếc thẻ ID / Quản trị nhân sự `MnuHRS000`)**.
- [ ] Tại menu bên trái, nhấp chọn menu **`Lương nhân viên`** (Mã `MnuHRS145`).
- [ ] Tại ô tìm kiếm của lưới lương: Gõ `099`.
- [ ] Nhấp đúp chuột (**Double click**) vào dòng nhân viên `099 - Nguyễn Văn Test` để mở popup chi tiết.
- [ ] Nhập thông số lương:
  * **Lương cơ bản**: Nhập `10000000` *(Mười triệu đồng)*
  * **Lương đóng BHXH**: Nhập `10000000`
  * **Ngày hiệu lực**: Chọn `01/10/2026`
- [ ] Nhấp nút **Lưu** $\rightarrow$ Đóng popup.

### ▫️ Bước 0.4: Khai báo 1 Người phụ thuộc giảm trừ gia cảnh (`MnuHRS157`)
- [ ] Tại menu bên trái, chọn **`Thông tin gia đình`** (Mã `MnuHRS157`).
- [ ] Nhấp nút **`+ Thêm mới`** trên toolbar:
  * **Mã nhân viên**: Nhấp vào ô để mở popup "Chọn nhân viên" $\rightarrow$ Gõ **`Test`** vào ô tìm kiếm `🔍` $\rightarrow$ Chọn dòng **`099 - Nguyễn Văn Test`** *(Do đã có tài khoản test.nv trong CSDL nên dòng 099 sẽ hiển thị ngay lập tức)* $\rightarrow$ Bấm **Lưu** trên popup.
  * **Họ và tên người thân**: `Nguyễn Minh Khang`
  * **Quan hệ**: Chọn `Con`
  * **Ngày sinh**: `15/05/2024`
  * **Mã số thuế / Giấy khai sinh**: `8639998888` *(Gõ 10 số tượng trưng để hợp lệ form)*
  * **Người phụ thuộc thuế**: **TÍCH CHỌN VÀO Ô VUÔNG CÓ / YES** *(Rất quan trọng!)*
  * **Từ ngày hiệu lực**: `01/10/2026`
- [ ] Nhấp nút **Lưu** form Thông tin gia đình.
- [ ] Nhấp nút tab **`Người Phụ Thuộc (NPT)`** trên đỉnh màn hình để thấy hồ sơ cháu Khang được ghi nhận giảm trừ `4,400,000 đ/tháng`.

### ▫️ Bước 0.5: Phân Ca làm việc hành chính chuẩn Tháng 10 (`MnuTAD020`)
- [ ] Nhìn lên thanh Dock: Nhấp vào **Icon thứ 3 (Hình chiếc đồng hồ - Quản lý chấm công `MnuTAD000`)**.
- [ ] Trên sidebar bên trái: Nhấp chọn menu **`Lịch làm việc / Phân ca`** (Mã `MnuTAD020`).
- [ ] Chọn Tháng: `10` | Năm: `2026`.
- [ ] Tìm nhân viên `099` $\rightarrow$ Gán Ca hành chính chuẩn (`HC`: 08:00 - 17:00, 8h/ngày) cho toàn bộ các ngày làm việc Thứ 2 - Thứ 6 trong Tháng 10/2026 $\rightarrow$ Bấm **Lưu / Áp dụng**.

### ▫️ Bước 0.6: Đăng xuất tài khoản HR Admin
- [ ] Nhấp vào ảnh đại diện góc trên cùng bên phải $\rightarrow$ Chọn **Đăng xuất**. Hoàn tất trọn vẹn Giai đoạn 0!

---

## 📋 GIAI ĐOẠN 1: NHÂN VIÊN MỚI KHẢO SÁT BEFORE & GỬI 3 ĐƠN
> **Người thực hiện**: Đăng nhập tài khoản **`test.nv`** / **`123`**

### ▫️ Bước 1.1: Đăng nhập tài khoản Nhân viên mới
- [ ] Tại màn hình đăng nhập: Nhập `test.nv` | Mật khẩu: `123` $\rightarrow$ Bấm **Đăng nhập**.
- [ ] Giao diện Portal nhân viên hiển thị với tên `Nguyễn Văn Test`.

### ▫️ Bước 1.2: Ghi nhận hiện trạng ban đầu (LÚC TRƯỚC - BEFORE)
- [ ] Nhấp icon chiếc đồng hồ trên Dock $\rightarrow$ Mở menu **`Xem dữ liệu chấm công hằng ngày` (`MnuHRS225`)**:
  * Chọn Từ ngày: `01/10/2026` | Đến ngày: `31/10/2026`.
  * Soi dòng ngày **`15/10/2026`**:
    - `GIỜ VÀO`: Đang là **`[--:--]`** (trống).
    - `GIỜ RA`: Đang là **`[--:--]`**.
    - `TRẠNG THÁI`: Báo **`Thiếu giờ quẹt / Không có dữ liệu`**.
    - `CÔNG NGÀY`: Đang là **`0.0 công`** ($0\text{ giờ}$).
- [ ] Mở menu **`Tổng hợp công cả tháng` (`MnuTAD1000`)**:
  * Chọn Tháng `10`, Năm `2026`:
  * Ghi nhận: Cột `CÔNG CHUẨN` = `23 ngày`, nhưng `NGÀY CÔNG THỰC TẾ` = **`21 ngày`** *(Bị thiếu mất 2 ngày công!)*.

### ▫️ Bước 1.3: Nộp Đơn xin bù công ngày 15/10/2026 (`MnuHRS033`)
- [ ] Nhấp icon đầu tiên trên Dock (**Cổng thông tin nhân viên `MnuWPT000`**).
- [ ] Chọn menu **`Xin bù công`** (Mã `MnuHRS033`).
- [ ] Điền form bù công:
  * **Ngày bù công**: Chọn `15/10/2026`
  * **Loại bù công**: Chọn `Quên quẹt thẻ vào đầu ca`
  * **Giờ bổ sung thực tế**: Nhập `08:00`
  * **Lý do**: Nhập `Quên quẹt thẻ sáng do tiếp khách sảnh`
- [ ] Bấm nút **Lưu** / **Gửi đơn**.
- [ ] Nếu có popup xác nhận: Bấm **Đồng ý**.
- [ ] Bấm chuyển sang tab **Lịch sử**: Thẻ đơn 15/10 xuất hiện đầu danh sách với trạng thái **`Chờ duyệt`** (Màu vàng).

### ▫️ Bước 1.4: Nộp Đơn xin nghỉ phép năm AL ngày 24/10/2026 (`MnuWPT315`)
- [ ] Tại menu bên trái, chọn **`Xin nghỉ phép`** (Mã `MnuWPT315`).
- [ ] Điền form xin nghỉ phép:
  * **Loại phép**: Chọn `Phép năm (AL)`
  * **Từ ngày**: `24/10/2026` (08:00) | **Đến ngày**: `24/10/2026` (17:00)
  * **Số ngày nghỉ**: Hệ thống tự nhảy `1 ngày`
  * **Lý do**: Nhập `Giải quyết việc cá nhân gia đình`
- [ ] Bấm nút **Gửi đơn** $\rightarrow$ Chờ thông báo thành công. Đơn vào trạng thái **`Chờ duyệt`**.

### ▫️ Bước 1.5: Nộp Đơn xin tăng ca OT 2.0h ngày 20/10/2026 (`MnuWPT316`)
- [ ] Tại menu bên trái, chọn **`Xin tăng ca`** (Mã `MnuWPT316`).
- [ ] Điền form xin tăng ca:
  * **Ngày tăng ca**: Chọn `20/10/2026`
  * **Từ giờ**: `18:00` | **Đến giờ**: `20:00`
  * **Tổng số giờ**: Tự nhảy `2.0 giờ`
  * **Lý do**: Nhập `Làm thêm giờ hoàn thiện tính năng release`
- [ ] Bấm nút **Gửi đơn** $\rightarrow$ Thông báo thành công, trạng thái **`Chờ duyệt`**.
- [ ] **Đăng xuất** tài khoản `test.nv`.

---

## 📋 GIAI ĐOẠN 2: PHÊ DUYỆT ĐA CẤP PHÂN QUYỀN

### ▫️ Bước 2.1: Quản lý `ThanhLong` duyệt Cấp 1 đơn Nghỉ phép AL
- [ ] Đăng nhập tài khoản: **`ThanhLong`** / **`123`**.
- [ ] Mở menu **`Danh sách phê duyệt`** (`MnuWPT037`) trên sidebar.
- [ ] Chọn tab hoặc lọc loại đơn **Nghỉ phép**:
  * Tìm dòng của nhân viên `099 - Nguyễn Văn Test` (Nghỉ phép AL ngày 24/10).
  * Nhấp nút **Duyệt** $\rightarrow$ Xác nhận duyệt Cấp 1 thành công.
- [ ] **Đăng xuất** tài khoản `ThanhLong`.

### ▫️ Bước 2.2: Quản lý `LongKa` duyệt Cấp 1 đơn Tăng ca OT
- [ ] Đăng nhập tài khoản: **`LongKa`** / **`123`**.
- [ ] Mở menu **`Danh sách phê duyệt`** (`MnuWPT037`).
- [ ] Chọn tab hoặc lọc loại đơn **Tăng ca / Làm thêm giờ**:
  * Tìm dòng của nhân viên `099 - Nguyễn Văn Test` (Tăng ca 2.0h ngày 20/10).
  * Nhấp nút **Duyệt** $\rightarrow$ Xác nhận duyệt Cấp 1 thành công.
- [ ] **Đăng xuất** tài khoản `LongKa`.

### ▫️ Bước 2.3: Giám đốc `cuong.vu` duyệt Chặng cuối CẢ 2 ĐƠN + Bù công
- [ ] Đăng nhập tài khoản: **`cuong.vu`** / **`123`**.
- [ ] Mở menu **`Danh sách phê duyệt`** (`MnuWPT037`).
- [ ] Lọc tìm nhân viên `099`, lần lượt duyệt hoàn tất cả 3 đơn:
  * **Đơn nghỉ phép 24/10**: Bấm **Duyệt** (Trạng thái chuyển sang `Approved = 1` / Màu xanh lá).
  * **Đơn tăng ca 20/10**: Bấm **Duyệt** (`Approved = 1`).
  * **Đơn bù công 15/10**: Bấm **Duyệt** (`Approved = 1`).

### ▫️ Bước 2.4: Kiểm tra chốt chặn LÚC SAU (AFTER CHECK)
- [ ] Mở menu **`Xem dữ liệu chấm công hằng ngày` (`MnuHRS225`)**, lọc ngày 15/10 của `099`:
  * Cột `GIỜ VÀO`: Đã nhảy từ `[--:--]` $\rightarrow$ **`08:00`**!
  * Cột `CÔNG NGÀY`: Đã nhảy từ `0.0` $\rightarrow$ **`8.0 giờ (1.0 công)`**!
  * Cột `TRẠNG THÁI`: Đã đổi sang **`Hợp lệ / Có chấm công`**!
  * Cột `SỐ LẦN ĐI TRỄ`: Báo **`0`** (không bị phạt tiền)!
- [ ] Mở menu **`Tổng hợp công cả tháng` (`MnuTAD1000`)**, lọc tháng 10 của `099`:
  * Cột `NGÀY CÔNG THỰC TẾ`: Đã nhảy từ `21.0` $\rightarrow$ **`23.0 ngày`** (tăng đúng $+2.0\text{ ngày}$ gồm $+1.0\text{ ngày}$ bù công và $+1.0\text{ ngày}$ phép năm AL)!
  * Cột `NGHỈ HƯỞNG LƯƠNG`: Hiển thị `1` ngày.
  * Cột `TĂNG CA 150%`: Hiển thị `2.0` giờ.
- [ ] **Đăng xuất** tài khoản `cuong.vu`.

---

## 📋 GIAI ĐOẠN 3: KẾ TOÁN NẠP TÀI CHÍNH, TÍNH LƯƠNG & KHÓA SỔ
> **Người thực hiện**: Đăng nhập tài khoản **`chien.nguyen`** / **`123`**

### ▫️ Bước 3.1: Nạp Thưởng KPI 1,000,000 VNĐ (`MnuPRL036`)
- [ ] Đăng nhập tài khoản: `chien.nguyen` / `123`.
- [ ] Nhấp biểu tượng chiếc cặp tiền trên Dock (**Quản lý tiền lương `MnuPRL000`**).
- [ ] Mở menu **`Thu nhập không cố định`** (Mã `MnuPRL036`).
- [ ] Nhấp nút **`+ Thêm mới`**:
  * **Nhân viên**: Chọn `099 - Nguyễn Văn Test`
  * **Kỳ lương**: Chọn Tháng `10`, Năm `2026`
  * **Khoản thu nhập**: Chọn `Thưởng KPI / Hiệu quả công việc`
  * **Số tiền**: Nhập `1000000` *(Một triệu đồng)*
- [ ] Bấm nút **Lưu** $\rightarrow$ Dòng thưởng KPI xuất hiện trên lưới.

### ▫️ Bước 3.2: Nạp & Khóa khoản Tạm ứng lương 2,000,000 VNĐ (`MnuPRL070`)
- [ ] Tại menu bên trái, mở **`Tạm ứng lương`** (Mã `MnuPRL070`).
- [ ] Nhấp nút **`+ Thêm mới`**:
  * **Nhân viên**: Chọn `099 - Nguyễn Văn Test`
  * **Ngày tạm ứng**: Chọn `18/10/2026`
  * **Số tiền ứng**: Nhập `2000000` *(Hai triệu đồng)*
  * **Lý do**: Nhập `Tạm ứng sinh hoạt cá nhân`
- [ ] **THAO TÁC QUYẾT ĐỊNH**: **Tích chọn vào ô Khóa (`isLock`)** hoặc bấm **Duyệt & Khóa phiếu**!
- [ ] Bấm nút **Lưu** $\rightarrow$ Dòng tạm ứng hiển thị với trạng thái đã khóa.

### ▫️ Bước 3.3: Kích hoạt Tính tiền lương tự động toàn công ty (`MnuPRL040`)
- [ ] Tại menu bên trái, mở **`Tính tiền lương`** (Mã `MnuPRL040`).
- [ ] Thiết lập: Chọn Tháng `10` | Chọn Năm `2026`.
- [ ] Nhấp nút **`Tính lương`** (`#btnCalculate` trên toolbar).
- [ ] Chờ hệ thống thực thi trong 3–5 giây. Lưới hiển thị *"Không có dữ liệu"* là bình thường (do hệ thống kết thúc bằng `print 'eof'`).

### ▫️ Bước 3.4: Khóa sổ kỳ lương Tháng 10/2026 (`MnuPRL080`)
> *Đây là bước bắt buộc để mở khóa cho nhân viên mới nhìn thấy Tháng 10/2026 trên Phiếu lương cá nhân!*
- [ ] Tại menu bên trái, mở **`Mở/Khóa Lương`** (Mã `MnuPRL080`).
- [ ] Chọn Tháng: `10` | Năm: `2026`.
- [ ] Nhấp nút **`Khóa lương`** (`#btnLockSalary`).
- [ ] Popup xác nhận hiện ra $\rightarrow$ Bấm **Đồng ý / OK**.
- [ ] Trạng thái kỳ lương chuyển sang **Đã khóa**.
- [ ] **Đăng xuất** tài khoản `chien.nguyen`.

---

## 📋 GIAI ĐOẠN 4: NHÂN VIÊN MỚI NGHIỆM THU PHIẾU LƯƠNG CHÍNH THỨC
> **Người thực hiện**: Đăng nhập tài khoản **`test.nv`** / **`123`**

### ▫️ Bước 4.1: Đăng nhập tài khoản Nhân viên mới
- [ ] Đăng nhập: `test.nv` / `123`.

### ▫️ Bước 4.2: Mở Phiếu lương cá nhân (`MnuPRL445`)
- [ ] Nhấp icon đầu tiên trên Dock (**Cổng thông tin nhân viên `MnuWPT000`**).
- [ ] Nhấp chọn menu **`Phiếu lương cá nhân`** (Mã `MnuPRL445`).
- [ ] **Kiểm tra mốc thời gian**: Ô `Tháng/Năm` tự động hiển thị **`10/2026`**!

### ▫️ Bước 4.3: Đối soát định lượng đủ 17 chỉ tiêu toán học
Hãy dùng bút hoặc tích chọn từng dòng để so khớp trực tiếp trên màn hình:

- [ ] **1. Lương cơ bản hợp đồng**: Hiển thị **`10,000,000 đ`**
- [ ] **2. Lương đóng BHXH**: Hiển thị **`10,000,000 đ`**
- [ ] **3. Ngày công chuẩn**: Hiển thị **`23.0 ngày`**
- [ ] **4. Ngày công thực tế**: Hiển thị **`23.0 ngày`** *(Đạt 100% nhờ bù công 15/10)*
- [ ] **5. Số giờ làm thêm (OT)**: Hiển thị **`2.0 giờ`**
- [ ] **6. Tiền làm thêm giờ (OT 150%)**: Hiển thị **`+ 163,043 đ`**
  $$\left(\frac{10,000,000}{23 \times 8} \times 2.0 \times 1.5 = 163,043.48\text{ VNĐ}\right)$$
- [ ] **7. Ngày nghỉ hưởng lương**: Hiển thị **`1.0 ngày`** *(Phép năm AL 24/10)*
- [ ] **8. Thưởng KPI / Thu nhập khác**: Hiển thị **`+ 1,000,000 đ`**
- [ ] **9. Phạt đi trễ / về sớm**: Hiển thị **`0 đ`** *(Đã giải trình xóa phạt)*
- [ ] **10. Giảm trừ bản thân**: Hiển thị **`- 11,000,000 đ`**
- [ ] **11. Giảm trừ Người phụ thuộc (1 con)**: Hiển thị **`- 4,400,000 đ`**
- [ ] **12. Trừ BHXH (8%)**: Hiển thị **`- 800,000 đ`** $(10,000,000 \times 8\%)$
- [ ] **13. Trừ BHYT (1.5%)**: Hiển thị **`- 150,000 đ`** $(10,000,000 \times 1.5\%)$
- [ ] **14. Trừ BHTN (1%)**: Hiển thị **`- 100,000 đ`** $(10,000,000 \times 1\%)$
- [ ] **15. Thuế TNCN phát sinh**: Hiển thị **`0 đ`** *(Do tổng giảm trừ 15.4tr lớn hơn thu nhập)*
- [ ] **16. Khấu trừ Tạm ứng lương**: Hiển thị **`- 2,000,000 đ`**
- [ ] **17. LƯƠNG THỰC LĨNH CHUYỂN KHOẢN**:
  $$\text{Thực lĩnh} = (10,000,000 + 163,043 + 1,000,000) - (1,050,000 + 2,000,000) = \mathbf{8,113,043\text{ VNĐ}}$$

### ▫️ Bước 4.4: Bấm kiểm tra 3 Modal con mắt 👁️ và Tab Lịch sử
- [ ] Nhấp icon con mắt 👁️ cạnh **Tăng ca**: Popup `#psModalOvertime` mở ra, thấy chi tiết ngày 20/10 làm thêm 2.0 giờ $\rightarrow$ Bấm nút Đóng (x).
- [ ] Nhấp icon con mắt 👁️ cạnh **Ngày nghỉ**: Popup `#psModalDaysoff` mở ra, thấy chi tiết ngày 24/10 nghỉ phép năm AL $\rightarrow$ Bấm nút Đóng (x).
- [ ] Nhấp icon con mắt 👁️ cạnh **Đi trễ / Về sớm**: Popup `#psModalLateearly` mở ra, hiển thị bảng vi phạm trống sạch sẽ (0 phút vi phạm) $\rightarrow$ Bấm nút Đóng (x).
- [ ] Nhấp chuyển sang tab **Lịch Sử**: Dòng trên cùng hiển thị Tháng `10/2026` với biểu tượng ổ khóa niêm phong.

---

## 🏆 KẾT LUẬN NGHIỆM THU
Nếu bạn thực hiện đầy đủ các bước trên và toàn bộ 17 chỉ tiêu cùng 3 Modal con mắt hiển thị đúng chuẩn, quy trình tính lương liên hoàn cho nhân viên mới đạt chuẩn **100% ZERO-BUG / PASS HOÀN TOÀN**!
