---
name: fix-report
description: >-
  Tự động biên soạn báo cáo kỹ thuật phân tích lỗi fix-report.md hợp nhất cấp menu: fix-bug/<tên_menu>/fix-report.md. Báo cáo chia làm 2 phần lớn: Phần 1 (Automation Test Cases - TC) và Phần 2 (Manual Screenshot Bugs từ Screenshots_1_bug). Format của từng mục trong cả 2 phần là Y CHANG NHAU, tuân thủ nghiêm ngặt chuẩn 4 mục: 1. Hiện trạng ban đầu (Before Fix), 2. RCA Câu 28 (HTML/<style>/5 phân khu <script>), 3. Đối chiếu Before vs After (Diff SQL), 4. Minh chứng sau khi sửa (After Fix).
---

# KỸ NĂNG: BIÊN SOẠN BÁO CÁO KỸ THUẬT FIX BUG CHUẨN CẤP MENU (`fix-report.md`)

> **NGUYÊN LÝ CỐT LÕI**: Một Stored Procedure đại diện cho toàn bộ một màn hình/trang. Do đó, **bỏ hẳn cấu trúc chia nhỏ thư mục riêng biệt**. Toàn bộ báo cáo kỹ thuật của trang được gom vào **duy nhất 1 file `fix-report.md` cấp Menu**, đồng thời mã sửa lỗi của cả TC và Screenshot được tích hợp vào **1 file `fix-bug.sql` duy nhất**:

```text
fix-bug/<tên_menu>/
├── origin.sql          # Mã nguồn gốc trích xuất từ DB trước khi sửa (xài chung cho toàn trang)
├── fix-bug.sql         # Mã nguồn bản vá Stored Procedure chuẩn 3 bước Clean Code (tích lũy tất cả bản sửa của cả TC và Screenshot)
├── fix-report.md       # Báo cáo kỹ thuật tổng hợp duy nhất cho trang (chia làm 2 Phần: TC & Screenshot)
└── screenshot/         # Thư mục lưu trữ hình ảnh minh chứng before/after của cả 2 loại
    ├── TC-01-before.png
    ├── TC-01-after.png
    ├── screenshot-25-before.png  # (Lấy từ Screenshots_1_bug/ sang làm minh chứng Before)
    └── screenshot-25-after.png   # (Ảnh chụp thực tế sau khi fix)
```

---

## 🛑 5 NGUYÊN TẮC CỐT LÕI BẮT BUỘC

1. **PHÂN ĐỊNH RÕ 2 NGUỒN BUG TRONG 1 BÁO CÁO DUY NHẤT (KHÔNG BẮT BUỘC CẢ 2 PHẦN ĐỀU CÓ NỘI DUNG)**:
   - **Loại 1 (Automation Test)**: Dò ra qua test tự động (`test-evidence/`), định danh theo mã TC (`TC-01`, `TC-02`...).
   - **Loại 2 (Manual Test)**: Người dùng dò thủ công và lưu trong `Screenshots_1_bug/`, định danh theo Screenshot (`Screenshot 25`, `Screenshot 26`...).
   - **QUY TẮC BẤT BIẾN — TUYỆT ĐỐI CẤM BỊA ĐẶT NỘI DUNG**:
     * Báo cáo **không bắt buộc cả 2 phần đều phải có nội dung**.
     * Nếu menu chưa chạy Playwright automation test (hoặc người dùng chỉ yêu cầu sửa Screenshot): **Phần 1 BẮT BUỘC ĐỂ TRỐNG** (ghi chú: `*(Chưa có kịch bản kiểm thử tự động / Không có lỗi ghi nhận)*`), **TUYỆT ĐỐI KHÔNG TỰ BỊA ĐẶT TEST CASE HAY LỖI GIẢ ĐỂ NHỒI VÀO PHẦN 1**!
     * Ngược lại, nếu chỉ sửa lỗi TC từ automation test thì Phần 2 để trống.
     * Cả 2 loại khi có thì được trình bày trong 2 Phần riêng biệt của file `fix-report.md`, và mã sửa gom chung vào `fix-bug.sql`.

2. **ĐƯỜNG DẪN ẢNH TƯƠNG ĐỐI 100% (PORTABLE)**:
   - Toàn bộ ảnh chụp lỗi ban đầu và sau khi fix phải nằm trong thư mục `screenshot/` cạnh `fix-report.md`.
   - Cú pháp nhúng ảnh bắt buộc là đường dẫn tương đối:
     * Cho TC: `![Hiện trạng lỗi ban đầu](screenshot/TC-xx-before.png)` -> `![Minh chứng kết quả](screenshot/TC-xx-after.png)`
     * Cho Screenshot: `![Hiện trạng lỗi ban đầu](screenshot/screenshot-xx-before.png)` -> `![Minh chứng kết quả](screenshot/screenshot-xx-after.png)`
   - Tuyệt đối không dùng đường dẫn tuyệt đối `C:\...` hay link mạng để tránh bị vỡ ảnh khi di chuyển thư mục.

3. **CHUẨN PHÂN TÍCH PHÂN KHU THEO CÂU 28 (`HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md`)**:
   - Khi mổ xẻ từng đoạn code bị lỗi trong từng mục, **bắt buộc xác định rõ**:
     * Đoạn code đó nằm ở thẻ nào: HTML tĩnh? `<style>`? Hay `<script>`?
     * Nếu nằm trong `<script>`, **bắt buộc chỉ rõ thuộc phân khu nào trong 5 phân khu chuẩn**:
       - `1️⃣ Phân khu 1: Khai báo Biến & Trạng thái (Variables & States)`
       - `2️⃣ Phân khu 2: Khởi tạo Widget giao diện (Widget Initialization)`
       - `3️⃣ Phân khu 3: Khai báo & Định nghĩa Hàm nghiệp vụ (Function Definitions)`
       - `4️⃣ Phân khu 4: Đăng ký Sự kiện người dùng (Event Listeners Binding)`
       - `5️⃣ Phân khu 5: Thực thi Khởi động (Bootstrap / Trigger Execution)`
     * Giải thích chi tiết: **Bạn sửa nó như thế nào? Tại sao phải sửa như vậy?** (Cơ chế V8 Engine, DOM reactivity, bảo vệ dữ liệu).

4. **QUY TRÌNH 3 BƯỚC SẠCH SẼ TRONG `fix-bug.sql` (CLEAN CODE - KHÔNG DÙNG REPLACE)**:
   - Bản vá `fix-bug.sql` duy nhất của trang chỉ gồm 3 bước:
     * Bước 1: `ALTER PROCEDURE [dbo].[sp_<Tên_SP>_html]` (sửa toàn bộ code giao diện đã tích lũy tất cả các TC và Screenshot).
     * Bước 2: `ALTER PROCEDURE [dbo].[sp_<Tên_SP>]` (chuẩn hóa SP điều phối đọc từ `tblHtmlScriptCache`).
     * Bước 3: `EXEC sp_GenerateHTMLScript_new 'sp_<Tên_SP>_html', 'VN', 'sp_<Tên_SP>'` (tự động biên dịch và cập nhật version cache).
   - Nghiêm cấm dùng các câu lệnh `UPDATE tblHtmlScriptCache SET html = REPLACE(...)` chắp vá.

5. **QUY CHUẨN CHỤP ẢNH MINH CHỨNG AFTER FIX — CHỈ CHỤP KHI NGƯỜI DÙNG XÁC NHẬN ĐÃ EXEC**:
   - **Giai đoạn vừa tạo bản vá (Chưa exec)**: Agent **TUYỆT ĐỐI KHÔNG ĐƯỢC PHÉP** tạo ảnh `after.png`, không can thiệp browser runtime để chụp ảnh mô phỏng rồi nhét vào báo cáo. Lúc này, Mục 4 của `fix-report.md` bắt buộc ghi: `*(Đang chờ Người Dùng Execute file fix-bug.sql trên SSMS và xác nhận cập nhật)*`.
   - **Điều kiện mở Playwright chụp ảnh**: **CHỈ KHI NÀO** Người Dùng nhắn tin xác nhận: *"Đã exec"*, *"Đã chạy xong"*, *"Đã cập nhật DB"*, Agent mới mở Playwright Chrome thật, truy cập web thật (`https://paradisehrm.com/Tai3/#`), chụp ảnh thực tế và cập nhật vào Mục 4 của `fix-report.md`.
   - Cam kết trung thực tuyệt đối: Không bịa đặt hoặc dùng ảnh giả lập trước khi Người Dùng thực sự bấm chạy trên SSMS.

---

## 📋 CẤU TRÚC CHUẨN 2 PHẦN TRONG `fix-report.md`

File `fix-report.md` được cấu trúc thành 2 Phần rõ rệt. **Format của từng mục trong cả 2 phần là Y CHANG NHAU**:

```markdown
# BÁO CÁO KỸ THUẬT TỔNG HỢP FIX BUG: <TÊN_MENU>

> **Màn hình**: <Tên menu> (MenuID: <Mã menu>)  
> **Cơ sở dữ liệu**: Vietinsoft_ForTest_Tai2 (Web /Tai3/#)  
> **Các Test Case tự động đã xử lý**: TC-01, TC-02...  
> **Các Screenshot lỗi thủ công đã xử lý**: Screenshot 25, Screenshot 26...  

---

# PHẦN 1: CÁC LỖI DÒ QUA KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST CASES)

## [TC-01]: <Tiêu đề Test Case 1>

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)
- **Mô tả triệu chứng**: Sai khác giữa Expected và Actual.
- **Bảng đối soát**: Thuộc tính / Số liệu thực tế vs kỳ vọng.
- **Minh chứng ảnh**:
  ![Hiện trạng lỗi ban đầu TC-01](screenshot/TC-01-before.png)

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
- Phân tích chuẩn Câu 28: HTML / <style> / 5 phân khu <script>.
- Bạn sửa như thế nào? Tại sao phải sửa như vậy?
- Sơ đồ Mermaid luồng lỗi.

### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)
- Diff `origin.sql` vs `fix-bug.sql`.
- Bảng giải thích chi tiết What Changed.

### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)
- Đánh giá giao diện và bảng kiểm tra.
- *(Lưu ý: Chỉ mở Playwright chụp ảnh sau khi Người Dùng chat xác nhận đã exec trên DB. Lúc chưa exec thì ghi: `*(Đang chờ Người Dùng Execute file fix-bug.sql trên SSMS và xác nhận cập nhật)*`)*
- **Minh chứng ảnh sau khi sửa**:
  ![Minh chứng kết quả sau khi sửa TC-01](screenshot/TC-01-after.png)

---

# PHẦN 2: CÁC LỖI DÒ QUA TEST THỦ CÔNG (MANUAL SCREENSHOT BUGS)

## [Screenshot 25]: <Tiêu đề lỗi theo Screenshot 25 trong Screenshots_1_bug>

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)
- **Mô tả triệu chứng**: Lỗi phát hiện qua ảnh chụp thủ công.
- **Bảng đối soát**: Hiện trạng quan sát được trên màn hình.
- **Minh chứng ảnh gốc** (sao chép từ `Screenshots_1_bug/`):
  ![Hiện trạng lỗi ban đầu Screenshot 25](screenshot/screenshot-25-before.png)

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
- Phân tích chuẩn Câu 28: HTML / <style> / 5 phân khu <script>.
- Bạn sửa như thế nào? Tại sao phải sửa như vậy?
- Sơ đồ Mermaid luồng lỗi.

### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)
- Diff `origin.sql` vs `fix-bug.sql`.
- Bảng giải thích chi tiết What Changed.

### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)
- Đánh giá giao diện sau khi nạp bản vá `fix-bug.sql`.
- *(Lưu ý: Chỉ mở Playwright chụp ảnh sau khi Người Dùng chat xác nhận đã exec trên DB. Lúc chưa exec thì ghi: `*(Đang chờ Người Dùng Execute file fix-bug.sql trên SSMS và xác nhận cập nhật)*`)*
- **Minh chứng ảnh sau khi sửa**:
  ![Minh chứng kết quả sau khi sửa Screenshot 25](screenshot/screenshot-25-after.png)
```
