---
name: playwright-live-visual-e2e
description: >-
  Thực hiện kiểm thử E2E trực quan (Live Visual Testing) trên Google Chrome thật: hiển thị cửa sổ trên màn hình Windows, mô phỏng con trỏ chuột Neon, gõ phím chậm rãi quan sát được, tự động quay video, chụp ảnh và xuất báo cáo Markdown vào test-evidence/. Sử dụng khi người dùng yêu cầu viết test hoặc kiểm thử bất kỳ menu, màn hình, form, API hay user flow nào. Tự động nhận diện tạo mới TC-01 nếu trang chưa có hoặc bổ sung TC-02, TC-03... nếu trang đã có, tổ chức thư mục bằng chứng phân cấp theo từng Trang và từng TC, đồng thời tự động cập nhật vào menu 1-Click .bat.
---

# Playwright Live Visual E2E — Kiểm thử trực quan trên màn hình thật

Skill này là kim chỉ nam cho AI Agent khi thực hiện yêu cầu kiểm thử tự động trực quan trên hệ thống web (Paradise HRM hoặc các dự án tương tự). Khi người dùng yêu cầu kiểm thử bất kỳ menu/trang nào, Agent tự động phân tích DOM, khởi tạo hoặc bổ sung test case theo chuẩn `TC-01`, `TC-02`, lưu bằng chứng nghiệm thu theo đúng cấu trúc thư mục phân cấp (`test-evidence/<tên_trang>/<TC-0x>/`), kiểm tra cơ chế quét động của file `.bat`, thực thi kiểm thử và xuất báo cáo nghiệm thu theo đúng chuẩn.

---

## 0. Quản Lý Mục Tiêu Website & Tài Khoản (`test.env.json`)

Skill này **hoàn toàn đa năng**, có thể kiểm thử **BẤT KỲ TRANG WEB NÀO TRÊN INTERNET**:

### A. Lần đầu tiên kiểm thử một website mới:
- Người dùng chỉ cần cung cấp: **Link website** + **Tài khoản / Mật khẩu**.
- Agent tự động lưu thông tin vào file cấu hình `test.env.json`:
  ```json
  {
    "baseUrl": "https://<url_website_can_test>",
    "auth": {
      "username": "<ten_dang_nhap>",
      "password": "<mat_khau>",
      "usernameSelector": "#username",
      "passwordSelector": "input[type=\"password\"]",
      "submitSelector": "#submitLogin"
    }
  }
  ```
- Agent tự động khảo sát DOM của form đăng nhập trên web đó, cập nhật selector tương ứng và kiểm tra đăng nhập thành công.

### B. Những lần sau:
- Người dùng **chỉ cần nêu tên menu/chức năng muốn test** (không cần nhập lại link hay mật khẩu).
- Agent tự động đọc `test.env.json`, mở đúng website mục tiêu, tự động đăng nhập sẵn qua `helpers/auth.js` và tiến hành kiểm thử màn hình được yêu cầu!

---

## 1. Cấu Trúc Tổ Chức Thư Mục Bằng Chứng Phân Cấp (BẮT BUỘC TUÂN THỦ)

Cấu trúc thư mục bằng chứng nghiệm thu trong `test-evidence/` được tổ chức **chuẩn xác theo 2 cấp phân cấp** tương ứng 1:1 với thư mục `tests/`:

```
tests/ (Mã nguồn kịch bản)                test-evidence/ (Bằng chứng nghiệm thu)
├── login.spec.js               ───►     ├── login/                          <-- 1 THƯ MỤC CHO 1 TRANG/FILE
│   ├── TC-01                                │   ├── test-report.md              <-- Báo cáo riêng trang login
│   └── TC-02                                │   ├── Run-This-Page.bat           <-- 1-CLICK CHẠY TOÀN BỘ TRANG NÀY
│                                            │   ├── TC-01/                      <-- THƯ MỤC RIÊNG CHO TC-01
│                                            │   │   ├── Run-This-TC.bat         <-- 1-CLICK CHẠY TRỰC QUAN RIÊNG TC-01!
│                                            │   │   ├── screenshots/            <-- Ảnh chụp TC-01
│                                            │   │   ├── videos/                 <-- Video quay TC-01 (.webm)
│                                            │   │   ├── traces/                 <-- Playwright Trace TC-01 (.zip)
│                                            │   │   └── results.json            <-- Kết quả JSON của TC-01
│                                            │   └── TC-02/                      <-- THƯ MỤC RIÊNG CHO TC-02
│                                            │       ├── Run-This-TC.bat         <-- 1-CLICK CHẠY TRỰC QUAN RIÊNG TC-02!
│                                            │       ├── screenshots/            <-- Ảnh chụp TC-02
│                                            │       ├── videos/                 <-- Video quay TC-02 (.webm)
│                                            │       ├── traces/                 <-- Playwright Trace TC-02 (.zip)
│                                            │       └── results.json
├── dashboard_overview.spec.js  ───►     ├── dashboard_overview/             <-- THƯ MỤC CHO TRANG DASHBOARD
│   └── TC-01                                │   ├── test-report.md
│                                            │   ├── Run-This-Page.bat           <-- 1-CLICK CHẠY TOÀN BỘ TRANG DASHBOARD
│                                            │   └── TC-01/
│                                            │       ├── Run-This-TC.bat         <-- 1-CLICK CHẠY TRỰC QUAN RIÊNG TC-01!
│                                            │       ├── screenshots/
│                                            │       ├── videos/
│                                            │       ├── traces/
│                                            │       └── results.json
                                             ├── results.json                    <-- Master JSON tổng hợp
                                             └── test-report.md                  <-- MASTER REPORT TỔNG THỂ DỰ ÁN
```

### Nguyên tắc tổ chức:
1. **Mỗi file `.spec.js` trong `tests/` đại diện cho 1 trang/menu** $\rightarrow$ Có đúng **1 thư mục con** mang tên file đó trong `test-evidence/` (ví dụ: `tests/login.spec.js` $\rightarrow$ `test-evidence/login/`).
2. **Trong thư mục của trang đó**:
   - `test-report.md`: Báo cáo riêng của trang đó.
   - `Run-This-Page.bat`: File 1-Click để nhấp đúp chạy lại toàn bộ test case của trang này trên Chrome thật.
   - Có các thư mục con riêng biệt cho từng kịch bản: `TC-01/`, `TC-02/`, `TC-03/`...
3. **Trong mỗi thư mục `TC-0x/`**:
   - `Run-This-TC.bat`: **BẮT BUỘC CÓ** — File thực thi 1-Click tại chỗ. Khi nhấp đúp, máy sẽ mở Google Chrome thật hiển thị con trỏ Neon, gõ phím từ từ và chạy riêng đúng test case này cho người dùng quan sát!
   - `screenshots/`: Chứa tất cả ảnh chụp màn hình kiểm chứng của riêng test case đó.
   - `videos/`: Chứa video `.webm` quay lại trọn vẹn thao tác của test case đó.
   - `traces/`: Chứa file `trace.zip` phục vụ mổ xẻ lỗi khi cần.
   - `results.json`: Chứa dữ liệu kết quả máy đọc (status, duration, error).
4. **Tại thư mục gốc `test-evidence/`**:
   - `test-report.md`: Báo cáo Master tổng hợp toàn bộ các trang, có bảng tóm tắt và link trỏ vào từng trang/từng test case.

---

## 2. Nguyên Tắc Cốt Lõi (Bắt Buộc Tuân Thủ)

1. **Hiển thị trực quan 100% trên Google Chrome thật (`channel: 'chrome'`, `headless: false`)**:
   - Tuyệt đối không chạy headless khi người dùng yêu cầu test quan sát.
   - **Đồng bộ độ trễ chuột và thao tác (Low Latency Synchronization)**: Cấu hình `slowMo: 100` trong `playwright.config.js` để tránh trễ lệch pha. Trong `visual_cursor.js` luôn dùng `transition: none !important; will-change: transform` để con trỏ chuột Neon bám sát 100% thời gian thực.
   - Thao tác gõ phím mượt mà, quan sát rõ: dùng `locator.pressSequentially('text', { delay: 35-50 })`.
   - Khuyến nghị dùng helper `moveAndClick(page, locator, { steps: 8-12 })` để chuột lướt trực quan vào giữa phần tử trước khi bấm, người xem nhìn rõ thao tác chuột.
   - Luôn nhúng `visual_cursor.js` trong `test.beforeEach` để tạo con trỏ chuột Neon phát sáng và hiệu ứng sóng gợn khi click.
2. **Tái sử dụng phiên đăng nhập (Authentication Reuse)**:
   - Sử dụng trợ lý `const { loginAsAdmin } = require('../helpers/auth')` trong `beforeEach` hoặc cấu hình `storageState: 'auth.json'` để tránh phải lặp lại mã đăng nhập trong từng test case.
3. **Cơ chế 1-Click Bất Tử (Dynamic Test Discovery)**:
   - File batch ngoài Desktop (`Run-ParadiseHR-Interactive.bat`) sử dụng thuật toán quét động `tests/**/*.spec.js`. Khi Agent thêm file mới hoặc thêm test case mới, menu sẽ **tự động cập nhật thêm tùy chọn mới** mà người dùng không cần sửa lại file `.bat`.
4. **Bắt Buộc Thẩm Định Sự Kiện Mạng & Phản Hồi API (Network & API Validation)**:
   - **Tuyệt đối không chỉ kiểm tra class CSS, DOM ảo hay visual bề nổi**: Khi tương tác với bất kỳ control nào (click chip/nút lọc, tích chọn checkbox, nhập ô tìm kiếm, chuyển trang phân trang), script **BẮT BUỘC PHẢI CHẶN VÀ KIỂM TRA SỰ KIỆN MẠNG** (`page.waitForResponse(...)`).
   - Kiểm tra đầy đủ:
     * Endpoint API được gọi đúng và có phương thức chuẩn (POST/GET).
     * HTTP Status Code trả về thành công (`200 OK`).
     * Nội dung Response Body trả về dữ liệu hợp lệ (ví dụ: `result: "success"`, danh sách `data: [...]`).
     * Đối chiếu tính toàn vẹn dữ liệu: các dòng trên DataGrid/bảng phải được render đồng bộ với dữ liệu trả về từ API backend.
5. **Kiểm Thử Chức Năng Nghiệp Vụ Thực Sự (True Business Function / CRUD Testing)**:
   - **Tuyệt đối không chỉ mở form/modal rồi bấm Đóng hoặc Hủy**: Khi kiểm thử một phân hệ hay menu, Agent bắt buộc phải thực thi trọn vẹn các chức năng nghiệp vụ cốt lõi:
     * **Chức năng Tạo mới (Create)**: Điền đầy đủ dữ liệu hợp lệ vào form $\rightarrow$ Di chuyển chuột Neon bấm nút **Lưu** $\rightarrow$ Bắt API lưu dữ liệu (Status 200, phản hồi thành công) $\rightarrow$ Kiểm tra thông báo Toast/Alert $\rightarrow$ Đối chiếu bản ghi mới xuất hiện trên DataGrid.
     * **Chức năng Xem chi tiết / Cập nhật (View/Edit)**: Mở bản ghi từ danh sách $\rightarrow$ Bắt API nạp chi tiết $\rightarrow$ Kiểm tra hiển thị đầy đủ thông tin $\rightarrow$ Cập nhật dữ liệu $\rightarrow$ Bấm Lưu $\rightarrow$ Bắt API cập nhật.
     * **Chức năng Lọc / Tìm kiếm (Filter/Search)**: Lọc theo tiêu chí $\rightarrow$ Bắt API truy vấn $\rightarrow$ Kiểm tra bảng hiển thị đúng các dòng thuộc tiêu chí đó.

---

## 2.1. BỘ NGUYÊN TẮC TEST TỔNG QUÁT THEO TỪNG LOẠI CONTROL (UNIVERSAL CONTROL SPECIFICATION)

*(Áp dụng nhất quán cho MỌI menu, màn hình, phân hệ và dự án web. Mọi kịch bản `.spec.js` khi sinh ra hoặc mở rộng BẮT BUỘC phải tuân theo 3 lớp thẩm định: **UI/DOM ── Network API ── Logic Dữ Liệu**)*

```
┌────────────────────────────────────────────────────────────────────────┐
│             3 LỚP THẨM ĐỊNH BẮT BUỘC CHO MỌI CONTROL (TRIPLE-LAYER)     │
├───────────────────┬─────────────────────────────┬──────────────────────┤
│ 1. UI / DOM Layer │ 2. Network / API Layer      │ 3. Data/State Layer  │
│ - Trạng thái focus│ - Chặn waitForResponse      │ - Đối chiếu API vs UI│
│ - Class .active   │ - Payload gửi đi đúng chuẩn │ - Round-trip khôi    │
│ - Viền đỏ validate│ - HTTP Status & JSON Body   │   phục trạng thái    │
│ - Enable/Disable  │ - Check cờ success/result   │ - Đọc lại (Read-back)│
└───────────────────┴─────────────────────────────┴──────────────────────┘
```

---

### NHÓM 1: CÁC CONTROL NHẬP LIỆU (INPUT CONTROLS)

#### 1. Ô Nhập Văn Bản (Text Field / Textarea)
* **Thao tác chuẩn**:
  - Di chuột Neon vào giữa ô input $\rightarrow$ Click focus $\rightarrow$ Xóa trắng dữ liệu cũ (`fill('')` hoặc `selectText() + Backspace`).
  - Gõ phím mô phỏng người thật: `pressSequentially(text, { delay: 35 })`.
* **Thẩm định 3 lớp**:
  1. *UI*: `expect(input).toHaveValue(text)`.
  2. *Negative/Validation*: Khi xóa rỗng trường bắt buộc rồi blur ra ngoài $\rightarrow$ Bắt buộc assert xuất hiện viền đỏ hoặc thông báo lỗi `dx-invalid` / `.text-danger` / `.error-message`.
  3. *Ký tự đặc biệt (Edge case)*: Thử nghiệm chuỗi có dấu tiếng Việt, khoảng trắng thừa ở 2 đầu, ký tự `'`, `"`, `&` $\rightarrow$ Đảm bảo không bị vỡ giao diện hoặc lỗi câu query SQL.

#### 2. Ô Nhập Số / Tiền Tệ / Tỷ Lệ (Number / Currency / Percentage Input)
* **Thao tác chuẩn**:
  - Click focus $\rightarrow$ Nhập số bằng chuỗi số nguyên hoặc số thập phân.
* **Thẩm định 3 lớp**:
  1. *UI Formatting*: Kiểm tra định dạng tiền tệ tự động (vd: gõ `1000000` $\rightarrow$ UI phải format `1,000,000` hoặc `1.000.000 ₫`).
  2. *Chống nhập sai (Negative)*: Cố tình gõ chữ cái `abc` hoặc ký tự lạ $\rightarrow$ Assert ô input không nhận ký tự chữ, giá trị giữ nguyên kiểu số.
  3. *Giới hạn biên (Boundary)*: Nhập số âm (nếu không cho phép số âm), nhập `0`, hoặc nhập số vượt ngưỡng max $\rightarrow$ Assert thông báo chặn hợp lệ.

#### 3. Bộ Chọn Ngày / Khoảng Ngày (Date Picker / Date Range Picker)
* **Thao tác chuẩn**:
  - Hạn chế gõ chuỗi tay nếu control dùng popup calendar $\rightarrow$ Click icon lịch $\rightarrow$ Chọn ngày cụ thể hoặc gõ định dạng chuẩn hệ thống (`dd/MM/yyyy`).
* **Thẩm định 3 lớp**:
  1. *UI*: Assert ngày hiển thị đúng định dạng `dd/MM/yyyy`.
  2. *Ràng buộc logic (Cross-field Validation)*: Chọn `Từ ngày` > `Đến ngày` $\rightarrow$ Bắt buộc assert thông báo lỗi logic *"Từ ngày không được lớn hơn Đến ngày"*.
  3. *Network*: Bắt API khi chọn ngày $\rightarrow$ Assert tham số `@FromDate`, `@ToDate` gửi lên server khớp đúng định dạng backend mong đợi (không bị lệch timezone).

#### 4. Danh Sách Chọn Đơn (Single Select / Dropdown / Combobox)
* **Thao tác chuẩn**:
  - Di chuột Neon click mở dropdown $\rightarrow$ Đợi menu popup `.dx-dropdowneditor-overlay, .select2-dropdown` hiển thị $\rightarrow$ Gõ tìm kiếm hoặc cuộn tới option mục tiêu $\rightarrow$ Click chọn.
* **Thẩm định 3 lớp**:
  1. *UI*: Assert text hiển thị trên dropdown đổi sang option vừa chọn.
  2. *Khóa liên động (Cascading Dropdown)*: Nếu Dropdown A quyết định Dropdown B (ví dụ: Tỉnh/Thành $\rightarrow$ Quận/Huyện) $\rightarrow$ Assert Dropdown B tự động nạp lại danh sách tương ứng và reset giá trị cũ.
  3. *API*: Chặn API nạp danh sách dropdown $\rightarrow$ Đảm bảo có danh sách trả về, không bị mảng rỗng `[]`.

#### 5. Danh Sách Chọn Nhiều (Multi-Select / TagBox / Chip Input)
* **Thao tác chuẩn**:
  - Mở dropdown $\rightarrow$ Tích chọn 2-3 phần tử $\rightarrow$ Click ra ngoài để đóng.
* **Thẩm định 3 lớp**:
  1. *UI*: Assert các Tags/Badges xuất hiện tương ứng trong ô input. Thử bấm nút `x` trên 1 tag để xóa $\rightarrow$ Assert tag đó biến mất.
  2. *Chọn tất cả (Select All)*: Bấm nút "Chọn tất cả" $\rightarrow$ Assert toàn bộ items được tích và badge cập nhật số lượng.
  3. *Network*: Payload gửi lên server phải là mảng hoặc chuỗi phân tách dấu phẩy (vd: `[1, 2, 3]` hoặc `'1,2,3'`).

#### 6. Hộp Kiểm / Nút Gạt Trạng Thái (Checkbox / Toggle Switch)
* **Thao tác chuẩn**:
  - Di chuột Neon click trực tiếp vào checkbox/toggle.
* **Thẩm định 3 lớp**:
  1. *UI*: Assert trạng thái `expect(checkbox).toBeChecked()` hoặc toggle có class `.dx-switch-on`.
  2. *Hiển thị có điều kiện (Conditional Visibility)*: Nếu checkbox điều khiển ẩn/hiện trường khác (vd: "Tích chọn để xuất hóa đơn VAT" $\rightarrow$ Hiện ô Mã số thuế) $\rightarrow$ Bắt buộc assert khu vực phụ xuất hiện khi ON và biến mất khi OFF.
  3. *Đảo ngược trạng thái*: Click lần 1 (ON) $\rightarrow$ Click lần 2 (OFF) $\rightarrow$ Assert trạng thái trở về ban đầu nguyên vẹn.

---

### NHÓM 2: CÁC CONTROL LỌC, TÌM KIẾM & BỘ ĐIỀU HƯỚNG BẢNG

#### 7. Thẻ Lọc Trạng Thái (Filter Chips / Status Pills / Pill Tabs)
* **Thao tác chuẩn**:
  - Ghi nhận số dòng ban đầu $N_0$ ở chip mặc định ("Tất cả").
  - Click chip lọc cụ thể $A$ (vd: "Đã duyệt", "Chờ xử lý").
* **Thẩm định 3 lớp (BẮT BUỘC ROUND-TRIP)**:
  1. *UI*: Chip được click có class active/selected.
  2. *Network*: Bắt API `/query` hoặc `/filter` $\rightarrow$ Assert payload gửi đúng mã trạng thái $A$ và response trả về dữ liệu tương ứng.
  3. *Logic Dữ Liệu*:
     - Mọi dòng trên bảng phải mang đúng nhãn trạng thái $A$.
     - **Vòng lặp khôi phục bắt buộc**: Click quay lại chip "Tất cả" lần 2 $\rightarrow$ Bắt API $\rightarrow$ **Assert số dòng phục hồi $N_{restore} == N_0$** (chặn triệt để lỗi kẹt filter ngày hoặc đột biến state làm mất sạch dữ liệu).

#### 8. Ô Tìm Kiếm Nhanh (Search Box / Instant Filter)
* **Thao tác chuẩn**:
  - Tuyệt đối không nhập chuỗi cứng bừa bãi.
  - **Trích xuất từ khóa động**: Đọc text từ 1 dòng thực tế đang có trên bảng (vd: Tên khách hàng, Mã nhân viên) $\rightarrow$ Gõ vào ô search bằng `pressSequentially`.
* **Thẩm định 3 lớp**:
  1. *Instant Filter*: Đợi debounce 300-500ms $\rightarrow$ Mọi dòng hiển thị trên DataGrid bắt buộc phải chứa từ khóa tìm kiếm.
  2. *Trường hợp không tìm thấy*: Gõ một chuỗi ngẫu nhiên không tồn tại (vd: `###XYZ_NO_DATA###`) $\rightarrow$ Assert bảng hiển thị giao diện rỗng: *"Không có dữ liệu"* (Empty state).
  3. *Phục hồi khi xóa search*: Dùng `selectText() + Backspace` để xóa sạch ô tìm kiếm $\rightarrow$ Assert bảng tự động nạp lại đầy đủ danh sách ban đầu.

#### 9. Bộ Phân Trang (Pagination: Next, Prev, Page Size, Jump)
* **Thao tác chuẩn**:
  - Đọc text dòng đầu tiên của Trang 1 $\rightarrow$ Bấm nút chuyển sang Trang 2 (hoặc số trang cụ thể).
* **Thẩm định 3 lớp**:
  1. *UI*: Nút Trang 2 chuyển sang active, nút "Previous" được enable (không còn disabled).
  2. *Network*: Bắt API phân trang $\rightarrow$ Assert tham số `pageIndex=2` (hoặc `skip=20, take=20`).
  3. *Dữ liệu*: Dòng đầu tiên của Trang 2 **PHẢI KHÁC** dòng đầu tiên của Trang 1.
  4. *Đổi Page Size*: Chọn đổi số dòng từ `20` lên `50` $\rightarrow$ Assert số dòng trên bảng tăng lên tương ứng.

#### 10. Sắp Xếp Cột & Lọc Đầu Cột (Column Sorting & Header Filter)
* **Thao tác chuẩn**:
  - Di chuột click vào tiêu đề cột (Column Header).
* **Thẩm định 3 lớp**:
  1. *UI*: Xuất hiện icon mũi tên sắp xếp tăng dần $\uparrow$ (click lần 1) hoặc giảm dần $\downarrow$ (click lần 2).
  2. *Network*: Bắt API query $\rightarrow$ Assert tham số `sortColumn` và `sortDirection` (`ASC`/`DESC`).
  3. *Logic*: So sánh giá trị dòng 1 và dòng 2 sau khi sắp xếp để đảm bảo đúng thứ tự chữ cái hoặc ngày tháng.

---

### NHÓM 3: BẢNG DỮ LIỆU & HIỂN THỊ (DATA DISPLAY CONTROLS)

#### 11. Bảng Dữ Liệu (DataGrid / Table)
* **Thao tác chuẩn**:
  - Kiểm tra trạng thái nạp ban đầu, chọn dòng (single row / checkbox multi-row), double-click xem chi tiết.
* **Thẩm định 3 lớp**:
  1. *Đối chiếu API vs UI*: Bóc tách JSON payload từ API nạp bảng (`rawRows = JSON.parse(json.result)`) $\rightarrow$ So khớp `expect(uiRowCount).toBe(rawRows.length)`.
  2. *Empty State*: Khi backend trả mảng rỗng `[]` $\rightarrow$ Bảng phải hiện thông báo "Không có dữ liệu" rõ ràng, không bị crash vỡ bảng.
  3. *Double-click chi tiết*: Double click 1 dòng $\rightarrow$ Bắt API nạp chi tiết $\rightarrow$ Assert form chi tiết mở ra nạp đúng thông tin dòng đó.

#### 12. Thẻ Chỉ Số Tổng Hợp (Metric / KPI Counter Cards)
* **Thao tác chuẩn**:
  - Thao tác các bộ lọc bên dưới bảng và quan sát thẻ KPI ở trên.
* **Thẩm định 3 lớp**:
  1. *UI*: Các thẻ chỉ số (Tổng số, Đang xử lý, Hoàn tất) có số lượng rõ ràng, không hiển thị `NaN`, `null`, `undefined`.
  2. *Toán học / Logic tổng hợp*: Tổng số trên thẻ KPI phải bằng tổng các thẻ trạng thái con cộng lại, hoặc khớp đúng `totalCount` trả về từ API backend.

---

### NHÓM 4: CÁC CONTROL HÀNH ĐỘNG (ACTION & BUTTON CONTROLS)

#### 13. Nút Hành Động Chính (Primary CTA: Lưu, Gửi, Duyệt, Tạo Mới)
* **Thao tác chuẩn**:
  - Di chuyển chuột Neon tới đúng tọa độ nút $\rightarrow$ Dừng ngắm trực quan $\rightarrow$ Click.
* **Thẩm định 3 lớp**:
  1. *Chống click kép (Debounce / Double-click prevention)*: Click nút Lưu $\rightarrow$ Nút phải lập tức chuyển sang trạng thái disabled hoặc có icon spinner xoay xoay để chống người dùng bấm liên tiếp tạo bản ghi trùng lặp.
  2. *Network*: Bắt API POST/PUT $\rightarrow$ Assert HTTP 200, payload JSON trả về mã thành công (`result: "success"`, `Success: 1`).
  3. *Đọc lại (Read-back)*: Modal đóng $\rightarrow$ Toast thành công hiện lên $\rightarrow$ Bản ghi mới/vừa cập nhật phải lập tức xuất hiện trên DataGrid.

#### 14. Nút Hủy / Đóng (Cancel / Close / Dismiss)
* **Thao tác chuẩn**:
  - Thử nghiệm 2 trường hợp: (1) Form chưa sửa gì và (2) Form đã sửa dữ liệu dở dang (Dirty Form).
* **Thẩm định 3 lớp**:
  1. *Form chưa sửa*: Bấm Hủy $\rightarrow$ Modal đóng ngay lập tức, không gây lỗi.
  2. *Form đã sửa dở dang (Dirty check)*: Nhập vài chữ vào form rồi bấm Hủy $\rightarrow$ Kiểm tra xem hệ thống có bật popup cảnh báo *"Dữ liệu chưa được lưu, bạn có chắc chắn muốn thoát?"* hay không.
  3. *Bảo toàn trạng thái*: Đóng modal xong $\rightarrow$ Danh sách DataGrid bên ngoài vẫn giữ nguyên vị trí phân trang và bộ lọc, không bị reset trắng.

#### 15. Nút Hành Động Xóa / Hủy Bỏ (Delete / Inactivate Action)
* **Thao tác chuẩn**:
  - Chọn dòng cần xóa $\rightarrow$ Bấm nút Xóa $\rightarrow$ Thao tác trên Modal xác nhận.
* **Thẩm định 3 lớp (BẢO VỆ DỮ LIỆU)**:
  1. *Bắt buộc có xác nhận*: Tuyệt đối không được xóa ngay khi vừa click icon xóa $\rightarrow$ Bắt buộc assert xuất hiện Popup/Confirm Dialog ("Bạn có chắc chắn muốn xóa bản ghi này?").
  2. *Hành động Hủy xóa*: Bấm "Hủy" trên popup $\rightarrow$ Bản ghi vẫn giữ nguyên trên bảng.
  3. *Hành động Đồng ý xóa*: Bấm "Xóa" $\rightarrow$ Bắt API Delete (HTTP 200) $\rightarrow$ Assert số dòng trên DataGrid giảm đi 1 ($N - 1$) và mã bản ghi đó biến mất hoàn toàn.

#### 16. Menu Thao Tác Từng Dòng (Context Menu / Row Kebab Menu 3 chấm)
* **Thao tác chuẩn**:
  - Di chuột tới nút 3 chấm trên dòng $\rightarrow$ Click mở menu ngữ cảnh.
* **Thẩm định 3 lớp**:
  1. *UI Position*: Menu ngữ cảnh bung ra đúng vị trí chuột, không bị tràn ra ngoài màn hình (overflow) hoặc che khuất nút khác.
  2. *Phân quyền*: Các nút hành động (Sửa, Xóa, Phê duyệt) hiển thị đúng theo quyền hạn tài khoản đang đăng nhập.
  3. *Click ngoài*: Click chuột ra ngoài khoảng trống $\rightarrow$ Menu ngữ cảnh phải tự động đóng lại.

---

### NHÓM 5: KHUNG CHỨA & PHẢN HỒI (CONTAINERS & FEEDBACK CONTROLS)

#### 17. Cửa Sổ Bật Lên (Modal / Dialog / Drawer / Popup)
* **Thao tác chuẩn**:
  - Mở modal $\rightarrow$ Thao tác bên trong $\rightarrow$ Đóng bằng nút `x`, nút Đóng, phím `Escape`, hoặc click vùng mờ Backdrop.
* **Thẩm định 3 lớp**:
  1. *Backdrop & Focus Trap*: Khi modal mở, thanh cuộn của trang chính phía sau phải bị khóa (không cuộn được trang nền) và phím `Tab` chỉ di chuyển bên trong modal.
  2. *Phím Escape*: Bấm phím `Escape` $\rightarrow$ Modal phải đóng lại an toàn.
  3. *Dọn dẹp DOM (Cleanup)*: Khi đóng modal $\rightarrow$ Các phần tử overlay trong DOM phải bị gỡ bỏ hoặc chuyển sang `display: none`, không được để lại màn mờ vô hình chặn chuột người dùng.

#### 18. Tab Chuyển Đổi & Khung Thu Gọn (Tabs / Accordion / Panels)
* **Thao tác chuẩn**:
  - Đang ở Tab 1 (nhập dở dữ liệu) $\rightarrow$ Click chuyển sang Tab 2 $\rightarrow$ Click quay lại Tab 1.
* **Thẩm định 3 lớp**:
  1. *UI*: Tab được chọn đổi màu active, nội dung panel tương ứng hiển thị, panel cũ bị ẩn.
  2. *Bảo toàn dữ liệu dở dang (Tab State Persistence)*: Dữ liệu đã gõ ở Tab 1 **không được bị xóa mất** khi chuyển qua lại giữa các Tab.
  3. *Network Lazy Load*: Nếu tab có nạp dữ liệu riêng $\rightarrow$ Bắt API khi click tab, đảm bảo API chỉ gọi 1 lần và cache dữ liệu, không spam request mỗi lần click.

#### 19. Thông Báo Phản Hồi (Toast Message / Alert Banner)
* **Thao tác chuẩn**:
  - Kích hoạt sau mỗi thao tác Lưu, Sửa, Xóa hoặc khi văng lỗi.
* **Thẩm định 3 lớp**:
  1. *Đúng phân loại ngữ nghĩa (Semantic Type)*:
     - Thao tác thành công $\rightarrow$ Toast màu xanh lá (`success`).
     - Lỗi nghiệp vụ / Lỗi server $\rightarrow$ Toast màu đỏ (`error` / `danger`).
     - Cảnh báo $\rightarrow$ Toast màu vàng (`warning`).
  2. *Nội dung thông báo rõ ràng*: Toast phải chứa thông điệp tiếng Việt có nghĩa (vd: *"Cập nhật thông tin thành công"*), không được hiện mã code thô ráp như `null`, `[object Object]` hay `Error: 500`.
  3. *Tự động biến mất (Auto-dismiss)*: Toast tự biến mất sau 3-5 giây mà không cần người dùng bấm tắt.

---

### QUY TẮC BẤT KHẢ XÂM PHẠM: "DUAL-ASSERTION" (UI + NETWORK PAYLOAD)
1. **Tuyệt đối cấm viết `expect(response.status()).toBe(200)` đơn lẻ:**
   Luôn luôn phải bóc tách sâu vào JSON Body:
   ```javascript
   const json = await response.json();
   // Không chỉ kiểm tra mã 200, mà phải kiểm tra dữ liệu nghiệp vụ bên trong
   expect(json.status || json.result).toBeDefined();
   ```
2. **Đối chiếu chéo (Cross-check) giữa API và UI:**
   ```javascript
   // Dữ liệu từ API nạp về bao nhiêu bản ghi thì DataGrid phải render bấy nhiêu dòng
   const apiRows = JSON.parse(json.result);
   const uiRows = await page.locator('#grid tbody tr.dx-data-row').count();
   expect(uiRows).toBe(apiRows.length);
   ```
3. **Phân biệt rạch ròi Test Runner vs Logic Nghiệp Vụ:**
   - Kịch bản test bắt được Bug của hệ thống thì **Test Runner (Playwright) vẫn là PASS** (vì script chạy thông suốt, bắt được chính xác lỗi).
   - Nhưng **Trạng thái Logic (Business Status) trong Báo cáo phải đánh dấu ❌ FAIL**, kèm khối `> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)`.

---

## 2.2. KHO KỊCH BẢN BIÊN, TIÊU CỰC & BẪY LỖI NGHIỆP VỤ TỰ ĐỘNG MỞ RỘNG (EDGE CASES & TRAP REPOSITORY)

> **NGUYÊN TẮC TÍCH LŨY TRI THỨC (CONTINUOUS LEARNING RULE):**
> Kho kịch bản biên này là một "thư viện sống". **Mỗi khi phát hiện thêm một lỗi mới, một bẫy logic hoặc một ca kiểm thử khó trong thực tế**, Agent/Tester **BẮT BUỘC PHẢI BỔ SUNG NGAY** mã kịch bản mới (`EDGE-xxx-N`) vào kho này. Nhờ đó, kho tri thức ngày càng dày đặc, việc kiểm thử ở các menu và dự án sau sẽ **tự động kế thừa toàn bộ các kịch bản biên từ trước**, đảm bảo hệ thống ngày càng được kiểm tra kĩ lưỡng và không bao giờ lặp lại sai lầm cũ!

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│              CƠ CHẾ KẾ THỪA & TÍCH LŨY KỊCH BẢN BIÊN LIÊN TỤC                   │
│                                                                                 │
│   Dự án A / Menu 1  ──► Phát hiện Bug mới ──► Thêm mã EDGE-xxx vào Kho        │
│                                                              │                  │
│                                                              ▼                  │
│   Dự án B / Menu N  ◄── Tự động kế thừa toàn bộ Kho ────────┴────────────────   │
│   (Kiểm thử tự động ngày càng sâu sắc, khắt khe và bao quát 100% rủi ro)         │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

### A. KHO BẪY LỖI BỘ LỌC & TÌM KIẾM (FILTER & SEARCH TRAPS)

#### 🔸 `EDGE-FLT-01`: Bẫy Mất Dữ Liệu Khi Khôi Phục Trạng Thái (The Lost-Data Re-click Trap)
* **Đối tượng**: Chip lọc trạng thái (Status Pills), Tab trạng thái, Dropdown lọc.
* **Mô tả bẫy lỗi**: Ban đầu danh sách có $N$ bản ghi. Click chọn lọc 1 trạng thái con $\rightarrow$ Click lại "Tất cả" lần 2. Do frontend không khôi phục cờ `isViewAll = 1` hoặc ngầm ép cứng ngày theo tuần hiện tại $\rightarrow$ Danh sách bị xóa sạch trắng trơn!
* **Cách lập trình `.spec.js`**:
  ```javascript
  const n0 = await page.locator('#grid tbody tr.dx-data-row').count();
  await chipChild.click(); // Chọn lọc con
  await page.waitForTimeout(800);
  await chipAll.click();   // Chọn lại Tất cả lần 2
  await page.waitForTimeout(800);
  const nRestore = await page.locator('#grid tbody tr.dx-data-row').count();
  expect(nRestore).toBe(n0); // Bắt buộc phải phục hồi nguyên vẹn n0 dòng
  ```

#### 🔸 `EDGE-FLT-02`: Bẫy Khoảng Ngày Mặc Định Ngầm (The Hidden Default Date Boundary Trap)
* **Đối tượng**: Mọi bộ lọc có gắn kèm khoảng ngày (FromDate, ToDate) ngầm hoặc nổi.
* **Mô tả bẫy lỗi**: Hệ thống ngầm định lấy ngày theo "Tuần này" hoặc "Tháng này" mà không có thông báo cho người dùng, làm biến mất các dữ liệu lịch sử hợp lệ tạo từ các tháng trước.
* **Cách lập trình `.spec.js`**:
  - Chặn request API: `const request = await page.waitForRequest(r => r.url().includes('/query'));`
  - Bóc tách POST data: `const postData = request.postData();`
  - Kiểm tra xem tham số `@FromDate` có bị ép ngầm khi người dùng KHÔNG hề chọn lọc theo ngày hay không.

#### 🔸 `EDGE-FLT-03`: Bẫy Ký Tự Đặc Biệt & SQL Injection Trong Ô Tìm Kiếm (Special Characters & SQLi)
* **Đối tượng**: Ô tìm kiếm nhanh (Search Box / Instant Filter).
* **Mô tả bẫy lỗi**: Người dùng gõ các ký tự nhạy cảm như `'`, `"`, `\`, `%`, `_`, `--`, `<script>` khiến Stored Procedure văng lỗi cú pháp SQL hoặc giao diện bị crash.
* **Cách lập trình `.spec.js`**:
  ```javascript
  await searchInput.fill("' OR '1'='1");
  await page.waitForTimeout(600);
  // Không được văng lỗi Unhandled Exception, bảng phải hiển thị Empty State an toàn
  const errorAlert = page.locator('.dx-error-message, .alert-danger');
  await expect(errorAlert).not.toBeVisible();
  ```

#### 🔸 `EDGE-FLT-04`: Bẫy Khoảng Trắng 2 Đầu Từ Khóa (Leading / Trailing Whitespace Trap)
* **Đối tượng**: Ô tìm kiếm nhanh, Ô nhập mã số/tên.
* **Mô tả bẫy lỗi**: Người dùng copy-paste từ khóa kèm khoảng trắng ở đầu hoặc cuối (vd: `" Nguyen Van A "`). Hệ thống so khớp chính xác (Exact match) thay vì tự động `trim()` làm kết quả tìm kiếm rỗng.
* **Cách lập trình `.spec.js`**:
  - Trích xuất tên dòng 1: `const realName = await firstRowName.innerText();`
  - Gõ vào ô search chuỗi có khoảng trắng thừa: `await searchInput.fill(`  ${realName}  `);`
  - Assert bảng vẫn phải tìm ra đúng bản ghi đó.

#### 🔸 `EDGE-FLT-05`: Bẫy Bộ Lọc Chồng Chéo Mâu Thuẫn (Conflicting Filter Combinations)
* **Đối tượng**: Kết hợp đồng thời 2-3 bộ lọc (ví dụ: Trạng thái = "Đã nghỉ việc" + Phòng ban = "Kinh doanh" + Tìm kiếm theo từ khóa).
* **Mô tả bẫy lỗi**: Khi reset 1 trong 3 bộ lọc, các bộ lọc còn lại bị reset ngầm hoặc gây ra câu query trả về dữ liệu sai lệch.
* **Cách lập trình `.spec.js`**:
  - Áp dụng lần lượt 3 tiêu chí $\rightarrow$ Ghi nhận số dòng.
  - Xóa 1 tiêu chí $\rightarrow$ Assert số dòng tăng lên hợp lý và 2 tiêu chí còn lại vẫn giữ nguyên hiệu lực.

---

### B. KHO BẪY LỖI NHẬP LIỆU & FORM CRUD (FORM & INPUT TRAPS)

#### 🔸 `EDGE-INP-01`: Bẫy Bấm Lưu Khi Form Trống Hoàn Toàn (Empty Form Submit)
* **Đối tượng**: Mọi Modal / Form Tạo mới hoặc Cập nhật.
* **Mô tả bẫy lỗi**: Người dùng mở popup rồi bấm thẳng vào nút "Lưu" mà chưa nhập bất kỳ thông tin nào. Hệ thống hoặc văng lỗi Backend 500, hoặc gửi dữ liệu `null` vào DB, hoặc đóng popup mà không có phản hồi gì.
* **Cách lập trình `.spec.js`**:
  ```javascript
  await openCreateModalBtn.click();
  await saveBtn.click(); // Bấm Lưu ngay khi form còn rỗng
  // BẮT BUỘC: Form không được đóng và phải hiển thị các viền đỏ / thông báo validation
  await expect(modal).toBeVisible();
  const invalidFields = page.locator('.dx-invalid, input:invalid, .field-validation-error');
  expect(await invalidFields.count()).toBeGreaterThan(0);
  ```

#### 🔸 `EDGE-INP-02`: Bẫy Click Đúp Nút Lưu Liên Tục (Double-Click / Rapid Fire Debounce)
* **Đối tượng**: Mọi nút Submit / Lưu / Gửi phê duyệt / Đặt hàng.
* **Mô tả bẫy lỗi**: Người dùng click đúp hoặc click liên tiếp 2-3 lần vào nút Lưu. Do frontend không vô hiệu hóa nút (disable) hoặc thiếu cơ chế debounce $\rightarrow$ Server nhận cùng lúc 2 request tạo ra 2 bản ghi trùng lặp (Duplicate Records) trong Database!
* **Cách lập trình `.spec.js`**:
  ```javascript
  // Lắng nghe số lượng request gửi đi
  let requestCount = 0;
  page.on('request', req => { if (req.url().includes('/save') && req.method() === 'POST') requestCount++; });
  // Giả lập click liên tiếp cực nhanh
  await saveBtn.click({ clickCount: 3, delay: 50 });
  await page.waitForTimeout(1500);
  // BẮT BUỘC: Hệ thống chỉ được phát ra tối đa 1 request lưu dữ liệu duy nhất!
  expect(requestCount).toBe(1);
  ```

#### 🔸 `EDGE-INP-03`: Bẫy Mất Dữ Liệu Khi Chuyển Tab Dở Dang (Tab Switch State Loss)
* **Đối tượng**: Form nhập liệu có nhiều Tab (vd: Tab 1: Thông tin chung, Tab 2: Người liên hệ, Tab 3: Tài khoản ngân hàng).
* **Mô tả bẫy lỗi**: Người dùng nhập dữ liệu ở Tab 1, chuyển sang Tab 2 xem rồi quay lại Tab 1 $\rightarrow$ Các ô input ở Tab 1 bị xóa sạch về rỗng!
* **Cách lập trình `.spec.js`**:
  ```javascript
  await tab1Input.fill('Dữ liệu thử nghiệm Tab 1');
  await tab2Header.click(); // Chuyển Tab 2
  await page.waitForTimeout(500);
  await tab1Header.click(); // Quay lại Tab 1
  // Dữ liệu Tab 1 PHẢI được giữ nguyên vẹn
  await expect(tab1Input).toHaveValue('Dữ liệu thử nghiệm Tab 1');
  ```

#### 🔸 `EDGE-INP-04`: Bẫy Thoát Không Lưu Không Cảnh Báo (Unsaved Changes / Dirty Form Exit)
* **Đối tượng**: Modal chỉnh sửa dữ liệu, Form chi tiết.
* **Mô tả bẫy lỗi**: Người dùng đã sửa nhiều trường quan trọng, nhưng lỡ tay bấm phím `Esc`, click vào nền mờ Backdrop hoặc bấm nút "Hủy". Hệ thống đóng ngay lập tức làm mất toàn bộ công sức nhập liệu mà không có bất kỳ lời cảnh báo nào.
* **Cách lập trình `.spec.js`**:
  - Nhập dữ liệu mới vào 1 ô input $\rightarrow$ Bấm nút "Hủy" hoặc phím `Escape`.
  - Assert hệ thống phải bật Dialog xác nhận: *"Dữ liệu chưa được lưu, bạn có chắc chắn muốn thoát?"*.

#### 🔸 `EDGE-INP-05`: Bẫy Tràn Giới Hạn Độ Dài Ký Tự (Max-length Overflow / Truncation)
* **Đối tượng**: Ô Mã số thuế, Số CMND/CCCD, Số điện thoại, Ghi chú.
* **Mô tả bẫy lỗi**: Cố tình nhập chuỗi quá dài (vd: 500 ký tự vào ô Tên ngắn có `varchar(50)`). Hệ thống văng lỗi SQL: `String or binary data would be truncated`.
* **Cách lập trình `.spec.js`**:
  - Gõ chuỗi 255 ký tự `A`.
  - Kiểm tra xem ô input có thuộc tính `maxlength` ngăn chặn nhập quá ngưỡng hay không, hoặc khi bấm Lưu hệ thống có validate độ dài hợp lệ hay không.

#### 🔸 `EDGE-INP-06`: Bẫy Số Âm & Tiền Tệ Âm (Negative & Zero Value Bypassing)
* **Đối tượng**: Ô Số lượng, Đơn giá, Lương cơ bản, Số ngày phép.
* **Mô tả bẫy lỗi**: Nhập số âm (vd: `-5000000`) hoặc số `0`. Backend không validate $\rightarrow$ Lưu số âm vào DB gây sai lệch báo cáo tài chính.
* **Cách lập trình `.spec.js`**:
  - Nhập `-1000` vào ô tiền tệ $\rightarrow$ Bấm Lưu $\rightarrow$ Bắt buộc assert thông báo lỗi: *"Số tiền phải lớn hơn 0"*.

---

### C. KHO BẪY LỖI BẢNG DỮ LIỆU & THAO TÁC (DATAGRID & ACTION TRAPS)

#### 🔸 `EDGE-GRD-01`: Bẫy Mã HTTP 200 Che Giấu Lỗi Backend (HTTP 200 Masking Trap)
* **Đối tượng**: Mọi request API qua Generic Handler (`.ashx`, `/api/query`, `/hpa/paradise2`).
* **Mô tả bẫy lỗi**: Server IIS luôn trả về HTTP 200 OK ngay cả khi SQL văng Exception hoặc trả về kết quả rỗng `data: [[]]`.
* **Cách lập trình `.spec.js`**:
  ```javascript
  const res = await page.waitForResponse(r => r.url().includes('/hpa/paradise2'));
  expect(res.status()).toBe(200); // ⚠️ KHÔNG ĐƯỢC DỪNG Ở ĐÂY!
  const json = await res.json();
  // Bóc tách kiểm tra bên trong có bị văng chuỗi lỗi SQL hay không
  expect(json.result).not.toContain('error');
  expect(json.result).not.toContain('Exception');
  ```

#### 🔸 `EDGE-GRD-02`: Bẫy Xóa Ngay Lập Tức Không Qua Xác Nhận (Accidental Instant Delete)
* **Đối tượng**: Nút icon Thùng rác / Nút Xóa trên bảng hoặc form.
* **Mô tả bẫy lỗi**: Người dùng lỡ tay click trúng icon Xóa $\rightarrow$ Hệ thống gọi API xóa luôn bản ghi trong tích tắc mà không hỏi lại người dùng!
* **Cách lập trình `.spec.js`**:
  - Di chuột click icon Xóa.
  - Bắt buộc kiểm tra Popup xác nhận ("Bạn có chắc chắn muốn xóa bản ghi này?") xuất hiện.
  - Bấm nút "Hủy" trên popup $\rightarrow$ Bản ghi vẫn còn nguyên vẹn trên bảng.

#### 🔸 `EDGE-GRD-03`: Bẫy Double-Click Mở Chi Tiết Nhưng Form Rỗng (Empty Detail Binding Trap)
* **Đối tượng**: DataGrid có tính năng nhấp đúp vào dòng để xem chi tiết.
* **Mô tả bẫy lỗi**: Nhấp đúp vào dòng, popup chi tiết mở lên thành công nhưng các ô input bên trong hoàn toàn trắng trơn (rỗng `""`) do API nạp chi tiết bị lỗi ID hoặc Stored Procedure thiếu tham số.
* **Cách lập trình `.spec.js`**:
  ```javascript
  const rowName = await row.locator('.col-name').innerText();
  await row.dblclick(); // Mở chi tiết
  await page.waitForResponse(r => r.url().includes('Detail'));
  // BẮT BUỘC: Ô input Tên trong modal chi tiết PHẢI BẰNG tên của dòng vừa click
  const detailNameInput = page.locator('#txtName, input[name="FullName"]');
  await expect(detailNameInput).not.toHaveValue('');
  await expect(detailNameInput).toHaveValue(rowName.trim());
  ```

#### 🔸 `EDGE-GRD-04`: Bẫy Mất Vị Trí Phân Trang Sau Khi Thao Tác (Pagination Reset Trap)
* **Đối tượng**: DataGrid có phân trang.
* **Mô tả bẫy lỗi**: Người dùng đang ở Trang 5, mở 1 bản ghi lên xem rồi đóng lại, hoặc sửa 1 bản ghi rồi Lưu. Hệ thống tự động reset về Trang 1 bắt người dùng phải cuộn và bấm lại từ đầu!
* **Cách lập trình `.spec.js`**:
  - Điều hướng sang Trang 3.
  - Mở chi tiết 1 bản ghi rồi đóng lại.
  - Assert DataGrid vẫn giữ nguyên trạng thái đang ở Trang 3.

---

### D. HƯỚNG DẪN BỔ SUNG KỊCH BẢN MỚI VÀO KHO (CONTRIBUTING NEW EDGE CASES)

Khi Agent hoặc Tester gặp một lỗi mới trong thực tế, **hãy mở file này và bổ sung thêm 1 mục theo đúng khung mẫu 5 thành tố chuẩn**:

```markdown
#### 🔸 `EDGE-[NHÓM]-[SỐ_THỨ_TỰ]`: <Tên Kịch Bản Biên / Bẫy Lỗi Rõ Ràng>
* **Đối tượng**: <Tên các control hoặc quy trình bị ảnh hưởng>
* **Mô tả bẫy lỗi**: <Bối cảnh thực tế và hậu quả nghiệp vụ khi gặp lỗi này>
* **Cách lập trình `.spec.js`**:
  <Đoạn mã mẫu Playwright bắt trọn trường hợp biên này>
* **Kỳ vọng hệ thống**: <Hành vi đúng mà hệ thống chuẩn mực phải đáp ứng>
```

---

## 3. Quy Trình Xử Lý Khi Người Dùng Yêu Cầu Viết Test Cho Một Trang/Menu


### Bước 1: Kiểm tra Trang đó ĐÃ TỪNG ĐƯỢC TEST CHƯA?
Agent quét thư mục `tests/` để tìm file spec tương ứng với chức năng đó (Ví dụ: `tests/employee.spec.js`, `tests/contracts.spec.js`, `tests/timesheet.spec.js`):

#### TRƯỜNG HỢP A: Trang CHƯA TỪNG được test (File spec chưa tồn tại)
1. **Tạo mới file** `tests/<tên_menu>.spec.js` (tên file viết thường, nối bằng dấu gạch dưới `_`).
2. **Áp dụng BỘ KHUNG MẪU CHUẨN (GOLDEN CODE BLUEPRINT)** — Mọi file test bắt buộc phải có đầy đủ 4 khối sau:

```javascript
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const PAGE_NAME = '<tên_menu>'; // Ví dụ: 'employee_bank_approval'

// ============================================================================
// KHỐI 1: CÁC HELPER BẮT BUỘC (DI CHUỘT TRỰC QUAN & CHỤP ẢNH TỪNG BƯỚC)
// ============================================================================

// Di chuyển chuột Neon mượt mà, dừng ngắm và click (đồng bộ 100% thời gian thực)
async function moveAndClick(page, locator, options = {}) {
  await locator.scrollIntoViewIfNeeded().catch(() => {});
  const box = await locator.boundingBox();
  if (box) {
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await page.mouse.move(x, y, { steps: options.steps || 8 });
    if (options.pause) await page.waitForTimeout(options.pause);
  }
  await locator.click();
}

// Chụp ảnh từng bước tuần tự (Step-by-Step Evidence) với tiêu đề tiếng Việt chuẩn
async function captureStep(page, testInfo, { tcId, step, desc, pageName = PAGE_NAME }) {
  const safeDesc = desc
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  const fileName = `${tcId}-step${String(step).padStart(2, '0')}-${safeDesc}.png`;
  const dir = path.resolve(__dirname, `../test-evidence/${pageName}/${tcId}/screenshots`);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const filePath = path.join(dir, fileName);
  await page.screenshot({ path: filePath, fullPage: false });
  await testInfo.attach(`Bước ${step}: ${desc}`, {
    path: filePath,
    contentType: 'image/png'
  });
  console.log(`📸 [${tcId}] Đã chụp Bước ${step}: ${desc}`);
}

// ============================================================================
// KHỐI 2: CẤU HÌNH PHIÊN & CHUỘT PHÁT SÁNG NEON
// ============================================================================
test.use({ storageState: { cookies: [], origins: [] } });

test.describe('Kiểm thử Phân hệ/Trang: <Tên Tiếng Việt>', () => {
  test.beforeEach(async ({ context }) => {
    await context.clearCookies();
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
      await context.addInitScript(cursorScript);
    }
  });

  // ==========================================================================
  // KHỐI 3: KỊCH BẢN CHUẨN 5 BƯỚC NGHIỆP VỤ (TC-01)
  // ==========================================================================
  test('TC-01: <Tiêu đề kịch bản rõ ràng>', async ({ page }, testInfo) => {
    // 🌐 BƯỚC 1: Mở trang & Đăng nhập
    await page.goto('https://<url_web>/#', { waitUntil: 'domcontentloaded' });
    const userInput = page.locator('#username');
    await moveAndClick(page, userInput);
    await userInput.pressSequentially('<username>', { delay: 35 });
    const passInput = page.locator('input[type="password"]');
    await moveAndClick(page, passInput);
    await passInput.pressSequentially('<password>', { delay: 35 });
    await moveAndClick(page, page.locator('#submitLogin'));
    await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Đăng nhập thành công và mở trang chủ'
    });

    // 📂 BƯỚC 2: Điều hướng vào phân hệ & mở màn hình
    const menuBtn = page.locator('...').first();
    await moveAndClick(page, menuBtn);
    await page.waitForTimeout(1500);

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Mở màn hình mục tiêu cần thao tác'
    });

    // 📝 BƯỚC 3: Thao tác nhập liệu hoặc chọn bản ghi
    const inputField = page.locator('input.dx-texteditor-input').first();
    await moveAndClick(page, inputField);
    await inputField.pressSequentially('Dữ liệu thử nghiệm', { delay: 35 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: 'Điền đầy đủ thông tin vào form'
    });

    // 🎯 BƯỚC 4: Di chuyển chuột Neon lên nút hành động chính (Lưu/Duyệt)
    const actionBtn = page.locator('button:has-text("Lưu")').first();
    await actionBtn.scrollIntoViewIfNeeded().catch(() => {});
    const btnBox = await actionBtn.boundingBox();
    if (btnBox) {
      await page.mouse.move(btnBox.x + btnBox.width / 2, btnBox.y + btnBox.height / 2, { steps: 10 });
      await page.waitForTimeout(300);
    }

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 4,
      desc: 'Con trỏ chuột Neon di chuyển và bấm nút Lưu thay đổi'
    });

    await actionBtn.click();
    await page.waitForTimeout(2000);

    // ✅ BƯỚC 5: Kết quả phản hồi từ hệ thống
    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 5,
      desc: 'Hệ thống xác nhận thao tác thành công'
    });

    // ========================================================================
    // KHỐI 4: ĐÁNH GIÁ TRẠNG THÁI NGHIỆP VỤ (DUAL STATUS)
    // ========================================================================
    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Dữ liệu đã được lưu và hệ thống phản hồi thành công'
    });
  });
});
```

#### TRƯỜNG HỢP B: Trang ĐÃ TỪNG được test (File spec đã tồn tại)
1. **Đọc nội dung file hiện tại** `tests/<tên_menu>.spec.js`.
2. **Tìm mã số Test Case cao nhất** đã có trong file bằng regex `TC-(\d+)`:
   - Ví dụ: File đã có `TC-01` và `TC-02` $\rightarrow$ Số cao nhất là `2`.
   - Sinh mã kế tiếp: `TC-03`.
3. **Bổ sung test case mới theo đúng chuẩn 5 bước và Dual Status**:
   - Nếu kịch bản **ĐẠT**: Đính kèm `business_status: PASS`.
   - Nếu kịch bản **PHÁT HIỆN LỖI (BUG)**: Đính kèm `business_status: FAIL` và khối `business_analysis` JSON đầy đủ 5 thành tố:
   ```javascript
   testInfo.annotations.push({
     type: 'business_status',
     description: 'FAIL - Thông tin dữ liệu không cập nhật sau khi xử lý'
   });
   testInfo.annotations.push({
     type: 'business_analysis',
     description: JSON.stringify({
       issue: 'Tóm tắt ngắn gọn lỗi phát hiện được',
       expected: 'Kỳ vọng nghiệp vụ hệ thống lẽ ra phải trả về',
       actual: 'Thực tế hệ thống đang phản hồi sai',
       rootCause: 'Phân tích nguyên nhân kỹ thuật (Stored Procedure, API hoặc UI binding)',
       recommendation: 'Đề xuất hướng xử lý cụ thể cho team Dev / BA'
     })
   });
   ```

---

### Bước 2: Đảm Bảo Tự Động Cập Nhật Vào Menu `.bat`
Sau khi tạo hoặc sửa file test:
1. File [`menu_runner.ps1`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/menu_runner.ps1) và [`Run-ParadiseHR-Interactive.bat`](file:///c:/Users/Y.Thach/Desktop/Run-ParadiseHR-Interactive.bat) tự động quét và cập nhật:
   - Nếu là **Trang mới**: Menu chính cấp 1 sẽ lập tức xuất hiện thêm số `[N] tests/<tên_menu>.spec.js -> <Tiêu đề>`.
   - Nếu là **Bổ sung TC**: Khi người dùng chọn menu đó, Menu cấp 2 sẽ lập tức hiển thị thêm dòng `[X] TC-0x: <Mô tả>`.
2. Agent đảm bảo đồng bộ file launcher ra Desktop:
   ```powershell
   Copy-Item "c:\Users\Y.Thach\Desktop\paradiseHR\Run-ParadiseHR-Interactive.bat" -Destination "C:\Users\Y.Thach\Desktop\Run-ParadiseHR-Interactive.bat" -Force
   ```

---

### Bước 3: Chạy Thử & Kiểm Tra Nghiệm Thu (Verification)
1. **Thực thi kiểm thử test case vừa tạo**:
   ```powershell
   npx playwright test tests/<tên_menu>.spec.js -g "TC-0x" --headed
   ```
2. **Kiểm tra file kết quả**:
   - Xác nhận thư mục `test-evidence/<tên_menu>/TC-0x/` đã được sinh ra đầy đủ (`screenshots/`, `videos/`, `traces/`, `results.json`).
   - Đọc báo cáo trang [`test-evidence/<tên_menu>/test-report.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/test-evidence/) và báo cáo tổng thể [`test-evidence/test-report.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/test-evidence/test-report.md).
   - Nếu `FAILED`, phân tích lỗi từ trace/screenshot, sửa code và retest đến khi `PASSED`.

---

### Bước 4: Bàn Giao Kết Quả Cho Người Dùng
Agent báo cáo ngắn gọn, rõ ràng cho người dùng:
1. **Thông tin kịch bản**: Đã tạo mới file nào hoặc bổ sung `TC-0x` nào vào menu nào.
2. **Báo cáo nghiệm thu**: Cung cấp link mở file báo cáo tổng hợp và thư mục bằng chứng `test-evidence/<tên_menu>/<TC-0x>/`.
3. **Hướng dẫn người dùng chạy lại**:
   - Mở file [`Run-ParadiseHR-Interactive.bat`](file:///C:/Users/Y.Thach/Desktop/Run-ParadiseHR-Interactive.bat) ngoài Desktop để thấy ngay Option mới vừa được bổ sung!
   - Hoặc vào trực tiếp thư mục `test-evidence/<tên_menu>/<TC-0x>/` và nhấp đúp file `Run-This-TC.bat` để xem lại riêng test case này.

---

## 4. Hướng Dẫn Kỹ Thuật: Cách Tạo File .BAT 1-Click Cho Từng Cấp Độ

Mọi AI Agent khi thực thi skill này phải nắm rõ cơ chế và cấu trúc để tạo các file `.bat` 1-Click tự động:

### A. File `Run-This-TC.bat` (Đặt trong `test-evidence/<tên_trang>/<TC-0x>/`):
Mục đích: Cho phép người dùng nhấp đúp để mở Chrome thật chạy riêng đúng test case này với chuột Neon và gõ phím trực quan.

**Cấu trúc mã nguồn chuẩn của file `Run-This-TC.bat`**:
```bat
@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: <tên_trang> - <TC-0x>
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: <TC-0x> (<tên_trang>.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 400ms)...
echo.
cd /d "%~dp0..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/<tên_trang>.spec.js -g "<TC-0x>" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
```

---

### B. File `Run-This-Page.bat` (Đặt trong `test-evidence/<tên_trang>/`):
Mục đích: Cho phép người dùng nhấp đúp để chạy lại toàn bộ tất cả các test case của trang này.

**Cấu trúc mã nguồn chuẩn của file `Run-This-Page.bat`**:
```bat
@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Trang <tên_trang>
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TOAN BO TRANG: <tên_trang>.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 400ms)...
echo.
cd /d "%~dp0..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/<tên_trang>.spec.js --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG!
echo ====================================================================
echo.
pause
```

---

### C. Cách Tự Động Hóa Sinh File `.bat` Bằng Mã Nguồn Node.js:
Trong custom reporter [`markdown-reporter.js`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/markdown-reporter.js) hoặc khi Agent tạo test case mới, Agent sử dụng đoạn mã sau để tự động sinh file:

```javascript
// 1. Tự động sinh Run-This-TC.bat trong thư mục của test case
const batPath = path.join(tcDir, 'Run-This-TC.bat');
const batContent = `@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: ${pageName} - ${tcId}
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: ${tcId} (${pageName}.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 400ms)...
echo.
cd /d "%~dp0..\\..\\.."
if not exist "node_modules" (
    cd /d "c:\\Users\\Y.Thach\\Desktop\\paradiseHR"
)
call npx playwright test tests/${pageName}.spec.js -g "${tcId}" --headed --workers=1
echo.
pause
`;
fs.writeFileSync(batPath, batContent, 'utf8');

// 2. Tự động sinh Run-This-Page.bat trong thư mục của trang
const pageBatPath = path.join(pageDir, 'Run-This-Page.bat');
const pageBatContent = `@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Trang ${pageName}
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TOAN BO TRANG: ${pageName}.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 400ms)...
echo.
cd /d "%~dp0..\\.."
if not exist "node_modules" (
    cd /d "c:\\Users\\Y.Thach\\Desktop\\paradiseHR"
)
call npx playwright test tests/${pageName}.spec.js --headed --workers=1
echo.
pause
`;
fs.writeFileSync(pageBatPath, pageBatContent, 'utf8');
```

---

### D. Giải thích các tham số kỹ thuật then chốt trong file `.bat`:
1. `chcp 65001 >nul`: Bật chế độ UTF-8 cho Command Prompt của Windows để hiển thị tiếng Việt có dấu đẹp mắt, không bị vỡ font.
2. `%~dp0`: Biến môi trường đặc biệt của Windows Batch chỉ định đường dẫn thư mục hiện thời nơi file `.bat` đang cư trú.
   - Với `Run-This-TC.bat` nằm ở tầng 3 (`test-evidence/<trang>/<TC-0x>/`), lùi 3 cấp `%~dp0..\..\..` sẽ trỏ chính xác về gốc dự án!
3. `if not exist "node_modules"`: Cơ chế phòng vệ tự động (fallback) — nếu người dùng copy thư mục hoặc chạy từ shortcut, script vẫn tự động tìm về thư mục gốc dự án để chạy.
4. `-g "<TC-0x>"`: Cờ Grep của Playwright để chỉ chạy đúng test case này và bỏ qua các test case khác trong file.
5. `--headed --workers=1`: Bắt buộc mở 1 cửa sổ Google Chrome thật duy nhất trên màn hình để người dùng quan sát trực quan.

---

## 7. Cơ Chế Tự Động Chạy Theo Hệ Thống Hiện Tại & Xử Lý Khi Hệ Thống Thay Đổi

### 1. Cơ chế tự động chạy theo hệ thống hiện tại
Mỗi khi bạn mở bất kỳ file `.bat` nào:
* 🎯 **`Run-This-TC.bat`**: Chạy lại riêng 1 kịch bản cụ thể.
* 📄 **`Run-This-Page.bat`**: Chạy lại toàn bộ kịch bản của trang đó.
* 🖥️ **`Run-ParadiseHR-Interactive.bat`**: Menu tổng ngoài Desktop để chọn chạy bất kỳ trang nào.

**Hệ thống sẽ tự động thực hiện hoàn toàn mới:**
* Mở trình duyệt Google Chrome thật và truy cập thẳng vào trang web hiện tại (theo URL trong `test.env.json`).
* Quay một Video `.webm` MỚI TOANH ghi lại toàn bộ chuyển động con trỏ chuột Neon và hành động trên giao diện mới nhất.
* Chụp các ảnh Screenshot MỚI để lưu vết màn hình tại thời điểm chạy.
* Cập nhật lại Báo cáo `test-report.md` và `results.json`:
  - Ghi nhận chính xác ngày giờ vừa chạy (`timestamp`).
  - Nếu hệ thống chạy tốt $\rightarrow$ Đánh dấu **✅ PASS**.
  - Nếu hệ thống vừa sửa phát sinh lỗi (bug) $\rightarrow$ Đánh dấu **❌ FAIL**, trích xuất ảnh lỗi và log lỗi chi tiết vào báo cáo để bạn gửi cho team dev sửa ngay!

### 2. Hai trường hợp khi hệ thống thay đổi
* **Trường hợp 1 (Sửa backend/logic, UI giữ nguyên)**:
  👉 Bạn chỉ việc chạy file `.bat`. Không cần sửa bất kỳ dòng mã test nào, kết quả, ảnh chụp và video mới sẽ tự động cập nhật phản ánh đúng trạng thái hệ thống hiện tại.
* **Trường hợp 2 (Giao diện đổi lớn: đổi tên nút, đổi luồng, đổi vị trí menu)**:
  👉 Bạn chỉ cần nhắn AI một câu: *"Hệ thống vừa đổi menu X thành Y / đổi quy trình duyệt, hãy cập nhật lại kịch bản test"*. AI sẽ mở trình duyệt dò lại và cập nhật kịch bản `.spec.js`. Sau đó file `.bat` của bạn vẫn tiếp tục sử dụng bình thường mà không cần làm lại từ đầu!

---

## 8. Chuẩn Báo Cáo Kép (Dual Status) & Cơ Chế Tự Suy Luận Expect

### 1. Chuẩn Báo Cáo Phân Tách 2 Trạng Thái Cho Mọi Test Case:
Trong mọi file `test-report.md` và `results.json`, bắt buộc phải phân tách rạch ròi:
* **Trạng thái thực thi Test (Kỹ thuật - Test Execution)**:
  - `✅ PASS`: Script Playwright mở trang, click, gõ phím, lưu video thông suốt mà không bị crash code hoặc timeout.
  - `❌ FAIL`: Script bị lỗi cú pháp, locator gãy hoặc trang không phản hồi.
* **Trạng thái Logic Nghiệp vụ (Business Output / Logic Validation)**:
  - `✅ PASS`: Dữ liệu thực tế trên màn hình (Actual Output) khớp chính xác 100% với giá trị mong đợi (Expected Output).
  - `❌ FAIL`: Phát hiện **Lỗi Logic / Bug của Hệ thống** (ví dụ: Quản lý bấm Duyệt thành công nhưng màn hình hồ sơ vẫn trắng trơn không cập nhật dữ liệu).

### 2. Cơ Chế Tự Động Suy Luận Expect (Người dùng không cần prompt chi tiết):
Người dùng **KHÔNG CẦN phải prompt chi tiết từng Expect** cho mỗi Test Case. AI Agent tự động suy luận các điểm kiểm thử nghiệp vụ chuẩn mực:
* **Form Cập nhật / Nhập liệu**: Tự suy luận kỳ vọng thông báo thành công (Toast/Alert), popup đóng, và dữ liệu lưu vào bảng.
* **Quy trình Phê duyệt (Approval Flow)**: Tự suy luận kỳ vọng badge chuyển từ `Chờ duyệt` sang `Đã duyệt`, đơn biến mất khỏi danh sách chờ.
* **Chu trình Khép kín (End-to-End Verification)**: Tự suy luận khi người gửi mở lại hồ sơ, các ô dữ liệu phải hiển thị đúng giá trị mới được duyệt thay vì để trống.
* **Khi nào người dùng mới cần prompt thêm?** Chỉ khi hệ thống có **quy tắc nghiệp vụ đặc thù riêng của doanh nghiệp** (ví dụ: *"Sau khi duyệt phải qua 0h đêm mới có hiệu lực"*, hoặc *"Số tài khoản ngân hàng chỉ nhận tối đa 10 số"*).

---

## 9. Tiêu Chuẩn Chụp Ảnh Step-by-Step (Bắt Buộc - Visual Storyboard)

Tuyệt đối **KHÔNG CHỈ CHỤP DUY NHẤT 1 MÀN HÌNH CUỐI** hoặc để nhiều ảnh trùng lặp vô nghĩa (`test-finished-1.png`). Mọi kịch bản kiểm thử bắt buộc phải ghi lại chuỗi bằng chứng tuần tự theo từng thao tác chính:

### 1. Các điểm mốc bắt buộc phải chụp ảnh (Milestones):
1. **Bước 1**: Đăng nhập thành công và mở trang/menu mục tiêu.
2. **Bước 2**: Mở màn hình/modal thao tác hoặc chọn bản ghi dữ liệu.
3. **Bước 3**: Điền dữ liệu vào form hoặc tích chọn các tùy chọn.
4. **Bước 4**: Di chuyển chuột Neon trực tiếp lên nút bấm hành động chính (Lưu, Duyệt, Xóa, Xác nhận) để người xem thấy rõ điểm click.
5. **Bước 5**: Kết quả phản hồi của hệ thống (Toast thành công, đóng modal, hoặc màn hình đối chiếu dữ liệu sau thao tác).

### 2. Quy cách đặt tên file ảnh và đính kèm:
Sử dụng helper chuẩn trong mã nguồn:
```javascript
async function captureStep(page, testInfo, { tcId, step, desc, pageName }) {
  const safeDesc = desc.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, '-');
  const fileName = `${tcId}-step${String(step).padStart(2, '0')}-${safeDesc}.png`;
  const dir = path.resolve(__dirname, `../test-evidence/${pageName}/${tcId}/screenshots`);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const filePath = path.join(dir, fileName);
  await page.screenshot({ path: filePath, fullPage: false });
  await testInfo.attach(`Bước ${step}: ${desc}`, { path: filePath, contentType: 'image/png' });
}
```

### 3. Trình bày trong Báo cáo Markdown:
Từng ảnh được đặt dưới tiêu đề phân cấp rõ ràng:
```markdown
##### 📸 Bước 1: Đăng nhập thành công với tài khoản nhân viên
![Bước 1: Đăng nhập thành công](TC-01/screenshots/TC-01-step01-dang-nhap.png)

##### 📸 Bước 2: Điền đầy đủ thông tin vào form
![Bước 2: Điền thông tin](TC-01/screenshots/TC-01-step02-dien-form.png)
```

---

## 10. Tiêu Chuẩn Phân Tích Nguyên Nhân Thất Bại Khi TC FAIL (Failure Analysis)

Khi một Test Case bị đánh giá **FAIL** (dù là Kỹ thuật hay Logic Nghiệp vụ), báo cáo nghiệm thu **BẮT BUỘC PHẢI CÓ KHỐI PHÂN TÍCH LỖI CHI TIẾT** theo định dạng GitHub Alert `> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)`.

### Cấu trúc 5 thành tố bắt buộc:
1. **Vấn đề / Mã lỗi**: Tóm tắt ngắn gọn lỗi phát hiện được.
2. **Kỳ vọng nghiệp vụ (Expected Output)**: Hệ thống lẽ ra phải hoạt động hoặc trả về kết quả gì theo chuẩn nghiệp vụ.
3. **Thực tế hệ thống (Actual Output)**: Trên thực tế, hệ thống phản hồi như thế nào (kèm trích dẫn dữ liệu rỗng, mã lỗi, hoặc thông báo sai).
4. **Nguyên nhân cốt lõi (Root Cause)**: Phân tích nguyên nhân kỹ thuật (Stored Procedure nào chưa UPDATE dữ liệu, API nào chưa nạp, hoặc component frontend nào binding sai).
5. **Đề xuất khắc phục (Recommendation)**: Hướng dẫn cụ thể cho đội ngũ Backend/Frontend/DBA cách sửa lỗi nhanh chóng.

### Mẫu trình bày trong báo cáo:
```markdown
> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)
>
> * **Vấn đề / Mã lỗi**: Dữ liệu số tài khoản và thông tin ngân hàng không cập nhật vào hồ sơ cá nhân sau khi Quản lý phê duyệt thành công
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Sau khi Quản lý Cuong.Vu thực hiện duyệt ở TC-02, số tài khoản mới (ví dụ 99xxxxxxx) và ngân hàng phải được nạp đầy đủ vào form Thông tin ngân hàng của nhân viên Tai.Dang
> * **Thực tế hệ thống (Actual Output)**: Các ô nhập liệu Số tài khoản, Ngân hàng, Chi nhánh trong form Thông tin ngân hàng của nhân viên vẫn hoàn toàn rỗng ("")
> * **Nguyên nhân cốt lõi (Root Cause)**: Hệ thống Paradise HRM khi gọi sp_approve_EmployeeChange mới chỉ cập nhật cờ trạng thái trong bảng yêu cầu thay đổi (sp_EmployeeChange_Detail), nhưng chưa thực hiện câu lệnh UPDATE dữ liệu vào bảng chính của nhân viên (tbl_HRS_Employee / tbl_HRS_Employee_Bank).
> * **Đề xuất khắc phục (Recommendation)**: Đội ngũ Backend cần kiểm tra lại Stored Procedure sp_approve_EmployeeChange để đảm bảo dữ liệu được đồng bộ vào bảng nhân viên chính thức; đồng thời kiểm tra luồng API nạp dữ liệu lên form Hồ sơ nhân viên.
```

---

## 11. KHUNG MẪU CHUẨN BÁO CÁO NGHIỆM THU MARKDOWN (THE GOLDEN REPORT BLUEPRINT)

Báo cáo nghiệm thu kiểm thử là sản phẩm cốt lõi bàn giao cho Quản lý dự án, Developer và QA/BA. Báo cáo bắt buộc phải theo chuẩn trực quan Storyboard, phân tách trạng thái kép (Dual Status), cung cấp đầy đủ bằng chứng tuần tự theo từng bước và khối phân tích nguyên nhân lỗi khi có thất bại.

Mọi báo cáo nghiệm thu sinh ra (`test-evidence/<tên_trang>/test-report.md`) bắt buộc phải tuân theo cấu trúc chuẩn mực sau:

### Cấu Trúc Khung Mẫu Báo Cáo Cấp Trang (`test-report.md`):

```markdown
# BÁO CÁO KIỂM THỬ TRANG: <TÊN_TRANG_IN_HOA>

> Thời gian kiểm thử: **HH:mm:ss dd/MM/yyyy**
> Tổng số kịch bản: **N** | ✅ LOGIC PASS: **X** | ❌ LOGIC FAIL: **Y**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | <Tiêu đề TC-01> | ✅ PASS | ✅ PASS | <Tóm tắt kết quả nghiệp vụ TC-01> |
| **TC-02** | <Tiêu đề TC-02> | ✅ PASS | ✅ PASS | <Tóm tắt kết quả nghiệp vụ TC-02> |
| **TC-03** | <Tiêu đề TC-03> | ✅ PASS | ❌ FAIL | <Tóm tắt phát hiện Bug nghiệp vụ TC-03> |

---

### TC-01: <Tiêu đề kịch bản thành công>

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `38.01s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: Yêu cầu cập nhật thông tin đã được gửi thành công lên hệ thống phê duyệt
* **Thư mục lưu trữ**: `test-evidence/<tên_trang>/TC-01/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Đăng nhập thành công với tài khoản nhân viên Tai.Dang
![Bước 1: Đăng nhập thành công với tài khoản nhân viên Tai.Dang](TC-01/screenshots/TC-01-step01-dang-nhap-thanh-cong.png)

##### 🔹 Bước 2: Mở màn hình Hồ sơ nhân viên và khu vực thông tin cá nhân
![Bước 2: Mở màn hình Hồ sơ nhân viên](TC-01/screenshots/TC-01-step02-mo-man-hinh-ho-so.png)

##### 🔹 Bước 3: Nhập đầy đủ thông tin vào form chỉnh sửa
![Bước 3: Nhập thông tin form](TC-01/screenshots/TC-01-step03-nhap-thong-tin.png)

##### 🔹 Bước 4: Con trỏ chuột Neon di chuyển và nhấp nút Lưu thay đổi
![Bước 4: Con trỏ Neon di chuyển bấm nút](TC-01/screenshots/TC-01-step04-con-tro-chuot-neon-bam-luu.png)

##### 🔹 Bước 5: Hệ thống hoàn tất gửi yêu cầu phê duyệt
![Bước 5: Hệ thống xác nhận](TC-01/screenshots/TC-01-step05-he-thong-xac-nhan.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-01/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/<tên_trang>/TC-01/traces/trace.zip`)*

---

### TC-03: <Tiêu đề kịch bản phát hiện Bug / Thất bại>

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `29.79s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: FAIL - Dữ liệu không hiển thị trên hồ sơ sau khi đã được phê duyệt
* **Thư mục lưu trữ**: `test-evidence/<tên_trang>/TC-03/`

> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)
>
> * **Vấn đề / Mã lỗi**: Dữ liệu số tài khoản và thông tin ngân hàng không cập nhật vào hồ sơ cá nhân sau khi Quản lý phê duyệt thành công
> * **Kỳ vọng nghiệp vụ (Expected Output)**: Sau khi Quản lý Cuong.Vu thực hiện duyệt ở TC-02, số tài khoản mới (ví dụ 99xxxxxxx) và ngân hàng phải được nạp đầy đủ vào form Thông tin ngân hàng của nhân viên Tai.Dang
> * **Thực tế hệ thống (Actual Output)**: Các ô nhập liệu Số tài khoản, Ngân hàng, Chi nhánh trong form Thông tin ngân hàng của nhân viên vẫn hoàn toàn rỗng ("")
> * **Nguyên nhân cốt lõi (Root Cause)**: Hệ thống Paradise HRM khi gọi sp_approve_EmployeeChange mới chỉ cập nhật cờ trạng thái trong bảng yêu cầu thay đổi (sp_EmployeeChange_Detail), nhưng chưa thực hiện câu lệnh UPDATE dữ liệu vào bảng chính của nhân viên (tbl_HRS_Employee / tbl_HRS_Employee_Bank), hoặc API lấy thông tin nhân viên chưa nạp dữ liệu từ nguồn đã duyệt.
> * **Đề xuất khắc phục (Recommendation)**: Đội ngũ Backend cần kiểm tra lại Stored Procedure sp_approve_EmployeeChange để đảm bảo dữ liệu được đồng bộ vào bảng nhân viên chính thức; đồng thời kiểm tra luồng API nạp dữ liệu lên form Hồ sơ nhân viên.

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Nhân viên Tai.Dang đăng nhập lại hệ thống để kiểm tra thông tin sau duyệt
![Bước 1: Nhân viên đăng nhập lại](TC-03/screenshots/TC-03-step01-dang-nhap-lai.png)

##### 🔹 Bước 2: Điều hướng đến mục Thông tin Ngân hàng & Thuế trên màn hình Hồ sơ nhân viên
![Bước 2: Mở hồ sơ nhân viên](TC-03/screenshots/TC-03-step02-mo-ho-so.png)

##### 🔹 Bước 3: Bằng chứng đối chiếu thực tế: Form Thông tin ngân hàng vẫn rỗng dữ liệu sau khi duyệt
![Bước 3: Bằng chứng form rỗng](TC-03/screenshots/TC-03-step03-bang-chung-form-rong.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-03/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-03/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/<tên_trang>/TC-03/traces/trace.zip`)*

---
```

### Các Tiêu Chí Thẩm Định Báo Cáo Đạt Chuẩn (Definition of Done for Reports):
1. **Bảng đối chiếu kép ngay đầu báo cáo**: Phải có đầy đủ 5 cột (`Mã TC`, `Tiêu đề Kịch bản`, `Trạng thái Test`, `Trạng thái Logic`, `Đánh giá Nghiệp vụ`).
2. **Không có ảnh trùng lặp**: Tuyệt đối không xuất hiện `test-finished-1.png` hay nhiều ảnh chụp cùng 1 trạng thái cuối.
3. **Ảnh Storyboard tuần tự**: Mỗi bước đều có heading `##### 🔹 Bước X: <Tên bước>` và ảnh minh họa rõ nét vị trí con trỏ chuột Neon.
4. **Bắt buộc có Failure Analysis khi FAIL**: Phải có khối `> [!CAUTION]` với đủ 5 thành tố (Vấn đề, Kỳ vọng, Thực tế, Nguyên nhân cốt lõi, Đề xuất khắc phục).
5. **Đầy đủ đính kèm đa phương tiện**: Phải có link mở trực tiếp file `video.webm` và file `trace.zip` kèm cú pháp lệnh `npx playwright show-trace`.





