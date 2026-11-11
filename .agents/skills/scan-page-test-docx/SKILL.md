---
name: scan-page-test-docx
description: Quét nghiệp vụ toàn diện của 1 trang (DOM, Controls, Modals, Filters, API CRUD) và phân tích đối soát liên màn hình (Downstream Verification / Ripple Effect), sau đó xuất ra kịch bản kiểm thử chuẩn chỉnh dưới dạng file Microsoft Word (.docx) với dữ liệu thực tế và kỳ vọng định lượng đối soát từ CSDL.
---

# SCAN PAGE TEST DOCX — QUÉT NGHIỆP VỤ & XUẤT KỊCH BẢN TEST DƯỚI DẠNG FILE WORD (.DOCX)

> **Sứ mệnh cốt lõi**: Khảo sát 100% Controls trên giao diện $\longrightarrow$ **Truy vấn CSDL (Read-only) lấy giá trị thực tế & số lượng định lượng** $\longrightarrow$ Bóc tách luồng nghiệp vụ CRUD & Bộ lọc 3 pha $\longrightarrow$ Truy vết CSDL/API đối soát liên màn hình (Ripple Effect) $\longrightarrow$ Xuất ra file tài liệu Microsoft Word (`.docx`) hoàn chỉnh, chuyên nghiệp tại `docs/test-specs/<tên_trang>-test-spec.docx`.

---

## 🛑 BỘ 4 NGUYÊN TẮC VÀNG BẮT BUỘC KHI TẠO KỊCH BẢN DOCX

### 1. NGUYÊN TẮC 1: DỮ LIỆU KIỂM THỬ THỰC TẾ 100% (ZERO PLACEHOLDER TEST DATA)
* **TUYỆT ĐỐI NGHIÊM CẤM** sử dụng các từ ngữ chung chung, vô định hình, hình thức:
  - ❌ *Cấm ghi*: `"N/A"`, `"Dữ liệu thực tế trên hệ thống"`, `"Chọn một nhân viên bất kỳ"`, `"Nhập từ khóa tìm kiếm"`, `"Chọn một ngày bất kỳ"`.
* **BẮT BUỘC PHẢI CHỈ ĐỊNH RÕ RÀNG GIÁ TRỊ THỰC TẾ** bóc tách từ DOM hoặc CSDL:
  - ✅ **Ô tìm kiếm**: Ghi rõ từ khóa thực tế: ví dụ `"Từ khóa: 'Nguyễn'"` hoặc `"Từ khóa: 'Chiến'"`.
  - ✅ **Bộ lọc nhân sự**: Ghi rõ nhân viên cụ thể kèm mã: ví dụ `"Nhân sự: NGUYỄN TẤN CHIẾN (Mã: 013)"`.
  - ✅ **Bộ lọc trạng thái / giai đoạn**: Ghi rõ tên trạng thái cụ thể: ví dụ `"Trạng thái: 'Mới tạo'`, `'Báo giá'`, `'Thành công'"`.
  - ✅ **Bộ lọc thời gian**: Ghi rõ khoảng ngày hoặc mốc cụ thể: ví dụ `"Mốc: 'Tháng này'` và `'Năm nay'"` hoặc `"Từ 01/10/2026 đến 31/10/2026"`.
  - ✅ **Form CRUD thêm mới**: Ghi rõ các trường dữ liệu thật có hậu tố ngẫu nhiên để chống trùng: `"Tên: Công ty TNHH Pipeline Sync <RandomID>, SĐT: 0977xxxxxx, MST: 99xxxxxx"`.

### 2. NGUYÊN TẮC 2: KỲ VỌNG ĐỊNH LƯỢNG ĐỐI SOÁT TỪ DATABASE (DB-BACKED QUANTITATIVE EXPECTATION)
* **TUYỆT ĐỐI NGHIÊM CẤM** viết kỳ vọng mơ hồ kiểu cảm tính:
  - ❌ *Cấm ghi*: `"Hệ thống hoạt động ổn định"`, `"Dropdown mở mượt mà và đóng không gây nghẽn"`, `"Dữ liệu hiển thị đúng"`, `"Bảng nạp danh sách thành công"`.
* **BẮT BUỘC SỬ DỤNG TRUY VẤN READ-ONLY CSDL** để lấy con số định lượng chính xác:
  - Trong quá trình quét trang, Agent dùng `helpers/db.js` chạy câu lệnh SQL đọc an toàn (`SELECT COUNT(*)...`) để biết trước chính xác hệ thống sẽ trả về bao nhiêu bản ghi.
  - Kỳ vọng nghiệp vụ trong file Word **bắt buộc phải ghi rõ số lượng bản ghi mong đợi** khớp với CSDL:
    - *Ví dụ*: `"Bảng dữ liệu lọc tức thì hiển thị đúng 31 bản ghi chứa từ khóa 'Nguyễn' (khớp 100% với truy vấn CSDL: 31 bản ghi). Khi dọn sạch ô tìm kiếm, hệ thống khôi phục đủ 61 bản ghi ban đầu."*
    - *Ví dụ*: `"Sau khi chọn nhân viên NGUYỄN TẤN CHIẾN (Mã: 013) và bấm Làm mới, bảng Kanban lọc chính xác 17 thẻ cơ hội thuộc nhân sự này. Khi Xóa chọn, khôi phục đủ 61 thẻ ban đầu."*
  - **Bổ sung trường `dbQuery`** trong mỗi kịch bản test để in trực tiếp câu lệnh SQL đối soát vào file Word!

### 3. NGUYÊN TẮC 3: VÒNG ĐỜI BỘ LỌC ĐẦY ĐỦ 3 PHA (FULL 3-PHASE FILTER LIFECYCLE)
Mọi kịch bản kiểm thử liên quan đến Bộ lọc (Filter, Dropdown, Search, Date Range, Status Chip) **BẮT BUỘC PHẢI ĐI ĐỦ 3 PHA**:
```
[Pha 1: Baseline]
Ghi nhận số lượng bản ghi ban đầu (N0)
        │
        ▼
[Pha 2: Filter Action]
Chọn giá trị thực tế -> Áp dụng bộ lọc (kèm nút Làm mới nếu Web yêu cầu)
-> Kiểm chứng số lượng hiển thị thu hẹp đúng bằng số lượng kỳ vọng từ CSDL (N_filtered)
        │
        ▼
[Pha 3: Reset & Restore]
Xóa chọn / Dọn sạch bộ lọc -> Áp dụng lại
-> Kiểm chứng số lượng phục hồi trọn vẹn 100% bản ghi ban đầu (N_restored == N0)
```
* **TUYỆT ĐỐI NGHIÊM CẤM** kịch bản hời hợt: "Mở menu ra xem rồi ấn Escape đóng lại"!

### 4. NGUYÊN TẮC 4: BẢO VỆ DATABASE TOÀN VẸN (STRICT READ-ONLY)
* Mọi câu lệnh truy vấn phục vụ lấy dữ liệu kỳ vọng **chỉ được phép dùng `SELECT`**, không bao giờ được phép dùng `INSERT`, `UPDATE`, `DELETE`, `ALTER`. Tuân thủ 100% quy tắc bảo vệ CSDL tại `AGENTS.md`.

### 5. NGUYÊN TẮC 5: KHẢO SÁT CHUỖI PHÊ DUYỆT ĐA CẤP & VÒNG ĐỜI FORM MODAL (APPROVAL MATRIX & CONFIRMATION MODAL)
* **Đối với các màn hình có chức năng gửi đơn từ (Xin bù công, Xin nghỉ phép, Xin tăng ca...)**:
  - **Khảo sát Chuỗi duyệt đa cấp**: Bắt buộc truy vấn `tblApprovalLineByEmployee` hoặc inspect DOM cây duyệt để ghi rõ trong kịch bản test: Ai là Cấp 1, ai là Cấp 2. Tuyệt đối cấm gán 1 người duyệt đại diện.
  - **Vòng đời Form Modal**: Bắt buộc mô tả rõ bước xử lý popup xác nhận `#vc-vu-confirm-popup` (bấm nút "Đồng ý" `.VC-Vu-btn-ok`), không dừng lại ở nút submit.
  - **Đối soát Top 1 chống Fake PASS**: Kỳ vọng đối soát trong tab Lịch sử phải chỉ định rõ: Bản ghi mới nạp bắt buộc phải nằm ở vị trí Top 1 với đúng Ngày, Giờ, Trạng thái "Đang chờ duyệt". Cấm kỳ vọng kiểm tra số lượng bản ghi chung chung nếu danh sách đã có dữ liệu cũ.

---

## 2. QUY TRÌNH 5 BƯỚC KHẢO SÁT & XUẤT BẢN FILE DOCX

```
[Dev yêu cầu: Tên trang / URL cần quét nghiệp vụ]
                         │
                         ▼
  [BƯỚC 1: Khảo sát DOM & Lập bảng kiểm kê 100% Controls]
  • Quét Toolbar, Modals, Dropdowns, Ô nhập liệu (*)
  • Quét Cụm bộ lọc, Chip trạng thái, Lọc ngày, Tìm kiếm
  • Quét Bảng DataGrid / Kanban: Cột, phân trang, thẻ
                         │
                         ▼
  [BƯỚC 2: Truy vấn CSDL Read-only Lấy Giá Trị Thực Tế & Định Lượng]
  • Dùng helpers/db.js truy vấn dữ liệu mẫu có sẵn
  • Xác định: Nhân viên nào có lead? Trạng thái nào có bao nhiêu thẻ?
  • Tính toán trước các con số kỳ vọng (N0, N_filtered)
                         │
                         ▼
  [BƯỚC 3: Thiết Kế Kịch Bản Chi Tiết & Gán Dữ Liệu Thực Tế]
  • Thiết lập Test Data cụ thể cho từng TC
  • Thiết lập Kỳ vọng nghiệp vụ định lượng dựa trên kết quả CSDL
  • Đính kèm câu lệnh SQL đối soát vào trường dbQuery
                         │
                         ▼
  [BƯỚC 4: Điều Tra Hiệu Ứng Gợn Sóng & Đối Soát Downstream]
  • Xác định bảng CSDL đích (Target Tables)
  • Truy vết các Stored Procedures / APIs khác đọc bảng đó
  • Ánh xạ sang các Màn hình Đích & Vai trò Người dùng chịu ảnh hưởng
                         │
                         ▼
  [BƯỚC 5: Biên dịch & Xuất bản ra file Word .docx]
  • Ghi dữ liệu vào file JSON tạm
  • Chạy script generate_docx.js sinh file docs/test-specs/<tên_trang>-test-spec.docx
```

---

## 3. CÁCH SỬ DỤNG `helpers/db.js` ĐỂ LẤY DỮ LIỆU THỰC TẾ & KỲ VỌNG

Trong quá trình khảo sát trang, Agent có thể viết một script Node.js ngắn gọn hoặc chạy qua terminal để truy vấn dữ liệu mẫu:

### Ví dụ 1: Tìm nhân viên có dữ liệu và số lượng lead tương ứng:
```javascript
const { query } = require('./helpers/db');

// Tìm nhân viên có cơ hội trên Sales Pipeline
const empStats = query(`
  SELECT EmployeeIDs, COUNT(*) AS TotalLeads 
  FROM tblCRM_CompanyInfo 
  WHERE EmployeeIDs IS NOT NULL AND LTRIM(RTRIM(EmployeeIDs)) <> ''
  GROUP BY EmployeeIDs
  ORDER BY TotalLeads DESC
`);
console.log(empStats);
// Kết quả: Mã 013 (Nguyễn Tấn Chiến) có 17 leads, Mã 034 có 21 leads...
```
$\longrightarrow$ **Đưa ngay vào kịch bản**: Chọn `NGUYỄN TẤN CHIẾN (Mã: 013)`, kỳ vọng: `17 thẻ`.

### Ví dụ 2: Tìm từ khóa phổ biến để test Ô tìm kiếm nhanh:
```javascript
const keywords = query(`
  SELECT TOP 5 CompanyName, ContactName 
  FROM tblCRM_CompanyInfo 
  WHERE CompanyName LIKE N'%Nguyễn%'
`);
const countKeyword = query(`
  SELECT COUNT(*) AS Cnt 
  FROM tblCRM_CompanyInfo 
  WHERE CompanyName LIKE N'%Nguyễn%' OR ContactName LIKE N'%Nguyễn%'
`);
console.log('Số lượng bản ghi chứa từ khóa Nguyễn:', countKeyword[0].Cnt);
// Kết quả: 31 bản ghi
```
$\longrightarrow$ **Đưa ngay vào kịch bản**: Từ khóa `'Nguyễn'`, kỳ vọng: `Hiển thị đúng 31 bản ghi`.

---

## 4. CẤU TRÚC JSON ĐẦU VÀO CHO SCRIPT SINH WORD (`temp_spec.json`)

Mẫu chuẩn cấu trúc JSON mới hỗ trợ đầy đủ `testData`, `dbQuery`, `expected` định lượng và `downstream`:

```json
{
  "systemName": "Paradise HRM / CRM",
  "pageName": "Sales Pipeline",
  "menuUrl": "https://paradisehrm.com/Tai3/#/KPI/SalesPipeline/Index",
  "createdDate": "21/10/2026",
  "inventory": [
    { "name": "Ô tìm kiếm nhanh", "group": "Toolbar Filter", "selector": "#kanbanSearchInput", "action": "Gõ từ khóa lọc trực tiếp các thẻ cơ hội trên Kanban" },
    { "name": "Nút Xóa tìm kiếm", "group": "Toolbar Filter", "selector": "#btnClearSearch", "action": "Dọn sạch ô tìm kiếm và khôi phục 100% dữ liệu" },
    { "name": "Bộ lọc nhân viên phụ trách", "group": "Toolbar Filter", "selector": "div[id*='EmployeeID']", "action": "Mở popup chọn nhân viên kinh doanh để phân loại lead" },
    { "name": "Cụm nút lọc thời gian", "group": "Toolbar Filter", "selector": ".segmented-item", "action": "Lọc cơ hội theo mốc Hôm nay, Tháng này, Năm nay, Tất cả" },
    { "name": "Nút Làm mới", "group": "Toolbar Action", "selector": "button:has-text('Làm mới')", "action": "Tái nạp dữ liệu tức thì từ CSDL" },
    { "name": "Nút + Thêm mới", "group": "Toolbar CRUD", "selector": "button:has-text('+ Thêm mới')", "action": "Mở modal tạo mới cơ hội bán hàng" }
  ],
  "controlCases": [
    {
      "id": "TC-CTL-02",
      "title": "Kiểm tra Ô Tìm kiếm Nhanh (#kanbanSearchInput) & Lọc Tức thì",
      "objective": "Thẩm định tính năng tìm kiếm theo từ khóa thực tế và khôi phục toàn vẹn dữ liệu",
      "precondition": "Bảng Kanban đang hiển thị đầy đủ N0 = 61 thẻ cơ hội ban đầu",
      "testData": "Từ khóa tìm kiếm thực tế: 'Nguyễn'",
      "steps": [
        "Bước 1: Ghi nhận tổng số thẻ cơ hội ban đầu trên Kanban (N0 = 61 thẻ)",
        "Bước 2: Di chuyển chuột Neon nhập từ khóa 'Nguyễn' vào ô #kanbanSearchInput",
        "Bước 3: Chờ 300ms debounce, kiểm tra danh sách thẻ cơ hội hiển thị trên các cột",
        "Bước 4: Nhấp nút xóa nhanh (#btnClearSearch) để dọn sạch từ khóa",
        "Bước 5: Xác nhận số lượng thẻ cơ hội phục hồi lại trạng thái ban đầu"
      ],
      "expected": "Bảng Kanban lọc tức thì hiển thị đúng 31 thẻ cơ hội chứa từ khóa 'Nguyễn' (khớp với kết quả kiểm tra CSDL). Khi xóa từ khóa, khôi phục đủ 61/61 thẻ ban đầu.",
      "dbQuery": {
        "sql": "SELECT COUNT(*) AS TotalMatches FROM tblCRM_CompanyInfo WHERE (CompanyName LIKE N'%Nguyễn%' OR ContactName LIKE N'%Nguyễn%') AND IsDelete = 0",
        "expectedResult": "TotalMatches = 31 bản ghi"
      }
    },
    {
      "id": "TC-CTL-07",
      "title": "Kiểm tra Bộ Lọc Dropdown 'Chọn Nhân Viên Phụ Trách' Trên Toolbar",
      "objective": "Thẩm định khả năng phân loại và lọc cơ hội theo nhân sự kinh doanh thực tế",
      "precondition": "Tài khoản có quyền xem danh sách nhân sự; Bảng Kanban có N0 = 61 thẻ ban đầu",
      "testData": "Nhân viên kinh doanh thực tế: 'NGUYỄN TẤN CHIẾN' (Mã nhân sự: 013)",
      "steps": [
        "Bước 1: Xác định vị trí nút chọn nhân viên trên Toolbar và ghi nhận N0 = 61 thẻ",
        "Bước 2: Di chuyển chuột Neon nhấp mở hộp thoại DevExtreme Popup 'Chọn nhân viên'",
        "Bước 3: Sử dụng ô tìm kiếm trong popup tìm từ khóa 'Chiến', tick chọn nhân viên NGUYỄN TẤN CHIẾN",
        "Bước 4: Nhấn nút 'Lưu' trên popup, sau đó nhấp nút 'Làm mới' trên Toolbar để đồng bộ CSDL",
        "Bước 5: Thẩm định số lượng thẻ Kanban sau lọc thu hẹp đúng về số thẻ của nhân viên 013",
        "Bước 6: Mở lại popup, bấm 'Xóa chọn' -> bấm 'Lưu' -> bấm 'Làm mới' để khôi phục bảng Kanban"
      ],
      "expected": "Hệ thống lọc chính xác hiển thị đúng 17 thẻ cơ hội thuộc trách nhiệm của Nguyễn Tấn Chiến (Mã: 013). Khi dọn bộ lọc, khôi phục đủ 61/61 thẻ ban đầu.",
      "dbQuery": {
        "sql": "SELECT COUNT(*) AS AssignedLeads FROM tblCRM_CompanyInfo WHERE EmployeeIDs LIKE '%013%' AND IsDelete = 0",
        "expectedResult": "AssignedLeads = 17 thẻ cơ hội"
      }
    }
  ],
  "crudCases": [
    {
      "id": "TC-BIZ-01",
      "title": "Nghiệp vụ Thêm mới Cơ hội Bán hàng Thực tế (Create End-to-End)",
      "objective": "Tạo mới một cơ hội bán hàng hoàn chỉnh, lưu vào CSDL và hiển thị trên cột 'Mới tạo'",
      "precondition": "Mở sẵn modal '+ Thêm mới' trên thanh Toolbar Sales Pipeline",
      "testData": "Tên khách hàng: 'Nguyễn Văn Sync <RandomID>', Công ty: 'Công ty TNHH Pipeline Sync <RandomID>', SĐT: '0977xxxxxx', MST: '99xxxxxx', Giai đoạn: 'Mới tạo'",
      "steps": [
        "Bước 1: Nhập đầy đủ các trường thông tin bắt buộc (*)",
        "Bước 2: Chọn giai đoạn khởi tạo là 'Mới tạo'",
        "Bước 3: Nhấp nút 'Lưu thông tin' và bắt phản hồi API POST HTTP 200",
        "Bước 4: Kiểm tra thẻ cơ hội mới xuất hiện ở vị trí đầu tiên của cột 'Mới tạo'"
      ],
      "expected": "API phản hồi thành công, modal đóng lại, thẻ khách hàng mới xuất hiện ngay trên cột 'Mới tạo' và tổng số thẻ Kanban tăng từ 61 lên 62.",
      "dbQuery": {
        "sql": "SELECT TOP 1 CRM_CustomerID, CompanyName, ContactName FROM tblCRM_CompanyInfo WHERE CompanyName LIKE N'Công ty TNHH Pipeline Sync%' ORDER BY CreatedDate DESC",
        "expectedResult": "Bản ghi mới tồn tại trong bảng tblCRM_CompanyInfo với đầy đủ thông tin vừa nhập."
      }
    }
  ],
  "downstreamMatrix": [
    {
      "sourceAction": "Tạo mới Khách hàng tại 'Dữ liệu khách hàng'",
      "targetTable": "tblCRM_CompanyInfo",
      "readApis": "sp_KPIGetProcessStatus, sp_CRM_Dashboard_Stats",
      "targetScreens": "Sales Pipeline (MnuKPI007), Tổng quan CRM (MnuKPI001)",
      "roles": "Admin (Chien.nguyen), Nhân viên Sale (Tai.Dang), Quản lý (Cuong.Vu)"
    }
  ],
  "flowCases": [
    {
      "id": "TC-FLOW-01",
      "title": "Quy trình Nghiệp vụ Liên Màn hình: TẠO MỚI TẠI DỮ LIỆU KHÁCH HÀNG & ĐỐI SOÁT TỨC THÌ TRÊN SALES PIPELINE",
      "objective": "Kiểm chứng khách hàng vừa tạo tại màn hình nguồn xuất hiện đồng bộ tức thì trên bảng Kanban Sales Pipeline",
      "precondition": "Tài khoản có quyền truy cập cả hai phân hệ Dữ liệu khách hàng và Sales Pipeline",
      "testData": "Khách hàng thử nghiệm: 'Công ty TNHH Pipeline Sync <RandomID>'",
      "steps": [
        "Bước 1: Điều hướng vào menu 'Dữ liệu khách hàng', tạo mới công ty 'Công ty TNHH Pipeline Sync <RandomID>'",
        "Bước 2: Chuyển sang menu 'Sales Pipeline', kiểm tra thẻ khách hàng vừa tạo đã xuất hiện trên cột 'Mới tạo'",
        "Bước 3: Đối soát tính đồng bộ về thông tin liên hệ, SĐT, MST hiển thị trên thẻ"
      ],
      "expected": "Khách hàng vừa tạo tại menu Dữ liệu khách hàng hiển thị ngay lập tức trên cột 'Mới tạo' của Sales Pipeline mà không cần đăng xuất hay xóa cache.",
      "downstream": {
        "targetMenu": "Sales Pipeline (MnuKPI007)",
        "role": "Admin / Quản lý / Sale",
        "verification": "Thẻ 'Công ty TNHH Pipeline Sync <RandomID>' xuất hiện đồng bộ trên bảng Kanban."
      },
      "dbQuery": {
        "sql": "SELECT COUNT(*) FROM tblCRM_CompanyInfo WHERE CompanyName LIKE N'Công ty TNHH Pipeline Sync%'",
        "expectedResult": "Tăng thêm 1 bản ghi so với trước khi tạo."
      }
    }
  ]
}
```

---

## 5. LỆNH CHẠY XUẤT BẢN FILE WORD (.DOCX)

Sau khi chuẩn bị file JSON tạm chứa đầy đủ dữ liệu thực tế và câu lệnh DB đối soát:
```bash
node .agents/skills/scan-page-test-docx/scripts/generate_docx.js temp_spec.json docs/test-specs/<tên_trang>-test-spec.docx
```

### ✅ Tiêu chuẩn nghiệm thu của file DOCX xuất ra:
1. **100% Test Data là giá trị thật** (không có `"N/A"`, không có `"Dữ liệu thực tế trên hệ thống"`).
2. **Kỳ vọng nghiệp vụ định lượng chính xác** (có số lượng cụ thể, có đối soát trước sau).
3. **Mỗi ca kiểm thử bộ lọc đều có đầy đủ câu lệnh CSDL đối soát (`🗄️ Truy vấn CSDL đối soát`)**.
4. **Bảng biểu phân màu sang trọng**: Màu Navy chủ đạo, tiêu đề nổi bật, khối code CSDL màu xanh lá đậm chuẩn chỉ.
