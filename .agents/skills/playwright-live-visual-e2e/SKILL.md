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





