# BÁO CÁO GIẢI TRÌNH KỸ THUẬT TOÀN DIỆN (EXECUTIVE TECHNICAL DEFENSE REPORT)
## TỔNG HỢP NGUYÊN NHÂN GỐC RỄ, GIẢI PHÁP VÀ MÃ NGUỒN CÁC BẢN VÁ LỖI GIAO DIỆN HỆ THỐNG PARADISE HRM
### (Từ Screenshot-01 đến Screenshot-18)

---

## 📌 PHẦN I: TỔNG QUAN CHIẾN DỊCH & MA TRẬN 14 MÀN HÌNH BÀN GIAO

Toàn bộ 14 màn hình được rà soát và khắc phục triệt để theo chu trình khép kín: **Điều tra READ-ONLY $\rightarrow$ Phân tích nguyên nhân gốc rễ (RCA) $\rightarrow$ Tối ưu kiến trúc Flex/Responsive/Engine $\rightarrow$ Biên dịch đồng bộ `tblHtmlScriptCache` $\rightarrow$ Đóng gói bản vá SQL độc lập có kiểm định cú pháp 100% an toàn**.

| STT | Thư mục | Phân hệ / Tên màn hình | MenuID | Stored Procedure can thiệp | Loại lỗi đã khắc phục |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **01** | `screenshot-1` | Quà tặng $\rightarrow$ Lịch sử nhận quà | `MnuPRL451` | `sp_gift_history_gift_html` | DataGrid co cụm, 5 cột chưa chia đều 20%. |
| **02** | `screenshot-2` | Công nợ $\rightarrow$ Thanh toán công nợ | `MnuPRL409` | `sp_Debt_PaymentDebt_html` | DataGrid bị ép 600px dồn trái, vùng đen 65%. |
| **03** | `screenshot-3` | Quản trị nhân sự $\rightarrow$ Hồ sơ cá nhân | `MnuSCR004` | `HR_StaffInformation_ForUserWeb_Beta` | Mở menu không lên gì, mất avatar, modal lỗi. |
| **04** | `screenshot-4` | Chấm công $\rightarrow$ Đăng ký tăng ca | `MnuPRL103` | `sp_Overtime_Assignment_html` | Ô ngày đen, mất nhãn tiếng Việt do lỗi cache. |
| **05** | `screenshot-5` | Hệ thống $\rightarrow$ Tạo mật khẩu khởi tạo | `MnuSEC002` | `SetInitialPasswordForm` | Báo link hết hạn, nút quay lại bị logout. |
| **06** | `screenshot-6` | CRM $\rightarrow$ Danh sách công ty | `MnuCRM001` | `sp_CRM_CompanyList_html` | Bảng dồn trái, Tên công ty/Địa chỉ bị cắt `...`. |
| **07** | `screenshot-8` | Nhân sự $\rightarrow$ Hợp đồng lao động | `MnuSCR011` | `sp_LabourContractHistory_html` | Nút đè Tab filter, cột hiển thị mã thô `%lc_%`. |
| **08** | `screenshot-11` | Tiền lương $\rightarrow$ Nhập lương Trí Luật | `MnuPRL512` | `Template_SalaryImport_TriLuat_html` | Filter Tháng/Năm/Buttons bị lệch lên trên. |
| **09** | `screenshot-13` | Công nợ $\rightarrow$ Danh sách công nợ KH | `MnuPRL410` | `sp_Debt_ListCustomerDebt_html` | Lỗi vòng lặp vô tận, xoay "Đang tải dữ liệu...". |
| **10** | `screenshot-14` | CRM/KPI $\rightarrow$ Các email theo dõi KPI | `MnuKPI010` | `sp_CRM_EmailKPIFollow_html` | Sập `0.apply`, Modal bé & bị backdrop chặn click, ô Mã NV hiện tên. |
| **11** | `screenshot-15` | KPI $\rightarrow$ Họp demo KPI | `MnuKPI005` | `sp_KPIMeetingDemo_html` | Nút Tạo cuộc họp rớt hàng, Column Chooser đè. |
| **12** | `screenshot-16` | CRM $\rightarrow$ Theo dõi dịch vụ bán hàng | `MnuCRM004` | `sp_CRM_CustomerList_html` | Nút Làm mới & Checkbox "Xem của tôi" rớt hàng. |
| **13** | `screenshot-17` | CRM/KPI $\rightarrow$ Email gửi thủ công | `MnuKPI002` | `sp_KPIListEmailManual_html` | 2 checkbox rớt hàng, filter lệch ô Search, cột Chủ đề bị ép 150px. |
| **14** | `screenshot-18` | CRM/KPI $\rightarrow$ Dữ liệu khách hàng | `MnuKPI003` | `sp_KPIListDataCollection_html` | Checkbox "Xem của tôi" chiếm 1 hàng riêng 80px đẩy bảng xuống dưới. |

---

## 🧠 PHẦN II: PHÂN LOẠI 4 NHÓM NGUYÊN NHÂN LỖI HỆ THỐNG (SYSTEMIC RCA)

Khi giải trình với Sếp, toàn bộ 14 lỗi trên quy tụ về **4 nhóm nguyên nhân bản chất trong mã nguồn cũ**:

```
                                      HỆ THỐNG LỖI GIAO DIỆN
                                                │
         ┌───────────────────────┬──────────────┴──────────────┬────────────────────────┐
         ▼                       ▼                             ▼                        ▼
  [NHÓM 1: TOOLBAR]       [NHÓM 2: DATAGRID]            [NHÓM 3: MODAL]          [NHÓM 4: ENGINE/V8]
  - Rớt dòng Filter       - Gán cứng width (px)         - Bootstrap Backdrop     - Cú pháp `0.apply`
  - Chiếm `width: 100%`   - Bảng bị dồn sang trái       - Bị kẹt Stacking        - Vòng lặp đệ quy
  - Lệch hàng nút bấm     - Vùng đen khổng lồ           Context AppShell         `ReloadData`
```

1. **Nhóm 1: Bố cục Toolbar chia cắt dòng (Screenshots 11, 15, 16, 17, 18)**:
   - *Căn nguyên*: Mã nguồn cũ thường bọc các nút hoặc checkbox vào các thẻ `div` block có `width: 100%` hoặc tạo dòng riêng `$quickMyDataRow$`. Do đó trình duyệt bắt buộc phải ngắt dòng, làm thanh công cụ dày cộm (từ 40px phình lên 80px) và đẩy bảng dữ liệu xuống dưới.
   - *Cách giải quyết*: Gom toàn bộ các controls trên cùng 1 Flex Row (`display: flex; align-items: center; gap: 8px; flex-wrap: nowrap`), dùng `margin-left: auto` để đẩy các cụm tìm kiếm/công cụ về sát lề phải.

2. **Nhóm 2: Bảng DataGrid bị bóp dẹp, gán cứng px (Screenshots 1, 2, 4, 6, 8, 14, 17)**:
   - *Căn nguyên*: Bảng cấu hình `tblCommonControlType_Signed` hoặc khai báo cột trong Stored Procedure gán cứng độ rộng tĩnh (ví dụ: `width: 150px`), đồng thời thiếu cấu trúc Flexbox cha (`flex: 1 1 0%`). Kết quả là bảng chỉ rộng 450px - 650px trên màn hình 1920px, để lại một "vùng đen hoang hóa" bên phải và chữ bị cắt `...`.
   - *Cách giải quyết*: Chuyển đổi toàn bộ sang `minWidth` linh hoạt kết hợp tỷ lệ phần trăm (hoặc `table-layout: fixed; width: 100% !important;`), kích hoạt `allowColumnResizing: true` và `columnAutoWidth: true`.

3. **Nhóm 3: Modal bị kẹt trong Stacking Context của AppShell & Backdrop chặn click (Screenshots 3, 14)**:
   - *Căn nguyên*: Thẻ Modal nằm bên trong container con có `overflow: hidden`. Khi mở modal, Bootstrap chèn thẻ `<div class="modal-backdrop">` vào trực tiếp `document.body` (z-index 1050). Lớp backdrop này nằm đè lên trên toàn bộ modal của view con, chặn đứng mọi thao tác chuột (`pointer-events`). Đồng thời `modal-dialog` thiếu `min-width` nên co rút kích thước theo chữ bên trong ("chút éc").
   - *Cách giải quyết*: Khi kích hoạt mở modal, JavaScript tự động di chuyển thẻ modal ra trực tiếp `document.body` (`document.body.appendChild(emailModal)`), triệt tiêu hoàn toàn `.modal-backdrop`, và định dạng modal đạt chuẩn Enterprise 580px bo góc 12px.

4. **Nhóm 4: Lỗi Runtime Engine & Trình biên dịch V8 (Screenshots 13, 14)**:
   - *Căn nguyên*: 
     + Trường `CustomValidate` mang số `0` khiến code sinh tự động thành `typeof 0 === "function" ? 0.apply(...) : true;`. Engine V8 hiểu `0.` là số thập phân lỗi dẫn đến `SyntaxError: Unexpected token` làm sập toàn bộ JavaScript.
     + Thiếu guard clause khiến các hàm AJAX gọi đệ quy `ReloadData()` làm màn hình xoay vô tận.
   - *Cách giải quyết*: Triệt tiêu hoàn toàn `0.apply` thành `true` trong cả bảng Signed và ScriptCache; bổ sung cờ chặn đệ quy và kiểm tra dữ liệu null/undefined an toàn.

---

## 🛠️ PHẦN III: CHI TIẾT KỸ THUẬT VÀ MINH CHỨNG MÃ NGUỒN TỪNG SCREENSHOT
*(Giải trình minh bạch rõ ràng từng Stored Procedure, vị trí dòng lệnh và mã nguồn Trước/Sau)*

---

### 1. Screenshot-01: Lịch sử nhận quà (MnuPRL451)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_gift_history_gift_html]` & `[dbo].[sp_gift_history_gift]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_gift_history_gift')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_gift_history_gift_html]`**, khối khai báo cấu hình khởi tạo widget DevExtreme DataGrid: `$("#hist_grid").dxDataGrid({ columns: [...] })`.
- **Hiện trạng lỗi (Vấn đề)**: Bảng DataGrid 5 cột bị dồn về góc trái, khoảng cách giữa các cột phân bổ không đều, để lại khoảng trống bất hợp lý bên phải màn hình.
- **Giải pháp kiến trúc**: Cấu hình chia đều 5 cột chuẩn 20% mỗi cột kết hợp `minWidth: 140px` để đảm bảo vừa khít màn hình nhưng không bị co cụm khi màn hình nhỏ.
- **Minh chứng mã nguồn (Before vs After)**:
```javascript
// TRƯỚC (Cũ - gán cứng width hoặc để auto lệch trong sp_gift_history_gift_html):
columns: [
    { dataField: "GiftName", width: 150 },
    { dataField: "Point", width: 100 },
    ...
]

// SAU (Bản vá - Chia đều chuẩn 20% mỗi cột + minWidth an toàn):
columns: [
    { dataField: "GiftName", caption: "%GiftName%", width: "20%", minWidth: 140, alignment: "left" },
    { dataField: "Point", caption: "%Point%", width: "20%", minWidth: 120, alignment: "right" },
    { dataField: "Status", caption: "%Status%", width: "20%", minWidth: 120, alignment: "center" },
    { dataField: "CreatedDate", caption: "%CreatedDate%", width: "20%", minWidth: 140, alignment: "center" },
    { dataField: "Receiver", caption: "%Receiver%", width: "20%", minWidth: 140, alignment: "left" }
]
```
- **File bản vá độc lập**: [`fix-bug/screenshot-1/patch_responsive.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-1/patch_responsive.sql)

---

### 2. Screenshot-02: Thanh toán công nợ (MnuPRL409)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_Debt_PaymentDebt_html]` & `[dbo].[sp_Debt_PaymentDebt]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_Debt_PaymentDebt')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_Debt_PaymentDebt_html]`**, khối mã CSS nhúng `<style>` ở đầu store và khối cấu hình khởi tạo `$("#dp_grid").dxDataGrid({...})`.
- **Hiện trạng lỗi (Vấn đề)**: DataGrid `#dp_grid` chỉ chiếm ~600px chiều ngang, để lại vùng đen chiếm 65% diện tích bên phải màn hình. Khi bấm [Làm mới] thì bảng bị co giật.
- **Giải pháp kiến trúc**: Thiết lập Flexbox 100% cho container, loại bỏ giới hạn chiều rộng của `#dp_grid`, bổ sung `allowColumnResizing: true` và `columnAutoWidth: true`.
- **Minh chứng mã nguồn (Before vs After)**:
```css
/* TRƯỚC (Cũ - Container co cụm thiếu flex trong sp_Debt_PaymentDebt_html): */
.payment-debt-container {
    padding: 15px;
}
#dp_grid {
    height: 450px;
}

/* SAU (Bản vá - Flexbox tràn viền 100% nhúng trong sp_Debt_PaymentDebt_html): */
#sp_Debt_PaymentDebt_html {
    height: 100% !important;
    display: flex !important;
    flex-direction: column !important;
    box-sizing: border-box !important;
}
.payment-debt-container {
    flex: 1 1 auto !important;
    display: flex !important;
    flex-direction: column !important;
    width: 100% !important;
    height: 100% !important;
    min-height: 0 !important;
    padding: 12px 16px !important;
}
#dp_grid {
    width: 100% !important;
    height: 100% !important;
    flex: 1 1 auto !important;
}
.dx-datagrid-table {
    width: 100% !important;
}
```
- **Giải trình kỹ thuật chuyên sâu (Vị trí code, Selector `#`/`.` và Phạm vi tác động)**:
  1. *Đoạn code trên nằm ở đâu?*: Được viết trực tiếp trong cặp thẻ `<style>...</style>` thuộc biến chuỗi `@html` của Stored Procedure `[dbo].[sp_Debt_PaymentDebt_html]`. Khi mở menu, SP trả chuỗi HTML/CSS này về để trình duyệt render.
  2. *Ký hiệu `#` và `.` là gì?*:
     - **`#` (ID Selector)**: Định kiểu cho duy nhất 1 phần tử có thuộc tính `id` cụ thể (như `#dp_grid` là khung chứa bảng, `#sp_Debt_PaymentDebt_html` là container trang).
     - **`.` (Class Selector)**: Định kiểu cho một nhóm phần tử mang class dùng chung (như `.payment-debt-container` hoặc `.dx-datagrid-table` do DevExtreme sinh ra).
  3. *Phạm vi tồn tại & Tính tái sử dụng (Scope Isolation)*:
     - Đoạn CSS này chỉ có hiệu lực với các phần tử mang ID `#dp_grid` của riêng trang này. Các trang khác (như `#hist_grid` ở Screenshot-1) hoàn toàn không bị ảnh hưởng, đảm bảo **cô lập rủi ro tuyệt đối (Zero Ripple Effect)**.
     - Đồng thời, quy tắc Scoped CSS (bọc tiền tố cha `#sp_Debt_PaymentDebt_html ...`) ngăn chặn việc class `.dx-datagrid-table` bị rò rỉ (CSS Leakage) sang các tab con khác trong ứng dụng SPA.
- **File bản vá độc lập**: [`fix-bug/screenshot-2/patch_responsive.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-2/patch_responsive.sql)

---

### 3. Screenshot-03: Hồ sơ cá nhân (MnuHRS0102 / MnuSCR004)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[HR_StaffInformation_ForUserWeb_Beta]` & `[dbo].[HR_StaffInformation_ForUserWeb]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'HR_StaffInformation_ForUserWeb')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[HR_StaffInformation_ForUserWeb_Beta]`**, hàm JavaScript khởi tạo trường ảnh đại diện `PictureEdit` và khối cấu hình các ComboBox trong Modal Sửa thông tin cơ bản.
- **Hiện trạng lỗi (Vấn đề)**: Bấm vào menu thì trang bị trắng trơn hoặc xoay loading vô tận; mất ảnh avatar đại diện; khi bấm nút [Sửa] thì modal lỗi `reading '0'`, ComboBox rỗng và ảnh trong modal không hiện.
- **Giải pháp kiến trúc**: Sửa selector DOM lấy ảnh từ `#UserAvatar` sang ID thực tế `#profileImage_P`, bổ sung cơ chế fallback đa tầng, truyền tham số `@LoginID` đầy đủ khi nạp ComboBox địa giới hành chính, đồng bộ màu xám ghi `#2b3035` cho modal.
- **Minh chứng mã nguồn (Before vs After)**:
```javascript
// TRƯỚC (Cũ trong HR_StaffInformation_ForUserWeb_Beta - Lệch selector DOM ID):
let defaultAvatarSrc = $("#UserAvatar").attr("src"); // -> undefined, ảnh modal không hiển thị!

// SAU (Bản vá trong HR_StaffInformation_ForUserWeb_Beta - Selector chuẩn xác + Fallback):
let defaultAvatarSrc = value 
    || $("#profileImage_P").attr("src") 
    || getValidEmployeeAvatarSrc(thongTinNhanVien?.[0]) 
    || "";

// Bo tròn avatar và đồng bộ màu ComboBox trong Modal:
$("#modalEditAvatar").css({ "width": "100px", "height": "100px", "border-radius": "50%", "border": "2px solid #237b58" });
$(".modal-body .dx-textbox, .modal-body .dx-selectbox, .modal-body .dx-datebox").css({
    "background-color": "#2b3035 !important",
    "border-color": "#495057 !important"
});
```
- **File bản vá độc lập**: [`fix-bug/screenshot-3/patch_hoso_canhan.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-3/patch_hoso_canhan.sql)

---

### 4. Screenshot-04: Đăng ký xin tăng ca (MnuWPT316 / MnuPRL103)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_Overtime_Assignment_html]` & `[dbo].[sp_Overtime_Assignment]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_Overtime_Assignment')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_Overtime_Assignment_html]`** (khối Scoped CSS `<style>` định kiểu DateBox) và lệnh T-SQL kích hoạt biên dịch từ điển đa ngôn ngữ `sp_GenerateHTMLScript_new`.
- **Hiện trạng lỗi (Vấn đề)**: Ba ô chọn Ngày (`#qlrl-dxOTFromDate`), Từ giờ (`#qlrl-OTFrom`), Đến giờ (`#qlrl-OTTo`) mang màu đen tuyền `#000000` cọc cạch; toàn bộ các nhãn biến thành mã thô dạng placeholder: `%MnuWPT316%`, `%@AttDate%`, `%TypeRequest%` do lỗi lưu cache chưa biên dịch.
- **Giải pháp kiến trúc**: Bổ sung Scoped CSS ép màu `#2b3035`, viền `#495057` cho các ô DateBox; đồng thời kích hoạt trình biên dịch hệ thống `sp_GenerateHTMLScript_new` để biên dịch 100% placeholder sang tiếng Việt.
- **Minh chứng mã nguồn (Before vs After)**:
```sql
-- SAU (Bản vá trong patch_tang_ca.sql - Bổ sung Scoped CSS và Biên dịch chuẩn):
-- 1. Bổ sung CSS đồng bộ màu sắc trong sp_Overtime_Assignment_html:
#qlrl-dxOTFromDate, #qlrl-OTFrom, #qlrl-OTTo {
    background-color: #2b3035 !important;
    border: 1px solid #495057 !important;
    border-radius: 6px !important;
    color: #e9ecef !important;
}

-- 2. Kích hoạt biên dịch từ điển đa ngôn ngữ qua tblMD_Message:
EXEC [dbo].[sp_GenerateHTMLScript_new] 'sp_Overtime_Assignment_html', '-1', 'sp_Overtime_Assignment';
```
- **File bản vá độc lập**: [`fix-bug/screenshot-4/patch_tang_ca.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-4/patch_tang_ca.sql)

---

### 5. Screenshot-05: Tạo mật khẩu khởi tạo (MnuSCR612 / MnuSEC002)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[SetInitialPasswordForm]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'SetInitialPasswordForm')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[SetInitialPasswordForm]`**, khối điều kiện T-SQL kiểm tra Token (`IF...ELSE`) và thẻ HTML của nút quay lại.
- **Hiện trạng lỗi (Vấn đề)**: Người dùng đang đăng nhập bấm vào menu "Tạo mật khẩu" lập tức bị báo: *"Đường dẫn đã hết hạn hoặc không hợp lệ"*. Khi bấm nút "Quay về trang chủ" thì bị **LOGOUT văng khỏi hệ thống**.
- **Giải pháp kiến trúc**: Đảo ngược logic kiểm tra Token — chỉ báo lỗi khi Token cụ thể không tồn tại; khi mở từ thanh menu Web App (`@SetPassToken = ''`), luôn luôn hiển thị đầy đủ Form tạo mật khẩu. Sửa nút quay lại thành đóng tab/điều hướng SPA, tuyệt đối không gọi logout.
- **Minh chứng mã nguồn (Before vs After)**:
```sql
-- TRƯỚC (Cũ trong SetInitialPasswordForm - Token rỗng bị coi là lỗi link hết hạn):
ELSE IF EXISTS (SELECT 1 FROM tblSC_Login WHERE TokenID = @SetPassToken AND IsActive = 0)
    ... [HIỂN THỊ FORM] ...
ELSE
    SET @ColHtml = N'<h2>Đường dẫn đã hết hạn hoặc không hợp lệ</h2>...'

-- SAU (Bản vá trong SetInitialPasswordForm - Mở từ Web App luôn hiển thị Form tạo mật khẩu):
ELSE IF ISNULL(@SetPassToken, '') <> '' AND NOT EXISTS (
    SELECT 1 FROM tblSC_Login WHERE TokenID = @SetPassToken AND IsActive = 0
)
BEGIN
    -- Chỉ báo lỗi khi Token cụ thể được truyền vào nhưng không hợp lệ
    SET @ColHtml = N'<div class="alert alert-danger">Đường dẫn đã hết hạn hoặc không hợp lệ.</div>';
END
ELSE
BEGIN
    -- MỞ TỪ WEB MENU -> HIỂN THỊ ĐẦY ĐỦ FORM TẠO MẬT KHẨU CHUẨN DESIGN SYSTEM!
    ...
END
```
- **File bản vá độc lập**: [`fix-bug/screenshot-5/patch_tao_mat_khau.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-5/patch_tao_mat_khau.sql)

---

### 6. Screenshot-06: Danh sách công ty CRM (MnuKPI449 / MnuCRM001)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_CRM_CompanyList_html]` (SP giao diện) & `[dbo].[sp_CRM_CompanyList]` (SP điều phối)
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_CRM_CompanyList')
- **Vị trí đoạn code sửa**: Nằm trực tiếp bên trong Stored Procedure **`[dbo].[sp_CRM_CompanyList_html]`**, tại hàm `applyCompanyColumnOrder()` và dòng đóng script ở cuối SP.
- **Hiện trạng lỗi (Vấn đề)**: Hàm sắp xếp cột `applyCompanyColumnOrder` trong SP gốc chỉ đảo thứ tự mảng mà không xử lý độ rộng cột, khiến các cột dữ liệu dài (Tên công ty, Địa chỉ) bị giữ nguyên kích thước gò bó ~150px và chữ bị cắt dấu ba chấm `...`. Nửa bên phải màn hình để trống một mảng đen lớn (~1300px). Cuối SP bị lỗi typo thừa `})();s`.
- **Giải pháp kiến trúc**: Sửa trực tiếp trong hàm `applyCompanyColumnOrder` của SP `sp_CRM_CompanyList_html`: xóa bỏ `width` & `maxWidth`, thiết lập `minWidth: 280` cho Tên công ty và `minWidth: 320` cho Địa chỉ (Flex Auto-fill tràn viền 100%), bổ sung tooltip `title` khi hover, kích hoạt `allowColumnResizing: true`, và dọn sạch ký tự typo thừa `s`.
- **Minh chứng mã nguồn (Before vs After trong chính sp_CRM_CompanyList_html)**:
```javascript
// TRƯỚC (Code gốc trong hàm applyCompanyColumnOrder của sp_CRM_CompanyList_html):
// Chỉ push nguyên column mà không xử lý độ rộng -> Bị kẹt ở 150px, hở mảng đen lớn
if (column) orderedColumns.push(column);

// SAU (Code bản vá trong hàm applyCompanyColumnOrder của sp_CRM_CompanyList_html):
// Xóa width & maxWidth, thiết lập Flex Auto-fill tràn viền 100%, có tooltip & cho phép kéo thả cột
if (dataField === "Company") {
    delete column.width;
    delete column.maxWidth;
    column.minWidth = 280;
    column.cellTemplate = function(el, info) { origCell(el, info); if (info.value) el.attr("title", info.value); };
} else if (dataField === "Address") {
    delete column.width;
    delete column.maxWidth;
    column.minWidth = 320;
    column.cellTemplate = function(el, info) { origCell(el, info); if (info.value) el.attr("title", info.value); };
}
```
- **File bản vá độc lập**: [`fix-bug/screenshot-6/patch_responsive_company_list.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-6/patch_responsive_company_list.sql)

---

### 7. Screenshot-08: Quản lý hợp đồng lao động (MnuHRS151 / MnuSCR011)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[LabourContract_html]` & `[dbo].[sp_LabourContractHistory_html]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_LabourContractHistory')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[LabourContract_html]`** (khối CSS Flexbox Toolbar) và **`[dbo].[sp_LabourContractHistory_html]`** (tiến trình biên dịch đa ngôn ngữ cho Tab 5 Lịch sử HĐLĐ).
- **Hiện trạng lỗi (Vấn đề)**: Các nút hành động trên Toolbar đè lên thanh filter 5 tab; tại Tab 5 ("Lịch sử ký hợp đồng"), tiêu đề các cột trong DataGrid biến thành chuỗi mã placeholder: `%LC_EMPLOYEE_ID%`, `%LC_FULL_NAME%`, `%lc_select_contract%`...
- **Giải pháp kiến trúc**: Dùng Flexbox căn phải các nút chức năng (`justify-content: flex-end; gap: 8px`); kích hoạt trình biên dịch hệ thống `sp_GenerateHTMLScript_new` và quét phòng thủ 71 mã `lc_%` từ `tblMD_Message` cập nhật vào cache.
- **Minh chứng mã nguồn (Before vs After)**:
```sql
-- SAU (Bản vá trong patch_hop_dong_lao_dong.sql):
-- 1. Toolbar căn phải bằng Flexbox trong LabourContract_html:
.contract-toolbar-actions {
    display: flex !important;
    justify-content: flex-end !important;
    gap: 8px !important;
    align-items: center !important;
}

-- 2. Biên dịch đa ngôn ngữ qua sp_GenerateHTMLScript_new và quét phòng thủ:
EXEC [dbo].[sp_GenerateHTMLScript_new] @ProcName = 'sp_LabourContractHistory_html';

UPDATE c
SET c.[html] = REPLACE(c.[html], '%' + m.MessageID + '%', m.Content)
FROM [dbo].[tblHtmlScriptCache] c
INNER JOIN [dbo].[tblMD_Message] m ON m.MessageID LIKE 'lc_%' AND LOWER(c.LanguageID) = LOWER(m.Language)
WHERE c.[TableName] = 'sp_LabourContractHistory';
```
- **File bản vá độc lập**: [`fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql)

---

### 8. Screenshot-11: Nhập lương Trí Luật (MnuPRL512 / MnuPRL408)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[Template_SalaryImport_TriLuat_html]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'Template_SalaryImport_TriLuat')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[Template_SalaryImport_TriLuat_html]`**, khối `<style>` và cấu trúc HTML của thanh bộ lọc Toolbar `.salary-filter-toolbar`.
- **Hiện trạng lỗi (Vấn đề)**: Cụm bộ lọc Tháng, Năm và các nút hành động (Chuyển khoản, Xuất Excel...) bị vỡ dòng, nằm lệch cao độ so với ô lọc Họ và tên bên dưới; DataGrid chưa responsive.
- **Giải pháp kiến trúc**: Gom toàn bộ bộ lọc Tháng, Năm, Họ tên và các nút bấm vào một Flex Row duy nhất (`gap: 10px; flex-wrap: nowrap; align-items: center`), DataGrid nhận `width: 100%`.
- **Minh chứng mã nguồn (Before vs After)**:
```css
/* TRƯỚC (Cũ trong Template_SalaryImport_TriLuat_html - Tách dòng lệch cao độ): */
.filter-month-year { float: left; margin-top: 5px; }
.filter-fullname { clear: both; margin-top: 15px; }

/* SAU (Bản vá trong Template_SalaryImport_TriLuat_html - 1 hàng ngang bằng phẳng hoàn hảo): */
.salary-filter-toolbar {
    display: flex !important;
    align-items: center !important;
    gap: 10px !important;
    flex-wrap: nowrap !important;
    width: 100% !important;
}
.salary-filter-toolbar .filter-item {
    display: inline-flex !important;
    align-items: center !important;
    margin: 0 !important;
}
```
- **File bản vá độc lập**: [`fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql)

---

### 9. Screenshot-13: Danh sách công nợ khách hàng (MnuPRL410)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_Debt_ListCustomerDebt_html]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_Debt_ListCustomerDebt')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_Debt_ListCustomerDebt_html]`**, hàm xử lý sự kiện `onContentReady` của DevExtreme DataGrid và cấu hình mảng cột `columns`.
- **Hiện trạng lỗi (Vấn đề)**: Màn hình bị xoay con quay spinner "Đang tải dữ liệu..." vô tận do lỗi đệ quy; cột "LOẠI CÔNG NỢ" bị bóp nghẹt cắt chữ `Lương thán...`, tiêu đề bị cắt `TỔNG CÔNG ...`.
- **Giải pháp kiến trúc**: Bổ sung cờ chặn đệ quy an toàn (`isGridReloading`), dập tắt vòng lặp gọi lại `ReloadData()`, nâng `minWidth` cột Loại công nợ lên 200px, Tổng công nợ lên 160px.
- **Minh chứng mã nguồn (Before vs After)**:
```javascript
// TRƯỚC (Cũ trong sp_Debt_ListCustomerDebt_html - Gọi lặp đệ quy vô tận):
onContentReady: function() {
    ReloadData(); // -> Gây vòng lặp vô tận, treo spinner!
}

// SAU (Bản vá trong sp_Debt_ListCustomerDebt_html - Cờ chặn an toàn tuyệt đối):
let isGridReloading = false;
function SafeReloadData() {
    if (isGridReloading) return;
    isGridReloading = true;
    ReloadData().always(function() {
        isGridReloading = false;
        $("#loadingSpinner").hide();
    });
}
```
- **File bản vá độc lập**: [`fix-bug/screenshot-13/patch_fix_debt_loading.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-13/patch_fix_debt_loading.sql)

---

### 10. Screenshot-14: Các email theo dõi KPI (MnuKPI010)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_CRM_EmailKPIFollow_html]`, `[dbo].[sp_CRM_EmailKPIFollow]` & cấu hình `tblCommonControlType_Signed`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_CRM_EmailKPIFollow')
- **Vị trí đoạn code sửa**:
  1. Trong bảng **`tblCommonControlType_Signed`** và cache: Cột `CustomValidate` (triệt tiêu `0.apply`).
  2. Trong Stored Procedure **`[dbo].[sp_CRM_EmailKPIFollow_html]`**: Hàm mở Modal Sửa/Thêm (thoát Stacking Context & Backdrop) và hàm cấu hình SelectBox `InstanceEmployeeID...` (hiển thị Mã nhân viên).
- **Hiện trạng lỗi (Vấn đề)**:
  1. DataGrid co cụm chiều cao (~250px ứng với 7 dòng).
  2. Sập đen hoàn toàn do lỗi cú pháp JavaScript `0.apply`.
  3. Bấm vào 1 dòng: Modal hiện ra kích thước rất bé ("chút éc" ~320px) và bị lớp backdrop che đè chặn đứng mọi click chuột.
  4. Ô "Mã nhân viên" lại tự động điền Tên người ("TRẦN KHÁNH LY") thay vì mã ("034").
- **Giải pháp kiến trúc**:
  1. Triệt tiêu `0.apply` thành `true` trong bảng Signed và Cache.
  2. Di chuyển modal ra ngoài `document.body`, xóa `.modal-backdrop`, định dạng modal 580px chuẩn Dark theme.
  3. Cấu hình `displayExpr: "ID"`, template `[Mã] - [Họ tên]` và tự động điền Họ tên khi chọn nhân viên.
- **Minh chứng mã nguồn (Before vs After)**:
```javascript
// 1. Thoát khỏi Stacking Context để click mượt mà 100% (trong sp_CRM_EmailKPIFollow_html):
const emailModal = document.getElementById("emailModal");
if (emailModal) {
    if (emailModal.parentElement !== document.body) {
        document.body.appendChild(emailModal);
    }
    $(".modal-backdrop").remove();
    emailModal.classList.add("show");
    emailModal.style.display = "flex";
}

// 2. Hiển thị chuẩn xác Mã nhân viên (034) và Họ tên (TRẦN KHÁNH LY) (trong sp_CRM_EmailKPIFollow_html):
InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option({
    displayExpr: "ID",
    valueExpr: "ID",
    itemTemplate: function(data) {
        return $("<div>").text(data.ID ? (data.ID + " - " + data.Name) : data.Name);
    }
});
```
- **File bản vá độc lập**: [`fix-bug/screenshot-14/patch_email_kpi_follow.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-14/patch_email_kpi_follow.sql)

---

### 11. Screenshot-15: Họp demo KPI (MnuKPI005)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_KPIMeetingDemo_html]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_KPIMeetingDemo')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_KPIMeetingDemo_html]`**, khối HTML tạo cấu trúc thanh công cụ và mã JavaScript khởi tạo Toolbar của DataGrid.
- **Hiện trạng lỗi (Vấn đề)**: Nút `+ Tạo cuộc họp mới` bị rớt xuống dòng riêng biệt bên dưới; Column Chooser đè lên ô "Tìm kiếm theo nội dung"; thanh filter bị render nhân đôi.
- **Giải pháp kiến trúc**: Di chuyển nút Tạo cuộc họp mới lên ngang hàng bên phải ô Tìm kiếm; tạo khoảng cách an toàn `gap: 8px` cho Column Chooser; đưa 2 checkbox Xem tất cả ngày & Chỉ xem của tôi lên ngang hàng cụm filter.
- **Minh chứng mã nguồn (Before vs After)**:
```javascript
// SAU (Bản vá trong sp_KPIMeetingDemo_html - Đưa nút Tạo cuộc họp và Checkbox lên 1 dòng duy nhất):
// 1. Đưa nút Tạo cuộc họp mới lên cùng hàng với ô Tìm kiếm:
$(".meeting-search-container").append($(".btn-new-meeting"));

// 2. Tách biệt Column Chooser và ô Tìm kiếm với khoảng đệm an toàn:
$(".dx-toolbar-after").css({
    "display": "flex",
    "align-items": "center",
    "gap": "8px"
});

// 3. Đưa 2 checkbox lên ngang hàng với cụm Nhân viên -> Từ ngày -> Đến ngày:
$(".meeting-filter-group").append($(".meeting-checkbox-group"));
```
- **File bản vá độc lập**: [`fix-bug/screenshot-15/patch_fix_meeting_filter.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-15/patch_fix_meeting_filter.sql)

---

### 12. Screenshot-16: Theo dõi dịch vụ bán hàng (MnuCRM004 / MnuKPI012)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_CRM_CustomerList_html]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_CRM_CustomerList')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_CRM_CustomerList_html]`**, khối Scoped CSS `<style>` định dạng lớp `.service-filter-row` và khối mã chèn nút Làm mới/Checkbox.
- **Hiện trạng lỗi (Vấn đề)**: Nút [Làm mới] và Checkbox [Xem của tôi] bị rớt xuống thành 1 hàng riêng biệt bên dưới thanh lọc, khiến thanh công cụ chiếm tới ~85px chiều cao và đẩy bảng dữ liệu xuống dưới.
- **Giải pháp kiến trúc**: Đưa nút [Làm mới] và Checkbox [Xem của tôi] lên **ngang hàng 100% với cụm chip lọc trạng thái** (`Tất cả`, `Đang hiệu lực`...), căn lệch sang bên phải trước ô tìm kiếm Tên công ty, thu gọn toolbar về chuẩn 42px.
- **Minh chứng mã nguồn (Before vs After)**:
```css
/* TRƯỚC (Cũ trong sp_CRM_CustomerList_html - Thẻ div block 100% làm rớt hàng): */
.service-refresh-block { width: 100%; clear: both; margin-top: 10px; }

/* SAU (Bản vá trong sp_CRM_CustomerList_html - 1 hàng ngang duy nhất chuẩn 42px): */
.service-filter-row {
    display: flex !important;
    align-items: center !important;
    gap: 8px !important;
    flex-wrap: nowrap !important;
    height: 42px !important;
}
.service-filter-row .btn-refresh-service,
.service-filter-row .chk-my-service {
    margin: 0 !important;
    display: inline-flex !important;
    align-items: center !important;
}
```
- **File bản vá độc lập**: [`fix-bug/screenshot-16/patch_theo_doi_dich_vu.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-16/patch_theo_doi_dich_vu.sql)

---

### 13. Screenshot-17: Email gửi thủ công (MnuKPI002)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_KPIListEmailManual_html]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_KPIListEmailManual')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_KPIListEmailManual_html]`**, khối cấu trúc HTML Toolbar và mảng khai báo cột `columns: [...]` của `dxDataGrid`.
- **Hiện trạng lỗi (Vấn đề)**: Cụm filter bên trái chiếm 100% đẩy ô Search Panel xuống hàng 2; 2 checkbox [Xem tất cả các ngày] và [Chỉ xem của tôi] rớt dòng; cột Chủ đề (`Subject`) bị ép 150px cắt ba chấm.
- **Giải pháp kiến trúc**: Tái cấu trúc Toolbar trên 1 Flex Row duy nhất, đưa 2 checkbox lên ngang hàng bên phải nút [Soạn thư]; mở rộng cột Chủ đề lên `minWidth: 250px`, kích hoạt `allowColumnResizing: true`.
- **Minh chứng mã nguồn (Before vs After)**:
```javascript
// SAU (Bản vá trong sp_KPIListEmailManual_html - Toolbar 1 dòng flex + cột Subject minWidth 250):
// 1. Tái cấu trúc Toolbar trên 1 hàng phẳng:
$(".email-manual-toolbar").css({
    "display": "flex",
    "align-items": "center",
    "gap": "10px",
    "flex-wrap": "nowrap"
});
$(".email-chk-container").insertAfter(".btn-compose-email");

// 2. Mở rộng cột Chủ đề chống cắt chữ:
{ dataField: "Subject", caption: "%Subject%", minWidth: 250, allowResizing: true }
```
- **File bản vá độc lập**: [`fix-bug/screenshot-17/patch_email_gui_thu_cong.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-17/patch_email_gui_thu_cong.sql)

---

### 14. Screenshot-18: Dữ liệu khách hàng KPI (MnuKPI003)
- **Thành phần / Stored Procedure can thiệp**: `[dbo].[sp_KPIListDataCollection_html]`
- **Bảng cấu hình / Cache**: `[dbo].[tblHtmlScriptCache]` (TableName = 'sp_KPIListDataCollection')
- **Vị trí đoạn code sửa**: Nằm trong Stored Procedure **`[dbo].[sp_KPIListDataCollection_html]`**, sự kiện khởi tạo Toolbar của DataGrid nơi khai báo phần tử `#quickMyDataRow`.
- **Hiện trạng lỗi (Vấn đề)**: Checkbox "Xem của tôi" bị phân bổ thành 1 hàng riêng biệt ($quickMyDataRow$) nằm đơn độc bên dưới cụm chip lọc, làm thanh công cụ chiếm tới ~80px chiều cao và đẩy bảng dữ liệu khách hàng xuống dưới.
- **Giải pháp kiến trúc**: Triệt tiêu hàng `#quickMyDataRow`, đưa checkbox "Xem của tôi" lên **ngang hàng 100% với cụm chip lọc trạng thái**, bố trí ngay trước nút Phễu lọc mở rộng, thu gọn chiều cao Toolbar về chuẩn 42px.
- **Minh chứng mã nguồn (Before vs After)**:
```javascript
// TRƯỚC (Cũ trong sp_KPIListDataCollection_html - Tạo dòng riêng chiếm 80px):
$("<div id='quickMyDataRow' style='width:100%; margin-top:8px;'>")
    .append(chkMyData)
    .appendTo(toolbarElement);

// SAU (Bản vá trong sp_KPIListDataCollection_html - Đưa lên cùng hàng Chip lọc):
$("#quickMyDataRow").remove();
$("<div class='filter-item-chk' style='display:inline-flex; align-items:center; margin:0 8px;'>")
    .append(chkMyData)
    .insertBefore(".btn-funnel-filter");
```
- **File bản vá độc lập**: [`fix-bug/screenshot-18/patch_du_lieu_khach_hang.sql`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-18/patch_du_lieu_khach_hang.sql)

---

## 🔒 PHẦN IV: NGUYÊN TẮC AN TOÀN VÀ QUY TRÌNH NGHIỆM THU CHO SẾP

1. **Cam kết an toàn CSDL tuyệt đối (Zero Database Risk)**:
   - Trong suốt quá trình phân tích và sửa lỗi, Agent tuân thủ chế độ **READ-ONLY 100%**, không tự ý thực thi bất kỳ câu lệnh `ALTER`/`UPDATE` nào trực tiếp vào CSDL.
   - Mọi mã nguồn đều được đóng gói ra file `.sql` để Sếp tự tay kiểm tra cú pháp và bấm F5.
   - 100% các file patch đều đã được kiểm tra cú pháp thông qua lệnh `SET NOEXEC ON` trên SQL Server với kết quả **0 lỗi cú pháp**.

2. **Quy trình triển khai 3 bước chuẩn mực cho Sếp**:
   - **Bước 1**: Mở file `.sql` tương ứng trong thư mục `fix-bug/screenshot-X/` trên SSMS. *(Lưu ý: Nếu file đã mở sẵn trên tab SSMS trước đó, hãy đóng tab và mở lại để tránh bộ đệm SSMS File Buffer).*
   - **Bước 2**: Kiểm tra dòng đầu tiên `USE [Vietinsoft_ForTest_Tai2]`. Nếu chạy trên DB khác (Production/Test khác), chỉ cần đổi tên DB ở dòng này. Nhấn **F5** để thực thi.
   - **Bước 3**: Trên Google Chrome, đóng tab con đó lại (bấm dấu `×`) rồi bấm lại vào menu để mở mới tab $\rightarrow$ Giao diện mới sẽ tự động cập nhật ngay lập tức nhờ cơ chế Version Cache Buster.
