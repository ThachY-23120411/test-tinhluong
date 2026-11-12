# KỊCH BẢN KIỂM THỬ THỦ CÔNG & QUAY RECORDING (MANUAL TEST SCRIPT) - PHÂN VÙNG FIX-7
> **DỰ ÁN**: Flow liên hoàn tính lương nhân viên mới `099 - Nguyễn Văn Test` (E2E New Employee Payroll)  
> **TIỀN ĐỀ BẮT BUỘC**: Đã hoàn tất quy trình của **`fix-5`** ([`kb_fix5.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/kb_fix5.md)) và **`fix-6`** ([`kb-fix6.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/kb-fix6.md))  
> **VAI TRÒ THỰC HIỆN**: Kế toán trưởng **`chien.nguyen`** / **`123`** (EmployeeID: `013`, LoginID: `22`)  
> **DANH SÁCH TEST CASE**: `TC-14`, `TC-15`, `TC-16`, `TC-17`  
> **MÔI TRƯỜNG KIỂM THỬ**: Google Chrome — Web Paradise HRM: `https://paradisehrm.com/Tai3/#`  
> **CƠ SỞ DỮ LIỆU**: `Vietinsoft_ForTest_Tai2` (SQL Server)  
> **MỤC TIÊU KÉP**:
> 1. Hướng dẫn từng bước thao tác tay trên giao diện Web thật để test thủ công và bật **Chrome F12 Recorder** xuất file `.json`.
> 2. Gửi file `.json` cho Agent chuyển đổi thành kịch bản Playwright mô phỏng người thật + script `.sql` reset + file `.bat` 1-Click theo **Điều 9 `AGENTS.md`** ([`recorder-json-replay/SKILL.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/.agents/skills/recorder-json-replay/SKILL.md)).

---

## 📌 1. BỨC TRANH DỮ LIỆU ĐẦU VÀO KẾ THỪA TỪ `FIX-4`, `FIX-5` & `FIX-6`

Trước khi Kế toán trưởng **`chien.nguyen`** thực hiện các thao tác tài chính và tính lương tại **`fix-7`**, hồ sơ nhân viên `099 - Nguyễn Văn Test` đã tích lũy đầy đủ dữ liệu từ 3 giai đoạn trước:

| Nguồn | Thành phần dữ liệu của NV `099` (Kỳ Tháng 10/2026: `10/10–09/11/2026`) | Trạng thái / Giá trị thực tế |
| :--- | :--- | :--- |
| **`fix-4`** | **Hợp đồng & Lương cơ bản** (`tblSalaryHistory`) | Lương cơ bản: **`10,000,000 VNĐ`** \| Lương đóng BHXH: **`10,000,000 VNĐ`** |
| **`fix-4`** | **Người phụ thuộc** (`tblFamilyInfo`) | **`1` người phụ thuộc** (*Nguyễn Minh Khang*, giảm trừ `4,400,000 VNĐ`) + Bản thân `11,000,000 VNĐ` |
| **`fix-5` + `fix-6`** | **Ngày 12/10 & 13/10** (Thứ Hai, Thứ Ba) | Chấm công `08:00 - 17:00` $\rightarrow$ **`8.0h`** / ngày (`1.0` công chuẩn x 2 = **`2.0 công`**) |
| **`fix-5` + `fix-6`** | **Ngày 14/10** (Thứ Tư — *NV tự hủy đơn bù công*) | Chấm công `07:00 - 14:00` $\rightarrow$ **`6.0h` công lẻ** (**`0.75 công`**) |
| **`fix-5` + `fix-6`** | **Ngày 15/10** (Thứ Năm — *Được duyệt bù công 2 cấp*) | Quẹt gốc `07:00 - 12:00` (`4.0h`) $\rightarrow$ Bù công đạt **`8.0h`** (**`1.0 công`**) |
| **`fix-5` + `fix-6`** | **Ngày 16/10** (Thứ Sáu — *Bị từ chối/Reject bù công*) | Chấm công `07:00 - 15:00` $\rightarrow$ Giữ nguyên **`7.0h` công lẻ** (**`0.875 công`**) |
| **`fix-5` + `fix-6`** | **Tổng hợp công đi làm thực tế (`MnuTAD1000`)** | $8.0 + 8.0 + 6.0 + 8.0 + 7.0 = \mathbf{37.0\text{ giờ}}$ (**`4.625 ngày công`**) |
| **`fix-5` + `fix-6`** | **Đơn Nghỉ phép năm AL** (Ngày `24/10/2026` — *Đã duyệt 2 cấp*) | **`1.0 ngày`** (`8.0h`, hưởng 100% lương) $\rightarrow$ Tổng công hưởng lương = `4.625 + 1.0` = **`5.625 ngày`** |
| **`fix-5` + `fix-6`** | **Đơn Tăng ca OT** (Ngày `20/10/2026`, `18:00–20:00` — *Đã duyệt 2 cấp*) | **`2.0 giờ OT`** ngày thường (hệ số `150%`) |

> [!NOTE]
> **Lưu ý kiểm tra tiền đề lương công thức (`fix-4`)**: Nếu ở bước chuẩn bị nhân viên `099`, bạn mới chạy seed SQL thô mà chưa lưu lại hợp đồng/loại nhân viên trên UI `MnuHRS145` / `MnuHRS0102`, cần đảm bảo `tblSalaryHistory` của `099` có `SalCalRuleID` hợp lệ (ví dụ `1` = `Std_WD` hoặc `2` = `Fixed_WD`, không để `0`) và nhân viên có `EmployeeTypeID` phù hợp để `SALCAL_MAIN` nhận diện đúng số ngày công chuẩn trong tháng 10/2026.

---

> [!IMPORTANT]
> ### 🛠️ BƯỚC 0 (TIỀN ĐỀ BẮT BUỘC): CHUẨN BỊ CSDL TRÊN SSMS TRƯỚC KHI TEST / QUAY LẠI
> Mở **SQL Server Management Studio (SSMS)**, kết nối đúng CSDL `Vietinsoft_ForTest_Tai2`, tùy vào tình huống bạn chọn 1 trong 2 cách:
>
> #### 🔹 Cách A — Khi bạn VỪA chạy xong tay `kb_fix5.md` $\rightarrow$ `kb-fix6.md` (Khuyên dùng)
> *(Muốn giữ nguyên 5 ngày công mẫu `4.625 công`, đơn phép AL `1.0 ngày`, đơn OT `2.0h` của `fix-5`/`fix-6`, chỉ dọn sạch phần tài chính & khóa sổ của `fix-7` để test hoặc chạy lại nhiều lần)*:
> - Mở file: 📁 [**`scripts/reset/reset_fix7_data.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/reset/reset_fix7_data.sql)
> - Bấm **`Ctrl + F5`** kiểm tra cú pháp $\rightarrow$ Bấm **`F5`** để thực thi.
> - *Tác dụng*: Mở khóa sổ kỳ lương Tháng 10/2026 (`tblSal_Lock`), xóa sạch bảng lương (`tblSal_Sal`, `tblSal_Sal_Detail`), tạm ứng (`tblSal_Advance`) và thưởng KPI (`tblSal_Adjustment`) của NV `099` trong kỳ `10/2026`.
>
> #### 🔹 Cách B — Khi muốn Reset SẠCH TOÀN BỘ cả Flow (từ `fix-4` $\rightarrow$ `fix-8`) để test lại từ đầu
> - Mở file: 📁 [**`scripts/reset/reset_full_flow_tinh_luong_nv_moi.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/reset/reset_full_flow_tinh_luong_nv_moi.sql)
> - Bấm **`Ctrl + F5`** kiểm tra cú pháp $\rightarrow$ Bấm **`F5`** để thực thi.
> - *(Sau khi chạy Cách B, cần chạy lại `fix-4`, `kb_fix5.md` và `kb-fix6.md` trước khi vào `kb_fix7.md`)*.

---

## 🎥 HƯỚNG DẪN BẬT CHROME DEVTOOLS RECORDER ĐỂ QUAY THAO TÁC (THEO WORKFLOW MỚI)

1. Mở trình duyệt **Google Chrome** toàn màn hình, truy cập: `https://paradisehrm.com/Tai3/#`
2. Nhấn **`F12`** (hoặc `Ctrl + Shift + I`) để mở Chrome DevTools $\rightarrow$ chọn tab **Recorder**.
3. Nhấp **"Create new recording"**:
   - **Recording name**: Đặt tên là `fix7-tinh-luong-khoa-so`.
   - **Selector attribute**: Giữ mặc định.
4. Nhấp **"Start recording"** màu đỏ để bắt đầu ghi hình, rồi thao tác tuần tự theo **Bước 1 $\rightarrow$ Bước 6** bên dưới.

---

## 📋 CÁC BƯỚC THAO TÁC CHI TIẾT STEP-BY-STEP (RECORDING FLOW)

### BƯỚC 1: ĐĂNG NHẬP TÀI KHOẢN KẾ TOÁN TRƯỞNG
1. Tại màn hình Đăng nhập Paradise HRM:
   - Ô **Tên đăng nhập**: Nhập `chien.nguyen`
   - Ô **Mật khẩu**: Nhập `123`
2. Nhấp nút **"Đăng nhập"**.
3. Chờ màn hình Dashboard tải xong hoàn toàn.

---

### BƯỚC 2 [`TC-14`]: NẠP THƯỞNG KPI `1,000,000 VNĐ` (`MnuPRL036` — Thu nhập không cố định)
*(Bổ sung khoản thưởng KPI chịu thuế $1,000,000\text{ VNĐ}$ kỳ Tháng 10/2026 cho NV `099` vào bảng `tblSal_Adjustment`)*

1. **Mở màn hình "Thu nhập không cố định" (`MnuPRL036`)**:
   - Nhấp vào biểu tượng **Cửa sổ Windows 🪟** trên thanh Dock trên cùng (hoặc chọn **Tính lương** trên Dock $\rightarrow$ Sidebar trái).
   - Tại ô Search của Launchpad, gõ: `Thu nhập không cố định` $\rightarrow$ Nhấp chọn biểu tượng menu **"Thu nhập không cố định"**.
2. **Thiết lập bộ lọc kỳ lương trên Toolbar**:
   - Tại combobox **Tháng**: Nhấp chọn **`10`**.
   - Tại combobox **Năm**: Nhấp chọn **`2026`**.
3. **Mở form Thêm mới điều chỉnh**:
   - Quan sát góc trên bên phải thanh Toolbar của lưới (`#gridAdjustment`, bên phải nút Làm mới `↻`): Nhấp vào biểu tượng dấu **`+`** *(nút Thêm mới)*.
   - Chờ popup modal **"Thông tin điều chỉnh"** (`sp_EditAdjustment`) bật lên rõ ràng.
4. **Nhập đầy đủ thông tin Thưởng KPI trên Popup**:
   - **Nhân viên (\*)**: Nhấp mở hộp chọn $\rightarrow$ Tìm/gõ `099` $\rightarrow$ Chọn **`099 - Nguyễn Văn Test`**.
   - **Loại điều chỉnh (\*)**: Nhấp mở danh sách $\rightarrow$ Chọn **`Tiền thưởng`** *(nếu giao diện đang hiển thị tiếng Anh thì chọn `Performance bonus`, ứng với `IncomeID = 1`)*.
   - **Số tiền (VND) (\*)**: Nhấp vào ô nhập liệu $\rightarrow$ Gõ **`1000000`**.
   - **Mã tiền tệ**: Giữ nguyên mặc định **`VND`**.
   - **Ghi chú**: Nhấp vào ô Ghi chú $\rightarrow$ Nhập `[TEST_LUONG] Thưởng KPI nhân viên mới xuất sắc`.
5. **Lưu và đối soát trên lưới**:
   - Nhấp nút **`Lưu`** màu xanh lá cây ở góc dưới bên phải popup.
   - Chờ thông báo *"Thêm mới điều chỉnh lương thành công!"* hiển thị và popup đóng lại.
   - Tại ô tìm kiếm (kính lúp 🔍 bên phải toolbar lưới), nhập `099` $\rightarrow$ Quan sát dòng dữ liệu mới của **`099 | NGUYỄN VĂN TEST`** hiển thị đủ cột `TIỀN = 1.000.000`, `THÁNG = 10`, `NĂM = 2026`.
   - *(Mẹo: Có thể bấm chip filter **`Tiền thưởng`** ở hàng đầu tiên phía trên toolbar để lọc riêng nhóm thưởng kiểm chứng)*.
   - Dừng 2–3 giây để đối soát trực quan.

---

### BƯỚC 3 [`TC-15`]: NẠP & KHÓA TẠM ỨNG LƯƠNG `2,000,000 VNĐ` (`MnuPRL070` — Tạm ứng lương)
*(Cấp khoản tạm ứng $2,000,000\text{ VNĐ}$ và chốt khóa `IsLock = 1` cho NV `099` vào bảng `tblSal_Advance`)*

1. **Mở màn hình "Tạm ứng lương" (`MnuPRL070`)**:
   - Nhấp **Cửa sổ Windows 🪟** $\rightarrow$ Gõ `Tạm ứng lương` $\rightarrow$ Click mở menu **"Tạm ứng lương"** *(hoặc click thẳng mục **Tạm ứng lương** trên Sidebar trái nhóm Tính lương)*.
2. **Chọn kỳ tạm ứng trên Toolbar**:
   - Tại combobox **Tháng**: Chọn **`10`**.
   - Tại combobox **Năm**: Chọn **`2026`**.
   - *(⚠️ **LƯU Ý ĐẶC BIỆT BÁM SÁT `fix-5` & `fix-6` + UI THẬT**:*
     * *Màn hình `MnuPRL070` **KHÔNG có nút `+ Thêm mới`** trên toolbar! Hệ thống tự tải danh sách nhân viên và tự tính sẵn dòng `099 - Nguyễn Văn Test`.*
     * *Do 5 ngày công mẫu của `fix-5`/`fix-6` mới đạt **`4.625` ngày công đi làm** (chưa đạt ngưỡng ngày công tạm ứng tự động của hệ thống), cột **TẠM ỨNG** ban đầu của `099` sẽ hiện **`0`** và ô **DUYỆT** đang bỏ trống — điều này hoàn toàn bình thường!)*
3. **Mở Popup sửa & khóa tạm ứng cho NV `099`**:
   - Nhấp vào ô **Tìm kiếm** (góc trên bên phải lưới `#GridSAL_Advance_Process`) $\rightarrow$ Nhập `099` để lọc đúng dòng **`099 - Nguyễn Văn Test`**.
   - **Nhấp đúp chuột (Double-click)** trực tiếp vào dòng `099 - Nguyễn Văn Test` trên lưới.
   - Chờ popup chỉnh sửa tạm ứng (`sp_SAL_Advance_Process_Edit`) bật lên.
4. **Nhập số tiền `2,000,000` & Tích Khóa phiếu**:
   - Ô **Tạm ứng**: Xóa `0` và nhập **`2000000`**.
   - Checkbox **Khóa**: **Tích chọn ô `Khóa`** (`IsLock = true`). *(Lưu ý: Khi tích `Khóa`, giao diện sẽ tự động tích kèm ô `Tiền mặt` theo rule mặc định của form)*.
   - Ô **Ghi chú**: Nhập `[TEST_LUONG] Tạm ứng sinh hoạt cá nhân`.
   - Nhấp nút **`Lưu`** màu xanh (`#btnSaveAdvance`).
5. **Đối soát sau khi Lưu**:
   - Chờ thông báo *"Lưu thành công!"* hiển thị, popup tự đóng và lưới tự tải lại.
   - Kiểm chứng trên dòng **`099 - Nguyễn Văn Test`**:
     * Cột **TẠM ỨNG** hiển thị **`2.000.000`**.
     * Cột **DUYỆT** (checkbox khóa) hiển thị **đã tích xanh ✅**.
   - *(Tùy chọn kiểm chứng khóa)*: Nhấp đúp thử lại vào dòng `099` $\rightarrow$ hệ thống bật cảnh báo *"Dữ liệu tạm ứng của nhân viên này đã bị khóa, không thể chỉnh sửa!"* $\rightarrow$ chứng tỏ khóa phiếu hoạt động chuẩn 100%.

---

### BƯỚC 4 [`TC-16`]: KÍCH HOẠT TÍNH TIỀN LƯƠNG TỰ ĐỘNG TOÀN CÔNG TY (`MnuPRL040` — Tính tiền lương)
*(Chạy thủ tục lõi `SALCAL_MAIN` tổng hợp 4.625 ngày công + 1.0 AL + 2.0h OT từ `fix-5`/`fix-6` cùng Thưởng KPI +1M & Tạm ứng -2M của `fix-7`)*

1. **Mở màn hình "Tính tiền lương" (`MnuPRL040`)**:
   - Nhấp **Cửa sổ Windows 🪟** trên thanh Dock $\rightarrow$ Gõ `Tính tiền lương` $\rightarrow$ Nhấp chọn biểu tượng menu **"Tính tiền lương"**.
2. **Kiểm tra & chọn đúng Kỳ lương Tháng 10/2026**:
   - ⚠️ **CẢNH BÁO QUAN TRỌNG TỪ UI THẬT**: Màn hình này khi vừa mở ra thường **đang đứng sẵn ở tháng khác** (ví dụ `Tháng: 2`, `Năm: 2026`).
   - Nhấp vào dropdown **Tháng** $\rightarrow$ Chọn lại chính xác **`10`**.
   - Kiểm tra dropdown **Năm** $\rightarrow$ Đảm bảo đang là **`2026`**.
3. **Bấm nút chạy Tính lương tự động**:
   - Nhấp vào nút dài màu xanh lá cây: **`Tính lương`**.
   - Nếu xuất hiện popup xác nhận, nhấp **`Đồng ý` / `Có`**.
   - Chờ biểu tượng xoay *"Đang tải..."* hoàn tất (khoảng 3–8 giây để SQL Server chạy `SALCAL_MAIN @EmployeeID = '-1'` cho toàn bộ nhân viên).
   - *(Lưu ý kỹ thuật: Sau khi chạy xong, vùng lưới phía dưới trống / hiển thị *"Không có dữ liệu"* là bình thường vì `SALCAL_MAIN` kết thúc bằng `print 'eof'`, lưới chỉ hiện danh sách nếu có nhân viên bị lỗi cấu hình)*.

---

### BƯỚC 5 [`TC-17`]: KHÓA CHẤM CÔNG (`MnuTAD125`) & NIÊM PHONG KHÓA SỔ KỲ LƯƠNG THÁNG 10/2026 (`MnuPRL080`)
*(Khóa chấm công trước để mở khóa điều kiện cho phép khóa sổ kỳ lương Tháng 10/2026 vào `tblSal_Lock`, kích hoạt cho `fix-8` / `test.nv` xem Phiếu lương chính thức)*

> [!WARNING]
> **Ràng buộc nghiệp vụ bắt buộc của Hệ thống (`PR_Sal_Lock_Update`)**:
> Để khóa lương cho nhân viên `099`, nhân viên `099` **phải được Khóa công trước** (`tblAtt_LockMonth`). Nếu cột Ghi chú trên `MnuPRL080` của `099` báo **`Chưa khóa công`** mà bạn bấm Khóa lương ngay, hệ thống sẽ báo lỗi *"Lỗi: Vui lòng khóa chấm công trước khi khóa lương: 099"*.

#### 🔹 Phần 5A: Khóa chấm công Tháng 10/2026 (nếu NV `099` đang báo "Chưa khóa công")
1. Nhấp **Cửa sổ Windows 🪟** $\rightarrow$ Gõ `Mở/Khóa. Công` $\rightarrow$ Mở màn hình **`Mở/Khóa. Công`** (`MnuTAD125`).
2. Chọn **Tháng** = `10`, **Năm** = `2026` trên Toolbar.
3. Gõ `099` vào ô tìm kiếm kiểm tra; nếu NV `099` chưa khóa công, nhấp nút **`🔒 Khóa`** $\rightarrow$ Xác nhận popup $\rightarrow$ Chờ thông báo khóa công thành công.

#### 🔹 Phần 5B: Niêm phong Khóa sổ kỳ lương tại **`MnuPRL080` ("Mở/Khóa. Lương")**
1. **Mở màn hình "Mở/Khóa. Lương" (`MnuPRL080`)**:
   - Nhấp **Cửa sổ Windows 🪟** $\rightarrow$ Gõ `Mở/Khóa` $\rightarrow$ Chọn **"Mở/Khóa. Lương"** *(hoặc click trực tiếp **`Mở/Khóa. Lương`** trên Sidebar trái nhóm Tính lương)*.
2. **Chọn Kỳ khóa lương trên Toolbar**:
   - Tại combobox **Tháng**: Chọn **`10`**.
   - Tại combobox **Năm**: Chọn **`2026`**.
3. **Quan sát trạng thái & Bấm nút Khóa**:
   - Quan sát dòng trạng thái phía trên bên phải toolbar: **`Trạng thái khóa lương: Đang mở <số>/<tổng>`** (ví dụ `Đang mở 40/41` — tức nhân viên mới `099` đã khóa công xong và đang ở trạng thái *Đang mở* chờ khóa lương) và nút màu đỏ **`🔒 Khóa`** đang sáng active.
   - Nhấp vào nút màu đỏ **`🔒 Khóa`**.
   - Popup xác nhận hiện lên *(ví dụ hỏi "Bạn có chắc chắn muốn khóa công không?")* $\rightarrow$ Nhấp **`Đồng ý` / `Có`**.
4. **Kiểm chứng sau khi Khóa**:
   - Chờ thông báo *"Khoá lương thành công"* xuất hiện.
   - Quan sát trên Toolbar:
     * Trạng thái cập nhật đủ toàn bộ nhân viên (ví dụ `41/41`), nút đỏ **`Khóa`** mờ đi (`disabled`), nút **`Mở khóa`** sáng lên.
     * Gõ `099` vào ô tìm kiếm lưới $\rightarrow$ Dòng **`099 | NGUYỄN VĂN TEST | 10 | 2026 | Đã khóa lương`** hiển thị đầy đủ.

---

### BƯỚC 6: ĐĂNG XUẤT BÀN GIAO CHO `FIX-8` & XUẤT FILE `.JSON` RECORDER
1. Nhấp vào **Avatar tài khoản** ở góc trên cùng bên phải $\rightarrow$ Chọn **"Đăng xuất"** để trả về màn hình đăng nhập sạch cho giai đoạn `fix-8` (nghiệm thu Bảng lương tổng hợp `MnuPRL092` & Phiếu lương `MnuPRL445`).
2. Nếu bạn đang bật Chrome DevTools Recorder:
   - Nhấp **"End recording"** màu đỏ ở góc dưới.
   - Nhấp biểu tượng **Export ($\downarrow$)** $\rightarrow$ Chọn **"Export as a JSON file"**.
   - Lưu thành `fix7-recording.json` và gửi qua cho Agent để tự động chuyển đổi thành kịch bản Replay `.spec.js` + `.sql` reset + `.bat` 1-Click theo **Điều 9 `AGENTS.md`**.

---

## 🎯 2. BẢNG ĐỐI SOÁT KẾT QUẢ & TRUY VẤN SQL KIỂM CHỨNG (READ-ONLY)

Sau khi bạn thực hiện xong 6 bước trên giao diện, mở **SSMS** và chạy đoạn SQL Read-Only dưới đây để kiểm chứng từng lớp dữ liệu trong CSDL `Vietinsoft_ForTest_Tai2`:

```sql
-- ============================================================================
-- ĐỐI SOÁT KẾT QUẢ GIAI ĐOẠN FIX-7 CHO NHÂN VIÊN 099 - THÁNG 10/2026
-- ============================================================================

-- 1. Kiểm chứng [TC-14]: Thưởng KPI 1,000,000 VNĐ trong tblPR_Adjustment (UI) & tblSal_Adjustment (MnuPRL036)
--    Kỳ vọng: IncomeID = 1 (Tiền thưởng), Amount = 1000000.0000
SELECT EmpAdjustmentID, EmployeeID, Month, Year, IncomeID, Amount, Remark
FROM tblPR_Adjustment
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

SELECT EmployeeID, Month, Year, IncomeID, Amount, TaxableAmount, UntaxableAmount
FROM tblSal_Adjustment
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 2. Kiểm chứng [TC-15]: Tạm ứng 2,000,000 VNĐ & Đã Khóa phiếu trong tblSal_Advance (MnuPRL070)
--    Kỳ vọng: AdvanceAmount = 2000000.0000, IsLock = 1 (TRUE)
SELECT EmployeeID, Month, Year, BasicSalary, AttDays, AdvanceAmount, IsLock, Cash, Notes
FROM tblSal_Advance
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 3. Kiểm chứng [TC-16]: Kết quả tính lương tổng hợp & chi tiết từ SALCAL_MAIN (MnuPRL040)
--    Kỳ vọng: Có bản ghi tblSal_Sal & tblSal_Sal_Detail phản ánh tổng công từ fix-5/fix-6,
--             cộng Thưởng KPI (+1,000,000) và trừ Tạm ứng (-2,000,000)
SELECT EmployeeID, Month, Year, ActualMonthlyBasic, TaxableAdjustment,
       TotalIncome, TotalEarn, TaxableIncomeBeforeDeduction, IncomeAfterPIT, GrossTakeHome, Notes
FROM tblSal_Sal
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

SELECT EmployeeID, Month, Year, DaysOfSalEntry, ATTHours, WorkingHours,
       ActualMonthlyBasic, TotalEarn, GrossTakeHome
FROM tblSal_Sal_Detail
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

--    Kiểm chứng đối chiếu chi tiết OT (2.0h ngày 20/10) & Nghỉ hưởng lương (1.0 ngày 24/10)
SELECT * FROM tblSal_OT_Detail WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
SELECT * FROM tblSal_PaidLeave_Detail WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 4. Kiểm chứng [TC-17]: Đã khóa công (tblAtt_LockMonth) & khóa sổ lương (tblSal_Lock) cho NV 099
--    Kỳ vọng: Cả 2 bảng đều có bản ghi EmployeeID = '099' cho Month = 10, Year = 2026
SELECT Month, Year, EmployeeID, PeriodID FROM tblAtt_LockMonth WHERE Month = 10 AND Year = 2026 AND EmployeeID = '099';
SELECT Month, Year, EmployeeID, PeriodID
FROM tblSal_Lock
WHERE Month = 10 AND Year = 2026 AND (EmployeeID = '099' OR EmployeeID = '-1')
ORDER BY EmployeeID;
```

### Tóm tắt tiêu chí PASS cho `fix-7`:
| TC | Menu | Thao tác cốt lõi trên UI | Kết quả kỳ vọng (UI + CSDL) |
| :--- | :--- | :--- | :--- |
| **`TC-14`** | `MnuPRL036` | Chọn `10/2026` $\rightarrow$ Bấm `+` $\rightarrow$ Chọn `099`, `Tiền thưởng`, `1000000` $\rightarrow$ `Lưu` | Lưới hiện `099` với `1.000.000`; `tblSal_Adjustment` có `Amount = 1000000` |
| **`TC-15`** | `MnuPRL070` | Chọn `10/2026` $\rightarrow$ Gõ `099` $\rightarrow$ **Nhấp đúp dòng `099`** $\rightarrow$ Nhập `2000000`, tích `Khóa` $\rightarrow$ `Lưu` | Lưới hiện `2.000.000` + ✅ Duyệt; `tblSal_Advance` có `AdvanceAmount = 2000000`, `IsLock = 1` |
| **`TC-16`** | `MnuPRL040` | Chọn lại **Tháng `10`**, Năm `2026` $\rightarrow$ Bấm nút xanh **`Tính lương`** | Hoàn tất không lỗi; `tblSal_Sal` & `tblSal_Sal_Detail` ghi nhận đủ dữ liệu lương `099` từ công `4.625` + `1 AL` + `2h OT` + `KPI` + `Tạm ứng` |
| **`TC-17`** | `MnuPRL080` | Chọn `10/2026` $\rightarrow$ Bấm nút đỏ **`🔒 Khóa`** $\rightarrow$ Xác nhận popup $\rightarrow$ Đăng xuất | Trạng thái chuyển `Đã khóa` cho toàn bộ nhân sự (`41/41`); `tblSal_Lock` có bản ghi `099` kỳ `10/2026` |
