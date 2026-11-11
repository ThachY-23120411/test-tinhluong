---
name: screenshot-patch-report
description: >-
  Quy chuẩn chuyên nghiệp để điều tra, làm sạch mã nguồn bản vá SQL và biên soạn báo cáo kỹ thuật (Technical Defense Report) cho các lỗi giao diện theo từng Screenshot (Screenshot 1 đến Screenshot 18+) trong dự án Paradise HRM. Áp dụng quy trình 3 bước sạch sẽ (Clean Code), đối chiếu chuẩn Before (Hệ thống gốc) vs After (Bản vá hoàn thiện), loại bỏ hoàn toàn code rác/code chắp vá, bám sát 100% cây DOM HTML và cam kết an toàn tuyệt đối cho CSDL (Read-only khi điều tra, không dùng lệnh DELETE).
---

# Screenshot Patch & Technical Defense Report — Quy Chuẩn Xử Lý Bản Vá & Báo Cáo Screenshot

Skill này đóng gói toàn bộ quy trình chuẩn mực, nguyên tắc kiến trúc và phương pháp lập báo cáo giải trình kỹ thuật cho từng màn hình bị lỗi giao diện theo danh sách **Screenshot (từ Screenshot 1 đến Screenshot 18+)** trong hệ thống Paradise HRM.

---

## 🛑 NGUYÊN TẮC BẤT BIẾN (NON-NEGOTIABLE CORE DIRECTIVES)

> [!CAUTION] 🚨 NGUYÊN TẮC AN TOÀN DATABASE & QUY CHUẨN CLEAN CODE
> 1. **CHẾ ĐỘ ĐIỀU TRA READ-ONLY 100%**:
>    - Khi phân tích lỗi, Agent chỉ được sử dụng các truy vấn đọc dữ liệu an toàn (`SELECT`, `OBJECT_DEFINITION`, `sys.sql_modules`, `INFORMATION_SCHEMA`). Tuyệt đối không tự ý chạy `ALTER`, `UPDATE`, `INSERT`, `DELETE`, `DROP`.
> 2. **TUYỆT ĐỐI KHÔNG DÙNG LỆNH `DELETE`**:
>    - Không chạy bất kỳ câu lệnh `DELETE` nào trên database (kể cả xóa bản ghi cũ trong `tblHtmlScriptCache`). Toàn bộ dữ liệu lịch sử phải được giữ nguyên vẹn để bảo toàn CSDL.
> 3. **LOẠI BỎ TRIỆT ĐỂ CODE RÁC / CODE CHẮP VÁ**:
>    - **Không có bước 2.2**: Tuyệt đối không viết lệnh `UPDATE` sao chép dữ liệu cưỡng bức giữa 2 key cache.
>    - **Không có bước 2.3**: Tuyệt đối không viết lệnh `UPDATE Version = CAST(CHECKSUM(...))` cưỡng bức.
>    - **Không dùng `DROP PROCEDURE`**: Luôn dùng `CREATE OR ALTER PROCEDURE` để chống rủi ro mất thủ tục nếu lệnh tạo bị gián đoạn.
> 4. **QUY TẮC ĐỐI CHIẾU BEFORE VS AFTER TRONG BÁO CÁO**:
>    - **BEFORE (TRƯỚC)**: Bắt buộc là **Mã nguồn gốc của hệ thống ban đầu (lúc chưa sửa gì)** $\rightarrow$ để Sếp/Khách hàng thấy rõ lỗi ban đầu của hệ thống.
>    - **AFTER (SAU)**: Là **Mã nguồn bản vá hoàn thiện cuối cùng** $\rightarrow$ giải pháp dứt điểm.
>    - **TUYỆT ĐỐI KHÔNG**: So sánh giữa các lần sửa thử nghiệm nội bộ của Dev (sửa lúc này so với lúc kia).
> 5. **BÁM SÁT 100% CÂY DOM & MÃ NGUỒN THỰC TẾ**:
>    - Mọi class/selector CSS được đề cập trong báo cáo phải chỉ rõ: **Nó nằm ở dòng nào trong file SQL? Và nó tác động lên thẻ HTML nào trong cây DOM?**

---

## 📁 QUY CHUẨN ĐÓNG GÓI BÀN GIAO HỢP NHẤT THEO MENU (`fix-bug/<tên_menu>/`)

> [!IMPORTANT]
> **THAY ĐỔI KIẾN TRÚC QUAN TRỌNG**: Một Stored Procedure đại diện cho toàn bộ một màn hình/trang. Do đó:
> 1. **BỎ HẲN cấu trúc thư mục `screenshot-xx/`** và không chia thư mục con theo TC.
> 2. Mọi lỗi vặt chụp màn hình (từ `Screenshots_1_bug/<X>.png`) sẽ được quy đổi thành mã Test Case (ví dụ `TC-01`, `TC-02`...) và gom về thư mục menu tương ứng.
> 3. `origin.sql`, `fix-bug.sql` và `fix-report.md` là **XÀI CHUNG cho toàn bộ trang** $\rightarrow$ Sửa thì sửa ở 1 chỗ duy nhất!

```text
fix-bug/<tên_menu>/
├── origin.sql          # Mã nguồn Stored Procedure gốc trích xuất từ Database trước khi sửa (xài chung)
├── fix-bug.sql         # File SQL bản vá tổng hợp duy nhất cho trang (tích lũy tất cả các TC, chuẩn 3 bước Clean Code)
├── fix-report.md       # Báo cáo kỹ thuật chi tiết chuẩn 4 mục (chia rõ từng TC theo format chuẩn)
└── screenshot/         # Thư mục chứa hình ảnh minh chứng before/after của các TC
    ├── TC-01-before.png (hoặc before.png)
    └── TC-01-after.png  (hoặc after.png)
```

---

## 🛠️ QUY TRÌNH 4 BƯỚC THỰC HIỆN KHI TIẾP NHẬN SCREENSHOT MỚI

### BƯỚC 1: Khảo sát & Nhận diện Thành phần Hệ thống (Read-Only)
1. Xác định:
   - **Menu / Màn hình**: Tên chức năng, MenuID.
   - **Stored Procedure sinh HTML**: `sp_..._html` (hoặc `..._Beta`).
   - **Stored Procedure điều phối**: `sp_...` (SP mà Web gọi qua AJAX).
   - **Bảng Cache**: `tblHtmlScriptCache` (Key chuẩn `TableName = 'sp_...'`).
2. Trích xuất định nghĩa gốc của hệ thống ban đầu:
   ```javascript
   // Chạy script Node.js với helpers/db để đọc OBJECT_DEFINITION:
   const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_..._html')) as def")[0].def;
   ```
3. Lưu lại bản gốc để phục vụ phần đối chiếu **BEFORE** trong báo cáo.

---

### BƯỚC 2: Chuẩn Hóa File Bản Vá SQL (Quy trình 3 Bước Duy Nhất)

File SQL bản vá phải được tinh gọn và tổ chức chuẩn mực theo **đúng 3 bước dứt khoát**:

```sql
/*==================================================================================================
  PARADISE HRM - PATCH: <TÊN MENU> (MenuID: <Mã Menu>)
  SỬA LỖI: <Mô tả ngắn gọn lỗi trên Screenshot X>
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT GIAO DIỆN SP_..._HTML (HTML / CSS RESPONSIVE / JS DEVIEXTREME)
--------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[sp_<TênMenu>_html]
    @LoginID INT = NULL,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html NVARCHAR(MAX);
    SET @html = N'
        <!-- 1. CSS Scoped chống rò rỉ: Dùng tiền tố #sp_<TênMenu> bao bọc -->
        <!-- 2. Cây DOM HTML chuẩn hóa -->
        <!-- 3. JS DataGrid Responsive: columnAutoWidth: true, allowColumnResizing: true, chia width % -->
    ';
    SELECT @html AS html;
END
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI (TRỎ VỀ ĐÚNG 1 KEY CHUẨN HỆ THỐNG)
--------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[sp_<TênMenu>]
    @LoginID INT = NULL,
    @LanguageID VARCHAR(2) = 'VN',
    @EmployeeID VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Đọc duy nhất 1 Key chuẩn quy ước của hệ thống (Không dùng IN, không fallback chắp vá)
    SELECT TOP 1 html AS Col1 
    FROM tblHtmlScriptCache 
    WHERE TableName = 'sp_<TênMenu>' 
      AND ScreenType = -1 
      AND LanguageID = @LanguageID;
END
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE
--------------------------------------------------------------------------------------------------*/
PRINT N'==> Đang biên dịch cache qua sp_GenerateHTMLScript_new...';
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
    EXEC sp_GenerateHTMLScript_new 'sp_<TênMenu>_html', '-1', 'sp_<TênMenu>';
ELSE
    EXEC sp_GenerateHTMLScript 'sp_<TênMenu>_html';
GO

PRINT N'==================================================================================================';
PRINT N'==> HOÀN TẤT CẬP NHẬT SCREENSHOT <X>! MỞ TAB VÀ BẤM CTRL + F5 ĐỂ KIỂM TRA.';
PRINT N'==================================================================================================';
GO
```

> [!IMPORTANT]
> **Checklist kiểm tra file SQL trước khi bàn giao**:
> - [ ] Không có câu lệnh `UPDATE` cưỡng bức sao chép key (2.2).
> - [ ] Không có câu lệnh `UPDATE Version = CHECKSUM(...)` (2.3).
> - [ ] Không có câu lệnh `DELETE` nào.
> - [ ] Không có câu lệnh `DROP PROCEDURE` (dùng `CREATE OR ALTER PROCEDURE`).
> - [ ] Đã kiểm tra cú pháp JavaScript bên trong biến `@html` qua Node.js V8 engine (`new Function(...)` không văng lỗi).

---

### BƯỚC 3: Soạn Thảo Báo Cáo Kỹ Thuật Chuẩn Mực (`fix-report.md`)

Báo cáo phải tuân thủ nghiêm ngặt khung cấu trúc 5 mục dưới đây:

#### Mục 1: Thông tin chung & Hiện trạng lỗi ban đầu (Problem Statement)
- Mô tả chính xác triệu chứng lỗi nhìn thấy trên màn hình và tác động người dùng.
- Dẫn link tới ảnh đối chiếu lỗi trong thư mục `screenshots/`.

#### Mục 2: Phân tích nguyên nhân gốc rễ (Root Cause Analysis - RCA)
- Chỉ rõ dòng code bị lỗi trong mã nguồn hệ thống ban đầu.
- Phân tích vì sao lỗi xảy ra (lệch selector DOM, thiếu flexbox, gán cứng pixel, lệch key cache...).

#### Mục 3: Đối chiếu mã nguồn Before vs After (Bắt buộc)
- **`❌ HỆ THỐNG BAN ĐẦU (BEFORE)`**: Trích dẫn chính xác đoạn mã gốc lúc chưa sửa.
- **`✅ BẢN VÁ HOÀN THIỆN (AFTER)`**: Trích dẫn chính xác đoạn mã đã sửa trong file SQL.
- Có comment chỉ rõ từng điểm khắc phục và số dòng tương ứng.

#### Mục 4: Giải trình liên kết DOM & Selector CSS
- Lập bảng chi tiết giải thích rõ: **Selector CSS đó nằm ở dòng nào trong file SQL? Và nó tác động vào thẻ HTML nào trong cây DOM?**

| Selector CSS (Dòng trong file SQL) | Thẻ HTML trong cây DOM | Tác dụng kỹ thuật thực tế |
| :--- | :--- | :--- |
| `#sp_<TênMenu>` | `<div id="sp_<TênMenu>">` | Thẻ cha ngoài cùng, quản lý layout tổng thể. |
| `#sp_<TênMenu> .grid-container` | `<div id="<id>_container" class="grid-container">` | Khung bọc bảng, bo tròn góc, viền mờ. |
| `#sp_<TênMenu> .dx-datagrid` | Thẻ widget sinh ra bên trong `<div id="<id>_grid">` | Tinh chỉnh hiển thị bảng DevExtreme DataGrid. |

#### Mục 5: Quy trình thực thi & Hướng dẫn nghiệm thu
- Hướng dẫn rõ ràng 3 bước nghiệm thu:
  1. Mở file `.sql` trên SSMS, bấm `Ctrl + F5` kiểm tra cú pháp $\rightarrow$ bấm `F5` chạy script.
  2. Mở trình duyệt Chrome, đóng tab con cũ $\rightarrow$ bấm `Ctrl + F5` $\rightarrow$ mở lại menu.
  3. Liệt kê các tiêu chí nghiệm thu thành công.

---

### BƯỚC 4: Tự Động Kiểm Định Trước Khi Bàn Giao (Self-Verification)

Chạy script Node.js kiểm tra:
1. File SQL tồn tại và parse thành công.
2. Cú pháp JavaScript nhúng trong Stored Procedure hợp lệ 100% trên V8 Engine.
3. Không sót bất kỳ từ khóa cấm nào (`DELETE`, lệnh UPDATE chắp vá).
4. File báo cáo `fix-report.md` đầy đủ 5 mục và đúng chuẩn Before = Hệ thống gốc.

---

## 💡 CÁCH SỬ DỤNG KHI USER YÊU CẦU

Khi người dùng nhắn:
* *"tiếp tới screenshot X đi"*
* *"làm screenshot X"*
* *"refactor screenshot X"*

Agent lập tức:
1. Kích hoạt kỹ năng `screenshot-patch-report`.
2. Truy cập thư mục `fix-bug/screenshot-X/`.
3. Kiểm tra file SQL $\rightarrow$ dọn sạch code thừa theo quy trình 3 bước chuẩn.
4. Kiểm tra mã nguồn gốc hệ thống $\rightarrow$ biên soạn lại báo cáo `fix-report.md` với đối chiếu Before (Hệ thống gốc) vs After (Bản vá hoàn thiện).
5. Báo cáo ngắn gọn, mạch lạc kết quả cho người dùng.
