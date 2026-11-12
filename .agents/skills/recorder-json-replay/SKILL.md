---
name: recorder-json-replay
description: >-
  Chuyển đổi file JSON xuất từ Chrome DevTools Recorder (F12 -> Recorder -> Export JSON) thành Test Case Playwright (.spec.js) mô phỏng trực quan khớp 100% thao tác thật (chuột Neon, gõ phím từng chữ, cuộn thông minh, định vị động theo chuẩn skill playwright-live-visual-e2e), KHÔNG chèn Expected Result / chẩn đoán lỗi, kèm script .sql reset dữ liệu tái sử dụng và file .bat chạy 1-Click. Kích hoạt ngay khi Người Dùng gửi file .json từ Recorder hoặc yêu cầu tạo test replay + .sql reset + .bat từ thao tác quay tay.
---

# RECORDER JSON REPLAY — TÁI HIỆN THAO TÁC TRỰC QUAN TỪ F12 RECORDER (.JSON $\rightarrow$ .SPEC.JS + .SQL RESET + .BAT)

> **Mục tiêu cốt lõi**: Người Dùng tự quay thao tác mẫu trên Chrome F12 Recorder rồi xuất `.json` $\longrightarrow$ Agent lọc thao tác thừa, chuyển selector mong manh sang định vị động $\longrightarrow$ tạo `.spec.js` mô phỏng trực quan khớp **100% mạch thao tác** (không cần Expected Result) $\longrightarrow$ tạo script `.sql` reset sạch dữ liệu test $\longrightarrow$ đóng gói `.bat` 1-Click để Người Dùng tái sử dụng vô hạn lần và tự quan sát đúng/sai trực tiếp bằng mắt.

---

## 📋 QUY TRÌNH 6 BƯỚC BẮT BUỘC

### Bước 1: Tiếp nhận JSON & Xác định phạm vi đóng gói
1. Đọc toàn bộ file `.json` xuất từ Chrome DevTools Recorder (`title`, `steps[]` gồm `setViewport`, `navigate`, `click`, `doubleClick`, `change`, `keyDown`/`keyUp`, `scroll`, `waitForElement`...).
2. Xác định 2 thông tin đầu vào (nếu thiếu trong file `.json` hoặc tin nhắn thì hỏi nhanh Người Dùng):
   - **Đăng nhập**: File quay từ màn hình Login hay quay lúc đã đăng nhập sẵn (nếu đã login sẵn thì dùng tài khoản nào, ví dụ trong `ACCOUNTS` / `test.env.json`).
   - **Đích lưu code**: Tạo file `tests/<ten_luong>.spec.js` + `Run-<TenLuong>.bat` riêng mới, hay nối thêm block TC mới vào một file `.spec.js` có sẵn.
3. **Tuân thủ Khóa đa Agent ([AGENTS.md](../../../AGENTS.md) Điều 6 & Điều 8)**:
   - Nếu gắn thêm TC vào file `.spec.js` dùng chung (như `tests/quy_trinh_tinh_luong_nv_moi.spec.js`), **TUYỆT ĐỐI CHỈ ĐƯỢC CODE TRONG BLOCK TC MỚI** (`// >>> [START_TC_XX] ... // <<< [END_TC_XX]`), **NGHIÊM CẤM sửa bất kỳ helper dùng chung nào** khi chưa được Người Dùng cho phép.

---

### Bước 2: Phân tích & Lược bỏ thao tác thừa (Step Pruning)
Rà soát mảng `steps[]` trong file `.json` để giữ đúng **100% mạch nghiệp vụ thật** nhưng loại sạch các nhiễu thao tác tay:
1. **Gộp các nhịp `change` liên tiếp trên cùng 1 phần tử**: Nếu người quay gõ/sửa lại giá trị nhiều lần vào cùng 1 input, chỉ giữ giá trị cuối cùng hợp lệ.
2. **Bỏ `click` focus thừa ngay trước `change` trên cùng input**: Vì helper `typeHumanLike` / bước nhập trực quan đã tự di chuột Neon click mở focus trước khi gõ.
3. **Bỏ thao tác rác không mang ý nghĩa nghiệp vụ**: Click ra khoảng trắng nền để đóng gợi ý rồi mở lại ngay, double-click vô tình lên text tĩnh, `keyDown`/`keyUp` rác (`Shift`/`Control` lẻ không kèm tổ hợp), hoặc các đoạn `scroll` lắc qua lại liên tiếp không dẫn tới phần tử mục tiêu nào.
4. **Minh bạch khi bàn giao**: Khi trả lời Người Dùng, liệt kê ngắn gọn danh sách thao tác thừa đã lược bỏ để Người Dùng đối chiếu.

---

### Bước 3: Chuyển đổi Selector & Sinh code `.spec.js` Chuẩn Live Visual (NO EXPECTED ASSERTIONS)

#### 3.1. Nguyên tắc "Không Expected / Không Chẩn Đoán Lỗi" (Pure Replay Mode)
- **KHÔNG** tự ý chèn các khối `expect(...)` kiểm tra logic nghiệp vụ, **KHÔNG** viết cổng đối soát DB để đánh FAIL test case, **KHÔNG** ghi `FAILURE ANALYSIS` hay `testInfo.annotations` chẩn đoán đúng/sai.
- Chỉ chờ điều kiện vật lý tối thiểu để bước kế tiếp bấm được (ví dụ: chờ modal/popup/dropdown `.waitFor({ state: 'visible' })` trước khi di chuột vào bên trong). Nếu không tìm thấy nút để thao tác tiếp thì mới báo lỗi vị trí control bị thiếu/ẩn.

#### 3.2. Bộ Quy Chuẩn Trực Quan Bắt Buộc (Kế thừa [playwright-live-visual-e2e](../playwright-live-visual-e2e/SKILL.md) mục 2.0)
Mọi file `.spec.js` sinh ra **BẮT BUỘC** đảm bảo 6 chuẩn sau:
1. **Toàn màn hình không viền đen**:
   - Giữ `viewport: null` và `launchOptions.args` có `--start-maximized` trong config / `test.use(...)`.
2. **Con trỏ chuột Neon thời gian thực**:
   - Nhúng `visual_cursor.js` ở `test.beforeEach` qua `context.addInitScript(...)` để hiển thị mũi tên Neon, hiệu ứng sóng gợn `mousedown` và bong bóng gõ phím.
   - Đọc danh sách `selectors` trong JSON và chuyển đổi sang selector bền vững trước khi truyền vào helper:
     * **Ưu tiên**: `#id` cố định $\rightarrow$ `[aria-label]` / `aria/...` $\rightarrow$ thuộc tính định danh (`data-*`, `name`, `placeholder`) $\rightarrow$ văn bản nhãn / bộ lọc dòng-cột.
     * **Cấm dùng mù quáng**: Không giữ selector vị trí mong manh `:nth-child(...)` / `nth-of-type(...)` của Recorder khi bấm vào dòng bảng `DataGrid`, danh sách thẻ hoặc dropdown item $\rightarrow$ chuyển sang định vị động theo **Nội dung cột / Văn bản dòng** (Luật 17 trong `playwright-live-visual-e2e`) và thu hẹp tới đúng ô `td` hoặc nút/checkbox bên trong dòng trước khi lấy `boundingBox()`.
     * **Cấm tọa độ cứng**: Không copy `offsetX`/`offsetY` từ JSON để gọi `page.mouse.click(x, y)` cố định; mọi click phải đi qua locator động + `boundingBox()` thời gian thực (`moveAndClick`).
3. **Di chuột & Click người thật (`moveAndClick`)**:
   - Rê chuột Neon mượt theo `steps` tới phần tử đang `visible` (đợi `boundingBox()` ổn định nếu đang trong popup có animation) rồi mới click. Tuyệt đối không dùng `locator.click()` tắt, `{ force: true }` hay `page.evaluate(() => el.click())`.
4. **Gõ bàn phím từng ký tự (`typeHumanLike` / `pressSequentially`)**:
   - Click mở focus $\rightarrow$ xóa giá trị cũ bằng `Control+A` + `Backspace` $\rightarrow$ gõ từng ký tự bằng `pressSequentially` / `keyboard.type` với độ trễ tự nhiên (35–150ms).
   - Xử lý đúng 2 loại control ngày giờ (`dxDateBox` nhập chuỗi chữ số thuần không `/` để khớp mask; `<input type="date">` dùng chuẩn ISO `YYYY-MM-DD`).
   - **Cấm** dùng `.fill()` để đẩy chữ trong 0ms (trừ `<input type="date">`), **cấm** dùng `Tab` để chuyển ô trước chuột Neon, **cấm** gán ngầm `instance.option('value', ...)`.
5. **Scroll thông minh chuẩn người thật**:
   - Chỉ cuộn khi phần tử nằm ngoài/bị khuất khỏi khung nhìn, hoặc dùng `page.mouse.wheel(0, stepPx)` từng nấc trên đúng khung cuộn đang active (ưu tiên `.dx-overlay-content:visible .dx-scrollable-container` nếu đang mở popup) với `smoothScroll` / nhịp dừng vừa mắt.
6. **Nhịp dừng quan sát trực quan**:
   - Sau các bước chuyển màn hình / mở popup / bấm Lưu hoặc chốt hành động chính, chèn khoảng nghỉ hợp lý (ví dụ `await page.waitForTimeout(3000)` hoặc `5000` ở bước kết thúc) để Người Dùng kịp quan sát kết quả bằng mắt trên Chrome trước khi phiên kết thúc.

---

### Bước 4: Điều tra DB Read-Only & Xuất Script `.sql` Reset Dữ Liệu Tái Sử Dụng
1. **Tuân thủ tuyệt đối [AGENTS.md](../../../AGENTS.md) Điều 1 (Read-Only DB Mode 100%)**:
   - Agent chỉ dùng các câu lệnh đọc (`SELECT`, `OBJECT_DEFINITION`, `sys.sql_modules`, `INFORMATION_SCHEMA` qua `helpers/db.js`) để xác định thao tác trong JSON ghi/sửa/xóa ở những bảng SQL nào và Stored Procedure nào.
   - **NGHIÊM CẤM** tự ý chạy `INSERT`, `UPDATE`, `DELETE`, `ALTER`, `EXEC` làm đổi dữ liệu DB.
2. **Xuất file `.sql` reset sạch & an toàn** (đặt tại `scripts/reset/reset_<ten_luong>.sql` hoặc file reset theo chỉ định của Người Dùng):
   - Chỉ tác động đúng phạm vi dữ liệu test (theo `EmployeeID`, mã chứng từ, hoặc kỳ `Month`/`Year` test), **tuyệt đối không** đụng vào tài khoản quản trị hay dữ liệu chung của công ty.
   - Bổ sung bước khôi phục trạng thái đầu vào (nếu luồng test cần có sẵn dữ liệu tiền đề sạch như hồ sơ/tài khoản, nhớ chuẩn hệ thống ví dụ `StatusEndDate = NULL` trong `tblEmployeeStatusHistory`, không gán `'9999-12-31'`).
   - Chú thích rõ thứ tự sử dụng cho Người Dùng: **Mở SSMS $\rightarrow$ `F5` chạy script `.sql` reset $\rightarrow$ chạy file `.bat`**.

---

### Bước 5: Đóng gói File `.bat` Chạy 1-Click
Tạo file `.bat` (ví dụ `Run-<TenLuong>.bat` ở thư mục gốc hoặc trong `test-evidence/<ten_luong>/Run-This-TC.bat`) theo mẫu chuẩn của dự án:
```bat
@echo off
chcp 65001 >nul
title Paradise HRM - Replay: <Ten Luong / Ma TC>
cls
echo ====================================================================
echo   CHAY MO PHONG TRUC QUAN: <Ten Luong / Ma TC>
echo   (Nho chay script reset SQL truoc neu muon lap lai du lieu sach!)
echo ====================================================================
echo.
cd /d "%~dp0"
call npx playwright test tests/<ten_file>.spec.js -g "<TC-XX>" --project="Google Chrome" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT MO PHONG!
echo ====================================================================
echo.
pause
```

---

### Bước 6: Kiểm tra trước bàn giao & Định dạng báo cáo ngắn gọn
1. Chạy kiểm tra cú pháp & danh sách test trước khi bàn giao:
   - `node -c tests/<ten_file>.spec.js`
   - `npx playwright test "tests/<ten_file>.spec.js" --list`
   - Nếu Người Dùng có sẵn dữ liệu sạch / cho phép chạy thử, chạy đúng `-g "<TC-XX>" --project="Google Chrome"` (tuân thủ Targeted Run theo Điều 6 `AGENTS.md`).
2. Trả lời bàn giao ngắn gọn gồm đúng 4 mục:
   - **Thao tác thừa đã lọc bỏ** từ `.json` (hoặc ghi rõ nếu không có).
   - **Link tới TC trong `.spec.js`** đã tạo (kèm ghi chú không can thiệp helper dùng chung nếu nằm trong file nhiều conversation).
   - **Link tới file `.sql` reset dữ liệu** + hướng dẫn chạy trong SSMS (`F5`).
   - **Link tới file `.bat`** + kết quả kiểm tra cú pháp / chạy thử thực tế.
