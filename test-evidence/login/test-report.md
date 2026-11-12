# BÁO CÁO KIỂM THỬ TRANG: LOGIN

> Thời gian kiểm thử: **11:55:19 2/11/2026**
> Tổng số kịch bản: **2** | ✅ LOGIC PASS: **0** | ❌ LOGIC FAIL: **2**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | Đăng nhập thành công với tài khoản Chien.nguyen | ❌ FAIL | ❌ FAIL | Error: [2mexpect([22m[31mlocator[39m[2m).[22mtoBeVisible[2m([22m[2m)[22m failed

Locator: locator('#username')
Expected: visible
Timeout: 15000ms
Error: element(s) not found

Call log:
[2m  - Expect "toBeVisible" locator('#username') with timeout 15000ms[22m
[2m  - waiting for locator('#username')[22m
 |
| **TC-02** | TC-02: Đăng nhập thất bại khi nhập sai mật khẩu | ❌ FAIL | ❌ FAIL | — |

---

### TC-01: Đăng nhập thành công với tài khoản Chien.nguyen

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `23.61s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: Error: [2mexpect([22m[31mlocator[39m[2m).[22mtoBeVisible[2m([22m[2m)[22m failed

Locator: locator('#username')
Expected: visible
Timeout: 15000ms
Error: element(s) not found

Call log:
[2m  - Expect "toBeVisible" locator('#username') with timeout 15000ms[22m
[2m  - waiting for locator('#username')[22m

* **Thư mục lưu trữ**: `test-evidence/login/TC-01/`

> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)
>
> * **Vấn đề ghi nhận**: Error: [2mexpect([22m[31mlocator[39m[2m).[22mtoBeVisible[2m([22m[2m)[22m failed

Locator: locator('#username')
Expected: visible
Timeout: 15000ms
Error: element(s) not found

Call log:
[2m  - Expect "toBeVisible" locator('#username') with timeout 15000ms[22m
[2m  - waiting for locator('#username')[22m

> * **Kỳ vọng nghiệp vụ (Expected Output)**: Theo đặc tả chuẩn của hệ thống
> * **Thực tế hệ thống (Actual Output)**: Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra
>
> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.

> [!WARNING] Lỗi Kỹ Thuật (System/Playwright Error):
```
Error: [2mexpect([22m[31mlocator[39m[2m).[22mtoBeVisible[2m([22m[2m)[22m failed

Locator: locator('#username')
Expected: visible
Timeout: 15000ms
Error: element(s) not found

Call log:
[2m  - Expect "toBeVisible" locator('#username') with timeout 15000ms[22m
[2m  - waiting for locator('#username')[22m

```

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-01/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/login/TC-01/traces/trace.zip`)*

---

### TC-02: TC-02: Đăng nhập thất bại khi nhập sai mật khẩu

* **Trạng thái thực thi Test (Kỹ thuật)**: ❌ FAIL (Thời gian thực thi: `12.80s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ❌ FAIL
* **Đánh giá tổng quát**: undefined
* **Thư mục lưu trữ**: `test-evidence/login/TC-02/`

> [!WARNING] Lỗi Kỹ Thuật (System/Playwright Error):
```
Error: [2mexpect([22m[31mlocator[39m[2m).[22mtoBeVisible[2m([22m[2m)[22m failed

Locator: locator('#username')
Expected: visible
Error: element(s) not found

Call log:
[2m  - Expect "toBeVisible" locator('#username') with timeout 15000ms[22m
[2m  - waiting for locator('#username')[22m
[2m  - Target page, context or browser has been closed[22m

```

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

*(Không có ảnh chụp màn hình)*

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-02/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/login/TC-02/traces/trace.zip`)*

---

