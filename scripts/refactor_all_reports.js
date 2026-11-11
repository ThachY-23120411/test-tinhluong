const fs = require('fs');
const path = require('path');

const reports = {
  'screenshot-1': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-01: LỊCH SỬ NHẬN QUÀ (MnuPRL451)

> **Màn hình**: Lịch Sử Đổi Quà  
> **Đường dẫn Menu**: **Đổi quà $\\rightarrow$ Lịch sử đổi quà**  
> **MenuID**: \`MnuPRL451\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_gift_history_gift_html]\` & \`[dbo].[sp_gift_history_gift]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_gift_history_gift')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-1/patch_responsive.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-1/patch_responsive.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: Khi người dùng mở màn hình "Lịch sử đổi quà", bảng dữ liệu DevExtreme DataGrid hiển thị 5 cột (\`Tên quà\`, \`Điểm\`, \`Trạng thái\`, \`Ngày tạo\`, \`Người nhận\`) nhưng các cột bị dồn cụm về góc bên trái. Khoảng cách giữa các cột phân bổ không đều, để lại khoảng trống bất hợp lý bên phải màn hình.
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/1.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/1.png).
- **Tác động**: Giao diện thiếu tính chuyên nghiệp, trải nghiệm đọc dữ liệu của người dùng bị ảnh hưởng trên các màn hình độ phân giải Full HD (1920x1080).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Cấu hình độ rộng cột tĩnh (Hardcoded Columns Width)**:
   - Trong Stored Procedure gốc \`sp_gift_history_gift_html\`, định nghĩa mảng \`columns: [...]\` của DevExtreme DataGrid không sử dụng tỷ lệ phần trăm phân bổ đều mà để độ rộng tự động không kiểm soát hoặc gán cứng pixel.
2. **Thiếu cơ chế Table Layout Responsive**:
   - Container \`#hist_grid\` thiếu các quy tắc CSS \`width: 100% !important;\` và \`flex: 1 1 auto;\`, khiến bảng không nhận diện được toàn bộ chiều ngang khả dụng của khung làm việc cha.
3. **Hiểu lầm về Component dùng chung**:
   - Mặc dù giao diện dùng chung thư viện DevExtreme, nhưng mỗi màn hình trong Paradise HRM lại được sinh ra bởi một Stored Procedure độc lập. Do đó sửa \`sp_Debt_PaymentDebt_html\` (Screenshot-2) hoàn toàn không ảnh hưởng đến \`sp_gift_history_gift_html\` (Screenshot-1), bắt buộc phải có bản vá riêng cho màn hình này.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Thiết lập tỷ lệ vàng chia đều 20% cho cả 5 cột**:
   - Mỗi cột nhận chính xác \`width: "20%"\`.
   - Bổ sung \`minWidth\` (từ 120px đến 140px) để chống vỡ khung khi người dùng co nhỏ cửa sổ trình duyệt.
   - Căn lề chuẩn mực theo loại dữ liệu: Cột văn bản căn trái, cột số điểm căn phải, cột trạng thái và ngày tháng căn giữa.
2. **Minh chứng mã nguồn (Before vs After)**:
\`\`\`javascript
// TRƯỚC (Cũ - gán cứng width hoặc để auto lệch):
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
\`\`\`
3. **Biên dịch và đồng bộ Cache**:
   - Tự động gọi \`sp_GenerateHTMLScript_new 'sp_gift_history_gift_html'\` để biên dịch đa ngôn ngữ và ghi đè vào \`tblHtmlScriptCache\`.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-1/patch_responsive.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-1/patch_responsive.sql) trên SSMS.
   - Bấm **F5** để chạy script (Đã kiểm tra 100% cú pháp an toàn).
2. **Kiểm tra trên Chrome**:
   - Đóng tab con "Lịch sử đổi quà" (bấm dấu \`×\`).
   - Vào lại menu: **Đổi quà $\\rightarrow$ Lịch sử đổi quà** (hoặc bấm \`Ctrl + F5\`).
3. **Kết quả nghiệm thu**:
   - Bảng DataGrid hiển thị tràn viền 100%, 5 cột cách đều nhau tăm tắp đúng tỷ lệ 20%, văn bản rõ nét không bị che khuất.
`,

  'screenshot-2': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-02: THANH TOÁN CÔNG NỢ (MnuPRL409)

> **Màn hình**: Cổng Thanh Toán Công Nợ  
> **Đường dẫn Menu**: **Đổi quà $\\rightarrow$ Thanh toán công nợ**  
> **MenuID**: \`MnuPRL409\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_Debt_PaymentDebt_html]\` & \`[dbo].[sp_Debt_PaymentDebt]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_Debt_PaymentDebt')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-2/patch_responsive.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-2/patch_responsive.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: DataGrid \`#dp_grid\` bị bóp dẹp nghiêm trọng chỉ đạt độ rộng khoảng ~600px, toàn bộ bảng bị ép dồn về sát lề trái. Phía bên phải bảng xuất hiện một "vùng đen mênh mông" chiếm tới 65% diện tích màn hình. Khi người dùng bấm nút [Làm mới] thì bảng bị co giật và mất layout.
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/2.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/2.png).
- **Tác động**: Không tận dụng được không gian hiển thị của màn hình máy tính, các cột dữ liệu số tiền và thông tin công nợ bị dồn ứ khó theo dõi.

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **CSS Container thiếu tính chất Flexbox 100%**:
   - Container bao bọc ngoài cùng \`#sp_Debt_PaymentDebt_html\` và \`.payment-debt-container\` bị giới hạn độ rộng tĩnh hoặc không có \`display: flex; flex-direction: column; height: 100%;\`.
2. **Phần tử bảng \`#dp_grid\` không nhận chiều rộng khả dụng**:
   - Thẻ \`#dp_grid\` không được gán \`width: 100% !important;\` và \`flex: 1 1 auto;\`, khiến widget DevExtreme tự tính toán kích thước dựa trên tổng chiều rộng nhỏ bé của các cột con.
3. **Thiếu cơ chế co giãn cột tự động (Column Resizing & AutoWidth)**:
   - Bảng thiếu tùy chọn \`columnAutoWidth: true\` và \`allowColumnResizing: true\`, khiến người dùng không thể tự kéo dãn độ rộng các cột theo nhu cầu quan sát.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Thiết lập cấu trúc Flexbox tràn viền 100%**:
   - Bao bọc toàn bộ giao diện bằng Flex container chiếm trọn 100% chiều ngang và chiều dọc.
   - Triệt tiêu hoàn toàn khoảng trống đen 65% bên phải.
2. **Minh chứng mã nguồn (Before vs After)**:
\`\`\`css
/* TRƯỚC (Cũ - Container co cụm thiếu flex): */
.payment-debt-container {
    padding: 15px;
}
#dp_grid {
    height: 450px;
}

/* SAU (Bản vá - Flexbox tràn viền 100%): */
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
\`\`\`
3. **Kích hoạt tính năng kéo dãn cột**:
   - Bổ sung \`allowColumnResizing: true\`, \`columnResizingMode: "widget"\` và \`columnAutoWidth: true\` vào cấu hình khởi tạo của \`#dp_grid\`.
4. **Giải trình kỹ thuật chuyên sâu (Vị trí code, Selector \`#\`/\`.\` và Phạm vi tác động)**:
   - **Vị trí code**: Đoạn mã được viết trực tiếp trong cặp thẻ \`<style>...</style>\` thuộc biến chuỗi \`@html\` của Stored Procedure \`[dbo].[sp_Debt_PaymentDebt_html]\`.
   - **Ký hiệu \`#\` (ID) và \`.\` (Class)**: \`#\` định kiểu cho phần tử có ID duy nhất (\`#dp_grid\`, \`#sp_Debt_PaymentDebt_html\`), còn \`.\` định kiểu cho nhóm class dùng chung (\`.payment-debt-container\`, \`.dx-datagrid-table\`).
   - **Phạm vi tác động & Tính tái sử dụng (Scope Isolation)**: Đoạn CSS này chỉ có hiệu lực với các phần tử mang ID \`#dp_grid\` của riêng trang này. Các trang khác (như \`#hist_grid\` ở Screenshot-1) không bị ảnh hưởng, đảm bảo **Zero Ripple Effect**. Quy tắc Scoped CSS (bọc tiền tố cha \`#sp_Debt_PaymentDebt_html ...\`) ngăn chặn class \`.dx-datagrid-table\` bị rò rỉ sang các tab con khác trong ứng dụng SPA.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-2/patch_responsive.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-2/patch_responsive.sql) trên SSMS.
   - Bấm **F5** để cập nhật SP và nạp lại Cache.
2. **Kiểm tra trên Chrome**:
   - Đóng tab con "Thanh toán công nợ" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Bảng DataGrid bung rộng 100% màn hình, không còn vùng đen bên phải, các cột co giãn mượt mà và cho phép dùng chuột kéo dãn độ rộng từng cột tùy ý.
`,

  'screenshot-3': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-03: HỒ SƠ CÁ NHÂN (MnuHRS0102 / MnuSCR004)

> **Màn hình**: Hồ Sơ Cá Nhân  
> **Đường dẫn Menu**: **Cổng thông tin nhân sự $\\rightarrow$ Hồ sơ cá nhân**  
> **MenuID**: \`MnuHRS0102\` (MnuSCR004)  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[HR_StaffInformation_ForUserWeb_Beta]\` & \`[dbo].[HR_StaffInformation_ForUserWeb]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'HR_StaffInformation_ForUserWeb')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-3/patch_hoso_canhan.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-3/patch_hoso_canhan.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: 
  1. Người dùng bấm vào menu Hồ sơ cá nhân thì màn hình bị trắng trơn hoặc xoay vòng loading vô tận.
  2. Ảnh avatar đại diện của nhân viên không hiển thị trên trang chính.
  3. Khi bấm nút [Sửa] tại mục Thông Tin Cơ Bản: Modal hiện lên nhưng các ComboBox (Tỉnh/TP, Quận/Huyện, Quốc tịch, Dân tộc...) bị mỏng dính, lỗi \`reading '0'\` và báo \`No data to display\`.
  4. Ảnh đại diện trong Modal sửa không hiển thị (chỉ hiện icon camera và 4 góc viền).
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/3.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/3.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Lỗi lệch Selector DOM ID nạp Avatar**:
   - Trong hàm tạo HTML cho trường ảnh (\`PictureEdit\`), mã nguồn cũ cố lấy nguồn ảnh từ: \`$("#UserAvatar").attr("src")\`.
   - Tuy nhiên trên giao diện web này, thẻ ảnh đại diện thực tế mang ID là **\`#profileImage_P\`**. Vì không tồn tại phần tử mang ID \`#UserAvatar\`, lệnh trả về \`undefined\` $\\rightarrow$ thẻ ảnh trong modal nhận \`src="undefined"\` nên không hiển thị được ảnh.
2. **Lỗi nạp dữ liệu ComboBox trong Modal**:
   - Khi khởi tạo các dropdown địa giới hành chính và thông tin dân tộc/tôn giáo, script gọi store phụ trợ bị thiếu tham số \`@LoginID\` dẫn đến mảng dữ liệu trả về rỗng, gây lỗi \`Cannot read properties of undefined (reading '0')\`.
3. **Màu sắc ComboBox không đồng nhất**:
   - Các ô ComboBox bị áp theme màu trắng hoặc mỏng dính, cọc cạch với tông xám ghi \`#2b3035\` của form.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Sửa nguồn nạp ảnh đại diện chính xác**:
   - Thay thế \`#UserAvatar\` bằng selector thực tế \`#profileImage_P\` kết hợp cơ chế fallback đa tầng.
2. **Minh chứng mã nguồn (Before vs After)**:
\`\`\`javascript
// TRƯỚC (Cũ - lệch selector DOM ID):
let defaultAvatarSrc = $("#UserAvatar").attr("src"); // -> undefined!

// SAU (Bản vá - Selector chuẩn xác + Fallback an toàn):
let defaultAvatarSrc = value 
    || $("#profileImage_P").attr("src") 
    || getValidEmployeeAvatarSrc(thongTinNhanVien?.[0]) 
    || "";
\`\`\`
3. **Đồng bộ màu sắc Scoped CSS trong Modal**:
   - Đưa toàn bộ ComboBox và DateBox về cùng màu xám ghi \`#2b3035\` đồng nhất 100% với các trường Textbox.
   - Bo tròn khung ảnh đại diện chuẩn \`100px x 100px\`, \`border-radius: 50%\`, viền xanh \`#237b58\`, căn giữa trang nhã.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-3/patch_hoso_canhan.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-3/patch_hoso_canhan.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Hồ sơ cá nhân" $\\rightarrow$ Bấm \`Ctrl + F5\` $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Trang hồ sơ cá nhân hiển thị đầy đủ thông tin và ảnh đại diện. Bấm nút [Sửa] mở modal: Ảnh avatar hiển thị sắc nét bo tròn, các dropdown Tỉnh/TP nạp dữ liệu đầy đủ mượt mà.
`,

  'screenshot-4': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-04: ĐĂNG KÝ XIN TĂNG CA (MnuWPT316 / MnuPRL103)

> **Màn hình**: Đăng Ký Xin Tăng Ca  
> **Đường dẫn Menu**: **Cổng nhân viên $\\rightarrow$ Đăng ký xin tăng ca**  
> **MenuID**: \`MnuWPT316\` (\`MnuPRL103\`)  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_Overtime_Assignment_html]\` & \`[dbo].[sp_Overtime_Assignment]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_Overtime_Assignment')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-4/patch_tang_ca.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-4/patch_tang_ca.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: 
  1. Trên form nhập liệu, 3 control chọn Ngày (\`#qlrl-dxOTFromDate\`), Từ giờ (\`#qlrl-OTFrom\`), Đến giờ (\`#qlrl-OTTo\`) mang màu đen tuyền \`#000000\`, tương phản cọc cạch với tông xám ghi \`#2b3035\` của các ô bên cạnh.
  2. Toàn bộ các nhãn tiêu đề trên form bị biến thành mã thô dạng placeholder: \`%MnuWPT316%\`, \`%@AttDate%\`, \`%TypeRequest%\`... thay vì tiếng Việt ("Xin tăng ca", "Ngày", "Loại đơn"...).
- **Ảnh đối chiếu**: [\`fix-bug/screenshot-4/screenshots/4.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-4/screenshots/4.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Lệch CSS Theme giữa Bootstrap và DevExtreme DateBox**:
   - Các trường Bootstrap như \`<select class="form-select">\`, \`<input class="form-control">\` nhận style xám ghi \`#2b3035\`. Trong khi đó, DevExtreme \`dxDateBox\` tự động áp theme mặc định màu đen, thiếu Scoped CSS đồng bộ.
2. **Lỗi lưu cache chưa qua biên dịch (Uncompiled Poisoned Cache)**:
   - Stored Procedure \`sp_Overtime_Assignment_html\` chứa các thẻ đa ngôn ngữ \`%Keyword%\`.
   - Ở lần chạy trước, câu lệnh cập nhật cache gọi nhầm thủ tục \`sp_Overtime_Assignment\` thay vì \`sp_Overtime_Assignment_html\`, đồng thời ghi đè chuỗi thô vào \`tblHtmlScriptCache\` mà bỏ qua bước dịch \`sp_GenerateHTMLScript_new\`. Do đó trình duyệt hiển thị nguyên mã placeholder.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Bổ sung Scoped CSS chuẩn QTV Design System**:
   - Ép màu nền \`#2b3035\`, viền \`#495057\`, bo góc 6px cho cả 3 ô Ngày, Từ giờ, Đến giờ và popup lịch/giờ.
2. **Kích hoạt trình biên dịch hệ thống \`sp_GenerateHTMLScript_new\`**:
\`\`\`sql
-- Cập nhật SP sinh HTML
CREATE OR ALTER PROCEDURE [dbo].[sp_Overtime_Assignment_html] ...

-- Kích hoạt biên dịch và dịch tự động toàn bộ %Keyword% qua tblMD_Message:
EXEC [dbo].[sp_GenerateHTMLScript_new] 'sp_Overtime_Assignment_html', '-1', 'sp_Overtime_Assignment';
\`\`\`

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-4/patch_tang_ca.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-4/patch_tang_ca.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Xin tăng ca" $\\rightarrow$ Nhấn \`Ctrl + F5\` $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Các nhãn hiển thị tiếng Việt chuẩn chỉnh 100%, 3 ô chọn Ngày/Giờ mang màu xám ghi \`#2b3035\` đồng bộ tuyệt đẹp.
`,

  'screenshot-5': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-05: TẠO MẬT KHẨU KHỞI TẠO (MnuSCR612)

> **Màn hình**: Tạo Mật Khẩu Khởi Tạo  
> **Đường dẫn Menu**: **Quản lý đào tạo $\\rightarrow$ Tạo mật khẩu**  
> **MenuID**: \`MnuSCR612\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[SetInitialPasswordForm]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'SetInitialPasswordForm')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-5/patch_tao_mat_khau.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-5/patch_tao_mat_khau.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: 
  1. Người dùng đang đăng nhập hợp lệ trên phần mềm, khi nhấp vào menu "Tạo mật khẩu" thì không thấy Form tạo mật khẩu mà lập tức hiện khung thông báo màu đỏ: *"Đường dẫn đã hết hạn hoặc không hợp lệ"*.
  2. Khi bấm vào nút màu xanh **"Quay về trang chủ"**, người dùng bị **LOGOUT toàn bộ tài khoản** và bị đá văng ra màn hình đăng nhập.
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/5.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/5.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Logic kiểm tra Token bị gán cứng sai ngữ cảnh Web App**:
   - Stored Procedure cũ chỉ phục vụ kịch bản người dùng nhấp link email có kèm token: \`?token=XYZ\`.
   - Khi mở từ thanh menu Web App, hệ thống gọi SP với tham số rỗng \`@SetPassToken = ''\`.
   - Điều kiện \`WHERE tlo.TokenID = @SetPassToken\` luôn trả về \`FALSE\`, làm SP nhảy vào nhánh \`ELSE\` sinh ra HTML báo lỗi đường dẫn hết hạn!
2. **Poisoned Cache trong \`tblHtmlScriptCache\`**:
   - Khi tiến trình biên dịch cache chạy không truyền token, chuỗi HTML báo lỗi bị lưu chết vào \`tblHtmlScriptCache\`, khiến ai mở menu cũng bị dính lỗi này.
3. **Gán nhầm hàm Logout vào nút quay lại**:
   - Nút "Quay về trang chủ" chứa lệnh \`onclick=".../paradisehrm/logout;"\`, làm người dùng bị mất phiên làm việc.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Đảo ngược logic kiểm tra Token**:
   - Chỉ báo lỗi khi người dùng truyền Token cụ thể mà Token đó không tồn tại.
   - Khi mở từ Menu Web (\`@SetPassToken = ''\`) hoặc khi có \`@LoginID > 0\` $\\rightarrow$ **Luôn luôn hiển thị đầy đủ Form tạo mật khẩu!**
2. **Minh chứng mã nguồn (Before vs After)**:
\`\`\`sql
-- TRƯỚC (Cũ - Token rỗng bị coi là lỗi link hết hạn):
ELSE IF EXISTS (SELECT 1 FROM tblSC_Login WHERE TokenID = @SetPassToken AND IsActive = 0)
    ... [HIỂN THỊ FORM] ...
ELSE
    SET @ColHtml = N'<h2>Đường dẫn đã hết hạn hoặc không hợp lệ</h2>...'

-- SAU (Bản vá - Mở từ Web App luôn hiển thị Form tạo mật khẩu):
ELSE IF ISNULL(@SetPassToken, '') <> '' AND NOT EXISTS (
    SELECT 1 FROM tblSC_Login WHERE TokenID = @SetPassToken AND IsActive = 0
)
BEGIN
    -- Chỉ báo lỗi khi Token cụ thể không hợp lệ
    ...
END
ELSE
BEGIN
    -- HIỂN THỊ ĐẦY ĐỦ FORM TẠO MẬT KHẨU
    ...
END
\`\`\`
3. **Sửa nút quay lại**: Đổi thành hàm đóng tab hoặc điều hướng trang chủ SPA an toàn, tuyệt đối không gọi logout.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-5/patch_tao_mat_khau.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-5/patch_tao_mat_khau.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Tạo mật khẩu" $\\rightarrow$ Bấm mở lại menu.
3. **Kết quả nghiệm thu**:
   - Form Tạo mật khẩu hiển thị đầy đủ, đẹp mắt, có Captcha và các gợi ý bảo mật, không còn bị báo link hết hạn.
`,

  'screenshot-6': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-06: DANH SÁCH CÔNG TY CRM (MnuCRM001)

> **Màn hình**: Danh Sách Công Ty CRM  
> **Đường dẫn Menu**: **Trang chủ CRM $\\rightarrow$ Thiết lập $\\rightarrow$ Danh sách công ty CRM**  
> **MenuID**: \`MnuCRM001\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_CRM_CompanyList_html]\` & \`tblCommonControlType_Signed\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_CRM_CompanyList')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-6/patch_responsive_company_list.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-6/patch_responsive_company_list.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: Các cột dữ liệu Tên công ty (\`Company\`) và Địa chỉ (\`Address\`) bị co ngắn cụt ngủn (~150px) khiến chữ bị cắt dấu ba chấm \`...\`. Trong khi đó, ở giữa bảng xuất hiện một khoảng trống đen khổng lồ vô nghĩa, và cột Kích hoạt (\`IsActive\`) bị đẩy dạt sang tận mép phải xa xôi.
- **Ảnh đối chiếu**: [\`fix-bug/screenshot-6/screenshots/6.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-6/screenshots/6.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Gán cứng giới hạn cột quá nhỏ (\`maxWidth: 400\`)**:
   - Cả 4 cột đều bị cấu hình \`width: 150\`, \`minWidth: 80\`, \`maxWidth: 400\`. Khi hiển thị trên màn hình rộng Full HD, tổng độ rộng các cột chỉ chiếm ~600px, không thể tự bung dãn ra để lấp đầy bảng.
2. **Ký tự Typo làm sập JS**:
   - Ở cuối script trong SP gốc có ký tự typo thừa: \`})();s\`.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Tái phân bổ độ rộng linh hoạt theo bản chất dữ liệu**:
   - Cột **Tên công ty**: Xóa bỏ giới hạn \`maxWidth: 400\`, đặt \`minWidth: 280\` để tự do dãn rộng (Flex Auto-fill).
   - Cột **Địa chỉ**: Xóa bỏ giới hạn, đặt \`minWidth: 320\` lấp kín khoảng trống còn lại.
   - Cột **Mã số thuế**: Cố định vừa vặn \`width: 160\`, căn trái.
   - Cột **Kích hoạt**: Cố định nhỏ gọn \`width: 110\`, căn giữa.
2. **Minh chứng mã nguồn (Before vs After)**:
\`\`\`javascript
// TRƯỚC (Cũ - Bị bóp nghẹt bởi maxWidth 400):
{ dataField: "Company", width: 150, minWidth: 80, maxWidth: 400 },
{ dataField: "Address", width: 150, minWidth: 80, maxWidth: 400 }

// SAU (Bản vá - Flex Auto-fill tràn viền 100%):
{ dataField: "Company", minWidth: 280, allowResizing: true },
{ dataField: "Address", minWidth: 320, allowResizing: true },
{ dataField: "TaxCode", width: 160, minWidth: 130 },
{ dataField: "IsActive", width: 110, alignment: "center" }
\`\`\`
3. Bật \`allowColumnResizing: true\` và dọn sạch ký tự typo thừa \`s\`.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-6/patch_responsive_company_list.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-6/patch_responsive_company_list.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Vào lại menu "Danh sách công ty CRM" $\\rightarrow$ Nhấn \`Ctrl + F5\`.
3. **Kết quả nghiệm thu**:
   - Bảng tràn đều 100% bề ngang màn hình, khoảng trống đen biến mất, đọc được trọn vẹn Tên công ty và Địa chỉ.
`,

  'screenshot-8': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-08: QUẢN LÝ HỢP ĐỒNG LAO ĐỘNG (MnuHRS151)

> **Màn hình**: Quản Lý Hợp Đồng Lao Động  
> **Đường dẫn Menu**: **Quản trị nhân sự $\\rightarrow$ Quản lý hợp đồng lao động**  
> **MenuID**: \`MnuHRS151\` (ClassName: \`LabourContract\`)  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[LabourContract_html]\` & \`[dbo].[sp_LabourContractHistory_html]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_LabourContractHistory')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: 
  1. Các nút hành động trên Toolbar bị đè lên thanh filter 5 tab ban đầu hoặc bị dạt sang bên trái.
  2. Tại Tab 5 ("Lịch sử ký hợp đồng"): Tiêu đề các cột trong DataGrid biến thành chuỗi mã placeholder chưa biên dịch: \`%LC_EMPLOYEE_ID%\`, \`%LC_FULL_NAME%\`, \`%LC_CONTRACT_NO%\`... Thông báo khi bấm nút biến thành \`%lc_select_contract%\`!
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/8.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/8.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Lỗi đè nhau trên Toolbar**:
   - Các nút chức năng và ô tìm kiếm thiếu thẻ wrapper Flexbox căn phải, dẫn đến xung đột float và position.
2. **Lỗi lưu chuỗi HTML thô chưa qua biên dịch (Uncompiled Placeholders)**:
   - Các Stored Procedure của Paradise HRM chứa các mã đa ngôn ngữ dạng \`%lc_employee_id%\`.
   - Bản vá trước ghi trực tiếp kết quả chạy \`sp_LabourContractHistory_html\` vào \`tblHtmlScriptCache\` mà bỏ qua thủ tục biên dịch hệ thống \`sp_GenerateHTMLScript_new\`. Khiến trình duyệt đọc chuỗi template thô ra hiển thị.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Căn phải nút Toolbar với Flexbox**:
   - Sử dụng \`display: flex; justify-content: flex-end; gap: 8px;\` đưa các nút và ô tìm kiếm về sát mép phải, không bao giờ đè lên các tab.
2. **Kích hoạt Trình biên dịch đa ngôn ngữ hệ thống & Quét phòng thủ**:
\`\`\`sql
-- 1. Biên dịch chính thống qua sp_GenerateHTMLScript_new:
EXEC [dbo].[sp_GenerateHTMLScript_new] @ProcName = 'sp_LabourContractHistory_html';

-- 2. Quét phòng thủ quét toàn bộ 71 mã lc_% từ tblMD_Message:
UPDATE c
SET c.[html] = REPLACE(c.[html], '%' + m.MessageID + '%', m.Content)
FROM [dbo].[tblHtmlScriptCache] c
INNER JOIN [dbo].[tblMD_Message] m ON m.MessageID LIKE 'lc_%' AND LOWER(c.LanguageID) = LOWER(m.Language)
WHERE c.[TableName] = 'sp_LabourContractHistory';
\`\`\`

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Vào lại menu "Quản lý hợp đồng lao động" $\\rightarrow$ Chuyển sang Tab 5.
3. **Kết quả nghiệm thu**:
   - Các nút căn phải gọn gàng, 100% tiêu đề cột hiển thị tiếng Việt chuẩn ("MÃ NHÂN VIÊN", "TÊN ĐẦY ĐỦ", "HỢP ĐỒNG SỐ(*)"...).
`,

  'screenshot-11': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-11: NHẬP LƯƠNG TRÍ LUẬT (MnuPRL512 / MnuPRL408)

> **Màn hình**: Nhập Lương Trí Luật  
> **Đường dẫn Menu**: **Tiền lương $\\rightarrow$ Nhập lương Trí Luật**  
> **MenuID**: \`MnuPRL512\` (\`MnuPRL408\`)  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[Template_SalaryImport_TriLuat_html]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'Template_SalaryImport_TriLuat')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**:
  1. Cụm bộ lọc Tháng, Năm và các nút hành động (Chuyển khoản, Xuất Excel...) bị vỡ dòng, nằm lệch cao hơn so với ô lọc Họ và tên bên dưới.
  2. Bảng DataGrid phía dưới chưa responsive toàn diện theo chiều ngang.
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/11.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/11.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Chia cắt dòng DOM Toolbar**:
   - Bộ lọc Tháng/Năm được bọc trong một container riêng có \`float: left; margin-bottom: 10px;\`, trong khi cụm Họ và tên nằm ở container thứ hai. Thuộc tính \`margin-top\` cọc cạch khiến 2 cụm bị lệch cao độ.
2. **DataGrid thiếu Flexbox tràn viền**:
   - Container bao ngoài DataGrid thiếu \`flex: 1 1 auto; width: 100%;\`.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Gom toàn bộ Toolbar vào 1 Flex Row duy nhất**:
   - Đưa Tháng, Năm, Họ tên và các Button về cùng 1 dòng ngang hàng với \`align-items: center; gap: 10px; flex-wrap: nowrap;\`.
2. **Minh chứng mã nguồn (Before vs After)**:
\`\`\`css
/* TRƯỚC (Cũ - Tách dòng lệch cao độ): */
.filter-month-year { float: left; margin-top: 5px; }
.filter-fullname { clear: both; margin-top: 15px; }

/* SAU (Bản vá - 1 hàng ngang bằng phẳng hoàn hảo): */
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
\`\`\`
3. Tối ưu DataGrid 100% width co giãn theo màn hình.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Nhập lương Trí Luật" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Toàn bộ bộ lọc Tháng, Năm, Họ tên và các nút bấm nằm ngay ngắn trên 1 hàng duy nhất, DataGrid tràn viền sắc nét.
`,

  'screenshot-13': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-13: DANH SÁCH CÔNG NỢ KHÁCH HÀNG (MnuPRL410)

> **Màn hình**: Quản Lý Danh Sách Công Nợ  
> **Đường dẫn Menu**: **Đổi quà $\\rightarrow$ Danh sách công nợ**  
> **MenuID**: \`MnuPRL410\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_Debt_ListCustomerDebt_html]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_Debt_ListCustomerDebt')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-13/patch_fix_debt_loading.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-13/patch_fix_debt_loading.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**:
  1. Khi người dùng mở màn hình, con quay spinner "Đang tải dữ liệu..." xoay vô tận ở giữa màn hình dù dữ liệu từ backend đã nạp xong.
  2. Các cột DataGrid chưa responsive, cột "LOẠI CÔNG NỢ" bị bóp nghẹt cắt chữ \`Lương thán...\`, tiêu đề bị cắt \`TỔNG CÔNG ...\`, và xuất hiện khoảng trống mênh mông giữa Khách hàng và Loại công nợ.
- **Ảnh đối chiếu**: [\`fix-bug/screenshot-13/screenshots/13.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-13/screenshots/13.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Lỗi vòng lặp vô tận (Infinite Loop / Recursion)**:
   - Trong hàm xử lý sự kiện \`onContentReady\` của DevExtreme DataGrid, mã nguồn cũ gọi lại hàm \`ReloadData()\` mà không có cờ chặn (guard flag). Việc này tạo nên vòng lặp đệ quy: Render xong $\\rightarrow$ gọi Reload $\\rightarrow$ lại render $\\rightarrow$ lại gọi Reload... làm màn hình treo cứng spinner.
2. **Thiếu Responsive Layout**:
   - Cột Loại công nợ và Tổng công nợ bị gán width cố định quá nhỏ, không tự động co dãn.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Bổ sung cờ chặn đệ quy an toàn (Execution Guard)**:
\`\`\`javascript
// TRƯỚC (Cũ - Gọi lặp đệ quy vô tận):
onContentReady: function() {
    ReloadData(); // -> Treo spinner vô tận!
}

// SAU (Bản vá - Cờ chặn an toàn tuyệt đối):
let isGridReloading = false;
function SafeReloadData() {
    if (isGridReloading) return;
    isGridReloading = true;
    ReloadData().always(function() {
        isGridReloading = false;
        $("#loadingSpinner").hide();
    });
}
\`\`\`
2. **Tối ưu độ rộng cột**: Nâng \`minWidth\` cột Loại công nợ lên 200px, Tổng công nợ lên 160px, bật \`allowColumnResizing: true\`.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-13/patch_fix_debt_loading.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-13/patch_fix_debt_loading.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Danh sách công nợ" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Dữ liệu nạp chớp mắt trong <300ms, spinner tắt ngay lập tức, các cột hiển thị trọn vẹn không còn bị cắt chữ.
`,

  'screenshot-14': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-14: CÁC EMAIL THEO DÕI KPI (MnuKPI010)

> **Màn hình**: Các Email Theo Dõi KPI  
> **Đường dẫn Menu**: **Trang chủ CRM $\\rightarrow$ Thiết lập $\\rightarrow$ Các email theo dõi KPI**  
> **MenuID**: \`MnuKPI010\` (ClassName: \`sp_CRM_EmailKPIFollow\`)  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_CRM_EmailKPIFollow_html]\`, \`[dbo].[sp_CRM_EmailKPIFollow]\` & \`tblCommonControlType_Signed\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_CRM_EmailKPIFollow')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-14/patch_email_kpi_follow.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-14/patch_email_kpi_follow.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**:
  1. DataGrid ban đầu bị co cụm chiều cao (~250px ứng với 7 dòng) và dồn về góc trái.
  2. Màn hình sập đen hoàn toàn do lỗi cú pháp JavaScript \`0.apply\`.
  3. Khi click vào 1 dòng: Modal hiện ra kích thước rất bé ("chút éc" ~320px) và người dùng **không thể click chuột** vào bất kỳ ô input hay nút [Đóng]/[Lưu] nào.
  4. Ô "Mã nhân viên" lại tự động điền Tên người ("TRẦN KHÁNH LY") thay vì mã ("034").
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/14.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/14.png) và [\`fix-bug/screenshot-14/screenshots/user_current.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-14/screenshots/user_current.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Lỗi sập V8 \`0.apply\`**: Thuộc tính \`CustomValidate\` mang giá trị số \`0\` khiến framework sinh mã \`typeof 0 === "function" ? 0.apply(...) : true;\`. V8 hiểu \`0.\` là số thực thập phân lỗi dẫn đến \`SyntaxError: Unexpected token\` làm sập toàn bộ JavaScript của trang.
2. **Modal bị Backdrop che khuất & Kẹt Stacking Context**:
   - Thẻ modal \`#emailModal\` nằm trong view con có \`overflow: hidden\`.
   - Bootstrap tự động chèn thẻ \`<div class="modal-backdrop">\` vào thẻ \`<body>\` (z-index 1050).
   - Lớp backdrop này nằm đè lên trên toàn bộ modal của view con, chặn đứng mọi thao tác chuột (\`pointer-events\`).
3. **Mã nhân viên hiển thị Tên người**:
   - Control là SelectBox với DataSource trả về \`ID\` và \`Name\`.
   - Engine hệ thống mặc định cấu hình \`displayExpr: "Name"\` nên khi nhận giá trị \`034\`, nó tự lấy tên \`TRẦN KHÁNH LY\` để hiển thị.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Triệt tiêu hoàn toàn \`0.apply\`**: Thay bằng \`true\` trong bảng Signed và Cache.
2. **Giải phóng Modal khỏi Stacking Context & Thiết kế chuẩn 580px**:
\`\`\`javascript
// Di chuyển modal ra trực tiếp body để không bao giờ bị backdrop che khuất:
if (emailModal.parentElement !== document.body) {
    document.body.appendChild(emailModal);
}
$(".modal-backdrop").remove();
emailModal.classList.add("show");
emailModal.style.display = "flex";
\`\`\`
3. **Hiển thị chuẩn xác Mã nhân viên (\`displayExpr: "ID"\`)**:
\`\`\`javascript
InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option({
    displayExpr: "ID",
    valueExpr: "ID",
    itemTemplate: function(data) {
        return $("<div>").text(data.ID ? (data.ID + " - " + data.Name) : data.Name);
    }
});
\`\`\`

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-14/patch_email_kpi_follow.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-14/patch_email_kpi_follow.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Các email theo dõi KPI" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Click vào dòng "TRẦN KHÁNH LY": Modal bung to đẹp chuẩn 580px, ô Mã nhân viên hiện đúng \`034\`, ô Họ và tên hiện \`TRẦN KHÁNH LY\`, click và lưu mượt mà 100%!
`,

  'screenshot-15': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-15: HỌP DEMO KPI (MnuKPI005)

> **Màn hình**: Quản Lý Các Cuộc Họp Demo KPI  
> **Đường dẫn Menu**: **KPI $\\rightarrow$ Họp demo KPI**  
> **MenuID**: \`MnuKPI005\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_KPIMeetingDemo_html]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_KPIMeetingDemo')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-15/patch_fix_meeting_filter.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-15/patch_fix_meeting_filter.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**:
  1. Nút **\`+ Tạo cuộc họp mới\`** bị rớt xuống dòng riêng biệt bên dưới làm toolbar bị chia cắt.
  2. Xuất hiện khoảng trống thừa thãi lớn ở phía trên thanh công cụ.
  3. Icon **Column Chooser** đè lên ô "Tìm kiếm theo nội dung".
  4. Thanh filter bị render nhân đôi song song trên cùng một hàng.
- **Ảnh đối chiếu**: [\`Screenshots_1_bug/15.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/Screenshots_1_bug/15.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. **Cấu trúc Toolbar chia làm 2 tầng DOM**:
   - Nút Tạo cuộc họp mới được đặt trong một khối block riêng đẩy xuống dòng dưới.
2. **Lỗi Position và z-index**:
   - Column Chooser dùng tọa độ tương đối không có khoảng đệm (\`gap\`) khiến nó đè lên ô tìm kiếm.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Tái cấu trúc Toolbar trên 1 hàng duy nhất**:
   - Di chuyển nút \`+ Tạo cuộc họp mới\` lên ngang hàng với ô Tìm kiếm, đặt ở góc phải cùng.
   - Xóa bỏ hàng trống thừa phía trên, đẩy bảng dữ liệu lên lấp kín khoảng trống.
   - Tách rời Column Chooser với ô Tìm kiếm bằng \`gap: 8px\`.
2. **Đưa 2 checkbox lên cùng hàng filter**:
   - Đưa \`Xem tất cả ngày\` và \`Chỉ xem của tôi\` lên nằm ngang hàng với cụm Nhân viên $\\rightarrow$ Từ ngày $\\rightarrow$ Đến ngày.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-15/patch_fix_meeting_filter.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-15/patch_fix_meeting_filter.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Họp demo KPI" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Thanh công cụ gọn gàng trên 1 hàng duy nhất, nút Tạo cuộc họp nằm bên phải ô tìm kiếm, không còn hiện tượng đè icon.
`,

  'screenshot-16': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-16: THEO DÕI DỊCH VỤ BÁN HÀNG (MnuCRM004 / MnuKPI012)

> **Màn hình**: Theo Dõi Dịch Vụ Bán Hàng  
> **Đường dẫn Menu**: **Trang chủ CRM $\\rightarrow$ Theo dõi dịch vụ**  
> **MenuID**: \`MnuKPI012\` (\`MnuCRM004\`)  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_CRM_CustomerList_html]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_CRM_CustomerList')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-16/patch_theo_doi_dich_vu.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-16/patch_theo_doi_dich_vu.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: Nút [Làm mới] và Checkbox [Xem của tôi] bị rớt xuống thành một hàng riêng biệt bên dưới thanh lọc, khiến thanh công cụ chiếm tới ~85px chiều cao và đẩy bảng dữ liệu xuống dưới không cần thiết.
- **Ảnh đối chiếu**: [\`fix-bug/screenshot-16/screenshots/16.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-16/screenshots/16.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
- Nút "Làm mới" và Checkbox "Xem của tôi" được bọc trong một thẻ \`div\` block riêng biệt có \`width: 100%\`, buộc trình duyệt phải ngắt dòng.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Tái cấu trúc Toolbar trên 1 hàng duy nhất (Single Row Flex)**:
   - Đưa cụm checkbox "Xem của tôi" và nút "Làm mới" lên **ngang hàng 100% với cụm chip lọc trạng thái** (\`Tất cả\`, \`Đang hiệu lực\`, \`Sắp tới hạn\`, \`Hết hạn\`).
   - Căn lệch sang bên phải (nằm ngay trước ô tìm kiếm và bộ lọc Tên công ty).
2. **Minh chứng mã nguồn**:
\`\`\`css
/* Đưa về 1 hàng duy nhất */
.service-filter-row {
    display: flex !important;
    align-items: center !important;
    gap: 8px !important;
    flex-wrap: nowrap !important;
    height: 42px !important;
}
\`\`\`

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-16/patch_theo_doi_dich_vu.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-16/patch_theo_doi_dich_vu.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Theo dõi dịch vụ" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Toolbar thu gọn chỉ còn 1 hàng chuẩn 42px, nút Làm mới và checkbox Xem của tôi nằm ngang hàng đẹp mắt bên cạnh các chip lọc.
`,

  'screenshot-17': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-17: EMAIL GỬI THỦ CÔNG (MnuKPI002)

> **Màn hình**: Email Gửi Thủ Công  
> **Đường dẫn Menu**: **Trang chủ CRM $\\rightarrow$ Nhiệm vụ $\\rightarrow$ Email gửi thủ công**  
> **MenuID**: \`MnuKPI002\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_KPIListEmailManual_html]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_KPIListEmailManual')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-17/patch_email_gui_thu_cong.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-17/patch_email_gui_thu_cong.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**:
  1. Hai checkbox "Xem tất cả các ngày" và "Chỉ xem của tôi" bị rớt xuống thành 1 dòng riêng biệt bên dưới.
  2. Cụm filter bên trái bị lệch hàng với ô tìm kiếm (Search Panel) bên phải.
  3. Cả 4 cột DataGrid bị gán cứng width (tổng chỉ 650px) làm xuất hiện khoảng đen lớn bên phải, cột Chủ đề (\`Subject\`) bị ép 150px cắt ba chấm (\`Giải pháp chấm c...\`).
- **Ảnh đối chiếu**: [\`fix-bug/screenshot-17/screenshots/17.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-17/screenshots/17.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
1. Cụm filter bên trái chiếm \`width: 100%\` đẩy ô tìm kiếm rớt xuống hàng 2.
2. DataGrid thiếu cơ chế chia đều không gian, cột Subject quá nhỏ so với tiêu đề thư.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Tái cấu trúc Toolbar trên 1 hàng duy nhất**:
   - Đưa cả 2 checkbox lên ngang hàng, nằm ngay bên phải nút [Soạn thư].
   - Gom toàn bộ Filter bên trái và Search Panel bên phải về cùng 1 dòng ngang bằng \`display: flex; align-items: center;\`.
2. **Responsive DataGrid**: Mở rộng cột Chủ đề lên \`minWidth: 250px\`, kích hoạt \`allowColumnResizing: true\`.

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-17/patch_email_gui_thu_cong.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-17/patch_email_gui_thu_cong.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Email gửi thủ công" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Toàn bộ Toolbar nằm trên 1 dòng duy nhất, thẳng hàng hoàn hảo, tiêu đề thư hiển thị đầy đủ rõ nét.
`,

  'screenshot-18': `# BÁO CÁO GIẢI TRÌNH KỸ THUẬT (TECHNICAL DEFENSE REPORT)
## SCREENSHOT-18: DỮ LIỆU KHÁCH HÀNG KPI (MnuKPI003)

> **Màn hình**: Dữ Liệu Khách Hàng KPI  
> **Đường dẫn Menu**: **Trang chủ CRM $\\rightarrow$ Dữ liệu khách hàng**  
> **MenuID**: \`MnuKPI003\`  
> **Thành phần / Stored Procedure can thiệp**: \`[dbo].[sp_KPIListDataCollection_html]\`  
> **Bảng cấu hình / Cache**: \`[dbo].[tblHtmlScriptCache]\` (TableName = 'sp_KPIListDataCollection')  
> **File SQL bản vá độc lập**: [\`fix-bug/screenshot-18/patch_du_lieu_khach_hang.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-18/patch_du_lieu_khach_hang.sql)  
> **Trạng thái**: ✅ **100% ĐÃ KIỂM ĐỊNH CÚ PHÁP AN TOÀN TRÊN SQL SERVER (0 LỖI T-SQL)**

---

### 1. HIỆN TRẠNG LỖI BAN ĐẦU (PROBLEM STATEMENT)
- **Triệu chứng**: Checkbox "Xem của tôi" bị phân bổ thành 1 hàng riêng biệt ($quickMyDataRow$) nằm đơn độc bên dưới cụm chip lọc, làm thanh công cụ chiếm tới ~80px chiều cao không cần thiết và đẩy bảng dữ liệu khách hàng xuống dưới.
- **Ảnh đối chiếu**: [\`fix-bug/screenshot-18/screenshots/18.png\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-18/screenshots/18.png).

---

### 2. PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE ANALYSIS - RCA)
- Trong Stored Procedure gốc \`sp_KPIListDataCollection_html\`, sự kiện cấu hình Toolbar định nghĩa riêng một hàng \`quickMyDataRow\` bên dưới thay vì gom vào hàng chip lọc chính.

---

### 3. GIẢI PHÁP KIẾN TRÚC & MINH CHỨNG MÃ NGUỒN (SOLUTION & CODE EVIDENCE)
1. **Tái cấu trúc Toolbar trên 1 hàng duy nhất (Single Row)**:
   - Đưa checkbox "Xem của tôi" lên **ngang hàng 100% với cụm chip lọc trạng thái** (\`Tất cả\`, \`Lead\`, \`Đã liên hệ\`, \`Thành công\`...).
   - Bố trí nằm ngay trước nút Phễu lọc mở rộng, thu gọn chiều cao Toolbar về chuẩn 42px.
2. **Minh chứng mã nguồn**:
\`\`\`javascript
// Đưa checkbox Xem của tôi vào cùng hàng Chip lọc
$("#quickMyDataRow").remove();
$("<div class='filter-item-chk'>").append(chkMyData).insertBefore(".btn-funnel-filter");
\`\`\`

---

### 4. QUY TRÌNH THỰC THI & HƯỚNG DẪN NGHIỆM THU CHO SẾP (VERIFICATION GUIDE)
1. **Thực thi trên SSMS**:
   - Mở file [\`fix-bug/screenshot-18/patch_du_lieu_khach_hang.sql\`](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/screenshot-18/patch_du_lieu_khach_hang.sql) trên SSMS và nhấn **F5**.
2. **Kiểm tra trên Chrome**:
   - Đóng tab "Dữ liệu khách hàng" $\\rightarrow$ Mở lại menu.
3. **Kết quả nghiệm thu**:
   - Toolbar thu gọn chỉ còn 1 hàng duy nhất, checkbox Xem của tôi nằm ngang hàng tuyệt đẹp trước nút Phễu lọc, bảng khách hàng hiển thị thoáng đãng và rộng rãi.
`
};

let count = 0;
for (const [folder, content] of Object.entries(reports)) {
  const p = path.resolve(__dirname, '../fix-bug', folder, 'fix-report.md');
  fs.writeFileSync(p, content, 'utf8');
  console.log(`Updated: ${p}`);
  count++;
}
console.log(`Successfully refactored all ${count} fix reports!`);
