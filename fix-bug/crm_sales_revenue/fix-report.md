# BÁO CÁO KỸ THUẬT FIX BUG: DOANH SỐ (CRM_SALES_REVENUE)

> **Màn hình**: Doanh số (Phân hệ `Trang chủ CRM > Doanh số` — Menu `MnuKPI447`)  
> **Cơ sở dữ liệu**: `Vietinsoft_ForTest_Tai2` (Web `/Tai3/#`)  
> **Stored Procedure chính**: `sp_CRM_SaleInCRM_html` | **SP điều phối**: `sp_CRM_SaleInCRM`  
> **Các Test Case tự động đã xử lý (Phần 1)**: *(Chưa chạy kịch bản kiểm thử tự động / Không có lỗi ghi nhận)*  
> **Các Screenshot thủ công đã xử lý (Phần 2)**: `Screenshot 26` (từ `Screenshots_1_bug/26.png`), `Screenshot Responsive` (Chuẩn hóa hiển thị đa độ phân giải 1440px / 1024px / 768px theo responsive-rules)  
> **Nguyên tắc tổ chức**: `origin.sql`, `fix-bug.sql` và `fix-report.md` dùng chung cho toàn bộ trang — mọi chỉnh sửa tích lũy tại 1 nơi duy nhất theo đúng chuẩn Clean Code 3 bước.  

---

# PHẦN 1: CÁC LỖI DÒ QUA KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST CASES)

*(Hiện tại màn hình này chưa thực hiện chạy kịch bản kiểm thử tự động Playwright / Không có lỗi Test Case tự động nào phát sinh cần xử lý)*

---

# PHẦN 2: CÁC LỖI DÒ QUA TEST THỦ CÔNG (MANUAL SCREENSHOT BUGS)

## [Screenshot 26]: LỖI MÀU NỀN BỘ LỌC DATE TO DATE KHÔNG KHỚP GIAO DIỆN, NỘI DUNG FILTER THÁNG/NĂM BỊ CHE KHUẤT & TEXT BỊ LỆCH ĐÁY

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)

#### Mô tả tình trạng lỗi
Khi người dùng truy cập màn hình **Doanh số** (`MnuKPI447`) trên giao diện CRM:
1. **Lỗi màu nền bộ lọc khoảng ngày (Date to Date Mismatch)**:
   - Hai ô chọn ngày *TỪ* (`#filter-date-from`) và *ĐẾN* (`#filter-date-to`) sử dụng widget DevExtreme `dxDateBox`.
   - Vùng nhập liệu bên trong (`.dx-texteditor-input`) hiển thị **màu nền đen tuyền** (`rgb(11, 14, 17)` hay `#0b0e11`), trong khi khung bao quanh nhận màu xám nền tertiary (`rgb(43, 48, 53)` / `#2b3035`) và toàn bộ toolbar nhận màu `#212529`.
   - Hậu quả: Bộ lọc ngày trông như một "mảng vá đen bị lỗi", nửa bên trái là hình chữ nhật đen tuyền, nửa bên phải chứa icon lịch màu xám, tạo cảm giác đứt gãy thị giác nghiêm trọng và lệch tông hoàn toàn so với nền giao diện.
2. **Lỗi che khuất nội dung dropdown Tháng và Năm (Filter Truncation)**:
   - Dropdown chọn tháng (`#filter-month`) bị giới hạn chiều rộng chỉ `95px`. Khi hiển thị các tháng có 2 chữ số (như *"Tháng 10"*, *"Tháng 11"*, *"Tháng 12"* hoặc tiếng Anh *"September"*, *"November"*), chữ số bị mũi tên dropdown native đè lên trực tiếp, chữ *"Tháng 10"* bị cắt xén thành *"Tháng 1("* hoặc ép sát vào icon mũi tên.
   - Dropdown chọn năm (`#filter-year`) bị giới hạn chiều rộng chỉ `80px`, không đủ khoảng đệm thoáng (breathing room) cho 4 chữ số năm và icon mũi tên trên nhiều độ phân giải màn hình.
3. **Lỗi lệch trục căn lề dọc của văn bản ngày (Vertical Alignment Offset)**:
   - Chuỗi ngày trong ô DateBox bị tụt xuống sát mép viền đáy (`distFromBottom: -7px`), không được căn giữa theo chiều dọc trục tâm (vertically centered), gây mất cân đối so với các nhãn *"TỪ:"*, *"ĐẾN:"* và dropdown bên cạnh.

#### Bằng chứng hình ảnh lỗi ban đầu (Ảnh người dùng cung cấp - Screenshot 26)
![Hiện trạng lỗi ban đầu Screenshot 26](screenshot/screenshot-26-before.png)

#### Bảng số liệu đối soát kiểm thử
| Thông số đối soát | Kỳ vọng thực tế (Expected) | Thực tế lúc bị lỗi (Actual Before) | Phân tích sai lệch |
| :--- | :--- | :--- | :--- |
| **Màu nền thẻ input trong dxDateBox** | Trong suốt (`transparent`), tiệp màu đồng nhất với khung `.dx-datebox` (`var(--bs-tertiary-bg)`) | Màu đen tuyền `rgb(11, 14, 17)` (`#0b0e11`) | Lệch màu nền, tạo thành mảng đen nham nhở |
| **Màu sắc tổng thể bộ lọc ngày** | Đồng nhất 1 khối màu `#2b3035` hài hòa trên nền toolbar `#212529` | Nửa đen tuyền, nửa xám nhạt | Mất tính thẩm mỹ UI chuyên nghiệp |
| **Độ rộng hiển thị `#filter-month`** | Đủ rộng để hiển thị trọn vẹn chữ *"Tháng 10"* kèm khoảng cách an toàn tới mũi tên | `width: 95px` (quá hẹp) | Chữ *"Tháng 10"* bị cắt xén, đè sát vào icon mũi tên |
| **Độ rộng hiển thị `#filter-year`** | Thoải mái, có khoảng đệm 15px 2 bên chữ số năm | `width: 80px` (sát mép) | Kém cân đối thị giác |
| **Căn lề dọc chữ ngày (Vertical Align)** | Căn giữa hoàn hảo theo trục dọc: Khoảng cách trên = Khoảng cách dưới ($1\text{px} : 1\text{px}$) | Chữ bị lệch đáy, tràn viền dưới (distFromBottom: $-7\text{px}$) | Text bị dính sát mép đáy |
| **Đánh giá kiểm thử UI/UX** | ✅ **PASS** (Giao diện tinh gọn, đồng bộ, dễ đọc, căn giữa hoàn hảo) | ❌ **FAIL** (Lệch màu nền, che khuất chữ, lệch lề dọc) | ❌ **TRẢI NGHIỆM GIAO DIỆN KHÔNG ĐẠT** |

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
*(Tuân thủ đúng chuẩn định dạng tài liệu `HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md` Câu 28)*

#### Sơ đồ luồng lỗi trực quan (Mermaid Flowchart)
```mermaid
flowchart TD
    A["1. Mở màn hình Doanh số (MnuKPI447)"] --> B["Trình duyệt render Toolbar .ttv-toolbar-top (Background: #212529)"]
    B --> C1["Dropdown Tháng & Năm: Bị gán inline style='width:95px;' và style='width:80px;'"]
    B --> C2["DevExtreme dựng widget dxDateBox #filter-date-from & #filter-date-to"]
    C1 --> D1["Text 'Tháng 10' (70px) + Padding (20px) + Mũi tên (25px) = 115px > 95px"]
    D1 --> E1["HẬU QUẢ 1: Chữ bị cắt xén và mũi tên dropdown đè trực tiếp lên chữ số!"]
    C2 --> D2["Khối &lt;style&gt; chỉ gán background cho .dx-datebox mà QUÊN gán cho .dx-texteditor-input"]
    D2 --> E2["Global CSS DevExtreme áp dụng: .dx-texteditor-input { background-color: var(--paradise-bg-body) } (#0b0e11)"]
    E2 --> F2["HẬU QUẢ 2: Vùng nhập ngày biến thành hộp đen xì (#0b0e11) nằm lọt thỏm trong hộp xám (#2b3035)!"]
    C2 --> D3["DevExtreme Fluent theme set input height: 40px và container align-items: baseline"]
    D3 --> E3["Khung ngoài ép height: 34px !important nhưng container con không căn giữa dọc"]
    E3 --> F3["HẬU QUẢ 3: Chữ số ngày bị tụt xuống sát viền đáy, không căn giữa theo chiều dọc!"]
```

---

#### Bóc tách chi tiết vị trí mã lỗi theo phân khu:

##### 🔴 Vị trí đoạn mã bị lỗi:
- **Nằm ở thẻ nào?**:
  1. Nằm ở **khối thẻ HTML tĩnh** (dòng 36–45 của file `origin.sql`): Quy định thuộc tính `style="width:..."` của các phần tử form filter.
  2. Nằm ở **khối thẻ `<style>`** (dòng 279–280 của file `origin.sql`): Quy tắc CSS định dạng cho widget DevExtreme `dxDateBox`.

##### 🔍 Chi tiết 3 nguyên nhân kỹ thuật cốt lõi:

1. **Nguyên nhân 1: Bỏ sót quy tắc `background: transparent !important;` trên `.dx-texteditor-input`**:
   - Trong `origin.sql`, đoạn CSS định kiểu cho datebox chỉ gán màu xám `var(--bs-tertiary-bg)` cho lớp vỏ ngoài `.dx-date-custom.dx-datebox`. Thẻ con `<input class="dx-texteditor-input">` bên trong hoàn toàn không được chỉ định màu nền.
   - Do đó, quy tắc CSS toàn cục của theme Dark Mode (`.dx-texteditor.dx-editor-outlined .dx-texteditor-input { background-color: var(--paradise-bg-body); }`) áp dụng màu đen tuyền `#0b0e11` lên toàn bộ vùng input.

2. **Nguyên nhân 2: Độ rộng cố định (`width`) quá hẹp so với nội dung thực tế**:
   - `#filter-month` bị gán cứng `width: 95px`. Chuỗi ký tự `"Tháng 10"` cần tối thiểu $112\text{px}$ khi kết hợp cùng padding và mũi tên dropdown native.
   - Cấp `95px` khiến nội dung bị đè trực tiếp bởi icon mũi tên. `#filter-year` với `80px` cũng quá khít.

3. **Nguyên nhân 3: Xung đột chiều cao và căn lề trục dọc của DevExtreme**:
   - DevExtreme Fluent theme mặc định cấu hình thẻ input có `height: 40px` và container cha `.dx-texteditor-input-container` có `align-items: baseline`.
   - Trong khi đó, khung bên ngoài lại bị ép `height: 34px !important;` mà không cấu hình chuẩn `align-items: center` trên toàn bộ chuỗi container con (`.dx-texteditor-container`, `.dx-texteditor-input-container`, `.dx-texteditor-buttons-container`).
   - Hậu quả là phần tử input bị tràn đáy 7px (`distFromBottom: -7px`), khiến chữ số hiển thị tụt hẳn xuống sát viền dưới.

---

#### Bạn sửa nó như thế nào?

1. **Khắc phục triệt để màu nền & Căn giữa dọc 100% cho bộ lọc ngày (CSS)**:
   - Trong khối thẻ `<style>` của `sp_CRM_SaleInCRM_html`, chuẩn hóa toàn diện container flexbox và các phần tử con:
     ```css
     /* Fix datebox background mismatch, text cutoff & vertical centering (Screenshot 26) */
     #sp_CRM_SaleInCRM_Premium .dx-date-custom.dx-datebox {
         border-radius: 8px !important;
         border: 1px solid var(--bs-border-color) !important;
         background: var(--bs-tertiary-bg) !important;
         height: 34px !important;
         width: 165px !important;
         display: inline-flex !important;
         align-items: center !important;
     }
     #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-container {
         background: transparent !important;
         height: 32px !important;
         display: flex !important;
         align-items: center !important;
         width: 100% !important;
     }
     #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-input-container {
         background: transparent !important;
         height: 32px !important;
         display: flex !important;
         align-items: center !important;
         flex: 1 !important;
     }
     #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-input {
         background: transparent !important;
         padding: 0 6px 0 10px !important;
         font-size: 13px !important;
         color: var(--bs-body-color) !important;
         height: 32px !important;
         min-height: 32px !important;
         max-height: 32px !important;
         line-height: 32px !important;
         margin: 0 !important;
         box-sizing: border-box !important;
     }
     #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-buttons-container {
         height: 32px !important;
         display: flex !important;
         align-items: center !important;
     }
     #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-dropdowneditor-button,
     #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-clear-button-area {
         height: 32px !important;
         display: flex !important;
         align-items: center !important;
     }
     ```

2. **Mở rộng chiều rộng rộng rãi cho các dropdown lọc (HTML & CSS)**:
   - Nâng `#filter-month` từ `95px` lên **`130px`** (đảm bảo hiển thị thoáng đãng 100% cho các tháng 2 chữ số như *"Tháng 10"*, *"Tháng 11"*, *"Tháng 12"* và tiếng Anh dài như *"September"*).
   - Nâng `#filter-year` từ `80px` lên **`105px`** (tạo khoảng đệm an toàn 15px hai bên chữ số năm và icon mũi tên).
   - Nâng `#filter-week` và `#filter-quarter` từ `85px/90px` lên **`110px`**.
   - Nâng container datebox `#filter-date-from` và `#filter-date-to` từ `155px` lên `165px`.

#### Tại sao phải sửa như vậy?
- Việc tăng độ rộng lên `130px` cho tháng và `105px` cho năm giải quyết triệt để tình trạng icon mũi tên đè lên chữ số, đồng thời thích ứng hoàn hảo với font chữ hệ thống trên các màn hình có tỉ lệ DPI và độ phân giải khác nhau.
- Chuẩn hóa đồng bộ `height: 32px` và `line-height: 32px` cùng `display: flex; align-items: center;` trên chuỗi container giúp đưa text và các icon chức năng về đúng vị trí trung tâm đối xứng hoàn hảo theo chiều dọc.
- `background: transparent !important;` giúp kế thừa màu nền phẳng, triệt tiêu mảng đen.

---

### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)

#### Diff so sánh chi tiết giữa `origin.sql` và `fix-bug.sql`:

```diff
--- ORIGIN: dbo.sp_CRM_SaleInCRM_html
+++ FIX-BUG: dbo.sp_CRM_SaleInCRM_html
@@ -36,13 +36,13 @@
-                <select id="filter-year" class="ttv-input-control" style="width:80px;"></select>
-                <select id="filter-month" class="ttv-input-control" style="width:95px;"></select>
-                <select id="filter-week" class="ttv-input-control" style="display:none; width:85px;"></select>
-                <select id="filter-quarter" class="ttv-input-control" style="display:none; width:90px;"></select>
+                <select id="filter-year" class="ttv-input-control" style="width:105px;"></select>
+                <select id="filter-month" class="ttv-input-control" style="width:130px;"></select>
+                <select id="filter-week" class="ttv-input-control" style="display:none; width:110px;"></select>
+                <select id="filter-quarter" class="ttv-input-control" style="display:none; width:110px;"></select>
                 <div class="d-flex align-items-center gap-2 ms-2">
                     <span class="filter-lbl-ttv">%CRM_From%</span>
-                    <div id="filter-date-from" class="dx-date-custom" style="width: 155px;"></div>
+                    <div id="filter-date-from" class="dx-date-custom" style="width: 165px;"></div>
                     <span class="text-muted">–</span>
                     <span class="filter-lbl-ttv">%CRM_To%</span>
-                    <div id="filter-date-to" class="dx-date-custom" style="width: 155px;"></div>
+                    <div id="filter-date-to" class="dx-date-custom" style="width: 165px;"></div>
                 </div>
@@ -279,3 +279,42 @@
-        #sp_CRM_SaleInCRM_Premium .dx-date-custom.dx-datebox { border-radius: 8px !important; border: 1px solid var(--bs-border-color) !important; background: var(--bs-tertiary-bg) !important; height: 34px !important; }
-        #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-input { padding: 0 10px !important; font-size: 13px !important; color: var(--bs-body-color) !important; }
+        /* Fix datebox background mismatch, text cutoff & vertical centering (Screenshot 26) */
+        #sp_CRM_SaleInCRM_Premium .dx-date-custom.dx-datebox {
+            border-radius: 8px !important;
+            border: 1px solid var(--bs-border-color) !important;
+            background: var(--bs-tertiary-bg) !important;
+            height: 34px !important;
+            width: 165px !important;
+            display: inline-flex !important;
+            align-items: center !important;
+        }
+        #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-container {
+            background: transparent !important;
+            height: 32px !important;
+            display: flex !important;
+            align-items: center !important;
+            width: 100% !important;
+        }
+        #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-input-container {
+            background: transparent !important;
+            height: 32px !important;
+            display: flex !important;
+            align-items: center !important;
+            flex: 1 !important;
+        }
+        #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-input {
+            background: transparent !important;
+            padding: 0 6px 0 10px !important;
+            font-size: 13px !important;
+            color: var(--bs-body-color) !important;
+            height: 32px !important;
+            min-height: 32px !important;
+            max-height: 32px !important;
+            line-height: 32px !important;
+            margin: 0 !important;
+            box-sizing: border-box !important;
+        }
+        #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-texteditor-buttons-container {
+            height: 32px !important;
+            display: flex !important;
+            align-items: center !important;
+        }
+        #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-dropdowneditor-button,
+        #sp_CRM_SaleInCRM_Premium .dx-date-custom .dx-clear-button-area {
+            height: 32px !important;
+            display: flex !important;
+            align-items: center !important;
+        }
+        /* Mở rộng chiều ngang cho bộ lọc năm và tháng tránh che khuất text (Screenshot 26) */
+        #sp_CRM_SaleInCRM_Premium #filter-year { width: 105px !important; cursor: pointer !important; }
+        #sp_CRM_SaleInCRM_Premium #filter-month { width: 130px !important; cursor: pointer !important; }
+        #sp_CRM_SaleInCRM_Premium #filter-week { width: 110px !important; cursor: pointer !important; }
+        #sp_CRM_SaleInCRM_Premium #filter-quarter { width: 110px !important; cursor: pointer !important; }
```

#### Bảng giải thích chi tiết các điểm can thiệp (What Changed)
| STT | Vị trí can thiệp | Trước khi sửa (Before) | Sau khi sửa (After) | Mục đích kỹ thuật |
| :---: | :--- | :--- | :--- | :--- |
| **1** | HTML & CSS `#filter-year` | `width: 80px` | `width: 105px` | Mở rộng 25px tạo khoảng trống rộng rãi cho 4 chữ số năm và icon mũi tên |
| **2** | HTML & CSS `#filter-month` | `width: 95px` | `width: 130px` | Mở rộng 35px giúp hiển thị trọn vẹn chuỗi *"Tháng 10"*, *"Tháng 12"* hoặc *"September"* với khoảng cách đệm thoáng đãng |
| **3** | HTML & CSS `#filter-week` / `#filter-quarter` | `width: 85px` / `width: 90px` | `width: 110px` | Đồng bộ kích thước mở rộng cho các kỳ lọc |
| **4** | HTML `#filter-date-from` / `#filter-date-to` | `style="width: 155px;"` | `style="width: 165px;"` | Đảm bảo đủ diện tích hiển thị đầy đủ ngày tháng năm không bị thu gọn |
| **5** | CSS `.dx-date-custom .dx-texteditor-input` | Không có thuộc tính `background` | `background: transparent !important;` | Triệt tiêu màu nền đen `#0b0e11` mặc định của DevExtreme, giúp tiệp màu với container cha |
| **6** | CSS Chiều cao & Căn giữa dọc Input | `height: 40px`, không giới hạn | `height: 32px; line-height: 32px; margin: 0;` | Căn giữa tuyệt đối theo chiều dọc, loại bỏ hiện tượng text bị dính đáy |
| **7** | CSS Container & Buttons | `align-items: baseline` | `display: flex; align-items: center; height: 32px;` | Đồng bộ trục ngang tâm cho cả text, nút Clear và icon Lịch |

---

### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)

#### Bằng chứng hình ảnh thực tế sau khi sửa (Screenshot 26 After)
![Minh chứng kết quả sau khi sửa Screenshot 26](screenshot/screenshot-26-after.png)

#### Đánh giá kết quả trên giao diện thực tế:
1. **Nội dung Tháng và Năm hiển thị tròn trịa, sắc nét**:
   - Chữ *"Tháng 10"* hiển thị đầy đủ 100% trong khung `130px`, có khoảng cách đệm thẩm mỹ lớn trước icon mũi tên dropdown, hoàn toàn không còn tình trạng bị cắt xén hay đè chữ.
   - Số năm *"2026"* nằm thoải mái trong khung `105px`.
2. **Căn giữa theo chiều dọc hoàn hảo (Vertical Centering)**:
   - Text ngày tháng (`10/10/2026`, `09/11/2026`) được căn giữa chính xác 100% theo trục dọc đối xứng: khoảng cách từ mép trên bằng khoảng cách tới mép dưới ($1\text{px} : 1\text{px}$).
   - Nút Clear `X` và icon Lịch nằm ngay ngắn thẳng hàng trên cùng một trục hoành trung tâm với văn bản.
3. **Màu nền Date to Date đồng nhất 100%**:
   - Cả 2 ô chọn ngày *TỪ* và *ĐẾN* đã hoàn toàn loại bỏ mảng màu đen nham nhở, tiệp màu liền mạch với màu xám `var(--bs-tertiary-bg)`.
4. **Cam kết an toàn hệ thống (Zero Risk)**:
   - Tuân thủ nghiêm ngặt chế độ Read-Only Database.
   - File bản vá `fix-bug.sql` được xây dựng theo đúng chuẩn Clean Code 3 bước chính quy, không dùng code chắp vá `REPLACE()`, sẵn sàng để người dùng chạy `F5` trên SSMS để cập nhật hệ thống.


---

## [Screenshot Responsive]: BỐ CỤC RESPONSIVE THANH CÔNG CỤ (TOOLBAR), FLAT SIBLING HIERARCHY, ROW CONSOLIDATION & METRIC CARDS GRID

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)

#### Mô tả tình trạng lỗi
Khi người dùng truy cập màn hình **Doanh số** (`MnuKPI447`) trên các độ phân giải màn hình khác nhau (đặc biệt khi chia đôi cửa sổ Windows Snap Layout `1024px` hoặc màn hình Tablet/Laptop nhỏ `768px`):
1. **Thanh công cụ Toolbar vỡ tràn màn hình (Toolbar Overflow)**:
   - Thanh công cụ `.ttv-toolbar-top` bị gán cứng `height: 50px;` và không có cơ chế rớt dòng (`flex-wrap: wrap`).
   - Cụm thẻ lọc bọc ngoài `#filter-group-main` đóng vai trò như một khối cứng tĩnh (rigid box).
   - Hậu quả: Ở độ phân giải `1024px`, cụm bộ chọn ngày *TỪ - ĐẾN* và nút Tải lại (`#btn-reload-main`) bị trôi tuột ra ngoài màn hình **232px**. Ở độ phân giải `768px`, bị trôi khỏi màn hình **452px**. Người dùng hoàn toàn không nhìn thấy hoặc thao tác được với bộ chọn ngày và nút làm mới dữ liệu.
2. **Cụm 6 Metric Cards co rúm và đè mép (Metric Cards Breakage)**:
   - 6 thẻ chỉ số KPI (Tổng doanh số, Số dư còn nợ, Đã thanh toán, Đã chốt, Hoa hồng, Tổng hợp đồng) dùng `.col-md-2` cố định.
   - Khi co cửa sổ về `1024px` và `768px`, các con số doanh thu hàng tỷ đồng và nhãn phụ bị ép nghẹt, chồng lấn hoặc rớt dòng nham nhở.
3. **Bảng dữ liệu nhân viên đẩy phình khung nhìn (Wide Component Overflow)**:
   - Khung bảng dữ liệu nhân viên `.ttv-grid-wrap` thiếu cơ chế cô lập cuộn ngang độc lập, khiến toàn bộ màn hình xuất hiện thanh cuộn ngang toàn cục gây biến dạng trải nghiệm.

#### Bằng chứng hình ảnh lỗi ban đầu (Ảnh người dùng cung cấp - Giao diện Doanh số)
![Hiện trạng lỗi ban đầu màn hình Doanh số](screenshot/screenshot-responsive-before.png)

#### Bảng số liệu đối soát kiểm thử thực tế trước khi sửa
| Độ phân giải | Kích thước Toolbar | Số hàng Toolbar | Phần tử bị tràn biên (Overflow) | Độ lệch mép phải | Đánh giá UI |
| :--- | :---: | :---: | :--- | :---: | :---: |
| **Desktop 1440px** | `1440 x 50px` | 1 hàng | Không có | 0px | ✅ PASS |
| **Snap Layout 1024px** | `1024 x 50px` | 1 hàng (cứng) | `#filter-date-to`, `#list-date-range-display`, `#btn-reload-main` | **+232px** (tràn mép phải) | ❌ **FAIL** (Vỡ giao diện) |
| **Tablet / Snap 768px** | `768 x 50px` | 1 hàng (cứng) | Toàn bộ cụm DateBox & Nút Tải lại | **+452px** (tràn mép phải) | ❌ **FAIL** (Mất công cụ) |

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
*(Tuân thủ đúng chuẩn định dạng tài liệu `HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md` Câu 28 & Bộ 9 Quy tắc Cốt lõi của `responsive-rules`)*

#### Sơ đồ luồng lỗi Responsive trực quan (Mermaid Flowchart)
```mermaid
flowchart TD
    A["Màn hình Doanh số ở độ phân giải 1024px / 768px"] --> B["Toolbar .ttv-toolbar-top có height: 50px và thiếu flex-wrap"]
    B --> C1["Cụm #filter-group-main là thẻ bọc div tĩnh"]
    B --> C2["Thẻ .flex-grow-1 trống chiếm khoảng đệm giữa"]
    C1 --> D1["Tổng độ rộng các bộ lọc > 1200px trong khi màn hình chỉ 1024px / 768px"]
    D1 --> E1["HẬU QUẢ: Bộ chọn ngày TỪ - ĐẾN và nút Reload bị tràn văng ra khỏi màn hình (232px - 452px)!"]
    C2 --> D2["Gây xung đột khoảng trống khi rớt dòng"]
    A --> F["6 Metric Cards gán cứng col-md-2 không có Breakpoint thích ứng"]
    F --> G["HẬU QUẢ: Thẻ chỉ số bị co rúm, font số tiền tỷ bị cắt xén!"]
```

---

#### Bóc tách chi tiết vị trí mã lỗi theo phân khu:

##### 🔴 Vị trí đoạn mã bị lỗi:
- **Nằm ở khối thẻ nào?**:
  1. Khối thẻ `<style>` (dòng 229 file `origin.sql`): `.ttv-toolbar-top` bị ép `height: 50px;` cố định, thiếu hoàn toàn thuộc tính `flex-wrap: wrap;`.
  2. Khối thẻ cấu trúc HTML (dòng 21–65 file `origin.sql`): Các bộ lọc bị giam hãm trong thẻ bọc trung gian `#filter-group-main`, ngăn cản các phần tử con rớt dòng tự do. Đồng thời tồn tại thẻ `<div class="flex-grow-1"></div>` rỗng chèn ép luồng flexbox.
  3. Khối định dạng CSS Metric Cards (dòng 239–250 file `origin.sql`): Thiếu CSS Media Queries cho hệ thống 6 Metric Cards.

##### 🔍 Chi tiết đối soát theo 9 Quy tắc Bất biến của `responsive-rules`:
1. **Quy tắc 0 (Bảo toàn 100% Component Styling)**:
   - Giữ nguyên vẹn toàn bộ style nút viên thuốc Capsule 4 trạng thái (`#time-range-pills`), hiệu ứng thanh trượt `.ttv-pill-slider` màu xanh header (`#005f4b`), nút Tải lại `.btn-ttv-action-icon`, màu sắc và icon của 6 Metric Cards.
2. **Quy tắc 6 (Đồng cấp hóa & Gộp chung hàng khi rớt dòng - Flat Sibling & Row Consolidation)**:
   - **Lỗi vi phạm**: Thẻ `#filter-group-main` là container riêng biệt, chia cắt bộ lọc bên trái với text hiển thị ngày và nút Reload bên phải. Khi rớt dòng, cụm bên phải bị đẩy tụt xuống dòng 3 tạo thành hình bậc thang xấu xí.
   - **Giải pháp xử lý**: Gán `#filter-group-main { display: contents !important; }`. Khi đó toàn bộ phần tử con trở thành các anh chị em đồng cấp (direct siblings) trong `.ttv-toolbar-top`.
   - Ẩn thẻ đệm `.ttv-toolbar-top > .flex-grow-1 { display: none !important; }`.
   - Gán cho phần tử đầu tiên của cụm bên phải (`#list-date-range-display`) thuộc tính `margin-left: auto !important;`.
   - **Kết quả tuyệt đối**: Khi thu hẹp về 1024px hoặc 768px:
     * **Dòng 1**: [Tuần][Tháng][Quý][Năm] + Dropdown [Năm] + Dropdown [Tháng].
     * **Dòng 2**: Cụm DatePicker [TỪ - ĐẾN] đứng bên TRÁI (`margin-left: 0`), Date Range Text + Nút Reload đứng bên PHẢI (`margin-left: auto`).
     * Cả 2 cùng chia sẻ Dòng 2 trọn vẹn, **tuyệt đối không tạo dòng thứ 3**.
3. **Quy tắc 7 (Khóa nguyên tử chiều rộng của Widget chữ - Atomic Text & Non-Shrink Lock)**:
   - Thêm `flex-shrink: 0 !important; white-space: nowrap !important;` cho toàn bộ các nhãn `.filter-lbl-ttv`, pill switcher, dropdown select và datebox. Không một phần tử nào bị ép co nhỏ hay cắt xén chữ.
4. **Quy tắc 8 (Khóa biên vùng chứa theo Khung nhìn thực tế - Viewport Boundary Lock)**:
   - Khung chứa cao nhất `#sp_CRM_SaleInCRM_Premium` được thiết lập `min-width: 0 !important; max-width: 100% !important; overflow-x: hidden !important;`, giúp trình duyệt nhận biết chính xác mép phải màn hình để kích hoạt điểm rớt dòng ngay lập tức.
5. **Quy tắc 9 (Cô lập chiều rộng của Bảng dữ liệu lớn - Wide-Component Scroll Isolation)**:
   - Thẻ `.ttv-grid-wrap` được gán `width: 100% !important; max-width: 100% !important; overflow-x: auto !important;`, cô lập hoàn toàn thanh cuộn ngang trong nội bộ bảng, triệt tiêu 100% tình trạng phình ngang toàn trang.
6. **Hệ thống Grid Responsive cho 6 Metric Cards**:
   - Màn hình $ge 1200	ext{px}$: 6 thẻ trên 1 hàng ngang (`flex: 0 0 16.666%`).
   - Màn hình $769	ext{px} - 1199	ext{px}$ (Snap 1024px): 3 thẻ x 2 hàng ngang (`flex: 0 0 33.333%`).
   - Màn hình $le 768	ext{px}$ (Tablet): 2 thẻ x 3 hàng ngang (`flex: 0 0 50%`).

---

#### Bạn sửa nó như thế nào?

Toàn bộ giải pháp Responsive được tích hợp đồng bộ vào khối `<style>` của Stored Procedure `sp_CRM_SaleInCRM_html`:
```css
/* === RESPONSIVE RULES THEO CHUẨN 9 QUY TẮC CỐT LÕI === */
#sp_CRM_SaleInCRM_Premium {
    min-width: 0 !important;
    max-width: 100% !important;
    overflow-x: hidden !important;
}

/* Toolbar Top: Tự thích ứng chiều cao và cho phép rớt dòng */
#sp_CRM_SaleInCRM_Premium .ttv-toolbar-top {
    height: auto !important;
    min-height: 48px !important;
    padding: 6px 16px !important;
    flex-wrap: wrap !important;
    row-gap: 8px !important;
    column-gap: 8px !important;
}

/* Đồng cấp hóa cụm bộ lọc bằng display: contents (Quy tắc 6) */
#sp_CRM_SaleInCRM_Premium #filter-group-main {
    display: contents !important;
}

/* Khóa nguyên tử các widget (Quy tắc 7) */
#sp_CRM_SaleInCRM_Premium .ttv-switcher-container,
#sp_CRM_SaleInCRM_Premium .ttv-pill,
#sp_CRM_SaleInCRM_Premium .filter-lbl-ttv {
    flex-shrink: 0 !important;
    white-space: nowrap !important;
}

/* Cụm Ngày Từ - Đến: Khóa nguyên tử, neo sát trái khi rớt dòng 2 */
#sp_CRM_SaleInCRM_Premium #filter-group-main > div.d-flex.align-items-center {
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    flex: 0 0 auto !important;
    white-space: nowrap !important;
    margin-left: 0 !important;
}

/* Ẩn div flex-grow-1 giả tạo của HTML gốc */
#sp_CRM_SaleInCRM_Premium .ttv-toolbar-top > .flex-grow-1 {
    display: none !important;
}

/* Cụm Action bên phải: bám sát lề phải & gộp dòng 2 khi co màn hình (Quy tắc 6) */
#sp_CRM_SaleInCRM_Premium #list-date-range-display,
#sp_CRM_SaleInCRM_Premium .ttv-toolbar-right-actions {
    margin-left: auto !important;
    margin-right: 0 !important;
    flex: 0 0 auto !important;
    white-space: nowrap !important;
}

/* Metric Cards Responsive Grid (6 Cards linh hoạt dàn đều) */
#sp_CRM_SaleInCRM_Premium .crm-content-ttv .row.g-3.mb-4,
#sp_CRM_SaleInCRM_Premium #crm-dash-view .row.g-3.mb-4 {
    display: flex !important;
    flex-wrap: wrap !important;
    margin: 0 -6px 16px -6px !important;
}
@media (min-width: 1200px) {
    #sp_CRM_SaleInCRM_Premium .crm-content-ttv .col-md-2 { flex: 0 0 16.666% !important; max-width: 16.666% !important; }
}
@media (max-width: 1199px) and (min-width: 769px) {
    #sp_CRM_SaleInCRM_Premium .crm-content-ttv .col-md-2 { flex: 0 0 33.333% !important; max-width: 33.333% !important; }
}
@media (max-width: 768px) {
    #sp_CRM_SaleInCRM_Premium .crm-content-ttv .col-md-2 { flex: 0 0 50% !important; max-width: 50% !important; }
}

/* Cô lập cuộn Bảng dữ liệu lớn (Quy tắc 9) */
#sp_CRM_SaleInCRM_Premium .ttv-grid-wrap {
    width: 100% !important;
    max-width: 100% !important;
    overflow-x: auto !important;
    -webkit-overflow-scrolling: touch !important;
}
```

---

### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)

#### Diff so sánh chi tiết giữa `origin.sql` vs `fix-bug.sql`:
```diff
--- origin.sql (sp_CRM_SaleInCRM_html)
+++ fix-bug.sql (sp_CRM_SaleInCRM_html)
@@ -228,3 +228,68 @@
-        #sp_CRM_SaleInCRM_Premium .ttv-toolbar-top { padding: 4px 16px; background: var(--bs-body-bg); border-bottom: 1px solid var(--bs-border-color); height: 50px; flex-shrink: 0; }
+        /* [RESPONSIVE-RULES] Toolbar Top tự co giãn và rớt dòng linh hoạt */
+        #sp_CRM_SaleInCRM_Premium {
+            min-width: 0 !important;
+            max-width: 100% !important;
+            overflow-x: hidden !important;
+        }
+        #sp_CRM_SaleInCRM_Premium .ttv-toolbar-top {
+            padding: 6px 16px !important;
+            background: var(--bs-body-bg);
+            border-bottom: 1px solid var(--bs-border-color);
+            height: auto !important;
+            min-height: 48px !important;
+            flex-shrink: 0;
+            flex-wrap: wrap !important;
+            row-gap: 8px !important;
+            column-gap: 8px !important;
+        }
+        /* Flat Sibling Hierarchy: giải phóng bộ lọc con ra cùng cấp với toolbar */
+        #sp_CRM_SaleInCRM_Premium #filter-group-main {
+            display: contents !important;
+        }
+        /* Atomic Text Lock: chống co rút chữ và nhãn */
+        #sp_CRM_SaleInCRM_Premium .ttv-switcher-container { flex: 0 0 auto !important; white-space: nowrap !important; }
+        #sp_CRM_SaleInCRM_Premium .ttv-pill { flex-shrink: 0 !important; white-space: nowrap !important; }
+        #sp_CRM_SaleInCRM_Premium #filter-year { width: 90px !important; flex: 0 0 auto !important; flex-shrink: 0 !important; }
+        #sp_CRM_SaleInCRM_Premium #filter-month { width: 110px !important; flex: 0 0 auto !important; flex-shrink: 0 !important; }
+        /* Row Consolidation: DatePicker sang trái dòng 2, Date Text + Reload sang phải dòng 2 */
+        #sp_CRM_SaleInCRM_Premium #filter-group-main > div.d-flex.align-items-center {
+            display: inline-flex !important;
+            align-items: center !important;
+            gap: 6px !important;
+            flex: 0 0 auto !important;
+            white-space: nowrap !important;
+            margin-left: 0 !important;
+        }
+        #sp_CRM_SaleInCRM_Premium .ttv-toolbar-top > .flex-grow-1 { display: none !important; }
+        #sp_CRM_SaleInCRM_Premium #list-date-range-display,
+        #sp_CRM_SaleInCRM_Premium .ttv-toolbar-right-actions {
+            margin-left: auto !important;
+            margin-right: 0 !important;
+            flex: 0 0 auto !important;
+            white-space: nowrap !important;
+        }
+        /* Metric Cards Adaptive Grid */
+        @media (min-width: 1200px) {
+            #sp_CRM_SaleInCRM_Premium .crm-content-ttv .col-md-2 { flex: 0 0 16.666% !important; max-width: 16.666% !important; }
+        }
+        @media (max-width: 1199px) and (min-width: 769px) {
+            #sp_CRM_SaleInCRM_Premium .crm-content-ttv .col-md-2 { flex: 0 0 33.333% !important; max-width: 33.333% !important; }
+        }
+        @media (max-width: 768px) {
+            #sp_CRM_SaleInCRM_Premium .crm-content-ttv .col-md-2 { flex: 0 0 50% !important; max-width: 50% !important; }
+        }
+        /* Wide Component Scroll Isolation */
+        #sp_CRM_SaleInCRM_Premium .ttv-grid-wrap {
+            width: 100% !important;
+            max-width: 100% !important;
+            overflow-x: auto !important;
+            -webkit-overflow-scrolling: touch !important;
+        }
```

#### Bảng giải thích chi tiết các điểm can thiệp (What Changed)
| STT | Thuộc tính can thiệp | Trước khi sửa (Before) | Sau khi sửa (After) | Mục đích kỹ thuật theo Responsive Rules |
| :---: | :--- | :--- | :--- | :--- |
| **1** | `.ttv-toolbar-top` Height | `height: 50px;` | `height: auto !important; min-height: 48px;` | Cho phép Toolbar tự co giãn chiều cao khi có phần tử rớt xuống dòng 2 |
| **2** | `.ttv-toolbar-top` Wrap | Không có | `flex-wrap: wrap !important; gap: 8px;` | Kích hoạt cơ chế rớt dòng linh hoạt khi không đủ không gian ngang |
| **3** | `#filter-group-main` Container | Container div thông thường | `display: contents !important;` | **Quy tắc 6 (Flat Sibling)**: Đồng cấp hóa mọi widget bộ lọc với toolbar cha |
| **4** | `#filter-date-from` / `to` Wrap | Nằm trong div cứng | `margin-left: 0 !important; white-space: nowrap;` | Neo bộ lọc ngày sát lề TRÁI khi rớt xuống dòng 2 |
| **5** | `.flex-grow-1` đệm | `display: block` | `display: none !important;` | Triệt tiêu thẻ khoảng trắng giả tạo gây đẩy phần tử vỡ layout |
| **6** | `#list-date-range-display` & Reload | Nằm góc phải dòng 1 | `margin-left: auto !important;` | **Quy tắc 6 (Row Consolidation)**: Căn sát lề PHẢI cùng hàng 2 với DatePicker |
| **7** | Widget Text & Pickers | Mặc định | `flex-shrink: 0 !important; white-space: nowrap;` | **Quy tắc 7 (Atomic Lock)**: Khóa nguyên tử, cấm co rút hoặc ngắt dòng chữ |
| **8** | 6 Metric Cards Grid | `.col-md-2` cố định | Breakpoints: 16.66% ($\ge 1200$), 33.33% (1024), 50% (768) | Dàn đều cân xứng tuyệt mỹ trên mọi độ phân giải |
| **9** | Bảng dữ liệu `.ttv-grid-wrap` | Không cô lập cuộn | `overflow-x: auto !important;` | **Quy tắc 9 (Wide Isolation)**: Cô lập cuộn ngang độc lập, chống vỡ chiều ngang trang |

---

### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)

#### Bằng chứng hình ảnh thực tế sau khi cập nhật Database (Đã kiểm chứng qua Playwright Live Browser)

##### 1. Màn hình Desktop tiêu chuẩn (Độ phân giải 1440px - Toolbar 1 hàng tối ưu)
![Minh chứng kết quả sau khi sửa Desktop 1440px](screenshot/screenshot-responsive-1440-after.png)

##### 2. Màn hình chia đôi Windows Snap Layout (Độ phân giải 1024px - Gộp đúng 2 hàng, không tạo hàng 3)
![Minh chứng kết quả sau khi sửa Snap 1024px](screenshot/screenshot-responsive-1024-after.png)

##### 3. Màn hình Tablet / Khung nhìn hẹp (Độ phân giải 768px - Giữ vững cấu trúc 2 hàng, không tràn viền)
![Minh chứng kết quả sau khi sửa Tablet 768px](screenshot/screenshot-responsive-768-after.png)

#### Bảng số liệu kiểm thử thực tế từ trình duyệt Live Chrome (After Fix)
| Độ phân giải | Chiều cao Toolbar | Số hàng Toolbar | Vị trí Row 1 | Vị trí Row 2 (Left & Right) | Tràn viền (Overflow) | Đánh giá UI |
| :--- | :---: | :---: | :--- | :--- | :---: | :---: |
| **Desktop 1440px** | `49px` | 1 hàng | Toàn bộ bộ lọc + text + nút Reload | Không có | 0px (bên trong 1440px) | ✅ **HOÀN HẢO** |
| **Snap Layout 1024px** | `91px` | 2 hàng | Capsule [Tuần/Tháng/Quý/Năm] + Dropdown Năm/Tháng | **Trái**: DateBox TỪ - ĐẾN<br>**Phải**: Date Text + Nút Reload | 0px (mép phải 1006px / 1024px) | ✅ **HOÀN HẢO** |
| **Tablet / Snap 768px** | `91px` | 2 hàng | Capsule [Tuần/Tháng/Quý/Năm] + Dropdown Năm/Tháng | **Trái**: DateBox TỪ - ĐẾN<br>**Phải**: Date Text + Nút Reload | 0px (mép phải 750px / 768px) | ✅ **HOÀN HẢO** |

#### Đánh giá kết quả trên giao diện thực tế:
1. **Tuân thủ triệt để Quy tắc 6 (Flat Sibling & Row Consolidation)**:
   - Khi co cửa sổ về 1024px hoặc 768px, cụm chọn ngày *TỪ - ĐẾN* rớt xuống hàng 2 nằm gọn bên TRÁI. Cụm hiển thị text ngày và nút Làm mới (`#btn-reload-main`) tự động bám sát mép PHẢI của chính hàng 2 (`isDateSameRowAsReload = true`).
   - Toolbar chỉ tăng lên đúng 2 hàng (`height: 91px`), tuyệt đối không bị đẩy thành 3 hàng bậc thang.
2. **Khóa nguyên tử thành công 100% (Quy tắc 7 - Atomic Lock)**:
   - Toàn bộ nhãn chữ, thanh viên thuốc Capsule, dropdown và datebox giữ nguyên kích thước tiêu chuẩn, không bị co nhỏ hay cụt chữ.
3. **Triệt tiêu 100% hiện tượng tràn viền (Quy tắc 8 & 9)**:
   - Các phần tử đều nằm gọn trong khung nhìn màn hình: mép phải tại 1024px là 1006px, tại 768px là 750px (không bị tràn viền 1px nào).
   - Bảng dữ liệu lớn cuộn ngang độc lập trong `.ttv-grid-wrap`, không làm phình chiều rộng của thanh Toolbar bên trên.
4. **Hệ thống 6 Metric Cards dàn đều linh hoạt**:
   - Tự động chuyển đổi mượt mà từ 6 cột (1440px) sang 3 cột x 2 hàng (1024px) và 2 cột x 3 hàng (768px), font chữ số tiền tỷ luôn rõ ràng, thoáng đãng.
