const fs = require('fs');
const path = require('path');

const targetFile = path.resolve(__dirname, '../docs/HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md');
let content = fs.readFileSync(targetFile, 'utf8');

// Replace from "### Câu 10: Các component dùng chung" to right before "### Câu 11: Giải phẫu mã nguồn"
const startMarker = "### Câu 10: Các component dùng chung gọi HTML của trang thì phạm vi nào thuộc về nội tại (bất biến) và phạm vi nào linh động tùy vào trang gọi nó?";
const endMarker = "### Câu 11: Giải phẫu mã nguồn fix lỗi giao diện (Screenshot-02):";

const startIndex = content.indexOf(startMarker);
const endIndex = content.indexOf(endMarker);

if (startIndex === -1 || endIndex === -1) {
    console.error("Markers not found! startIndex:", startIndex, "endIndex:", endIndex);
    process.exit(1);
}

const newSection10 = `### Câu 10: Các component dùng chung gọi HTML của trang thì phạm vi nào thuộc về nội tại (bất biến) và phạm vi nào linh động tùy vào trang gọi nó?

#### ❓ Thắc mắc của bạn:
> *"bây giờ nói cho tôi là các compoennt dùng chung gọi html của trang thì phạm vi nào thuộc về nội tại của nó (ở bất kì trang html gọi nó đều tuân thủ) và phạm vi nào linh động tùy vào trang html gọi nó (cũng là nó những ở mỗi html sẽ khác nhau)."*
> *"những cái này là hàm? hay thuộc tính của thẻ? hay là class? ... thì nhớ mở ngoặc ghi thêm vào cho tôi rõ. cập nhật lại vs toàn bộ control/component đi"*

#### 💡 Giải đáp chi tiết:
Trong kiến trúc phần mềm hướng Component (Component-Driven Architecture) của Paradise HRM, ranh giới giữa **Nội tại (Intrinsic - Bất biến)** và **Linh động (Contextual - Biến thiên)** được phân định rõ ràng. 

Để dễ dàng nắm bắt, mỗi thuật ngữ kỹ thuật dưới đây đều được **mở ngoặc chú thích rõ ràng bản chất**:
* *(Thuộc tính cấu hình JS / Option)*: Cấu hình truyền vào widget JavaScript.
* *(Hàm gọi lại / Callback Function)*: Đoạn mã hàm JavaScript tự viết để xử lý/vẽ giao diện.
* *(Sự kiện / Event Hook)*: Điểm móc để bắt sự kiện người dùng click, gõ phím hay khi dữ liệu nạp xong.
* *(Class CSS / Lớp định kiểu)*: Tên lớp CSS dùng chung để tạo kiểu dáng hiển thị.
* *(Thuộc tính CSS / CSS Property)*: Các quy tắc tạo kiểu như màu sắc, độ rộng, vị trí.
* *(ID HTML / Định danh phần tử)*: Tên định danh duy nhất của thẻ HTML trên trang.
* *(Thuộc tính thẻ HTML / HTML Attribute)*: Thuộc tính gắn trực tiếp vào thẻ HTML như \`disabled\`, \`placeholder\`.
* *(Thủ tục CSDL / Stored Procedure)*: Câu lệnh SQL chạy trên SQL Server.

---

### 📌 BẢNG TỔNG HỢP SO SÁNH 8 COMPONENT (NỘI TẠI vs LINH ĐỘNG)

| STT | Tên Component / Control | Phạm vi NỘI TẠI (Bất biến ở mọi trang HTML gọi nó) | Phạm vi LINH ĐỘNG (Biến thiên tùy theo từng trang HTML gọi nó) |
| :---: | :--- | :--- | :--- |
| **1** | **DataGrid (\`dxDataGrid\` / dgv)** | • Bộ khung thẻ DOM gồm các **Class CSS** (\`.dx-datagrid\`, \`.dx-datagrid-headers\`, \`.dx-datagrid-rowsview\`, \`.dx-datagrid-table\`).<br>• **Thuộc tính cấu hình JS** phân trang (\`pageSize: 15, 30, 50\`, \`showInfo: true\`).<br>• **Thuộc tính cấu hình JS** kéo dãn cột (\`allowColumnResizing: true\`, \`columnResizingMode: "widget"\`).<br>• **Sự kiện (Event Hooks)** theo vòng đời: \`init\` $\\rightarrow$ \`onContentReady\` $\\rightarrow$ \`onRowClick\`.<br>• **Thuộc tính cấu hình JS** nhãn rỗng \`noDataText\` và icon spinner chờ tải. | • **Thuộc tính cấu hình JS** nguồn dữ liệu (\`dataSource\`): Trỏ đến Stored Procedure tương ứng (\`sp_gift_history_gift\`, \`sp_Debt_PaymentDebt\`).<br>• **Mảng thuộc tính JS** danh sách cột (\`columns: [...]\`): Số lượng cột, định dạng hiển thị (\`format: "#,##0"\`).<br>• **Thuộc tính CSS / JS** tỷ lệ độ rộng (\`width\`, \`minWidth\`): Chia đều 20% hay chia 18%-15%-10%.<br>• **Hàm gọi lại JS (\`cellTemplate\`)**: Tự vẽ lại ô cụ thể của cột đó (Vẽ Badge xanh/đỏ, nút thu tiền inline, hoặc chữ 2 dòng).<br>• **Hàm bắt sự kiện JS (\`onRowClick\`)**: Mở Modal thanh toán PayOS hay mở Modal sửa nhân viên. |
| **2** | **ComboBox / SelectBox** | • **Class CSS** popup danh sách thả xuống (\`.dx-dropdowneditor-overlay\`).<br>• **Thuộc tính cấu hình JS** bật ô tìm kiếm nhanh (\`searchEnabled: true\`, \`searchMode: "contains"\`).<br>• Phím điều hướng bàn phím \`↑\`/\`↓\` và phím \`Enter\`.<br>• **Class CSS** icon mũi tên xổ xuống (\`.dx-icon-spindown\`).<br>• **Sự kiện (Event Hooks)**: \`onValueChanged\`, \`onOpened\`, \`onClosed\`. | • **Thuộc tính cấu hình JS** nguồn danh mục (\`dataSource\`): Danh sách nạp từ bảng Nhân viên, Phòng ban hay Tỉnh/Thành.<br>• **Thuộc tính cấu hình JS** trường giá trị ngầm máy lưu (\`valueExpr: "ID"\` $\\rightarrow$ Lưu mã ngầm).<br>• **Thuộc tính cấu hình JS** trường in chữ cho người đọc (\`displayExpr\`: Trang KPI hiện Mã \`"ID"\` $\\rightarrow$ \`034\`, trang khác hiện Tên \`"Name"\` $\\rightarrow$ "Trần Khánh Ly").<br>• **Hàm gọi lại JS (\`itemTemplate\`)**: Tùy biến vẽ layout cho từng dòng trong danh sách xổ xuống (Ảnh avatar + Mã + Tên + Phòng ban).<br>• **Hàm bắt sự kiện JS (\`onValueChanged\` - Ripple Effect)**: Chọn nhân viên tự điền email vào ô bên cạnh; chọn Tỉnh tự lọc lại Huyện. |
| **3** | **TextBox / NumberBox / DateBox** | • **Thuộc tính CSS** theme nền xám (\`background: #2b3035\`), viền (\`border: 1px solid #495057\`).<br>• Bộ popup lịch tháng/năm tích hợp sẵn của \`dxDateBox\`.<br>• Bộ nút mũi tên tăng giảm số của \`dxNumberBox\`.<br>• **Thuộc tính cấu hình JS** bật nút xóa nhanh \`×\` (\`showClearButton: true\`).<br>• **Sự kiện (Event Hooks)**: \`onInput\`, \`onChange\`, \`onFocusIn\`, \`onFocusOut\`. | • **Thuộc tính cấu hình JS** định dạng tiền/số (\`format: "#,##0 VNĐ"\`) và mặt nạ nhập liệu (\`mask: "(0##) ###-####"\`).<br>• **Mảng cấu hình JS** quy tắc kiểm tra (\`validationRules: [RequiredRule, EmailRule]\`).<br>• **Thuộc tính cấu hình JS** khóa chỉ đọc (\`readOnly: true/false\`) hoặc **Thuộc tính thẻ HTML** (\`disabled\`).<br>• **Thuộc tính thẻ HTML / JS** chữ gợi ý mờ trong ô (\`placeholder: "Nhập họ tên..."\`). |
| **4** | **Card KPI / Metric Card** | • **Thuộc tính CSS** bo góc (\`border-radius: 12px\`), bóng đổ (\`box-shadow\`), viền mờ \`border\`.<br>• Phân tầng thị giác: Icon tròn $\\rightarrow$ Title nhỏ $\\rightarrow$ Value số to $\\rightarrow$ Trend badge.<br>• **Thuộc tính CSS** hiệu ứng hover nhấc nhẹ (\`transform: translateY(-2px)\`).<br>• **Class CSS** khung nhấp nháy chờ nạp số liệu (\`.skeleton-loading\`). | • **Thẻ HTML \`<i>\` & nhãn text**: Icon nghiệp vụ (💵, 📑, 🏋️) và tên chỉ số.<br>• **Hàm SQL Server** tính toán số liệu (\`SUM(DoanhThu)\`, \`COUNT(NhanVien)\`).<br>• **Mã màu CSS** theo tính chất: Tích cực xanh lá (\`#2E7D32\`), cảnh báo đỏ (\`#E53935\`), chờ xử lý vàng (\`#FBC02D\`).<br>• **Hàm bắt sự kiện JS (\`onclick\`)**: Bấm card tự động lọc DataGrid bên dưới (Drill-down). |
| **5** | **Card / Panel / Container** | • Các **Class CSS** phân chia cấu trúc vùng (\`.card-header\`, \`.card-body\`, \`.card-footer\`).<br>• **Thuộc tính CSS** đường kẻ ngăn cách (\`border-bottom\`), khoảng cách đệm (\`padding: 16px - 24px\`). | • **Thuộc tính CSS** cơ chế co giãn: Form dùng \`height: auto\`, Bảng dùng Flexbox tràn viền 100% (\`flex: 1 1 auto; height: 100%\`).<br>• **Các thẻ HTML/DOM nhúng bên trong**: Chứa Form 2 cột, chứa TabStrip 10 tabs, hay chứa DataGrid.<br>• **Nhóm nút công cụ HTML trên Header**: Nút [Xuất Excel], [In biểu mẫu] hoặc [Ẩn/Hiện filter]. |
| **6** | **Modal / Popup / Dialog** | • **Thuộc tính CSS** lớp nền tối overlay (\`position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,0.7)\`).<br>• Cấu trúc 3 tầng: Modal Header (nút \`×\`) $\\rightarrow$ Modal Body (cuộn dọc \`overflow-y: auto\`) $\\rightarrow$ Modal Footer (nút [Đóng] và [Lưu]).<br>• Bẫy phím bàn phím \`Escape\` và **Class CSS** khóa cuộn trang (\`body.modal-open\`).<br>• **Hàm DOM JavaScript** thoát Stacking Context: \`document.body.appendChild(modal)\`. | • **Thuộc tính CSS** độ rộng: Modal xác nhận nhỏ 400px; Modal KPI chuẩn 580px; Modal QR PayOS rộng 800px - 900px.<br>• **Các thẻ Form HTML nhúng trong Body**: Nơi chứa đổi Avatar, nơi chứa form mail KPI, nơi chứa mã QR.<br>• **Tên Stored Procedure SQL** gọi thực thi khi bấm [Lưu]: \`sp_CRM_EmailKPIFollow\`, \`HR_StaffInformation_Save\`.<br>• **Hàm gọi lại JS sau khi đóng**: Tự gọi \`ReloadData()\` làm mới DataGrid hoặc cập nhật lại avatar header. |
| **7** | **Filter Toolbar / Search Panel** | • **Thuộc tính CSS** Flexbox 1 hàng phẳng chuẩn 42px (\`display: flex; gap: 8px; flex-wrap: nowrap; min-height: 42px\`).<br>• Phân chia 2 vế: Vế trái là bộ lọc, Vế phải dùng **Thuộc tính CSS** \`margin-left: auto\` để đẩy Search box về sát lề phải.<br>• **Kỹ thuật lập trình JS** tự động tìm kiếm hoãn 300ms (Debounce). | • **Các thẻ HTML Form điều khiển**: Thẻ \`<select>\` Tháng/Năm, Thẻ \`<input>\` tìm kiếm, Checkbox \`[Xem của tôi]\`, Các thẻ chip trạng thái \`[Lead]\`, \`[Đã liên hệ]\`.<br>• **Hàm JavaScript xử lý lọc**: Lọc trực tiếp trên mảng RAM trình duyệt hay gửi AJAX gọi lại Stored Procedure. |
| **8** | **Button / Action Bar** | • Các **Class CSS** phân cấp màu Design System: \`.btn-primary\` (Xanh \`#2E7D32\`), \`.btn-danger\` (Đỏ \`#E53935\`), \`.btn-secondary\` (Xám).<br>• **Thuộc tính CSS** hiệu ứng vật lý: \`hover: translateY(-1px)\`, \`active: scale(0.98)\`.<br>• **Thuộc tính thẻ HTML** khóa chống click đúp (\`disabled\`) kèm **Class CSS** con quay xoay (\`.spinner-border\`). | • **Thuộc tính thẻ HTML** nhãn chữ & icon: \`+ Thêm nhân sự\`, \`+ Tạo cuộc họp\`, \`💳 Thanh toán\`.<br>• **Thuộc tính cấu hình JS kiểm tra phân quyền**: Khóa hoặc ẩn nút (\`visible: false\`, \`disabled: true\`) theo quyền tài khoản.<br>• **Hàm bắt sự kiện JS (\`onclick\`)**: Validate dữ liệu và gọi API lưu tương ứng của từng phân hệ. |

---

### PHÂN TÍCH CHUYÊN SÂU TỪNG CONTROL / COMPONENT CÓ MỞ NGOẶC CHÚ THÍCH BẢN CHẤT:

---

### 1. DataGrid (dgv - Lưới dữ liệu bảng biểu)
*Được sử dụng tại hầu hết các màn hình danh sách (Quà tặng, Công nợ, Danh sách công ty, Hợp đồng lao động, Thiết bị...)*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Lõi Engine & Cấu trúc DOM chuẩn**: Thư viện DevExtreme (\`dxDataGrid\`) luôn sinh ra cùng một bộ khung thẻ HTML gồm các **Class CSS** (\`.dx-datagrid\`, \`.dx-datagrid-headers\`, \`.dx-datagrid-rowsview\`, \`.dx-datagrid-table\`).
  * **Bộ máy phân trang**: Các **Thuộc tính cấu hình JS** (\`pageSize: 15, 30, 50\` - số dòng hiển thị mỗi trang), (\`showInfo: true\` - hiển thị tổng số dòng), thuật toán chuyển trang.
  * **Cơ chế sắp xếp & Lọc cơ bản**: Nhấp vào header cột để đổi chiều tăng/giảm (Asc/Desc), cơ chế lọc theo dòng (**Thuộc tính cấu hình JS** \`filterRow: { visible: true }\`).
  * **Bộ máy kéo dãn cột**: Các **Thuộc tính cấu hình JS** (\`allowColumnResizing: true\` - cho phép dùng chuột kéo dãn cột), (\`columnResizingMode: "widget"\` - co giãn các cột lân cận).
  * **Vòng đời sự kiện (Lifecycle)**: Các **Sự kiện (Event Hooks)** chạy theo thứ tự bất biến: (\`onInitialized\` - khi widget bắt đầu khởi tạo) $\\rightarrow$ (\`onContentReady\` - khi đã vẽ xong bảng lên màn hình) $\\rightarrow$ (\`onRowClick\` - khi click chuột vào dòng) $\\rightarrow$ (\`onCellPrepared\` - trước khi vẽ từng ô).
  * **Trạng thái rỗng & Chờ dữ liệu**: Con quay spinner mặc định và **Thuộc tính cấu hình JS** (\`noDataText: "Không có dữ liệu"\`).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Nguồn dữ liệu nghiệp vụ**: **Thuộc tính cấu hình JS** (\`dataSource\` - trỏ đến Stored Procedure tương ứng như \`sp_gift_history_gift\`, \`sp_Debt_PaymentDebt\`).
  * **Danh sách cột & Tiêu đề**: **Mảng thuộc tính cấu hình JS** (\`columns: [...]\`):
    - Tên trường dữ liệu: **Thuộc tính cấu hình cột** (\`dataField: "CustomerName"\`, \`dataField: "Point"\`).
    - Nhãn tiêu đề: **Thuộc tính cấu hình cột** (\`caption: "%Keyword%"\` - dịch tự động từ CSDL).
    - Căn lề: **Thuộc tính cấu hình cột** (\`alignment: "left"\`, \`"center"\`, \`"right"\`).
    - Định dạng số/ngày: **Thuộc tính cấu hình cột** (\`format: "#,##0 VNĐ"\`, \`format: "dd/MM/yyyy"\`).
  * **Tỷ lệ độ rộng & Quy tắc chia cột**: Các **Thuộc tính cấu hình cột** (\`width: "20%"\`, \`minWidth: 140\` - pixel hoặc tỷ lệ %).
  * **Hàm vẽ giao diện riêng cho từng ô của 1 cột cụ thể**: **Hàm gọi lại JS (Callback Function)** (\`cellTemplate: function(container, options) { ... }\`):
    - Khai báo nằm lọt trong dấu ngoặc \`{ ... }\` của cột nào thì chỉ áp dụng để vẽ lại các ô (\`Cells\`) của riêng cột đó trên mọi dòng.
    - Cột Khách hàng: Vẽ 2 dòng chữ trong 1 ô (Dòng trên là Tên in đậm, dòng dưới là MST/Mã nhỏ mờ).
    - Cột Trạng thái: Thay vì hiện text thô thì vẽ viên thuốc Badge màu (Đã thanh toán xanh lá, Chưa thanh toán đỏ).
    - Cột Thao tác: Vẽ các nút bấm hành động inline (Nút [Thu tiền], Nút [Sửa], Icon [Xóa]).
    > 💡 **Hỏi nhanh - Đáp gọn về \`cellTemplate\`:**
    > * **Nó có phải là giá trị của cả 1 dòng (Row) không?**  
    >   $\\rightarrow$ **KHÔNG**. Nó chỉ là giá trị/giao diện của **MỘT Ô (CELL)** tại một cột cụ thể trên dòng đó (Một dòng gồm nhiều ô).
    > * **Làm sao trình duyệt biết nó áp dụng cho cột nào?**  
    >   $\\rightarrow$ Nhờ vào **vị trí đặt dấu ngoặc nhọn \`{ ... }\`** của cột đó trong mảng \`columns: [ ... ]\`. Bạn đặt \`cellTemplate\` lọt vào bên trong \`{ ... }\` của cột nào thì nó chỉ vẽ cho các ô của riêng cột đó!
  * **Tác vụ khi bấm vào dòng**: **Hàm bắt sự kiện JS (Event Hook)** (\`onRowClick\` / \`onCellClick\`):
    - Click vào dòng trang này: Mở Modal chi tiết thanh toán PayOS.
    - Click vào dòng trang kia: Mở Modal sửa thông tin nhân viên (Screenshot-14).
    - Click vào dòng trang khác: Điều hướng chuyển tab hoặc tích chọn checkbox.

---

### 2. ComboBox / SelectBox / DropDownList (Hộp chọn danh mục)
*Được sử dụng để chọn Nhân viên, Phòng ban, Chi nhánh, Trạng thái, Tỉnh/Thành...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Cơ chế Popup danh sách**: Click vào control sẽ bung ra một danh sách thả xuống mang **Class CSS** (\`.dx-dropdowneditor-overlay\`), click ra ngoài hoặc bấm phím bàn phím \`Escape\` sẽ tự động đóng lại.
  * **Bộ máy tìm kiếm nhanh nội bộ**: Các **Thuộc tính cấu hình JS** (\`searchEnabled: true\` - bật ô gõ tìm kiếm), (\`searchMode: "contains"\` - tìm kiếm chuỗi con).
  * **Điều khiển bàn phím (Keyboard Navigation)**: Bấm phím \`↑\`/\`↓\` để chọn mục, bấm \`Enter\` để xác nhận.
  * **Thiết kế chuẩn hệ thống**: Viền border xám, bo góc chuẩn, icon mũi tên mang **Class CSS** (\`.dx-icon-spindown\`) ở mép phải.
  * **Các sự kiện cốt lõi**: Các **Sự kiện (Event Hooks)** (\`onValueChanged\` - khi giá trị thay đổi), (\`onOpened\`, \`onClosed\` - khi mở/đóng danh sách).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Nguồn danh mục**: **Thuộc tính cấu hình JS** (\`dataSource\` - nạp mảng các đối tượng từ bảng Nhân viên, Phòng ban hay Tỉnh/Thành).
  * **Cấu hình trường hiển thị & trường giá trị**:
    - **Thuộc tính cấu hình JS** (\`valueExpr: "ID"\` - **Giá trị ngầm máy lưu**): Chỉ định trường nào sẽ gửi về CSDL khi bấm Lưu (thường là Mã/ID ngầm).
    - **Thuộc tính cấu hình JS** (\`displayExpr\` - **Chữ người xem trên màn hình**):
      + Ở trang KPI (Screenshot-14): Cần hiện Mã NV $\\rightarrow$ Cấu hình (\`displayExpr: "ID"\` $\\rightarrow$ hiện \`034\`).
      + Ở trang phân công: Cần hiện Tên NV $\\rightarrow$ Cấu hình (\`displayExpr: "Name"\` $\\rightarrow$ hiện "Trần Khánh Ly").
  * **Giao diện dòng item trong danh sách xổ xuống**: **Hàm gọi lại JS (Callback Function)** (\`itemTemplate: function(data) { ... }\`):
    - Trang bình thường: Chỉ hiện mỗi tên chữ đơn thuần.
    - Trang nâng cao: Render 2 cột \`[Mã] - [Họ tên]\` kèm ảnh avatar đại diện thu nhỏ bên cạnh.
  * **Hiệu ứng lan tỏa khi chọn (Ripple Effect)**: **Hàm bắt sự kiện JS (Event Hook)** (\`onValueChanged: function(e) { ... }\`):
    - Khi chọn nhân viên ở trang Email KPI: Tự động trích xuất Email và Tên điền tự động vào 2 ô bên cạnh.
    - Khi chọn Tỉnh/TP ở trang Hồ sơ cá nhân: Tự động lọc lại danh sách Quận/Huyện của Tỉnh/TP đó (Cascading Dropdown).
    - Khi chọn Trạng thái ở trang Toolbar: Tự động kích hoạt DataGrid tải lại dữ liệu tương ứng.
  * **Ràng buộc nghiệp vụ**: **Thuộc tính cấu hình JS** (\`isRequired: true\` - bắt buộc chọn), (\`placeholder: "-- Chọn nhân sự --"\` - chữ gợi ý khi chưa chọn).

---

### 3. TextBox / NumberBox / DateBox (Nhóm ô nhập liệu Form Input)
*Được sử dụng nhập văn bản, nhập số tiền, chọn ngày tháng năm...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Bộ khung Input Control**: Cung cấp ô nhập liệu văn bản với kiểu dáng **Thuộc tính CSS** chuẩn QTV Design System: nền xám (\`background: #2b3035\`), viền (\`border: 1px solid #495057\`), bo góc (\`border-radius: 6px\`), màu chữ (\`color: #e9ecef\`).
  * **Bộ lịch chọn ngày của DateBox**: Bấm vào hiện ra popup lịch tháng/năm, các nút chuyển tháng \`◀ / ▶\`, nút chọn nhanh "Hôm nay".
  * **Bộ tăng giảm số của NumberBox**: Nút bấm mũi tên tăng giảm số lượng, tự động chặn người dùng gõ chữ vào ô số.
  * **Tiện ích nút xóa nhanh**: **Thuộc tính cấu hình JS** (\`showClearButton: true\` - hiện dấu \`×\` bên phải khi có chữ để xóa trắng nội dung bằng 1 click).
  * **Các sự kiện nền tảng**: Các **Sự kiện (Event Hooks)** (\`onInput\` - khi đang gõ từng phím), (\`onChange\` - khi giá trị đổi), (\`onFocusIn\`, \`onFocusOut\` - khi con trỏ chuột nhảy vào/ra khỏi ô).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Định dạng & Mặt nạ nhập liệu**:
    - **Thuộc tính cấu hình JS** (\`format: "#,##0 VNĐ"\` - tự động thêm dấu phẩy ngàn cho số tiền).
    - **Thuộc tính cấu hình JS** (\`mask: "(0##) ###-####"\` - mặt nạ cho số điện thoại).
    - **Thuộc tính cấu hình JS** (\`format: "dd/MM/yyyy"\` - định dạng ngày tháng năm).
  * **Quy tắc kiểm tra tính hợp lệ**: **Mảng các quy tắc cấu hình JS** (\`validationRules: [...] \`):
    - Bắt buộc nhập: Đối tượng quy tắc (\`{ type: "required", message: "Vui lòng nhập họ tên" }\`).
    - Kiểm tra email: Đối tượng quy tắc (\`{ type: "email", message: "Email không hợp lệ" }\`).
    - Giới hạn số tiền: Đối tượng quy tắc (\`{ type: "range", min: 1000, max: 500000000 }\`).
  * **Trạng thái phân quyền thao tác**:
    - **Thuộc tính cấu hình JS** (\`readOnly: true\` - khóa chỉ đọc, màu xám mờ).
    - **Thuộc tính thẻ HTML / JS** (\`disabled: true\` - vô hiệu hóa hoàn toàn ô nhập).
  * **Gợi ý hiển thị**: **Thuộc tính thẻ HTML / JS** (\`placeholder: "Nhập số hợp đồng..."\`, \`"ly.tran@phanmemtinhluong.com"\`).

---

### 4. Card KPI / Metric Card (Thẻ chỉ số tổng quan)
*Được sử dụng ở đầu trang Dashboard, trang CRM 360°, trang Báo cáo bán hàng, Chấm công...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Bố cục khung thẻ chuẩn**: Các **Thuộc tính CSS** bo góc (\`border-radius: 12px\`), bóng đổ (\`box-shadow: 0 2px 8px rgba(0,0,0,0.15)\`), viền mờ (\`border: 1px solid rgba(128,128,128,0.2)\`).
  * **Phân tầng thông tin thị giác (Visual Hierarchy)**:
    - Vị trí 1: Icon đại diện tròn nổi bật bên trái hoặc góc trên phải.
    - Vị trí 2: Nhãn tiêu đề (Card Label) chữ nhỏ, mờ (opacity 75%).
    - Vị trí 3: Giá trị số đo lớn (Metric Value) cỡ chữ 24px - 28px in đậm.
    - Vị trí 4: Chỉ số tăng giảm hoặc thanh tiến độ (Trend badge / Progress bar).
  * **Hiệu ứng tương tác**: **Thuộc tính CSS** khi di chuột hover (\`transform: translateY(-2px)\` - nhấc nhẹ lên 2px) và đổi viền sáng.
  * **Hiệu ứng chờ tải**: **Class CSS** (\`.skeleton-loading\` - tạo khung nhấp nháy xám trong khi chờ API trả số liệu).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Ý nghĩa chỉ số nghiệp vụ & Icon minh họa**:
    - **Thẻ HTML \`<i>\`**: Trang CRM dùng icon tiền (💵), hợp đồng (📑), nợ (⚠️); Trang Gym dùng icon tạ (🏋️).
  * **Nguồn dữ liệu & Công thức tính toán**:
    - **Hàm SQL Server**: Lấy hàm \`SUM(TotalAmount)\` từ bảng Hợp đồng; Lấy hàm \`COUNT(EmployeeID)\` từ bảng Chấm công.
  * **Màu sắc nhấn nhận diện**: Các **Mã màu CSS**:
    - Chỉ số tích cực: Màu xanh lá (\`#2E7D32\`).
    - Chỉ số cảnh báo rủi ro: Màu đỏ (\`#E53935\`).
    - Chỉ số chờ xử lý: Màu vàng cam (\`#FBC02D\`).
  * **Hành vi tương tác khi bấm vào thẻ**: **Hàm bắt sự kiện JS** (\`onclick: function() { ... }\`):
    - Bấm vào Card "Chưa thanh toán" $\\rightarrow$ DataGrid phía dưới tự động lọc danh sách chỉ hiện đơn nợ (Drill-down).
    - Bấm vào Card "Hợp đồng sắp hết hạn" $\\rightarrow$ Mở trang danh sách hợp đồng cần tái ký.

---

### 5. Card / Panel / Container (Khung bao bọc nội dung phân khu)
*Được sử dụng làm khối bao bọc Form, bao bọc Bảng, khối Sidebar chi tiết...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Cấu trúc 3 phân khu chuẩn**: Các **Class CSS** phân vùng:
    - **Header**: **Class CSS** (\`.card-header\` - thanh tiêu đề phân khu + cụm nút công cụ phụ).
    - **Body**: **Class CSS** (\`.card-body\` - vùng làm việc chính chứa form hoặc bảng).
    - **Footer**: **Class CSS** (\`.card-footer\` - thanh chân trang chứa nút xác nhận hành động).
  * **Quy chuẩn bố cục & Khoảng cách**: Các **Thuộc tính CSS** khoảng cách đệm (\`padding: 16px - 24px\`), bo góc (\`border-radius: 12px\`), đường kẻ phân cách (\`border-bottom: 1px solid rgba(128,128,128,0.15)\`).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Kích thước & Cơ chế co giãn**: Các **Thuộc tính CSS**:
    - Card chứa Form (Screenshot-5): Dùng chiều cao tự động (\`height: auto\`), độ rộng cố định (\`width: 500px\`), căn giữa (\`margin: auto\`).
    - Card chứa Bảng (Screenshot-2): Dùng Flexbox tràn viền 100% (\`flex: 1 1 auto; height: 100%; width: 100%\`).
  * **Nội dung nhúng bên trong Body**:
    - Nơi thì chứa các thẻ HTML Form 2 cột.
    - Nơi thì chứa 10 thẻ TabStrip điều hướng (Trang Chi tiết khách hàng 360°).
    - Nơi thì chứa DataGrid kết hợp sơ đồ đồ thị Chart.
  * **Nút bấm công cụ trên Header**:
    - Màn hình thì có các thẻ nút HTML: Nút [Xuất Excel], [In ấn].
    - Màn hình thì có nút [Ẩn/Hiện bộ lọc nâng cao], nút [Thu nhỏ card].

---

### 6. Modal / Popup / Dialog (Cửa sổ hội thoại nổi)
*Được sử dụng khi Thêm mới, Sửa thông tin, Quét mã QR thanh toán, Hộp thoại xác nhận...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Cơ chế lớp phủ toàn màn hình**: Các **Thuộc tính CSS** định vị phủ toàn màn hình (\`position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,0.7)\`), căn giữa (\`display: flex; align-items: center; justify-content: center\`).
  * **Cấu trúc 3 tầng chuẩn**:
    - **Modal Header**: **Class CSS** (\`.modal-header\` - tiêu đề + nút đóng dấu \`×\`).
    - **Modal Body**: **Class CSS** (\`.modal-body\` - cuộn dọc mượt mà \`overflow-y: auto; max-height: 80vh\`).
    - **Modal Footer**: **Class CSS** (\`.modal-footer\` - nút [Đóng / Hủy] bên trái, nút [Lưu dữ liệu] bên phải).
  * **Bẫy sự kiện bàn phím & chuột**: Bấm phím \`Escape\` hoặc click vùng đen ngoài để đóng; khi modal mở thì gắn **Class CSS** (\`body.modal-open\`) để khóa cuộn trang nền.
  * **Cơ chế thoát Stacking Context**: **Hàm DOM JavaScript** (\`document.body.appendChild(modal)\` - tự động chuyển thẻ Modal ra trực tiếp thẻ body để không bao giờ bị backdrop che khuất chặn click chuột).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Kích thước & Tỷ lệ chiều rộng**: **Thuộc tính CSS** (\`width\`):
    - Modal xác nhận xóa: Nhỏ gọn (\`width: 400px\`).
    - Modal sửa Email KPI (Screenshot-14): Chuẩn Enterprise (\`width: 580px\`).
    - Modal sửa Hồ sơ nhân sự (Screenshot-3): Rộng (\`width: 700px\`).
    - Modal thanh toán quét mã QR PayOS (Screenshot-2): Lớn (\`width: 800px - 900px\`).
  * **Nội dung nghiệp vụ trong Body**: Các thẻ HTML Form nhập liệu riêng biệt (Form Avatar, Form mail KPI, Form quét mã QR).
  * **Hành vi xử lý khi bấm nút [Lưu]**: **Tên Stored Procedure SQL** gọi thực thi:
    - Trang này: Gọi Stored Procedure \`sp_CRM_EmailKPIFollow\` để lưu theo dõi KPI.
    - Trang kia: Gọi Stored Procedure \`HR_StaffInformation_ForUserWeb\` để cập nhật hồ sơ nhân sự.
  * **Phản ứng sau khi đóng Modal**: **Hàm gọi lại JS (Callback Function)**:
    - Trang thì kích hoạt hàm (\`ReloadData()\` làm mới DataGrid).
    - Trang thì cập nhật lại ảnh đại diện góc phải màn hình (\`#profileImage_P\`).

---

### 7. Filter Toolbar / Search Panel / Filter Pills (Thanh bộ lọc & Tìm kiếm)
*Được sử dụng ở đầu bảng dữ liệu để người dùng tra cứu, phân loại bản ghi...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Cấu trúc Flexbox một hàng duy nhất**: Các **Thuộc tính CSS** (\`display: flex; align-items: center; gap: 8px; flex-wrap: nowrap; min-height: 42px\`).
  * **Bố cục 2 vế**: Vế trái gom cụm các bộ lọc điều kiện; Vế phải dùng **Thuộc tính CSS** (\`margin-left: auto\`) để đẩy ô tìm kiếm nhanh và nút tác vụ về sát mép phải.
  * **Ô tìm kiếm nhanh chuẩn**: Thẻ HTML icon kính lúp 🔍 bên trái, nút xóa từ khóa \`×\` bên phải, **Kỹ thuật lập trình JS** tự động tìm kiếm hoãn 300ms (Debounce).
  * **Nguyên tắc không ngắt dòng**: Chiều cao thanh công cụ chuẩn 42px, tuyệt đối không tạo các khối block \`width: 100%\` làm phình to thanh công cụ đẩy bảng xuống dưới.

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Các loại tiêu chí lọc nghiệp vụ**: Các thẻ HTML điều khiển:
    - Trang Lương (Screenshot-11): Thẻ \`<select>\` Tháng, Thẻ \`<select>\` Năm, Ô \`<input>\` tìm Họ tên.
    - Trang Công nợ (Screenshot-2): Thẻ \`<select>\` Trạng thái (Tất cả, Chưa trả, Đã trả).
    - Trang Lịch hẹn Demo (Screenshot-15): Bộ chọn Nhân viên, 2 ô chọn Ngày (\`Từ ngày ──► Đến ngày\`).
    - Trang Khách hàng (Screenshot-16, 18): Các thẻ Chip trạng thái (\`[Lead]\`, \`[Đã liên hệ]\`) kết hợp Thẻ Checkbox \`[Xem của tôi]\`.
  * **Cơ chế lọc dữ liệu**: **Hàm xử lý JavaScript**:
    - Trang ít dữ liệu: Hàm lọc trực tiếp trên mảng RAM trình duyệt (\`Array.prototype.filter()\`).
    - Trang nhiều dữ liệu: Hàm gửi AJAX request gọi lại Stored Procedure SQL Server với tham số lọc mới.

---

### 8. Buttons & Action Bar (Nút hành động & Thanh tác vụ)
*Được sử dụng cho các thao tác [Thêm], [Lưu], [Xóa], [Xuất Excel], [Làm mới]...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Phân cấp màu sắc theo Design System**: Các **Class CSS**:
    - **Nút chính**: **Class CSS** (\`.btn-primary\` - nền xanh lá \`#2E7D32\`, chữ trắng, dùng cho Lưu, Thêm mới).
    - **Nút cảnh báo**: **Class CSS** (\`.btn-danger\` - nền đỏ \`#E53935\`, chữ trắng, dùng cho Xóa, Hủy đơn).
    - **Nút phụ**: **Class CSS** (\`.btn-secondary\` - viền xám, nền trong suốt, dùng cho Đóng, Làm mới).
  * **Hiệu ứng vật lý khi tương tác**: Các **Thuộc tính CSS**:
    - Di chuột: (\`hover: translateY(-1px)\` - nhấc nhẹ nút lên 1px).
    - Bấm chuột: (\`active: scale(0.98)\` - co nhẹ nút lại).
  * **Cơ chế chống bấm đúp**: **Thuộc tính thẻ HTML** (\`disabled: true\`) kèm **Class CSS** (\`.spinner-border\` - hiện icon xoay xoay khi đang gửi dữ liệu lên server).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Nhãn hiển thị & Icon chức năng**: Các thẻ HTML chữ và icon (\`+ Thêm nhân sự\`, \`+ Tạo cuộc họp mới\`, \`💳 Thanh toán\`, \`📥 Xuất Excel\`).
  * **Kiểm tra phân quyền động**: Các **Thuộc tính cấu hình JS** (\`visible: false\`, \`disabled: true\`) dựa trên vai trò tài khoản đăng nhập (Nhân viên bị ẩn nút Duyệt lương, Sếp mới hiện).
  * **Nghiệp vụ thực thi khi click**: **Thuộc tính sự kiện HTML / JS** (\`onclick: function() { ... }\`):
    - Click nút [Lưu] ở trang này: Kích hoạt validate form và gọi Stored Procedure lưu KPI.
    - Click nút [Lưu] ở trang kia: Kiểm tra số dư tài khoản và kích hoạt tạo hóa đơn VAT.

---

`;

const updatedContent = content.substring(0, startIndex) + newSection10 + content.substring(endIndex);
fs.writeFileSync(targetFile, updatedContent, 'utf8');
console.log('Successfully enriched Câu 10 with explicit technical annotations in:', targetFile);
