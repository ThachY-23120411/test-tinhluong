# CẨM NANG TOÀN DIỆN: CẤU HÌNH, VẬN HÀNH & NGHIỆM THU PLAYWRIGHT LIVE VISUAL TESTING TRÊN WINDOWS
*(Tài liệu chuẩn hóa SOP - Standard Operating Procedure dành cho AI Agent và Automation QC trên máy PC mới)*

---

## MỤC LỤC
1. [Bản chất kỹ thuật: Vì sao trước đây cài Playwright rồi nhưng Agent không mở trình duyệt cho người dùng xem được?](#1-bản-chất-kỹ-thuật-vì-sao-trước-đây-cài-playwright-rồi-nhưng-agent-không-mở-trình-duyệt-cho-người-dùng-xem-được)
2. [Cài đặt những gì? (Prerequisites & Libraries)](#2-cài-đặt-những-gì-prerequisites--libraries)
3. [Cấu hình những gì? Bật/Tắt những gì? (playwright.config.js)](#3-cấu-hình-những-gì-bậttắt-những-gì-playwrightconfigjs)
4. [Cấu trúc tổ chức thư mục kiểm thử chuẩn (Test Architecture)](#4-cấu-trúc-tổ-chức-thư-mục-kiểm-thử-chuẩn-test-architecture)
5. [Mẫu viết kịch bản test trực quan (tests/*.spec.js)](#5-mẫu-viết-kịch-bản-test-trực-quan-testsspecjs)
6. [File Batch Launcher mở trình duyệt trên Desktop thật (Run-Test-Live.bat)](#6-file-batch-launcher-mở-trình-duyệt-trên-desktop-thật-run-test-livebat)
7. [Quy trình nghiệm thu sau khi test (Test Acceptance & Verification)](#7-quy-trình-nghiệm-thu-sau-khi-test-test-acceptance--verification)
8. [Sau khi test xong thì làm gì? (Post-Test Actions & Bug Workflow)](#8-sau-khi-test-xong-thì-làm-gì-post-test-actions--bug-workflow)
9. [Cách thêm mới hoặc chỉnh sửa kịch bản trong các lần test sau](#9-cách-thêm-mới-hoặc-chỉnh-sửa-kịch-bản-trong-các-lần-test-sau)
10. [Checklist 9 bước Step-by-Step dành riêng cho Agent trên máy PC mới](#10-checklist-9-bước-step-by-step-dành-riêng-cho-agent-trên-máy-pc-mới)

---

## 1. BẢN CHẤT KỸ THUẬT: VÌ SAO TRƯỚC ĐÂY CÀI PLAYWRIGHT RỒI NHƯNG AGENT KHÔNG MỞ TRÌNH DUYỆT CHO NGƯỜI DÙNG XEM ĐƯỢC?

Đây là phần **sống còn** giải thích 3 nguyên nhân cốt lõi khiến các AI Agent thường thất bại khi chạy test trực quan trên Windows:

### 🔴 Nguyên nhân 1: Cơ chế cô lập Desktop Station của Windows (`exebox` vs `WinSta0\Default`)
* **Bản chất**: Khi AI Agent (Antigravity, Cursor, background worker) chạy terminal lệnh ngầm (`run_command`), Windows và môi trường sandbox tự động đẩy tiến trình con vào một **Desktop ảo cô lập** (ví dụ: `exebox-UH4IDT53D23N2B6IEPLI3QWQEP`).
* **Hậu quả**: Khi Agent gõ lệnh `playwright test --headed`, Chrome **thực sự đã mở và chạy thành công**, nhưng cửa sổ của nó được vẽ trên màn hình ảo ngầm `exebox`. Trong khi đó, mắt người dùng đang nhìn vào màn hình vật lý chính (`WinSta0\Default`). Người dùng thấy máy im lìm, không có cửa sổ nào xuất hiện!
* **Giải pháp chuẩn xác**: Agent phải tạo một file launcher `.bat` (ví dụ `Run-Test-Live.bat`) đặt ngoài **Desktop** của người dùng. Khi chạy từ giao diện tương tác thật (`explorer.exe`), Windows sẽ gán Chrome vào đúng `WinSta0\Default`, cửa sổ bật to rõ trước mắt người dùng.

### 🔴 Nguyên nhân 2: Lỗi màn hình trắng xóa (Blank White Canvas) khi dùng Puppeteer / sai cờ GPU
* **Bản chất**: Nếu dùng Puppeteer-core với các cờ dòng lệnh thủ công (`--start-maximized`, `defaultViewport: null`), driver đồ họa của Windows (DirectX/ANGLE) bị xung đột (GPU deadlock) khiến Chrome không thể vẽ canvas nội dung.
* **Hậu quả**: Cửa sổ mở lên nhưng trắng tinh, không thấy web đâu.
* **Giải pháp chuẩn xác**: Dùng chuẩn **Playwright Test Runner (`@playwright/test`)** với:
  ```javascript
  channel: 'chrome' // Trỏ trực tiếp đến Google Chrome chính thức trên máy
  ```
  Playwright tự động xử lý kết nối CDP, tăng tốc phần cứng mượt mà và không bao giờ bị trắng màn hình.

### 🔴 Nguyên nhân 3: Dùng `fill()` thay vì `pressSequentially()`
* `page.fill()` dán thẳng giá trị trong 1 mili-giây mà không kích hoạt chuỗi sự kiện bàn phím tự nhiên (`keydown`, `keypress`, `keyup`).
* Người dùng không kịp thấy thao tác gõ phím, đồng thời các framework phức tạp (như Knockout.js, DevExtreme, React trong các dự án Monolith HTML) dễ bị mất dữ liệu.
* **Giải pháp**: Luôn dùng `locator.pressSequentially('text', { delay: 120 })` kết hợp `slowMo: 400`.

---

## 2. CÀI ĐẶT NHỮNG GÌ? (PREREQUISITES & LIBRARIES)

Trên bất kỳ máy PC mới nào, Agent thực hiện tuần tự trong thư mục dự án:

```powershell
# 1. Khởi tạo package.json (nếu chưa có)
npm init -y

# 2. Cài đặt bộ đôi Playwright chuẩn
npm install -D @playwright/test playwright

# 3. Cài đặt Chromium của Playwright
npx playwright install chromium
```

> [!IMPORTANT]
> **Hiểu đúng bản chất Runtime vs. Thư viện:**
> - **Runtime**: Là **Node.js**. Bản thân Node.js gốc không có hàm `test()`, `expect()`.
> - **Thư viện**: Là **`@playwright/test`**. Trong file test bắt buộc phải có dòng `const { test, expect } = require('@playwright/test');` thì Node.js mới hiểu được.
> - **Lệnh `npx`**: `npx playwright test` ra lệnh cho Node.js gọi chương trình Playwright Test Runner nằm trong `node_modules` để điều phối test và gửi tín hiệu qua giao thức CDP điều khiển Google Chrome.

### File hỗ trợ 1: Nhúng con trỏ chuột Neon trực quan (`visual_cursor.js`)
Tạo file `visual_cursor.js` tại gốc dự án để tạo hiệu ứng con trỏ chuột Neon và sóng gợn (ripple) khi click:

```javascript
// visual_cursor.js
(function initVisualCursor() {
  if (window.__antigravity_cursor_injected__) return;
  window.__antigravity_cursor_injected__ = true;

  function setupElements() {
    if (document.getElementById('__ag_cursor__')) return;

    const style = document.createElement('style');
    style.id = '__antigravity_cursor_style__';
    style.innerHTML = `
      #__ag_cursor__ {
        position: fixed;
        top: 0; left: 0;
        width: 26px; height: 26px;
        pointer-events: none;
        z-index: 2147483647;
        transform: translate3d(-100px, -100px, 0);
        transition: transform 0.04s ease-out;
        filter: drop-shadow(0 2px 5px rgba(0, 0, 0, 0.45));
      }
      .__ag_ripple__ {
        position: fixed;
        width: 36px; height: 36px;
        border-radius: 50%;
        background: rgba(225, 29, 72, 0.45);
        border: 2px solid #e11d48;
        pointer-events: none;
        z-index: 2147483646;
        transform: translate(-50%, -50%) scale(0.2);
        animation: __ag_ripple_anim__ 0.45s ease-out forwards;
      }
      @keyframes __ag_ripple_anim__ {
        0% { transform: translate(-50%, -50%) scale(0.2); opacity: 1; }
        100% { transform: translate(-50%, -50%) scale(1.6); opacity: 0; }
      }
    `;
    document.head.appendChild(style);

    const cursor = document.createElement('div');
    cursor.id = '__ag_cursor__';
    cursor.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M4.5 3L11.5 21L14.5 13.5L21.5 11.5L4.5 3Z" fill="#e11d48" stroke="#ffffff" stroke-width="1.8" stroke-linejoin="round"/>
      </svg>
    `;
    document.body.appendChild(cursor);

    window.addEventListener('mousemove', (e) => {
      cursor.style.transform = `translate3d(${e.clientX}px, ${e.clientY}px, 0)`;
    }, { passive: true });

    window.addEventListener('mousedown', (e) => {
      const ripple = document.createElement('div');
      ripple.className = '__ag_ripple__';
      ripple.style.left = `${e.clientX}px`;
      ripple.style.top = `${e.clientY}px`;
      document.body.appendChild(ripple);
      setTimeout(() => ripple.remove(), 500);
    }, { passive: true });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupElements);
  } else {
    setupElements();
  }
})();
```

### File hỗ trợ 2: Xuất báo cáo Markdown tự động (`markdown-reporter.js`)
Tạo file `markdown-reporter.js` tại gốc dự án để gom ảnh, video, trace và xuất báo cáo `test-evidence/test-report.md`:

```javascript
// markdown-reporter.js
const fs = require('fs');
const path = require('path');

class MarkdownReporter {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.resolve(process.cwd(), 'test-evidence');
    this.testResults = [];
  }

  onBegin() {
    if (!fs.existsSync(this.outputDir)) fs.mkdirSync(this.outputDir, { recursive: true });
    ['screenshots', 'videos', 'traces'].forEach(d => {
      const p = path.join(this.outputDir, d);
      if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
    });
  }

  onTestEnd(test, result) {
    const title = test.title;
    const status = result.status.toUpperCase();
    const duration = (result.duration / 1000).toFixed(2);
    const attachments = { screenshots: [], videos: [], traces: [] };

    for (const att of result.attachments || []) {
      if (att.name === 'screenshot' || (att.path && att.path.endsWith('.png'))) {
        const dest = path.join(this.outputDir, 'screenshots', path.basename(att.path));
        try { fs.copyFileSync(att.path, dest); } catch (_) {}
        attachments.screenshots.push(`screenshots/${path.basename(att.path)}`);
      } else if (att.name === 'video' || (att.path && att.path.endsWith('.webm'))) {
        const dest = path.join(this.outputDir, 'videos', path.basename(att.path));
        try { fs.copyFileSync(att.path, dest); } catch (_) {}
        attachments.videos.push(`videos/${path.basename(att.path)}`);
      } else if (att.name === 'trace' || (att.path && att.path.endsWith('.zip'))) {
        const dest = path.join(this.outputDir, 'traces', path.basename(att.path));
        try { fs.copyFileSync(att.path, dest); } catch (_) {}
        attachments.traces.push(`traces/${path.basename(att.path)}`);
      }
    }

    if (result.video) {
      const vPath = result.video.path();
      if (fs.existsSync(vPath)) {
        const dest = path.join(this.outputDir, 'videos', path.basename(vPath));
        try { fs.copyFileSync(vPath, dest); } catch (_) {}
        attachments.videos.push(`videos/${path.basename(vPath)}`);
      }
    }

    this.testResults.push({
      title,
      status,
      duration: `${duration}s`,
      errors: (result.errors || []).map(e => e.message || e.value).join('\n'),
      attachments
    });
  }

  async onEnd(result) {
    fs.writeFileSync(
      path.join(this.outputDir, 'results.json'),
      JSON.stringify({ status: result.status, total: this.testResults.length, tests: this.testResults }, null, 2),
      'utf8'
    );

    let md = `# BÁO CÁO KẾT QUẢ KIỂM THỬ PLAYWRIGHT E2E\n\n`;
    md += `> Thời gian chạy: ${new Date().toLocaleString('vi-VN')}\n`;
    md += `> Trạng thái tổng thể: **${result.status.toUpperCase()}** (${this.testResults.length} test case)\n\n---\n\n`;

    this.testResults.forEach((tc, idx) => {
      const id = `TC-${String(idx + 1).padStart(2, '0')}`;
      const badge = tc.status === 'PASSED' ? '✅ PASS' : '❌ FAIL';
      md += `### ${id}: ${tc.title}\n\n`;
      md += `**Kết quả**: ${badge} (Thời gian thực thi: \`${tc.duration}\`)\n\n`;

      if (tc.errors) {
        md += `> [!WARNING] Lỗi phát hiện:\n`;
        md += `\`\`\`\n${tc.errors}\n\`\`\`\n\n`;
      }

      md += `#### Bằng chứng kiểm thử:\n`;
      if (tc.attachments.screenshots.length) {
        md += `- **Ảnh chụp màn hình**:\n`;
        tc.attachments.screenshots.forEach(s => md += `  - ![Screenshot](${s})\n`);
      }
      if (tc.attachments.videos.length) {
        md += `- **Video quay trực tiếp**:\n`;
        tc.attachments.videos.forEach(v => md += `  - [${v}](${v})\n`);
      }
      if (tc.attachments.traces.length) {
        md += `- **Playwright Trace**:\n`;
        tc.attachments.traces.forEach(t => md += `  - [${t}](${t}) *(Mở xem lại: \`npx playwright show-trace ${t}\`)*\n`);
      }
      md += `\n---\n\n`;
    });

    fs.writeFileSync(path.join(this.outputDir, 'test-report.md'), md, 'utf8');
  }
}

module.exports = MarkdownReporter;
```

---

## 3. CẤU HÌNH NHỮNG GÌ? BẬT/TẮT NHỮNG GÌ? (`playwright.config.js`)

Tạo file `playwright.config.js` tại thư mục gốc:

```javascript
// playwright.config.js
const { defineConfig } = require('@playwright/test');
const path = require('path');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 60000,
  fullyParallel: false, // Để false khi muốn chạy tuần tự quan sát

  // BẬT: 1 worker khi muốn quan sát trực quan trước mắt
  // (Đổi thành 4 hoặc 8 khi muốn chạy song song siêu tốc)
  workers: 1,

  // BẬT: Gom báo cáo ra Markdown
  reporter: [
    ['list'],
    ['./markdown-reporter.js', { outputDir: path.resolve(__dirname, 'test-evidence') }]
  ],

  use: {
    // TẮT: Tắt headless để BẮT BUỘC mở cửa sổ Chrome thật
    headless: false,

    // TẮT viewport cứng để cửa sổ vừa vặn toàn màn hình
    viewport: null,

    // BẬT: Độ trễ 400ms giữa các thao tác để mắt người dễ quan sát
    launchOptions: {
      slowMo: 400,
      args: [
        '--start-maximized',
        '--no-sandbox',
        '--disable-setuid-sandbox'
      ]
    },

    // BẬT: Chụp ảnh bằng chứng
    screenshot: 'on',

    // BẬT: Quay video màn hình
    video: {
      mode: 'on',
      size: { width: 1440, height: 900 }
    },

    // BẬT: Ghi trace Playwright
    trace: 'on'
  },

  // BẬT: Dùng Google Chrome thật trên Windows
  projects: [
    {
      name: 'Google Chrome',
      use: {
        channel: 'chrome'
      }
    }
  ]
});
```

---

## 4. CẤU TRÚC TỔ CHỨC THƯ MỤC KIỂM THỬ CHUẨN (TEST ARCHITECTURE)

Áp dụng quy tắc phân chia module khoa học để dự án phát triển lên hàng trăm kịch bản vẫn quản lý gọn gàng:

```
project-root/
│
├── tests/                                  📁 NƠI CHỨA CÁC FILE KỊCH BẢN TEST (.spec.js)
│   ├── auth/                               # Phân hệ Xác thực
│   │   ├── login.spec.js                   # 1 Menu/Màn hình = 1 File .spec.js
│   │   └── forgot_password.spec.js
│   │
│   ├── human_resource/                     # Phân hệ Quản trị nhân sự
│   │   ├── employee_list.spec.js           # Kịch bản Danh sách nhân viên
│   │   ├── add_employee.spec.js            # Kịch bản Thêm mới nhân viên
│   │   └── contract_management.spec.js    # Kịch bản Quản lý hợp đồng
│   │
│   ├── timekeeping/                        # Phân hệ Chấm công
│   │   └── attendance_board.spec.js
│   │
│   └── payroll/                            # Phân hệ Tính lương
│       └── salary_sheet.spec.js
│
├── test-evidence/                          📁 NƠI CHỨA BẰNG CHỨNG XUẤT RA TỰ ĐỘNG
│   ├── test-report.md                      # Báo cáo Markdown tổng hợp chi tiết
│   ├── results.json                        # Dữ liệu JSON máy đọc
│   ├── screenshots/                        # Chứa các ảnh chụp màn hình (.png)
│   ├── videos/                             # Chứa video quay lại toàn bộ thao tác (.webm)
│   └── traces/                             # Chứa file trace (.zip)
│
├── playwright.config.js                    ⚙️ Cấu hình Playwright chung
├── visual_cursor.js                        🖱️ Con trỏ chuột Neon & Ripple
├── markdown-reporter.js                    📄 Reporter xuất báo cáo Markdown
└── Run-Test-Live.bat                       🚀 Nút bấm 1-Click Run trên Desktop
```

---

## 5. MẪU VIẾT KỊCH BẢN TEST TRỰC QUAN (`tests/*.spec.js`)

Mỗi kịch bản test tuân thủ nghiêm ngặt mô hình 3 bước: **Action $\rightarrow$ Evidence $\rightarrow$ Assertion**:

```javascript
// tests/human_resource/add_employee.spec.js
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

test.describe('Phân hệ Nhân sự - Thêm mới nhân viên', () => {
  test.beforeEach(async ({ context }) => {
    // Luôn nhúng con trỏ chuột Neon trước mỗi kịch bản
    const cursorScriptPath = path.resolve(__dirname, '../../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      await context.addInitScript(fs.readFileSync(cursorScriptPath, 'utf8'));
    }
  });

  test('TC-01: Thêm mới nhân viên thành công với đầy đủ thông tin', async ({ page }) => {
    // BƯỚC 1: ACTION (Mở trang & Nhập liệu trực quan)
    await page.goto('https://paradisehrm.com/Tai3/#', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(1500);

    // Di chuột và gõ có delay
    const empNameInput = page.locator('#employee-name');
    await empNameInput.click();
    await empNameInput.fill('');
    await empNameInput.pressSequentially('Nguyễn Văn An', { delay: 120 });

    const saveBtn = page.locator('#btn-save');
    await saveBtn.click();

    // BƯỚC 2: EVIDENCE (Chụp ảnh bằng chứng)
    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'test-evidence/screenshots/TC-01-added.png' });

    // BƯỚC 3: ASSERTION (Trọng tài phán quyết PASS/FAIL)
    const isSuccess = await page.evaluate(() => {
      return document.body.innerText.includes('Lưu thành công');
    });
    expect(isSuccess).toBeTruthy();
  });
});
```

---

## 6. CƠ CHẾ "1-CLICK RUN" & HƯỚNG DẪN CHẠY SONG SONG 10 CỬA SỔ CÙNG LÚC

### 6.1. Vì sao dù thay đổi kịch bản (thêm/sửa/xóa) thì bạn VẪN CHỈ BẤM ĐÚNG 1 CLICK?
Nhiều người nghĩ mỗi khi viết kịch bản mới thì phải mở file `.bat` ra để sửa lệnh. **Thực tế hoàn toàn không cần!**
- **Thuật toán quét động (Dynamic Test Discovery)**: Lệnh `npx playwright test` được thiết kế theo cơ chế quét động toàn bộ cây thư mục `tests/**/*.spec.js`.
- **Hành vi tự động**:
  - Khi bạn thêm 10 file `.spec.js` mới $\rightarrow$ Playwright tự động nhận diện và đưa vào hàng đợi.
  - Khi bạn sửa code trong file cũ $\rightarrow$ Playwright tự nạp logic mới nhất.
  - Khi bạn xóa file $\rightarrow$ Playwright tự động bỏ qua.
- **Kết luận**: File `.bat` ngoài Desktop được tạo **đúng 1 lần duy nhất và dùng vĩnh viễn**!

---

### 6.2. Hướng dẫn chạy SONG SONG 10 CỬA SỔ CÙNG LÚC (Parallel 10 Workers)
Khi hệ thống có nhiều màn hình cần kiểm tra nhanh, bạn không cần chạy tuần tự từng cái mà có thể mở **10 cửa sổ Chrome chạy song song độc lập**:

#### Bản chất kỹ thuật:
- Playwright khởi tạo 10 tiến trình con (Workers).
- Mỗi Worker kiểm soát một cửa sổ Chrome riêng biệt với **Isolated Browser Context** (bộ nhớ, cookies, session hoàn toàn độc lập, không sợ bị xung đột đăng nhập).
- Thời gian kiểm thử 10 màn hình rút ngắn từ **10 phút xuống còn dưới 1 phút**!

#### File Batch chạy song song 10 cửa sổ (`Run-10-Parallel-Live.bat`):
Tạo file này ngoài màn hình Desktop để kích hoạt chế độ 10 luồng:

```bat
@echo off
title Paradise HRM - 10 Parallel Windows Visual Test
cls
echo ====================================================================
echo   PARADISE HRM - TEST SONG SONG 10 CUA SO CUNG LUC (1-CLICK RUN)
echo ====================================================================
echo.
echo Dang khoi chay 10 cua so Google Chrome dong thoi tren man hinh...
echo Co che: Tu dong phat hien moi kich ban moi trong thu muc tests/!
echo.
cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
call npx playwright test --headed --workers=10
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU 10 LUONG! DANG MO BAO CAO TONG HOP...
echo ====================================================================
echo.
if exist "test-evidence\test-report.md" (
    start "" "test-evidence\test-report.md"
)
pause
```

---

### 6.3. File Batch chạy tuần tự 1 cửa sổ để quan sát chậm (`Run-Test-Live.bat`):
Khi bạn muốn ngồi thong thả quan sát con trỏ chuột Neon di chuyển mượt mà từng bước một:

```bat
@echo off
title Paradise HRM - Playwright Live Visual Testing (1 Worker)
cls
echo ====================================================================
echo   PLAYWRIGHT LIVE VISUAL TESTING (QUAN SAT TRUC QUAN CHIEU CHAM)
echo ====================================================================
echo.
echo Dang mo Google Chrome that tren man hinh...
echo Che do: slowMo 400ms, Con tro Neon, Quay video, Xuat Markdown!
echo.
cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
call npx playwright test --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT TEST! DANG TU DONG MO FILE BAO CAO...
echo ====================================================================
echo.
if exist "test-evidence\test-report.md" (
    start "" "test-evidence\test-report.md"
)
pause
```

---

## 7. CẤU TRÚC THƯ MỤC BẰNG CHỨNG PHÂN CẤP & QUY TRÌNH NGHIỆM THU

### 7.1. Cấu trúc thư mục bằng chứng chuẩn 2 cấp (`test-evidence/<trang>/<TC-0x>/`)
Mọi bằng chứng kiểm thử được tổ chức tương ứng 1:1 với các file kịch bản trong `tests/`:

```
tests/ (Mã nguồn kịch bản)                test-evidence/ (Bằng chứng nghiệm thu)
├── login.spec.js               ───►     ├── login/                          <-- 1 THƯ MỤC CHO 1 TRANG/FILE
│   ├── TC-01                                │   ├── test-report.md              <-- Báo cáo riêng của trang
│   └── TC-02                                │   ├── TC-01/                      <-- THƯ MỤC RIÊNG CỦA TC-01
│                                            │   │   ├── screenshots/            <-- Ảnh chụp của TC-01
│                                            │   │   ├── videos/                 <-- Video quay TC-01 (.webm)
│                                            │   │   ├── traces/                 <-- Playwright Trace TC-01 (.zip)
│                                            │   │   └── results.json            <-- Kết quả JSON của TC-01
│                                            │   └── TC-02/                      <-- THƯ MỤC RIÊNG CỦA TC-02
│                                            │       ├── screenshots/            <-- Ảnh chụp của TC-02
│                                            │       ├── videos/                 <-- Video quay TC-02 (.webm)
│                                            │       ├── traces/                 <-- Playwright Trace TC-02 (.zip)
│                                            │       └── results.json
├── dashboard_overview.spec.js  ───►     ├── dashboard_overview/             <-- THƯ MỤC CHO TRANG DASHBOARD
│   └── TC-01                                │   ├── test-report.md
│                                            │   └── TC-01/
│                                            │       ├── screenshots/
│                                            │       ├── videos/
│                                            │       ├── traces/
│                                            │       └── results.json
                                             ├── results.json                    <-- Master JSON tổng hợp
                                             └── test-report.md                  <-- MASTER REPORT TỔNG THỂ DỰ ÁN
```

### 7.2. Tiêu chuẩn nghiệm thu một đợt test (DoD):
1. **100% Test cases đều có thư mục riêng** `test-evidence/<trang>/<TC-0x>/` với đầy đủ ảnh chụp, video `.webm`, trace `.zip`, và file thực thi **`Run-This-TC.bat`**.
2. **File thực thi 1-Click tại chỗ (`Run-This-TC.bat`)**: Khi nhấp đúp vào file `.bat` trong thư mục `TC-0x`, Chrome sẽ bật lên, hiển thị chuột Neon, gõ phím từ từ và chạy lại đúng test case đó cho người dùng xem trực tiếp.
3. **File thực thi trang (`Run-This-Page.bat`)**: Trong thư mục `test-evidence/<trang>/` để chạy lại toàn bộ test case của trang đó.
4. **File báo cáo Master [`test-evidence/test-report.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/test-evidence/test-report.md) đã sinh ra**: Tổng hợp trạng thái toàn bộ các trang, có link xem chi tiết từng trang.
5. **Báo cáo riêng từng trang [`test-evidence/<trang>/test-report.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/test-evidence/)**: Liệt kê chi tiết từng `TC-01`, `TC-02` bên trong trang đó.

### 7.3. 3 bước nghiệm thu thực tế:
* **Bước 1: Mở báo cáo Master**: Xem bảng tổng quan các trang. Nếu toàn bộ màu xanh `✅ PASS` $\rightarrow$ Nghiệm thu đợt test thành công.
* **Bước 2: Mở video kiểm chứng hoặc nhấp đúp `Run-This-TC.bat`**: Xem video hoặc bấm chạy lại trực tiếp trên màn hình xem máy thao tác.
* **Bước 3: Đối chiếu kết quả nghiệp vụ**: Xác nhận dữ liệu vừa tạo đã thực sự đi vào hệ thống hoặc hiển thị đúng trên giao diện.

---

## 8. SAU KHI TEST XONG THÌ LÀM GÌ? (POST-TEST ACTIONS & BUG WORKFLOW)

Tùy vào kết quả nghiệm thu, quy trình xử lý tiếp theo như sau:

```
                      KẾT QUẢ ĐỢT TEST
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
      TẤT CẢ ĐỀU PASS                   CÓ TEST CASE FAIL
            │                                 │
  • Lưu trữ file test-report.md      • Phân loại nguyên nhân:
  • Bàn giao tính năng                 1. Do Selector UI đổi?
  • Đưa kịch bản vào bộ Test           2. Do Dữ liệu / Mạng?
    Hồi quy (Regression Suite).        3. Do LỖI PHẦN MỀM THỰC SỰ?
                                              │
                                     • Gửi Bug Report kèm Video
                                       hoặc Agent tự fix code & retest!
```

### Nếu có lỗi (FAIL) — Mẫu Bug Report gửi cho Developer:
```markdown
### [BUG-01] Không thể lưu Hồ sơ nhân viên khi nhập ký tự có dấu
- **Màn hình**: Quản trị nhân sự -> Hồ sơ nhân viên
- **Kịch bản**: TC-02 trong `tests/human_resource/add_employee.spec.js`
- **Thời gian phát hiện**: 10:45 15/10/2026
- **Kết quả thực tế**: Nút "Lưu" bấm vào bị vô hiệu hóa, console báo lỗi 500.
- **Bằng chứng**:
  - Video khoảnh khắc lỗi: `test-evidence/videos/TC-02.webm`
  - Ảnh chụp lỗi: `test-evidence/screenshots/TC-02-failed.png`
  - Trace: `test-evidence/traces/TC-02.zip`
```

---

## 9. CÁCH THÊM MỚI HOẶC CHỈNH SỬA KỊCH BẢN TRONG CÁC LẦN TEST SAU

Khi dự án tiếp tục phát triển, quy tắc mở rộng kịch bản như sau:

### A. Thêm kịch bản mới trên MÀN HÌNH ĐÃ CÓ:
👉 **Mở trực tiếp file `.spec.js` của màn hình đó và viết thêm block `test()`**:
```javascript
// tests/human_resource/employee_list.spec.js
test('TC-01: Xem danh sách nhân viên', async ({ page }) => { ... });

// VIẾT THÊM VÀO ĐÂY:
test('TC-02: Tìm kiếm nhân viên theo mã phòng ban', async ({ page }) => {
  await page.locator('#dept-filter').click();
  await page.locator('#dept-option-IT').click();
  await expect(page.locator('.grid-row')).toContainText('Phòng CNTT');
});
```

### B. Thêm kịch bản cho MÀN HÌNH MỚI:
👉 **Tạo file `.spec.js` mới trong thư mục phân hệ tương ứng** (ví dụ: `tests/payroll/bonus_calculation.spec.js`).

### C. Chạy lại kiểm thử:
👉 **Bạn không cần cấu hình lại gì cả!** Chỉ cần bấm lại file **`Run-Test-Live.bat`**. Playwright sẽ tự động phát hiện tất cả các file mới và chạy lại toàn bộ từ A $\rightarrow$ Z!

---

## 10. CHECKLIST 9 BƯỚC STEP-BY-STEP DÀNH CHO AGENT TRÊN MÁY PC MỚI

Khi một AI Agent mới tiếp nhận máy tính hoặc dự án mới, chỉ cần thực hiện đúng **9 bước** sau để vận hành trơn tru:

1. **Bước 1**: Kiểm tra Node.js bằng `node -v` (yêu cầu Node 18 trở lên).
2. **Bước 2**: Chạy lệnh `npm install -D @playwright/test playwright`.
3. **Bước 3**: Tạo file `visual_cursor.js` theo mã nguồn ở Mục 2.
4. **Bước 4**: Tạo file `markdown-reporter.js` theo mã nguồn ở Mục 2.
5. **Bước 5**: Tạo file `playwright.config.js` theo mã nguồn ở Mục 3 (đảm bảo `channel: 'chrome'`, `slowMo: 400`, `headless: false`).
6. **Bước 6**: Tạo thư mục `tests/` và viết kịch bản test mẫu đầu tiên `tests/login.spec.js` theo Mục 5.
7. **Bước 7**: Tạo file `Run-Test-Live.bat` đặt tại gốc dự án và copy 1 bản ra `C:\Users\<username>\Desktop`.
8. **Bước 8**: Hướng dẫn người dùng nhấp đúp file `.bat` trên Desktop để quan sát Chrome thao tác trực tiếp.
9. **Bước 9**: Sau khi chạy xong, mở file `test-evidence/test-report.md` để đối chiếu nghiệm thu kết quả!

---

## 11. HƯỚNG DẪN CHẠY TEST THỦ CÔNG BẰNG TERMINAL (CLI CHEATSHEET LINH HOẠT)

Nếu bạn muốn mở PowerShell hoặc CMD để gõ lệnh trực tiếp với độ linh hoạt cao nhất, dưới đây là bộ lệnh đầy đủ:

### 1. Cú pháp điều hướng vào dự án:
```powershell
cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
```

### 2. Các cấp độ chạy test:
| Cấp độ | Câu lệnh Terminal | Ý nghĩa |
| :--- | :--- | :--- |
| **Cả thư mục** | `npx playwright test --headed` | Quét và chạy **toàn bộ file** trong `tests/`. |
| **Chỉ 1 file** | `npx playwright test tests/login.spec.js --headed` | Chỉ chạy **toàn bộ bài test trong file đó**. |
| **Chỉ 1 test case** | `npx playwright test -g "TC-01" --headed` | Lọc theo từ khóa/mã: Chỉ chạy **đúng test case có tên chứa TC-01**. |
| **Kết hợp File + Case** | `npx playwright test tests/login.spec.js -g "TC-01" --headed` | Chỉ chạy TC-01 bên trong file `login.spec.js`. |

### 3. Các cờ tham số (Flags) nâng cao cực kỳ mạnh mẽ:
* `--headed`: Bắt buộc mở giao diện trình duyệt để người dùng nhìn thấy thao tác.
* `--workers=4`: Chạy 4 luồng song song (mở 4 cửa sổ Chrome cùng lúc).
* `--max-failures=1`: Chế độ **Fail-Fast** — Hễ phát hiện 1 lỗi đầu tiên là dừng ngay lập tức, không test tiếp.
* `--debug`: Mở chế độ **Playwright Inspector** từng bước: Cho phép bạn bấm nút Next để chạy từng dòng code, soi selector trực tiếp.
* `--ui`: Mở giao diện **Playwright UI Dashboard** đồ họa: Cho phép xem timeline thao tác, time-travel tua lại video mượt mà.
* `npx playwright show-trace <đường_dẫn_file_trace.zip>`: Mở công cụ phân tích trace chi tiết từng frame hình và gói tin mạng.

---

## 12. CƠ CHẾ PHÁT HIỆN LỖI (LÀM SAO PLAYWRIGHT BIẾT CÓ LỖI HAY ĐẠT?)

Playwright là một hệ thống kiểm định tự động nghiêm ngặt. Nó nhận biết lỗi qua **2 cơ chế cốt lõi**:

### A. Lỗi thao tác giao diện & Runtime (Action / Timeout Errors)
Khi code ra lệnh:
```javascript
await page.locator('#btn-submit').click();
```
* Playwright tự động chờ nút `#btn-submit` xuất hiện, có thể nhìn thấy (visible), không bị che khuất và có thể bấm được (enabled).
* Nếu sau thời gian chờ (mặc định 30s) mà nút không xuất hiện hoặc bị loading che $\rightarrow$ Playwright lập tức ném ra lỗi `TimeoutError: locator.click: Timeout 30000ms exceeded`.
* **Playwright nhận diện đây là LỖI THAO TÁC $\rightarrow$ Đánh dấu test case là FAILED**.

### B. Lỗi kiểm chứng kỳ vọng (`expect` Assertions)
Đây chính là **"Vị giám khảo"** quyết định bài test có đạt tiêu chuẩn nghiệp vụ hay không:
```javascript
// 1. Kiểm tra thông báo lưu thành công có hiển thị không
await expect(page.locator('.toast-success')).toBeVisible();

// 2. Kiểm tra dữ liệu hiển thị đúng giá trị
await expect(page.locator('#total-salary')).toHaveText('15,000,000');

// 3. Kiểm tra biến toàn cục hệ thống đã nạp chưa
expect(isAppLoaded).toBeTruthy();
```
* Nếu kết quả thực tế **KHÔNG KHỚP** với kỳ vọng của hàm `expect()` $\rightarrow$ Playwright lập tức ngắt bài test, ném ra lỗi `AssertionError`.
* **Playwright nhận diện đây là LỖI NGHIỆP VỤ $\rightarrow$ Đánh dấu test case là FAILED**.

### Khi gặp lỗi, Playwright làm gì?
1. **Dừng bài test hiện tại ngay tại dòng bị lỗi** (không chạy tiếp các dòng bên dưới bài đó nữa để tránh làm bẩn dữ liệu).
2. **Chụp ngay ảnh màn hình tại đúng thời khắc lỗi** $\rightarrow$ Lưu vào `test-evidence/screenshots/`.
3. **Đóng gói video quay màn hình** từ đầu đến thời khắc lỗi $\rightarrow$ Lưu vào `test-evidence/videos/`.
4. **Chuyển sang chạy tiếp bài test tiếp theo** trong danh sách (không làm treo cả hệ thống).

---

## 13. CẤU TRÚC THƯ MỤC `test-results/` VÀ NGUYÊN TẮC GHI ĐÈ KẾT QUẢ

Khi bạn nhìn vào thư mục `test-results/` trên máy tính:
```
test-results/
└── login-Kiểm-thử-Đăng-nhập-P-6a55f--với-tài-khoản-Chien-nguyen-Google-Chrome/
    ├── test-finished-1.png
    ├── trace.zip
    └── video.webm
```

### 1. Cứ chạy 1 `TC-0x` thì tạo 1 thư mục riêng hay chạy cả file mới có?
👉 **MỖI 1 TEST CASE (`TC-0x`) SẼ TẠO RA ĐÚNG 1 THƯ MỤC RIÊNG!**
* Tên thư mục được Playwright sinh tự động theo công thức:
  `[Tên file test] - [Tên nhóm describe] - [Mã Hash ID] - [Tên test case] - [Tên Browser]`
* Nếu trong 1 file `.spec.js` bạn viết 3 bài test (`TC-01`, `TC-02`, `TC-03`), thì khi chạy Playwright sẽ tạo ra **3 thư mục con riêng biệt** trong `test-results/`, mỗi thư mục chứa video, ảnh và trace riêng của bài test đó.

### 2. Nếu chạy lại cùng 1 `TC-0x` nhiều lần thì sinh thêm thư mục hay thay thế thư mục cũ?
👉 **MẶC ĐỊNH LÀ THAY THẾ (GHI ĐÈ) THƯ MỤC CŨ BẰNG KẾT QUẢ MỚI NHẤT!**
* Trước khi bắt đầu một lượt chạy test mới, Playwright sẽ tự động dọn dẹp thư mục kết quả của bài test đó và ghi đè video/ảnh mới nhất.
* Trừ khi bạn bật cấu hình tự động thử lại khi fail (`retries: 2`), Playwright mới sinh thêm thư mục phụ có đuôi `-retry1`, `-retry2`.
* Nhờ cơ chế này, ổ cứng của bạn không bao giờ bị tràn dung lượng khi test đi test lại một chức năng nhiều lần!

---

## 14. BẢNG ĐIỀU KHIỂN TƯƠNG TÁC 2 CẤP (MENU -> TEST CASES)

Hệ thống đã tích hợp sẵn file [`Run-ParadiseHR-Interactive.bat`](file:///C:/Users/Y.Thach/Desktop/Run-ParadiseHR-Interactive.bat) ngoài Desktop hoạt động theo mô hình 2 cấp:

```
[MENU CHÍNH] -> Quét tự động các file trong tests/
   │
   ├── Người dùng chọn Menu [2]: tests/login.spec.js
   │      │
   │      ▼
   └── [MENU CẤP 2 - CHI TIẾT KỊCH BẢN CỦA MENU]:
          ├── [A] Chạy TOÀN BỘ các test case trong menu này (Mặc định)
          ├── [1] TC-01: Đăng nhập thành công với tài khoản Chien.nguyen
          └── [B] Quay lại Menu chính
```
* **Bấm [A]**: Chạy toàn bộ các test case trong file.
* **Bấm [1]**: Chỉ chạy riêng đúng test case `TC-01`.
* **Bấm [B]**: Quay lại menu chính.

---

## 15. CƠ CHẾ TÁI SỬ DỤNG TRẠNG THÁI ĐĂNG NHẬP (AUTHENTICATION REUSE & STORAGESTATE)

### Vấn đề thực tế:
Khi hệ thống có 50 - 100 test case cho các chức năng nội bộ (Chấm công, Tính lương, Hợp đồng, v.v.), tất cả đều yêu cầu phải đăng nhập.
Nếu kịch bản nào cũng phải mở trang đăng nhập, gõ tài khoản, mật khẩu rồi chờ load:
- Mất thêm 5 - 10 giây cho MỖI bài test $\rightarrow$ 100 bài test tốn thêm 10 - 15 phút lãng phí chỉ để ngồi đăng nhập lặp đi lặp lại!
- Làm lặp code (duplicate code) khắp các file test.

---

### Giải pháp 1 (Chuẩn mực Playwright): Cơ chế `storageState` — Đăng nhập 1 lần, dùng mãi mãi
Playwright hỗ trợ lưu toàn bộ phiên làm việc (Cookies, Session, LocalStorage) vào một file `auth.json`:

#### 1. Bước 1: Viết 1 file setup đăng nhập duy nhất (`tests/auth.setup.js`):
```javascript
const { test } = require('@playwright/test');

test('Xác thực và lưu phiên đăng nhập', async ({ page }) => {
  await page.goto('https://paradisehrm.com/Tai3/#');
  await page.locator('#username').pressSequentially('Chien.nguyen');
  await page.locator('input[type="password"]').pressSequentially('123');
  await page.locator('#submitLogin').click();
  await page.waitForTimeout(4000);

  // Lưu toàn bộ phiên đăng nhập (Cookies, Token, LocalStorage) ra file auth.json
  await page.context().storageState({ path: 'auth.json' });
});
```

#### 2. Bước 2: Cấu hình nạp `auth.json` trong `playwright.config.js`:
```javascript
module.exports = defineConfig({
  use: {
    // Tự động cấp trạng thái đã đăng nhập cho tất cả các bài test
    storageState: 'auth.json',
  }
});
```

#### 3. Bước 3: Viết các kịch bản test chức năng (Mở web là ĐÃ ĐĂNG NHẬP SẴN):
```javascript
test('TC-01: Thêm mới hợp đồng lao động', async ({ page }) => {
  // Trình duyệt mở web lên là ĐÃ Ở TRẠNG THÁI ĐĂNG NHẬP SẴN!
  await page.goto('https://paradisehrm.com/Tai3/#');

  // Đi thẳng vào thao tác menu nghiệp vụ:
  await page.locator('#menu-contract').click();
  await page.locator('#btn-add').click();
});
```

---

### Giải pháp 2 (Trực quan nhất): Dùng Hàm dùng chung `loginAsAdmin` + Hook `beforeEach`
Nếu bạn vẫn muốn trình duyệt mở trang login và nhập mật khẩu trực tiếp để người dùng/khách hàng xem video biểu diễn:

#### 1. Tạo file helper dùng chung `helpers/auth.js`:
```javascript
async function loginAsAdmin(page) {
  await page.goto('https://paradisehrm.com/Tai3/#');
  await page.locator('#username').pressSequentially('Chien.nguyen', { delay: 100 });
  await page.locator('input[type="password"]').pressSequentially('123', { delay: 100 });
  await page.locator('#submitLogin').click();
  await page.waitForTimeout(4000);
}
module.exports = { loginAsAdmin };
```

#### 2. Gọi lại trong `beforeEach` của file test (chỉ 1 dòng duy nhất):
```javascript
const { test, expect } = require('@playwright/test');
const { loginAsAdmin } = require('../helpers/auth');

test.describe('Phân hệ Chấm công', () => {
  // Tự động chạy đăng nhập TRƯỚC MỖI BÀI TEST trong file này:
  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
  });

  test('TC-01: Xem bảng chấm công tháng', async ({ page }) => {
    // Đã đăng nhập xong, chỉ việc test nghiệp vụ:
    await page.locator('#menu-timesheet').click();
  });
});
```

---

### Bảng so sánh khi nào dùng Giải pháp nào:
| Tiêu chí | Giải pháp 1: `storageState` | Giải pháp 2: `beforeEach + login()` |
| :--- | :--- | :--- |
| **Tốc độ test** | **Siêu tốc** (bỏ qua bước login, vào thẳng menu) | Chậm hơn (mất thêm 5s gõ tài khoản mỗi bài) |
| **Mục đích phù hợp** | Chạy kiểm thử hồi quy 100 kịch bản hàng ngày (Regression Testing) | Biểu diễn Live Visual cho sếp/khách hàng quan sát từ A-Z |
| **Bảo trì** | Khi đổi mật khẩu, chỉ cần chạy lại `auth.setup.js` 1 lần | Sửa tài khoản tại 1 file duy nhất `helpers/auth.js` |

---

## 16. CƠ CHẾ KIỂM THỬ ĐA NĂNG CHO MỌI WEBSITE BẤT KỲ TRÊN INTERNET (`test.env.json`)

Playwright không chỉ kiểm thử riêng hệ thống Paradise HRM, mà là một framework kiểm định toàn cầu có thể **kiểm thử bất kỳ trang web nào trên Internet** (từ ERP, HRM, thương mại điện tử Tiki/Shopee, SaaS, mạng xã hội, đến phần mềm quản lý nội bộ).

### 1. Làm sao hệ thống biết đang test trên web nào?
Hệ thống sử dụng file cấu hình môi trường chuẩn:
👉 [`test.env.json`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/test.env.json)

```json
{
  "baseUrl": "https://paradisehrm.com/Tai3/#",
  "auth": {
    "username": "Chien.nguyen",
    "password": "123",
    "usernameSelector": "#username",
    "passwordSelector": "input[type=\"password\"]",
    "submitSelector": "#submitLogin"
  }
}
```

### 2. Quy trình làm việc 2 bước cực kỳ tiện lợi:

#### LẦN ĐẦU TIÊN (Khi bắt đầu kiểm thử một website mới):
Người dùng chỉ cần cung cấp: **Link website** + **Tài khoản / Mật khẩu**.
> *Ví dụ:* *"Hãy test web `https://my-company-erp.vn`, tài khoản `admin`, mật khẩu `Abc@123`"*.

* **AI Agent sẽ tự động**:
  1. Mở website đó trên Google Chrome.
  2. Dò tìm selector của ô nhập tài khoản, mật khẩu và nút submit.
  3. Lưu toàn bộ cấu hình vào file `test.env.json`.
  4. Đăng nhập thử để kiểm tra tính hợp lệ và sẵn sàng cho các bài test.

#### TẤT CẢ CÁC LẦN SAU:
👉 **Người dùng HOÀN TOÀN KHÔNG CẦN nhập lại link web hay mật khẩu nữa!**
Chỉ cần gọi skill và nói tên menu muốn test:
> *Ví dụ:* *"Dùng skill `playwright-live-visual-e2e` test menu Tạo phiếu nghỉ phép"* hoặc *"Test thêm chức năng duyệt đơn"*.

* **Hệ thống sẽ tự động**:
  1. Đọc link web và tài khoản từ `test.env.json`.
  2. Mở trình duyệt Google Chrome thật (có chuột Neon phát sáng).
  3. Tự động đăng nhập sẵn qua module `helpers/auth.js`.
  4. Bấm vào đúng menu bạn yêu cầu để viết `TC-01` (nếu là trang mới) hoặc bổ sung `TC-02` (nếu trang đã có test).
  5. Xuất ảnh, video, báo cáo và tự động cập nhật vào menu `Run-ParadiseHR-Interactive.bat` ngoài Desktop!

### 3. Khi muốn đổi sang một website khác hoàn toàn:
Người dùng chỉ cần nói:
> *"Bây giờ hãy chuyển sang test web `https://he-thong-khac.com` với tài khoản `user2`/`pass2`"*.

Agent sẽ lập tức cập nhật lại file `test.env.json` cho website mới và mọi bài test sau đó sẽ tự động chạy trên trang web mới này!

---

## 17. HƯỚNG DẪN KỸ THUẬT: CƠ CHẾ SINH FILE .BAT TẠI CHỖ (Run-This-TC.bat & Run-This-Page.bat)

Để đảm bảo người dùng có thể nhấp đúp chạy lại riêng bất kỳ test case nào ngay tại thư mục bằng chứng của nó, hệ thống sử dụng cơ chế sinh file `.bat` tự động:

### 1. File `Run-This-TC.bat` (Nằm trong `test-evidence/<trang>/<TC-0x>/`):
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
pause
```

### 2. File `Run-This-Page.bat` (Nằm trong `test-evidence/<trang>/`):
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
pause
```

### 3. Tự động hóa qua Node.js trong `markdown-reporter.js`:
Mỗi khi một test case chạy xong (`onTestEnd`) hoặc khi toàn bộ trang chạy xong (`onEnd`), reporter sẽ tự động ghi các file `.bat` này ra đĩa. Người dùng không cần phải tạo thủ công!

---

## 18. CƠ CHẾ TỰ ĐỘNG CHẠY THEO HỆ THỐNG HIỆN TẠI & XỬ LÝ KHI HỆ THỐNG THAY ĐỔI (REGRESSION TESTING)

### 1. Cơ chế tự động chạy theo hệ thống hiện tại

Mỗi khi bạn mở bất kỳ file `.bat` nào:
* 🎯 **`Run-This-TC.bat`**: Chạy lại riêng 1 kịch bản cụ thể.
* 📄 **`Run-This-Page.bat`**: Chạy lại toàn bộ kịch bản của trang đó.
* 🖥️ **`Run-ParadiseHR-Interactive.bat`**: Menu tổng ngoài Desktop để chọn chạy bất kỳ trang nào.

**Hệ thống sẽ tự động thực hiện hoàn toàn mới:**
* **Mở trình duyệt Google Chrome thật** và truy cập thẳng vào trang web hiện tại (theo URL trong `test.env.json`).
* **Quay một Video `.webm` MỚI TOANH** ghi lại toàn bộ chuyển động con trỏ chuột Neon và hành động trên giao diện mới nhất.
* **Chụp các ảnh Screenshot MỚI** để lưu vết màn hình tại thời điểm chạy.
* **Cập nhật lại Báo cáo `test-report.md` và `results.json`**:
  - Ghi nhận chính xác ngày giờ vừa chạy (`timestamp`).
  - Nếu hệ thống chạy tốt $\rightarrow$ Đánh dấu **✅ PASS**.
  - Nếu hệ thống vừa sửa phát sinh lỗi (bug) $\rightarrow$ Đánh dấu **❌ FAIL**, trích xuất ảnh lỗi và log lỗi chi tiết vào báo cáo để gửi cho team dev sửa ngay!

---

### 2. Hai trường hợp khi hệ thống thay đổi

* **Trường hợp 1 (Sửa backend/logic, UI giữ nguyên):**
  👉 Bạn chỉ việc chạy file `.bat`. Không cần sửa bất kỳ dòng mã test nào, kết quả, ảnh chụp và video mới sẽ tự động cập nhật phản ánh đúng trạng thái hệ thống hiện tại.
* **Trường hợp 2 (Giao diện đổi lớn: đổi tên nút, đổi luồng, đổi vị trí menu):**
  👉 Bạn chỉ cần nhắn AI một câu: *"Hệ thống vừa đổi menu X thành Y / đổi quy trình duyệt, hãy cập nhật lại kịch bản test"*. AI sẽ mở trình duyệt dò lại và cập nhật kịch bản `.spec.js`. Sau đó file `.bat` của bạn vẫn tiếp tục sử dụng bình thường mà không cần làm lại từ đầu!

---

## 19. CHUẨN BÁO CÁO KÉP (TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ) & CƠ CHẾ TỰ SUY LUẬN EXPECT

### 1. Chuẩn Báo Cáo Phân Tách 2 Trạng Thái:
Trong kiểm thử tự động chuyên nghiệp, một test case đạt hay không đạt phải được nhìn nhận qua 2 lăng kính:
* **Trạng thái thực thi Test (Kỹ thuật - Test Execution)**:
  - `✅ PASS`: Script Playwright mở trình duyệt, thao tác mượt mà, gõ phím, click và hoàn tất luồng không crash code.
  - `❌ FAIL`: Lỗi kỹ thuật do script (không tìm thấy element, timeout, cú pháp code bị sai).
* **Trạng thái Logic Nghiệp vụ (Business Output / Logic Validation)**:
  - `✅ PASS`: Dữ liệu thực tế hiển thị trên màn hình (Actual Output) khớp chính xác 100% với giá trị kỳ vọng (Expected Output).
  - `❌ FAIL`: Bắt được **Lỗi Logic / Bug Phần mềm** (Ví dụ: Quản lý bấm Duyệt thành công nhưng khi nhân viên mở lại hồ sơ thì dữ liệu vẫn rỗng).

### 2. Bảng Đối Chiếu Chuẩn Trên Mọi Báo Cáo:
Mỗi file `test-report.md` đều có bảng đối chiếu kép ngay đầu báo cáo:
```markdown
| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| TC-01 | Cập nhật thông tin ngân hàng | ✅ PASS | ✅ PASS | Gửi yêu cầu thành công |
| TC-02 | Quản lý phê duyệt thay đổi | ✅ PASS | ✅ PASS | Phê duyệt thành công trên hệ thống |
| TC-03 | Đối chiếu thông tin sau duyệt | ✅ PASS | ❌ FAIL | [Bug Logic]: Dữ liệu sau duyệt chưa cập nhật ra giao diện |
```

### 3. Người dùng có cần prompt chi tiết từng `expect` không?
👉 **HOÀN TOÀN KHÔNG CẦN!**
AI Agent được huấn luyện tự động suy luận toàn bộ các điểm kiểm tra kỳ vọng (Expected Output) theo chuẩn QA:
* **Form nhập liệu/cập nhật**: Tự kỳ vọng thông báo thành công (Toast/Alert), đóng popup, dữ liệu lưu vào bảng.
* **Quy trình phê duyệt**: Tự kỳ vọng badge chuyển từ `Chờ duyệt` sang `Đã duyệt`, đơn biến mất khỏi danh sách chờ.
* **Quy trình đối chiếu khép kín**: Tự kỳ vọng dữ liệu người gửi được cập nhật đúng giá trị vừa duyệt thay vì để trống.
* **Người dùng chỉ cần can thiệp khi nào?** Khi có **quy tắc nghiệp vụ đặc thù riêng** của công ty (Ví dụ: *"Duyệt xong nhưng 24h sau mới có hiệu lực"*, hoặc *"Số tài khoản ngân hàng chỉ nhận tối đa 10 số"*).

---

## 20. TIÊU CHUẨN CHỤP ẢNH STEP-BY-STEP (VISUAL STORYBOARD - BẮT BUỘC)

Tuyệt đối **KHÔNG CHỈ CHỤP DUY NHẤT 1 MÀN HÌNH CUỐI** hoặc để nhiều ảnh trùng lặp vô nghĩa (`test-finished-1.png`). Mọi kịch bản kiểm thử bắt buộc phải ghi lại chuỗi bằng chứng tuần tự theo từng thao tác chính để báo cáo trở thành một thước phim diễn hoạt (storyboard) trực quan sinh động:

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

## 21. QUY CHUẨN PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI KHI TC FAIL (FAILURE ANALYSIS - BẮT BUỘC)

Khi một Test Case bị đánh giá **FAIL** (dù là Kỹ thuật hay Logic Nghiệp vụ), báo cáo nghiệm thu **BẮT BUỘC PHẢI CÓ KHỐI PHÂN TÍCH LỖI CHI TIẾT** theo định dạng GitHub Alert `> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)`.

### Cấu trúc 5 thành tố bắt buộc:
1. **Vấn đề / Mã lỗi**: Tóm tắt ngắn gọn lỗi phát hiện được.
2. **Kỳ vọng nghiệp vụ (Expected Output)**: Hệ thống lẽ ra phải hoạt động hoặc trả về kết quả gì theo chuẩn nghiệp vụ.
3. **Thực tế hệ thống (Actual Output)**: Trên thực tế, hệ thống phản hồi như thế nào (kèm trích dẫn dữ liệu rỗng, mã lỗi, hoặc thông báo sai).
4. **Nguyên nhân cốt lõi (Root Cause)**: Phân tích nguyên nhân kỹ thuật (Stored Procedure nào chưa UPDATE dữ liệu, API nào chưa nạp, hoặc component frontend nào binding sai).
5. **Đề xuất khắc phục (Recommendation)**: Hướng dẫn cụ thể cho đội ngũ Backend/Frontend/DBA cách sửa lỗi nhanh chóng.

### Mẫu trình bày chuẩn trong báo cáo:
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

## 22. BỘ KHUNG MẪU CHUẨN ĐỂ VIẾT FILE TEST `.spec.js` (THE GOLDEN CODE BLUEPRINT)

Để đảm bảo mọi kịch bản đều sinh ra báo cáo trực quan có chuỗi ảnh Step-by-Step, video mượt mà và phân tích lỗi chuẩn xác, mọi file test `.spec.js` mới bắt buộc phải tuân theo bộ khung mẫu gồm 4 khối sau:

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

---

## 23. KHUNG MẪU CHUẨN BÁO CÁO NGHIỆM THU MARKDOWN (THE GOLDEN REPORT BLUEPRINT)

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






