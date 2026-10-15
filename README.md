# 🚀 Playwright Live Visual E2E Automation Testing Framework

> **Bộ khung kiểm thử tự động trực quan chuẩn E2E (Live Visual Testing Starter Kit)** dành cho các hệ thống Web / HRM / ERP / CRM. 
> Tích hợp sẵn con trỏ chuột Neon phát sáng, gõ phím chân thực quan sát được, tự động quay video, chụp ảnh tuần tự từng bước (Step-by-Step Storyboard) và xuất báo cáo Markdown phân cấp chuyên nghiệp với phân tích lỗi chi tiết.

---

## 🌟 8 TÍNH NĂNG ĐỘC BẢN CỦA FRAMEWORK

1. 🎯 **Google Chrome Thật Trực Quan 100%**:
   - Chạy trên Google Chrome chính thức trên Windows (`channel: 'chrome'`, `headless: false`).
   - Tối ưu hóa độ trễ thấp (`slowMo: 100ms`, `transition: none !important`), đồng bộ 100% chuyển động chuột với thao tác thực tế.
2. 💡 **Con Trỏ Chuột Neon Phát Sáng (`visual_cursor.js`)**:
   - Tự động nhúng con trỏ chuột Neon xanh lam trực quan, phát sáng và tỏa sóng gợn (ripple effect) mỗi khi click, giúp người xem nhìn rõ mọi vị trí tương tác trên màn hình.
3. 📸 **Chụp Ảnh Tuần Tự Từng Bước (Step-by-Step Storyboard)**:
   - Tự động ghi lại ảnh chụp ở từng mốc nghiệp vụ chính: Đăng nhập -> Mở form -> Nhập liệu -> Di chuột lên nút hành động -> Kết quả phản hồi.
   - Báo cáo phân cấp theo từng đề mục rõ ràng, loại bỏ 100% ảnh trùng lặp vô nghĩa (`test-finished-1.png`).
4. ⚖️ **Báo Cáo Kép (Dual Status: Kỹ Thuật vs Logic Nghiệp Vụ)**:
   - **Trạng thái thực thi Test (Playwright)**: `PASS` / `FAIL` (Code chạy thông suốt hay bị crash).
   - **Trạng thái Logic Nghiệp vụ**: `PASS` / `FAIL` (Dữ liệu thực tế trên UI có khớp đúng kỳ vọng sau khi xử lý hay không).
5. 🚨 **Khối Phân Tích Lỗi Chi Tiết (Failure Analysis Khi TC FAIL)**:
   - Khi phát hiện bug logic phần mềm, báo cáo tự động hiển thị khối GitHub Alert `> [!CAUTION]` với đủ 5 thành tố: Vấn đề, Kỳ vọng (Expected), Thực tế (Actual), Nguyên nhân cốt lõi (Root Cause), và Đề xuất khắc phục (Recommendation).
6. 🖥️ **Menu 1-Click Bất Tử (Dynamic Test Discovery)**:
   - `Run-ParadiseHR-Interactive.bat`: Menu tương tác tự động quét thư mục `tests/**/*.spec.js`, tự nhận diện trang mới và test case mới mà không cần sửa file `.bat`.
   - `Run-This-Page.bat`: 1-Click chạy lại toàn bộ test case của trang đó.
   - `Run-This-TC.bat`: 1-Click chạy lại riêng đúng 1 kịch bản cụ thể để quan sát.
7. 🌐 **Đa Năng Với Bất Kỳ Website Nào (`test.env.json`)**:
   - Dễ dàng đổi URL mục tiêu, tài khoản hoặc selector đăng nhập qua file cấu hình `test.env.json`.
8. ⚡ **Chế Độ Chạy Song Song 10 Luồng (`Run-10-Parallel-Live.bat`)**:
   - Mở đồng thời 10 cửa sổ Chrome độc lập chạy song song, rút ngắn thời gian hồi quy từ 10 phút xuống dưới 1 phút.

---

## 📂 CẤU TRÚC THƯ MỤC DỰ ÁN

```
├── .agents/skills/                   <-- Skill hướng dẫn AI Agent tự động viết test chuẩn
├── helpers/                          <-- Các module trợ lý (auth, utils)
├── tests/                            <-- Thư mục chứa kịch bản kiểm thử (*.spec.js)
│   ├── login.spec.js
│   ├── employee_bank_approval.spec.js
│   └── ...
├── test-evidence/                    <-- Bằng chứng nghiệm thu tổ chức phân cấp 2 tầng
│   ├── <tên_trang>/                  <-- Thư mục bằng chứng riêng của từng trang
│   │   ├── test-report.md            <-- Báo cáo chi tiết của trang
│   │   ├── Run-This-Page.bat         <-- 1-Click chạy lại toàn bộ trang
│   │   └── <TC-0x>/                  <-- Thư mục bằng chứng riêng từng test case
│   │       ├── Run-This-TC.bat       <-- 1-Click chạy lại riêng TC này
│   │       ├── screenshots/          <-- Ảnh chụp Step-by-Step
│   │       ├── videos/               <-- Video quay trực quan (.webm)
│   │       ├── traces/               <-- Playwright Trace (.zip)
│   │       └── results.json          <-- Kết quả JSON của TC
│   └── test-report.md                <-- BÁO CÁO MASTER TỔNG HỢP TOÀN BỘ DỰ ÁN
├── markdown-reporter.js              <-- Bộ xuất báo cáo phân cấp chuyên nghiệp
├── playwright.config.js              <-- Cấu hình Playwright tối ưu cho Live Visual
├── visual_cursor.js                  <-- Script con trỏ chuột Neon phát sáng
├── test.env.json                     <-- Cấu hình URL & tài khoản mục tiêu
├── Run-ParadiseHR-Interactive.bat    <-- Menu 1-Click ngoài Desktop
├── package.json                      <-- Khai báo dependencies & npm scripts
└── README.md                         <-- Tài liệu hướng dẫn sử dụng
```

---

## 🛠️ HƯỚNG DẪN CÀI ĐẶT & BẮT ĐẦU NHANH (QUICK START)

### 1. Clone repository về máy:
```bash
git clone https://github.com/ThachY-23120411/automation-test.git
cd automation-test
```

### 2. Cài đặt thư viện dependencies:
```bash
npm install
```

### 3. Cài đặt trình duyệt Google Chrome cho Playwright (nếu chưa có):
```bash
npx playwright install chrome
```

### 4. Cấu hình môi trường mục tiêu (`test.env.json`):
Chỉnh sửa file `test.env.json` trỏ tới website bạn muốn test:
```json
{
  "baseUrl": "https://your-website.com/#",
  "auth": {
    "username": "your_account",
    "password": "your_password",
    "usernameSelector": "#username",
    "passwordSelector": "input[type=\"password\"]",
    "submitSelector": "#submitLogin"
  }
}
```

---

## 🎮 CÁCH CHẠY KIỂM THỬ

### Cách 1: Sử dụng Menu 1-Click Tương Tác (Khuyên Dùng)
Nhấp đúp file **`Run-ParadiseHR-Interactive.bat`**:
* Menu cấp 1 sẽ liệt kê toàn bộ các trang đang có trong `tests/`.
* Menu cấp 2 cho phép bạn chọn chạy toàn bộ trang hoặc chọn đích danh một kịch bản `TC-0x`.

### Cách 2: Chạy trực tiếp từ dòng lệnh (CLI)
```bash
# Chạy trực quan hiển thị Chrome với chuột Neon (1 Worker quan sát chậm)
npm run test

# Chạy headless ngầm trong nền (dành cho CI/CD)
npm run test:headless

# Chạy song song 10 cửa sổ Chrome cùng lúc (Regression siêu tốc)
npm run test:parallel

# Chạy riêng 1 file kịch bản
npx playwright test tests/employee_bank_approval.spec.js --headed --workers=1

# Chạy riêng 1 Test Case cụ thể (theo mã TC)
npx playwright test tests/employee_bank_approval.spec.js -g "TC-01" --headed --workers=1
```

---

## 📝 BỘ KHUNG MẪU CHUẨN VIẾT TEST CASE (GOLDEN CODE BLUEPRINT)

Khi tạo kịch bản mới trong `tests/<tên_trang>.spec.js`, áp dụng bộ khung mẫu 4 khối sau:

```javascript
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const PAGE_NAME = 'employee_bank_approval';

// Helper 1: Di chuyển chuột Neon mượt mà và click
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

// Helper 2: Chụp ảnh từng bước (Step-by-Step Evidence)
async function captureStep(page, testInfo, { tcId, step, desc, pageName = PAGE_NAME }) {
  const safeDesc = desc.replace(/đ/g, 'd').replace(/Đ/g, 'D').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, '-');
  const fileName = `${tcId}-step${String(step).padStart(2, '0')}-${safeDesc}.png`;
  const dir = path.resolve(__dirname, `../test-evidence/${pageName}/${tcId}/screenshots`);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const filePath = path.join(dir, fileName);
  await page.screenshot({ path: filePath, fullPage: false });
  await testInfo.attach(`Bước ${step}: ${desc}`, { path: filePath, contentType: 'image/png' });
}

test.use({ storageState: { cookies: [], origins: [] } });

test.describe('Kiểm thử Trang: Ví dụ chức năng', () => {
  test.beforeEach(async ({ context }) => {
    await context.clearCookies();
    const cursorScriptPath = path.resolve(__dirname, '../visual_cursor.js');
    if (fs.existsSync(cursorScriptPath)) {
      await context.addInitScript(fs.readFileSync(cursorScriptPath, 'utf8'));
    }
  });

  test('TC-01: Thao tác cập nhật và gửi yêu cầu', async ({ page }, testInfo) => {
    // Bước 1: Mở trang & Đăng nhập
    await page.goto('https://your-website.com/#');
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 1, desc: 'Đăng nhập thành công và mở trang chủ' });

    // Bước 2: Mở modal / chọn chức năng
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 2, desc: 'Mở màn hình thao tác' });

    // Bước 3: Điền form
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 3, desc: 'Nhập thông tin vào form' });

    // Bước 4: Di chuột lên nút Lưu
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 4, desc: 'Con trỏ chuột Neon di chuyển và bấm nút Lưu' });

    // Bước 5: Xác nhận kết quả
    await captureStep(page, testInfo, { tcId: 'TC-01', step: 5, desc: 'Hệ thống xác nhận thao tác thành công' });

    // Đánh giá Dual Status
    testInfo.annotations.push({
      type: 'business_status',
      description: 'PASS - Yêu cầu đã được lưu thành công trên hệ thống'
    });
  });
});
```

---

## 📊 MẪU BÁO CÁO NGHIỆM THU ĐẠT CHUẨN

Báo cáo Markdown sinh ra tại `test-evidence/<tên_trang>/test-report.md` tự động chứa:
* **Bảng đối chiếu kép**: Cột trạng thái kỹ thuật (Test) và trạng thái logic (Business Output).
* **Khối Phân tích nguyên nhân lỗi (Failure Analysis)**: Tự động trích xuất nếu có kịch bản bị `FAIL`.
* **Ảnh chụp Storyboard**: Đánh số từng bước kèm ảnh minh họa vị trí chuột Neon.
* **Video & Trace**: Link trực tiếp tới file `.webm` và file `.zip` phục vụ mổ xẻ lỗi.

---

## 📜 Giấy phép & Tác giả
* **Tác giả**: [ThachY-23120411](https://github.com/ThachY-23120411)
* **License**: MIT
