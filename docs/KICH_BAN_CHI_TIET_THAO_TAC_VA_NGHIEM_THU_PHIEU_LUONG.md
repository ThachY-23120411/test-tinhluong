# ĐẶC TẢ KỊCH BẢN KIỂM THỬ THAO TÁC CHI TIẾT & LOGIC NGHIỆM THU E2E (AUTOMATION TEST SPEC)
# PHÂN HỆ PHIẾU LƯƠNG & CHUỖI 12 MENU LIÊN HOÀN (5 ROLES)

> **Mục đích tài liệu**: Tài liệu này đóng vai trò là **Bản vẽ kỹ thuật chi tiết (Master Action & Assertion Blueprint)** chuẩn bị sẵn cho Agent tự động hóa (`author-playwright-spec`) đọc và sinh mã nguồn Playwright `.spec.js` hoàn chỉnh 100% chuẩn mực, không lỗi, không đoán mò toạ độ hay selector, tuân thủ nghiêm ngặt **BỘ 9 LUẬT THÉP BẤT BIẾN CHỐNG FAKE PASS**.

---

## 📌 PHẦN 1: THIẾT LẬP MÔI TRƯỜNG, PHÂN ĐỊNH VAI TRÒ & QUY TRÌNH TÍNH LƯƠNG TOÀN CÔNG TY

* **URL hệ thống**: `https://paradisehrm.com/Tai3/#`
* **Cơ sở dữ liệu**: `Vietinsoft_ForTest_Tai2` (Server: `192.168.11.51,2222`)
* **Kỳ kiểm thử**: **Tháng 10/2026** (Kỳ mở hiện hành; hoặc **Tháng 09/2026** nếu muốn dùng sẵn 1,165 công quẹt thẻ trong DB).
* **Mật khẩu dùng chung cho tất cả tài khoản**: **`123`**

### 1. Bảng Danh Mục 5 Tài Khoản Test (Accounts Setup)

| STT | Mã Vai Trò | Username | Password | Mã NV (`EmployeeID`) | Họ và tên | Trách nhiệm thao tác trong kịch bản |
| :---: | :--- | :--- | :---: | :---: | :--- | :--- |
| **1** | `STAFF_DEV` | `tai.dang` | `123` | `046` | Đặng Minh Tài | Khởi tạo 3 đơn vận hành (Bù công, Nghỉ phép, Tăng ca) và Nghiệm thu Phiếu lương cuối cùng. |
| **2** | `DIRECTOR` | `chien.nguyen` | `123` | `013` | Nguyễn Tấn Chiến | Kế toán trưởng: Chạy Tính lương toàn công ty tại `MnuPRL040`, đối soát Bảng lương tổng hợp (Before/After) tại `MnuPRL092`/`MnuHRS145`, nhập KPI, khóa Tạm ứng và Khóa sổ. |
| **3** | `MANAGER_LEAVE`| `ThanhLong` | `123` | `011` | Nguyễn Thanh Long | Quản lý trực tiếp Cấp 1 thẩm định và duyệt **Đơn xin nghỉ phép năm**. |
| **4** | `MANAGER_OT` | `LongKa` | `123` | `012` | Nguyễn Trường Long | Quản lý trực tiếp Cấp 1 thẩm định và duyệt **Đơn xin làm thêm giờ (Tăng ca - OT)**. |
| **5** | `HR_ADMIN` | `cuong.vu` | `123` | `014` | Vũ Đình Cường | Quản lý Cấp 2 / Giám đốc phê duyệt chặng cuối cho **CẢ 2 ĐƠN** (Nghỉ phép & Tăng ca), ký mức Lương 10tr và NPT. |

### 2. Phân Định Nghiệp Vụ Cốt Lõi: AI SẼ TÍNH LƯƠNG CHO MỌI NGƯỜI & TÍNH Ở ĐÂU?

> [!IMPORTANT]
> **VẤN ĐỀ NGHIỆP VỤ: AI SẼ TÍNH LƯƠNG CHO MỌI NGƯỜI?**
> 1. **Về thẩm quyền & Vai trò**:
>    - **Kế toán tiền lương (`chien.nguyen` - Mã `013`)**: Là người trực tiếp phụ trách nghiệp vụ tính toán bảng lương định kỳ cho toàn thể nhân viên trong công ty.
>    - **Ban Giám đốc / HR Admin (`cuong.vu` - Mã `014`)**: Có quyền quản trị cao nhất (`isAdmin = True`), có thể kiểm tra, đối soát hoặc trực tiếp thực hiện tính lương nếu cần.
> 2. **Về phân nhiệm hai Menu tính toán & báo cáo trong hệ thống**:
>    - **Menu TÍNH LƯƠNG TOÀN CÔNG TY (`MnuPRL040` - "Tính tiền lương")**:
>      * Đây là **công cụ chuyên dụng chính thức** để tính lương cho **toàn bộ nhân viên công ty** (hoặc theo từng phòng ban).
>      * Selector chuẩn: Ô tháng `input[name="cbx@month"]`, ô năm `input[name="cbx@year"]`, nút bấm `button:has-text("Tính lương"), .btnreload`.
>      * Khi Kế toán/Admin chọn Tháng/Năm và bấm nút **"Tính lương"**, hệ thống kích hoạt Stored Procedure `SALCAL_MAIN` quét toàn bộ nhân viên có hợp đồng lương $> 0$ và lưu dữ liệu vào bảng `tblSal_Sal`.
>      * *(Lưu ý: Màn hình này là form chạy tác vụ ngầm, sau khi tính xong lưới hiển thị chữ mặc định "Không có dữ liệu" là hoàn toàn bình thường vì thủ tục chỉ ghi dữ liệu vào CSDL chứ không SELECT ra lưới)*.
>    - **Menu XEM BÁO CÁO TỔNG HỢP & KHÓA SỔ (`MnuPRL092` - "Danh sách trả lương")**:
>      * Đây là nơi để Kế toán và Ban Giám đốc **xem Bảng lương tổng hợp toàn công ty** bằng cách bấm nút **"Bảng lương tổng hợp" (`#btnPrint`)** (hiển thị iframe danh sách mọi người: Cường, Long, Chiến, và dòng 3 là Đặng Minh Tài `046`).
>      * Sau khi đối soát xong, bấm nút **"Khoá lương" (`#btnLock`)** để niêm phong bảng lương Tháng 10 và mở quyền cho từng nhân viên xem phiếu lương cá nhân.
>      * *(Lưu ý: Nút "Tính lương" trên menu `MnuPRL092` không dùng để tính cho cả công ty vì mã nguồn chỉ truyền tham số `@EmployeeID = window.EmployeeID` tính cho riêng người đang đăng nhập, và đang bị vướng bug kiểm tra chuỗi tiếng Việt "chưa khóa công")*.

---

## 🛠️ PHẦN 2: BẢNG TRA CỨU SELECTOR DOM & HÀM ĐIỀU KHIỂN DÙNG CHUNG

### 1. Hàm Di Chuột & Click Trực Quan (Neon Mouse Pointer)
```javascript
async function moveAndClick(page, locator, options = {}) {
  const timeout = options.timeout || 8000;
  await locator.waitFor({ state: 'visible', timeout }).catch(() => {});
  await locator.scrollIntoViewIfNeeded({ timeout: 4000 }).catch(() => {});
  const box = await locator.boundingBox().catch(() => null);
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 10 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click({ force: true, timeout: 5000 }).catch(async () => {
    await locator.evaluate((el) => el.click()).catch(() => {});
  });
}
```

### 2. Hàm Chuyển Menu An Toàn Bằng JavaScript (Anti-Stale Navigation)
Thay vì click dò dẫm trên DOM thanh Dock phức tạp, luôn ưu tiên mở trực tiếp qua API nền tảng:
```javascript
await page.evaluate((menuId) => {
  if (typeof OpenAppInSidebar === 'function') OpenAppInSidebar(menuId);
  else if (typeof openMenu === 'function') openMenu(menuId);
}, 'MnuPRL445');
```

### 3. Bộ Selectors Chuẩn Hóa Của Các Thành Phần Hệ Thống
* **Đăng nhập**: 
  - Ô Tài khoản: `input[name="username"], input.dx-texteditor-input, textbox:has-text("Tên đăng nhập")`
  - Ô Mật khẩu: `input[type="password"]`
  - Nút Đăng nhập: `button:has-text("Đăng nhập"), button.btnLogin`
* **Modal Xác Nhận Bắt Buộc (Luật thép 3)**:
  - Hộp thoại: `#vc-vu-confirm-popup`
  - Nút Đồng ý: `#vc-vu-confirm-popup .VC-Vu-btn-ok, button.VC-Vu-btn-ok:has-text("Đồng ý")`
* **Thẻ Top 1 trong Tab Lịch Sử**:
  - Container lịch sử: `.tab-history-container, .history-list`
  - Thẻ mới nhất: `.history-item, .card-history, .dx-card:first-child`
* **Menu Phiếu Lương Chính Thức Nhân Viên (`MnuPRL445`)**:
  - Container chính: `#sp_salaryslip_html`
  - Lương cơ bản: `#psBasicSalary`
  - Công chuẩn: `#psStdDays`
  - Công thực tế: `#psActDays`
  - Tiền OT: `#psOTSalary` (Icon mắt: `#psOTEye, .eye-ot`)
  - Số ngày nghỉ: `#psDaysOff` (Icon mắt: `#psLeaveEye, .eye-leave`)
  - Đi trễ/về sớm: `#psLateEarly` (Icon mắt: `#psIOEye, .eye-io`)
  - Thu nhập khác: `#psTotalOther`
  - Thưởng KPI: `#psAdjustment`
  - Khấu trừ tạm ứng: `#psAdvance`
  - Giảm trừ NPT: `#psDepTax`
  - Lương thực lĩnh: `#psNetSalary`
  - Tab Lịch sử: `#tabHistory, button:has-text("Lịch Sử")`
* **Menu Tính Tiền Lương Toàn Công Ty (`MnuPRL040` - ClassName: `SALCAL_MAIN`)**:
  - Container chính: `#dynamic-pane-MnuPRL040`
  - Ô chọn Tháng: `input[name="cbx@month"]`
  - Ô chọn Năm: `input[name="cbx@year"]`
  - Nút Tính lương: `#dynamic-pane-MnuPRL040 button:has-text("Tính lương"), .btnreload`
* **Menu Danh Sách Trả Lương & Báo Cáo Tổng Hợp (`MnuPRL092` - Trung tâm điều hành Kế toán)**:
  - Container chính: `#CompanySalarySummary`
  - Nút Bảng lương tổng hợp: `#btnPrint, button:has-text("Bảng lương tổng hợp")`
  - Nút Xem phiếu lương nháp: `#btnView, button:has-text("Xem phiếu lương")`
  - Nút Khoá lương chốt sổ: `#btnLock, button:has-text("Khoá lương")`
  - Nút Tính lương cá nhân: `#btnCalculate, button:has-text("Tính lương")`
  - Nút Khóa / Mở khóa công: `#btnOpenAttendanceLock`
  - Trạng thái khóa công: `#attendanceLockQuickStatus`
  - Lật trang phiếu lương nháp: Nút Lùi `#btnPrev`, Nút Tiến `#btnNext`, Ô nhập trang `.pdf-page-input`
  - Vùng render phiếu lương nháp / Bảng lương: `#preview-container, #preview-body, iframe`

---

## 🎯 PHẦN 3: KỊCH BẢN CHI TIẾT 15 TEST CASES (E2E STEP-BY-STEP)

---

### 🔹 GIAI ĐOẠN 1: NHÂN VIÊN GỬI ĐƠN VẬN HÀNH (ROLE: `tai.dang`)

#### [TC-01]: Gửi đơn "Xin bù công" xóa vi phạm quẹt thẻ ngày 15/10/2026
* **Mục đích**: Bổ sung giờ công vào ca sáng, xóa phạt đi trễ cho ngày 15/10/2026.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. `Di chuột tới` ô Tài khoản $\rightarrow$ `Click` $\rightarrow$ `Nhập text`: `tai.dang`.
  2. `Di chuột tới` ô Mật khẩu $\rightarrow$ `Click` $\rightarrow$ `Nhập text`: `123`.
  3. `Di chuột tới` button `Đăng nhập` $\rightarrow$ `Click`.
  
  > **BƯỚC CHỐT CHẶN: KIỂM TRA HIỆN TRẠNG BAN ĐẦU (LÚC TRƯỚC - BEFORE CHECK)**:
  > *Trước khi gửi đơn, người kiểm thử bắt buộc phải mở menu chấm công để ghi nhận số liệu Lúc trước làm mốc đối chiếu (Baseline)*:
  4. Mở menu Xem dữ liệu chấm công: Gọi hàm `OpenAppInSidebar('MnuHRS225')`.
     - Lọc Từ ngày `01/10/2026` đến `31/10/2026`, gõ tìm `046`.
     - Soi dòng ngày **`15/10/2026`**:
       * Cột `GIỜ VÀO`: **`[--:--]`** (trống, chưa có giờ quẹt thẻ).
       * Cột `CÔNG NGÀY`: **`0.0 công`** ($0.0\text{ giờ}$).
       * Cột `TRẠNG THÁI`: Báo **`Thiếu giờ quẹt`**.
  5. Mở menu Tổng hợp công tháng: Gọi hàm `OpenAppInSidebar('MnuTAD1000')`.
     - Chọn Tháng `10`, Năm `2026`, gõ tìm `046`.
     - Ghi nhận `NGÀY CÔNG` hiện tại (Lúc trước): **`21.0 ngày`** (hụt mất ngày 15/10).
  
  > **BƯỚC NỘP ĐƠN BÙ CÔNG (ACTION STEPS)**:
  6. Gọi hàm mở menu: `OpenAppInSidebar('MnuHRS033')`.
  7. Chờ Form Bù công xuất hiện:
     - `Di chuột tới` ô `Ngày bù công` (`#AttDate` hoặc `dxDateBox`) $\rightarrow$ `Click` $\rightarrow$ Nhập/chọn ngày: `15/10/2026`.
     - `Di chuột tới` ô `Loại bù công` (`#ReasonCode` hoặc `dxSelectBox`) $\rightarrow$ `Click` $\rightarrow$ Chọn mục: `Quên quẹt thẻ vào đầu ca`.
     - `Di chuột tới` ô `Giờ bổ sung thực tế` (`#TimeIn`) $\rightarrow$ `Click` $\rightarrow$ Nhập: `08:00`.
     - `Di chuột tới` ô `Lý do` (`textarea#Note`) $\rightarrow$ `Click` $\rightarrow$ Nhập chuỗi Fingerprint: `[TEST_LUONG] Quên quẹt thẻ sáng 15/10 do tiếp khách tại sảnh - [${Date.now()}]`.
  8. `Di chuột tới` button `Lưu` / `Gửi đơn` (`button.btnRegister, button:has-text("Lưu")`) $\rightarrow$ `Click`.
  9. **Chặn Popup Xác Nhận (Luật thép 3)**:
     - Chờ modal `#vc-vu-confirm-popup` hiển thị (timeout 5s).
     - `Di chuột tới` button xanh `Đồng ý` (`.VC-Vu-btn-ok`) $\rightarrow$ `Click`.
  10. `Di chuột tới` tab `Lịch sử` $\rightarrow$ `Click`.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Thẻ đầu tiên (Top 1) trong tab Lịch sử phải chứa ngày `15/10/2026`, giờ `08:00`, đúng chuỗi lý do kèm timestamp, và trạng thái hiển thị: `Chờ duyệt` (Pending).
  * **Database**:
    ```sql
    SELECT TOP 1 EmployeeID, CONVERT(varchar, AttDate, 23) AS AttDate, Approve_Status 
    FROM tblAttendanceConfirmRequest 
    WHERE EmployeeID = '046' ORDER BY RequestDate DESC;
    ```
    *Kỳ vọng*: `EmployeeID = '046'`, `AttDate = '2026-10-15'`, `Approve_Status = 0`.

---

#### [TC-02]: Gửi đơn "Xin nghỉ phép năm" hưởng 100% lương ngày 24/10/2026
* **Mục đích**: Khởi tạo 1 ngày nghỉ phép năm AL hưởng nguyên lương, nuôi trường `#psDaysOff` trên phiếu lương.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Gọi hàm mở menu: `OpenAppInSidebar('MnuWPT315')`.
  2. Chờ Form Xin nghỉ phép xuất hiện:
     - `Di chuột tới` dropdown `Loại phép` (`#LeaveCode` hoặc `dxSelectBox`) $\rightarrow$ `Click` $\rightarrow$ Chọn: `Phép năm (AL)`.
     - `Di chuột tới` ô `Từ ngày` (`#FromDate`) $\rightarrow$ Đặt giá trị ngày giờ: `2026-10-24 08:00:00`.
     - `Di chuột tới` ô `Đến ngày` (`#ToDate`) $\rightarrow$ Đặt giá trị ngày giờ: `2026-10-24 17:00:00`.
     - Xác nhận hệ thống tự tính: `Số ngày nghỉ = 1 ngày` (8 giờ).
     - `Di chuột tới` ô `Lý do` (`textarea#Note`) $\rightarrow$ `Click` $\rightarrow$ Nhập: `[TEST_LUONG] Giải quyết việc gia đình cá nhân - [${Date.now()}]`.
  3. `Di chuột tới` button `Đăng ký` (`button.btnRegister`) $\rightarrow$ `Click`.
  4. Chờ modal `#vc-vu-confirm-popup` xuất hiện $\rightarrow$ `Di chuột tới` button `Đồng ý` (`.VC-Vu-btn-ok`) $\rightarrow$ `Click`.
  5. `Di chuột tới` tab `Lịch sử` $\rightarrow$ `Click`.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Thẻ Top 1 trong tab Lịch sử hiển thị đúng ngày `24/10/2026`, loại `Phép năm (AL)`, thời lượng `1 ngày`, trạng thái `Chờ duyệt`.
  * **Database**:
    ```sql
    SELECT TOP 1 EmployeeID, LeaveCode, Days, ApproveStatus 
    FROM tblLvHistory 
    WHERE EmployeeID = '046' ORDER BY RequestDate DESC;
    ```
    *Kỳ vọng*: `LeaveCode = 'AL'`, `Days = 1.0`, `ApproveStatus = 0`.

---

#### [TC-03]: Gửi đơn "Xin làm thêm giờ (Tăng ca - OT)" 2 giờ ngày 20/10/2026
* **Mục đích**: Phát sinh 2 giờ OT hệ số 150%, sinh thu nhập tăng ca trên phiếu lương.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Gọi hàm mở menu: `OpenAppInSidebar('MnuWPT316')`.
  2. Chờ Form Xin tăng ca xuất hiện:
     - `Di chuột tới` ô `Ngày tăng ca` (`#OTDate`) $\rightarrow$ `Click` $\rightarrow$ Chọn ngày: `20/10/2026`.
     - `Di chuột tới` ô `Từ giờ` $\rightarrow$ Nhập `18:00`.
     - `Di chuột tới` ô `Đến giờ` $\rightarrow$ Nhập `20:00` (Xác nhận hệ thống tính `2.0 giờ`).
     - `Di chuột tới` dropdown `Loại tăng ca / Hệ số` $\rightarrow$ Chọn `Ngày thường (150%)`.
     - `Di chuột tới` ô `Lý do` $\rightarrow$ Nhập: `[TEST_LUONG] OT hỗ trợ triển khai hệ thống - [${Date.now()}]`.
  3. `Di chuột tới` button `Đăng ký` $\rightarrow$ `Click`.
  4. Chờ modal `#vc-vu-confirm-popup` $\rightarrow$ `Di chuột tới` button `Đồng ý` $\rightarrow$ `Click`.
  5. `Di chuột tới` tab `Lịch sử` $\rightarrow$ `Click`.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Thẻ Top 1 trong Lịch sử hiển thị ngày `20/10/2026`, số giờ `2.0 giờ`, hệ số `150%`, trạng thái `Chờ duyệt`.
  * **Database**:
    ```sql
    SELECT TOP 1 EmployeeID, CONVERT(varchar, OTDate, 23) AS OTDate, OTHours, Status 
    FROM tblOverTimeRegistration 
    WHERE EmployeeID = '046' ORDER BY RegDate DESC;
    ```
    *Kỳ vọng*: `OTHours = 2.0`, `Status = 0`.
  6. `Di chuột tới` icon Avatar góc trên bên phải $\rightarrow$ `Click` $\rightarrow$ `Di chuột tới` mục `Đăng xuất` $\rightarrow$ `Click`.

---

### 🔹 GIAI ĐOẠN 2: KẾ TOÁN TÍNH LƯƠNG LẦN 1 & ĐỐI SOÁT BẢNG LƯƠNG BAN ĐẦU (BEFORE) (ROLE: `chien.nguyen`)
> [!IMPORTANT]
> **TIỀN ĐỀ BẮT BUỘC TRƯỚC KHI DUYỆT ĐƠN**:
> Kế toán tiền lương (`chien.nguyen`) mở menu chuyên dụng **`Tính tiền lương` (`MnuPRL040`)** bấm Tính lương Lần 1 để kích hoạt `SALCAL_MAIN` tính toán và sinh dữ liệu bảng lương gốc vào `tblSal_Sal` cho **toàn bộ nhân viên công ty**. Sau đó:
> - Mở menu **`Danh sách trả lương` (`MnuPRL092`)** bấm **`Bảng lương tổng hợp` (`#btnPrint`)** để xem tổng thể toàn công ty trong iframe (dòng 3 hiển thị `046 - Đặng Minh Tài`).
> - Mở menu **`Lương nhân viên` (`MnuHRS145`)** tìm `046` để đối soát số liệu gốc (Baseline Before). Lúc này vì các đơn chưa được duyệt: Tiền OT = `0 đ`, Phép = `0 ngày`, vẫn bị trừ phạt đi trễ ngày 15/10.

#### [TC-04]: Chạy "Tính lương" LẦN 1 & Đối soát Bảng lương nhân viên ban đầu "Before" (Menu: `MnuPRL040`, `MnuPRL092` & `MnuHRS145`)
* **Mục đích**: Kế toán kích hoạt tính toán lương toàn công ty ban đầu tại menu chuyên dụng `MnuPRL040`, sau đó kiểm tra Bảng lương tổng hợp tại `MnuPRL092` và đối soát số liệu cơ sở của nhân viên 046 trên lưới Lương nhân viên trước khi các đơn từ được duyệt.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Đăng nhập tài khoản Kế toán: `Username = chien.nguyen`, `Password = 123`.
  2. **Thao tác Tính lương toàn công ty tại `MnuPRL040`**:
     - Mở menu Tính tiền lương: `OpenAppInSidebar('MnuPRL040')`.
     - Chờ container `#dynamic-pane-MnuPRL040` hiển thị hoàn tất.
     - Tại ô chọn Tháng (`input[name="cbx@month"]`): Chọn hoặc nhập `10` (hoặc `9`).
     - Tại ô chọn Năm (`input[name="cbx@year"]`): Chọn hoặc nhập `2026`.
     - `Di chuột tới` button `Tính lương` (`#dynamic-pane-MnuPRL040 button:has-text("Tính lương"), .btnreload`) $\rightarrow$ `Click`.
     - Chờ hệ thống thực thi xong tác vụ tính toán ngầm `SALCAL_MAIN` (lưới hiển thị "Không có dữ liệu" là trạng thái hoàn tất thành công của form chạy tác vụ).
  3. **Thao tác Xem Bảng lương tổng hợp tại `MnuPRL092`**:
     - Mở menu Danh sách trả lương: `OpenAppInSidebar('MnuPRL092')`.
     - Tại dropdown Tháng: Chọn `10`, Năm: `2026`.
     - `Di chuột tới` button `Bảng lương tổng hợp` (`#btnPrint, button:has-text("Bảng lương tổng hợp")`) $\rightarrow$ `Click`.
     - Chờ iframe kết xuất bảng lương hiển thị: Đối soát dòng số 3 chứa `046 - Đặng Minh Tài` (chức danh Kỹ sư phần mềm, bộ phận R&D).
  4. **Thao tác Đối soát số liệu chi tiết Before tại `MnuHRS145`**:
     - Mở menu Lương nhân viên: `OpenAppInSidebar('MnuHRS145')`.
     - Tại ô tìm kiếm trên thanh toolbar của lưới: Nhập `046` (hoặc `Đặng Minh Tài`).
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI (`MnuHRS145` - Bảng lương Trước biến động)**:
    - Cột Mã NV: `046` | Họ và tên: `Đặng Minh Tài`.
    - `Lương cơ bản`: `10,000,000 VNĐ`.
    - `Tiền làm thêm giờ (OT)`: `0 đ` (Vì đơn OT chưa được duyệt).
    - `Nghỉ phép hưởng lương`: `0 ngày` (Vì đơn nghỉ phép AL chưa được duyệt).
    - `Thưởng KPI`: `0 đ`.
    - `Khấu trừ tạm ứng`: `0 đ`.
  * **Database**:
    ```sql
    SELECT COUNT(*) AS SalCount FROM tblSal_Sal WHERE Month = 10 AND Year = 2026;
    SELECT ActualMonthlyBasic FROM tblSal_Sal WHERE EmployeeID = '046' AND Month = 10 AND Year = 2026;
    ```
    *Kỳ vọng*: `SalCount > 0`, `ActualMonthlyBasic` được tính toán thành công.
  10. Đăng xuất tài khoản `chien.nguyen`.

---

### 🔹 GIAI ĐOẠN 3: PHÊ DUYỆT ĐA CẤP PHÂN QUYỀN CHUYÊN BIỆT (ROLE: `ThanhLong`, `LongKa`, `cuong.vu`)

#### [TC-05]: Quản lý Cấp 1 (`ThanhLong`) phê duyệt Đơn xin nghỉ phép năm (Menu: `MnuWPT037`)
* **Mục đích**: Đúng phân quyền chuyên môn: Quản lý `ThanhLong` (011) thẩm định và duyệt Cấp 1 cho Đơn xin nghỉ phép năm ngày 24/10 của Đặng Minh Tài.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Đăng nhập tài khoản: `Username = ThanhLong`, `Password = 123`.
  2. Mở menu Danh sách phê duyệt: `OpenAppInSidebar('MnuWPT037')`.
  3. Tại ô tìm kiếm: Nhập `046` (hoặc `Đặng Minh Tài`).
  4. `Di chuột tới` dòng đơn **Xin nghỉ phép ngày 24/10/2026** $\rightarrow$ `Click` mở chi tiết.
  5. `Di chuột tới` button `Duyệt` (`button.btnApprove, button:has-text("Duyệt")`) $\rightarrow$ `Click`.
  6. Modal xác nhận hiện ra $\rightarrow$ `Click` `Đồng ý`. Chờ thông báo duyệt thành công.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Đơn nghỉ phép chuyển trạng thái sang `Đã duyệt Cấp 1`.
  * **Database**:
    ```sql
    SELECT EmployeeID, LeaveCode, ApproveStatus FROM tblLvHistory WHERE EmployeeID = '046' AND LeaveDate = '2026-10-24';
    ```
    *Kỳ vọng*: `ApproveStatus = 1` (Đã qua xét duyệt Cấp 1 của `ThanhLong`).
  7. Đăng xuất tài khoản `ThanhLong`.

---

#### [TC-06]: Quản lý Cấp 1 (`LongKa`) phê duyệt Đơn xin làm thêm giờ - Tăng ca OT (Menu: `MnuWPT037`)
* **Mục đích**: Đúng phân quyền chuyên môn: Quản lý `LongKa` (012) thẩm định và duyệt Cấp 1 cho Đơn xin làm thêm giờ (OT 2h) ngày 20/10 của Đặng Minh Tài.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Đăng nhập tài khoản: `Username = LongKa`, `Password = 123`.
  2. Mở menu Danh sách phê duyệt: `OpenAppInSidebar('MnuWPT037')`.
  3. Tại ô tìm kiếm: Nhập `046` (hoặc `Đặng Minh Tài`).
  4. `Di chuột tới` dòng đơn **Xin làm thêm giờ ngày 20/10/2026 (OT 2.0 giờ)** $\rightarrow$ `Click` mở chi tiết.
  5. `Di chuột tới` button `Duyệt` (`button.btnApprove, button:has-text("Duyệt")`) $\rightarrow$ `Click`.
  6. Modal xác nhận hiện ra $\rightarrow$ `Click` `Đồng ý`. Chờ thông báo duyệt thành công.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Đơn tăng ca chuyển trạng thái sang `Đã duyệt Cấp 1`.
  * **Database**:
    ```sql
    SELECT EmployeeID, OTHours, Status FROM tblOverTimeRegistration WHERE EmployeeID = '046' AND OTDate = '2026-10-20';
    ```
    *Kỳ vọng*: `Status = 1` (Đã qua xét duyệt Cấp 1 của `LongKa`).
  7. Đăng xuất tài khoản `LongKa`.

---

#### [TC-07]: Quản lý Cấp 2 / Giám đốc (`cuong.vu`) phê duyệt hoàn tất chặng cuối CẢ 2 ĐƠN (Nghỉ phép & Tăng ca) và Đơn bù công
* **Mục đích**: Phê duyệt chặng cuối (Final Approval) cho toàn bộ chuỗi đơn từ để nạp chính thức vào bảng chấm công `tblHasTA` và tổng hợp công.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Đăng nhập tài khoản: `Username = cuong.vu`, `Password = 123`.
  2. Mở menu Danh sách phê duyệt: `OpenAppInSidebar('MnuWPT037')`.
  3. Lọc tìm kiếm nhân viên `046`.
  4. **Duyệt Cấp 2 Đơn Nghỉ phép**: Mở đơn Nghỉ phép 24/10 $\rightarrow$ `Di chuột tới` button `Duyệt` $\rightarrow$ `Click` $\rightarrow$ Xác nhận.
  5. **Duyệt Cấp 2 Đơn Tăng ca**: Mở đơn Tăng ca 20/10 $\rightarrow$ `Di chuột tới` button `Duyệt` $\rightarrow$ `Click` $\rightarrow$ Xác nhận.
  6. **Duyệt Đơn Bù công 15/10**: Mở đơn Bù công $\rightarrow$ `Di chuột tới` button `Duyệt` $\rightarrow$ `Click` $\rightarrow$ Xác nhận.
  
  > **BƯỚC ĐỐI SOÁT CHỐT CHẶN: SO SÁNH DELTA LÚC SAU (AFTER) VS LÚC TRƯỚC (BEFORE)**:
  7. Mở menu Xem chấm công: Gọi hàm `OpenAppInSidebar('MnuHRS225')`:
     - Lọc Từ ngày `01/10/2026` đến `31/10/2026`, gõ tìm `046`.
     - Soi dòng ngày **`15/10/2026`**:
       * Cột `GIỜ VÀO`: Nhảy từ `[--:--]` (Lúc trước ở TC-01) $\rightarrow$ **`08:00`** (Lúc sau).
       * Cột `CÔNG NGÀY`: Nhảy từ `0.0 giờ` $\rightarrow$ **`8.0 giờ (1.0 công)`**.
       * Cột `TRẠNG THÁI`: Chuyển từ `Thiếu giờ quẹt` $\rightarrow$ **`Hợp lệ / Có chấm công`**.
  8. Mở menu Tổng hợp công tháng: Gọi hàm `OpenAppInSidebar('MnuTAD1000')`:
     - Chọn Tháng `10`, Năm `2026`, gõ tìm `046`.
     - Soi cột `NGÀY CÔNG`: Nhảy từ **`21.0 ngày`** (Lúc trước ở TC-01) $\rightarrow$ **`23.0 ngày`** (Lúc sau - Tăng đúng $+2.0\text{ ngày}$ gồm $+1.0\text{ ngày}$ bù công 15/10 và $+1.0\text{ ngày}$ phép năm AL 24/10).
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Cả 3 đơn đạt trạng thái cao nhất `Đã duyệt hoàn tất` (Final Approved). Bảng đối soát Before vs After khớp 100%.
  * **Database**:
    ```sql
    SELECT TOP 1 Approve FROM tblHasTA WHERE EmployeeID = '046' AND AttDate = '2026-10-15';
    SELECT TOP 1 Approved FROM tblOTList WHERE EmployeeID = '046' AND OTDate = '2026-10-20';
    ```
    *Kỳ vọng*: Toàn bộ cờ `Approved = 1`, `tblHasTA` xóa vi phạm quẹt thẻ ngày 15/10.

---

#### [TC-08]: Nhân sự (`cuong.vu`) thiết lập Tiền đề Hồ sơ & Lương 10,000,000 VNĐ + 1 NPT (Menu: `MnuHRS145` & `MnuHRS157`)
* **Mục đích**: Thiết lập mức lương cơ bản 10tr xóa chặn `TotalSalary <= 0` và đăng ký 1 Người phụ thuộc giảm trừ gia cảnh.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Mở menu Lương nhân viên: `OpenAppInSidebar('MnuHRS145')`.
  2. Tại ô Tìm kiếm trên thanh toolbar của lưới: Nhập `046`.
  3. `Di chuột tới` dòng của `046 - Đặng Minh Tài` $\rightarrow$ `Double click` mở popup `Chi tiết lương nhân viên`.
  4. Nhập mức lương `10000000`, lương BHXH `10000000`, ngày hiệu lực `01/10/2026` $\rightarrow$ Bấm `Lưu`.
  5. Mở menu Thông tin gia đình: `OpenAppInSidebar('MnuHRS157')` $\rightarrow$ Bấm `+ Thêm mới`.
  6. Nhập: NV `046`, Họ tên `Đặng Minh Khang`, Quan hệ `Con`, Ngày sinh `15/05/2024`, MST `8639998888`, Tích chọn `Người phụ thuộc thuế`, Ngày hiệu lực `01/10/2026` $\rightarrow$ Bấm `Lưu`.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **Database**:
    ```sql
    SELECT TOP 1 Salary, InsSalary FROM tblSalaryHistory WHERE EmployeeID = '046' ORDER BY Date DESC;
    SELECT COUNT(*) AS DependantCount FROM tblFamilyInfo WHERE EmployeeID = '046' AND TaxDependant = 1;
    ```
    *Kỳ vọng*: `Salary = 10000000.0000`, `DependantCount = 1`.
  7. Đăng xuất tài khoản `cuong.vu`.

---

### 🔹 GIAI ĐOẠN 4: KẾ TOÁN NẠP BIẾN ĐỘNG TÀI CHÍNH, TÍNH LƯƠNG LẦN 2 & KHÓA SỔ (ROLE: `chien.nguyen`)

#### [TC-09]: Đăng nhập Kế toán trưởng & Nhập Thưởng KPI 1,000,000 VNĐ (Menu: `MnuPRL036`)
* **Mục đích**: Bổ sung khoản thu nhập bất thường hưởng trọn vẹn trong tháng 10.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Đăng nhập tài khoản: `Username = chien.nguyen`, `Password = 123`.
  2. Mở menu Thu nhập không cố định: `OpenAppInSidebar('MnuPRL036')`.
  3. `Di chuột tới` button `+ Thêm mới` $\rightarrow$ `Click`.
  4. Nhập form:
     - `Di chuột tới` dropdown `Nhân viên` $\rightarrow$ Chọn `046 - Đặng Minh Tài`.
     - `Di chuột tới` ô `Kỳ lương` $\rightarrow$ Chọn Tháng `10`, Năm `2026`.
     - `Di chuột tới` dropdown `Loại thu nhập` $\rightarrow$ Chọn `Thưởng hiệu quả công việc / KPI` (`IncomeKind = 1`).
     - `Di chuột tới` ô `Số tiền` $\rightarrow$ Nhập: `1000000`.
     - `Di chuột tới` ô `Ghi chú` $\rightarrow$ Nhập: `[TEST_LUONG] Thưởng xuất sắc dự án tháng 10`.
  5. `Di chuột tới` button `Lưu` $\rightarrow$ `Click`.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Dòng thưởng KPI 1,000,000 đ xuất hiện trên lưới `MnuPRL036`.
  * **Database**:
    ```sql
    SELECT Amount, IncomeKind FROM tblPR_Adjustment WHERE EmployeeID = '046' AND Month = 10 AND Year = 2026;
    ```
    *Kỳ vọng*: `Amount = 1000000.0000`, `IncomeKind = 1`.

---

#### [TC-10]: Nhập và KHÓA Phiếu Tạm ứng lương 2,000,000 VNĐ (Menu: `MnuPRL070`) [BẮT BUỘC isLock = 1]
* **Mục đích**: Khởi tạo khoản tạm ứng và thực hiện khóa phiếu để hệ thống trừ vào thu nhập thực lĩnh.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Mở menu Tạm ứng lương: `OpenAppInSidebar('MnuPRL070')`.
  2. `Di chuột tới` button `+ Thêm mới` $\rightarrow$ `Click`.
  3. Nhập form:
     - `Di chuột tới` dropdown `Nhân viên` $\rightarrow$ Chọn `046 - Đặng Minh Tài`.
     - `Di chuột tới` ô `Số tiền tạm ứng` $\rightarrow$ Nhập: `2000000`.
     - `Di chuột tới` ô `Ngày tạm ứng` $\rightarrow$ Nhập: `18/10/2026`.
     - `Di chuột tới` ô `Lý do` $\rightarrow$ Nhập: `[TEST_LUONG] Tạm ứng giải quyết việc cá nhân`.
  4. `Di chuột tới` button `Lưu` $\rightarrow$ `Click`.
  5. **Thao tác chốt chặn bắt buộc (isLock = 1)**:
     - `Di chuột tới` dòng tạm ứng vừa tạo $\rightarrow$ Click chọn.
     - `Di chuột tới` button `Duyệt & Khóa tạm ứng` (hoặc tích chọn ô `Khóa / Lock`) $\rightarrow$ `Click`.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Cột `Đã khóa` trên lưới hiển thị dấu tích xanh.
  * **Database**:
    ```sql
    SELECT AdvanceAmount, isLock FROM tblSal_Advance WHERE EmployeeID = '046' AND Month = 10 AND Year = 2026;
    ```
    *Kỳ vọng*: `AdvanceAmount = 2000000.0000`, `isLock = 1`.

---

#### [TC-11]: Chạy "Tính lương" LẦN 2 & Đối soát biến động trên Bảng lương nhân viên "After" (Menu: `MnuPRL040`, `MnuPRL092` & `MnuHRS145`)
* **Mục đích**: Tái tính toán tại menu chuyên dụng `MnuPRL040` cho toàn công ty, kiểm tra Bảng lương tổng hợp tại `MnuPRL092` và tận mắt đối soát số liệu nhân viên 046 cập nhật toàn bộ 5 biến động vừa nộp và duyệt (OT, Bù công, Phép năm, Thưởng KPI, Tạm ứng).
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. **Thao tác Tính lương Lần 2 tại `MnuPRL040`**:
     - Mở menu Tính tiền lương: `OpenAppInSidebar('MnuPRL040')`.
     - Vẫn giữ Tháng `10`, Năm `2026`.
     - `Di chuột tới` button `Tính lương` (`#dynamic-pane-MnuPRL040 button:has-text("Tính lương"), .btnreload`) $\rightarrow$ `Click` lần 2!
     - Chờ hệ thống thực thi xong `SALCAL_MAIN` toàn công ty, nạp toàn bộ dữ liệu OT, phép, tạm ứng và KPI vào bảng lương.
  2. **Thao tác Đối soát Bảng lương tổng hợp tại `MnuPRL092`**:
     - Mở menu Danh sách trả lương: `OpenAppInSidebar('MnuPRL092')`.
     - `Di chuột tới` button `Bảng lương tổng hợp` (`#btnPrint`) $\rightarrow$ `Click`.
     - Xem kết xuất iframe kiểm tra các cột số liệu biến động của nhân viên công ty.
  3. **Thao tác Đối soát chi tiết After tại `MnuHRS145`**:
     - Mở menu Lương nhân viên: `OpenAppInSidebar('MnuHRS145')`.
     - Tại ô tìm kiếm trên thanh toolbar của lưới: Nhập `046` (hoặc `Đặng Minh Tài`).
* **Logic nghiệm thu đối soát Delta trên Bảng Lương (LẦN 1 vs LẦN 2)**:
  * **UI `MnuHRS145` cập nhật các chỉ số biến động**:
    1. **Ngày công thực tế**: Tăng lên và bảo toàn trọn vẹn (nhờ đơn bù công 15/10 và ngày nghỉ phép năm AL 24/10).
    2. **Tiền làm thêm giờ (OT)**: Tăng từ `0 đ` $\rightarrow$ **`+ 163,043 đ`** (Khớp với 2h OT 150%).
    3. **Nghỉ phép hưởng lương**: Tăng từ `0 ngày` $\rightarrow$ **`1.0 ngày`** (Khớp với đơn AL ngày 24/10).
    4. **Phạt đi trễ 15/10**: Xóa phạt về **`0 đ`** (Đã giải trình xóa vi phạm thành công).
    5. **Thưởng hiệu quả (KPI)**: Tăng từ `0 đ` $\rightarrow$ **`+ 1,000,000 đ`** (Khớp với MnuPRL036).
    6. **Khấu trừ tạm ứng lương**: Trừ đúng **`- 2,000,000 đ`** (Khớp với MnuPRL070 đã khóa).
    7. **TỔNG LƯƠNG & LƯƠNG THỰC LĨNH (NET TAKE HOME)**: Tự động nhảy số mới chính xác 100%!
  * **Database**:
    ```sql
    SELECT ActualMonthlyBasic, GrossTakeHome FROM tblSal_Sal WHERE EmployeeID = '046' AND Month = 10 AND Year = 2026;
    ```
    *Kỳ vọng*: `GrossTakeHome` lần 2 cao hơn lần 1 và khớp số thực tế.

---

#### [TC-12]: BƯỚC CHỐT CHẶN BẮT BUỘC — "Khóa lương" phát hành phiếu lương (Menu: `MnuPRL092` hoặc `MnuPRL080`)
* **Mục đích**: Niêm phong kỳ lương Tháng 10/2026 vào bảng `tblSal_Lock` để mở quyền truy cập phiếu lương chính thức cho toàn thể nhân viên.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Ngay tại menu Danh sách trả lương: `OpenAppInSidebar('MnuPRL092')`.
  2. `Di chuột tới` button màu đỏ `Khoá lương` (`#btnLock, button:has-text("Khoá lương")`) $\rightarrow$ `Click`.
  3. Hộp thoại xác nhận hiện ra: *"Bạn có chắc chắn muốn chốt lương?"* $\rightarrow$ `Di chuột tới` button `Đồng ý` $\rightarrow$ `Click`.
  4. Chờ thông báo Toast: *"Khoá lương Thành công"*.
  *(Ghi chú: Kế toán cũng có thể kiểm tra chéo tại menu Mở/Khóa. Lương `MnuPRL080`)*.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **UI**: Trạng thái khóa chuyển sang `ĐÃ KHÓA` (hoặc `Đã khóa 40/40`).
  * **Database**:
    ```sql
    SELECT * FROM tblSal_Lock WHERE Month = 10 AND Year = 2026;
    ```
    *Kỳ vọng*: Trả về 1 bản ghi xác nhận Tháng 10/2026 đã chính thức được niêm phong.
  5. Đăng xuất tài khoản `chien.nguyen`.

---

### 🔹 GIAI ĐOẠN 5: NHÂN VIÊN NGHIỆM THU PHIẾU LƯƠNG & 3 MODAL (ROLE: `tai.dang`)

#### [TC-13]: Nghiệm thu giao diện Phiếu lương cá nhân Tháng 10/2026 (Menu: `MnuPRL445`)
* **Mục đích**: Nhân viên đăng nhập xem phiếu lương chính thức, đối soát định lượng từng trường dữ liệu.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. Đăng nhập lại tài khoản Nhân viên: `Username = tai.dang`, `Password = 123`.
  2. Mở menu Phiếu lương cá nhân: `OpenAppInSidebar('MnuPRL445')`.
  3. Chờ container `#sp_salaryslip_html` hiển thị hoàn tất.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **Tiêu đề phiếu lương**: Hiển thị chính xác chuỗi: `Tháng/Năm: 10/2026` (Đã tự động chuyển từ Tháng 08 sang Tháng 10 nhờ bước Khóa lương!).
  * **Đối soát 17 trường chỉ tiêu định lượng**:
    - `#psEmpID`: Hiển thị `046`
    - `#psFullName`: Hiển thị `ĐẶNG MINH TÀI`
    - `#psBasicSalary`: Hiển thị `10,000,000` (hoặc `10,000,000 đ`)
    - `#psStdDays`: Hiển thị `23 ngày` (hoặc `22/24` tùy ca)
    - `#psActDays`: Hiển thị đầy đủ số công thực tế
    - `#psOTSalary`: Hiển thị `163,043`
    - `#psDaysOff`: Hiển thị `1.0 ngày` (Nghỉ phép hưởng lương AL)
    - `#psLateEarly`: Hiển thị `0` (Không bị trừ phạt trễ)
    - `#psAdjustment`: Hiển thị `1,000,000` (Thưởng KPI)
    - `#psAdvance`: Hiển thị `2,000,000` (Tạm ứng đã trừ)
    - `#psDepTax`: Hiển thị `4,400,000` (Giảm trừ gia cảnh 1 con)
    - `#psNetSalary`: Hiển thị con số thực lĩnh dương, ăn khớp 100% với công thức toán học!

---

#### [TC-14]: Kiểm tra tương tác 3 Modal con mắt 👁️ trên Phiếu lương
* **Mục đích**: Kiểm tra trải nghiệm người dùng, tính năng đào sâu dữ liệu (Drill-down) tại 3 Popup Modal.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. **Kiểm tra Modal 1 (Chi tiết Tăng ca)**:
     - `Di chuột tới` icon con mắt 👁️ tại dòng Tăng ca (`#psOTEye, .eye-ot`) $\rightarrow$ `Click`.
     - Chờ Modal chi tiết tăng ca bung ra.
     - Soi dữ liệu: Có dòng ngày `20/10/2026`, thời lượng `2.0 giờ`, hệ số `150%`.
     - `Di chuột tới` button Đóng modal (`button.btnClose, .btn-close`) $\rightarrow$ `Click`.
  2. **Kiểm tra Modal 2 (Chi tiết Ngày nghỉ)**:
     - `Di chuột tới` icon con mắt 👁️ tại dòng Số ngày nghỉ (`#psLeaveEye, .eye-leave`) $\rightarrow$ `Click`.
     - Soi dữ liệu: Có dòng ngày `24/10/2026`, loại nghỉ `Phép năm (AL)`, thời lượng `1 ngày`.
     - `Di chuột tới` button Đóng modal $\rightarrow$ `Click`.
  3. **Kiểm tra Modal 3 (Chi tiết Đi trễ / Về sớm)**:
     - `Di chuột tới` icon con mắt 👁️ tại dòng Đi trễ/về sớm (`#psIOEye, .eye-io`) $\rightarrow$ `Click`.
     - Soi dữ liệu: Ngày `15/10/2026` hiển thị trạng thái `Đã bù công hợp lệ (0 phạt)`.
     - `Di chuột tới` button Đóng modal $\rightarrow$ `Click`.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * Cả 3 Modal mở mượt mà, render đúng dữ liệu dòng tương ứng, đóng an toàn và không gây treo giao diện hay crash màn hình.

---

#### [TC-15]: Kiểm tra Tab Lịch Sử hiển thị kỳ Tháng 10/2026 đã khóa sổ
* **Mục đích**: Nghiệm thu danh mục lịch sử lưu trữ phiếu lương đa kỳ của người lao động.
* **Quy trình thao tác chi tiết (Action Steps)**:
  1. `Di chuột tới` tab `Lịch Sử` (`#tabHistory, button:has-text("Lịch Sử")`) nằm cạnh tab Phiếu Lương $\rightarrow$ `Click`.
  2. Chờ lưới danh sách lịch sử nạp dữ liệu.
* **Logic nghiệm thu (Assertions & Expected Output)**:
  * **Dòng đầu tiên (Top 1)**: Hiển thị kỳ `10/2026` với số tiền thực lĩnh khớp với tab Phiếu Lương.
  * Các dòng tiếp theo: Hiển thị các kỳ cũ trong quá khứ (`08/2026`, `07/2026`...).
  * Thao tác bấm lại vào tab `Phiếu Lương` $\rightarrow$ Giao diện phiếu lương hiển thị nguyên vẹn, kết thúc toàn bộ luồng kiểm thử E2E Zero-Bug thành công mỹ mãn!

---

## 📋 PHẦN 4: HƯỚNG DẪN DÀNH CHO AGENT TỰ ĐỘNG HÓA KHI SINH MÃ PLAYWRIGHT

Khi agent đọc file này để sinh file `tests/cham_cong_tinh_luong_flow.spec.js`:
1. Sử dụng thư viện `test, expect` từ `@playwright/test`.
2. Khởi tạo `helpers/db.js` để thực thi các câu lệnh `query(sql)` đối soát CSDL kép theo các block SQL đã cung cấp ở mỗi TC.
3. Sử dụng helper `moveAndClick(page, locator)` cho tất cả các thao tác bấm nút để tạo hiệu ứng con trỏ Neon trực quan.
4. Bắt buộc gói các thao tác gửi form trong cấu trúc xử lý modal xác nhận `#vc-vu-confirm-popup` (Luật thép 3).
5. Sau mỗi TC, gọi hàm chụp ảnh minh chứng `captureStep` để lưu bằng chứng tự động vào `test-evidence/`.
6. Tuyệt đối không gán cứng kết quả FAIL/PASS nông, luôn dùng Dynamic Exact Match đối soát nội dung chi tiết.
