const fs = require('fs');
const path = require('path');

const targetFile = path.resolve(__dirname, '../docs/HOI_DAP_KY_THUAT_VA_NGHIEP_VU_PARADISE_HRM.md');
let content = fs.readFileSync(targetFile, 'utf8');

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
> *"câu 10 ,ghi dạng bảng xong thì ghi dạng dòng luôn, ở dạng dòng thì sẽ giải thích chi tiết hơn (có ví dụ) cũng gồm 3 phần, tên component/control, phạm vi nội tại, phạm vi linh động"*

#### 💡 Giải đáp chi tiết:
Trong kiến trúc phần mềm hướng Component (Component-Driven Architecture) của Paradise HRM, ranh giới giữa **Nội tại (Intrinsic - Bất biến)** và **Linh động (Contextual - Biến thiên)** được phân định rõ ràng.

Để bạn và Sếp nắm trọn bức tranh, câu trả lời được trình bày theo 2 cấp độ:
1. **Cấp độ 1**: **BẢNG TỔNG HỢP SO SÁNH 8 COMPONENT** (Xem nhanh, đối chiếu tức thì).
2. **Cấp độ 2**: **GIẢI THÍCH CHI TIẾT DẠNG DÒNG TỪNG COMPONENT** (Đúng chuẩn 3 phần: Tên control $\\rightarrow$ Phạm vi nội tại $\\rightarrow$ Phạm vi linh động có ví dụ code thực tế đối chiếu giữa các màn hình).

---

### PHẦN I: BẢNG TỔNG HỢP SO SÁNH 8 COMPONENT (NỘI TẠI vs LINH ĐỘNG)

| STT | Tên Component / Control | Phạm vi NỘI TẠI (Bất biến ở mọi trang HTML gọi nó) | Phạm vi LINH ĐỘNG (Biến thiên tùy theo từng trang HTML gọi nó) |
| :---: | :--- | :--- | :--- |
| **1** | **DataGrid (\`dxDataGrid\` / dgv)** | • Bộ khung thẻ DOM gồm các **Class CSS** (\`.dx-datagrid\`, \`.dx-datagrid-headers\`, \`.dx-datagrid-rowsview\`, \`.dx-datagrid-table\`).<br>• **Thuộc tính cấu hình JS** phân trang (\`pageSize: 15, 30, 50\`, \`showInfo: true\`).<br>• **Thuộc tính cấu hình JS** kéo dãn cột (\`allowColumnResizing: true\`, \`columnResizingMode: "widget"\`).<br>• **Sự kiện (Event Hooks)** theo vòng đời: \`init\` $\\rightarrow$ \`onContentReady\` $\\rightarrow$ \`onRowClick\`.<br>• **Thuộc tính cấu hình JS** nhãn rỗng \`noDataText\` và icon spinner chờ tải. | • **Thuộc tính cấu hình JS** nguồn dữ liệu (\`dataSource\`): Trỏ đến Stored Procedure tương ứng (\`sp_gift_history_gift\`, \`sp_Debt_PaymentDebt\`).<br>• **Mảng thuộc tính JS** danh sách cột (\`columns: [...]\`): Số lượng cột, định dạng hiển thị (\`format: "#,##0"\`).<br>• **Thuộc tính CSS / JS** tỷ lệ độ rộng (\`width\`, \`minWidth\`): Chia đều 20% hay chia 18%-15%-10%.<br>• **Hàm gọi lại JS (\`cellTemplate\`)**: Tự vẽ lại ô cụ thể của cột đó (Vẽ Badge xanh/đỏ, nút thu tiền inline, hoặc chữ 2 dòng).<br>• **Hàm bắt sự kiện JS (\`onRowClick\`)**: Mở Modal thanh toán PayOS hay mở Modal sửa nhân viên. |
| **2** | **ComboBox / SelectBox** | • **Class CSS** popup danh sách thả xuống (\`.dx-dropdowneditor-overlay\`).<br>• **Thuộc tính cấu hình JS** bật ô tìm kiếm nhanh (\`searchEnabled: true\`, \`searchMode: "contains"\`).<br>• Phím điều hướng bàn phím \`↑\`/\`↓\` và phím \`Enter\`.<br>• **Class CSS** icon mũi tên xổ xuống (\`.dx-icon-spindown\`).<br>• **Sự kiện (Event Hooks)**: \`onValueChanged\`, \`onOpened\`, \`onClosed\`. | • **Thuộc tính cấu hình JS** nguồn danh mục (\`dataSource\`): Danh sách nạp từ bảng Nhân viên, Phòng ban hay Tỉnh/Thành.<br>• **Thuộc tính cấu hình JS** trường giá trị ngầm máy lưu (\`valueExpr: "ID"\` $\\rightarrow$ Lưu mã ngầm).<br>• **Thuộc tính cấu hình JS** trường in chữ cho người đọc (\`displayExpr\`: Trang KPI hiện Mã \`"ID"\` $\\rightarrow$ \`034\`, trang khác hiện Tên \`"Name"\` $\\rightarrow$ "Trần Khánh Ly").<br>• **Hàm gọi lại JS (\`itemTemplate\`)**: Tùy biến vẽ layout cho từng dòng trong danh sách xổ xuống (Ảnh avatar + Mã + Tên + Phòng ban).<br>• **Hàm bắt sự kiện JS (\`onValueChanged\` - Ripple Effect)**: Chọn nhân viên tự điền email vào ô bên cạnh; chọn Tỉnh tự lọc lại Huyện. |
| **3** | **TextBox / NumberBox / DateBox** | • **Thuộc tính CSS** theme nền xám (\`background: #2b3035\`), viền (\`border: 1px solid #495057\`).<br>• Bộ popup lịch tháng/năm tích hợp sẵn của \`dxDateBox\`.<br>• Bộ nút mũi tên tăng giảm số của \`dxNumberBox\`.<br>• **Thuộc tính cấu hình JS** bật nút xóa nhanh \`×\` (\`showClearButton: true\`).<br>• **Sự kiện (Event Hooks)**: \`onInput\`, \`onChange\`, \`onFocusIn\`, \`onFocusOut\`. | • **Thuộc tính cấu hình JS** định dạng tiền/số (\`format: "#,##0 VNĐ"\`) và mặt nạ nhập liệu (\`mask: "(0##) ###-####"\`).<br>• **Mảng cấu hình JS** quy tắc kiểm tra (\`validationRules: [RequiredRule, EmailRule]\`).<br>• **Thuộc tính cấu hình JS** khóa chỉ đọc (\`readOnly: true/false\`) hoặc **Thuộc tính thẻ HTML** (\`disabled\`).<br>• **Thuộc tính thẻ HTML / JS** chữ gợi ý mờ trong ô (\`placeholder: "Nhập họ tên..."\`). |
| **4** | **Card KPI / Metric Card** | • **Thuộc tính CSS** bo góc (\`border-radius: 12px\`), bóng đổ (\`box-shadow\`), viền mờ \`border\`.<br>• Phân tầng thị giác: Icon tròn $\\rightarrow$ Title nhỏ $\\rightarrow$ Value số to $\\rightarrow$ Trend badge.<br>• **Thuộc tính CSS** hiệu ứng hover nhấc nhẹ (\`transform: translateY(-2px)\`).<br>• **Class CSS** khung nhấp nháy chờ nạp số liệu (\`.skeleton-loading\`). | • **Thẻ HTML \`<i>\` & nhãn text**: Icon nghiệp vụ (💵, 📑, 🏋️) và tên chỉ số.<br>• **Hàm SQL Server** tính toán số liệu (\`SUM(DoanhThu)\`, \`COUNT(NhanVien)\`).<br>• **Mã màu CSS** theo tính chất: Tích cực xanh lá (\`#2E7D32\`), cảnh báo đỏ (\`#E53935\`), chờ xử lý vàng (\`#FBC02D\`).<br>• **Hàm bắt sự kiện JS (\`onclick\`)**: Bấm card tự động lọc DataGrid bên dưới (Drill-down). |
| **5** | **Card / Panel / Container** | • Các **Class CSS** phân chia cấu trúc vùng (\`.card-header\`, \`.card-body\`, \`.card-footer\`).<br>• **Thuộc tính CSS** đường kẻ ngăn cách (\`border-bottom\`), khoảng cách đệm (\`padding: 16px - 24px\`). | • **Thuộc tính CSS** cơ chế co giãn: Form dùng \`height: auto\`, Bảng dùng Flexbox tràn viền 100% (\`flex: 1 1 auto; height: 100%\`).<br>• **Các thẻ HTML/DOM nhúng bên trong**: Chứa Form 2 cột, chứa TabStrip 10 tabs, hay chứa DataGrid.<br>• **Nhóm nút công cụ HTML trên Header**: Nút [Xuất Excel], [In biểu mẫu] hoặc [Ẩn/Hiện filter]. |
| **6** | **Modal / Popup / Dialog** | • **Thuộc tính CSS** lớp nền tối overlay (\`position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,0.7)\`).<br>• Cấu trúc 3 tầng: Modal Header (nút \`×\`) $\\rightarrow$ Modal Body (cuộn dọc \`overflow-y: auto\`) $\rightarrow$ Modal Footer (nút [Đóng] và [Lưu]).<br>• Bẫy phím bàn phím \`Escape\` và **Class CSS** khóa cuộn trang (\`body.modal-open\`).<br>• **Hàm DOM JavaScript** thoát Stacking Context: \`document.body.appendChild(modal)\`. | • **Thuộc tính CSS** độ rộng: Modal xác nhận nhỏ 400px; Modal KPI chuẩn 580px; Modal QR PayOS rộng 800px - 900px.<br>• **Các thẻ Form HTML nhúng trong Body**: Nơi chứa đổi Avatar, nơi chứa form mail KPI, nơi chứa mã QR.<br>• **Tên Stored Procedure SQL** gọi thực thi khi bấm [Lưu]: \`sp_CRM_EmailKPIFollow\`, \`HR_StaffInformation_Save\`.<br>• **Hàm gọi lại JS sau khi đóng**: Tự gọi \`ReloadData()\` làm mới DataGrid hoặc cập nhật lại avatar header. |
| **7** | **Filter Toolbar / Search Panel** | • **Thuộc tính CSS** Flexbox 1 hàng phẳng chuẩn 42px (\`display: flex; gap: 8px; flex-wrap: nowrap; min-height: 42px\`).<br>• Phân chia 2 vế: Vế trái là bộ lọc, Vế phải dùng **Thuộc tính CSS** \`margin-left: auto\` để đẩy Search box về sát lề phải.<br>• **Kỹ thuật lập trình JS** tự động tìm kiếm hoãn 300ms (Debounce). | • **Các thẻ HTML Form điều khiển**: Thẻ \`<select>\` Tháng/Năm, Thẻ \`<input>\` tìm kiếm, Checkbox \`[Xem của tôi]\`, Các thẻ chip trạng thái \`[Lead]\`, \`[Đã liên hệ]\`.<br>• **Hàm JavaScript xử lý lọc**: Lọc trực tiếp trên mảng RAM trình duyệt hay gửi AJAX gọi lại Stored Procedure. |
| **8** | **Button / Action Bar** | • Các **Class CSS** phân cấp màu Design System: \`.btn-primary\` (Xanh \`#2E7D32\`), \`.btn-danger\` (Đỏ \`#E53935\`), \`.btn-secondary\` (Xám).<br>• **Thuộc tính CSS** hiệu ứng vật lý: \`hover: translateY(-1px)\`, \`active: scale(0.98)\`.<br>• **Thuộc tính thẻ HTML** khóa chống click đúp (\`disabled\`) kèm **Class CSS** con quay xoay (\`.spinner-border\`). | • **Thuộc tính thẻ HTML** nhãn chữ & icon: \`+ Thêm nhân sự\`, \`+ Tạo cuộc họp\`, \`💳 Thanh toán\`.<br>• **Thuộc tính cấu hình JS kiểm tra phân quyền**: Khóa hoặc ẩn nút (\`visible: false\`, \`disabled: true\`) theo quyền tài khoản.<br>• **Hàm bắt sự kiện JS (\`onclick\`)**: Validate dữ liệu và gọi API lưu tương ứng của từng phân hệ. |

---

### PHẦN II: GIẢI THÍCH CHI TIẾT DẠNG DÒNG CHO TỪNG COMPONENT (CÓ VÍ DỤ MINH HỌA)

---

### 1. DataGrid (\`dxDataGrid\` / dgv - Lưới dữ liệu bảng biểu)
*Được sử dụng tại hầu hết các màn hình danh sách (Quà tặng, Công nợ, Danh sách công ty, Hợp đồng lao động, Thiết bị...)*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Cấu trúc khung DOM chuẩn**: Thư viện DevExtreme (\`dxDataGrid\`) luôn sinh ra cùng một bộ khung thẻ HTML gồm các **Class CSS**: \`.dx-datagrid\` (bao ngoài), \`.dx-datagrid-headers\` (hàng tiêu đề), \`.dx-datagrid-rowsview\` (vùng chứa các dòng dữ liệu), \`.dx-datagrid-table\` (thẻ \`<table>\` thực tế).
  * **Bộ máy phân trang**: Các **Thuộc tính cấu hình JS** (\`pageSize: 15, 30, 50\` - số dòng hiển thị mỗi trang), (\`showInfo: true\` - hiển thị tổng số dòng), thuật toán tính số trang và nút chuyển trang \`Prev / Next\`.
  * **Cơ chế sắp xếp & Lọc cơ bản**: Nhấp vào header cột để đổi chiều tăng/giảm (Asc/Desc), cơ chế lọc theo dòng (**Thuộc tính cấu hình JS** \`filterRow: { visible: true }\`).
  * **Bộ máy kéo dãn cột**: Các **Thuộc tính cấu hình JS** (\`allowColumnResizing: true\` - cho phép dùng chuột kéo dãn cột), (\`columnResizingMode: "widget"\` - co giãn các cột lân cận).
  * **Vòng đời sự kiện (Lifecycle)**: Các **Sự kiện (Event Hooks)** chạy theo thứ tự bất biến: (\`onInitialized\` - khi widget bắt đầu khởi tạo) $\\rightarrow$ (\`onContentReady\` - khi đã vẽ xong bảng lên màn hình) $\\rightarrow$ (\`onRowClick\` - khi click chuột vào dòng) $\\rightarrow$ (\`onCellPrepared\` - trước khi vẽ từng ô).
  * **Trạng thái rỗng & Chờ dữ liệu**: Con quay spinner mặc định khi đang tải và **Thuộc tính cấu hình JS** (\`noDataText: "Không có dữ liệu"\`).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Nguồn dữ liệu nghiệp vụ**: **Thuộc tính cấu hình JS** (\`dataSource\` - trỏ đến Stored Procedure khác nhau tùy phân hệ).
  * **Danh sách cột & Tiêu đề**: **Mảng thuộc tính cấu hình JS** (\`columns: [...]\`):
    - Tên trường CSDL: **Thuộc tính cấu hình cột** (\`dataField: "CustomerName"\`, \`dataField: "Point"\`).
    - Tiêu đề đa ngôn ngữ: **Thuộc tính cấu hình cột** (\`caption: "%Keyword%"\` - dịch tự động từ CSDL).
    - Căn lề: **Thuộc tính cấu hình cột** (\`alignment: "left"\`, \`"center"\`, \`"right"\`).
    - Định dạng số/ngày: **Thuộc tính cấu hình cột** (\`format: "#,##0 VNĐ"\`, \`format: "dd/MM/yyyy"\`).
  * **Tỷ lệ độ rộng & Quy tắc chia cột**: Các **Thuộc tính cấu hình cột** (\`width: "20%"\`, \`minWidth: 140\` - pixel hoặc tỷ lệ %).
  * **Hàm vẽ giao diện riêng cho từng ô của 1 cột cụ thể**: **Hàm gọi lại JS (Callback Function)** (\`cellTemplate: function(container, options) { ... }\`):
    - Khai báo nằm lọt trong dấu ngoặc \`{ ... }\` của cột nào thì chỉ áp dụng để vẽ lại các ô (\`Cells\`) của riêng cột đó trên mọi dòng.
  * **Tác vụ khi bấm vào dòng**: **Hàm bắt sự kiện JS (Event Hook)** (\`onRowClick\` / \`onCellClick\`).

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Quà tặng - Screenshot-01)**:
    \`\`\`javascript
    // 5 cột chia đều 20% mỗi cột, không dùng cellTemplate:
    columns: [
        { dataField: "GiftName", caption: "%GiftName%", width: "20%", minWidth: 140, alignment: "left" },
        { dataField: "Point", caption: "%Point%", width: "20%", minWidth: 120, alignment: "right" },
        { dataField: "Status", caption: "%Status%", width: "20%", minWidth: 120, alignment: "center" },
        { dataField: "CreatedDate", caption: "%CreatedDate%", width: "20%", minWidth: 140, alignment: "center" },
        { dataField: "Receiver", caption: "%Receiver%", width: "20%", minWidth: 140, alignment: "left" }
    ]
    \`\`\`
  * **Ví dụ B (Trang Công nợ - Screenshot-02)**:
    \`\`\`javascript
    // 8 cột chia tỷ lệ lệch, DÙNG cellTemplate để vẽ 2 dòng chữ và nút thu tiền inline:
    columns: [
        {
            caption: "Khách hàng",
            width: "18%",
            cellTemplate: function(container, options) {
                // Vẽ 2 dòng trong 1 ô Khách hàng:
                $("<div>").addClass("fw-bold").text(options.data.CustomerName).appendTo(container);
                $("<div>").addClass("small opacity-75").text(options.data.CustomerCode).appendTo(container);
            }
        },
        {
            caption: "Thao tác",
            width: "10%",
            cellTemplate: function(container, options) {
                // Vẽ nút bấm thu tiền inline trong ô Thao tác:
                $("<button class='btn btn-sm btn-success'>").text("Thu tiền").appendTo(container);
            }
        }
    ]
    \`\`\`

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
    - **Thuộc tính cấu hình JS** (\`valueExpr\` - **Giá trị ngầm máy lưu**): Chỉ định trường nào sẽ gửi về CSDL khi bấm Lưu (thường là Mã/ID ngầm).
    - **Thuộc tính cấu hình JS** (\`displayExpr\` - **Chữ người xem trên màn hình**): Chỉ định trường nào in ra chữ cho người đọc khi ô đang đóng.
  * **Giao diện dòng item trong danh sách xổ xuống**: **Hàm gọi lại JS (Callback Function)** (\`itemTemplate: function(data) { ... }\`): Tùy biến vẽ layout cho từng dòng khi người dùng bấm mũi tên mở menu thả xuống.
  * **Hiệu ứng lan tỏa khi chọn (Ripple Effect)**: **Hàm bắt sự kiện JS (Event Hook)** (\`onValueChanged: function(e) { ... }\`).

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Email KPI - Screenshot-14: Ô "Mã nhân viên")**:
    \`\`\`javascript
    // Bắt buộc cấu hình displayExpr: "ID" để hiện mã 034 thay vì hiện tên người:
    $("#cboEmployee").dxSelectBox({
        dataSource: listNhanVien,
        valueExpr: "ID",        // Máy lưu ngầm mã "034"
        displayExpr: "ID",      // Người nhìn thấy chữ "034" trên ô đóng
        itemTemplate: function(data) {
            // Khi bấm xổ xuống: Hiện cả Mã và Tên để người dùng dễ chọn
            return $("<div>").text(data.ID + " - " + data.Name);
        },
        onValueChanged: function(e) {
            // Ripple Effect: Tự động điền Họ tên và Email vào 2 ô bên cạnh
            $("#txtFullName").val(e.component.option("selectedItem").Name);
            $("#txtEmail").val(e.component.option("selectedItem").Email);
        }
    });
    \`\`\`
  * **Ví dụ B (Trang Hồ sơ cá nhân - Screenshot-03: Chọn Tỉnh/Thành)**:
    \`\`\`javascript
    // Hiển thị tên Tỉnh và tự động kích hoạt lọc Quận/Huyện con:
    $("#cboProvince").dxSelectBox({
        dataSource: listTinhThanh,
        valueExpr: "ProvinceID",
        displayExpr: "ProvinceName", // Người nhìn thấy "TP. Hồ Chí Minh"
        onValueChanged: function(e) {
            // Cascading Dropdown: Nạp lại danh sách Quận/Huyện theo Tỉnh vừa chọn
            loadDistrictsByProvince(e.value);
        }
    });
    \`\`\`

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
  * **Định dạng & Mặt nạ nhập liệu**: **Thuộc tính cấu hình JS** (\`format\`, \`mask\`).
  * **Quy tắc kiểm tra tính hợp lệ**: **Mảng các quy tắc cấu hình JS** (\`validationRules: [...] \`).
  * **Trạng thái phân quyền thao tác**: **Thuộc tính cấu hình JS** (\`readOnly: true/false\`), **Thuộc tính thẻ HTML** (\`disabled\`).
  * **Gợi ý hiển thị**: **Thuộc tính thẻ HTML / JS** (\`placeholder\`).

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Công nợ - Nhập số tiền thu)**:
    \`\`\`javascript
    $("#txtAmount").dxNumberBox({
        format: "#,##0 VNĐ",           // Tự động thêm dấu phẩy ngàn
        min: 1000,
        placeholder: "Nhập số tiền...",
        validationRules: [{ type: "required", message: "Số tiền không được để trống" }]
    });
    \`\`\`
  * **Ví dụ B (Trang Xin tăng ca - Screenshot-04: Chọn ngày & giờ)**:
    \`\`\`javascript
    $("#qlrl-dxOTFromDate").dxDateBox({
        type: "date",
        displayFormat: "dd/MM/yyyy",   // Định dạng ngày Việt Nam
        value: new Date()
    });
    \`\`\`

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
  * **Ý nghĩa chỉ số nghiệp vụ & Icon minh họa**: Thẻ HTML icon và nhãn text.
  * **Nguồn dữ liệu & Công thức tính toán**: Hàm SQL Server (\`SUM\`, \`COUNT\`).
  * **Màu sắc nhấn nhận diện**: Mã màu CSS (Xanh / Đỏ / Vàng).
  * **Hành vi tương tác khi bấm vào thẻ**: Hàm bắt sự kiện JS (\`onclick\` - Drill-down).

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Chi tiết khách hàng CRM 360°)**:
    \`\`\`html
    <!-- Thẻ KPI Tổng Công Nợ (Cảnh báo màu đỏ, tính SUM, bấm vào lọc đơn nợ) -->
    <div class="kpi-card card-danger" onclick="filterGridByDebtStatus('unpaid')">
        <div class="kpi-icon"><i class="bi bi-exclamation-triangle"></i></div>
        <div class="kpi-content">
            <span class="kpi-label">Tổng công nợ</span>
            <h3 class="kpi-value">45,000,000 đ</h3>
            <span class="badge bg-danger">Còn 3 đợt chưa thu</span>
        </div>
    </div>
    \`\`\`
  * **Ví dụ B (Trang Quản lý Gym)**:
    \`\`\`html
    <!-- Thẻ KPI Hội Viên Check-in (Tích cực màu xanh, tính COUNT) -->
    <div class="kpi-card card-success">
        <div class="kpi-icon"><i class="bi bi-person-check"></i></div>
        <div class="kpi-content">
            <span class="kpi-label">Đang trong phòng tập</span>
            <h3 class="kpi-value">128 hội viên</h3>
        </div>
    </div>
    \`\`\`

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
  * **Kích thước & Cơ chế co giãn**: Các **Thuộc tính CSS** (\`height: auto\` hay \`flex: 1 1 auto; height: 100%\`).
  * **Nội dung nhúng bên trong Body**: Chứa Form 2 cột, chứa TabStrip 10 tabs, hay chứa DataGrid.
  * **Nút bấm công cụ trên Header**: Nút [Xuất Excel], [In biểu mẫu] hoặc [Ẩn/Hiện filter].

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Tạo mật khẩu - Screenshot-05: Card Form căn giữa)**:
    \`\`\`css
    /* Form đơn lẻ -> Dùng chiều cao auto, độ rộng 500px, căn giữa màn hình */
    .password-card-container {
        max-width: 500px;
        margin: 40px auto;
        height: auto;
    }
    \`\`\`
  * **Ví dụ B (Trang Thanh toán công nợ - Screenshot-02: Card Grid tràn viền)**:
    \`\`\`css
    /* Bảng dữ liệu lớn -> Dùng Flexbox tràn viền 100% toàn màn hình */
    .payment-debt-container {
        flex: 1 1 auto !important;
        display: flex !important;
        flex-direction: column !important;
        width: 100% !important;
        height: 100% !important;
    }
    \`\`\`

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
  * **Kích thước & Tỷ lệ chiều rộng**: **Thuộc tính CSS** (\`width: 400px\`, \`580px\`, \`800px\`).
  * **Nội dung nghiệp vụ trong Body**: Form nhập Avatar, Form cấu hình mail KPI, hay Iframe cổng PayOS.
  * **Hành vi xử lý khi bấm nút [Lưu]**: Tên Stored Procedure SQL gọi thực thi.
  * **Phản ứng sau khi đóng Modal**: Hàm gọi lại JS làm mới bảng hoặc cập nhật avatar.

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Email KPI - Screenshot-14: Modal Sửa 580px)**:
    \`\`\`javascript
    // Kích thước chuẩn 580px, đưa ra body để thoát backdrop chặn click:
    if (emailModal.parentElement !== document.body) {
        document.body.appendChild(emailModal);
    }
    $(".modal-backdrop").remove();
    $("#emailModal .modal-content").css("max-width", "580px");
    \`\`\`
  * **Ví dụ B (Trang Công nợ - Screenshot-02: Modal Quét mã QR PayOS 800px)**:
    \`\`\`javascript
    // Kích thước lớn 800px để nhúng iframe thanh toán ngân hàng trực tuyến:
    $("#dp_modal_detail .modal-content").css({
        "max-width": "800px",
        "min-height": "600px"
    });
    \`\`\`

---

### 7. Filter Toolbar / Search Panel / Filter Pills (Thanh bộ lọc & Tìm kiếm)
*Được sử dụng ở đầu bảng dữ liệu để người dùng tra cứu, phân loại bản ghi...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Cấu trúc Flexbox một hàng duy nhất**: Các **Thuộc tính CSS** (\`display: flex; align-items: center; gap: 8px; flex-wrap: nowrap; min-height: 42px\`).
  * **Bố cục 2 vế**: Vế trái gom cụm các bộ lọc điều kiện; Vế phải dùng **Thuộc tính CSS** (\`margin-left: auto\`) để đẩy ô tìm kiếm nhanh và nút tác vụ về sát mép phải.
  * **Ô tìm kiếm nhanh chuẩn**: Thẻ HTML icon kính lúp 🔍 bên trái, nút xóa từ khóa \`×\` bên phải, **Kỹ thuật lập trình JS** tự động tìm kiếm hoãn 300ms (Debounce).
  * **Nguyên tắc không ngắt dòng**: Chiều cao thanh công cụ chuẩn 42px, tuyệt đối không tạo các khối block \`width: 100%\` làm phình to thanh công cụ đẩy bảng xuống dưới.

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Các loại tiêu chí lọc nghiệp vụ**: Các thẻ HTML điều khiển tùy theo yêu cầu của từng trang.
  * **Cơ chế lọc dữ liệu**: Hàm lọc trực tiếp trên mảng RAM trình duyệt hay gửi request AJAX lên SQL Server.

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Nhập lương Trí Luật - Screenshot-11)**:
    \`\`\`html
    <!-- Toolbar 1 hàng duy nhất gồm: Bộ lọc Tháng + Năm + Ô tìm Họ tên: -->
    <div class="salary-filter-toolbar">
        <select id="filter_month" class="form-select"><option>Tháng 10</option></select>
        <select id="filter_year" class="form-select"><option>2026</option></select>
        <input id="search_fullname" class="form-control" placeholder="Tìm theo họ tên...">
        <button class="btn btn-primary ms-auto"><i class="bi bi-file-earmark-excel"></i> Xuất Excel</button>
    </div>
    \`\`\`
  * **Ví dụ B (Trang Dữ liệu khách hàng KPI - Screenshot-18)**:
    \`\`\`html
    <!-- Toolbar 1 hàng gồm: Chip lọc trạng thái + Checkbox [Xem của tôi] + Nút Phễu lọc: -->
    <div class="kpi-toolbar-row">
        <div class="chip-group">
            <span class="chip active">Tất cả (1,250)</span>
            <span class="chip">Lead (420)</span>
            <span class="chip">Đã liên hệ (310)</span>
        </div>
        <div class="form-check ms-3">
            <input type="checkbox" id="chkMyData" class="form-check-input">
            <label class="form-check-label" for="chkMyData">Xem của tôi</label>
        </div>
        <button class="btn btn-outline-secondary ms-auto btn-funnel-filter"><i class="bi bi-funnel"></i></button>
    </div>
    \`\`\`

---

### 8. Buttons & Action Bar (Nút hành động & Thanh tác vụ)
*Được sử dụng cho các thao tác [Thêm], [Lưu], [Xóa], [Xuất Excel], [Làm mới]...*

* **Phạm vi nội tại (Intrinsic - Bất biến ở mọi trang HTML)**:
  * **Phân cấp màu sắc theo Design System**: Các **Class CSS**:
    - **Nút chính**: **Class CSS** (\`.btn-primary\` - nền xanh lá \`#2E7D32\`, chữ trắng, dùng cho Lưu, Thêm mới).
    - **Nút cảnh báo**: **Class CSS** (\`.btn-danger\` - nền đỏ \`#E53935\`, chữ trắng, dùng cho Xóa, Hủy đơn).
    - **Nút phụ**: **Class CSS** (\`.btn-secondary\` - viền xám, nền trong suốt, dùng cho Đóng, Làm mới).
  * **Hiệu ứng vật lý khi tương tác**: Các **Thuộc tính CSS** di chuột (\`hover: translateY(-1px)\`), bấm giữ (\`active: scale(0.98)\`).
  * **Cơ chế chống bấm đúp**: **Thuộc tính thẻ HTML** (\`disabled: true\`) kèm **Class CSS** (\`.spinner-border\` - hiện icon xoay xoay khi đang gửi dữ liệu lên server).

* **Phạm vi linh động (Contextual - Thay đổi tùy theo trang gọi)**:
  * **Nhãn hiển thị & Icon chức năng**: Các thẻ HTML chữ và icon.
  * **Kiểm tra phân quyền động**: Các **Thuộc tính cấu hình JS** (\`visible: false\`, \`disabled: true\`) dựa trên vai trò tài khoản đăng nhập.
  * **Nghiệp vụ thực thi khi click**: **Thuộc tính sự kiện HTML / JS** (\`onclick: function() { ... }\`).

* 🌟 **VÍ DỤ ĐỐI CHIẾU THỰC TẾ TRONG DỰ ÁN**:
  * **Ví dụ A (Trang Họp demo KPI - Screenshot-15: Nút Tạo cuộc họp mới)**:
    \`\`\`html
    <!-- Nút Primary đưa lên ngang hàng cạnh ô tìm kiếm, click mở Modal -->
    <button class="btn btn-primary btn-new-meeting" onclick="openNewMeetingModal()">
        <i class="bi bi-plus-lg"></i> Tạo cuộc họp mới
    </button>
    \`\`\`
  * **Ví dụ B (Trang Bảng lương - Phân quyền nút Duyệt lương)**:
    \`\`\`javascript
    // Nếu là tài khoản Nhân viên thường -> Ẩn hoàn toàn nút Duyệt lương:
    if (currentUserRole !== "Admin" && currentUserRole !== "ChiefAccountant") {
        $("#btnApproveSalary").hide(); // Ẩn khỏi màn hình
    } else {
        $("#btnApproveSalary").show(); // Sếp mới nhìn thấy để bấm duyệt
    }
    \`\`\`

---
`;

const updatedContent = content.substring(0, startIndex) + newSection10 + content.substring(endIndex);
fs.writeFileSync(targetFile, updatedContent, 'utf8');
console.log('Successfully written both Table and Line Breakdown with Examples to:', targetFile);
