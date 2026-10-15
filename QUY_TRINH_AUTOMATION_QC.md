# SỔ TAY QUY TRÌNH KIỂM THỬ TỰ ĐỘNG CHUYÊN NGHIỆP
## (AUTOMATION QC PLAYBOOK — PLAYWRIGHT FRAMEWORK)

> **Mục tiêu**: Hướng dẫn toàn diện từ A - Z quy trình vận hành hệ thống kiểm thử tự động: Máy tự thao tác, mở trình duyệt thật, chạy song song nhiều màn hình, tự quay video, chụp ảnh bằng chứng, bấm 1 nút chạy lại toàn bộ kịch bản và xuất báo cáo Markdown chuẩn mực.

---

## PHẦN 1: BẢN CHẤT CỦA AUTOMATION TEST & VAI TRÒ AUTOMATION QC

### 1. Automation Test là gì?
Kiểm thử tự động (**Automation Testing**) là phương pháp sử dụng mã lệnh (code) để điều khiển một chương trình "robot" (như Playwright Test Runner) tự động thực hiện các thao tác thay thế hoàn toàn bàn tay con người: mở website, di chuột, gõ phím, click nút, cuộn trang, và tự đối chiếu kết quả thực tế với kỳ vọng để chấm điểm **PASS** hoặc **FAIL**.

### 2. So sánh Manual QC vs. Automation QC

| Tiêu chí | Manual QC (Thủ công) | Automation QC (Tự động) |
| :--- | :--- | :--- |
| **Cách thức** | Dùng chuột và bàn phím bấm từng bước bằng tay. | **Viết mã lệnh (JavaScript/TypeScript)** để máy tự động thực thi. |
| **Tốc độ thực hiện** | Test 100 màn hình mất **2 - 3 ngày**. | Test 100 màn hình song song mất **5 - 10 phút**. |
| **Độ chính xác** | Dễ nhầm lẫn, bỏ sót khi mệt mỏi hoặc lặp đi lặp lại. | **Chính xác 100%**, lặp lại 1.000 lần y hệt nhau không mỏi mệt. |
| **Test hồi quy (Regression)** | Cực kỳ tốn công mỗi khi Dev sửa code hoặc ra tính năng mới. | **Chỉ cần bấm 1 nút Run**, toàn bộ kịch bản cũ và mới tự động chạy lại. |
| **Bằng chứng kiểm thử** | Tự chụp ảnh thủ công, dán vào file Word/Excel. | **Tự động lưu Video**, ảnh chụp màn hình và xuất báo cáo Markdown. |

### 3. Bản chất kỹ thuật: Node.js (Runtime) vs Playwright Test (Thư viện) vs npx

Rất nhiều người nhầm lẫn giữa Node.js và Playwright. Dưới đây là bức tranh kiến trúc chuẩn xác:

#### A. Node.js là gì?
- **Node.js là một JavaScript Runtime** (Môi trường thực thi mã JavaScript ngoài trình duyệt).
- Trong từ điển cốt lõi của Node.js **hoàn toàn không có các hàm như `test()`, `expect()`, `page.click()`**. Nếu bạn tạo 1 file `.js` và viết trực tiếp `test(...)` rồi gõ lệnh `node file.js`, Node.js sẽ báo lỗi ngay: `ReferenceError: test is not defined`.

#### B. Playwright Test Runner (`@playwright/test`) là gì?
- **Là một bộ thư viện kiểm thử chuyên biệt** được cài đặt vào `node_modules`.
- Nó cung cấp cho Node.js các "vũ khí" kiểm thử:
  - Cung cấp cú pháp `test()` để khai báo ca kiểm thử.
  - Cung cấp `expect()` làm trọng tài so sánh kết quả.
  - Cung cấp API điều khiển trình duyệt: mở trang, di chuột, gõ phím, chụp ảnh, quay video.
- Vì thế, ở ngay dòng số 1 trong mọi file test luôn có câu lệnh "nhờ vả" thư viện:
  ```javascript
  const { test, expect } = require('@playwright/test');
  ```
  Nhờ dòng này, Node.js mới hiểu được `test` và `expect` là gì!

#### C. Phân biệt `node` vs `npm` vs `npx`:
- **`node`**: Chạy 1 file code JavaScript đơn lẻ (ví dụ `node script.js`).
- **`npm`** *(Node Package Manager)*: Người đi chợ, dùng để tải và cài đặt các thư viện về máy (ví dụ `npm install @playwright/test`).
- **`npx`** *(Node Package eXecute)*: Bộ kích hoạt chương trình của thư viện nằm trong `node_modules/.bin/`.
  $\rightarrow$ Lệnh `npx playwright test` thực chất là bạn nói với hệ thống:
  > *"Node.js ơi, hãy nạp chương trình điều hành của Playwright Test Runner lên, rồi dùng nó để đọc, điều khiển trình duyệt và chấm điểm toàn bộ các file test trong thư mục `tests/`!"*

#### D. Sơ đồ 3 tầng kiến trúc vận hành:
```
  TẦNG 1: Mã kịch bản
  ┌────────────────────────────────────────────────────────┐
  │ File kịch bản của bạn: tests/*.spec.js                 │
  │ (Khai báo require('@playwright/test'), test, expect)   │
  └───────────────────────────┬────────────────────────────┘
                              │
                              ▼
  TẦNG 2: Runtime điều khiển (Engine)
  ┌────────────────────────────────────────────────────────┐
  │ 🟢 NODE.JS RUNTIME + PLAYWRIGHT TEST RUNNER            │
  │ • Node.js đọc và chạy các dòng lệnh JS.                │
  │ • Playwright Test Runner chia workers song song,       │
  │   chấm điểm assertion, ghi video và gửi tín hiệu CDP.   │
  └───────────────────────────┬────────────────────────────┘
                              │ (Giao thức Chrome DevTools Protocol - CDP)
                              ▼
  TẦNG 3: Trình duyệt hiển thị
  ┌────────────────────────────────────────────────────────┐
  │ 🌐 GOOGLE CHROME THẬT (Renderer)                       │
  │ • Nhận lệnh từ Node.js: Mở tab, di chuột, gõ phím.     │
  │ • Vẽ giao diện trước mắt bạn và xuất video bằng chứng. │
  └────────────────────────────────────────────────────────┘
```

---

## PHẦN 2: QUY TRÌNH 5 GIAI ĐOẠN CHUẨN HÓA

```
┌─────────────────────────┐
│ GIAI ĐOẠN 1             │ ──> Xác định Menu/Màn hình, liệt kê các ca kiểm thử
│ Phân tích Nghiệp vụ     │     (Happy Path, Negative Path, Filter/Search).
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│ GIAI ĐOẠN 2             │ ──> Lập trình các bước Action, chụp ảnh Evidence và
│ Viết Kịch bản Test      │     đặt trọng tài Assertion trong tests/<module>/*.spec.js.
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│ GIAI ĐOẠN 3             │ ──> Cấu hình fullyParallel: true, workers: 4 để máy
│ Chạy Song Song Đa Luồng │     mở nhiều trình duyệt test cùng một lúc.
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│ GIAI ĐOẠN 4             │ ──> Đóng gói file .bat ngoài màn hình, nhấp đúp là
│ Nút bấm 1-Click Run     │     toàn bộ hệ thống tự test từ A -> Z.
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│ GIAI ĐOẠN 5             │ ──> Đọc file test-report.md, xem lại video các case bị lỗi
│ Báo cáo & Xử lý Lỗi     │     để bàn giao Developer sửa chữa.
└─────────────────────────┘
```

---

### Giai đoạn 0: Cấu Hình Mục Tiêu Website & Tài Khoản (`test.env.json`)

Hệ thống có thể kiểm thử **bất kỳ trang web nào trên Internet** (từ ERP, HRM, SaaS, thương mại điện tử...):

#### 1. Lần đầu tiên test web mới:
Bạn chỉ cần cung cấp: **Link web** + **Tài khoản / Mật khẩu**.
- Agent sẽ tự động lưu vào file [`test.env.json`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/test.env.json):
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

#### 2. Tất cả các lần sau:
👉 **Bạn không cần nhập lại link hay mật khẩu nữa!**  
Chỉ cần gọi skill và nói tên menu muốn test (ví dụ: *"Test menu Bảng chấm công"*). Agent sẽ tự đọc cấu hình, mở đúng web, đăng nhập tự động và viết test cho bạn.

---

### Giai đoạn 1: Phân tích Màn hình & Thiết kế Test Cases
Trước khi viết mã, QC phân tích màn hình theo 3 nhóm trường hợp:
1. **Ca thành công (Happy Path)**: Nhập đúng dữ liệu hợp lệ $\rightarrow$ Hệ thống phản hồi thành công $\rightarrow$ Dữ liệu hiển thị lên bảng.
2. **Ca ngoại lệ / Bắt lỗi (Negative Path)**: Bỏ trống trường bắt buộc (*), nhập sai định dạng email/ngày tháng $\rightarrow$ Hệ thống phải hiện cảnh báo đỏ, chặn không cho lưu.
3. **Ca tìm kiếm / Lọc (Filter & Search)**: Nhập từ khóa $\rightarrow$ Bảng dữ liệu lọc chính xác danh sách tương ứng.

---

### Giai đoạn 2: Lập trình Kịch bản Kiểm thử (`tests/*.spec.js`)
Mỗi kịch bản test trong Playwright được cấu tạo bởi **3 thành phần cốt lõi**:
1. **ACTION (Hành động)**: Điều khiển chuột và bàn phím (`click`, `pressSequentially`).
2. **EVIDENCE (Bằng chứng)**: Chụp lại màn hình tại thời điểm then chốt (`screenshot`).
3. **ASSERTION (Trọng tài kiểm tra)**: Câu lệnh phán quyết PASS hay FAIL (`expect`).

#### Cấu trúc code mẫu chuẩn:
```javascript
// tests/human_resource/add_employee.spec.js
const { test, expect } = require('@playwright/test');

test('TC-01: Thêm mới nhân viên thành công', async ({ page }) => {
  // 1. ACTION: Mở trang và nhập liệu trực quan
  await page.goto('https://paradisehrm.com/Tai3/#');
  await page.locator('#btn-add').click();
  await page.locator('#employee-name').pressSequentially('Nguyễn Văn A', { delay: 120 });
  await page.locator('#employee-code').pressSequentially('NV001', { delay: 120 });
  await page.locator('#btn-save').click();

  // 2. EVIDENCE: Chụp ảnh bằng chứng ngay sau khi lưu
  await page.screenshot({ path: 'test-evidence/screenshots/TC-01-saved.png' });

  // 3. ASSERTION: Trọng tài đối chiếu kết quả mong đợi
  // Hệ thống phải có thông báo thành công hoặc tên xuất hiện trong danh sách
  await expect(page.locator('.toast-success')).toBeVisible();
  await expect(page.locator('.employee-grid')).toContainText('Nguyễn Văn A');
});
```

---

### Giai đoạn 2.1: Tái Sử Dụng Phiên Đăng Nhập (Authentication Reuse)

Một câu hỏi rất hay của mọi QC: *"Mỗi chức năng đều cần đăng nhập, vậy bài test nào cũng phải viết lại code đăng nhập từ đầu à?"*
👉 **HOÀN TOÀN KHÔNG CẦN!** Có 2 giải pháp tối ưu:

#### Cách 1 (Chuẩn mực Playwright): Dùng `storageState` (Đăng nhập 1 lần, dùng mãi mãi)
1. Viết 1 file đăng nhập duy nhất (`tests/auth.setup.js`): Sau khi đăng nhập thành công, lưu phiên làm việc ra file `auth.json`:
   ```javascript
   await page.context().storageState({ path: 'auth.json' });
   ```
2. Cấu hình `storageState: 'auth.json'` trong `playwright.config.js`.
3. Khi đó, **tất cả 100 test case sau này chỉ cần mở web là ĐÃ Ở TRẠNG THÁI ĐĂNG NHẬP SẴN**, nhảy thẳng vào menu chức năng để test mà không tốn thêm 1 giây nào cho trang login!

#### Cách 2 (Dễ xem Live Visual): Dùng Hook `beforeEach` + File trợ lý `helpers/auth.js`
1. Tạo file `helpers/auth.js` chứa hàm `loginAsAdmin(page)`.
2. Trong các file test, chỉ cần gọi đúng 1 dòng:
   ```javascript
   test.beforeEach(async ({ page }) => {
     await loginAsAdmin(page); // Tự động đăng nhập trước mỗi bài test
   });
   ```

---

### Giai đoạn 3: Cấu hình Chạy SONG SONG 10 CỬA SỔ CÙNG LÚC (Parallel 10 Workers)

Đây là "vũ khí tối thượng" của Automation QC: Thay vì phải ngồi đợi máy test từng màn hình một cách chậm chạp, Playwright có thể mở **10 cửa sổ Google Chrome cùng một lúc trên màn hình** để kiểm thử 10 chức năng song song!

#### 1. Cơ chế kỹ thuật bên dưới:
- **Tiến trình Worker độc lập**: Playwright khởi tạo 10 tiến trình Node.js con (Workers). Mỗi Worker kiểm soát một cửa sổ Chrome riêng biệt.
- **Không gian cô lập tuyệt đối (Isolated Browser Context)**: Mỗi cửa sổ Chrome chạy trên một luồng bộ nhớ độc lập, có cookies, session và localStorage riêng biệt. 10 cửa sổ có thể đăng nhập 10 tài khoản khác nhau hoặc cùng 1 tài khoản mà **hoàn toàn không bị đá văng (conflict session)**!
- **Tối ưu thời gian**: 
  - Test tuần tự 10 màn hình: Mất **10 - 15 phút**.
  - Test song song 10 cửa sổ: Chỉ mất **khoảng 40 - 60 giây**!

#### 2. Hai cách kích hoạt chạy song song 10 cửa sổ:

**Cách 1: Cấu hình cứng trong file `playwright.config.js`**:
```javascript
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',

  // BẬT: Cho phép tất cả các file test và test case chạy song song
  fullyParallel: true,

  // BẬT: Mở đúng 10 cửa sổ Chrome đồng thời trên màn hình
  workers: 10,

  use: {
    headless: false, // Bắt buộc mở cửa sổ hiển thị
    launchOptions: {
      slowMo: 300    // Độ trễ để quan sát cả 10 cửa sổ cùng gõ phím
    },
    screenshot: 'on',
    video: 'on',
    trace: 'on'
  }
});
```

**Cách 2: Ghi trực tiếp vào file Batch chạy 1-Click**:
```bat
call npx playwright test --headed --workers=10
```

> [!NOTE]
> Khi mở 10 cửa sổ Chrome cùng lúc, máy tính sẽ sử dụng khoảng 2GB - 4GB RAM và 10 luồng CPU. Các dòng máy chip Intel Core i5/i7/i9 hoặc AMD Ryzen hiện đại đều vận hành cực kỳ mượt mà!

---

### Giai đoạn 4: Cơ Chế "1-Click Bất Tử" (Dù Thay Đổi Kịch Bản Vẫn Chỉ Bấm 1 Nút)

Một trong những câu hỏi lớn nhất là: **"Nếu tôi thêm 5 kịch bản mới, hoặc sửa code của 3 kịch bản cũ, thì có phải viết lại file `.bat` không?"**
👉 **HOÀN TOÀN KHÔNG CẦN CHẠM VÀO FILE `.bat`!**

#### 1. Cơ chế Quét Động của Playwright (Dynamic Test Discovery):
Bên trong Playwright Runner có tích hợp sẵn thuật toán **Glob Pattern (`tests/**/*.spec.js`)**:
- Mỗi khi bạn bấm nút Run, Playwright sẽ **quét trực tiếp thư mục `tests/` tại thời điểm đó**:
  - Bạn **thêm 5 file `.spec.js` mới** $\rightarrow$ Playwright tự động phát hiện và nạp thêm 5 bài test mới vào hàng đợi.
  - Bạn **sửa nội dung bên trong file cũ** $\rightarrow$ Playwright tự động đọc nội dung vừa sửa để chạy logic mới.
  - Bạn **xóa 2 file cũ** $\rightarrow$ Playwright tự động loại bỏ khỏi danh sách chạy.
- **File `.bat` ngoài Desktop giữ nguyên 100% không cần chỉnh sửa bất kỳ dòng nào!**

#### 2. File Batch "1-Click Run" chuẩn hóa trên Desktop (`Run-10-Parallel-Live.bat`):
File này đã được tạo sẵn ngoài màn hình Desktop của bạn:

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

👉 **Quy trình làm việc hàng ngày của bạn**:
1. Bảo Agent viết thêm kịch bản mới $\rightarrow$ Agent lưu vào thư mục `tests/`.
2. Bạn chỉ cần **Double click vào file `Run-10-Parallel-Live.bat` ngoài Desktop**.
3. Cả 10 cửa sổ Chrome sẽ cùng lúc bật lên, tự chạy toàn bộ kịch bản từ A $\rightarrow$ Z, tự quay 10 video, chụp ảnh và tự bật file báo cáo tổng hợp Markdown trước mắt bạn!

---

### Giai đoạn 4.1: Bảng Điều Khiển Tương Tác Đa Năng (`Run-ParadiseHR-Interactive.bat`)

Nếu bạn **không muốn chạy toàn bộ**, mà muốn:
- Chọn riêng lẻ từng màn hình/menu từ `1` đến `N` để chạy 1 cửa sổ quan sát chi tiết.
- Hoặc chọn chế độ **Chạy song song** và tự chọn số lượng cửa sổ (ví dụ: 2, 4, 10 cửa sổ) cùng danh sách kịch bản tương ứng gán cho từng cửa sổ.

👉 **Hãy nhấp đúp vào file [`Run-ParadiseHR-Interactive.bat`](file:///C:/Users/Y.Thach/Desktop/Run-ParadiseHR-Interactive.bat) ngoài Desktop**:

```
================================================================================
          PARADISE HRM - BỘ ĐIỀU KHIỂN KIỂM THỬ E2E TRỰC QUAN
================================================================================
DANH SÁCH CÁC KỊCH BẢN TEST HIỆN CÓ TRONG tests/:
  [1] tests\dashboard_overview.spec.js -> Kiểm thử Bảng điều khiển (Dashboard)
  [2] tests\login.spec.js              -> Kiểm thử Đăng nhập Paradise HRM
  (Tự động cập nhật khi bạn thêm file test mới!)

--------------------------------------------------------------------------------
CÁC CHẾ ĐỘ THỰC THI:
  [1..N]  Chạy ĐƠN LẺ kịch bản tương ứng (1 cửa sổ xem chậm rãi, chuột Neon)
  [A]     Chạy TẤT CẢ kịch bản tuần tự (1 cửa sổ từ đầu đến cuối)
  [P]     Chạy SONG SONG (Parallel Multi-Windows) - Tùy chọn số lượng cửa sổ & kịch bản
  [R]     Mở xem Báo cáo kiểm thử gần nhất (test-evidence/test-report.md)
  [Q]     Thoát
--------------------------------------------------------------------------------
👉 Nhập lựa chọn của bạn:
```

* **Khi bạn chọn `[P]` (Song song)**:
  1. Hệ thống hỏi: *Bạn muốn mở bao nhiêu cửa sổ Chrome đồng thời? (1-10, mặc định: 2)*
  2. Hệ thống hỏi: *Chọn kịch bản muốn chạy: Bấm [Enter] để chạy tất cả, hoặc gõ danh sách số kịch bản (ví dụ: `1, 2`)*.
  3. Playwright sẽ khởi tạo đúng số lượng cửa sổ Chrome tương ứng trên màn hình, mỗi cửa sổ gánh một kịch bản test độc lập!

---

### Giai đoạn 5: Đọc Báo cáo Markdown & Xem Video Bằng chứng Theo Cấu Trúc Phân Cấp

Sau khi kết thúc lượt chạy, thư mục `test-evidence/` sẽ chứa bằng chứng được tổ chức chuẩn xác theo từng **Trang/Menu** và từng **Test Case (TC-0x)** tương ứng 1:1 với thư mục `tests/`:

```
test-evidence/
├── login/                             # Thư mục đại diện cho file tests/login.spec.js
│   ├── test-report.md                 # Báo cáo riêng của trang Login
│   ├── TC-01/                         # Kịch bản TC-01: Đăng nhập thành công
│   │   ├── screenshots/               # Ảnh chụp TC-01
│   │   ├── videos/                    # Video quay trực tiếp TC-01 (.webm)
│   │   ├── traces/                    # Playwright Trace TC-01 (.zip)
│   │   └── results.json               # Dữ liệu JSON của TC-01
│   └── TC-02/                         # Kịch bản TC-02: Đăng nhập thất bại khi sai mật khẩu
│       ├── screenshots/
│       ├── videos/
│       ├── traces/
│       └── results.json
├── dashboard_overview/                # Thư mục đại diện cho tests/dashboard_overview.spec.js
│   ├── test-report.md
│   └── TC-01/
│       ├── screenshots/
│       ├── videos/
│       ├── traces/
│       └── results.json
├── results.json                       # Master JSON tổng hợp
└── test-report.md                     # MASTER REPORT TỔNG THỂ DỰ ÁN
```

#### Mẫu nội dung trong `test-report.md` (Master Report):
```markdown
# BÁO CÁO KIỂM THỬ TỔNG HỢP E2E (MASTER TEST REPORT)
> Thời gian chạy: 14:21:23 15/10/2026
> Tổng số trang: 2 | Tổng số kịch bản: 3 | ✅ 100% PASS

## 1. TỔNG QUAN THEO TỪNG TRANG / MENU
| Trang / Menu | File Kịch Bản | Số Test Case | Trạng thái | Báo cáo chi tiết |
| :--- | :--- | :--- | :--- | :--- |
| **dashboard_overview** | `tests/dashboard_overview.spec.js` | 1 | ✅ 100% PASS | [Xem chi tiết](dashboard_overview/test-report.md) |
| **login** | `tests/login.spec.js` | 2 | ✅ 100% PASS | [Xem chi tiết](login/test-report.md) |

## 2. CHI TIẾT TẤT CẢ TEST CASES
### [login] TC-01: Đăng nhập thành công với tài khoản Chien.nguyen
- Kết quả: ✅ PASS (22.98s)
- Thư mục bằng chứng: `test-evidence/login/TC-01/`
  - Ảnh: ![Screenshot](login/TC-01/screenshots/test-finished-1.png)
  - Video: [Xem video](login/TC-01/videos/video.webm)
  - Trace: [traces](login/TC-01/traces/trace.zip)
```

---

## PHẦN 3: MÔ HÌNH PHỐI HỢP GIỮA BẠN VÀ AI AGENT

Bạn không cần phải tự ngồi gõ từng dòng code Playwright phức tạp. Mô hình phân chia công việc tối ưu nhất là:

| Công việc | Người thực hiện | Cách thức |
| :--- | :--- | :--- |
| **1. Định hướng & Đưa đề bài** | **BẠN (Trưởng nhóm QC)** | Chỉ cần nói bằng tiếng Việt: *"Hãy dùng skill `playwright-live-visual-e2e` test menu Thêm mới hợp đồng lao động, kiểm tra cả trường hợp bỏ trống ô lương"*. |
| **2. Phân tích DOM & Lập trình** | **AI AGENT** | Tự động mở web, dò tìm ID/class thẻ HTML, viết file `tests/*.spec.js`, cài đặt delay, con trỏ chuột Neon và assertions. |
| **3. Vận hành & Giám sát** | **BẠN** | Nhấn file `.bat`, ngồi nhìn Chrome tự động gõ phím, click chuột trên màn hình. |
| **4. Báo cáo & Bàn giao** | **HỆ THỐNG** | Tự động xuất video, ảnh chụp và file `test-report.md`. Bạn chỉ việc gửi link báo cáo cho sếp hoặc Developer. |

---

## PHẦN 4: TỔNG KẾT BỘ LỆNH QUẢN TRỊ TEST

| Lệnh | Ý nghĩa |
| :--- | :--- |
| `npx playwright test --headed` | Chạy toàn bộ test có hiển thị cửa sổ Chrome. |
| `npx playwright test tests/login.spec.js --headed` | Chỉ chạy riêng 1 kịch bản đăng nhập. |
| `npx playwright test --workers=4` | Chạy 4 luồng song song siêu tốc. |
| `npx playwright show-trace test-evidence/traces/trace.zip` | Mở công cụ xem lại từng mili-giây thao tác của trình duyệt. |
| `Double click Run-All-Regression.bat` | Bấm 1 nút chạy tự động toàn bộ từ A $\rightarrow$ Z trên Desktop. |
| `Double click Run-10-Parallel-Live.bat` | Bấm 1 nút mở ngay 10 cửa sổ Chrome test song song siêu tốc. |
| `Double click Run-ParadiseHR-Interactive.bat` | Mở menu tùy chọn: Chọn test màn hình 1..N hoặc chọn số cửa sổ song song. |
