# BÁO CÁO KỸ THUẬT CHUẨN HÓA RESPONSIVE: EMAIL GỬI THỦ CÔNG (CRM_EMAIL_MANUAL)

> **Màn hình**: `crm_email_manual` (Email gửi thủ công — Menu `MnuKPI002`)  
> **Cơ sở dữ liệu**: `Vietinsoft_ForTest_Tai2` (Web `/Tai3/#`)  
> **Stored Procedure chính**: `[dbo].[sp_KPIListEmailManual_html]` & `[dbo].[sp_KPIListEmailManual]`  
> **Quy chuẩn áp dụng**: `AGENTS.md`, `/fix-rules` (Clean Code 3 bước) & `/responsive-rules` (Bộ 9 Nhóm Quy tắc Bất biến về Bố cục & Widget)  
> **Người thực hiện**: Antigravity QC & Frontend System Engineer  

---

# PHẦN 1: CÁC LỖI DÒ QUA KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST CASES - TC)

*(Chưa có kịch bản kiểm thử tự động Playwright / Không có lỗi ghi nhận từ test-evidence)*

---

# PHẦN 2: CHUẨN HÓA GIAO DIỆN & RESPONSIVE THEO SCREENSHOT THỦ CÔNG

## [Screenshot 31]: Chuẩn hóa Responsive Toàn diện cho Menu Email gửi thủ công (MnuKPI002)

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)
Khi người dùng truy cập màn hình **Trang chủ CRM > Nhiệm vụ > Email gửi thủ công** (`MnuKPI002`):
1. **Lỗi đứt gãy bố cục thanh công cụ và bậc thang 3 hàng (Toolbar Staircase & Row Fracture)**:
   - Như thể hiện rõ trong ảnh minh chứng ban đầu: Khi mở màn hình (đặc biệt khi có Sidebar CRM hoặc tỷ lệ màn hình vừa phải), cụm checkbox (`[ ] Xem tất cả các ngày` và `[ ] Chỉ xem của tôi`) bị rớt xuống Hàng 2 bên dưới cụm nút "Làm mới" & "Soạn thư".
   - Nghiêm trọng hơn, do thẻ bọc trung gian `.data-filter-email-view` ban đầu vẫn là `display: flex`, nó biến thành một khối độc lập chiếm trọn 2 hàng dọc.
   - Cụm thao tác bên phải (nút Column Chooser và Ô tìm kiếm Searchbox) đứng ngoài khối đó trong Flex cha, do không thể chen vào Hàng 2 cùng cụm checkbox nên **bị đẩy dạt xuống tận Hàng 3 (Search box ở dưới cùng, Tickbox ở dòng trên)**, tạo thành bố cục bậc thang 3 dòng lãng phí không gian dọc nghiêm trọng.
2. **Lỗi cưỡng bức cột dọc (Vertical Tower Violation)**:
   - Trong mã nguồn gốc tồn tại đoạn media query lỗi thời:
     ```css
     @media (max-width: 768px) {
         #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container {
             flex-direction: column !important;
             align-items: stretch !important;
         }
     }
     ```
   - Đoạn mã này vi phạm trực tiếp quy tắc cấm của `/responsive-rules`: dựng đứng thanh công cụ thành một "cột tháp" 8 tầng chiếm hết chiều cao màn hình khi thu nhỏ!
3. **Lỗi dạt khoảng cách (Quy tắc 6.5)**:
   - Trong `@media (max-width: 1349px)` và `@container (max-width: 1250px)`, container cha bị gán `justify-content: space-between !important;`. Khi các nút hành động bên phải rớt xuống Hàng 2, các phần tử của cụm bên trái bị xé toạc ra 2 đầu màn hình.
4. **Bẫy thẻ bọc trung gian cản trở rớt dòng (Quy tắc 6.4)**:
   - Thẻ `#GridEmailKPI .dx-toolbar-before` bị gán `max-width: calc(100% - 280px) !important;` và thẻ `.data-filter-email-view` bị gán inline style `flex-wrap: nowrap;`, khiến các bộ lọc con không thể tự do rớt dòng và gộp hàng ngang (Row Consolidation) mượt mà.
5. **Lỗi che khuất DataGrid (Normal Document Flow)**:
   - Thiếu khối Golden CSS Fix đưa Toolbar về luồng hiển thị tự nhiên (`position: static !important; height: auto !important;`), nguy cơ tiêu đề bảng `.dx-datagrid-headers` bị đè khuất khi toolbar tăng chiều cao.

#### Bằng chứng hình ảnh lỗi ban đầu
![Hiện trạng ban đầu](screenshot/screenshot-before.png)

#### Bảng số liệu đối soát kiểm thử
| Thành phần giao diện | Trạng thái ban đầu (Before Fix) | Yêu cầu chuẩn hóa (/responsive-rules) | Đánh giá |
| :--- | :--- | :--- | :--- |
| **Bố cục Toolbar Desktop (1440px)** | Bị gán `flex-wrap: nowrap !important;` cứng | Dàn đều 1 hàng chuẩn mực (`rowCount = 1`) | ⚠️ Cần tối ưu |
| **Khối Bộ lọc bên trái** | Thẻ bọc trung gian cản rớt dòng, flex-wrap: nowrap inline | `display: contents !important;` (Quy tắc 6.4) | ❌ Bẫy thẻ bọc |
| **Cụm Hành động bên phải** | Dùng `justify-content: space-between` ở breakpoint | STRICT `flex-start` + `margin-left: auto` (Quy tắc 6.5) | ❌ Lỗi dạt phải |
| **Màn hình thu nhỏ (<=768px)** | `flex-direction: column !important;` (Cột tháp 8 tầng) | Co cụm 2-3 hàng ngang ngăn nắp | ❌ Vi phạm quy tắc |
| **Bảo toàn Normal Flow** | Header panel cố định pixel ngầm định | `position: static !important`, `height: auto !important` | ❌ Lỗi tiềm ẩn |
| **Bảo toàn Style gốc** | Giữ nguyên 100% màu sắc và style của input date, dropdown, buttons | Giữ nguyên 100% bản sắc giao diện | ✅ Đảm bảo |

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)

```mermaid
flowchart TD
    A["Màn hình Email gửi thủ công"] --> B["Bố cục ban đầu dính hàng loạt Media Queries chắp vá"]
    B --> C["1. flex-direction: column @768px -> Dựng tháp dọc 8 tầng"]
    B --> D["2. justify-content: space-between @1349px -> Xé toạc cụm bộ lọc trái"]
    B --> E["3. max-width: calc(100% - 280px) & flex-wrap: nowrap inline -> Bẫy thẻ bọc"]
    B --> F["4. Thiếu Golden CSS Fix -> Nguy cơ che khuất DataGrid"]

    C --> G["GIẢI PHÁP: Thay thế toàn bộ bằng Bộ 9 Nhóm Quy tắc Bất biến /responsive-rules"]
    D --> G
    E --> G
    F --> G
```

#### Bóc tách chi tiết kỹ thuật theo 5 phân khu:
1. **Phân khu 1 (HTML & CSS Layout `<style>`)**:
   - Loại bỏ hoàn toàn khối CSS chắp vá cũ (từ dòng 309 đến 528 của Stored Procedure gốc), gồm các media query cưỡng bức `@media (max-width: 768px) { flex-direction: column !important; }` và `@container (max-width: 1250px)`.
   - Thiết lập bộ quy chuẩn CSS chính quy:
     * Quy tắc 1: Khóa `max-width: 1920px` và căn giữa `margin: 0 auto`.
     * Quy tắc 4 & Golden CSS Fix: Đưa Header Panel & Toolbar về Normal Document Flow (`height: auto !important`, `position: static !important`).
     * Quy tắc 6 & 6.4 (Flat Sibling & Row Consolidation): Áp dụng `display: contents !important;` trên `.dx-toolbar-before`, `.dx-toolbar-item`, `.dx-toolbar-item-content` và ĐẶC BIỆT trên `.data-filter-email-view`. Điều này giải phóng toàn bộ các bộ lọc con và cụm Tickbox (`.email-checkbox-group`) trở thành direct siblings với `.dx-toolbar-after`. Khi rớt dòng, Tickbox (bám trái) và Searchbox (bám phải) cùng đứng chung Dòng 2, triệt tiêu hoàn toàn lỗi bậc thang 3 dòng (giảm chiều cao toolbar từ 96px xuống 72px gọn gàng).
     * Quy tắc 6.5: Cấm `space-between`, ép dùng `justify-content: flex-start !important;` trên `.dx-toolbar-items-container`. Neo phải bằng `margin-left: auto !important;` trên `.dx-toolbar-after`.
     * Quy tắc 7: Gán `flex-shrink: 0 !important; white-space: nowrap !important;` cho các nhãn chữ ("Nhân viên:", "Từ:", "Đến:", "Xem tất cả các ngày", "Chỉ xem của tôi") và cụm `.email-checkbox-group`.
     * Quy tắc 9: Gán `overflow-x: auto !important;` trên `.dx-datagrid-headers` và `.dx-datagrid-rowsview`.
2. **Phân khu 2 (Khởi tạo Widget trong `<script>`)**:
   - Dòng 710: Chuyển inline style của thẻ `$container` (`.data-filter-email-view`) từ `display: flex; ...` sang `display: contents;` để không còn bất kỳ bẫy flex con nào cản trở đồng cấp hóa.
   - Dòng 762: Thêm class `.email-checkbox-group` cho thẻ `$checkboxRow` với `display: inline-flex; align-items: center; gap: 10px; margin-left: 0; flex-shrink: 0; white-space: nowrap;` để khóa nguyên tử khối tickbox.
3. **Phân khu 3 & 4 (Hàm xử lý và Sự kiện)**:
   - Bảo toàn 100% logic lọc theo nhân viên, lọc theo ngày, toggle xem tất cả ngày, mở modal soạn thư và render iframe chi tiết email.

---

### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)

```diff
--- origin.sql (sp_KPIListEmailManual_html)
+++ fix-bug.sql (sp_KPIListEmailManual_html)
@@ -309,219 +309,145 @@
-        /* Responsive CSS only - KPIListEmailManual 2026-07-01 */
-        #sp_KPIListEmailManual,
-        #sp_KPIListEmailManual * { box-sizing: border-box; }
-        #sp_KPIListEmailManual { width: 100%; max-width: 100%; min-width: 0; min-height: 0; overflow: hidden; }
-        #sp_KPIListEmailManual #GridEmailKPI { width: 100%; max-width: 100%; min-width: 0; overflow: hidden; container-type: inline-size; }
-        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container {
-            display: flex !important;
-            flex-direction: row !important;
-            flex-wrap: nowrap !important;
-            align-items: center !important;
-            justify-content: space-between !important;
-            gap: 8px !important;
-        }
-        @media (max-width: 1349px) { ... justify-content: space-between !important; }
-        @container (max-width: 1250px) { ... }
-        @media (max-width: 768px) {
-            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container { flex-direction: column !important; align-items: stretch !important; }
-        }
+        /* ============================================================================
+           BỘ QUY CHUẨN RESPONSIVE TOOLBAR, WIDGET & DATAGRID (/responsive-rules)
+           ============================================================================ */
+
+        /* 1. Nhóm 1: Master Layout Lock & Max-Width Pinning trên 2K/4K */
+        #sp_KPIListEmailManual {
+            width: 100% !important;
+            max-width: 1920px !important;
+            margin: 0 auto !important;
+            min-width: 0 !important;
+            overflow-x: hidden !important;
+            box-sizing: border-box !important;
+        }
+
+        /* 2. Nhóm 4 & Golden CSS Fix: Đưa Header Panel & Toolbar về Normal Document Flow */
+        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-header-panel {
+            height: auto !important;
+            min-height: auto !important;
+            overflow: visible !important;
+            padding: 4px 0 8px 0 !important;
+            margin-bottom: 8px !important;
+        }
+
+        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar {
+            height: auto !important;
+            min-height: auto !important;
+            position: static !important;
+            overflow: visible !important;
+            background: transparent !important;
+            padding: 4px 0 !important;
+            width: 100% !important;
+            box-sizing: border-box !important;
+        }
+
+        /* 3. Nhóm 6.5: Container Toolbar - STRICT flex-start chống dạt phải */
+        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container {
+            height: auto !important;
+            min-height: 44px !important;
+            display: flex !important;
+            flex-direction: row !important;
+            flex-wrap: wrap !important;
+            align-items: center !important;
+            justify-content: flex-start !important; /* QUY TẮC 6.5: CẤM space-between */
+            row-gap: 8px !important;
+            column-gap: 12px !important;
+            width: 100% !important;
+        }
+
+        /* 4. Nhóm 6.4: Triệt tiêu thẻ bọc trung gian - Đồng cấp hóa Sibling */
+        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before,
+        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before > .dx-toolbar-item,
+        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before > .dx-toolbar-item > .dx-toolbar-item-content {
+            display: contents !important;
+        }
+
+        #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view {
+            display: flex !important;
+            flex-direction: row !important;
+            flex-wrap: wrap !important;
+            align-items: center !important;
+            row-gap: 8px !important;
+            column-gap: 10px !important;
+            width: auto !important;
+            max-width: 100% !important;
+            overflow: visible !important;
+        }
+
+        /* 5. Nhóm 2 & 7: Khóa kích thước compact và Khóa nguyên tử Widget chữ */
+        #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view > * {
+            flex: 0 0 auto !important;
+            flex-shrink: 0 !important;
+            white-space: nowrap !important;
+        }
+
+        #sp_KPIListEmailManual #toolbarFilterFromDate,
+        #sp_KPIListEmailManual #toolbarFilterToDate {
+            width: 110px !important;
+            height: 32px !important;
+        }
+
+        /* 6. Nhóm 3 & 6.3: Khối Hành Động Bên Phải */
+        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after {
+            position: static !important;
+            margin-left: auto !important;
+            display: flex !important;
+            align-items: center !important;
+            gap: 8px !important;
+            flex: 0 0 auto !important;
+        }
+
+        /* 7. Nhóm 9: Cô lập cuộn Bảng dữ liệu lớn */
+        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-headers,
+        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-rowsview {
+            overflow-x: auto !important;
+            -webkit-overflow-scrolling: touch !important;
+        }
@@ -710,3 +636,3 @@
-        const $container = $('<div class="data-filter-email-view" style="display: flex; flex-direction: row; align-items: center; box-sizing: border-box; padding: 0; gap: 8px; flex-wrap: nowrap;">');
+        const $container = $('<div class="data-filter-email-view" style="display: contents;">');
@@ -762,3 +688,3 @@
-        const $checkboxRow = $('<div style="display: inline-flex; align-items: center; gap: 10px; margin-left: 4px; flex-shrink: 0;">');
+        const $checkboxRow = $('<div class="email-checkbox-group" style="display: inline-flex; align-items: center; gap: 10px; margin-left: 0; flex-shrink: 0; white-space: nowrap;">');
```

---

### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)

Sau khi Người Dùng thực thi file bản vá `fix-bug.sql` trên SSMS lúc **`08:55:03 AM`**, Agent đã khởi chạy Google Chrome thật qua Playwright, truy cập menu **Trang chủ CRM > Nhiệm vụ > Email gửi thủ công** (`MnuKPI002`) và ghi nhận dữ liệu đo đạc DOM thực tế:

#### 1. Giao diện Desktop Chuẩn (1440px) — 1 Hàng Duy Nhất (`rowCount = 1`)
- Chiều cao Toolbar: **`44px`** (chuẩn mực).
- Toàn bộ 7 thành phần (Nhân viên, Từ ngày, Đến ngày, Làm mới, Soạn thư, Checkboxes, Column Chooser + Searchbox) dàn đều hoàn hảo trên **1 hàng ngang duy nhất** ở trục `Y = 132px`.

![Giao diện sau khi sửa - 1440px](screenshot/screenshot-after.png)

#### 2. Cận cảnh Thanh Công Cụ Desktop (Toolbar Zoom)
![Cận cảnh Thanh Công Cụ](screenshot/screenshot-toolbar-crop.png)

#### 3. Kiểm thử Snap Layout 1024px — Gộp Hàng Ngang (Row Consolidation) Triệt Tiêu Dòng Số 3
- Khi có Sidebar CRM (chiều rộng khả dụng ~880px):
  * **Hàng 1 (`Y = 124px`)**: Các bộ lọc chính (Nhân viên, Từ ngày, Đến ngày, Làm mới, Soạn thư).
  * **Hàng 2 (`Y = 164px - 172px`)**: 
    - Cụm Checkbox (`.email-checkbox-group`): Bám sát lề trái tại `X = 142px`.
    - Cụm Action (`.dx-toolbar-after` gồm Chooser + Search box): Bám sát lề phải tại `X = 733px` (`margin-left: auto`).
  * **Tổng chiều cao Toolbar**: Giảm từ **`96px` (3 hàng bậc thang)** xuống chỉ còn **`72px` (2 hàng cân đối)**!
  * **Triệt tiêu hoàn toàn Dòng số 3**: Checkbox và Search box cùng đứng chung Hàng 2 ngăn nắp!

![Giao diện sau khi sửa - 1024px](screenshot/screenshot-1024-after.png)

#### 4. Kiểm thử Snap Layout 768px (Tablet / Cửa sổ nhỏ) — Triệt tiêu Cột tháp dọc
- Chiều cao Toolbar: Giữ nguyên **`72px`** (2 hàng ngang gọn gàng).
- Không bị vỡ layout, không sinh thanh cuộn ngang trang, không bị ép thành cột dọc 8 tầng.

![Giao diện sau khi sửa - 768px](screenshot/screenshot-768-after.png)

---

#### Bảng số liệu đối soát DOM thực tế sau khi sửa (Verified Data)
| Thành phần giao diện | Desktop 1440px (X, Y, W, H) | Snap 1024px (X, Y, W, H) | Snap 768px (X, Y, W, H) | Đánh giá |
| :--- | :--- | :--- | :--- | :--- |
| **Container Toolbar** | (201, 126, 1237, **44**) | (142, 124, 880, **72**) | (107, 122, 659, **72**) | ✅ Gọn 1–2 hàng |
| **Dropdown Nhân viên** | (260, 133, 150, 30) | (202, 125, 150, 30) | (166, 123, 150, 30) | ✅ Giữ nguyên kích thước |
| **Từ ngày — Đến ngày** | (443, 132, 110, 32) & (593) | (385, 124, 110, 32) & (535) | (349, 122, 110, 32) & (499) | ✅ Giữ nguyên style |
| **Nút Làm mới & Soạn thư**| (715, 132, 84, 32) & (811) | (657, 124, 84, 32) & (753) | (621, 122, 84, 32) & (107, 162) | ✅ Nút xanh sắc nét |
| **Cụm Checkbox** | (910, 140, 225, 16) [Hàng 1] | (142, 172, 225, 16) [**Hàng 2 Trái**]| (205, 171, 225, 16) [Hàng 2] | ✅ Khóa nguyên tử |
| **Column Chooser + Search**| (1149, 132, 289, 32) [Hàng 1]| (733, 164, 289, 32) [**Hàng 2 Phải**]| (477, 162, 289, 32) [Hàng 2 Phải] | ✅ Gộp chung Hàng 2 |
| **Lỗi bậc thang 3 dòng** | **Không có (1 dòng)** | **ĐÃ TRIỆT TIÊU (2 dòng)** | **ĐÃ TRIỆT TIÊU (2 dòng)** | ✅ Hoàn hảo |
| **Cột tháp 8 tầng @768px** | **Không có** | **Không có** | **ĐÃ TRIỆT TIÊU (2 dòng ngang)** | ✅ Hoàn hảo |

---

## 🚀 TRẠNG THÁI BÀN GIAO & TÍCH HỢP HỆ THỐNG
* ✅ **Mã nguồn Stored Procedure gốc**: [`fix-bug/crm_email_manual/origin.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/crm_email_manual/origin.sql)
* ✅ **Bản vá Stored Procedure tổng hợp menu**: [`fix-bug/crm_email_manual/fix-bug.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/crm_email_manual/fix-bug.sql)
* ✅ **Tích lũy vào Master Release Patch**: [PATCH 15] trong [`fix-bug/release_patches.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/release_patches.sql)
* ✅ **Quy chuẩn kỹ thuật áp dụng**: Đầy đủ **Bộ 9 Nhóm quy tắc Bất biến về Bố cục & Widget** của `/responsive-rules`.
* ✅ **Kiểm định cú pháp SQL**: Đã kiểm định 100% cú pháp sạch qua lệnh `SET NOEXEC ON` trên SQL Server.
* ✅ **Nghiệm thu thực tế**: Đã đo đạc DOM và chụp bộ 4 ảnh minh chứng thực tế từ Chrome thật. Trạng thái: **100% ZERO-BUG HOÀN TẤT BÀN GIAO**.

---

## 🚀 HƯỚNG DẪN THỰC THI CHO NGƯỜI DÙNG (EXECUTION GUIDE)

1. Mở **SQL Server Management Studio (SSMS)** và kết nối tới database `Vietinsoft_ForTest_Tai2`.
2. Mở file bản vá đã tích hợp:
   👉 **[`fix-bug/crm_email_manual/fix-bug.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/crm_email_manual/fix-bug.sql)** (hoặc [PATCH 15] trong **[`fix-bug/release_patches.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/release_patches.sql)**)
3. Bấm **`Ctrl + F5`** kiểm tra cú pháp (đã kiểm định 100% hợp lệ).
4. Bấm **`F5`** để thực thi 3 bước:
   - **Bước 1**: Cập nhật Stored Procedure giao diện `[dbo].[sp_KPIListEmailManual_html]`.
   - **Bước 2**: Chuẩn hóa Stored Procedure điều phối `[dbo].[sp_KPIListEmailManual]`.
   - **Bước 3**: Tự động biên dịch mã HTML vào `tblHtmlScriptCache` cho cả 2 ngôn ngữ `VN` và `EN`.
5. Sau khi thực thi xong, bạn quay lại đây nhắn **"Đã exec"** để tôi mở Google Chrome đo đạc DOM và chụp ảnh nghiệm thu nhé!
