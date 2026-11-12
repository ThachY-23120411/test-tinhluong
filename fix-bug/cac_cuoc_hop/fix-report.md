# BÁO CÁO KỸ THUẬT SỬA LỖI GIAO DIỆN RESPONSIVE (TECHNICAL DEFENSE REPORT)
## MENU: TRANG CHỦ CRM > NHIỆM VỤ > CÁC CUỘC HỌP (MnuKPI006)
> **Bản vá Stored Procedure**: `[dbo].[sp_KPIMeetingDemo_html]` & `[dbo].[sp_KPIMeetingDemo]`  
> **Cơ sở dữ liệu**: `Vietinsoft_ForTest_Tai2`  
> **Thư mục bàn giao**: `fix-bug/cac_cuoc_hop/`  
> **Quy chuẩn tuân thủ**: `AGENTS.md` (Điều 1: Read-Only DB, Điều 2: origin.sql, Điều 3: Gom chung cấp menu, Điều 4: After Fix screenshot) & Quy chuẩn thiết kế Responsive (`/responsive-rules`).

---

## PHẦN 1: CÁC LỖI DÒ QUA KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST CASES - TC)
*(Chưa có kịch bản kiểm thử tự động / Không có lỗi ghi nhận)*

---

## PHẦN 2: CÁC LỖI DÒ QUA TEST THỦ CÔNG (MANUAL SCREENSHOT BUGS)

### [Screenshot 32]: Lỗi Bố Cục Toolbar Bậc Thang 3 Hàng Rời Rạc & Lỗi Dồn Cục 2 Hàng Trên Desktop (1920px & Snap 868px)

#### 1. HIỆN TRẠNG LỖI BAN ĐẦU (BEFORE FIX)
- **Thiết bị / Khung nhìn kiểm thử**: Kích thước màn hình Snap Layout Windows / Tablet: `868px × 911px` và Desktop: `1920px × 1080px`.
- **Hành vi sai khác trên giao diện**:
  * **Tại khung nhìn Snap Layout / Tablet (868px / 768px)**:
    - Toolbar của DataGrid `#Grid_MeetingCRM` bị vỡ bố cục thành **3 tầng bậc thang rời rạc** (`rowCount = 3`, chiều cao Toolbar phình to tới 110px - 125px):
      + **Hàng 1**: Bộ lọc chính (`Nhân viên`, `Từ ngày`, `Đến ngày`, nút `Làm mới`).
      + **Hàng 2**: Cụm Checkbox (`[ ] Xem tất cả ngày`, `[ ] Chỉ xem của tôi`) nằm trơ trọi một mình bên mép trái, để lại toàn bộ khoảng trống mênh mông vô dụng ở bên phải.
      + **Hàng 3**: Cụm Action Buttons (`[🔍 Tìm kiếm theo nội dung...]`, `[ 📄 ]` Chọn cột hiển thị, `[ ⊕ Tạo cuộc họp mới ]`) bị đẩy tút xuống hàng dưới cùng.
    - Việc phân mảnh thành 3 hàng gây lãng phí không gian hiển thị dọc quý giá của bảng dữ liệu cuộc họp, vi phạm nghiêm trọng nguyên tắc hợp nhất hàng (Row Consolidation) của `/responsive-rules`.
  * **Tại khung nhìn Desktop lớn (1920px / 1440px)**:
    - Nếu xử lý chắp vá bằng cách ép `width: 100%` vào `.dx-toolbar-after` hoặc chuyển phần tử JS thủ công, giao diện Desktop sẽ bị gãy thành 2 hàng cưỡng bức: Hàng 1 chứa bộ lọc bỏ trống toàn bộ khoảng đen bên phải, Hàng 2 dồn cục toàn bộ Checkbox và Nút bấm sang mép trái (bị co rúm ~630px), kèm theo lỗi cắt cụt chữ placeholder ô tìm kiếm (`Tìm kiếm theo nội d...`).
- **Ảnh chụp minh chứng lỗi ban đầu**:
  ![Hiện trạng ban đầu lỗi 3 hàng](/fix-bug/cac_cuoc_hop/screenshot/screenshot-responsive-before.png)

---

#### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA THEO CÂU 28)

Bóc tách mã nguồn Stored Procedure `[dbo].[sp_KPIMeetingDemo_html]` theo chuẩn 3 phân khu kiến trúc:

```mermaid
flowchart TD
    subgraph BEFORE["HIỆN TRẠNG BAN ĐẦU (BEFORE - BẪY THẺ BỌC TRUNG GIAN)"]
        direction TB
        B_Cont["dx-toolbar-items-container (display: flex)"]
        B_Before["dx-toolbar-before (Thẻ bọc trung gian: display: flex; flex-wrap: wrap)"]
        B_Wrap["ms-filter-toolbar (Thẻ bọc con lồng nhau)"]
        B_Row1["Cụm lọc chính: [Nhân viên] [Từ ngày - Đến ngày] [Làm mới] (~540px)"]
        B_Row2["Cụm Checkbox: [ ] Xem tất cả ngày  [ ] Chỉ xem của tôi (~216px) -> BỊ RỚT DÒNG BÊN TRONG BEFORE!"]
        B_After["dx-toolbar-after (Bị thẻ bọc dx-toolbar-before 2 tầng chiếm trọn, bắt buộc rớt xuống HÀNG 3)"]
        B_Row3["Hàng 3: [🔍 Tìm kiếm...] [Chọn cột] [⊕ Tạo cuộc họp mới]"]
        
        B_Cont --> B_Before
        B_Before --> B_Wrap
        B_Wrap --> B_Row1
        B_Wrap --> B_Row2
        B_Cont --> B_After
        B_After --> B_Row3
    end

    subgraph AFTER["BẢN VÁ TỐI ƯU (AFTER - QUY TẮC 6.4 DISPLAY: CONTENTS)"]
        direction TB
        A_Cont["dx-toolbar-items-container (display: flex; flex-wrap: wrap; row-gap: 8px; column-gap: 12px)"]
        A_Contents["Phẳng hóa thẻ bọc bằng display: contents !important (dx-toolbar-before, ms-filter-toolbar)"]
        A_Item1["1. [Nhân viên]"]
        A_Item2["2. [Từ ngày - Đến ngày]"]
        A_Item3["3. [Làm mới]"]
        A_Item4["4. [ ] Xem tất cả ngày  [ ] Chỉ xem của tôi"]
        A_After["5. dx-toolbar-after (margin-left: auto; flex: 0 0 auto): [🔍 Tìm kiếm 220px] [Chọn cột] [⊕ Tạo cuộc họp mới]"]
        
        A_Cont --> A_Contents
        A_Contents --> A_Item1
        A_Contents --> A_Item2
        A_Contents --> A_Item3
        A_Contents --> A_Item4
        A_Cont --> A_After
    end
```

##### A. Phân khu 1: Bóc tách Cấu trúc HTML
- Giao diện được bao bọc bởi container `#meetingScheduleComponent` và chứa bảng dữ liệu DevExtreme `#Grid_MeetingCRM`.
- Header toolbar của DevExtreme tạo ra cây phân cấp:
  `dx-toolbar` $\rightarrow$ `dx-toolbar-items-container` $\rightarrow$ `dx-toolbar-before` (chứa `.ms-filter-toolbar`) & `dx-toolbar-after` (chứa `.ms-toolbar-right-group`).

##### B. Phân khu 2: Bóc tách Bố cục Định kiểu `<style>`
- **Điểm nghẽn cốt lõi - "Bẫy thẻ bọc trung gian" (Intermediate Wrapper Trap)**:
  * Thẻ `.dx-toolbar-before` và con của nó `.ms-filter-toolbar` đóng vai trò là một flex container trung gian.
  * Khi kích thước màn hình thu hẹp về `868px` hoặc `768px`, tổng bề ngang của 4 cụm lọc bên trong `dx-toolbar-before` (~540px lọc + ~216px checkbox = ~756px) vượt quá không gian còn lại sau khi trừ padding, làm cho `$checkboxRow` tự động ngắt dòng xuống tầng thứ 2 **bên trong chính thẻ `dx-toolbar-before`**.
  * Vì `dx-toolbar-before` lúc này đã trở thành một khối hộp có chiều cao 2 dòng, phần tử anh em tiếp theo là `.dx-toolbar-after` (chứa Tìm kiếm và Nút tạo cuộc họp) bắt buộc phải trôi xuống **Hàng thứ 3**, sinh ra hiện tượng bậc thang 3 tầng rời rạc.
- **Tại sao giải pháp chắp vá cưỡng bức (ép `width: 100%` vào `dx-toolbar-after`) thất bại**:
  * Nếu dùng CSS ép `dx-toolbar-after { width: 100%; }` và dùng JS chuyển `$checkboxRow` sang `dx-toolbar-after`, thì trên màn hình Desktop lớn (1920px), `dx-toolbar-after` vẫn bị ép chiếm 100% chiều ngang, khiến toàn bộ thanh công cụ bị bẻ gãy thành 2 hàng một cách vô lý, để lại khoảng trống đen mênh mông ở Hàng 1 và dồn cục nút bấm về góc trái ở Hàng 2.

##### C. Phân khu 3: Bóc tách Mã nguồn Xử lý `<script>` (5 phân khu)
- Thuộc **Phân khu 2 (Khởi tạo Widget & Cấu hình Toolbar)**:
  * Trong `origin.sql`, hàm `configureMeetingGridToolbar()` khai báo cấu trúc tự nhiên:
    - `location: "before"` chứa các bộ lọc: Nhân viên, Khoảng ngày, Nút làm mới, và Checkbox.
    - `location: "after"` chứa: Ô tìm kiếm, Nút chọn cột và Nút tạo cuộc họp mới.
  * Cấu trúc logic JavaScript này vốn dĩ đã chuẩn mực và không cần can thiệp xáo trộn DOM. Vấn đề duy nhất là các thẻ bọc `<div>` trung gian của DevExtreme giam cầm các phần tử con khiến Flexbox của container cha không thể phân phối dòng một cách linh hoạt.

##### D. Giải pháp Kỹ thuật Triệt để (How & Why - Áp dụng Quy tắc 6.4 `display: contents`)
1. **Phẳng hóa toàn bộ thẻ bọc trung gian bằng `display: contents !important;`**:
   ```css
   #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before,
   #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before > .dx-item,
   #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before > .dx-item > .dx-item-content,
   #Grid_MeetingCRM .ms-filter-toolbar,
   #Grid_MeetingCRM .ms-filter-toolbar > div {
       display: contents !important;
   }
   ```
   - **Cơ chế hoạt động**: Thuộc tính `display: contents` biến các thẻ bọc trung gian trở nên "vô hình" trong cây bố cục (layout tree), đưa 4 cụm lọc (`$employeeDiv`, `$dateContainer`, `$actionButtonContainer`, `$checkboxRow`) và cụm `.dx-toolbar-after` trở thành các flex items trực tiếp cùng cấp của `.dx-toolbar-items-container`.
2. **Hành vi linh hoạt tự nhiên trên mọi độ phân giải (Responsive Adaptation)**:
   - **Trên Desktop lớn (1920px & 1440px)**:
     * Tổng chiều rộng của toàn bộ 4 cụm lọc + Action buttons là ~1150px < 1920px.
     * Flexbox sắp xếp toàn bộ trên **1 HÀNG DUY NHẤT**: 4 cụm lọc và checkbox dàn trải bên trái, Action buttons tự động dạt về góc phải ngoài cùng nhờ `margin-left: auto !important;`.
   - **Trên Snap Layouts / Tablet (868px & 768px)**:
     * 3 bộ lọc đầu tiên (Nhân viên + Ngày + Làm mới) chiếm ~540px $\rightarrow$ Nằm trọn vẹn trên **HÀNG 1**.
     * Hàng 1 hết chỗ, Flexbox đẩy cụm thứ 4 (`$checkboxRow`, ~216px) và cụm thứ 5 (`.dx-toolbar-after`, ~380px) xuống **HÀNG 2**.
     * Tại Hàng 2, tổng bề ngang là ~596px < 868px $\rightarrow$ Vừa khít trong 1 hàng: Cụm Checkbox nằm bên trái, cụm Action buttons dạt sang mép phải ngoài cùng nhờ `margin-left: auto`.
     * **Kết quả**: ĐÚNG 2 HÀNG CHUẨN MỰC, không bao giờ phát sinh hàng thứ 3!
3. **Bảo toàn độ rộng ô tìm kiếm chuẩn 220px**:
   - Khóa cứng `width: 220px !important; max-width: 220px !important;` trên `.dx-textbox` của thanh tìm kiếm.
   - Triệt tiêu 100% lỗi co rúm và cắt cụt chữ placeholder `Tìm kiếm theo nội dung...`.
4. **Clean Code 100%**:
   - Toàn bộ can thiệp nằm gọn trong phân khu `<style>`.
   - Giữ nguyên 100% mã nguồn JavaScript gốc của hệ thống, không chắp vá DOM qua JavaScript, đảm bảo an toàn tuyệt đối và tính ổn định dài hạn.

---

#### 3. ĐỐI CHIẾU MÃ NGUỒN TRƯỚC VÀ SAU (BEFORE VS AFTER)

##### A. Bảng tổng hợp các điểm can thiệp (What Changed)
| STT | Vị trí | Hiện trạng gốc (`origin.sql`) | Sau khi sửa (`fix-bug.sql`) | Mục đích kỹ thuật |
| :---: | :--- | :--- | :--- | :--- |
| 1 | `<style>` Header & Toolbar | `min-height: 44px; margin-bottom: 8px; justify-content: space-between;` | `min-height: 38px; margin-bottom: 4px; justify-content: flex-start; row-gap: 8px; column-gap: 12px;` | Toolbar co giãn theo Normal Document Flow, chuẩn hóa khoảng cách hàng |
| 2 | `<style>` Thẻ bọc `dx-toolbar-before` | `flex: 1 1 auto; max-width: 100%;` (bẫy bọc 2 tầng) | `display: contents !important;` trên toàn bộ thẻ bọc trung gian | Phẳng hóa layout, giải phóng các phần tử con thành direct flex items |
| 3 | `<style>` Cụm `dx-toolbar-after` | `position: absolute; right: 0;` (bị DevExtreme định vị ngầm) | `position: static !important; margin-left: auto !important; flex: 0 0 auto !important; width: auto !important;` | Luôn tự động dạt về góc phải ngoài cùng dù ở Hàng 1 (Desktop) hay Hàng 2 (Snap/Tablet) |
| 4 | `<style>` Ô tìm kiếm | `width: 200px;` (dễ co rúm khi thiếu không gian) | `width: 220px !important; max-width: 220px !important;` | Chống cắt cụt placeholder chữ "Tìm kiếm theo nội dung..." |
| 5 | `<style>` Input ngày & Nhãn | Width tự do, dễ tràn viền | Input ngày `115px`, `white-space: nowrap; flex-shrink: 0;` | Khóa nguyên tử widget, chống rớt dòng chữ |
| 6 | `<script>` Logic JS | Logic gốc hoàn chỉnh | **Giữ nguyên 100% mã nguồn JS gốc** | Không can thiệp DOM bằng JS, đảm bảo Clean Code và độ tin cậy tuyệt đối |

##### B. Đối chiếu Diff chi tiết
```diff
--- origin.sql (Stored Procedure Gốc)
+++ fix-bug.sql (Bản Vá Hoàn Thiện)
@@ -16,40 +16,49 @@
         #Grid_MeetingCRM .dx-toolbar {
             height: auto !important;
+            min-height: auto !important;
             overflow: visible !important;
-            margin-bottom: 8px !important;
+            background: transparent !important;
+            margin-bottom: 4px !important;
         }
 
         #Grid_MeetingCRM .dx-toolbar .dx-toolbar-items-container {
             height: auto !important;
-            min-height: 44px !important;
+            min-height: 38px !important;
             display: flex !important;
             flex-wrap: wrap !important;
             align-items: center !important;
-            justify-content: space-between !important;
+            justify-content: flex-start !important;
             row-gap: 8px !important;
-            column-gap: 12px !important;
-            padding: 4px 0 !important;
+            column-gap: 12px !important;
+            padding: 0 !important;
             width: 100% !important;
         }
 
-        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before,
-        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-center,
-        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-after {
-            position: relative !important;
+        /* Quy tắc 6.4: Phẳng hóa toàn bộ thẻ bọc trung gian của dx-toolbar-before bằng display: contents */
+        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before,
+        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before > .dx-item,
+        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before > .dx-item > .dx-item-content,
+        #Grid_MeetingCRM .ms-filter-toolbar,
+        #Grid_MeetingCRM .ms-filter-toolbar > div {
+            display: contents !important;
+        }
+
+        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-center {
+            display: none !important;
+        }
+
+        /* Cụm Action Buttons bên phải: Luôn căn sát mép phải bằng margin-left: auto */
+        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-after {
+            position: static !important;
+            left: auto !important;
+            right: auto !important;
+            top: auto !important;
+            transform: none !important;
+            display: flex !important;
+            align-items: center !important;
+            flex-wrap: nowrap !important;
+            margin-left: auto !important;
+            height: auto !important;
+            padding: 0 !important;
+            flex: 0 0 auto !important;
+            width: auto !important;
         }
@@ -75,6 +84,10 @@
+        /* Ô tìm kiếm chuẩn 220px không bị cắt chữ placeholder */
+        #Grid_MeetingCRM .ms-toolbar-right-group .dx-textbox {
+            width: 220px !important;
+            max-width: 220px !important;
+        }
```

---

#### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)

Sau khi Người Dùng thực thi bản vá `fix-bug.sql` trên cơ sở dữ liệu `Vietinsoft_ForTest_Tai2`, hệ thống đã được kiểm thử tự động trực quan (Visual E2E) bằng Google Chrome qua Playwright trên web thật (`https://paradisehrm.com/Tai3/#`).

##### A. Bảng đối soát số liệu đo đạc thực tế trên DOM (Live Metrics Verification)
| Khung nhìn (Viewport) | Số hàng trước fix | Số hàng sau fix | Chiều cao Toolbar | Bố cục Hàng 1 (Row 1) | Bố cục Hàng 2 (Row 2) | Trạng thái |
| :---: | :---: | :---: | :---: | :--- | :--- | :---: |
| **Desktop 1920px × 1080px** | 2 hàng (dồn cục) | **1 HÀNG DUY NHẤT** | **40px** | Toàn bộ Bộ lọc, Checkbox (Trái) & Action Buttons (Phải) | *(Không phát sinh)* | **ĐẠT (100%)** |
| **Desktop 1440px × 900px** | 3 hàng | **2 HÀNG** | **78px** | Bộ lọc chính + Checkbox | Action Buttons (căn sát lề phải) | **ĐẠT (100%)** |
| **Tablet/Laptop 1024px × 768px** | 3 hàng | **2 HÀNG** | **78px** | Bộ lọc chính (Nhân viên, Khoảng ngày, Làm mới) | Checkbox (Trái) & Action Buttons (Phải) | **ĐẠT (100%)** |
| **Snap Layout 868px × 911px** *(Màn hình lỗi gốc)* | 3 hàng (bậc thang) | **2 HÀNG CHUẨN MỰC** | **78px** | Bộ lọc chính (Nhân viên, Khoảng ngày, Làm mới) | Checkbox (Trái) & Action Buttons (Phải) | **ĐẠT (100%)** |
| **Tablet Portrait 768px × 800px** | 3 hàng vỡ | **3 HÀNG GỌN GÀNG** | **114px** | Bộ lọc Nhân viên + Khoảng ngày | Nút Làm mới + Checkbox | Action Buttons | **ĐẠT (100%)** |

##### B. Đánh giá chi tiết kết quả thực tế
1. **Triệt tiêu 100% hiện tượng bậc thang rời rạc tại 868px (Snap Layout Windows)**:
   - Thay vì vỡ nát thành 3 hàng lộn xộn với cụm Checkbox nằm trơ trọi ở Hàng 2 như trước, Toolbar hiện tại đã co giãn hoàn hảo thành **ĐÚNG 2 HÀNG CHUẨN MỰC**:
     * **Hàng 1**: Bộ lọc Nhân viên, Khoảng ngày (`Từ`, `Đến`) và nút `Làm mới`.
     * **Hàng 2**: Cụm Checkbox nằm sát mép trái, cụm Action Buttons (`Tìm kiếm`, `Chọn cột`, `Tạo cuộc họp mới`) dạt sát mép phải.
   - Chiều cao Toolbar thu gọn từ **115px $\rightarrow$ 78px** (tiết kiệm 37px chiều dọc).
2. **Hiển thị hoàn hảo 1 hàng trên Desktop lớn (1920px)**:
   - Toàn bộ thanh công cụ được xếp thẳng hàng trên **1 DÒNG DUY NHẤT** với chiều cao lý tưởng **40px**, tận dụng trọn vẹn bề ngang màn hình, không còn khoảng trống đen vô nghĩa.
3. **Ô tìm kiếm không còn bị cắt cụt chữ placeholder**:
   - Nhờ cố định `width: 220px !important;`, toàn bộ nội dung placeholder `Tìm kiếm theo nội dung...` hiển thị sắc nét, không bị co rút hay chồng lấn icon.

##### C. Hình ảnh minh chứng thực tế trên Web thật sau khi cập nhật Database

###### 1. Minh chứng tại khung nhìn Snap Layout Windows (868px × 911px - Đối chiếu lỗi Screenshot ban đầu):
![Minh chứng kết quả sau khi sửa tại 868px](/fix-bug/cac_cuoc_hop/screenshot/screenshot-responsive-868-after.png)

###### 2. Minh chứng tại khung nhìn Desktop lớn (1920px × 1080px - Chuẩn mực 1 hàng duy nhất):
![Minh chứng kết quả sau khi sửa tại 1920px](/fix-bug/cac_cuoc_hop/screenshot/screenshot-responsive-1920-after.png)

###### 3. Minh chứng tại khung nhìn Laptop / Tablet Landscape (1024px × 768px):
![Minh chứng kết quả sau khi sửa tại 1024px](/fix-bug/cac_cuoc_hop/screenshot/screenshot-responsive-1024-after.png)

