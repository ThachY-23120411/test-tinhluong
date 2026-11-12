# KỊCH BẢN KIỂM THỬ THỦ CÔNG & QUAY RECORDING (MANUAL TEST SCRIPT) - PHÂN VÙNG FIX-8
> **DỰ ÁN**: Flow liên hoàn tính lương nhân viên mới `099 - Nguyễn Văn Test` (E2E New Employee Payroll)  
> **TIỀN ĐỀ BẮT BUỘC**: Đã hoàn tất quy trình của **`fix-4`** (Hồ sơ, HĐLĐ, Người phụ thuộc, Phân ca), **`fix-5`** ([`kb_fix5.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/kb_fix5.md)), **`fix-6`** ([`kb-fix6.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/kb-fix6.md)) và **`fix-7`** ([`kb_fix7.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/kb_fix7.md))  
> **VAI TRÒ THỰC HIỆN**:
> - Kế toán trưởng **`chien.nguyen`** / **`123`** (`EmployeeID: '013'`, `LoginID: 22`) — dùng cho **`TC-18`**
> - Nhân viên mới **`test.nv`** / **`123`** (`EmployeeID: '099'`, `LoginID: 1241`) — dùng cho **`TC-19`** & **`TC-20`**  
> **DANH SÁCH TEST CASE**: `TC-18`, `TC-19`, `TC-20` (Giai đoạn P5 — Nghiệm thu cuối flow)  
> **MÔI TRƯỜNG KIỂM THỬ**: Google Chrome — Web Paradise HRM: `https://paradisehrm.com/Tai3/#`  
> **CƠ SỞ DỮ LIỆU**: `Vietinsoft_ForTest_Tai2` (SQL Server)  
> **MỤC TIÊU KÉP**:
> 1. Hướng dẫn từng bước thao tác tay trên giao diện Web thật để kiểm thử & nghiệm thu chéo bảng lương toàn công ty tại màn hình **Danh sách trả lương (`MnuPRL092`)** với phiếu lương cá nhân nhân viên tại **Phiếu lương (`MnuPRL445`)**, đồng thời bật **Chrome F12 Recorder** xuất file `.json`.
> 2. Gửi file `.json` cho Agent chuyển đổi thành kịch bản Playwright mô phỏng người thật + script `.sql` reset/kiểm chứng + file `.bat` 1-Click theo **Điều 9 `AGENTS.md`** ([`recorder-json-replay/SKILL.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/.agents/skills/recorder-json-replay/SKILL.md)).

---

## 📌 1. BỨC TRANH DỮ LIỆU ĐẦU VÀO & CÔNG THỨC KỲ VỌNG KẾ THỪA TỪ `FIX-4` $\rightarrow$ `FIX-7`

Trước khi nghiệm thu ở **`fix-8`**, nhân viên **`099 - Nguyễn Văn Test`** trong kỳ lương **Tháng 10/2026** (`10/10/2026 – 09/11/2026`) đã tích lũy đầy đủ chuỗi dữ liệu thực tế qua 4 giai đoạn trước:

| Nguồn | Thành phần dữ liệu của NV `099` | Giá trị / Công thức kế thừa từ CSDL & `SALCAL_MAIN` |
| :--- | :--- | :--- |
| **`fix-4`** | **Lương cơ bản & Đóng BHXH** (`tblSalaryHistory`) | `Salary = 10,000,000 VNĐ` \| `InsSalary = 10,000,000 VNĐ` |
| **`fix-5` + `fix-6`** | **5 ngày công mẫu đã chốt** (`tblHasTA` $\rightarrow$ `MnuTAD1000`) | `12/10 (8h)` + `13/10 (8h)` + `14/10 (6h - tự hủy đơn)` + `15/10 (4h -> duyệt bù lên 8h)` + `16/10 (7h - bị Reject bù)` = **`37.0 giờ`** (**`4.625 ngày`**) |
| **`fix-5` + `fix-6`** | **Nghỉ phép năm có lương** (`tblLvHistory` - `AL` ngày `24/10`) | **`1.0 ngày`** (`8.0 giờ`, hưởng `100%` lương) $\rightarrow$ **Tổng công hưởng lương (`DaysOfSalEntry`)** = `4.625 + 1.0` = **`5.625 ngày`** |
| **`fix-5` + `fix-6`** | **Tăng ca đã duyệt 2 cấp** (`tblOTList` ngày `20/10`, `18:00–20:00`) | **`2.0 giờ OT`** ngày thường (`OTKind = 11`, hệ số **`150%`**) $\rightarrow$ `Lương TC` = `10,000,000 / 24 / 8 * 2 * 150%` = **`156,250 VNĐ`** *(theo công thức `OTSalary / 24.0` trong `SALCAL_MAIN`)* |
| **`fix-5` + `fix-6`** | **Đi trễ / về sớm** (`tblSal_IO`) | **`0 ngày`** (không có dữ liệu đi trễ/về sớm) |
| **`fix-7` (`TC-14`)** | **Thưởng KPI** (`MnuPRL036`, `IncomeID = 1`: *Tiền thưởng*) | **`+1,000,000 VNĐ`** (`tblPR_Adjustment` $\rightarrow$ `tblSal_Adjustment`) |
| **`fix-7` (`TC-15`)** | **Tạm ứng lương đã khóa** (`MnuPRL070`, `tblSal_Advance`) | **`2,000,000 VNĐ`** (`IsLock = 1` $\rightarrow$ bắt buộc phải khóa mới hiện trừ trên Phiếu lương `sp_PaySlipView`) |
| **`fix-7` (`TC-16`)** | **Bảo hiểm NLĐ đóng (10.5%)** (`tblSal_Insurance`) | BHXH `8%` (`800,000`) + BHYT `1.5%` (`150,000`) + BHTN `1%` (`100,000`) = **`1,050,000 VNĐ`** *(gom 1 dòng `Insurance fee / BHXH, BHYT, BHTN`)* |
| **`fix-7` (`TC-16`)** | **Giảm trừ gia cảnh & Thuế TNCN** (`tblTaxDeduction` 01/2026+) | Bản thân: **`15,500,000 VNĐ`** \| Người phụ thuộc: **`6,200,000 VNĐ / người`** *(nếu `tblFamilyInfo.TaxDependant = 1`)* $\rightarrow$ Với tổng thu nhập `~2.3M – 3.8M`, nếu tính lũy tiến thì `Thu nhập chịu thuế = 0`, `Thuế TNCN = 0` |
| **`fix-7` (`TC-17`)** | **Khóa sổ kỳ lương Tháng 10/2026** (`tblSal_Lock`) | Bắt buộc đã có bản ghi khóa kỳ `10/2026` cho `099` $\rightarrow$ `MnuPRL445` (`sp_PaySlipView`) mới tự động mở đúng **`Tháng/Năm: 10/2026`** |

> [!NOTE]
> **3 điểm đối soát kỹ thuật quan trọng cần lưu ý khi nghiệm thu trên UI thật**:
> 1. **Số ngày công chuẩn (`StandardWDays`) & `Lương ngày công` (`ActualMonthlyBasic`)**:
>    - Tùy cấu hình `SalCalRuleID` (`tblSalaryHistory`) & `EmployeeTypeID` (`tblEmployeeTypeHistory`) đã thiết lập cho `099` ở `fix-4`:
>      * Nếu `SalCalRuleID = 1` (`Std_WD`) & `EmployeeTypeID = 1` (*Nghỉ T7 và CN*): `Công chuẩn` kỳ `10/2026` là **`21 ngày`** $\rightarrow$ `Lương ngày công` = `10,000,000 / 21 * 5.625` $\approx$ **`2,678,571 VNĐ`**.
>      * Nếu `SalCalRuleID = 1` & `EmployeeTypeID = 0` (*Nghỉ CN, T7 làm Online*) hoặc `SalCalRuleID = 2` (`Fixed_WD`): `Công chuẩn` là **`26 ngày`** $\rightarrow$ `Lương ngày công` = `10,000,000 / 26 * 5.625` $\approx$ **`2,163,462 VNĐ`**.
>    - *(Cảnh báo từ `fix-7`: Tuyệt đối không để `SalCalRuleID = 0` hoặc thiếu `EmployeeTypeID`, nếu không `SALCAL_MAIN` sẽ không tính được `ActualMonthlyBasic`)*.
> 2. **Hiển thị khoản Thưởng KPI `1,000,000 VNĐ` trên Mục `II/ Các khoản thu nhập khác` của `MnuPRL445`**:
>    - Stored Procedure `sp_PaySlipView` (Dataset 5) chỉ liệt kê chi tiết dòng điều chỉnh từ `tblPR_Adjustment` vào `#psOtherIncomes` khi `tblIrregularIncome.ForSalary = 1 AND IncomeKind = 1`. Nếu danh mục `IncomeID = 1` (*Tiền thưởng*) trong CSDL đang để `ForSalary = NULL`, màn hình `MnuPRL445` có thể hiện *"Không có khoản thu nhập nào khác."* ở Mục `II` dù số tiền thưởng đã được ghi nhận trong `tblPR_Adjustment` / `tblSal_Adjustment`.
> 3. **Số Người phụ thuộc (`DependantNumber`) trên `MnuPRL445`**:
>    - `SALCAL_MAIN` chỉ đếm bản ghi trong `tblFamilyInfo` có `TaxDependant = 1` và còn hiệu lực. Nếu dữ liệu `099` ở `fix-4` chưa bật `TaxDependant = 1` (đang để `NULL`), phiếu lương sẽ hiển thị `Người phụ thuộc: 0` và `Giảm trừ người phụ thuộc: 0`. Nếu đã bật `TaxDependant = 1` cho `1` người (*Nguyễn Minh Khang*), sẽ hiện `1` và `6,200,000`.

---

> [!IMPORTANT]
> ### 🛠️ BƯỚC 0 (TIỀN ĐỀ BẮT BUỘC): KIỂM TRA CSDL TRƯỚC KHI TEST / QUAY LẠI `FIX-8`
> Mở **SQL Server Management Studio (SSMS)**, kết nối đúng CSDL `Vietinsoft_ForTest_Tai2`, chọn 1 trong 4 tình huống sau:
>
> #### 🔹 Tình huống A — Bạn VỪA hoàn tất tuần tự `kb_fix5.md` $\rightarrow$ `kb-fix6.md` $\rightarrow$ `kb_fix7.md` (Khuyên dùng)
> - **Không cần chạy file reset nào!** Kỳ lương Tháng `10/2026` của NV `099` đã được tính và khóa sổ xong ở `TC-17` (`tblSal_Sal`, `tblSal_Sal_Detail`, `tblSal_Lock` đã có đủ dữ liệu). Bạn chạy ngay **Bước 1** bên dưới.
> - *(Mẹo: Nếu muốn kiểm tra nhanh dữ liệu `fix-7` đã sẵn sàng chưa trước khi mở web, chạy truy vấn Read-Only `SELECT * FROM tblSal_Lock WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026` — cần trả về `>= 1` dòng).*
>
> #### 🔹 Tình huống B — Bạn muốn Reset & Dựng SẴN dữ liệu chuẩn đầu vào cho `fix-8` (Chạy độc lập `kb_fix8.md` ngay lập tức)
> - Chạy 📁 [**`scripts/reset/reset_fix8_data.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/reset/reset_fix8_data.sql) trên SSMS (`Ctrl + F5` $\rightarrow$ `F5`).
> - Script này sẽ tự động đồng bộ toàn bộ hồ sơ/tài khoản NV `099`, công/phép/OT (`5.625` công, `2h` OT), thưởng KPI `1,000,000 đ`, tạm ứng đã khóa `2,000,000 đ`, xóa bảng lương cũ, gọi `SALCAL_MAIN` và khóa kỳ lương Tháng `10/2026` của NV `099` để bạn vào thẳng **Bước 1** test/quay `fix-8` mà không cần chạy lại `fix-4` $\rightarrow$ `fix-7`.
>
> #### 🔹 Tình huống C — Bạn muốn giữ công `fix-5`/`fix-6` và chạy lại từ đầu phần tài chính (`fix-7` $\rightarrow$ `fix-8`)
> - Chạy 📁 [**`scripts/reset/reset_fix7_data.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/reset/reset_fix7_data.sql) trên SSMS (`Ctrl + F5` $\rightarrow$ `F5`), sau đó thực hiện lại `kb_fix7.md` (`TC-14` $\rightarrow$ `TC-17`) rồi mới vào `kb_fix8.md`.
>
> #### 🔹 Tình huống D — Bạn muốn Reset SẠCH TOÀN BỘ cả Flow (từ `fix-4` $\rightarrow$ `fix-8`)
> - Chạy 📁 [**`scripts/reset/reset_full_flow_tinh_luong_nv_moi.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/reset/reset_full_flow_tinh_luong_nv_moi.sql) trên SSMS (`Ctrl + F5` $\rightarrow$ `F5`), sau đó chạy lại đầy đủ `fix-4` $\rightarrow$ `kb_fix5.md` $\rightarrow$ `kb-fix6.md` $\rightarrow$ `kb_fix7.md` rồi vào `kb_fix8.md`.

---

## 🎥 HƯỚNG DẪN BẬT CHROME DEVTOOLS RECORDER ĐỂ QUAY THAO TÁC (THEO WORKFLOW MỚI)

1. Mở trình duyệt **Google Chrome** toàn màn hình tại: `https://paradisehrm.com/Tai3/#` (đảm bảo đã **Đăng xuất** khỏi phiên của `fix-7`).
2. Nhấn **`F12`** (hoặc `Ctrl + Shift + I`) để mở Chrome DevTools $\rightarrow$ chọn tab **Recorder**.
3. Nhấp **"Create new recording"**:
   - **Recording name**: Đặt tên là `fix8-nghiem-thu-bang-luong-phieu-luong`.
   - **Selector attribute**: Giữ mặc định.
4. Nhấp nút **"Start recording"** màu đỏ để bắt đầu ghi hình, rồi thao tác tuần tự theo **Bước 1 $\rightarrow$ Bước 6** bên dưới.

---

## 📋 CÁC BƯỚC THAO TÁC CHI TIẾT STEP-BY-STEP (RECORDING FLOW)

### BƯỚC 1: ĐĂNG NHẬP KẾ TOÁN TRƯỞNG (`chien.nguyen`)
1. Tại màn hình Đăng nhập Paradise HRM (`https://paradisehrm.com/Tai3/#`):
   - Ô **Tên đăng nhập**: Nhập `chien.nguyen`
   - Ô **Mật khẩu**: Nhập `123`
2. Nhấp nút **"Đăng nhập"**.
3. Chờ màn hình Dashboard tải xong hoàn toàn.

---

### BƯỚC 2 [`TC-18`]: NGHIỆM THU DANH SÁCH TRẢ LƯƠNG & PHIẾU LƯƠNG HÀNG LOẠT (`MnuPRL092`)
*(Kế toán trưởng kiểm tra tổng thể kỳ lương Tháng 10/2026 tại màn hình **Danh sách trả lương** trước khi bàn giao cho nhân viên xem)*

1. **Mở màn hình "Danh sách trả lương" (`MnuPRL092`)**:
   - Nhấp vào biểu tượng **Cửa sổ Windows 🪟** trên thanh Dock trên cùng $\rightarrow$ Gõ `Danh sách trả lương` *(hoặc chọn phân hệ **Tính lương** trên thanh Dock / Sidebar trái $\rightarrow$ nhấp **`Danh sách trả lương`**)* $\rightarrow$ Nhấp mở **`MnuPRL092`**.
   - *(Lưu ý: **`Bảng lương tổng hợp`** là tên **nút bấm chức năng** `#btnPrint` nằm bên trong màn hình **Danh sách trả lương**, không phải tên menu).*
   - Quan sát khung hiển thị mặc định ở giữa màn hình: *"Chọn tham số và xem báo cáo — Dữ liệu lương chi tiết sẽ được hiển thị ở đây"*.
2. **Thiết lập bộ lọc kỳ lương & kiểm tra trạng thái khóa trên Toolbar**:
   - Tại hộp chọn **Tháng**: Kiểm tra / chọn **`10`**.
   - Tại hộp chọn **Năm**: Kiểm tra / chọn **`2026`**.
   - Ô checkbox **Xuất ra file**: Đảm bảo **ĐANG BỎ TÍCH** (để xem trực tiếp trên trình duyệt).
   - Quan sát các chỉ báo trên thanh công cụ:
     * Nhãn **Trạng thái khoá công:** hiển thị trạng thái kỳ `10/2026` (ví dụ `Đã khoá` toàn bộ).
     * Nút **`Tính lương`** ở bên phải đã chuyển sang **trạng thái mờ / vô hiệu hóa** (`disabled`) vì kỳ lương Tháng `10/2026` đã được khóa sổ tại `TC-17`.
3. **Xem báo cáo Excel preview — nút `Bảng lương tổng hợp`**:
   - Nhấp nút **`Bảng lương tổng hợp`** (`#btnPrint`).
   - Chờ spinner *"Đang tải..."* hoàn tất (khoảng 3–6 giây).
   - Quan sát báo cáo dạng Excel hiển thị ngay trong khung xem trước (`#preview-body`):
     * Nếu có nhiều tab sheet ở thanh footer phía dưới (`#report-footer`), nhấp chọn sheet bảng lương chi tiết.
     * Cuộn tìm đến dòng nhân viên **`099` — `Nguyễn Văn Test`**, đối chiếu các cột trọng yếu:
       - `StdWD` (Công chuẩn): **`21`** hoặc **`26`** (tùy công thức nhân viên)
       - `ActualWD` (Công thực tế hưởng lương): **`5.625`**
       - `TotalOTHours` (Tổng giờ OT): **`2`**
       - Cột Thưởng / Tạm ứng / Bảo hiểm / Thực lãnh (`GrossTakeHome_VND`) hiển thị đầy đủ, không âm sai lệch.
4. **Xem trước phiếu lương hàng loạt — nút `Xem phiếu lương`**:
   - Nhấp nút **`Xem phiếu lương`** (`#btnView`).
   - Chờ hệ thống nạp danh sách từng trang phiếu lương (`.html-payslip-page`) kèm thanh điều hướng trang ở phía trên khung xem trước (`◀` | `[ 1 ] / <Tổng số trang>` | `▶`).
   - Dùng nút mũi tên phải **`▶`** (hoặc nhập số trang trực tiếp vào ô số trang rồi nhấn `Enter`) để lật đến trang phiếu lương của **`099 - Nguyễn Văn Test`**.
   - Dừng 2–3 giây để ghi nhận số tiền **Thực lãnh** trên trang xem trước hàng loạt này để chuẩn bị đối chiếu chéo với `TC-19`.
   - *(Tùy chọn)* Nếu muốn test tính năng tải file Excel: tích chọn checkbox **`Xuất ra file`** $\rightarrow$ Nhấp **`Bảng lương tổng hợp`** $\rightarrow$ Chờ thông báo *"Xuất file thành công"* và trình duyệt tải về file `.xlsx`, sau đó bỏ tích lại **`Xuất ra file`**.
5. **Đăng xuất tài khoản Kế toán trưởng**:
   - Nhấp **Avatar tài khoản** góc trên bên phải $\rightarrow$ Chọn **"Đăng xuất"** để trả về màn hình đăng nhập sạch cho nhân viên `test.nv`.

---

### BƯỚC 3: ĐĂNG NHẬP NHÂN VIÊN MỚI (`test.nv`)
1. Tại màn hình Đăng nhập Paradise HRM:
   - Ô **Tên đăng nhập**: Nhập `test.nv`
   - Ô **Mật khẩu**: Nhập `123`
2. Nhấp nút **"Đăng nhập"**.
3. Chờ màn hình Portal nhân viên tải xong hoàn toàn.

---

### BƯỚC 4 [`TC-19`]: KIỂM TRA ĐỊNH LƯỢNG PHIẾU LƯƠNG CÁ NHÂN (`MnuPRL445`)
*(Nhân viên tự kiểm tra từng khoản lương, công, tăng ca, thưởng, khấu trừ và thực lãnh kỳ 10/2026)*

1. **Mở màn hình "Phiếu Lương" (`MnuPRL445`)**:
   - Nhấp biểu tượng **Cửa sổ Windows 🪟** trên thanh Dock $\rightarrow$ Gõ `Phiếu lương` $\rightarrow$ Nhấp chọn **"Phiếu Lương"** *(hoặc click mục **Phiếu Lương** trên Sidebar trái)*.
2. **Kiểm tra trạng thái Tab & Kỳ lương tự động tải**:
   - Xác nhận tab **`Phiếu Lương`** đang được chọn active (bên cạnh tab **`Lịch Sử`**).
   - Xác nhận tiêu đề chính **`PHIẾU LƯƠNG NHÂN VIÊN`** và dòng kỳ lương tự động hiển thị: **`Tháng/Năm: 10/2026`** *(do `10/2026` đã được khóa trong `tblSal_Lock` ở `TC-17`)*.
3. **Kiểm tra khối Thông tin nhân viên**:
   - **Mã nhân viên**: **`099`**
   - **Họ và tên**: **`Nguyễn Văn Test`**
   - **Ngày vào làm**: **`01/10/2026`**
   - **Chức vụ**: Khớp thông tin chức vụ của NV `099`
   - **Người phụ thuộc**: **`0`** *(hoặc **`1`** nếu đã bật `TaxDependant = 1` trong `tblFamilyInfo`)*
4. **Kiểm tra Mục `I/ Thông tin lương`**:
   - **Công chuẩn**: **`21 ngày`** *(nếu `EmployeeTypeID = 1`, `Std_WD`)* hoặc **`26 ngày`** *(nếu `EmployeeTypeID = 0` hoặc `Fixed_WD`)*
   - **Công thực tế**: **`5.625 ngày`** *(tổng `4.625` ngày công đi làm từ `fix-5`/`fix-6` + `1.0` ngày phép AL ngày `24/10`)*
   - **Số giờ tăng ca**: **`2 giờ`** *(kèm icon con mắt 👁️ bên cạnh)*
   - **Số ngày nghỉ**: **`1 ngày`** *(kèm icon con mắt 👁️ bên cạnh)*
   - **Đi trễ/về sớm**: **`0 ngày`** *(kèm icon con mắt 👁️ bên cạnh)*
   - **Lương ngày công**: **`ActualMonthlyBasic`** = `10,000,000 / Công chuẩn * 5.625` *(`≈ 2,678,571` nếu chia 21 ngày, hoặc `≈ 2,163,462` nếu chia 26 ngày)*
   - **Lương TC**: **`156,250`** *(`= 10,000,000 / 24 / 8 * 2 giờ * 150%`)*
5. **Kiểm tra Mục `II/ Các khoản thu nhập khác`**:
   - Quan sát danh sách các khoản điều chỉnh / phụ cấp hiển thị bên dưới:
     * Nếu `tblIrregularIncome.ForSalary = 1` cho `IncomeID = 1`: Hiển thị dòng **`Tiền thưởng [...]`** = **`1,000,000`**, **`Tổng thu nhập khác:`** = **`1,000,000`**.
     * *(Nếu `ForSalary = NULL` theo dữ liệu seed gốc: khu vực này sẽ hiện `"Không có khoản thu nhập nào khác."`, `Tổng thu nhập khác: 0`)*.
   - **`TỔNG LƯƠNG / TOTAL INCOME:`** = Tổng lương ngày công + Lương TC + Tổng thu nhập khác (đối chiếu khớp cột `TotalIncome` trong `tblSal_Sal`).
6. **Kiểm tra Mục `III/ Các khoản khấu trừ`**:
   - Quan sát danh sách các khoản khấu trừ tự động:
     * **`Insurance fee / BHXH, BHYT, BHTN`**: **`1,050,000`** *(tức `8% + 1.5% + 1% = 10.5%` $\times$ `10,000,000 VNĐ`)*
     * **`Advance salary / Tạm ứng lương`**: **`2,000,000`** *(lấy từ `tblSal_Advance` đã `IsLock = 1` ở `TC-15`)*
   - **`Tổng khấu trừ / Total deduction:`** = **`3,050,000`** *(nếu không có trừ khác/công đoàn)*.
7. **Kiểm tra Mục `IV/ Thông tin khấu trừ thuế TNCN`**:
   - **Giảm trừ thuế bản thân**: **`15,500,000`** *(mức áp dụng từ 01/2026 trong bảng `tblTaxDeduction`)*
   - **Giảm trừ người phụ thuộc**: **`0`** *(nếu `DependantNumber = 0`)* hoặc **`6,200,000`** *(nếu `DependantNumber = 1`)*
   - **Thu nhập chịu thuế**: **`0`** *(do tổng thu nhập thực tế thấp hơn mức giảm trừ bản thân `15,500,000 VNĐ`)*
   - **Thuế TNCN phải đóng**: **`0`** *(nếu áp dụng biểu lũy tiến)*
8. **Kiểm tra Mục `V/ Thực lãnh`**:
   - **`THỰC LÃNH / NET TAKE HOME:`** Kiểm tra số tiền thực lãnh cuối cùng:
     * Phải **KHỚP TUYỆT ĐỐI 100%** với cột `GrossTakeHome` trong `tblSal_Sal` và trang phiếu lương hàng loạt của `099` đã xem tại `TC-18`!
     * *(Dừng 2–3 giây để đối soát trực quan toàn bộ phiếu lương trước khi sang `TC-20`)*.

---

### BƯỚC 5 [`TC-20`]: TƯƠNG TÁC 3 MODAL CON MẮT (👁️) & TAB `LỊCH SỬ` (`MnuPRL445`)
*(Kiểm tra khả năng truy vết nguồn gốc chi tiết từng buổi tăng ca, ngày nghỉ phép, vi phạm công và lịch sử phiếu lương theo năm)*

1. **Mở & Kiểm tra Modal 1 — Chi tiết tăng ca**:
   - Tại Mục `I/ Thông tin lương`, dòng **`Số giờ tăng ca:`** (`2 giờ`), nhấp vào biểu tượng **con mắt 👁️** ngay bên phải số `2 giờ`.
   - Quan sát Popup tiêu đề **`Chi tiết tăng ca`** bật lên, kiểm tra bảng gồm 4 cột (`Ngày` | `Giờ bắt đầu` | `Giờ kết thúc` | `Số giờ`) hiển thị đúng **1 dòng**:
     * **`20/10/2026`** | **`18:00`** | **`20:00`** | **`2 giờ`**
   - Nhấp nút **`×`** ở góc trên bên phải Popup để đóng.
2. **Mở & Kiểm tra Modal 2 — Chi tiết ngày nghỉ**:
   - Tại dòng **`Số ngày nghỉ:`** (`1 ngày`), nhấp vào biểu tượng **con mắt 👁️** ngay bên phải số `1 ngày`.
   - Quan sát Popup tiêu đề **`Chi tiết ngày nghỉ`** bật lên, kiểm tra bảng gồm 3 cột (`Ngày` | `Loại nghỉ` | `Số giờ`) hiển thị đúng **1 dòng**:
     * **`24/10/2026`** | **`AL`** | **`8 giờ`**
   - Nhấp nút **`×`** ở góc trên bên phải Popup để đóng.
3. **Mở & Kiểm tra Modal 3 — Chi tiết đi trễ/về sớm**:
   - Tại dòng **`Đi trễ/về sớm:`** (`0 ngày`), nhấp vào biểu tượng **con mắt 👁️** ngay bên phải số `0 ngày`.
   - Quan sát Popup tiêu đề **`Chi tiết đi trễ/về sớm`** bật lên, bảng gồm 4 cột (`Ngày` | `Giờ bắt đầu` | `Giờ kết thúc` | `Phút khấu trừ`) hiển thị thông báo rỗng chuẩn:
     * **`"Không có dữ liệu đi trễ/về sớm."`**
   - Nhấp nút **`×`** ở góc trên bên phải Popup để đóng.
4. **Kiểm tra Tab `Lịch Sử` & Bộ lọc năm (`#psYearSelect`)**:
   - Cuộn lên đầu trang `MnuPRL445`, nhấp chuyển sang tab **`Lịch Sử`** (bên cạnh tab **`Phiếu Lương`**).
   - Chờ danh sách lịch sử phiếu lương đã khóa của NV `099` tải xong.
   - Nhấp mở dropdown **Lọc theo năm** (`Tất cả các năm`) $\rightarrow$ Chọn **`2026`**.
   - Quan sát danh sách hiển thị mục **`Tháng 10/2026`** kèm số tiền **Thực lãnh** khớp với Mục `V/ Thực lãnh` và nút **`Xem`**.
   - Nhấp vào nút **`Xem`** trên dòng **`Tháng 10/2026`**.
   - Xác nhận hệ thống tự động chuyển về lại tab **`Phiếu Lương`** và nạp đúng dữ liệu **`Tháng/Năm: 10/2026`**.

---

### BƯỚC 6: ĐĂNG XUẤT KẾT THÚC FLOW & EXPORT FILE `.JSON` RECORDER
1. Nhấp vào **Avatar tài khoản** góc trên bên phải $\rightarrow$ Chọn **"Đăng xuất"** khỏi tài khoản `test.nv` để đưa hệ thống về trạng thái đăng nhập sạch.
2. Tại cửa sổ **Chrome DevTools $\rightarrow$ Recorder**:
   - Nhấp nút **"End recording"** màu đỏ ở góc dưới.
   - Nhấp biểu tượng **Export ($\downarrow$)** $\rightarrow$ Chọn **"Export as a JSON file"**.
   - Lưu file thành `fix8-recording.json` và gửi cho Agent để chuyển đổi thành kịch bản Replay `.spec.js` + `.sql` reset + `.bat` 1-Click theo **Điều 9 `AGENTS.md`**.

---

## 🎯 2. BỘ TRUY VẤN SQL ĐỐI SOÁT KẾT QUẢ CUỐI FLOW (READ-ONLY)

Sau khi hoàn thành xong các bước trên giao diện, mở **SSMS** trên CSDL `Vietinsoft_ForTest_Tai2` và chạy bộ truy vấn chỉ đọc (`SELECT`) dưới đây để đối soát 100% số liệu của NV `099` kỳ Tháng `10/2026`:

```sql
-- ============================================================================
-- ĐỐI SOÁT KẾT QUẢ TOÀN FLOW FIX-8 CHO NHÂN VIÊN 099 - THÁNG 10/2026 (READ-ONLY)
-- ============================================================================

-- 1. Bảng lương tổng hợp (tblSal_Sal) — Khớp nút [Bảng lương tổng hợp] trong Danh sách trả lương (MnuPRL092) & Mục I, II, V trên Phiếu lương (MnuPRL445)
SELECT EmployeeID, Month, Year, PeriodID,
       ActualMonthlyBasic, TaxableAllowance, NontaxableAllowance,
       TaxableAdjustment, NontaxableAdj, TotalIncome, TotalEarn,
       EmpUnion, IOAmt, IncomeAfterPIT, GrossTakeHome, Notes
FROM tblSal_Sal
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 2. Chi tiết công & lương ngày (tblSal_Sal_Detail) — Kiểm chứng StandardWDays & DaysOfSalEntry = 5.625
SELECT EmployeeID, Month, Year, PeriodID,
       SalCalRuleID, StandardWDays, ATTHours, WorkingHours, DaysOfSalEntry,
       BasicSalary, SalaryPerDay, SalaryPerHour, ActualMonthlyBasic,
       TaxableAdjustmentTotal_ForSalary, GrossTakeHome
FROM tblSal_Sal_Detail
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 3. Chi tiết Tăng ca OT (tblSal_OT_Detail) — Kiểm chứng 2.0h x 150% = 156,250 VNĐ
SELECT EmployeeID, Month, Year, OverTimeID, OTRate, OTHour,
       SalaryPerDay, SalaryPerHour, OTAmount, TaxableOTAmount, NoneTaxableOTAmount
FROM tblSal_OT_Detail
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 4. Chi tiết Nghỉ hưởng lương (tblSal_PaidLeave_Detail) — Kiểm chứng AL 1.0 ngày (8h) ngày 24/10
SELECT EmployeeID, Month, Year, LeaveCode, LeaveDays, LeaveHour, AmountPaid, AmountDeduct
FROM tblSal_PaidLeave_Detail
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 5. Chi tiết Đi trễ / Về sớm (tblSal_IO) — Kỳ vọng 0 dòng hoặc số tiền = 0
SELECT EmployeeID, Month, Year, InLateHours, OutEarlyHours, InLateAmount, OutEarlyAmount
FROM tblSal_IO
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 6. Thưởng KPI đầu vào & sau tính lương (tblPR_Adjustment & tblSal_Adjustment)
--    Lưu ý: sp_PaySlipView (MnuPRL445) lọc tblPR_Adjustment kèm tblIrregularIncome.ForSalary = 1
SELECT a.EmployeeID, a.Month, a.Year, a.IncomeID, ir.Description, ir.ForSalary, ir.IncomeKind, a.Amount, a.Remark
FROM tblPR_Adjustment a
LEFT JOIN tblIrregularIncome ir ON a.IncomeID = ir.IncomeID
WHERE a.EmployeeID = '099' AND a.Month = 10 AND a.Year = 2026;

SELECT EmployeeID, Month, Year, IncomeID, Amount, TaxableAmount, UntaxableAmount
FROM tblSal_Adjustment
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 7. Tạm ứng lương (tblSal_Advance) — Phải có IsLock = 1 mới hiện khấu trừ trên MnuPRL445
SELECT EmployeeID, Month, Year, BasicSalary, AttDays, AdvanceAmount, IsLock, Notes
FROM tblSal_Advance
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 8. Bảo hiểm NLĐ (tblSal_Insurance) — Kỳ vọng 10.5% x 10,000,000 = 1,050,000 VNĐ
SELECT EmployeeID, Month, Year, SIIncome, HIIncome, UIIncome,
       EmployeeSI, EmployeeHI, EmployeeUI, EmployeeTotal, Notes
FROM tblSal_Insurance
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

-- 9. Giảm trừ & Thuế TNCN (tblSal_Tax) + Hồ sơ NPT (tblFamilyInfo)
SELECT EmployeeID, Month, Year, IncomeTaxable, DeductionAmt,
       EmployeeExemption, FamilyExemption, DependantNumber, OTDeduction, TaxAmt, FixedPercents
FROM tblSal_Tax
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

SELECT FamilyInfoID, EmployeeID, Name, EffectiveDate, EffectiveToDate, TaxDependant
FROM tblFamilyInfo
WHERE EmployeeID = '099';

-- 10. Trạng thái khóa sổ kỳ lương (tblSal_Lock) — Điều kiện mở khóa Phiếu lương MnuPRL445
SELECT Month, Year, EmployeeID, PeriodID
FROM tblSal_Lock
WHERE Month = 10 AND Year = 2026 AND (EmployeeID = '099' OR EmployeeID = '-1')
ORDER BY EmployeeID;
```

---

## ✅ 3. TÓM TẮT TIÊU CHÍ PASS CHO `FIX-8`

| TC | Vai trò & Menu | Thao tác cốt lõi trên UI | Kết quả kỳ vọng (UI + CSDL) |
| :--- | :--- | :--- | :--- |
| **`TC-18`** | `chien.nguyen` (`Danh sách trả lương` - `MnuPRL092`) | Chọn `10/2026` $\rightarrow$ Kiểm tra `Tính lương` disabled $\rightarrow$ Bấm `Bảng lương tổng hợp` xem Excel preview $\rightarrow$ Bấm `Xem phiếu lương` lật tới `099` $\rightarrow$ Đăng xuất | Khung `#preview-body` hiển thị đủ bảng lương công ty & phiếu lương của `099 - Nguyễn Văn Test` (`5.625` công, `2h` OT, `Thực lãnh` khớp `tblSal_Sal.GrossTakeHome`) |
| **`TC-19`** | `test.nv` (`MnuPRL445`) | Mở `Phiếu Lương` $\rightarrow$ Xác nhận tự load `Tháng/Năm: 10/2026` $\rightarrow$ Kiểm tra định lượng các mục I $\rightarrow$ V | Công thực tế `5.625 ngày`, OT `2 giờ` (`156,250`), Nghỉ `1 ngày`, Trễ/sớm `0 ngày`, Khấu trừ BHXH `1,050,000` + Tạm ứng `2,000,000` = `3,050,000`, Giảm trừ bản thân `15,500,000`, Thực lãnh khớp 100% `TC-18` & `tblSal_Sal` |
| **`TC-20`** | `test.nv` (`MnuPRL445`) | Bấm 3 con mắt 👁️ (Tăng ca, Ngày nghỉ, Đi trễ/về sớm) $\rightarrow$ Tab `Lịch Sử` lọc năm `2026` $\rightarrow$ Bấm `Xem` kỳ `10/2026` $\rightarrow$ Đăng xuất & Export JSON | Modal OT hiện `20/10/2026 (18:00–20:00, 2 giờ)`; Modal Nghỉ hiện `24/10/2026 (AL, 8 giờ)`; Modal Đi trễ hiện `"Không có dữ liệu đi trễ/về sớm."`; Tab `Lịch Sử` liệt kê `Tháng 10/2026` và nút `Xem` mở lại đúng phiếu lương |
