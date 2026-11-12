# AGENT RULES & WORKING GUIDELINES (QUY CHUẨN LÀM VIỆC & AN TOÀN HỆ THỐNG)

> **MỤC ĐÍCH**: Đây là bộ quy tắc bất biến bắt buộc Agent phải tuân thủ nghiêm ngặt 100% trong suốt quá trình rà soát, điều tra lỗi (RCA), viết bản vá và bàn giao kết quả trong dự án.

---

## 🛑 ĐIỀU 1: CHẾ ĐỘ READ-ONLY NGHIÊM NGẶT — TUYỆT ĐỐI KHÔNG TỰ Ý SỬA HOẶC EXEC SP TRÊN DATABASE
1. **Chỉ đọc dữ liệu (Read-Only Mode)**:
   - Agent **TUYỆT ĐỐI KHÔNG ĐƯỢC PHÉP** tự ý thực thi bất kỳ câu lệnh nào làm thay đổi dữ liệu, cấu trúc, schema hoặc mã nguồn trong Database:
     - `ALTER`, `DROP`, `CREATE`, `TRUNCATE`
     - `UPDATE`, `INSERT`, `DELETE`
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
   - Lưu nguyên văn mã nguồn vừa trích xuất thành file `origin.sql`.
   - Giữ nguyên toàn bộ logic, format, chú thích gốc của hệ thống, không tự ý thêm bớt hay can thiệp.
3. **Mục đích phục vụ Đối chiếu (Compare / Diff)**:
   - File `origin.sql` là nguồn đối chứng chuẩn (Base Source of Truth) để Người Dùng và Sếp thực hiện Compare (`Before vs After`) với mã sửa mới, xem rõ chính xác những dòng nào đã được thay đổi và vì sao thay đổi.

---

## 📁 ĐIỀU 3: QUY CHUẨN ĐÓNG GÓI BÀN GIAO HỢP NHẤT THEO TRANG / MENU (`fix-bug/<tên_menu>/`)
> **NGUYÊN LÝ CỐT LÕI**: Một Stored Procedure (`sp_<Tên_SP>_html`) đại diện cho toàn bộ một màn hình/trang. Do đó, **tuyệt đối không chia nhỏ theo từng thư mục con riêng biệt**. Mọi lỗi của trang đó đều được **gom về 1 thư mục duy nhất theo tên menu**.

### 1. Phân loại 2 nguồn lỗi trong hệ thống (Two Bug Sources):
- **Loại 1: Bug do kiểm thử tự động (Automation Test Bugs)**:
  * Phát hiện qua test tự động Playwright, lưu tại `test-evidence/<tên_menu>/TC-xx/`.
  * Định danh theo mã Test Case: `TC-01`, `TC-02`, `TC-03`...
- **Loại 2: Bug do kiểm thử thủ công (Manual Screenshot Bugs)**:
  * Do người dùng dò thủ công trên giao diện và lưu ảnh tại `C:\Users\Y.Thach\Desktop\paradiseHR\Screenshots_1_bug/`.
  * Định danh theo tên Screenshot: `Screenshot 25`, `Screenshot 26`...

### 2. Nguyên tắc "Sửa chung vào 1 file duy nhất" (`fix-bug.sql`):
- Toàn bộ các lỗi của menu (cả TC và Screenshot) đều **được tích hợp chung vào 1 file bản vá duy nhất**: `fix-bug/<tên_menu>/fix-bug.sql`.
- Tuyệt đối không tạo file SQL riêng rẽ cho từng TC hay từng Screenshot.

### 3. Cấu trúc thư mục bàn giao chuẩn cấp Menu:
```text
fix-bug/<tên_menu>/
├── origin.sql          # Mã nguồn Stored Procedure gốc trích xuất từ Database (xài chung cho toàn trang)
├── fix-bug.sql         # File bản vá Stored Procedure tổng hợp duy nhất cho trang (tích lũy tất cả bản sửa của cả TC và Screenshot)
├── fix-report.md       # Báo cáo kỹ thuật duy nhất chia làm 2 Phần: Phần 1 (TCs) và Phần 2 (Screenshots)
└── screenshot/         # Thư mục lưu trữ hình ảnh minh chứng before/after của cả 2 loại:
    ├── TC-01-before.png
    ├── TC-01-after.png
    ├── screenshot-25-before.png  # (Lấy từ Screenshots_1_bug/ sang)
    └── screenshot-25-after.png   # (Ảnh chụp thực tế sau khi fix)
```

### 4. Cấu trúc file báo cáo kỹ thuật `fix-report.md` (Chia làm 2 Phần rõ rệt):
File `fix-report.md` được cấu trúc thành **2 Phần lớn**:
- **PHẦN 1: CÁC LỖI DÒ QUA KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST CASES - TC)**
  * [TC-01]: <Tiêu đề TC 1>
  * [TC-02]: <Tiêu đề TC 2>
- **PHẦN 2: CÁC LỖI DÒ QUA TEST THỦ CÔNG (MANUAL SCREENSHOT BUGS)**
  * [Screenshot 25]: <Tiêu đề lỗi theo Screenshot 25 trong Screenshots_1_bug>
  * [Screenshot 26]: <Tiêu đề lỗi...>

> [!WARNING]
> **QUY TẮC BẤT BIẾN: KHÔNG BẮT BUỘC CẢ 2 PHẦN ĐỀU PHẢI CÓ NỘI DUNG — TUYỆT ĐỐI CẤM BỊA ĐẶT NỘI DUNG**:
> - Nếu người dùng chỉ yêu cầu sửa Screenshot và menu **chưa chạy bộ kiểm thử tự động Playwright** (hoặc không có lỗi TC): **Phần 1 BẮT BUỘC ĐỂ TRỐNG** (chỉ ghi chú: `*(Chưa có kịch bản kiểm thử tự động / Không có lỗi ghi nhận)*`), **TUYỆT ĐỐI KHÔNG TỰ BỊA ĐẶT TEST CASE HOẶC VIẾT BÁO CÁO GIẢ VÀO PHẦN 1**!
> - Ngược lại, nếu chỉ sửa lỗi TC tự động từ `test-evidence/`: Phần 2 để trống.
> - Chỉ khi nào menu thực sự có lỗi ở cả 2 nguồn thì mới viết nội dung cho cả 2 phần.

> [!IMPORTANT]
> **FORMAT TỪNG MỤC Y CHANG NHAU**:
> Cả mỗi TC trong Phần 1 lẫn mỗi Screenshot trong Phần 2 đều có format trình bày **HOÀN TOÀN GIỐNG NHAU**, tuân thủ nghiêm ngặt **chuẩn 4 mục bắt buộc**:
> 1. Hiện trạng ban đầu (Before Fix - có ảnh `screenshot/TC-xx-before.png` hoặc `screenshot/screenshot-xx-before.png`)
> 2. Phân tích nguyên nhân gốc rễ (RCA Câu 28)
> 3. Đối chiếu Before vs After (Diff SQL)
> 4. Minh chứng sau khi sửa (After Fix - có ảnh `screenshot/TC-xx-after.png` hoặc `screenshot/screenshot-xx-after.png`)

---

## 📐 CẤU TRÚC 3 BƯỚC BẮT BUỘC TRONG FILE `fix-bug.sql` (CLEAN CODE)
> [!CAUTION]
> **TUYỆT ĐỐI KHÔNG DÙNG CODE CHẮP VÁ REPLACE**:
> Nghiêm cấm viết câu lệnh `UPDATE tblHtmlScriptCache SET html = REPLACE(...)`. Toàn bộ file `fix-bug.sql` ở phần cuối bắt buộc phải tuân thủ chuẩn 3 bước chính quy sau:

1. **Bước 1**: `ALTER PROCEDURE [dbo].[sp_<Tên_SP>_html]` (chứa toàn bộ code HTML/JS đã sửa hoàn chỉnh).
2. **Bước 2**: Chuẩn hóa Stored Procedure điều phối `[dbo].[sp_<Tên_SP>]`:
   ```sql
   ALTER PROCEDURE [dbo].[sp_<Tên_SP>](
       @LoginID INT = NULL,
       @LanguageID VARCHAR(5) = 'VN'
   )
   AS
   BEGIN
       SET NOCOUNT ON;
       IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
           SET @LanguageID = 'VN';
       SELECT TOP 1 html
       FROM tblHtmlScriptCache
       WHERE TableName = 'sp_<Tên_SP>'
         AND ScreenType = -1
         AND LanguageID = @LanguageID;
   END
   GO
   ```
3. **Bước 3**: Biên dịch mã nguồn giao diện vào bảng cache và cập nhật version:
   ```sql
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
   ```

---

## 📋 CHI TIẾT 4 MỤC BẮT BUỘC TRONG `fix-report.md`:
1. **1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)**: Mô tả hành vi sai khác, bảng số liệu đối soát kiểm thử và ảnh minh chứng lỗi ban đầu `screenshot/before.png`.
2. **2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)**:
   - Tuân thủ chuẩn Câu 28 tài liệu `HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md`.
   - Bóc tách chính xác từng đoạn code lỗi nằm ở đâu: HTML? `<style>`? Hay `<script>`?
   - Nếu là `<script>` thì thuộc phân khu nào trong 5 phân khu (Biến, Widget, Hàm, Sự kiện, Khởi động).
   - Nêu rõ: Bạn sửa nó như thế nào? Tại sao phải sửa như vậy?
3. **3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)**: Diff so sánh chi tiết giữa `origin.sql` vs `fix-bug.sql` và bảng giải thích những điểm can thiệp (What Changed).
4. **4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)**: Đánh giá kết quả trên giao diện thực tế và ảnh chụp màn hình sau khi fix `screenshot/after.png`. *(Chỉ chụp sau khi Người Dùng xác nhận đã exec)*.

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

1. **Bắt Lỗi Console & Exception Thời Gian Thực (`list_console_messages`, `get_console_message`)**:
   - Tóm gọn các lỗi JavaScript runtime (`TypeError`, `ReferenceError`, `undefined`).
   - Xác định chính xác lỗi phát sinh từ hàm nào, thuộc phân khu nào trong **5 phân khu của `<script>` theo Câu 28**.
2. **Soi Chi Tiết CSS & Bố Cục Responsive (`get_css_styles`)**:
   - Khi gặp lỗi giao diện (vỡ layout, DataGrid che khuất Toolbar, dropdown nhân viên bị rớt dòng):
   - Soi trực tiếp các matched rules và CSS cascade trên DOM thực tế.
   - Kiểm tra các thuộc tính cốt lõi: `position: static` (chống che khuất Toolbar), `flex-shrink: 0`, `white-space: nowrap`, `overflow: hidden`, `z-index`.
3. **Bắt Gói Tin Network & Bóc Tách Stored Procedure (`list_network_requests`, `get_network_request`)**:
   - Bắt và bóc tách các request AJAX `/hpa/paradise2` hoặc `.ashx`.
   - Đối chiếu tham số Payload gửi vào Stored Procedure và Response JSON backend trả về để phát hiện thiếu tham số hoặc lỗi SQL ẩn sau mã HTTP 200.
4. **Thử Nghiệm Bản Vá Trực Tiếp (Live Hot-patching) Trước Khi Xuất SQL (`evaluate_script`)**:
   - **Nguyên tắc "Thử nghiệm trước - Viết SQL sau"**:
   - Dùng `evaluate_script` tiêm thử nghiệm đoạn mã JS/CSS đã sửa vào trang web đang chạy.
   - Chỉ khi bản vá hoạt động hoàn hảo 100% trên runtime mới gom mã nguồn đó đóng gói vào file `fix-bug.sql`.
   - Triệt tiêu hoàn toàn rủi ro sửa mò, sửa đi sửa lại nhiều lần trên Database.

---

## ⚔️ ĐIỀU 6: QUY CHUẨN PHỐI HỢP ĐA AGENT TRÊN CÙNG 1 FILE TEST (.SPEC.JS) (MULTI-AGENT TC ISOLATION RULE)
> [!CAUTION]
> **NGUYÊN TẮC BẤT BIẾN: VÙNG CÁCH LY TEST CASE (TEST CASE ISOLATION)**:
> Khi nhiều Conversation / Agent (`fix-4`, `fix-5`, `fix-6`, `fix-7`, `fix-8`) cùng thao tác trên 1 file kịch bản Playwright duy nhất (`tests/quy_trinh_tinh_luong_nv_moi.spec.js`):

1. **Tuyệt đối tuân thủ phạm vi phân công (Boundary Confinement)**:
   - Mỗi Conversation chỉ được phép xem kịch bản của mình tại thư mục `kichbantest/<tên_conversation>/TC-XX.md`.
   - Agent **TUYỆT ĐỐI CHỈ ĐƯỢC CHỈNH SỬA / THÊM CODE VÀO ĐÚNG KHỐI HÀM CỦA MÌNH**:
     ```javascript
     // >>> [START_TC_XX] - PHÂN CÔNG CHO <CONVERSATION_NAME>
     test('TC-XX: ...', async ({ page }, testInfo) => {
         // Agent CHỈ ĐƯỢC CODE TRONG VÙNG NÀY!
     });
     // <<< [END_TC_XX]
     ```
2. **Cấm xâm phạm vùng khai báo chung và khối TC của Agent khác**:
   - **Nghiêm cấm 100%** sửa đổi phần Header chung và **mọi Helper dùng chung** trong file `.spec.js` (xem chi tiết tại **ĐIỀU 8**), trừ khi được Người Dùng trực tiếp cho phép.
   - **Nghiêm cấm 100%** việc chỉnh sửa, xóa, ghi đè hoặc comment vào bất kỳ dòng code nào thuộc các block `TC-YY` của conversation khác.
3. **Cơ chế chạy thử nghiệm cục bộ (Targeted TC Run)**:
   - Agent chỉ được phép chạy kiểm thử riêng TC của mình bằng bộ lọc `-g`:
     ```bash
     npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "TC-XX:" --project="Google Chrome"
     ```
   - Tuyệt đối không chạy toàn bộ file khi các conversation khác đang trong quá trình biên tập code dở dang.
4. **Trật tự thực thi và Cam kết Toàn vẹn Cú pháp (Syntax Integrity)**:
   - Trước khi kết thúc lượt hoặc bàn giao, Agent phải đảm bảo file `.spec.js` không bị lỗi cú pháp (`SyntaxError`), không để thừa/thiếu dấu ngoặc nhọn `{}` hay ngoặc tròn `()`.

---

## 🛡️ ĐIỀU 7: QUY TẮC BẤT KHẢ XÂM PHẠM VỀ SKILL (SKILL INTEGRITY & CHANGE CONTROL)
> [!CAUTION]
> **NGHIÊM CẤM TỰ Ý SỬA ĐỔI SKILL KHI CHƯA ĐƯỢC PHÉP**:
> 1. **Chế độ đóng băng Skill (Strict Skill Lock)**:
>    - Agent **TUYỆT ĐỐI KHÔNG ĐƯỢC TỰ Ý SỬA ĐỔI**, thêm bớt, cập nhật hoặc ghi đè nội dung của bất kỳ file skill nào (`SKILL.md`, `scripts/`, `references/`) trong thư mục `.agents/skills/` hoặc các thư mục skill hệ thống.
> 2. **Bắt buộc hỏi ý kiến và chờ Người Dùng phê duyệt (Mandatory User Approval)**:
>    - Khi phát hiện cần cải tiến, bổ sung quy chuẩn mới vào skill, Agent **BẮT BUỘC PHẢI HỎI Ý KIẾN NGƯỜI DÙNG** (Team Lead/User) trước, nêu rõ lý do và những điểm dự kiến thay đổi.
>    - **CHỈ KHI NÀO NGƯỜI DÙNG CHO PHÉP IMPLEMENT** ("Đồng ý", "Cho phép sửa skill", hoặc tương đương) thì Agent mới được phép chỉnh sửa nội dung file của skill đó.

---

## 🔒 ĐIỀU 8: KHÓA CỨNG HELPER DÙNG CHUNG TRONG FILE `.SPEC.JS` (SHARED HELPER LOCK)
> [!CAUTION]
> **NGHIÊM CẤM TỰ Ý SỬA CÁC HELPER DÙNG CHUNG TRONG FILE `.SPEC.JS` KHI CHƯA ĐƯỢC NGƯỜI DÙNG CHO PHÉP**:
>
> 1. **Chế độ đóng băng Helper dùng chung (Strict Shared-Helper Lock)**:
>    - Khi sửa file kịch bản kiểm thử `.spec.js` (đặc biệt là `tests/quy_trinh_tinh_luong_nv_moi.spec.js`), Agent **TUYỆT ĐỐI KHÔNG ĐƯỢC TỰ Ý SỬA, XÓA, THÊM HOẶC REFACTOR** bất kỳ hàm helper dùng chung, biến cấu hình chung hay phần khai báo đầu file nào nằm ngoài khối `// >>> [START_TC_XX]` ... `// <<< [END_TC_XX]` của mình (ví dụ: `require`, `ACCOUNTS`, `test.use`, `moveAndClick`, `typeHumanLike`, `selectBoxHumanLike`, `fillDateHumanLike`, `buildGridRowSelector`, `findRowByColumns`, `getScrollableContainerState`, `resolveDynamicTarget`, `moveAndClickGridTarget`, `highlightAndClickDynamicTarget`, ...).
>    - **Lý do**: Mọi chỉnh sửa trên helper dùng chung đều có thể làm thay đổi hành vi và gây lỗi dây chuyền cho các Test Case mà những Conversation khác (`fix-4`, `fix-5`, `fix-6`, `fix-7`, `fix-8`...) đã làm và đang hoạt động ổn định.
> 2. **Nguyên tắc xử lý cục bộ trong phạm vi Test Case được giao**:
>    - Khi xử lý lỗi hoặc tùy biến thao tác cho một Test Case cụ thể, Agent **bắt buộc phải viết/chỉnh code cục bộ ngay bên trong block `TC-XX` được phân công**, tuyệt đối không sửa helper dùng chung để phục vụ riêng 1 TC.
> 3. **Bắt buộc xin phép & chờ Người Dùng phê duyệt (Mandatory User Approval)**:
>    - Nếu phát hiện helper dùng chung thực sự có bug cần can thiệp, Agent **BẮT BUỘC PHẢI DỪNG LẠI HỎI Ý KIẾN NGƯỜI DÙNG** trước, nêu rõ: (a) tên hàm helper cần sửa, (b) nguyên nhân lỗi & thay đổi dự kiến, và (c) đánh giá mức độ ảnh hưởng đối với các TC của các conversation khác.
>    - **CHỈ KHI NÀO NGƯỜI DÙNG CHO PHÉP RÕ RÀNG** (*"Đồng ý sửa helper"*, *"Cho phép sửa"* hoặc tương đương) thì Agent mới được phép chỉnh sửa vùng helper dùng chung của file `.spec.js`.

---

## 🎬 ĐIỀU 9: QUY TRÌNH TẠO REPLAY TEST TỪ FILE JSON CỦA F12 RECORDER (`.JSON` $\rightarrow$ `.SPEC.JS` + `.SQL` RESET + `.BAT`)
> [!IMPORTANT]
> **KÍCH HOẠT TỰ ĐỘNG KHI NGƯỜI DÙNG GỬI FILE `.JSON` XUẤT TỪ CHROME DEVTOOLS RECORDER**:
> Khi Người Dùng gửi file `.json` (F12 $\rightarrow$ Recorder $\rightarrow$ Export JSON) hoặc yêu cầu tạo kịch bản mô phỏng thao tác tái sử dụng từ Recorder, Agent bắt buộc đọc và tuân thủ skill [`.agents/skills/recorder-json-replay/SKILL.md`](./.agents/skills/recorder-json-replay/SKILL.md):
> 1. **Lọc thao tác thừa & khớp 100% mạch JSON**: Loại bỏ click nhầm/click focus thừa/gõ sửa lặp lại trên cùng 1 input, đồng thời giữ đúng 100% luồng nghiệp vụ thật trong JSON.
> 2. **Không chèn Expected Result / Chẩn đoán lỗi**: Chạy thuần mô phỏng trực quan để Người Dùng tự quan sát kết quả khi chạy `.bat`, không tự ý thêm `expect(...)` nghiệp vụ hay đối soát DB bắt FAIL giữa luồng.
> 3. **Chuẩn trực quan Skill Playwright**: Toàn màn hình (`viewport: null` + `--start-maximized`), nhúng `visual_cursor.js` (chuột Neon + sóng gợn + bong bóng phím), di chuột (`moveAndClick`) mới bấm, gõ phím từng ký tự (`pressSequentially`), cuộn thông minh (`mouse.wheel` / smooth scroll), chuyển selector `nth-child`/tọa độ cứng sang định vị động theo chữ/cột/ID, và tuân thủ tuyệt đối **ĐIỀU 8** nếu ghép vào `.spec.js` dùng chung.
> 4. **Script `.sql` Reset + Launcher `.bat` 1-Click**: Điều tra DB bằng chế độ **Read-Only** (ĐIỀU 1) để xuất file `.sql` reset dữ liệu test cho Người Dùng bấm `F5` trên SSMS trước mỗi lần chạy lại, kèm file `.bat` chạy trực quan `--headed --workers=1`.



