---
name: fix-rules
description: >-
  Bộ quy chuẩn bất biến khi fix bug trong Paradise HRM: 1. Read-Only DB 100% (tuyệt đối không tự ý sửa/exec DB), 2. Trích xuất origin.sql từ DB trước khi sửa, 3. Đóng gói hợp nhất theo trang / menu (fix-bug/<tên_menu>/) chuẩn 3 bước Clean Code, 4. Ảnh After Fix CHỈ ĐƯỢC CHỤP khi Người Dùng xác nhận đã exec trên DB, 5. Ứng dụng Chrome DevTools MCP để điều tra RCA (CSS, Console, Network) và thử nghiệm hot-patch trực tiếp trên UI trước khi xuất SQL. Báo cáo fix-report.md chia làm 2 phần (Phần 1: TC, Phần 2: Screenshot), chuẩn 4 mục RCA Câu 28.
---

# BỘ QUY CHUẨN AN TOÀN & BÀN GIAO BẢN VÁ FIX BUG (PARADISE HRM)

> **MỤC ĐÍCH**: Đây là kỹ năng quy định bộ quy tắc bất biến bắt buộc AI Agent phải tuân thủ nghiêm ngặt 100% trong suốt quá trình rà soát, điều tra lỗi (RCA), viết bản vá và bàn giao kết quả cho bất kỳ Test Case hoặc bug giao diện nào trong dự án Paradise HRM.

---

## 🛑 ĐIỀU 1: CHẾ ĐỘ READ-ONLY NGHIÊM NGẶT — TUYỆT ĐỐI KHÔNG TỰ Ý SỬA HOẶC EXEC SP TRÊN DATABASE

1. **Chỉ đọc dữ liệu (Read-Only Mode 100%)**:
   - Agent **TUYỆT ĐỐI KHÔNG ĐƯỢC PHÉP** tự ý thực thi bất kỳ câu lệnh nào làm thay đổi dữ liệu, cấu trúc, schema hoặc mã nguồn trong Database:
     - `ALTER`, `DROP`, `CREATE`, `TRUNCATE`
     - `UPDATE`, `INSERT`, `DELETE`, `MERGE`
     - `EXEC` hoặc `EXECUTE` các Stored Procedure / Function có khả năng ghi dữ liệu, chỉnh sửa bảng hoặc thay đổi trạng thái hệ thống.
2. **Các lệnh truy vấn an toàn được phép sử dụng**:
   - Chỉ sử dụng các câu lệnh truy vấn đọc thông tin:
     - `SELECT ...`
     - `OBJECT_DEFINITION(OBJECT_ID('...'))`
     - `sys.sql_modules`, `sys.objects`, `sys.procedures`
     - `INFORMATION_SCHEMA`
     - `sp_helptext` (nếu chỉ dùng để đọc định nghĩa).
3. **Quyền thực thi thuộc về Người Dùng**:
   - Toàn bộ mã SQL sửa lỗi bắt buộc phải được xuất ra file để Người Dùng tự tay kiểm tra cú pháp (`Ctrl + F5`) và tự tay bấm chạy (`F5`) trên SQL Server Management Studio (SSMS).

---

## 📌 ĐIỀU 2: TRÍCH XUẤT MÃ NGUỒN GỐC (ORIGIN.SQL) TRƯỚC KHI SỬA BẤT KỲ BUG NÀO

1. **Bắt buộc đọc mã nguồn gốc từ Database trước**:
   - Trước khi bắt tay vào sửa bất kỳ bug nào, Agent phải truy vấn vào Database hiện tại để lấy nguyên bản 100% mã nguồn của Stored Procedure / Function liên quan.
2. **Tạo file `origin.sql`**:
   - Lưu nguyên văn mã nguồn vừa trích xuất thành file `origin.sql` nằm trực tiếp trong thư mục `fix-bug/<tên_menu>/`.
   - Giữ nguyên toàn bộ logic, format, chú thích gốc của hệ thống, không tự ý thêm bớt hay can thiệp.
3. **Mục đích phục vụ Đối chiếu (Compare / Diff)**:
   - File `origin.sql` là nguồn đối chứng chuẩn (Base Source of Truth) để Người Dùng và Sếp thực hiện Compare (`Before vs After`) với mã sửa mới, xem rõ chính xác những dòng nào đã được thay đổi và vì sao thay đổi.

---

## 📁 ĐIỀU 3: QUY CHUẨN ĐÓNG GÓI BÀN GIAO HỢP NHẤT THEO TRANG / MENU (`fix-bug/<tên_menu>/`)

> **NGUYÊN LÝ CỐT LÕI**: Một Stored Procedure (`sp_<Tên_SP>_html`) đại diện cho toàn bộ một màn hình/trang. Do đó, **tuyệt đối không chia nhỏ theo từng thư mục screenshot con và không chia thư mục riêng theo từng TC**. Mọi lỗi của trang đó đều được **gom về 1 thư mục duy nhất theo tên menu**.

### 1. Phân loại 2 nguồn lỗi trong hệ thống (Two Bug Sources):
Hệ thống tiếp nhận lỗi từ 2 nguồn chính:
- **Loại 1: Bug do kiểm thử tự động (Automation Test Bugs)**:
  * Được phát hiện thông qua bộ test tự động Playwright.
  * Bằng chứng kiểm thử nằm tại: `test-evidence/<tên_menu>/TC-xx/`.
  * Được định danh theo mã Test Case chuẩn: `TC-01`, `TC-02`, `TC-03`...
- **Loại 2: Bug do kiểm thử thủ công (Manual Screenshot Bugs)**:
  * Do người dùng trực tiếp thao tác, phát hiện lỗi vặt trên giao diện và chụp ảnh lại.
  * Ảnh chụp màn hình lỗi gốc được lưu tại: `C:\Users\Y.Thach\Desktop\paradiseHR\Screenshots_1_bug/` (ví dụ: `Screenshot 25`, `Screenshot 26`...).
  * Được định danh theo tên Screenshot tương ứng: `Screenshot 25`, `Screenshot 26`...

### 2. Nguyên tắc "Sửa chung vào 1 file duy nhất" (`fix-bug.sql`):
- Toàn bộ các lỗi của menu (dù phát sinh từ Automation Test Case hay từ Screenshot thủ công) đều **được tích hợp chung vào 1 file bản vá duy nhất**: `fix-bug/<tên_menu>/fix-bug.sql`.
- Tuyệt đối không tạo file SQL riêng rẽ cho từng TC hay từng Screenshot.
- Bản vá phải giải quyết triệt để và đồng thời cả lỗi của TC và lỗi của Screenshot, không làm phá vỡ logic cũ.

### 3. Cấu trúc thư mục bàn giao chuẩn cấp Menu:
```text
fix-bug/<tên_menu>/
├── origin.sql          # Mã nguồn Stored Procedure gốc trích xuất từ Database (xài chung cho toàn trang)
├── fix-bug.sql         # File bản vá Stored Procedure tổng hợp duy nhất cho trang (tích lũy tất cả bản sửa của cả TC và Screenshot)
├── fix-report.md       # Báo cáo kỹ thuật duy nhất chia làm 2 Phần: Phần 1 (TCs) và Phần 2 (Screenshots)
└── screenshot/         # Thư mục lưu trữ hình ảnh minh chứng before/after của cả 2 loại:
    ├── TC-01-before.png
    ├── TC-01-after.png
    ├── TC-02-before.png
    ├── TC-02-after.png
    ├── screenshot-25-before.png  # (Lấy từ Screenshots_1_bug/ sang làm minh chứng Before)
    ├── screenshot-25-after.png   # (Ảnh chụp thực tế sau khi fix)
    ├── screenshot-26-before.png
    └── screenshot-26-after.png
```

### 4. Cấu trúc file báo cáo kỹ thuật `fix-report.md` (Chia làm 2 Phần rõ rệt):
File `fix-report.md` là báo cáo kỹ thuật duy nhất cho cả menu, được chia rõ ràng thành **2 Phần lớn**:
- **PHẦN 1: CÁC LỖI DÒ QUA KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST CASES - TC)**:
  * Mục 1.1: `[TC-01]: <Tiêu đề Test Case 1>`
  * Mục 1.2: `[TC-02]: <Tiêu đề Test Case 2>`
- **PHẦN 2: CÁC LỖI DÒ QUA TEST THỦ CÔNG (MANUAL SCREENSHOT BUGS)**:
  * Mục 2.1: `[Screenshot 25]: <Tiêu đề lỗi theo Screenshot 25 trong Screenshots_1_bug>`
  * Mục 2.2: `[Screenshot 26]: <Tiêu đề lỗi theo Screenshot 26 trong Screenshots_1_bug>`

> [!WARNING]
> **QUY TẮC BẤT BIẾN: KHÔNG BẮT BUỘC CẢ 2 PHẦN ĐỀU PHẢI CÓ NỘI DUNG — TUYỆT ĐỐI CẤM BỊA ĐẶT NỘI DUNG**:
> - Nếu người dùng chỉ yêu cầu sửa Screenshot thủ công và menu **chưa chạy bộ kiểm thử tự động Playwright** (hoặc không có lỗi TC): **Phần 1 BẮT BUỘC ĐỂ TRỐNG** (chỉ ghi chú: `*(Chưa có kịch bản kiểm thử tự động / Không có lỗi ghi nhận)*`), **TUYỆT ĐỐI KHÔNG TỰ BỊA ĐẶT TEST CASE HOẶC VIẾT BÁO CÁO GIẢ VÀO PHẦN 1**!
> - Ngược lại, nếu chỉ sửa lỗi TC tự động từ `test-evidence/`: Phần 2 để trống.
> - Chỉ khi nào menu thực sự có lỗi ở cả 2 nguồn thì mới viết nội dung cho cả 2 phần.

> [!IMPORTANT]
> **FORMAT TỪNG MỤC Y CHANG NHAU**:
> Cả mỗi TC trong Phần 1 lẫn mỗi Screenshot trong Phần 2 đều có format trình bày **HOÀN TOÀN GIỐNG NHAU**, tuân thủ nghiêm ngặt **chuẩn 4 mục bắt buộc** (Hiện trạng ban đầu, RCA Câu 28, Đối chiếu Before vs After, Minh chứng sau khi sửa).

---

## 📐 CẤU TRÚC 3 BƯỚC BẮT BUỘC TRONG FILE `fix-bug.sql` (CLEAN CODE)

> [!CAUTION]
> **TUYỆT ĐỐI KHÔNG DÙNG CODE CHẮP VÁ REPLACE**:
> Nghiêm cấm viết câu lệnh `UPDATE tblHtmlScriptCache SET html = REPLACE(...)`. Toàn bộ file `fix-bug.sql` ở phần cuối bắt buộc phải tuân thủ chuẩn 3 bước chính quy sau:

```sql
USE [Tên_Database];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-------------------------------------------------------------------
 BƯỚC 1: CẬP NHẬT MÃ NGUỒN GIAO DIỆN SP_<TÊN_SP>_HTML
 (Chứa toàn bộ mã nguồn HTML/JS đã sửa lỗi hoàn thiện, tích lũy cả TC và Screenshot)
--------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_<Tên_SP>_html]
    ...
END
GO

/*-------------------------------------------------------------------
 BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI SP_<TÊN_SP>
 (Trỏ về đúng key chuẩn quy ước hệ thống 'sp_<Tên_SP>' - Không dùng code chắp vá)
--------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_<Tên_SP>](
    @LoginID INT = NULL,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Đọc chuẩn xác theo tên màn hình quy ước của Paradise HRM (Không DELETE bất kỳ dữ liệu nào trong DB)
    SELECT TOP 1 html
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_<Tên_SP>'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

/*-------------------------------------------------------------------
 BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
 (Hệ thống tự động biên dịch, sinh Version mới và nạp đè sạch sẽ vào tblHtmlScriptCache)
--------------------------------------------------------------------*/
PRINT N'===> Đang biên dịch cache qua sp_GenerateHTMLScript_new...';
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_<Tên_SP>_html', 'VN', 'sp_<Tên_SP>';
    EXEC sp_GenerateHTMLScript_new 'sp_<Tên_SP>_html', 'EN', 'sp_<Tên_SP>';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_<Tên_SP>_html';
END
GO

PRINT N'===================================================================';
PRINT N'===> HOÀN TẤT CẬP NHẬT BẢN VÁ! MỞ TAB VÀ BẤM CTRL + F5 ĐỂ KIỂM TRA.';
PRINT N'===================================================================';
GO
```

---

## 📋 CHI TIẾT 4 MỤC BẮT BUỘC TRONG TỪNG PHẦN CỦA `fix-report.md`

Dù là **Test Case (Phần 1)** hay **Screenshot thủ công (Phần 2)**, mỗi mục báo cáo bắt buộc phải tuân thủ chuẩn 4 phần lớn sau:

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)
- **Mô tả hành vi sai khác**: Triệu chứng trên UI, các thao tác dẫn đến lỗi.
- **Bảng số liệu đối soát kiểm thử / Đối chiếu**: Expected vs Actual, số lượng bản ghi hoặc thuộc tính CSS sai khác.
- **Minh chứng hình ảnh lỗi ban đầu**:
  Nhúng bằng đường dẫn tương đối:
  * Cho TC: `![Hiện trạng lỗi ban đầu](screenshot/TC-xx-before.png)`
  * Cho Screenshot: `![Hiện trạng lỗi ban đầu](screenshot/screenshot-xx-before.png)` (copy từ `Screenshots_1_bug/` sang)

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
- **Tuân thủ đúng chuẩn Câu 28 tài liệu `HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md`**:
  * Bóc tách chính xác từng đoạn code lỗi nằm ở đâu: HTML? Thẻ `<style>`? Hay thẻ `<script>`?
  * Nếu là `<script>` thì thuộc phân khu nào trong **5 phân khu chuẩn**:
    - `1️⃣ Phân khu 1: Khai báo Biến & Trạng thái (Variables & States)`
    - `2️⃣ Phân khu 2: Khởi tạo Widget giao diện (Widget Initialization)`
    - `3️⃣ Phân khu 3: Khai báo & Định nghĩa Hàm nghiệp vụ (Function Definitions)`
    - `4️⃣ Phân khu 4: Đăng ký Sự kiện người dùng (Event Listeners Binding)`
    - `5️⃣ Phân khu 5: Thực thi Khởi động (Bootstrap / Trigger Execution)`
  * Nêu rõ: **Bạn sửa nó như thế nào? Tại sao phải sửa như vậy?** (Phân tích cơ chế V8 Engine, DOM Reactivity, điều kiện lọc CSDL).
  * Vẽ sơ đồ luồng lỗi trực quan bằng **Mermaid Flowchart**.

### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)
- **Diff so sánh chi tiết giữa `origin.sql` vs `fix-bug.sql`**:
  ```diff
  --- origin.sql (Stored Procedure gốc trước khi sửa)
  +++ fix-bug.sql (Bản vá hoàn thiện sau khi sửa)
  @@ ... @@
  - đoạn code cũ
  + đoạn code mới đã sửa
  ```
- **Bảng giải thích những điểm can thiệp (What Changed)**:
  Liệt kê rõ từng vị trí thay đổi, dòng lệnh cũ, dòng lệnh mới và tác dụng kỹ thuật/nghiệp vụ tương ứng.

### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)
- Đánh giá kết quả trên giao diện thực tế (toàn vẹn dữ liệu, Console sạch không còn lỗi đỏ).
- **Minh chứng hình ảnh sau khi sửa**:
  Nhúng bằng đường dẫn tương đối:
  * Cho TC: `![Minh chứng kết quả sau khi sửa](screenshot/TC-xx-after.png)`
  * Cho Screenshot: `![Minh chứng kết quả sau khi sửa](screenshot/screenshot-xx-after.png)`
- Đánh giá nghiệm thu: ✅ **PASS 100% Zero-Bug**.

---

## 📸 ĐIỀU 4: NGUYÊN TẮC BẤT BIẾN VỀ ẢNH MINH CHỨNG SAU KHI SỬA (AFTER FIX SCREENSHOT)

> [!CAUTION]
> **ẢNH MINH CHỨNG AFTER FIX CHỈ ĐƯỢC PHÉP TỒN TẠI KHI NGƯỜI DÙNG XÁC NHẬN ĐÃ EXEC VÀO DATABASE**:
> 1. **Giai đoạn vừa tạo file bản vá `fix-bug.sql` (Chưa exec)**:
>    - Agent **TUYỆT ĐỐI KHÔNG ĐƯỢC PHÉP** tự ý tạo ảnh `after.png`, không được can thiệp browser runtime để chụp ảnh mô phỏng rồi nhét vào thư mục `screenshot/` hay `fix-report.md`.
>    - Lúc này, Mục 4 của file `fix-report.md` bắt buộc phải để ở trạng thái chờ:
>      `*(Đang chờ Người Dùng Execute file fix-bug.sql trên SSMS và xác nhận cập nhật)*`.
> 2. **Điều kiện kích hoạt mở Playwright chụp ảnh After Fix**:
>    - **CHỈ KHI NÀO** Người Dùng nhắn tin/chat với Agent xác nhận rằng: **"Đã exec"**, **"Đã chạy xong"**, **"Đã cập nhật vào DB"**, hoặc tương đương.
>    - Khi đó, Agent mới được phép:
>      * Mở Google Chrome qua Playwright.
>      * Đăng nhập và truy cập vào đúng màn hình trên web thật (`https://paradisehrm.com/Tai3/#`).
>      * Chụp ảnh màn hình thực tế (Desktop + Responsive nếu có yêu cầu) để lấy ảnh thực tế 100% từ Database vừa được Người Dùng cập nhật.
>      * Lưu ảnh vào `fix-bug/<tên_menu>/screenshot/screenshot-xx-after.png` (hoặc `TC-xx-after.png`).
>      * Cập nhật ảnh thật vào Mục 4 của file `fix-report.md`.
> 3. **Cam kết trung thực tuyệt đối**:
>    - Tuyệt đối không "cầm đèn chạy trước ô tô", không bịa đặt hoặc dùng ảnh giả lập trước khi Người Dùng thực sự bấm chạy trên SSMS.

---

## 🛠️ ĐIỀU 5: ỨNG DỤNG CHROME DEVTOOLS MCP ĐỂ ĐIỀU TRA LỖI (RCA) & THỬ NGHIỆM BẢN VÁ TRỰC TIẾP

> [!IMPORTANT]
> **VŨ KHÍ CHỦ LỰC KHI ĐIỀU TRA LỖI (RCA)**:
> Thay vì viết script tạm hoặc đoán mò nguyên nhân, Agent **BẮT BUỘC SỬ DỤNG CHROME DEVTOOLS MCP** làm công cụ điều tra hiện trường và thử nghiệm bản vá trực tiếp trên trình duyệt theo quy trình 4 bước chuẩn:

### 1. Bắt Lỗi Console & Exception Thời Gian Thực (`list_console_messages`, `get_console_message`):
- Bắt trọn các lỗi JavaScript runtime văng ra trên trình duyệt: `Uncaught TypeError`, `ReferenceError`, `Cannot read properties of undefined`.
- Xác định chính xác lỗi phát sinh từ hàm nào, thuộc phân khu nào trong **5 phân khu của `<script>` theo Câu 28** (Biến, Widget, Hàm nghiệp vụ, Sự kiện, Khởi động).

### 2. Soi Chi Tiết CSS & Bố Cục Responsive (`get_css_styles`):
- Khi gặp lỗi giao diện (vỡ layout, DataGrid che khuất Toolbar, dropdown nhân viên bị rớt dòng, chữ placeholder bị che mất):
  - Dùng `get_css_styles` soi trực tiếp các matched rules và CSS cascade trên DOM thực tế.
  - Kiểm tra các thuộc tính cốt lõi theo `responsive-rules`: `position: static` (triệt tiêu che khuất Toolbar), `flex-shrink: 0`, `white-space: nowrap`, `overflow: hidden`, `z-index`.
  - Định vị chính xác class hoặc inline style gây lỗi mà không cần mò mẫm.

### 3. Bắt Gói Tin Network & Bóc Tách Stored Procedure (`list_network_requests`, `get_network_request`):
- Lọc các request AJAX gửi về IIS backend qua Generic Handler (`/hpa/paradise2`, `/api/query`, `.ashx`).
- Bóc tách 2 chiều:
  * **Chiều gửi đi (Payload)**: Soi các tham số gửi vào Stored Procedure (kiểm tra thiếu `@LoginID`, sai định dạng `@FromDate`/`@ToDate`, sai tên cột).
  * **Chiều nhận về (Response JSON)**: Kiểm tra mã HTTP 200 có che giấu lỗi SQL Server Exception bên trong không, hoặc backend trả về mảng dữ liệu rỗng do câu lệnh SQL nào.

### 4. Thử Nghiệm Bản Vá Trực Tiếp (Live Hot-patching) Trước Khi Xuất SQL (`evaluate_script`):
- **Nguyên tắc "Thử nghiệm trước - Viết SQL sau"**:
  * Trước khi viết lệnh `ALTER PROCEDURE [dbo].[sp_<Tên_SP>_html]` vào file `fix-bug.sql`, Agent sử dụng `evaluate_script` để **tiêm thử nghiệm trực tiếp đoạn mã JavaScript / CSS đã sửa vào trang web đang chạy**.
  * Quan sát trực tiếp trên UI xem: Giao diện đã hết lỗi chưa? Nút bấm đã kích hoạt đúng chưa? Dữ liệu đã hiển thị chuẩn chưa?
  * Chỉ khi bản vá đã được kiểm chứng hoạt động trơn tru 100% trên runtime, Agent mới gom mã nguồn đó đóng gói vào file `fix-bug.sql`.
  * **Lợi ích**: Triệt tiêu hoàn toàn rủi ro sửa mò, sửa đi sửa lại nhiều lần làm rác Database.
