# KIẾN TRÚC CHUYÊN SÂU: GIAO THỨC CDP, ĐIỀU KIỆN TIÊN QUYẾT & LUỒNG HOẠT ĐỘNG PLAYWRIGHT
*(Tài liệu giải phẫu kỹ thuật dành cho Kỹ sư Kiểm thử và AI Agent muốn hiểu sâu bản chất)*

---

## 1. GIAO THỨC CDP (CHROME DEVTOOLS PROTOCOL) LÀ GÌ? ĐÓNG VAI TRÒ GÌ?

### 1.1. Bản chất của CDP là gì?
Khi bạn mở trình duyệt Google Chrome trên máy tính và bấm phím **F12** (hoặc chuột phải chọn *Inspect / Kiểm tra*), bạn sẽ thấy cửa sổ **Chrome DevTools** hiện ra với các tab: *Elements, Console, Network, Application, Performance...*

**Vậy làm sao cửa sổ F12 đó có thể nhìn thấy mọi thẻ HTML, biết được mạng đang tải gì, hoặc bắt được lỗi Console?**
👉 Chính là nhờ **CDP (Chrome DevTools Protocol)**!

* **Định nghĩa**: CDP là một **giao thức điều khiển từ xa bí mật** được Google xây dựng sẵn ngay bên trong nhân (core) của trình duyệt Chromium/Chrome.
* **Cơ chế truyền tin**: CDP sử dụng kết nối mạng socket siêu tốc (**WebSocket** hoặc **I/O Pipe** hai chiều) truyền các gói tin định dạng **JSON-RPC**.
* **Hình ảnh ẩn dụ**: Trình duyệt Chrome giống như một **chiếc xe đua**, còn CDP chính là **bộ thu nhận sóng điều khiển từ xa**. Ai kết nối được vào CDP thì có toàn quyền điều khiển chiếc xe đó mà không cần tài xế ngồi vào ghế lái!

---

### 1.2. CDP đóng vai trò gì trong Playwright?

Trước thời Playwright (thời Selenium WebDriver cũ), việc test web rất chậm và cồng kềnh vì phải đi qua một file trung gian gọi là `chromedriver.exe` bằng các request HTTP REST.

**Playwright tạo ra cuộc cách mạng vì nó kết nối TRỰC TIẾP vào CDP của Chrome qua Pipe:**

```
  ┌────────────────────────┐                   ┌────────────────────────┐
  │                        │   JSON-RPC qua    │                        │
  │  PLAYWRIGHT RUNNER     │ ────────────────> │  CHROME ENGINE (CDP)   │
  │  (Node.js Process)     │ <──────────────── │  (Browser Process)     │
  │                        │  Độ trễ micro-giây│                        │
  └────────────────────────┘                   └────────────────────────┘
```

#### Các quyền năng đặc biệt mà CDP trao cho Playwright:
1. **Mô phỏng chuột & phím ở tầng phần cứng**:
   - Khi bạn gọi `locator.click()`, Playwright gửi lệnh CDP: `Input.dispatchMouseEvent { type: "mousePressed", x: 500, y: 300, button: "left" }`.
   - Khi bạn gõ `pressSequentially()`, Playwright gửi lệnh CDP: `Input.dispatchKeyEvent { type: "rawKeyDown", key: "a", code: "KeyA" }`. Trình duyệt đối xử với lệnh này **y hệt như tín hiệu từ bàn phím USB vật lý cắm vào máy tính**!
2. **Soi chiếu trực tiếp cây DOM & Bộ nhớ**:
   - Lệnh CDP `DOM.querySelector` lấy tọa độ chính xác của nút bấm (Bounding Box) trên màn hình để tính đường đi cho con trỏ chuột.
3. **Chặn bắt và kiểm soát gói mạng (Network Interception)**:
   - Các lệnh CDP `Network.requestWillBeSent`, `Network.responseReceived` giúp Playwright biết chính xác khi nào API backend đã tải xong để tự động chờ (`auto-wait`), triệt tiêu hoàn toàn lỗi văng do mạng chậm.
4. **Quay video và chụp ảnh màn hình ở tầng GPU**:
   - Lệnh CDP `Page.startScreencast` và `Page.captureScreenshot` ra lệnh cho GPU của Chrome chụp từng khung hình nhị phân (PNG/WebM) với tốc độ 60fps để ghi lại toàn bộ video test.
5. **Lắng nghe Console & Bắt lỗi sập trang (Crash)**:
   - Mọi lỗi đỏ trong Console hoặc lỗi vỡ mạng đều được CDP đẩy ngược về Node.js qua sự kiện `Runtime.consoleAPICalled` và `Runtime.exceptionThrown`.

---

## 2. ĐIỀU KIỆN TIÊN QUYẾT ĐỂ CẤU HÌNH ĐƯỢC HỆ THỐNG PLAYWRIGHT NHƯ HIỆN TẠI

Để một máy PC bất kỳ có thể chạy được hệ thống Playwright trực quan (mở Chrome thật, có chuột Neon, quay video, xuất Markdown), máy đó bắt buộc phải thỏa mãn **6 điều kiện tiên quyết** sau:

| STT | Điều kiện tiên quyết | Yêu cầu kỹ thuật chi tiết |
| :---: | :--- | :--- |
| **1** | **Hệ điều hành có GUI Desktop** | Windows 10 hoặc Windows 11 (có màn hình hiển thị đồ họa tương tác `WinSta0\Default`). |
| **2** | **JavaScript Runtime (Node.js)** | Node.js phiên bản **LTS v18, v20 hoặc v22+** kèm trình quản lý gói `npm`/`npx`. Kiểm tra bằng lệnh: `node -v` và `npm -v`. |
| **3** | **Trình duyệt Google Chrome thật** | Bản cài đặt chính thức của Google Chrome tại đường dẫn chuẩn: `C:\Program Files\Google\Chrome\Application\chrome.exe` (hoặc `C:\Program Files (x86)\...`). |
| **4** | **Quyền tương tác Desktop Shell** | Lệnh chạy test phải được kích hoạt từ **Desktop tương tác thật** (thông qua file `.bat` nhấp đúp từ `explorer.exe`). Tuyệt đối không chạy đơn độc trong background service vì sẽ bị rơi vào Desktop ảo ngầm (`exebox`). |
| **5** | **Các thư viện NPM cốt lõi** | Phải cài đặt 2 gói thư viện: `@playwright/test` và `playwright` (`npm install -D @playwright/test playwright`). |
| **6** | **3 File thành phần cấu trúc** | • `playwright.config.js`: Cấu hình `headless: false`, `slowMo: 400`, `channel: 'chrome'`.<br>• `visual_cursor.js`: Script nhúng con trỏ chuột Neon & Ripple.<br>• `markdown-reporter.js`: Bộ gom video, ảnh chụp và xuất báo cáo Markdown. |

---

## 3. LUỒNG HOẠT ĐỘNG CHI TIẾT TỪ A $\rightarrow$ Z (END-TO-END FLOW)

Dưới đây là sơ đồ dòng đời (Life Cycle) của một lượt chạy kiểm thử từ lúc bạn nhấn nút cho đến khi ra file báo cáo:

```
[NGƯỜI DÙNG]
    │  1. Nhấp đúp Run-ParadiseHR-Live.bat
    ▼
[EXPLORER.EXE] (Session 1: WinSta0\Default)
    │  2. Mở cửa sổ Command Prompt trên màn hình thật
    ▼
[CMD / NPX PLAYWRIGHT TEST]
    │  3. Node.js khởi động, đọc playwright.config.js
    │  4. markdown-reporter.js tạo thư mục test-evidence/
    ▼
[KHỞI TẠO BROWSER QUA CDP]
    │  5. Playwright kết nối pipe CDP tới Chrome.exe
    │  6. Cửa sổ Google Chrome thật bật to trên màn hình
    │  7. Bật chế độ quay video (Screencast) & ghi trace
    ▼
[NHÚNG CON TRỎ NEON]
    │  8. context.addInitScript nhúng visual_cursor.js
    │  9. Con trỏ chuột Neon xuất hiện trên z-index cao nhất
    ▼
[THỰC THI KỊCH BẢN (tests/*.spec.js)]
    │  10. page.goto('https://paradisehrm.com/Tai3/#') -> Tải DOM 1.4MB
    │  11. userInput.pressSequentially('Chien.nguyen') -> Gõ phím chậm 150ms
    │  12. passInput.pressSequentially('123') -> Gõ mật khẩu chậm 150ms
    │  13. loginBtn.click() -> Di chuột, tạo hiệu ứng ripple, bấm Đăng nhập
    ▼
[ĐỐI CHIẾU TRỌNG TÀI (ASSERTION)]
    │  14. expect(isAppLoaded).toBeTruthy()
    │  15. CDP chụp ảnh màn hình lưu: test-evidence/screenshots/*.png
    ▼
[ĐÓNG GÓI BẰNG CHỨNG & BÁO CÁO]
    │  16. Đóng trình duyệt -> Lưu file video: test-evidence/videos/*.webm
    │  17. Lưu file trace: test-evidence/traces/*.zip
    │  18. markdown-reporter.js tổng hợp dữ liệu, ghi: test-evidence/test-report.md
    ▼
[KẾT QUẢ HIỂN THỊ TRÊN MÀN HÌNH BẠN]
```

---

### Giải thích chi tiết từng nhịp vận hành:

#### 🔹 Nhịp 1: Khởi động không gian tương tác (Desktop Handshake)
- Bạn nhấp đúp file `.bat`. `explorer.exe` (tiến trình quản lý giao diện Desktop của Windows) nhận lệnh và tạo ra một cửa sổ `cmd.exe` trực tiếp trên **Desktop Station `WinSta0\Default`**.
- Điều này đảm bảo toàn bộ các cửa sổ con do `cmd.exe` sinh ra (Google Chrome) sẽ **hiển thị 100% trước mắt bạn**, tránh hoàn toàn bẫy Desktop ảo ngầm của Agent.

#### 🔹 Nhịp 2: Nạp cấu hình & Đặt bộ giám sát (Reporter Init)
- Node.js nạp file `playwright.config.js`.
- `markdown-reporter.js` lắng nghe sự kiện `onBegin()`. Nó tự động dọn dẹp và tạo mới các thư mục con trong `test-evidence/`:
  - `screenshots/`
  - `videos/`
  - `traces/`

#### 🔹 Nhịp 3: Bắt tay qua CDP & Bật máy quay phim (Browser Launch)
- Playwright gửi lệnh hệ thống khởi chạy `chrome.exe` với tham số kết nối pipe CDP.
- Ngay khi Chrome mở ra, Playwright gửi tín hiệu CDP ra lệnh:
  > *"Bắt đầu quay phim màn hình từ giây này cho đến khi test xong!"* (`Page.startScreencast`).

#### 🔹 Nhịp 4: Nhúng "linh hồn" con trỏ chuột ảo (InitScript Injection)
- Hàm `context.addInitScript()` can thiệp vào giai đoạn sơ khai của trang web (trước khi bất kỳ đoạn mã HTML/JS nào của web chạy).
- Nó nhúng đoạn mã `visual_cursor.js` vào DOM. Một thẻ `<div id="__ag_cursor__">` hình mũi tên màu hồng Neon nổi lên với `z-index = 2147483647` (nằm đè lên trên mọi nút bấm và hình ảnh).

#### 🔹 Nhịp 5: Di chuyển mượt mà & Gõ phím từng ký tự (Human Simulation)
- Playwright tính toán tọa độ $X, Y$ của ô `username` trên màn hình.
- Playwright gửi chuỗi lệnh CDP di chuyển con trỏ chuột từ tọa độ cũ đến tọa độ mới qua nhiều bước nhỏ (steps) kết hợp `slowMo: 400ms`.
- Con trỏ Neon trượt mượt mà trên màn hình.
- Khi click, hàm tạo ra thẻ `__ag_ripple__` bung hiệu ứng sóng gợn hình tròn màu hồng.
- Khi gõ phím, `pressSequentially()` phát tín hiệu bàn phím cách nhau 150ms. Mắt bạn nhìn thấy từng chữ `C - h - i - e - n - . - n - g - u - y - e - n` lần lượt nhảy vào ô nhập liệu.

#### 🔹 Nhịp 6: Phán quyết kết quả (Assertion & Evidence Capture)
- Khi nút Đăng nhập được bấm, trình duyệt gửi dữ liệu về máy chủ Paradise HRM.
- Sau khi giao diện bảng điều khiển nạp xong, câu lệnh `expect(isAppLoaded).toBeTruthy()` kiểm tra:
  - Nếu đúng có bảng điều khiển $\rightarrow$ Ghi nhận ca test **✅ PASS**.
  - Nếu sau timeout mà vẫn ở trang đăng nhập $\rightarrow$ Ghi nhận ca test **❌ FAIL**.
- Lệnh CDP `Page.captureScreenshot` lưu lại ảnh chụp màn hình hoàn chỉnh làm bằng chứng đối chiếu.

#### 🔹 Nhịp 7: Xuất xưởng Báo cáo Markdown & Bàn giao
- Khi test kết thúc, Chrome đóng lại. Luồng video được lưu thành file `.webm`.
- `markdown-reporter.js` thu gom toàn bộ:
  1. Thời gian bắt đầu, kết thúc, tổng thời lượng.
  2. Đường dẫn đến video quay được.
  3. Đường dẫn đến ảnh chụp màn hình.
  4. File trace debug `.zip`.
- Ghi toàn bộ vào file [`test-evidence/test-report.md`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/test-evidence/test-report.md).
- File báo cáo tự động bật mở lên màn hình để bạn nghiệm thu ngay lập tức!
