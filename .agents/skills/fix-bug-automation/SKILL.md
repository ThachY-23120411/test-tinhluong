---
name: fix-bug-automation
description: >-
  Tự động phân tích nguyên nhân lỗi (RCA) sau khi chạy Automation Test khi người dùng cung cấp tên trang/menu và mã TC bị fail (ví dụ: employee_bank_approval, TC-03). Tiến hành điều tra lỗi từ test-evidence, kịch bản spec và database schema qua chế độ READ-ONLY. Tuyệt đối không tự ý sửa DB. Đưa ra mã nguồn đề xuất, lập/bổ sung báo cáo vào fix-bug/<menu>/fix-report.md và tự động đồng bộ/tích lũy toàn bộ Stored Procedure đã sửa vào 1 file SQL duy nhất (fix-bug/release_patches.sql) để bàn giao cho Sếp chạy trên DB production.
---

# Fix Bug Automation — Quy Trình Khắc Phục Lỗi Sau Kiểm Thử Tự Động

Skill này hướng dẫn AI Agent thực hiện quy trình chuẩn xác khi người dùng yêu cầu sửa lỗi sau khi chạy kiểm thử tự động (Automation Test).
Người dùng chỉ cần cung cấp: **Tên menu/trang kiểm thử** + **Mã Test Case (TC) bị FAIL** (Ví dụ: `employee_bank_approval`, `TC-03`).

---

## 🛑 NGUYÊN TẮC BẤT BIẾN: BẢO VỆ AN TOÀN DATABASE

> [!CAUTION] 🚨 ĐIỀU KHOẢN AN TOÀN TUYỆT ĐỐI (NON-NEGOTIABLE)
> 1. **KHÔNG BAO GIỜ TỰ Ý THAY ĐỔI DATABASE**:
>    - Tuyệt đối KHÔNG được phép thực thi bất kỳ câu lệnh sửa đổi (`ALTER`, `UPDATE`, `INSERT`, `DELETE`, `DROP`, `CREATE`, `TRUNCATE`...) trên Database khi chưa được người dùng cho phép trực tiếp.
> 2. **CHẾ ĐỘ TRUY VẤN READ-ONLY 100%**:
>    - Chỉ dùng các lệnh đọc an toàn (`SELECT`, `sys.sql_modules`, `OBJECT_DEFINITION`, `INFORMATION_SCHEMA`, `sp_helptext`) để điều tra nguyên nhân.
> 3. **NGƯỜI DÙNG LÀ NGƯỜI DUYỆT & TỰ EXECUTE**:
>    - Agent chỉ đóng vai trò phân tích nguyên nhân, soạn thảo code đã sửa và hướng dẫn người dùng tự copy, paste và nhấn `F5` trên SSMS để thực thi.
> 4. **BÀN GIAO CHO SẾP CHỈ 1 FILE DUY NHẤT**:
>    - Toàn bộ các Stored Procedure được sửa trong dự án phải được tổng hợp, tích lũy vào **ĐÚNG 1 FILE SQL DUY NHẤT** tại đường dẫn `fix-bug/release_patches.sql` để người dùng có thể gửi ngay cho Sếp chạy trên Database Production của công ty.

---

## 🔄 QUY TRÌNH 5 BƯỚC THỰC THI CHUẨN MỰC (SOP)

```
[Người dùng cung cấp: <Tên trang> + <Mã TC>]
                │
                ▼
[Bước 1: Đọc Dữ liệu Bằng chứng Kiểm thử]
  ├── test-evidence/<menu>/test-report.md
  ├── test-evidence/<menu>/<TC>/ (screenshots, videos, trace, results.json)
  └── tests/<menu>.spec.js
                │
                ▼
[Bước 2: Điều tra Chuyên sâu (Chế độ READ-ONLY)]
  ├── Tìm SP, Function, Table liên quan qua sys.sql_modules
  ├── Trích xuất định nghĩa mã nguồn hiện tại của SP
  └── Đối chiếu dữ liệu thực tế trong DB qua SELECT
                │
                ▼
[Bước 3: Phân tích Nguyên nhân Gốc rễ & Soạn Thảo Bản Sửa]
  ├── Giải thích tại sao lỗi xảy ra (Root Cause Analysis - RCA)
  ├── Đưa ra mã nguồn đề xuất (Proposed Code) đã sửa lỗi
  └── Thống kê chi tiết những thay đổi so với code cũ (Diff Breakdown)
                │
                ▼
[Bước 4: Xuất Báo Cáo Fix Bug Phân Cấp]
  └── fix-bug/<menu>/<TC>/fix-report.md
                │
                ▼
[Bước 5: Đồng bộ & Tích lũy vào 1 File SQL Bàn Giao]
  └── fix-bug/release_patches.sql (DUY NHẤT 1 FILE ĐỂ BÀN GIAO CHO SẾP)
```

---

### Bước 1: Tiếp nhận và định vị dữ liệu kiểm thử
Khi người dùng gọi tên trang và mã TC (ví dụ: `employee_bank_approval`, `TC-03`):
1. Đọc báo cáo tổng thể: `test-evidence/<tên_trang>/test-report.md` và file `test-evidence/<tên_trang>/<TC>/results.json` để nắm bắt trọn vẹn khối bằng chứng lỗi khách quan (`defect_evidence`: Vấn đề gặp phải, Expected vs Actual, mã HTTP, Payload và selector UI).
2. Kiểm tra ảnh chụp màn hình tại bước bị fail: `test-evidence/<tên_trang>/<TC>/screenshots/`.
3. Đọc mã nguồn kiểm thử: `tests/<tên_trang>.spec.js` để hiểu chính xác các thao tác UI, form nhập liệu và vị trí xảy ra lỗi logic. Kịch bản test chỉ cung cấp sự thật khách quan (Facts); Agent là bên chịu trách nhiệm động não (Brainstorming) để tìm ra nguyên nhân gốc rễ (RCA) ở các bước tiếp theo.

---

### Bước 2: Điều tra chuyên sâu trong Database (Chế độ READ-ONLY)
1. Sử dụng `helpers/db.js` để chạy các câu lệnh `SELECT`:
   - Tìm kiếm các Stored Procedure, Table liên quan đến màn hình và nghiệp vụ đang lỗi:
     ```sql
     SELECT name, type_desc FROM sys.objects WHERE type = 'P' AND name LIKE '%<keyword>%'
     ```
   - Trích xuất định nghĩa đầy đủ của SP:
     ```sql
     SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('<Tên_SP>')
     ```
2. Phân tích cấu trúc bảng (`INFORMATION_SCHEMA.COLUMNS`), các cờ trạng thái, các bảng quan hệ liên quan (`tblEmployee`, `tblEmployeeRequestChange`, `tblSC_Login`,...).
3. Kiểm tra các trường hợp biên (Edge Cases): giá trị `NULL`, chuỗi rỗng `''`, giá trị `'undefined'`, chuyển đổi kiểu dữ liệu (`DATETIME`, `INT`, `BIT`), hoặc lỗi `PIVOT` / `ALTER TABLE` khi thiếu `DISTINCT`.

---

### Bước 3: Phân tích Nguyên nhân Gốc rễ & Soạn Thảo Bản Sửa
1. **Giải thích nguyên nhân cốt lõi (RCA)**:
   - Nêu rõ lỗi xảy ra ở dòng nào trong SP hoặc luồng xử lý nào.
   - Giải thích cơ chế vì sao dữ liệu không được cập nhật hoặc không hiển thị lên UI.
2. **Soạn thảo mã nguồn SP đề xuất (Proposed Code)**:
   - Giữ nguyên toàn bộ cấu trúc và các logic nghiệp vụ đã chạy đúng của SP cũ.
   - Bổ sung các mệnh đề bảo vệ (Guards/Validations), xử lý an toàn giá trị rỗng/undefined, bổ sung `DISTINCT` hoặc logic `UPDATE`/`INSERT` còn thiếu.
   - Viết sẵn câu lệnh `ALTER PROCEDURE [dbo].[Tên_SP] ... GO` hoàn chỉnh để người dùng chỉ việc copy và bấm `F5` trên SSMS.
3. **Thống kê những gì đã sửa**:
   - Liệt kê cụ thể từng dòng code cũ vs code mới.
   - Giải thích tác dụng của từng điểm sửa đổi.

---

### Bước 4: Xuất báo cáo Fix Bug phân cấp chuẩn mực
Tạo thư mục `fix-bug/<tên_trang>/<TC>/` và lưu file `fix-report.md`:
* **Đường dẫn**: `fix-bug/<tên_trang>/<TC>/fix-report.md`
* **Nội dung bao gồm**:
  1. Header: Tên trang, Mã TC, Ngày giờ lập báo cáo.
  2. Bảng tóm tắt lỗi (Mô tả, Kỳ vọng, Thực tế, Trạng thái).
  3. Phân tích nguyên nhân gốc rễ chi tiết (RCA).
  4. Mã nguồn hiện tại và Mã nguồn đề xuất (Code Comparison):
     - **BẮT BUỘC**: Với mỗi Stored Procedure, phải có đề mục rõ ràng: `🎯 Sửa Stored Procedure này giải quyết được vấn đề gì?` (Nêu rõ vấn đề cốt lõi được giải quyết, hiện tượng lỗi thực tế trước khi sửa, và kết quả đạt được sau khi sửa).
     - Mã nguồn hiện tại (Code cũ).
     - Mã nguồn đề xuất khắc phục (Code mới - Copy & Paste Ready).
  5. Bảng đối chiếu chi tiết: Những điểm đã thay đổi (What Changed).
  6. Hướng dẫn các bước Người Dùng tự thực thi trên SSMS (`Ctrl + F5` kiểm tra cú pháp $\rightarrow$ `F5` áp dụng).

---

### Bước 5: Đồng bộ & Tích lũy vào 1 File SQL duy nhất bàn giao cho Sếp
* **Đường dẫn**: `fix-bug/release_patches.sql`
* **Quy tắc bất biến**:
  - Không tạo ra nhiều file `.sql` phân mảnh. Tất cả các bản sửa đổi SP trong hệ thống được dồn chung vào duy nhất file `fix-bug/release_patches.sql`.
  - Nếu file đã tồn tại, tiến hành cập nhật/bổ sung đoạn script mới vào phần tương ứng, giữ nguyên các script sửa lỗi trước đó.
  - Cấu trúc chuẩn của file bàn giao:
    ```sql
    /*==============================================================================
      PARADISE HRM - MASTER RELEASE PATCH SCRIPT (CHUYỂN GIAO SẾP / PRODUCTION)
      Tổng hợp toàn bộ các Stored Procedure đã fix bug sau kiểm thử tự động
      Lưu ý: Chỉ cần chạy 1 file này trên Database chính của công ty.
    ==============================================================================*/
    USE [Vietinsoft_ForTest_Tai2] -- Hoặc tên DB Production
    GO

    -- =============================================================================
    -- PATCH 01: [employee_bank_approval] TC-03: Sửa hiển thị và cập nhật TK Ngân hàng
    -- Ngày sửa: ...
    -- SP liên quan: dbo.sp_StaffInformation_PopupInfoBank_LoadDataDetail
    -- =============================================================================
    SET ANSI_NULLS ON
    GO
    SET QUOTED_IDENTIFIER ON
    GO
    ALTER PROCEDURE [dbo].[sp_StaffInformation_PopupInfoBank_LoadDataDetail]
    ...
    GO
    ```
