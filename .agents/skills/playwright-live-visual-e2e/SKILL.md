---
name: playwright-live-visual-e2e
description: >-
  Thực hiện kiểm thử E2E trực quan (Live Visual Testing) trên Google Chrome thật: hiển thị cửa sổ trên màn hình Windows, mô phỏng con trỏ chuột Neon, gõ phím chậm rãi quan sát được, tự động quay video, chụp ảnh và xuất báo cáo Markdown vào test-evidence/. Sử dụng khi người dùng yêu cầu viết test hoặc kiểm thử bất kỳ menu, màn hình, form, API hay user flow nào. Tự động nhận diện tạo mới TC-01 nếu trang chưa có hoặc bổ sung TC-02, TC-03... nếu trang đã có, tổ chức thư mục bằng chứng phân cấp theo từng Trang và từng TC, đồng thời tự động cập nhật vào menu 1-Click .bat.
---

# Playwright Live Visual E2E — Kiểm thử trực quan trên màn hình thật

Skill này là kim chỉ nam cho AI Agent khi thực hiện yêu cầu kiểm thử tự động trực quan trên hệ thống web (Paradise HRM hoặc các dự án tương tự). Khi người dùng yêu cầu kiểm thử bất kỳ menu/trang nào, Agent tự động phân tích DOM, khởi tạo hoặc bổ sung test case theo chuẩn `TC-01`, `TC-02`, lưu bằng chứng nghiệm thu theo đúng cấu trúc thư mục phân cấp (`test-evidence/<tên_trang>/<TC-0x>/` hoặc `test-evidence/test-flow-tinhluong/<tên_conversation>/<tên_trang>/`), kiểm tra cơ chế quét động của file `.bat`, thực thi kiểm thử và xuất báo cáo nghiệm thu theo đúng chuẩn.

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
2. **Đối với các quy trình luồng kiểm thử liên hoàn nhiều conversation (ví dụ Flow Tính lương)**:
   - Thư mục được tổ chức theo cấp phân quyền:
     `test-evidence/test-flow-tinhluong/<tên_conversation>/<tên_trang>/`
   - Chứa file `Run-This-Page.bat` (chạy toàn bộ các TC trong trang do conversation đó làm) và từng thư mục `TC-xx/` với `Run-This-TC.bat`.
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

---

### 2.0. QUY CHUẨN KỸ THUẬT VỀ CON TRỎ CHUỘT NEON, CỬA SỔ TOÀN MÀN HÌNH & THAO TÁC THỜI GIAN THỰC (REALTIME VISUAL CURSOR & FULLSCREEN SPECIFICATION)

> [!IMPORTANT]
> **5 NGUYÊN TẮC BẤT BIẾN KHI THỰC THI KIỂM THỬ TRỰC QUAN (LIVE VISUAL TESTING):**
> 1. **Cửa sổ Google Chrome Full Màn Hình 100% (No Black Borders / No Viewport Override)**:
>    * Trong `playwright.config.js` hoặc file `.spec.js`, bắt buộc cấu hình:
>      ```javascript
>      // Cấu hình Full màn hình tràn viền
>      viewport: null, // BẮT BUỘC: Không gán { width: 1440, height: 900 } làm co màn hình!
>      launchOptions: {
>        args: ['--start-maximized', '--no-sandbox', '--disable-setuid-sandbox']
>      }
>      ```
>    * **Tuyệt đối cấm** gán cứng `viewport: { width: 1440, height: 900 }` trong `test.use` vì sẽ ghi đè `viewport: null`, tạo ra 2 vệt viền đen hai bên và thu nhỏ khung hiển thị của Chrome.
>
> 2. **File JS Tạo Con Trỏ Chuột Neon (`visual_cursor.js`)**:
>    * File định nghĩa con trỏ chuột Neon nằm tại thư mục gốc của dự án:
>      👉 **`c:\Users\Y.Thach\Desktop\paradiseHR\visual_cursor.js`**
>    * **Thành phần tạo lập**:
>      - `#__ag_cursor__`: Con trỏ chuột hình mũi tên Neon đỏ-hồng (`fill="#e11d48"`, `stroke="#ffffff"`), có chấm tròn phát sáng tâm bấm (`#f43f5e`).
>      - `.__ag_ripple__`: Hiệu ứng sóng tròn gợn lan tỏa (ripple effect) mỗi khi bấm chuột xuống (`mousedown`).
>      - `#__ag_typing_badge__`: Bong bóng hiển thị phím gõ `⌨️ Typing...` kèm từng ký tự gõ thời gian thực.
>    * **Cơ chế nhúng tự động vào trang**:
>      Trong mọi file `.spec.js`, bắt buộc phải có khối `test.beforeEach` đọc và nhúng script này vào context:
>      ```javascript
>      test.beforeEach(async ({ context }) => {
>        const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
>        if (fs.existsSync(cursorScriptPath)) {
>          const cursorScript = fs.readFileSync(cursorScriptPath, 'utf8');
>          await context.addInitScript(cursorScript);
>        }
>      });
>      ```
>
> 3. **Di Chuyển Chuột & Click Trực Quan (`moveAndClick`)**:
>    * Thay vì gọi `locator.click()` mù quáng lập tức, bắt buộc dùng helper `moveAndClick`:
>      ```javascript
>      async function moveAndClick(page, locator, options = {}) {
>        await locator.scrollIntoViewIfNeeded().catch(() => {});
>        const box = await locator.boundingBox();
>        if (box) {
>          const targetX = box.x + box.width / 2;
>          const targetY = box.y + box.height / 2;
>          // Chuột Neon lướt mượt mà từ vị trí cũ tới tâm nút trong 8-12 bước di chuyển
>          await page.mouse.move(targetX, targetY, { steps: options.steps || 10 });
>          if (options.pause) await page.waitForTimeout(options.pause);
>          else await page.waitForTimeout(150); // Dừng ngắm trực quan 150ms
>        }
>        await locator.click();
>      }
>      ```
>    * Nhờ đó, người quan sát trên màn hình thấy rõ con trỏ Neon lướt êm ái tới đúng nút cần bấm, dừng lại ngắm và click phát sáng gợn sóng!
>
> 4. **Gõ Phím Chậm Rãi Thời Gian Thực (`pressSequentially`)**:
>    * Thay vì dùng `locator.fill(text)` nạp dữ liệu trong 0 mili-giây, bắt buộc dùng:
>      ```javascript
>      await inputLocator.pressSequentially('Nội dung cần nhập', { delay: 40 });
>      ```
>    * Tốc độ `delay: 35-50ms` mô phỏng chính xác tốc độ gõ của một chuyên viên thật, kích hoạt sự kiện `keydown/keyup`, đồng thời bong bóng `⌨️ Typing...` hiển thị từng ký tự lên màn hình.
>
> 5. **Triệt Tiêu Hoàn Toàn Độ Trễ Lệch Pha (Zero Latency Synchronization)**:
>    * Trong CSS của con trỏ chuột (`visual_cursor.js`), sử dụng:
>      ```css
>      #__ag_cursor__ {
>        transition: none !important;
>        will-change: transform;
>      }
>      ```
>    * Điều này đảm bảo tọa độ của con trỏ chuột Neon bám sát 100% thời gian thực theo tọa độ sự kiện `mousemove` của Playwright, không bị hiện tượng "chuột click xong thì hình con trỏ mới lết tới nơi".
>
> 6. **Nguyên Tắc Cuộn Khung Nhìn Thông Minh (Smart Viewport Scroll - Chỉ Cuộn Khi Bị Khuất)**:
>    * **Quy chuẩn cốt lõi**: CHỈ thực hiện cuộn trang (`smoothScroll`) khi phần tử/vùng cần để ý (khoanh vùng) nằm ở dưới hoặc bị che khuất khỏi khung nhìn (`rect.bottom > window.innerHeight - 40 || rect.top < 60 || rect.right < 0 || rect.left > window.innerWidth`).
>    * **Cấm cuộn thừa thãi**: Nếu phần tử ĐÃ nằm trọn vẹn trong khung nhìn (viewport visible), TUYỆT ĐỐI KHÔNG cuộn trang. Việc cuộn liên tục khi phần tử đã nhìn thấy sẽ gây giật màn hình, rung lắc khó chịu và làm mất phương hướng của người xem.
>    * **Thực thi chuẩn**:
>      ```javascript
>      const isObscured = await locator.evaluate(el => {
>        const rect = el.getBoundingClientRect();
>        const vh = window.innerHeight || document.documentElement.clientHeight;
>        const vw = window.innerWidth || document.documentElement.clientWidth;
>        return (rect.bottom > (vh - 40) || rect.top < 60 || rect.right < 0 || rect.left > vw);
>      }).catch(() => false);
>
>      if (isObscured) {
>        await smoothScroll(page, locator, { block: 'center' });
>        await page.waitForTimeout(400);
>      }
>      ```
>
> 7. **Nguyên Tắc Chống Khoanh Vùng Giả / Ảo (Zero Fake Highlighting & Text Verification)**:
>    * **Cấm khoanh vùng bừa bãi**: Tuyệt đối KHÔNG dùng locator chung chung (ví dụ: lấy dòng đầu tiên `tr.dx-data-row:first` của DataGrid) khi dữ liệu thực tế của đối tượng chưa xuất hiện hoặc chưa được nạp.
>    * **Bắt buộc đối soát nội dung văn bản (Strict Text Verification)**: Trước khi vẽ khung khoanh vùng và bật Huy hiệu Badge chỉ thị (`highlightAndPause`), BẮT BUỘC phải đối soát nội dung văn bản (`innerText` / `textContent`) của dòng hoặc ô dữ liệu:
>      - Phải chứa đúng Mã đối tượng (ví dụ: `099`) hoặc Tên đối tượng chỉ định (ví dụ: `Nguyễn Văn Test`, `Nguyễn Minh Khang`).
>      - Tuyệt đối nghiêm cấm trường hợp trong kịch bản bảo khoanh "Nguyễn Văn Test" hay "Nguyễn Minh Khang" nhưng trên giao diện lại khoanh vào dòng "Lê Minh Trí" hay "Lê Thị Cà"!
>    * **Xử lý tiền đề đúng đắn**: Nếu đối tượng chưa hiển thị trên lưới do bộ lọc hoặc danh sách đang ở nhân viên mặc định khác: Phải dùng thao tác tìm kiếm / chọn đúng nhân viên đó trên thanh công cụ Toolbar trước, kiểm tra dòng xuất hiện đúng rồi mới tiến hành khoanh vùng.
>
> 8. **Nguyên Tắc 100% Thao Tác Trực Quan Qua Chuột & Bàn Phím (Real Visual Mouse & Keyboard Only)**:
>    * **Quy chuẩn bất biến**: Mọi tương tác trên giao diện (chuyển tab trên Top Tab Bar, mở menu trên Sidebar, tìm kiếm, bấm nút, chọn dropdown) đều phải xuất phát từ thao tác CHUỘT (`moveAndClick`) hoặc BÀN PHÍM (`pressSequentially`) trực quan của người dùng.
>    * **Tuyệt đối cấm can thiệp ngầm (No Silent Script Trigger)**: Nghiêm cấm việc gọi hàm JavaScript ngầm trong DOM (`page.evaluate(() => window.OpenAppInSidebar(...))`, `element.click()` âm thầm) làm cho menu hay tab "đùng một phát bung ra" mà người xem không thấy bất kỳ chuyển động chuột hay phím gõ nào.
>    * **Kịch bản điều hướng chuẩn mực**:
>      - **Khi chuyển tab đã mở**: Di chuyển con trỏ chuột Neon mượt mà tới đúng tab trên thanh tab (`#dynamic-tab-..., .nav-tabs button:has-text(...)`), dừng ngắm 150ms và nhấp chuột phát hiệu ứng sóng gợn để kích hoạt tab.
>      - **Khi mở menu mới trên Sidebar**:
>        1. Di chuyển chuột Neon tới ô tìm kiếm menu trên Sidebar (`#txtSearchApp` hoặc `.sidebar input[type="text"]`).
>        2. Nhấp chuột vào ô tìm kiếm, xóa trắng ô (Ctrl+A -> Backspace).
>        3. Gõ từ khóa tên menu bằng `pressSequentially('Tên Menu', { delay: 90-160 })` để hiển thị bong bóng gõ phím `⌨️ Typing...`.
>        4. Chờ Sidebar lọc ra kết quả, di chuyển chuột Neon tới đúng mục menu vừa được lọc và nhấp chuột mở chức năng.
>
> 9. **Nguyên Tắc Chống Dữ Liệu Ma & Lưu Ngầm (Zero Ghost Data & Strict Pre-Submit Verification)**:
>    * **Cấm tuyệt đối gọi API / Stored Procedure trực tiếp từ trình duyệt**: Nghiêm cấm sử dụng `window.AjaxHPAParadiseAsync(...)`, `fetch()`, `$.ajax()` hoặc bất kỳ hàm JS nội bộ nào trong `page.evaluate()` để tạo/sửa/xóa dữ liệu thay cho thao tác trên UI. Nếu nút Lưu hoặc Form không xuất hiện, Test Case bắt buộc phải báo **FAIL** để phát hiện lỗi giao diện, tuyệt đối không được viết nhánh `else` gọi API ngầm để "cứu" Test Case PASS giả tạo!
>    * **Cấm gán dữ liệu vào biến Instance ngầm của Framework**: Nghiêm cấm dùng `window[k].option('value', ...)` hay `$(...).dxTextBox('instance').option('value', ...)` hoặc `element.value = ...` để bơm dữ liệu vào form mà bỏ qua thao tác chuột và bàn phím.
>    * **Quy trình 3 bước bắt buộc khi điền bất kỳ trường nào trên Modal / Form**:
>      1. **Click mở focus**: Dùng `moveAndClick(page, inputLocator)` để chuột Neon bay tới đúng ô input và click mở con trỏ nhấp nháy.
>      2. **Gõ phím từng chữ**: Dùng `typeHumanLike(page, inputLocator, text)` (qua `pressSequentially`) để kích hoạt bong bóng `⌨️ Typing...` và chữ hiện ra từ từ trên màn hình.
>      3. **Chốt chặn kiểm tra hiển thị trước khi bấm Submit (Pre-Submit Visual Gate)**: Trước khi di chuột tới nút `Lưu / Gửi đơn / Đăng ký`, bắt buộc phải kiểm tra giá trị thực tế đang hiển thị bằng mắt thường trên các ô input qua `fillAndVerifyHumanLike`. Nếu ô input trên màn hình vẫn đang trống (`""`), kịch bản phải dừng lại ngay lập tức, tuyệt đối không được bấm Submit!
>
> 10. **Luật Gõ Phím Từng Ký Tự — Cấm Tuyệt Đối Copy-Paste (`Zero-Fill / Character-by-Character Typing Law`)**:
>     * **Cấm tuyệt đối lệnh `.fill()` và gán `.value`**: Nghiêm cấm sử dụng `locator.fill(text)`, `page.fill()`, `keyboard.insertText()` hoặc `el.value = text` để đưa dữ liệu vào ô input (vì các lệnh này đẩy toàn bộ chuỗi vào ô cùng lúc như Copy-Paste trong 0ms).
>     * **Cách duy nhất được phép xóa ô input**: Phải click vào ô, bấm tổ hợp phím `Control+A` rồi bấm `Backspace` như người thật.
>     * **Bắt buộc gõ từng chữ cái**: Mọi ký tự đưa vào ô input (kể cả ô tìm kiếm trên Sidebar, ô lọc DataGrid, ô ngày tháng, số tiền, ghi chú) BẮT BUỘC phải gõ tuần tự từng chữ một qua `pressSequentially(char, { delay: randomBetween(90, 160) })` để mắt người nhìn thấy từng chữ cái nhảy ra kèm bong bóng `⌨️` và con trỏ nhấp nháy dịch chuyển.
>
> 11. **Luật Khoanh Vùng Đúng Dòng Trọng Tâm & Dừng 5 Giây Quan Sát (`Strict Target-Row Highlight & Mandatory 5s Pause`)**:
>     * **Khi nào bắt buộc phải khoanh vùng + dừng 5 giây (`5000ms`)?**:
>       1. Ngay sau khi vừa điền xong toàn bộ các trường trên một Form/Modal (trước khi bấm Lưu/Gửi đơn): Khoanh vùng form vừa điền để người xem kiểm tra các chữ vừa gõ.
>       2. Ngay sau khi mở bất kỳ bảng dữ liệu (`DataGrid` / `Table` / Danh sách thẻ) có nhiều dòng: Bắt buộc phải lọc/tìm đến đúng dòng của đối tượng đang test, khoanh vùng **ĐÚNG DÒNG ĐÓ (`tr.dx-data-row` hoặc `.card`)** và dừng đúng **5,000ms (5 giây)**.
>       3. Ngay sau khi thực hiện xong thao tác Thêm / Sửa / Duyệt / Tính lương: Quay lại bảng danh sách, khoanh vùng đúng dòng kết quả vừa biến đổi và dừng **5,000ms (5 giây)**.
>     * **4 Cấm Kỵ Tuyệt Đối để Chống Khoanh Vùng Giả (Anti-Fake Highlighting Rules)**:
>       - ❌ **Cấm khoanh cả bảng lớn**: Tuyệt đối không đưa `.dx-datagrid`, `table`, `tbody`, `#appapp` vào locator của hàm `highlightAndPause`. Chỉ được phép khoanh vùng thẻ dòng (`tr.dx-data-row`, `tbody tr`, `.getcardregisteredOA`) hoặc ô dữ liệu cụ thể (`td`).
>       - ❌ **Cấm dùng `tr.first()` mù quáng**: Tuyệt đối không lấy dòng đầu tiên (`tr.dx-data-row >> nth=0`) nếu không có bộ lọc `:has-text("...")` chứa Mã định danh duy nhất (ví dụ: Mã NV `099`, Họ tên `Nguyễn Minh Khang`, hoặc Mã Token vừa tạo).
>       - ❌ **Cấm bỏ qua khi không khớp text**: Trong hàm `highlightAndPause`, tham số `expectedText` là **BẮT BUỘC**. Nếu nội dung dòng định khoanh không chứa đầy đủ `expectedText`, hàm bắt buộc phải **`throw new Error(...)` làm FAIL test case ngay lập tức**, tuyệt đối không được `return false` hay `catch(() => {})` để lờ đi!
>       - ❌ **Cấm khoanh dòng khi có nhiều dòng trùng**: Nếu locator chưa lọc kỹ, phải truyền mảng `expectedText: ['099', '10,000,000']` để đảm bảo dòng được khoanh chứa đồng thời cả Mã nhân viên lẫn Giá trị nghiệp vụ cần đối soát.
>
> 12. **Luật Cuộn Mượt Mà Từ Từ (Human-like Smooth Scroll)**:
>     * **Cấm cuộn nhảy cóc tức thì**: Nghiêm cấm dùng `el.scrollIntoView({ behavior: 'auto' })` hay `window.scrollTo(0, 500)` làm màn hình giật cục lập tức.
>     * **Bắt buộc cuộn mượt (Smooth Scroll)**: Mọi thao tác cuộn bảng (`DataGrid`), cuộn trang, cuộn popup đều phải sử dụng `behavior: 'smooth'`, kết hợp nhịp dừng `600ms - 900ms` để mắt người kịp bắt nhịp định vị nội dung vừa xuất hiện trên khung nhìn (`smoothScrollHumanLike`).
>
> 13. **Luật Chuyển Trang & Phân Trang Trực Quan (Real Mouse Pagination)**:
>     * **Cấm đổi trang ngầm qua API / Code**: Nghiêm cấm gọi `grid.navigateToPage(2)` hay hàm JS bên trong `page.evaluate()` để lật trang.
>     * **Bắt buộc di chuột click nút phân trang (`navigateToPageHumanLike`)**: 
>       1. Cuộn mượt màn hình xuống khu vực thanh phân trang (`.dx-datagrid-pager` hoặc `.pagination`).
>       2. Di chuyển con trỏ chuột Neon từ từ tới nút số trang mục tiêu (ví dụ: Trang `2`) hoặc nút Next (`>`).
>       3. Dừng ngắm 200ms - 300ms rồi click chuột, sau đó chờ `1000ms - 1500ms` cho bảng render xong dữ liệu của trang mới.
>
> 14. **Luật Cấm Can Thiệp Ngầm Vào Control Phức Tạp: SelectBox, Combobox, Lookup, DatePicker, NumberBox (`Zero Component-API Manipulation Law`)**:
>     * **5 Cú Pháp Bị CẤM TUYỆT ĐỐI trong mọi file `.spec.js`**:
>       1. ❌ **Cấm gọi DevExtreme Instance API**: Cấm dùng `.dxSelectBox('instance').option('value', ...)`, `.dxDateBox('instance')`, `.dxNumberBox('instance')`, `.dxLookup('instance')`, `.dxDropDownBox('instance')` hoặc quét `for (let k in window) if (k.startsWith('Instance')) window[k].option(...)`.
>       2. ❌ **Cấm thao túng thẻ `<select>` ngầm**: Cấm dùng `selectElement.value = ...`, `selectElement.selectedIndex = ...` hoặc `locator.selectOption()` mà không mở danh sách trực quan.
>       3. ❌ **Cấm giả lập sự kiện DOM**: Cấm dùng `el.dispatchEvent(new Event('change'))`, `el.dispatchEvent(new Event('input'))` trong `page.evaluate()`.
>       4. ❌ **Cấm vẽ chữ giả lên Control**: Cấm tuyệt đối việc gán `el.innerHTML = ...` hoặc `el.innerText = ...` để làm giả giao diện đã chọn nhân viên/dữ liệu.
>       5. ❌ **Cấm gán thẳng chuỗi ngày vào DatePicker**: Cấm dùng `dateInput.value = '2026-10-15'` hoặc `dateInput.fill('2026-10-15')`.
>     * **Quy trình Vật Lý Bắt Buộc khi tương tác với từng loại Control trên Modal / Toolbar**:
>       - **Đối với SelectBox / Combobox / Lookup (`selectDropdownHumanLike` / `selectBoxHumanLike`)**:
>         1. **Di chuột & Click mở**: Dùng `moveAndClick` đưa chuột Neon tới đúng khung SelectBox (hoặc nút mũi tên `.dx-dropdowneditor-button`) và click để mở danh sách.
>         2. **Chờ danh sách xổ xuống**: Dừng `400ms - 600ms` để mắt người nhìn thấy popup danh sách (`.dx-overlay-content .dx-list-item`, `.dx-datagrid-rowsview`, hoặc menu dropdown) hiện ra trên màn hình.
>         3. **Tìm & Click chọn dòng mục tiêu**: Nếu có ô tìm kiếm trong popup Lookup, dùng `typeHumanLike` gõ từng chữ để lọc. Sau đó dùng `moveAndClick` rê chuột Neon xuống đúng dòng item trong danh sách đang xổ ra và click chọn!
>       - **Đối với DatePicker / Ô Ngày Tháng & Giờ (`fillDateHumanLike`)**:
>         * **Phân biệt rõ 2 loại Control Ngày/Giờ trong hệ thống**:
>           1. **Loại 1: Thẻ HTML5 thuần `<input type="date">` hoặc `<input type="time">`** (như `#AttDate`, `#TimeInOut` trên màn hình Xin bù công `MnuHRS033`):
>              - *Lưu ý cốt lõi*: Trình duyệt Chromium/Google Chrome bảo vệ thẻ `type="date"` bằng Shadow DOM (`::-webkit-datetime-edit`) với 3 slot phân biệt `[mm]/[dd]/[yyyy]`. Thẻ này **từ chối nhận chuỗi ký tự tự do** (như dấu gạch chéo `/` hoặc `pressSequentially('15/10/2026')`), nếu cố gõ sẽ bị nuốt ký tự dẫn đến hiển thị lỗi `mm/dd/0006` và rỗng dữ liệu!
>              - *Quy chuẩn thực thi*: Dùng `moveAndClick` đưa chuột Neon vào ô input $\rightarrow$ Dùng chuẩn W3C ISO `YYYY-MM-DD` (hoặc `HH:mm`) qua `input.fill(isoDate)` $\rightarrow$ Kích hoạt sự kiện `dispatchEvent('input')` và `dispatchEvent('change')` để form cập nhật trạng thái hợp lệ.
>           2. **Loại 2: DevExtreme dxDateBox / Masked Input (`.dx-datebox`, `.dxDateBox`, `input.dx-texteditor-input`)** (như màn hình Xin nghỉ phép `MnuWPT315`, Xin tăng ca `MnuWPT316`):
>              - *Lưu ý cốt lõi*: DevExtreme sử dụng mặt nạ cố định (`useMaskBehavior: true`, định dạng `dd/MM/yyyy HH:mm` hoặc `dd/MM/yyyy`). Các ký tự phân cách như `/`, `:`, khoảng trắng ` ` là ký tự mặt nạ nội bộ. Nếu gõ chuỗi chứa `/` hoặc gọi `locator.pressSequentially()` lặp đi lặp lại từng ký tự, Playwright sẽ re-focus/re-click vào input liên tục làm con trỏ nhảy sai vị trí và mặt nạ từ chối nhận!
>              - *Quy chuẩn thực thi*:
>                + Nếu có nút Clear (`.dx-clear-button-area`), di chuột Neon `moveAndClick` bấm nút Clear để reset sạch sẽ về rỗng.
>                + Di chuột Neon `moveAndClick` vào ô text input (`input.dx-texteditor-input`), nhấn `Control+A` $\rightarrow$ `Backspace`.
>                + Trích xuất chuỗi chữ số thuần túy (Raw Digits: `dateString.replace(/\D/g, '')`, ví dụ `'241020260800'` hoặc `'20102026'`).
>                + Dùng `page.keyboard.type(rawDigits, { delay: 90-150 })` gõ tuần tự như người thật. Mặt nạ DevExtreme sẽ tự động đặt các dấu `/` và `:` vào đúng chỗ!
>                + Bấm phím `Enter` (hoặc click ra ngoài) để đóng popup lịch và xác nhận giá trị vào Instance (TUYỆT ĐỐI KHÔNG dùng phím `Tab` làm con trỏ nhấp nháy nhảy cóc sang ô tiếp theo).
>       - **Đối với NumberBox / Tiền lương (`typeHumanLike` / `fillNumberHumanLike`)**:
>         1. Dùng `moveAndClick` rê chuột Neon vào thẳng thẻ `input.dx-texteditor-input` bên trong NumberBox.
>         2. Xóa số cũ bằng `Control+A` + `Backspace` và gõ từng chữ số (ví dụ `'10000000'`) bằng `pressSequentially`.
>
> 15. **BỘ 7 LUẬT THÉP BẮT BUỘC ĐỂ 100% NHƯ NGƯỜI THẬT (ZERO BOT SHORTCUTS)**:
>     * **Luật 1: CẤM TUYỆT ĐỐI các hàm tương tác ngầm của Playwright (Zero Native Action Rule)**:
>       - ❌ Cấm: `locator.click()`, `locator.click({ force: true })`, `locator.dblclick()` $\rightarrow$ Bắt buộc thay bằng: `await moveAndClick(page, locator)`.
>       - ❌ Cấm: `locator.fill('...')` (trừ khi dùng để xóa trắng ô trong `typeHumanLike`) $\rightarrow$ Bắt buộc thay bằng: `await typeHumanLike(page, locator, '...')`.
>       - ❌ Cấm: `locator.check()`, `locator.uncheck()` $\rightarrow$ Bắt buộc thay bằng: `await moveAndClick(page, locator)`.
>       - ❌ Cấm: `document.querySelector(...).click()` bên trong `page.evaluate()`.
>     * **Luật 2: CẤM dùng `page.evaluate()` để mở Menu, mở Modal hoặc Submit Form (No Silent JS Trigger)**:
>       - ❌ Cấm tuyệt đối việc gọi `window.OpenAppInSidebar()`, `window.addNewTab()`, `window.openFormParam()`, `window.AjaxHPAParadiseAsync()` để mở màn hình hoặc lưu dữ liệu.
>       - ✅ Bắt buộc: Muốn mở Menu $\rightarrow$ Chuột phải di chuyển lên Top Tab Bar (nếu tab đã mở) hoặc di chuyển vào ô Tìm kiếm của Sidebar, gõ tên menu từng chữ, chờ danh sách lọc hiện ra rồi di chuột xuống bấm vào dòng menu đó (`openMenuHumanLike`). Muốn mở Modal Thêm mới $\rightarrow$ Chuột phải lướt tới đúng nút `+ Thêm` trên giao diện và click.
>     * **Luật 3: CẤM bơm dữ liệu hàng loạt vào Form qua DOM / DevExtreme Instance (No Instant Form Injection)**:
>       - ❌ Cấm dùng vòng lặp `for (let k in window) Instance...option('value', ...)` hay `document.getElementById('...').value = ...` để điền form trong 0ms.
>       - ✅ Bắt buộc: Dùng `fillAndVerifyHumanLike` cho Text/Number/Date và `selectDropdownHumanLike` cho dropdown theo đúng 3 nhịp: Di chuột click mở hộp chọn $\rightarrow$ Chờ danh sách xổ xuống (300ms) $\rightarrow$ Di chuột tới dòng dữ liệu mục tiêu và click chọn.
>     * **Luật 4: Thống nhất 100% một bộ Helper điều hướng duy nhất (Single Source of Truth Helpers)**:
>       - Xóa bỏ toàn bộ các hàm phân mảnh riêng lẻ (`openAppFix5`, `openAppFix7`, `confirmPopupFix5`...). Tất cả các Test Case từ TC-01 đến TC-20 phải gọi chung 1 hàm mở menu trực quan (`openMenuHumanLike`) và 1 hàm xác nhận popup trực quan (`confirmPopupHumanLike`).
>     * **Luật 5: Khóa chặn `moveAndClick` — Chưa tới nơi thì KHÔNG ĐƯỢC CLICK**:
>       - Tuyệt đối không dùng `else { await locator.click(); }` làm đường lui. Phải ép phần tử hiển thị (`waitFor({ state: 'visible' })`), lấy bằng được `boundingBox()`, di chuyển chuột từng bước tới tọa độ đó rồi mới phát lệnh `mouse.down()` / `mouse.up()`. Nếu không lấy được tọa độ $\rightarrow$ `throw new Error(...)` ngay!
>     * **Luật 6: Nhịp thở thị giác giữa các bước chuyển cảnh (Human Cognitive Pause)**:
>       - Sau khi mở Menu / chuyển Tab: Dừng `600ms – 1000ms` để giao diện render xong.
>       - Sau khi Modal / Popup bật lên: Dừng `400ms – 700ms` (nhịp mắt người quét form) rồi mới bắt đầu di chuột vào ô đầu tiên.
>       - Trước khi bấm nút Chốt / Lưu / Duyệt quan trọng: Tăng thời gian dừng ngắm (pause) lên `300ms – 500ms`.
>     * **Luật 7: CẤM DÙNG PHÍM TAB CHUYỂN Ô LÀM CON TRỎ NHÁY ĐI TRƯỚC CHUỘT NEON (Anti-Tab Focus Desynchronization Rule)**:
>       - ❌ **Cấm tuyệt đối**: Lệnh `page.keyboard.press('Tab')` sau khi gõ xong một ô input để nhảy sang ô tiếp theo.
>       - ❌ **Nguyên nhân cấm**: Phím `Tab` của Chromium chuyển focus trong **0ms**, khiến vạch nhấp nháy soạn thảo (`caret |`) xuất hiện ngay lập tức tại ô kế tiếp trước khi chuột Neon kịp di chuyển tới, gây lộ dấu vết bot và phá vỡ tính tự nhiên.
>       - **Quy chuẩn bất biến**: Trên mọi Form / Modal / Toolbar, con trỏ nhấp nháy soạn thảo (`caret |`) **CHỈ ĐƯỢC PHÉP** xuất hiện SAU KHI con trỏ chuột Neon đã bay tới đúng vị trí ô input và phát lệnh `click` mở focus thành công.
>       - ✅ **Bắt buộc**: Mọi thao tác chuyển trường (Form traversal giữa ô input, datepicker, selectbox) phải do **chuột Neon tự động lướt tới ô tiếp theo và click** (`moveAndClick` / `typeHumanLike`) để mở focus tự nhiên (trình duyệt tự kích hoạt `blur` ô cũ $\rightarrow$ `focus` ô mới y hệt người thật).
>
> 16. **Luật 16: KHÓA CHẶN ĐỒNG BỘ TAB ACTIVE & CHU TRÌNH PHÊ DUYỆT ĐƠN 3 CHẶNG TRỰC QUAN (Strict Active Tab Confinement & Real Visual Approval Lifecycle Law)**:
>     * **Chuyển Tab Trực Quan Bắt Buộc (Mandatory Visual Tab Switch)**:
>       - Khi nhấp vào thẻ/mục để mở form chi tiết ở một tab mới trên Top Tab Bar (`#divTabDynamic` / `.nav-tabs`), con trỏ chuột Neon **BẮT BUỘC PHẢI DI CHUYỂN LÊN THANH TAB ĐỂ CLICK KÍCH HOẠT TAB CHI TIẾT ĐÓ**, đảm bảo giao diện form chuyển sang active và hiển thị trọn vẹn 100% trên màn hình trước khi thao tác tiếp. Tuyệt đối cấm thao tác trên form khi tab chi tiết đang nằm ở chế độ ẩn ngầm (`display: none`).
>     * **Triệt Tiêu 100% Fallback Trigger Ngầm (`page.evaluate`) — Chống Fake Pass**:
>       - Tuyệt đối nghiêm cấm việc dùng `page.evaluate(() => ApproveRequest(...))` để gọi hàm backend ngầm khi selector UI chưa tìm thấy. Mọi thao tác duyệt đơn **BẮT BUỘC PHẢI ĐI QUA CON TRỎ CHUỘT NEON CLICK VÀO NÚT THẬT TRÊN FORM VÀ NÚT THẬT TRONG MODAL**. Việc gọi hàm ngầm làm popup "Thành công" hiện lên trong khi trên màn hình người dùng không hề thấy thao tác duyệt nào và tab chi tiết chưa mở là hành vi vi phạm nghiêm trọng (Fake Pass).
>     * **Chu Trình Phê Duyệt Đơn 3 Chặng Trực Quan Bất Biến**:
>       - **Chặng 1 (Form Chi Tiết)**: Chuột Neon chuyển sang tab chi tiết $\rightarrow$ Cuộn màn hình xuống nút "Duyệt" màu xanh (`.btnApprove`) $\rightarrow$ Khoanh vùng 2s $\rightarrow$ Bấm nút "Duyệt".
>       - **Chặng 2 (Modal Xác Nhận)**: Modal popup xác nhận bật lên giữa màn hình $\rightarrow$ Chuột Neon bay vào Modal $\rightarrow$ Khoanh vùng nút xác nhận 2s $\rightarrow$ Bấm nút xác nhận trong Modal $\rightarrow$ Chờ modal đóng và AJAX hoàn tất.
>       - **Chặng 3 (Đồng Bộ & Đối Soát Giao Diện)**: Chuột Neon quay lại tab Danh sách phê duyệt $\rightarrow$ Bấm nút Làm mới dữ liệu (`#reloadData`) $\rightarrow$ **Khoanh vùng kiểm chứng trực quan thẻ đơn ĐÃ BIẾN MẤT HOÀN TOÀN khỏi danh sách Chờ duyệt**!
>
> 17. **Luật 17: ĐỊNH VỊ ĐỘNG 3 CHIỀU THEO GIAO ĐIỂM CỘT, DẤU VÂN TAY & TỰ ĐỘNG CUỘN TÌM DÒNG (3D Dynamic Target & Auto-Scroll Resolution Law)**:
>     * **3 Cấm Kỵ Tuyệt Đối về Tọa Độ & Vị Trí Cố Định**:
>       1. ❌ **Cấm gán cứng số Pixel / Offset mù quáng**: Nghiêm cấm viết `page.mouse.move(500, 300)`, `box.x + 80, box.y + 120`, hay ép cố định `box.x + Math.min(box.width * 0.25, 120)` lên cả thẻ dòng `<tr>` dài (khiến chuột chỉ vào khoảng trắng hoặc cột không liên quan).
>       2. ❌ **Cấm bám `.first()` / `nth(0)` / `tr:first-child` mù quáng**: Khi có dữ liệu tạo tay chèn lên đầu danh sách hoặc dữ liệu cũ tồn đọng, `.first()` sẽ click nhầm sang bản ghi không phải của kịch bản!
>       3. ❌ **Cấm click/khoanh mù trên bảng có Virtual Scroll / danh sách dài mà không cuộn tìm**: Dòng của kịch bản có thể bị đẩy xuống đáy danh sách hoặc chưa render trong DOM nếu chưa cuộn tới.
>     * **Quy Chuẩn Định Vị Động 3 Chiều Bất Biến (`Row Fingerprint` $\cap$ `Progressive Auto-Scroll` $\cap$ `Cell/Action Scope`)**:
>       1. **Chiều 1 — Định danh dòng đa điều kiện & Dấu vân tay (`Row Fingerprint`)**: Ghép liên hoàn `.filter({ hasText: ... })` theo nhiều cột định danh đồng thời (ví dụ: Mã NV `'099'` + Ngày `'15/10'`/`'20/10'`/`'24/10'` + Số tiền/Chỉ tiêu + dấu vân tay `[TEST_LUONG]` / `[ID:${runToken}]` khi UI có hiển thị). Trước khi chọn phần tử phải kiểm tra `.count()`, không bao giờ gọi `.first()` từ bộ lọc lỏng lẻo.
>       2. **Chiều 2 — Tự động cuộn tìm từng nấc (`Progressive Auto-Scroll` qua `mouse.wheel`)**: Khi dòng mục tiêu chưa xuất hiện trong khung nhìn (`resolveDynamicTarget`), đưa chuột vào vùng cuộn (`.dx-scrollable-container`, `#scrollView`, `#cardregistered`) và lăn `page.mouse.wheel(0, stepPx)` từng nấc cho tới khi tìm thấy đúng dòng — tích hợp **chốt dừng sớm khi chạm đáy (`scrollTop + clientHeight >= scrollHeight - 2`)** và `throw new Error(...)` rõ ràng nếu duyệt hết danh sách vẫn không thấy.
>       3. **Chiều 3 — Thu hẹp tới đúng Ô (`td:visible`) hoặc Nút (`button:visible`) bên trong dòng rồi mới lấy `boundingBox()`**: Không lấy tọa độ cả `<tr>` để click/trỏ chuột! Phải thu hẹp từ dòng đã khớp vào đúng `td:visible:has-text(...)` hoặc nút/checkbox bên trong dòng đó (`findRowByColumns`, `moveAndClickGridTarget`, `highlightAndClickDynamicTarget`, `selectAndApproveExactScriptCard`), gọi `scrollIntoViewIfNeeded()`, rồi mới tính `boundingBox()` thời gian thực ngay tại thời điểm di chuột Neon!


---

1. **Hiển thị trực quan 100% trên Google Chrome thật (`channel: 'chrome'`, `headless: false`)**:
   - Tuyệt đối không chạy headless khi người dùng yêu cầu test quan sát.
   - Thao tác gõ phím mượt mà, quan sát rõ: dùng `locator.pressSequentially('text', { delay: 35-50 })`.
   - Sử dụng helper `moveAndClick(page, locator, { steps: 8-12 })` để chuột lướt trực quan vào giữa phần tử trước khi bấm.
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
  3. *Logic Dữ Liệu*: Mọi dòng trên bảng phải mang đúng nhãn trạng thái $A$. Vòng lặp khôi phục: Click lại chip "Tất cả" lần 2 $\rightarrow$ Assert số dòng phục hồi $N_{restore} == N_0$.

#### 8. Ô Tìm Kiếm Nhanh (Search Box / Instant Filter)
* **Thao tác chuẩn**:
  - Trích xuất từ khóa động từ 1 dòng thực tế đang có trên bảng $\rightarrow$ Gõ vào ô search bằng `pressSequentially`.
* **Thẩm định 3 lớp**:
  1. *Instant Filter*: Đợi debounce 300-500ms $\rightarrow$ Mọi dòng hiển thị trên DataGrid bắt buộc phải chứa từ khóa tìm kiếm.
  2. *Trường hợp không tìm thấy*: Gõ một chuỗi ngẫu nhiên không tồn tại $\rightarrow$ Assert bảng hiển thị giao diện rỗng: *"Không có dữ liệu"*.
  3. *Phục hồi khi xóa search*: Xóa sạch ô tìm kiếm $\rightarrow$ Assert bảng tự động nạp lại đầy đủ danh sách ban đầu.

#### 9. Bộ Phân Trang (Pagination: Next, Prev, Page Size, Jump)
* **Thẩm định 3 lớp**:
  1. *UI*: Nút Trang 2 chuyển sang active, nút "Previous" được enable.
  2. *Network*: Bắt API phân trang $\rightarrow$ Assert tham số `pageIndex=2` (hoặc `skip=20, take=20`).
  3. *Dữ liệu*: Dòng đầu tiên của Trang 2 PHẢI KHÁC dòng đầu tiên của Trang 1.
  4. *Đổi Page Size*: Chọn đổi số dòng từ `20` lên `50` $\rightarrow$ Assert số dòng trên bảng tăng lên tương ứng.

#### 10. Sắp Xếp Cột & Lọc Đầu Cột (Column Sorting & Header Filter)
* **Thẩm định 3 lớp**:
  1. *UI*: Xuất hiện icon mũi tên sắp xếp tăng dần $\uparrow$ (click lần 1) hoặc giảm dần $\downarrow$ (click lần 2).
  2. *Network*: Bắt API query $\rightarrow$ Assert tham số `sortColumn` và `sortDirection` (`ASC`/`DESC`).
  3. *Logic*: So sánh giá trị dòng 1 và dòng 2 sau khi sắp xếp để đảm bảo đúng thứ tự chữ cái hoặc ngày tháng.

---

### NHÓM 3: BẢNG DỮ LIỆU & HIỂN THỊ (DATA DISPLAY CONTROLS)

#### 11. Bảng Dữ Liệu (DataGrid / Table)
* **Thẩm định 3 lớp**:
  1. *Đối chiếu API vs UI*: Bóc tách JSON payload từ API nạp bảng $\rightarrow$ So khớp `expect(uiRowCount).toBe(rawRows.length)`.
  2. *Empty State*: Khi backend trả mảng rỗng `[]` $\rightarrow$ Bảng phải hiện thông báo "Không có dữ liệu" rõ ràng, không bị crash vỡ bảng.
  3. *Double-click chi tiết*: Double click 1 dòng $\rightarrow$ Bắt API nạp chi tiết $\rightarrow$ Assert form chi tiết mở ra nạp đúng thông tin dòng đó.

#### 12. Thẻ Chỉ Số Tổng Hợp (Metric / KPI Counter Cards)
* **Thẩm định 3 lớp**:
  1. *UI*: Các thẻ chỉ số (Tổng số, Đang xử lý, Hoàn tất) có số lượng rõ ràng, không hiển thị `NaN`, `null`, `undefined`.
  2. *Toán học / Logic tổng hợp*: Tổng số trên thẻ KPI phải bằng tổng các thẻ trạng thái con cộng lại, hoặc khớp đúng `totalCount` trả về từ API backend.

---

### NHÓM 4: CÁC CONTROL HÀNH ĐỘNG (ACTION & BUTTON CONTROLS)

#### 13. Nút Hành Động Chính (Primary CTA: Lưu, Gửi, Duyệt, Tạo Mới)
* **Thao tác chuẩn**: Di chuyển chuột Neon tới đúng tọa độ nút $\rightarrow$ Dừng ngắm 150ms $\rightarrow$ Click.
* **Thẩm định 3 lớp**:
  1. *Chống click kép (Debounce)*: Click nút Lưu $\rightarrow$ Nút phải lập tức chuyển sang trạng thái disabled hoặc spinner xoay để chống người dùng bấm liên tiếp tạo bản ghi trùng lặp.
  2. *Network*: Bắt API POST/PUT $\rightarrow$ Assert HTTP 200, payload JSON trả về mã thành công.
  3. *Đọc lại (Read-back)*: Modal đóng $\rightarrow$ Toast thành công hiện lên $\rightarrow$ Bản ghi mới/vừa cập nhật phải lập tức xuất hiện trên DataGrid.

#### 14. Nút Hủy / Đóng (Cancel / Close / Dismiss)
* **Thẩm định 3 lớp**:
  1. *Form chưa sửa*: Bấm Hủy $\rightarrow$ Modal đóng ngay lập tức, không gây lỗi.
  2. *Form đã sửa dở dang (Dirty check)*: Nhập vài chữ vào form rồi bấm Hủy $\rightarrow$ Kiểm tra xem hệ thống có bật popup cảnh báo *"Dữ liệu chưa được lưu, bạn có chắc chắn muốn thoát?"* hay không.
  3. *Bảo toàn trạng thái*: Đóng modal xong $\rightarrow$ Danh sách DataGrid bên ngoài vẫn giữ nguyên vị trí phân trang và bộ lọc.

#### 15. Nút Hành Động Xóa / Hủy Bỏ (Delete / Inactivate Action)
* **Thẩm định 3 lớp**:
  1. *Bắt buộc có xác nhận*: Tuyệt đối không được xóa ngay khi vừa click icon xóa $\rightarrow$ Bắt buộc assert xuất hiện Popup/Confirm Dialog ("Bạn có chắc chắn muốn xóa bản ghi này?").
  2. *Hành động Hủy xóa*: Bấm "Hủy" trên popup $\rightarrow$ Bản ghi vẫn giữ nguyên trên bảng.
  3. *Hành động Đồng ý xóa*: Bấm "Xóa" $\rightarrow$ Bắt API Delete (HTTP 200) $\rightarrow$ Assert số dòng trên DataGrid giảm đi 1 và mã bản ghi đó biến mất hoàn toàn.

#### 16. Menu Thao Tác Từng Dòng (Context Menu / Row Kebab Menu 3 chấm)
* **Thẩm định 3 lớp**:
  1. *UI Position*: Menu ngữ cảnh bung ra đúng vị trí chuột, không bị tràn ra ngoài màn hình hoặc che khuất nút khác.
  2. *Phân quyền*: Các nút hành động (Sửa, Xóa, Phê duyệt) hiển thị đúng theo quyền hạn tài khoản.
  3. *Click ngoài*: Click chuột ra ngoài khoảng trống $\rightarrow$ Menu ngữ cảnh phải tự động đóng lại.

---

### NHÓM 5: KHUNG CHỨA & PHẢN HỒI (CONTAINERS & FEEDBACK CONTROLS)

#### 17. Cửa Sổ Bật Lên (Modal / Dialog / Drawer / Popup)
* **Thẩm định 3 lớp**:
  1. *Backdrop & Focus Trap*: Khi modal mở, thanh cuộn của trang chính phía sau phải bị khóa và phím `Tab` chỉ di chuyển bên trong modal.
  2. *Phím Escape*: Bấm phím `Escape` $\rightarrow$ Modal phải đóng lại an toàn.
  3. *Dọn dẹp DOM (Cleanup)*: Khi đóng modal $\rightarrow$ Các phần tử overlay trong DOM phải bị gỡ bỏ, không được để lại màn mờ vô hình chặn chuột.

#### 18. Tab Chuyển Đổi & Khung Thu Gọn (Tabs / Accordion / Panels)
* **Thẩm định 3 lớp**:
  1. *UI*: Tab được chọn đổi màu active, nội dung panel tương ứng hiển thị, panel cũ bị ẩn.
  2. *Bảo toàn dữ liệu dở dang (Tab State Persistence)*: Dữ liệu đã gõ ở Tab 1 không được bị xóa mất khi chuyển qua lại giữa các Tab.
  3. *Network Lazy Load*: Bắt API khi click tab, đảm bảo API chỉ gọi 1 lần và cache dữ liệu, không spam request mỗi lần click.

#### 19. Thông Báo Phản Hồi (Toast Message / Alert Banner)
* **Thẩm định 3 lớp**:
  1. *Đúng phân loại ngữ nghĩa*: Thành công (xanh lá), Lỗi (đỏ), Cảnh báo (vàng).
  2. *Nội dung thông báo rõ ràng*: Toast phải chứa thông điệp tiếng Việt có nghĩa, không được hiện `null`, `[object Object]` hay `Error: 500`.
  3. *Tự động biến mất*: Toast tự biến mất sau 3-5 giây.

---

## 2.2. KHO KỊCH BẢN BIÊN, TIÊU CỰC & BẪY LỖI NGHIỆP VỤ (EDGE CASES & TRAP REPOSITORY)

#### 🔸 `EDGE-FLT-01`: Bẫy Mất Dữ Liệu Khi Khôi Phục Trạng Thái (The Lost-Data Re-click Trap)
Ban đầu danh sách có $N$ bản ghi. Click chọn lọc 1 trạng thái con $\rightarrow$ Click lại "Tất cả" lần 2. Do frontend không khôi phục cờ `isViewAll = 1` $\rightarrow$ Danh sách bị xóa sạch trắng trơn! Bắt buộc assert số dòng phục hồi nguyên vẹn $N_{restore} == N_0$.

#### 🔸 `EDGE-FLT-02`: Bẫy Khoảng Ngày Mặc Định Ngầm (The Hidden Default Date Boundary Trap)
Hệ thống ngầm định lấy ngày theo "Tuần này" hoặc "Tháng này" mà không có thông báo cho người dùng, làm biến mất các dữ liệu lịch sử hợp lệ tạo từ các tháng trước. Bắt buộc kiểm tra tham số `@FromDate` gửi lên server.

#### 🔸 `EDGE-FLT-03`: Bẫy Ký Tự Đặc Biệt & SQL Injection Trong Ô Tìm Kiếm
Người dùng gõ các ký tự `'`, `"`, `\`, `%`, `_`, `--` khiến Stored Procedure văng lỗi cú pháp SQL hoặc giao diện bị crash. Assert bảng phải hiển thị Empty State an toàn, không văng Unhandled Exception.

#### 🔸 `EDGE-INP-01`: Bẫy Bấm Lưu Khi Form Trống Hoàn Toàn (Empty Form Submit)
Người dùng mở popup rồi bấm thẳng vào nút "Lưu" mà chưa nhập bất kỳ thông tin nào. Bắt buộc form không được đóng và phải hiển thị các viền đỏ / thông báo validation.

#### 🔸 `EDGE-INP-02`: Bẫy Click Đúp Nút Lưu Liên Tục (Double-Click / Rapid Fire Debounce)
Người dùng click đúp hoặc click liên tiếp 2-3 lần vào nút Lưu. Do frontend không disable nút $\rightarrow$ Sinh ra 2 bản ghi trùng lặp trong DB. Bắt buộc hệ thống chỉ phát ra tối đa 1 request lưu dữ liệu duy nhất!

#### 🔸 `EDGE-INP-03`: Bẫy Mất Dữ Liệu Khi Chuyển Tab Dở Dang (Tab Switch State Loss)
Người dùng nhập dữ liệu ở Tab 1, chuyển sang Tab 2 xem rồi quay lại Tab 1 $\rightarrow$ Các ô input ở Tab 1 bị xóa sạch. Bắt buộc giữ nguyên vẹn dữ liệu.

#### 🔸 `EDGE-GRD-01`: Bẫy Mã HTTP 200 Che Giấu Lỗi Backend (HTTP 200 Masking Trap)
Server luôn trả về HTTP 200 OK ngay cả khi SQL văng Exception hoặc trả về kết quả rỗng. Bắt buộc bóc tách sâu vào JSON Body kiểm tra `result`, không chỉ dừng ở `status === 200`.

---

## 2.3. BỘ NGUYÊN TẮC TEST LUỒNG NGHIỆP VỤ & ĐỒNG BỘ LIÊN MÀN HÌNH (RIPPLE EFFECT / CASCADE LAW)

Một hành động Tạo mới, Cập nhật, Xóa hoặc Phê duyệt tại Menu Nguồn luôn tạo ra một "làn sóng ảnh hưởng" tới các Màn hình Đích (Downstream Menus), Dashboard và các Vai trò khác.
Kịch bản test chỉ được coi là HOÀN TẤT khi đã điều hướng đến các màn hình liên quan để kiểm chứng:
1. **Mô hình 1 (Khởi tạo thực thể $\rightarrow$ Lan tỏa danh mục)**: Tạo mới NV/Khách hàng $\rightarrow$ Phải xuất hiện trong Dropdown của Hợp đồng/Bảng lương.
2. **Mô hình 2 (Phê duyệt đa vai trò)**: Nhân viên gửi đơn $\rightarrow$ Quản lý duyệt $\rightarrow$ Mở lại hồ sơ nhân viên kiểm chứng dữ liệu đã thật sự được cập nhật vào bảng chính thức.
3. **Mô hình 3 (Đồng bộ Dashboard KPI)**: Thay đổi trạng thái thực thể $\rightarrow$ Thẻ chỉ số tổng quan trên Dashboard phải nhảy số tức thì ($N \pm 1$).
4. **Mô hình 4 (Khóa ngoại chống xóa)**: Không cho phép xóa thực thể mẹ khi đã phát sinh chứng từ/giao dịch con.

---

## 3. Quy Trình Xử Lý Khi Viết Test Cho Một Trang/Menu

### Áp Dụng BỘ KHUNG MẪU CHUẨN (GOLDEN CODE BLUEPRINT)
Mọi file test bắt buộc phải có đầy đủ 4 khối sau:

```javascript
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const PAGE_NAME = '<tên_menu>';

// ============================================================================
// KHỐI 1: CÁC HELPER BẮT BUỘC (DI CHUỘT TRỰC QUAN & CHỤP ẢNH TỪNG BƯỚC)
// ============================================================================

// Di chuyển chuột Neon mượt mà, dừng ngắm và click theo tọa độ động thời gian thực (Khóa chặn: Chưa tới nơi cấm bấm)
async function moveAndClick(page, locator, options = {}) {
  const target = locator.first();
  await target.waitFor({ state: 'visible', timeout: options.timeout || 10000 });
  await target.scrollIntoViewIfNeeded().catch(() => {});
  const box = await target.boundingBox();
  if (!box) {
    throw new Error('❌ [moveAndClick]: Không lấy được boundingBox của phần tử để di chuột Neon!');
  }
  const x = box.x + box.width * (0.35 + Math.random() * 0.3);
  const y = box.y + box.height * (0.35 + Math.random() * 0.3);
  await page.mouse.move(x, y, { steps: options.steps || 12 });
  await page.waitForTimeout(options.pause || 220);
  await page.mouse.down();
  await page.waitForTimeout(80);
  await page.mouse.up();
}

// Tìm đúng dòng trên bảng theo nhiều điều kiện cột (Cấm .first() mù quáng)
function findRowByColumns(page, columnValues = {}, gridSelector = '.dx-datagrid, table') {
  let rowLocator = page.locator(`${gridSelector} tr.dx-data-row:visible, ${gridSelector} tbody tr:visible`);
  const values = Array.isArray(columnValues) ? columnValues : Object.values(columnValues);
  for (const val of values) {
    if (val !== undefined && val !== null && String(val).trim() !== '') {
      rowLocator = rowLocator.filter({ hasText: String(val).trim() });
    }
  }
  return rowLocator;
}

// Cuộn tìm động 3 chiều (Dấu vân tay + Cuộn từng nấc + Nhắm đúng ô/nút mục tiêu)
async function moveAndClickGridTarget(page, { matchColumns, targetSubSelector, gridSelector = '.dx-datagrid, table' }) {
  const matchedRows = findRowByColumns(page, matchColumns, gridSelector);
  const count = await matchedRows.count();
  if (count === 0) throw new Error(`❌ Không tìm thấy dòng khớp điều kiện: ${JSON.stringify(matchColumns)}`);
  const row = matchedRows.first();
  const clickTarget = targetSubSelector
    ? row.locator(targetSubSelector).first()
    : row.locator('td:visible').first();
  await moveAndClick(page, clickTarget);
  return row;
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
// KHỐI 2: CẤU HÌNH PHIÊN & CHUỘT PHÁT SÁNG NEON FULL MÀN HÌNH
// ============================================================================
test.use({
  storageState: { cookies: [], origins: [] },
  viewport: null // BẮT BUỘC null để khớp với toàn màn hình từ --start-maximized
});

test.describe('Kiểm thử Phân hệ/Trang: <Tên Tiếng Việt>', () => {
  test.beforeEach(async ({ context }) => {
    await context.clearCookies();
    // Tự động nhúng con trỏ chuột Neon phát sáng từ file visual_cursor.js
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
    await userInput.pressSequentially('<username>', { delay: 40 });
    const passInput = page.locator('input[type="password"]');
    await moveAndClick(page, passInput);
    await passInput.pressSequentially('<password>', { delay: 40 });
    await moveAndClick(page, page.locator('#submitLogin'));
    await page.locator('.dock, .navbar').first().waitFor({ state: 'visible', timeout: 25000 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 1,
      desc: 'Đăng nhập thành công và mở trang chủ'
    });

    // 📂 BƯỚC 2: Mở màn hình mục tiêu
    const menuBtn = page.locator('...').first();
    await moveAndClick(page, menuBtn);
    await page.waitForTimeout(1500);

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 2,
      desc: 'Mở màn hình mục tiêu cần thao tác'
    });

    // 📝 BƯỚC 3: Điền thông tin với gõ phím trực quan
    const inputField = page.locator('input.dx-texteditor-input').first();
    await moveAndClick(page, inputField);
    await inputField.pressSequentially('Dữ liệu thử nghiệm', { delay: 40 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 3,
      desc: 'Điền đầy đủ thông tin vào form'
    });

    // 🎯 BƯỚC 4: Chuột Neon di chuyển lên nút Lưu
    const actionBtn = page.locator('button:has-text("Lưu")').first();
    await moveAndClick(page, actionBtn, { steps: 10, pause: 300 });

    await captureStep(page, testInfo, {
      tcId: 'TC-01',
      step: 4,
      desc: 'Con trỏ chuột Neon di chuyển và bấm nút Lưu thay đổi'
    });

    // ✅ BƯỚC 5: Kết quả phản hồi
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

---

## 4. Hướng Dẫn Kỹ Thuật: Tạo File .BAT 1-Click Cho Từng Cấp Độ

### A. File `Run-This-TC.bat` (Đặt trong `test-evidence/<tên_trang>/<TC-0x>/`):
```bat
@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: <tên_trang> - <TC-0x>
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: <TC-0x> (<tên_trang>.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
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

### B. File `Run-This-Page.bat` (Đặt trong `test-evidence/<tên_trang>/`):
```bat
@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Trang <tên_trang>
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TOAN BO TRANG: <tên_trang>.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
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

## 7. Cơ Chế Tự Động Chạy Theo Hệ Thống Hiện Tại
Mỗi khi mở bất kỳ file `.bat` nào (`Run-This-TC.bat`, `Run-This-Page.bat`, `Run-ParadiseHR-Interactive.bat`):
* Mở trình duyệt Google Chrome thật Fullscreen (không viền đen) truy cập thẳng vào trang web mục tiêu.
* Chuột Neon phát sáng lướt êm ái trên màn hình, gõ phím hiện bong bóng ký tự thời gian thực.
* Quay video `.webm` mới ghi lại toàn bộ chuyển động.
* Chụp ảnh Screenshot mới lưu vết từng thao tác.
* Cập nhật Báo cáo `test-report.md` và `results.json` theo đúng chuẩn Dual Status.

---

## 8. Chuẩn Báo Cáo Kép (Dual Status) & Tự Động Suy Luận Expect
* **Trạng thái thực thi Test (Kỹ thuật)**: `✅ PASS` hoặc `❌ FAIL`.
* **Trạng thái Logic Nghiệp vụ**: `✅ PASS` hoặc `❌ FAIL`.
* **Tự động suy luận Expect**: Thông báo thành công, đóng modal, nạp dữ liệu lên lưới, badge đổi trạng thái mà không bắt buộc người dùng prompt chi tiết.

---

## 9. Tiêu Chuẩn Chụp Ảnh Step-by-Step (Visual Storyboard)
Mỗi test case ghi lại 5 mốc ảnh:
1. Đăng nhập thành công và mở trang.
2. Mở màn hình/modal thao tác.
3. Điền dữ liệu form.
4. Con trỏ chuột Neon di chuyển và bấm nút hành động chính.
5. Kết quả phản hồi từ hệ thống.

---

## 10. Tiêu Chuẩn Phân Tích Nguyên Nhân Thất Bại (Failure Analysis)
Bắt buộc có khối `> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)` với 5 thành tố:
1. Vấn đề / Mã lỗi
2. Kỳ vọng nghiệp vụ (Expected Output)
3. Thực tế hệ thống (Actual Output)
4. Nguyên nhân cốt lõi (Root Cause)
5. Đề xuất khắc phục (Recommendation)

---

## 11. KHUNG MẪU CHUẨN BÁO CÁO NGHIỆM THU MARKDOWN (GOLDEN REPORT BLUEPRINT)
Sinh tại `test-evidence/<tên_trang>/test-report.md`:
* Bảng đối chiếu kép ngay đầu báo cáo (Mã TC, Tiêu đề, Test Status, Logic Status, Đánh giá).
* Heading `##### 🔹 Bước X: <Tên bước>` kèm ảnh chụp rõ vị trí con trỏ chuột Neon.
* Link mở trực tiếp file `video.webm` và file `trace.zip` kèm cú pháp lệnh `npx playwright show-trace`.
