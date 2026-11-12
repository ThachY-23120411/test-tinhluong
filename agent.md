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

## 📁 ĐIỀU 3: QUY CHUẨN ĐÓNG GÓI BÀN GIAO THƯ MỤC `fix-bug/<menu>/<TC-xx>/`
Mọi kết quả sửa lỗi sau khi hoàn thiện **bắt buộc phải được tổ chức phân cấp theo từng màn hình và mã Test Case** theo đúng cấu trúc thư mục sau:

```text
fix-bug/<menu>/<TC-xx>/
├── origin.sql          # Mã nguồn Stored Procedure gốc trích xuất từ Database trước khi sửa
├── fix-bug.sql         # Mã nguồn bản vá chuẩn 3 bước Clean Code (TUYỆT ĐỐI KHÔNG DÙNG LỆNH REPLACE)
├── fix-report.md       # Báo cáo kỹ thuật phân tích chi tiết chuẩn 4 mục (định dạng Markdown)
└── screenshot/         # Thư mục lưu trữ hình ảnh minh chứng
    ├── before.png      # Ảnh chụp ghi nhận hiện trạng lỗi ban đầu
    └── after.png       # Ảnh chụp giao diện thực tế sau khi fix thành công để nghiệm thu
```

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
4. **4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)**: Đánh giá kết quả trên giao diện thực tế và ảnh chụp màn hình sau khi fix `screenshot/after.png`.

---

## 🔒 QUY TẮC KHÓA CỨNG HELPER DÙNG CHUNG TRONG FILE `.SPEC.JS` (`tests/quy_trinh_tinh_luong_nv_moi.spec.js`)
> [!CAUTION]
> **NGHIÊM CẤM TỰ Ý SỬA CÁC HELPER DÙNG CHUNG KHI CHƯA ĐƯỢC NGƯỜI DÙNG CHO PHÉP**:
> *(Quy chuẩn đồng bộ với **ĐIỀU 8** trong file [`AGENTS.md`](./AGENTS.md) — file rule chính đang được Antigravity nạp tự động cho mọi conversation)*
>
> 1. **Đóng băng tuyệt đối vùng Helper dùng chung**:
>    - Khi chỉnh sửa file kịch bản kiểm thử `.spec.js` (đặc biệt là `tests/quy_trinh_tinh_luong_nv_moi.spec.js`), Agent **TUYỆT ĐỐI KHÔNG ĐƯỢC TỰ Ý SỬA, XÓA, THÊM HOẶC REFACTOR** bất kỳ hàm helper dùng chung, biến cấu hình chung hay phần khai báo chung nào ngoài khối `// >>> [START_TC_XX]` ... `// <<< [END_TC_XX]` được giao.
>    - **Lý do**: Việc thay đổi helper dùng chung sẽ ảnh hưởng trực tiếp đến toàn bộ các Test Case mà những Conversation khác (`fix-4`, `fix-5`, `fix-6`, `fix-7`, `fix-8`...) đã hoàn thiện và đang chạy ổn định.
> 2. **Ưu tiên xử lý cục bộ trong block TC được phân công**:
>    - Mọi điều chỉnh logic tương tác cho một Test Case cụ thể bắt buộc phải viết **cục bộ bên trong block `TC-XX` của conversation đó**, không can thiệp vào helper chung của toàn file.
> 3. **Bắt buộc xin phép trước khi chạm vào Helper dùng chung**:
>    - Nếu phát hiện helper dùng chung thực sự có lỗi, Agent **PHẢI DỪNG LẠI HỎI Ý KIẾN NGƯỜI DÙNG**, nêu rõ: tên helper cần sửa, nguyên nhân lỗi, phương án sửa và đánh giá ảnh hưởng tới các TC khác.
>    - **CHỈ KHI ĐƯỢC NGƯỜI DÙNG CHO PHÉP RÕ RÀNG** (*"Đồng ý sửa helper"*, *"Cho phép sửa"* hoặc tương đương), Agent mới được phép chỉnh sửa vùng helper dùng chung.

---

## 🎬 QUY TRÌNH TẠO REPLAY TEST TỪ FILE `.JSON` CỦA F12 RECORDER (ĐỒNG BỘ ĐIỀU 9 `AGENTS.md`)
> [!IMPORTANT]
> Khi Người Dùng gửi file `.json` xuất từ Chrome DevTools Recorder (F12 $\rightarrow$ Recorder $\rightarrow$ Export JSON), Agent kích hoạt skill [`.agents/skills/recorder-json-replay/SKILL.md`](./.agents/skills/recorder-json-replay/SKILL.md):
> 1. **Lọc thao tác thừa & khớp 100% mạch JSON** (gộp `change` lặp, bỏ click/scroll thừa, thay selector `nth-child`/tọa độ cứng bằng selector động theo tên/cột/ID).
> 2. **Không gắn Expected Result / chẩn đoán lỗi**: Mô phỏng thuần thao tác để Người Dùng tự nhìn `.bat` chạy và đánh giá.
> 3. **Chuẩn trực quan Skill Playwright**: Chuột Neon (`visual_cursor.js`), gõ phím từng chữ (`pressSequentially`), cuộn thông minh (`mouse.wheel` / smooth scroll), toàn màn hình `viewport: null`, và tuân thủ khóa Helper dùng chung (**ĐIỀU 8**).
> 4. **Xuất đủ 3 đầu ra**: TC trong `.spec.js` + Script `.sql` reset dữ liệu test (Read-Only DB khi điều tra) + File `.bat` chạy 1-Click.


