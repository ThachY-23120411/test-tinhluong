<span id="muc-luc"></span>

# CẨM NANG TOÀN TẬP TRA CỨU LỆNH JQUERY & DEVEXTREME
### Dự án: Paradise HRM (Kiến trúc SPA + Stored Procedure + DevExtreme)

---

## 📑 MỤC LỤC TRA CỨU NHANH
*(Bấm vào bất kỳ dòng nào bên dưới để nhảy ngay tới lệnh đó. Ở mỗi lệnh đều có nút **[↩ Quay lại Mục lục](#muc-luc)** để quay về đây trong 1 click).*

### [A. NGUYÊN TẮC CỐT LÕI: PHÂN BIỆT JQUERY VS DEVEXTREME](#phan-a-nguyen-tac)

---

### B. PHẦN 1: TOÀN BỘ CÁC LỆNH JQUERY THUẦN TÚY (DOM, CSS & SỰ KIỆN)
1. [`$(function() { ... })` — Khởi động an toàn (Document Ready)](#cmd-ready)
2. [`$('<tag>')` — Tạo thẻ HTML mới trong bộ nhớ RAM](#cmd-create-tag)
3. [`.append()` / `.prepend()` — Gắn thẻ con vào cuối / đầu thẻ cha](#cmd-append)
4. [`.remove()` / `.empty()` — Xóa sổ thẻ khỏi màn hình / Dọn sạch ruột](#cmd-remove)
5. [`.attr()` / `.removeAttr()` — Đọc, sửa, xóa thuộc tính HTML (`src`, `href`, `data-*`)](#cmd-attr)
6. [`.prop()` — Can thiệp trạng thái logic Boolean (`checked`, `disabled`, `selected`)](#cmd-prop)
7. [`.val()` — Đọc và gán giá trị ô nhập liệu form (`<input>`, `<select>`, `<textarea>`)](#cmd-val)
8. [`.text()` — Đọc và thay thế chữ thuần túy (không kèm mã HTML)](#cmd-text)
9. [`.html()` — Đọc và ghi đè toàn bộ cấu trúc mã HTML bên trong](#cmd-html)
10. [`.css()` — Can thiệp trực tiếp thuộc tính style CSS (inline style)](#cmd-css)
11. [`.addClass()` / `.removeClass()` / `.toggleClass()` — Quản lý Class CSS](#cmd-classes)
12. [`.show()` / `.hide()` / `.toggle()` — Bật / tắt hiển thị phần tử (`display: block / none`)](#cmd-show-hide)
13. [`.find()` — Tìm kiếm thẻ con, cháu nằm sâu bên trong](#cmd-find)
14. [`.closest()` — Leo ngược cây DOM tìm thẻ cha / tổ tiên gần nhất](#cmd-closest)
15. [`$(selector).on('click', fn)` — Lắng nghe sự kiện click trực tiếp (thẻ có sẵn)](#cmd-on-click)
16. [`$(document).on('click', '.child', fn)` — Bắt sự kiện ủy quyền (Event Delegation cho thẻ sinh động)](#cmd-delegation)
17. [`$.ajax()` — Bắn request ngầm gọi API Backend C# không tải lại trang](#cmd-ajax)

---

### C. PHẦN 2: TOÀN BỘ CÁC LỆNH DEVEXTREME (UI WIDGETS & INSTANCES)
1. [`dxDataGrid` — Bảng dữ liệu lưới cao cấp](#dx-datagrid)
2. [`dxSelectBox` — Dropdown chọn 1 giá trị kèm thanh tìm kiếm](#dx-selectbox)
3. [`dxDateBox` — Ô chọn ngày, tháng, năm, giờ có lịch popup](#dx-datebox)
4. [`dxTextBox` / `dxNumberBox` / `dxTextArea` — Bộ ô nhập liệu chuẩn DevExtreme](#dx-inputs)
5. [`dxPopup` — Cửa sổ Modal nổi (Dialog)](#dx-popup)
6. [`dxFileUploader` — Widget tải lên tài liệu / ảnh đại diện](#dx-fileuploader)
7. [`dxButton` / `dxDropDownButton` — Nút bấm và Nút có menu xổ xuống](#dx-buttons)
8. [`dxValidator` — Bộ kiểm tra hợp lệ dữ liệu form](#dx-validator)
9. [Cách lấy Instance của Widget DevExtreme](#dx-instance)
10. [`.option('key', value)` / `.option('key')` — Đọc hoặc thay đổi thuộc tính Widget khi đang chạy](#dx-option)
11. [`.refresh()` — Tải lại dữ liệu cho bảng DataGrid](#dx-refresh)
12. [`.getSelectedRowsData()` / `.clearSelection()` — Lấy dòng được tick chọn / Bỏ chọn toàn bộ](#dx-selection)
13. [`.show()` / `.hide()` (trên Instance Popup) — Bật mở / Đóng cửa sổ Modal](#dx-show-hide-popup)
14. [`.repaint()` — Ép vẽ lại hình học khi giao diện bị méo / co cụm layout](#dx-repaint)
15. [`DevExpress.ui.notify()` — Bật thông báo Toast góc màn hình](#dx-notify)
16. [`DevExpress.ui.dialog.confirm()` — Hộp thoại hỏi xác nhận Có / Không](#dx-confirm)
17. [`DevExpress.excelExporter.exportDataGrid()` — Xuất trực tiếp bảng dữ liệu ra Excel](#dx-export)

---

### [D. PHẦN 3: BẢNG SO SÁNH ĐỐI ỨNG KHI NÀO DÙNG GÌ?](#phan-d-bang-doi-ung)

---

### [E. PHẦN 4: GIẢI MÃ CHI TIẾT TỪNG DÒNG CODE MẪU THỰC TẾ TRONG DỰ ÁN](#phan-e-giai-ma-code)

---

<span id="phan-a-nguyen-tac"></span>
## 🧭 A. NGUYÊN TẮC CỐT LÕI: PHÂN BIỆT JQUERY VS DEVEXTREME

| Tiêu chí | jQuery thuần túy | DevExtreme |
| :--- | :--- | :--- |
| **Bản chất** | Thư viện thao tác trực tiếp trên cây **HTML DOM chuẩn** của trình duyệt. | Bộ linh kiện **UI Component cao cấp** (xây dựng bằng JavaScript bọc ngoài HTML). |
| **Thẻ HTML đại diện** | `<button>`, `<div>`, `<input>`, `<span>`, `<table>`, `<tr>`... | Các widget phức hợp tự sinh ra hàng chục thẻ con lồng nhau (`dx-datagrid`, `dx-selectbox`...). |
| **Dấu hiệu nhận biết trong code** | Bắt đầu bằng `$(`...`)` rồi gọi các hàm `.append()`, `.css()`, `.prop()`, `.val()`, `.find()`. | Khởi tạo qua `.dxTênWidget({...})` hoặc gọi qua biến `InstanceXYZ.option(...)`, `.refresh()`. |
| **Nguy cơ lỗi nghiêm trọng** | Dùng nhầm lệnh jQuery (`.val()`, `.html()`) can thiệp thô bạo vào ruột widget DevExtreme sẽ làm **mất đồng bộ dữ liệu ngầm**, widget ngừng hoạt động. |

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="b-phan-1-jquery-thuan-tuy"></span>
# B. PHẦN 1: TOÀN BỘ CÁC LỆNH JQUERY THUẦN TÚY (DOM, CSS & SỰ KIỆN)

---

<span id="cmd-ready"></span>
### 1. `$(function() { ... })` — Khởi động an toàn (Document Ready)

* **Bản chất**: Trình duyệt nạp mã HTML từ trên xuống dưới. Nếu JavaScript chạy trước khi thẻ HTML kịp xuất hiện, code sẽ tìm không thấy thẻ (`undefined`) và bị lỗi. Lệnh này báo cho trình duyệt: *"Hãy dựng xong toàn bộ khung xương HTML rồi mới chạy đoạn code bên trong tôi"*.
* **Cú pháp**:
  ```javascript
  $(function() {
      // Toàn bộ mã khởi tạo giao diện viết ở đây
  });
  ```
* **Khi nào dùng**: Luôn luôn là khối bao bọc ngoài cùng của các đoạn script khởi tạo trang trong Stored Procedure (`sp_..._html`).
* **Ví dụ thực tế trong dự án**:
  ```javascript
  $(function() {
      console.log('Trang web đã dựng xong DOM, bắt đầu khởi tạo lưới dữ liệu!');
      $('#myGrid').dxDataGrid({ ... });
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-create-tag"></span>
### 2. `$('<tag>')` — Tạo thẻ HTML mới trong bộ nhớ RAM

* **Bản chất**: Cho phép lập trình viên tự chế ra một hoặc nhiều thẻ HTML mới hoàn toàn bằng JavaScript ngay trong bộ nhớ tạm thời mà chưa cần gắn lên màn hình.
* **Cú pháp**: `const $bien = $('<tên_thẻ thuộc_tính="giá_trị">Nội dung</tên_thẻ>');`
* **Khi nào dùng**: Khi cần sinh động nút bấm, hàng lọc, chân trang footer tùy theo quyền của user hoặc dữ liệu trả về từ server.
* **Minh họa quá trình**:
  ```javascript
  // Lúc này thẻ chưa xuất hiện trên màn hình, chỉ nằm trong biến $btn
  const $btn = $('<button class="btn-dong" style="color:red;">Đóng lại</button>');
  ```
* **Ứng dụng thực tế trong Paradise HRM**:
  ```javascript
  // Tạo khung footer chứa 2 nút bấm động cho bộ lọc
  const $footer = $('<div style="display:flex; justify-content:space-between; border-top:0.5px solid #eee; padding-top:12px;"></div>');
  const $applyBtn = $('<button class="btn btn-primary">✓ Áp dụng</button>');
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-append"></span>
### 3. `.append()` / `.prepend()` — Gắn thẻ con vào cuối / đầu thẻ cha

* **Bản chất**: Sau khi đã tạo ra thẻ HTML bằng `$('<tag>')`, bạn phải dùng lệnh này để "dán" nó vào bên trong một thẻ cha đang có sẵn trên màn hình để người dùng nhìn thấy.
  * `.append()`: Dán vào **sau cùng** (dưới đáy thẻ cha).
  * `.prepend()`: Dán vào **đầu tiên** (trên đỉnh thẻ cha).
* **Cú pháp**: `$(thẻ_cha).append(thẻ_con_1, thẻ_con_2);`

#### Minh họa trực quan:
* **HTML ban đầu**:
  ```html
  <div id="footer">
      <span>Đang có 1 mục</span>
  </div>
  ```
* **Chạy lệnh jQuery**:
  ```javascript
  const $btn = $('<button>Lưu</button>');
  $('#footer').append($btn);
  ```
* **HTML biến đổi sau khi chạy**:
  ```html
  <div id="footer">
      <span>Đang có 1 mục</span>
      <button>Lưu</button> <!-- Thẻ mới được nhét vào cuối -->
  </div>
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-remove"></span>
### 4. `.remove()` / `.empty()` — Xóa sổ thẻ khỏi màn hình / Dọn sạch ruột

* **Bản chất**:
  * `.remove()`: Bứng tận gốc cả thẻ cha lẫn toàn bộ thẻ con bên trong vứt đi.
  * `.empty()`: Giữ lại cái vỏ thẻ cha, chỉ dọn sạch toàn bộ ruột bên trong cho trống rỗng.
* **Cú pháp**:
  ```javascript
  $('#thẻ_can_xoa').remove();
  $('#thẻ_can_don_ruot').empty();
  ```

#### Minh họa trực quan:
* **HTML ban đầu**:
  ```html
  <div id="hopThongBao">
      <p>Lỗi kết nối máy chủ!</p>
  </div>
  ```
* **Nếu chạy `$('#hopThongBao').empty();`**:
  ```html
  <div id="hopThongBao"></div> <!-- Thẻ div vẫn còn, chữ bên trong biến mất -->
  ```
* **Nếu chạy `$('#hopThongBao').remove();`**:
  *(Cả thẻ `<div id="hopThongBao">` biến mất hoàn toàn khỏi cây HTML, không còn dấu vết)*.

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-attr"></span>
### 5. `.attr()` / `.removeAttr()` — Đọc, sửa, xóa thuộc tính HTML (`src`, `href`, `data-*`)

* **Bản chất**: "Thuộc tính HTML" (Attribute) là các thông số đi kèm nằm bên trong dấu mở `<thẻ thuộc_tính="giá_trị">`.
  * `.attr('tên')`: **1 tham số $\rightarrow$ Đọc (Get)** giá trị thuộc tính xem đang là gì.
  * `.attr('tên', 'giá_trị_mới')`: **2 tham số $\rightarrow$ Ghi đè (Set)** giá trị mới cho thuộc tính.
  * `.removeAttr('tên')`: Xóa sổ thuộc tính đó khỏi thẻ.

#### Minh họa 1: Đổi ảnh đại diện (Avatar)
* **HTML ban đầu**:
  ```html
  <img id="imgAvatar" src="/Images/nam.png" title="Ảnh đại diện">
  ```
* **Chạy lệnh jQuery**:
  ```javascript
  // 1. Đọc đường dẫn cũ
  var oldSrc = $('#imgAvatar').attr('src'); // Trả về "/Images/nam.png"

  // 2. Gán đường dẫn mới
  $('#imgAvatar').attr('src', '/Images/nu_default.png');
  ```
* **HTML sau khi chạy**:
  ```html
  <img id="imgAvatar" src="/Images/nu_default.png" title="Ảnh đại diện">
  ```

#### Minh họa 2: Thuộc tính giấu dữ liệu `data-*` (Cực kỳ quan trọng trong Paradise HRM)

> [!IMPORTANT]
> **Câu hỏi kinh điển**: *"Dữ liệu lấy từ API/reload data cơ mà, tại sao lại phải lưu vào thẻ HTML? Dữ liệu truyền từ FE xuống BE có phải lưu trong thẻ HTML không?"*
> 
> 👉 **Bản chất cốt lõi**:
> * **KHÔNG!** Dữ liệu nghiệp vụ thật (lương, ngày sinh, tiền nợ...) **100% nằm ở Database** và gửi xuống Backend qua gói tin HTTP/JSON trong RAM, thẻ HTML **không hề bay xuống Backend**.
> * **Vậy `data-*` để làm gì?**
>   * Đối với **ô nhập liệu (`<input>`)**: Người dùng tự gõ chữ vào $\rightarrow$ JavaScript dùng `.val()` đọc ra được.
>   * Nhưng đối với **nút bấm (`<button>`)**: Người dùng **chỉ click chuột**, không hề gõ chữ nào vào nút cả. Vậy khi click thì hàm AJAX biết lấy tham số gì gửi xuống Backend? $\rightarrow$ **Lập trình viên bắt buộc phải gài thuộc tính ẩn `data-*` vào nút bấm để JavaScript bóc ra làm tham số gọi AJAX!**

---

#### 🧠 CHUỖI SUY LUẬN BẮT BUỘC DẪN TỚI SỰ RA ĐỜI CỦA `data-*`:
*(Tại sao thẻ HTML cơ sở lặp lại bắt buộc phải dùng `data-*`?)*

1. **Thẻ cơ sở lặp đi lặp lại với số lần không cố định**: Danh sách 5 nhân viên, 100 khách hàng, hay 1000 dòng công nợ được đổ động từ Database ra giao diện.
2. **Luật HTML nghiêm cấm đặt trùng `id`**: Chuẩn web quy định `id` phải là duy nhất. Do đó, các thẻ `<button>` sinh ra trong vòng lặp **tuyệt đối không được gán `id`** (nếu gán trùng `id="btnXoa"`, jQuery sẽ bị tê liệt và chỉ luôn bắt trúng dòng đầu tiên).
3. **Chỉ có thể dùng `class` làm định danh chung**: Vì `class` cho phép lặp lại không giới hạn, tất cả các nút cùng loại đều phải mang chung một class (ví dụ `class="btn-action"`).
4. **Bắt sự kiện tập trung qua class chung**: JavaScript sẽ lắng nghe sự kiện click trên chính cái thẻ HTML cơ sở có class chung đó: `$(document).on('click', '.btn-action', ...)`.
5. **VẤN ĐỀ NẢY SINH**: Khi có 100 cái nút dùng chung 1 class y hệt nhau, người dùng bấm vào 1 nút bất kỳ $\rightarrow$ **Lấy cái gì để phân biệt được ai là ai trong số 100 người đó?**
6. **👉 ĐÁP ÁN DUY NHẤT: DÙNG `data-*`!**
   * Ta gán trực tiếp thuộc tính ẩn `data-employee-id="NV001"`, `data-employee-id="NV002"`... vào chính thẻ HTML cơ sở đó ngay khi render.
   * Khi người dùng click, JavaScript dùng `$(this).attr('data-employee-id')` để bóc đúng mã ID của dòng vừa bấm ra làm tham số truyền vào AJAX!

---

* **HTML danh sách nút bấm được sinh từ vòng lặp (Stored Procedure / Template)**:
  ```html
  <!-- Dòng 1 của Nguyễn Văn A -->
  <button class="btn-action" data-employee-id="NV001" data-branch="HCM">Xem chi tiết</button>

  <!-- Dòng 2 của Trần Thị B -->
  <button class="btn-action" data-employee-id="NV002" data-branch="HN">Xem chi tiết</button>
  ```

* **Chạy lệnh jQuery bóc tham số ẩn và gọi AJAX xuống Backend**:
  ```javascript
  $(document).on('click', '.btn-action', function() {
      // 1. $(this) bắt trúng đúng cái nút vừa được click trong số hàng trăm nút
      // Dùng .attr() để bóc tham số ẩn ra bộ nhớ RAM của JavaScript
      var empId  = $(this).attr('data-employee-id'); // Đọc ra "NV001" hoặc "NV002"
      var branch = $(this).attr('data-branch');      // Đọc ra "HCM" hoặc "HN"

      // 2. Đóng gói tham số vừa bóc được vào túi JSON (hoàn toàn không liên quan đến HTML nữa)
      var payload = {
          EmployeeID: empId,
          Branch: branch
      };

      // 3. Bắn gói tin JSON qua mạng xuống C# Backend để gọi API / reload data
      $.ajax({
          url: '/api/v1/Employee/GetDetail',
          type: 'POST',
          contentType: 'application/json',
          data: JSON.stringify(payload),
          success: function(dataNhanVien) {
              console.log("Dữ liệu chi tiết từ DB trả về:", dataNhanVien);
              // Mở Popup hiển thị thông tin
          }
      });
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-prop"></span>
### 6. `.prop()` — Can thiệp trạng thái logic Boolean (`checked`, `disabled`, `selected`)

* **Bản chất**: Các thẻ form HTML có những trạng thái logic nhị phân chỉ mang giá trị `true` hoặc `false` (`checked` - có tick hay không, `disabled` - có bị khóa hay không). Khác với `.attr()` (vốn đọc chuỗi chữ viết trên HTML), `.prop()` can thiệp trực tiếp vào bộ nhớ trạng thái sống của trình duyệt.
* **Cú pháp**:
  * Đọc trạng thái: `var isChecked = $(selector).prop('checked');` (trả về `true` hoặc `false`)
  * Gán trạng thái: `$(selector).prop('checked', true);` hoặc `false`

#### Minh họa trực quan:
* **HTML ban đầu**:
  ```html
  <input type="checkbox" id="pillMyData" checked>
  <button id="btnLuu" disabled>Lưu dữ liệu</button>
  ```
* **Chạy lệnh jQuery**:
  ```javascript
  // 1. Bỏ tick ô checkbox
  $('#pillMyData').prop('checked', false);

  // 2. Mở khóa nút bấm cho người dùng click
  $('#btnLuu').prop('disabled', false);
  ```
* **Kết quả trên màn hình**: Checkbox bị mất dấu tick xanh, nút Lưu sáng lên và bấm được.

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-val"></span>
### 7. `.val()` — Đọc và gán giá trị ô nhập liệu form (`<input>`, `<select>`, `<textarea>`)

* **Bản chất**: Dành riêng cho các thẻ nhập liệu người dùng tương tác.
  * `.val()` (không truyền tham số): Đọc nội dung người dùng vừa gõ vào ô.
  * `.val('chữ_mới')` (truyền tham số): Ghi đè chữ mới vào ô (hoặc truyền chuỗi rỗng `''` để xóa trắng).
* **Lưu ý tối quan trọng**: Không dùng `.val()` cho thẻ `<div>`, `<span>`, `<p>` vì những thẻ này không có thuộc tính value.

#### Minh họa trực quan:
* **HTML ban đầu**:
  ```html
  <input type="text" id="txtTuKhoa" value="Nguyễn Văn A">
  ```
* **Chạy lệnh jQuery**:
  ```javascript
  var tuKhoa = $('#txtTuKhoa').val(); // Đọc được chữ "Nguyễn Văn A"
  $('#txtTuKhoa').val('');           // Xóa sạch ô nhập liệu về rỗng
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-text"></span>
### 8. `.text()` — Đọc và thay thế chữ thuần túy (không kèm mã HTML)

* **Bản chất**: Lấy ra hoặc thay thế toàn bộ văn bản thô bên trong một thẻ hiển thị (`<div>`, `<span>`, `<h1>`, `<td>`). Nếu bạn truyền chuỗi có thẻ HTML (như `<b>Chữ đậm</b>`), `.text()` sẽ in nguyên văn cả dấu `<>` ra màn hình chứ không bôi đậm.
* **Cú pháp**:
  * Đọc: `var chu = $('#tieuDe').text();`
  * Gán: `$('#tieuDe').text('Tiêu đề mới');`

#### Minh họa trực quan:
* **HTML ban đầu**:
  ```html
  <span id="lblSoLuong">Tổng: 10 nhân viên</span>
  ```
* **Chạy lệnh jQuery**:
  ```javascript
  $('#lblSoLuong').text('Tổng: 25 nhân viên');
  ```
* **HTML sau khi chạy**:
  ```html
  <span id="lblSoLuong">Tổng: 25 nhân viên</span>
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-html"></span>
### 9. `.html()` — Đọc và ghi đè toàn bộ cấu trúc mã HTML bên trong

* **Bản chất**: Giống như `.text()`, nhưng `.html()` hiểu được các thẻ HTML. Nó sẽ yêu cầu trình duyệt biên dịch và dựng thành các phần tử đồ họa có màu sắc, icon thật sự.
* **Cú pháp**:
  * Đọc mã HTML: `var noiDung = $('#khung').html();`
  * Ghi đè mã HTML: `$('#khung').html('<b style="color:green;">Thành công!</b>');`

#### Minh họa trực quan:
* **HTML ban đầu**:
  ```html
  <div id="hopTrangThai">Chưa duyệt</div>
  ```
* **Chạy lệnh jQuery**:
  ```javascript
  $('#hopTrangThai').html('<span class="badge bg-success">✓ ĐÃ DUYỆT</span>');
  ```
* **HTML sau khi chạy**:
  ```html
  <div id="hopTrangThai">
      <span class="badge bg-success">✓ ĐÃ DUYỆT</span>
  </div>
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-css"></span>
### 10. `.css()` — Can thiệp trực tiếp thuộc tính style CSS (inline style)

* **Bản chất**: Thò tay ghi đè trực tiếp vào thuộc tính `style="..."` của thẻ HTML trên trình duyệt. Có quyền ưu tiên rất cao.
* **Cú pháp**:
  * Đổi 1 thuộc tính: `$(selector).css('tên_thuộc_tính', 'giá_trị');`
  * Đổi nhiều thuộc tính: `$(selector).css({ thuộc_tính_1: 'giá_trị', thuộc_tính_2: 'giá_trị' });`

#### Minh họa ứng dụng fix lỗi responsive trong Paradise HRM:
* **Đoạn script trong bản vá**:
  ```javascript
  // Ép màn hình thanh toán công nợ co giãn 100% chiều cao theo mô hình Flexbox
  $('#sp_Debt_PaymentDebt_html').css({
      'display': 'flex',
      'flex-direction': 'column',
      'height': '100%',
      'box-sizing': 'border-box'
  });
  ```
* **HTML được sinh ra trên DOM**:
  ```html
  <div id="sp_Debt_PaymentDebt_html" style="display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-classes"></span>
### 11. `.addClass()` / `.removeClass()` / `.toggleClass()` — Quản lý Class CSS

* **Bản chất**: Thay vì nhồi nhét mã style lung tung vào HTML, người ta định nghĩa các bộ cánh đẹp trong file `.css` (ví dụ class `.active`, `.highlight`, `.hide-screen`), sau đó dùng jQuery để khoác áo hoặc lột áo thẻ HTML.
  * `.addClass('ten-class')`: Thêm class vào thẻ.
  * `.removeClass('ten-class')`: Gỡ bỏ class ra khỏi thẻ.
  * `.toggleClass('ten-class')`: Nếu thẻ chưa có thì thêm vào, nếu có rồi thì gỡ ra.

#### Minh họa trực quan:
* **CSS viết sẵn**:
  ```css
  .tab-selected { background-color: #007bff; color: #fff; font-weight: bold; }
  ```
* **Chạy lệnh jQuery khi click chuyển tab**:
  ```javascript
  // Bỏ chọn tất cả tab cũ
  $('.tab-item').removeClass('tab-selected');
  // Kích hoạt tab vừa click
  $(this).addClass('tab-selected');
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-show-hide"></span>
### 12. `.show()` / `.hide()` / `.toggle()` — Bật / tắt hiển thị phần tử

* **Bản chất**: Là phím tắt cực nhanh của jQuery.
  * `.hide()` $\rightarrow$ Gán `display: none;` (làm phần tử tàng hình và không chiếm diện tích trên màn hình).
  * `.show()` $\rightarrow$ Gỡ bỏ `display: none` để phần tử hiện lại bình thường.
  * `.toggle()` $\rightarrow$ Đang ẩn thì hiện, đang hiện thì ẩn.
* **Code mẫu trong Paradise HRM**:
  ```javascript
  // Hiện vòng xoay loading khi bắt đầu gọi API lấy dữ liệu nợ
  $('#loadingSpinner').show();

  // Ẩn vòng xoay loading sau khi dữ liệu đã tải xong
  $('#loadingSpinner').hide();
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-find"></span>
### 13. `.find()` — Tìm kiếm thẻ con, cháu nằm sâu bên trong

* **Bản chất**: Giúp giới hạn phạm vi tìm kiếm. Thay vì tìm kiếm trên toàn bộ trang web (rất chậm và dễ nhầm với màn hình khác), `.find()` chỉ lùng sục bên trong một thẻ cha cụ thể.
* **Cú pháp**: `$(thẻ_cha).find('selector_con');`

#### Minh họa trực quan:
* **HTML**:
  ```html
  <div id="rowQuickFilters">
      <button class="btn">Hôm nay</button>
      <button class="btn">Tuần này</button>
      <button class="btn">Tháng này</button>
  </div>
  ```
* **Chạy lệnh jQuery**:
  ```javascript
  // Tìm tất cả button nằm bên trong #rowQuickFilters để đổi màu viền xám
  $('#rowQuickFilters').find('button').css({ borderColor: '#ddd', fontWeight: '400' });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-closest"></span>
### 14. `.closest()` — Leo ngược cây DOM tìm thẻ cha / tổ tiên gần nhất

* **Bản chất**: Hoạt động ngược lại với `.find()`. Nó đứng từ thẻ hiện tại và **leo ngược lên trên** để tìm thẻ tổ tiên gần nhất khớp với điều kiện.
* **Khi nào dùng**: Thường dùng khi người dùng click vào một nút bấm nhỏ (ví dụ nút Xóa dòng, Sửa dòng) nằm sâu bên trong một bảng dữ liệu hoặc thẻ card.
* **Code mẫu thực tế**:
  ```javascript
  $(document).on('click', '.btn-xoa-dong', function() {
      // Từ cái nút vừa bấm, leo ngược lên tìm dòng <tr> chứa nó
      var $dong = $(this).closest('tr');
      // Xóa dòng đó khỏi bảng
      $dong.remove();
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-on-click"></span>
### 15. `$(selector).on('click', fn)` — Bắt sự kiện click trực tiếp

* **Bản chất**: Gắn một người lính canh trực tiếp vào thẻ HTML để chờ người dùng click.
* **Điều kiện bắt buộc**: Thẻ HTML này **phải có mặt sẵn trên trang ngay từ đầu**.
* **Hạn chế**: Nếu thẻ này được sinh ra sau bằng AJAX, lệnh này sẽ **hoàn toàn vô tác dụng**!
* **Code mẫu**:
  ```javascript
  $('#btnLamMoi').on('click', function(e) {
      e.preventDefault(); // Chặn hành vi tải lại trang mặc định
      console.log('Đã bấm nút làm mới!');
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-delegation"></span>
### 16. `$(document).on('click', '.child', fn)` — Bắt sự kiện ủy quyền (*Event Delegation*)

* **Bản chất**: Thay vì gắn lính canh vào từng nút con sinh động (vốn chưa tồn tại lúc nạp trang), ta gắn lính canh vào cấp cao nhất là `$(document)` (hoặc thẻ cha cố định). Khi có bất kỳ cú click nào xảy ra ở bất kỳ đâu trên màn hình, sự kiện sẽ nổi bọt (bubble) lên `document`, và `document` sẽ kiểm tra xem cú click đó có xuất phát từ thẻ `.child` hay không để thực thi.
* **Khi nào dùng**: **BẮT BUỘC DÙNG** cho mọi nút bấm, hàng bảng, chip lọc được sinh động trong kiến trúc SPA của Paradise HRM.
* **Code mẫu thực tế**:
  ```javascript
  $(document).on('click', '.chip-loc-trang-thai', function() {
      var statusId = $(this).attr('data-id');
      console.log('Đã bấm chọn trạng thái lọc:', statusId);
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="cmd-ajax"></span>
### 17. `$.ajax()` — Bắn request ngầm gọi API Backend C#

* **Bản chất**: Cầu nối giao tiếp giữa giao diện trình duyệt và máy chủ (C# Web API / ASP.NET). Gửi dữ liệu đi và nhận kết quả JSON về trong âm thầm mà không làm nhấp nháy hoặc tải lại trang web.
* **Cú pháp đầy đủ**:
  ```javascript
  $.ajax({
      url: '/api/v1/Debt/ProcessPayment', // Đường dẫn API
      type: 'POST',                       // Phương thức: POST, GET, PUT, DELETE
      contentType: 'application/json',     // Định dạng dữ liệu gửi đi
      data: JSON.stringify({              // Dữ liệu gói vào thân gửi đi
          VoucherNo: 'PT001',
          TotalAmount: 5000000
      }),
      beforeSend: function() {
          // Chạy trước khi gửi: thường bật loading
          $('#loadingSpinner').show();
      },
      success: function(response) {
          // Chạy khi máy chủ phản hồi thành công (mã 200 OK)
          DevExpress.ui.notify('Thanh toán thành công!', 'success', 3000);
      },
      error: function(xhr, status, error) {
          // Chạy khi có lỗi từ server (mã 400, 500...)
          DevExpress.ui.notify('Lỗi thanh toán: ' + error, 'error', 4000);
      },
      complete: function() {
          // Luôn luôn chạy sau cùng (dù thành công hay thất bại): tắt loading
          $('#loadingSpinner').hide();
      }
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="c-phan-2-devextreme"></span>
# C. PHẦN 2: TOÀN BỘ CÁC LỆNH DEVEXTREME (UI WIDGETS & INSTANCES)

DevExtreme không thao tác đơn lẻ từng thẻ HTML, mà nó quản lý **toàn bộ linh kiện UI** thông qua một cỗ máy ngầm (*Instance*).

---

<span id="dx-datagrid"></span>
### 1. `dxDataGrid` — Bảng dữ liệu lưới cao cấp

* **Bản chất**: Biến một thẻ `<div>` đơn giản thành một bảng dữ liệu doanh nghiệp hoàn chỉnh (cố định cột trái/phải, co giãn responsive, gom nhóm group, phân trang, lọc theo cột, sắp xếp).
* **Code mẫu khởi tạo**:
  ```javascript
  $('#gridThanhToanCongNo').dxDataGrid({
      dataSource: danhSachCongNo, // Mảng dữ liệu từ C# trả về
      showBorders: true,
      columnAutoWidth: true,
      height: '100%',             // Co giãn toàn bộ chiều cao cha
      paging: { pageSize: 20 },   // Phân trang 20 dòng/trang
      selection: { mode: 'multiple' }, // Cho phép tick chọn nhiều dòng bằng checkbox
      columns: [
          { dataField: 'VoucherNo', caption: 'Số phiếu', width: 120 },
          { dataField: 'CustomerName', caption: 'Khách hàng' },
          { dataField: 'Amount', caption: 'Số tiền', format: '#,##0 đ', alignment: 'right' },
          { dataField: 'Status', caption: 'Trạng thái', alignment: 'center' }
      ]
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-selectbox"></span>
### 2. `dxSelectBox` — Dropdown chọn 1 giá trị

* **Bản chất**: Thay thế thẻ `<select>` cùi bắp của HTML bằng một ô chọn cực kỳ thông minh: gõ phím tìm kiếm nhanh (searchable), phân trang dữ liệu, tự động mở rộng theo nội dung.
* **Code mẫu khởi tạo**:
  ```javascript
  $('#cboChiNhanh').dxSelectBox({
      dataSource: dsChiNhanh,
      displayExpr: 'BranchName', // Trường lấy chữ hiển thị lên ô (vd: "Chi nhánh Quận 1")
      valueExpr: 'BranchID',     // Trường lấy giá trị ngầm lưu xuống DB (vd: "CN01")
      searchEnabled: true,       // Bật tính năng gõ chữ để tìm
      placeholder: '-- Chọn chi nhánh --'
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-datebox"></span>
### 3. `dxDateBox` — Ô chọn ngày, tháng, năm, giờ

* **Bản chất**: Hộp nhập ngày kèm giao diện chọn lịch (Calendar) chuẩn mực, ngăn chặn người dùng nhập sai định dạng ngày tháng của SQL Server.
* **Code mẫu khởi tạo**:
  ```javascript
  $('#dtpTuNgay').dxDateBox({
      type: 'date',                  // Kiểu ngày ('date', 'time', 'datetime')
      displayFormat: 'dd/MM/yyyy',   // Định dạng hiển thị kiểu Việt Nam
      value: new Date(),             // Giá trị mặc định là ngày hôm nay
      showClearButton: true          // Hiện nút [x] để xóa nhanh
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-inputs"></span>
### 4. `dxTextBox` / `dxNumberBox` / `dxTextArea` — Bộ ô nhập liệu chuẩn DevExtreme

* **Bản chất**: 
  * `dxTextBox`: Nhập chuỗi chữ 1 dòng (Mã NV, Họ tên).
  * `dxNumberBox`: Chuyên nhập số (tự format dấu phẩy hàng nghìn `1,000,000`, chặn gõ chữ).
  * `dxTextArea`: Ô nhập ghi chú nhiều dòng (nội dung cuộc họp).
* **Code mẫu**:
  ```javascript
  // Ô nhập số tiền thanh toán
  $('#txtSoTien').dxNumberBox({
      format: '#,##0 VNĐ',
      min: 0,
      value: 500000
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-popup"></span>
### 5. `dxPopup` — Cửa sổ Modal nổi (Dialog)

* **Bản chất**: Biến thẻ `<div>` thành một cửa sổ pop-up chuyên nghiệp đè lên giữa màn hình, có thanh tiêu đề, nút tắt [X], hiệu ứng làm mờ nền (backdrop).
* **Code mẫu khởi tạo**:
  ```javascript
  $('#modalChinhSua').dxPopup({
      title: 'Cập nhật thông tin nhân viên',
      width: 750,
      height: 550,
      visible: false, // Ban đầu luôn luôn ẩn
      showCloseButton: true
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-fileuploader"></span>
### 6. `dxFileUploader` — Widget tải lên tài liệu / ảnh đại diện

* **Bản chất**: Giao diện kéo thả tệp tin (Drag & Drop) để upload avatar hoặc file đính kèm lên server Paradise HRM.
* **Code mẫu**:
  ```javascript
  $('#uploaderAvatar').dxFileUploader({
      selectButtonText: 'Chọn ảnh đại diện',
      accept: 'image/*',
      uploadMode: 'useForm'
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-buttons"></span>
### 7. `dxButton` / `dxDropDownButton` — Nút bấm DevExtreme

* **Bản chất**: Nút bấm đồng bộ theme với DevExtreme, tự đổi icon loading khi được click, hoặc có menu xổ xuống.
* **Code mẫu**:
  ```javascript
  $('#btnExportMenu').dxDropDownButton({
      text: 'Xuất dữ liệu',
      icon: 'export',
      items: ['Xuất file Excel (.xlsx)', 'Xuất file PDF', 'Xuất file CSV'],
      onItemClick: function(e) {
          console.log('Người dùng chọn:', e.itemData);
      }
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-validator"></span>
### 8. `dxValidator` — Bộ kiểm tra hợp lệ dữ liệu form

* **Bản chất**: Gắn quy tắc kiểm tra (bắt buộc nhập, định dạng email, số điện thoại) vào ô nhập liệu DevExtreme trước khi bấm nút Lưu.
* **Code mẫu**:
  ```javascript
  $('#txtMaNV').dxValidator({
      validationRules: [
          { type: 'required', message: 'Mã nhân viên không được để trống!' },
          { type: 'stringLength', min: 4, message: 'Mã nhân viên phải từ 4 ký tự trở lên!' }
      ]
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-instance"></span>
### 9. Cách lấy Instance của Widget DevExtreme

> [!IMPORTANT]
> **Khái niệm then chốt**: Khi bạn chạy `$('#grid').dxDataGrid({...})`, thẻ `<div>` đã biến thành một Widget. Muốn ra lệnh cho widget này (tải lại dữ liệu, đọc giá trị, mở popup), bạn **bắt buộc phải lấy đối tượng `Instance`** của nó.

Có 2 cách lấy:

#### Cách 1: Tự lấy bằng cú pháp jQuery chuẩn
```javascript
var gridInst   = $('#gridThanhToanCongNo').dxDataGrid('instance');
var selectInst = $('#cboChiNhanh').dxSelectBox('instance');
var popupInst  = $('#modalChinhSua').dxPopup('instance');
```

#### Cách 2: Biến toàn cục hệ thống Paradise HRM tự sinh sẵn trong Stored Procedure
Trong các Stored Procedure của hệ thống, mã máy tự động sinh ra một biến toàn cục gắn mã GUID định danh:
```javascript
// Hệ thống tự gán sẵn:
// InstanceEmployeeIDPDF424130C28F4C1298C81F737570F7A7 = $('#cboEmployee').dxSelectBox('instance');
// Ta chỉ việc gọi trực tiếp biến này!
```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-option"></span>
### 10. `.option('key', value)` / `.option('key')` — Đọc / Gán thuộc tính Widget khi đang chạy

* **Bản chất**: Là "chiếc đũa thần" mạnh nhất của DevExtreme. Cho phép can thiệp vào bất kỳ thuộc tính cấu hình nào của widget mà không cần khởi tạo lại từ đầu.
  * Truyền 1 tham số `.option('tên')`: **ĐỌC** giá trị hiện tại.
  * Truyền 2 tham số `.option('tên', giá_trị)`: **GHI ĐÈ** giá trị mới.

#### Ứng dụng 1: Xóa trắng ô đang chọn (Reset)
```javascript
// Gán giá trị đang chọn về null (rỗng)
InstanceEmployeeIDPDF424130C28F4C1298C81F737570F7A7.option('value', null);
```

#### Ứng dụng 2: Đọc mã đang chọn trong Dropdown
```javascript
var maChiNhanh = selectInst.option('value'); // Trả về "CN01"
```

#### Ứng dụng 3: Thay đổi nguồn dữ liệu mới cho bảng DataGrid
```javascript
gridInst.option('dataSource', danhSachMoi);
```

#### Ứng dụng 4: Khóa hoặc Mở khóa ô nhập liệu
```javascript
selectInst.option('disabled', true);  // Khóa ô chọn
selectInst.option('disabled', false); // Mở khóa ô chọn
```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-refresh"></span>
### 11. `.refresh()` — Tải lại dữ liệu cho bảng DataGrid

* **Bản chất**: Kích hoạt DataGrid kết nối lại nguồn dữ liệu (gọi lại API / hàm nạp ngầm) để cập nhật các dòng mới nhất từ cơ sở dữ liệu lên màn hình.
* **Code mẫu thực tế**:
  ```javascript
  // Sau khi người dùng thanh toán nợ thành công, làm mới lại lưới:
  var grid = $('#gridThanhToanCongNo').dxDataGrid('instance');
  grid.refresh();
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-selection"></span>
### 12. `.getSelectedRowsData()` / `.clearSelection()` — Lấy dòng được chọn / Bỏ chọn toàn bộ

* **Bản chất**:
  * `.getSelectedRowsData()`: Trả về một mảng chứa dữ liệu của toàn bộ các dòng đang được tick chọn checkbox.
  * `.clearSelection()`: Tự động bỏ dấu tick toàn bộ các dòng.
* **Code mẫu thực tế**:
  ```javascript
  var grid = $('#gridThanhToanCongNo').dxDataGrid('instance');

  // Lấy các dòng được tick chọn để gom đi duyệt hàng loạt
  var danhSachDuocChon = grid.getSelectedRowsData();
  if (danhSachDuocChon.length === 0) {
      alert('Vui lòng tick chọn ít nhất 1 dòng để duyệt!');
      return;
  }
  console.log('Đang xử lý ' + danhSachDuocChon.length + ' phiếu nợ được tick.');

  // Sau khi duyệt xong thì bỏ tick hết
  grid.clearSelection();
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-show-hide-popup"></span>
### 13. `.show()` / `.hide()` (Instance Popup) — Bật mở / Đóng cửa sổ Modal

* **Bản chất**: Điều khiển cửa sổ `dxPopup` hiển thị hoặc biến mất khỏi tầm mắt người dùng.
* **Code mẫu thực tế**:
  ```javascript
  var popup = $('#modalChinhSua').dxPopup('instance');

  // Mở popup lên khi bấm nút [Sửa]
  popup.show();

  // Đóng popup lại khi bấm nút [Hủy] hoặc lưu thành công
  popup.hide();
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-repaint"></span>
### 14. `.repaint()` — Ép vẽ lại hình học khi giao diện bị méo / co cụm

* **Bản chất**: Trong ứng dụng SPA (Single Page Application) của Paradise HRM, khi một tab hoặc modal bị ẩn, chiều rộng của nó bằng 0. Khi bật tab lên, DevExtreme đôi khi tính toán sai độ rộng khiến các cột bị co cụm lại còn vài pixel. Lệnh `.repaint()` ép widget đo đạc lại kích thước màn hình và vẽ lại giao diện hoàn hảo 100%.
* **Code mẫu thực tế**:
  ```javascript
  var grid = $('#gridThanhToanCongNo').dxDataGrid('instance');
  grid.repaint(); // Ép DataGrid tính toán lại độ rộng các cột
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-notify"></span>
### 15. `DevExpress.ui.notify()` — Bật thông báo Toast góc màn hình

* **Bản chất**: Hiển thị hộp thông báo nhỏ gọn gàng, tự động trôi ra từ góc màn hình và tự biến mất sau số giây quy định (không làm gián đoạn thao tác người dùng như lệnh `alert()` cổ lỗ sĩ).
* **Các kiểu thông báo (`type`)**:
  * `'success'`: Hộp màu xanh lá (Thông báo thành công).
  * `'error'`: Hộp màu đỏ (Báo lỗi).
  * `'warning'`: Hộp màu cam/vàng (Cảnh báo).
  * `'info'`: Hộp màu xanh dương (Thông tin chung).
* **Code mẫu**:
  ```javascript
  // Hiện thông báo màu xanh lá trong 3 giây (3000 ms)
  DevExpress.ui.notify('Đã lưu dữ liệu thành công!', 'success', 3000);

  // Hiện thông báo lỗi màu đỏ trong 4 giây
  DevExpress.ui.notify('Lỗi: Bạn chưa chọn phòng ban!', 'error', 4000);
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-confirm"></span>
### 16. `DevExpress.ui.dialog.confirm()` — Hộp thoại hỏi xác nhận Có / Không

* **Bản chất**: Bật một cửa sổ xác nhận đẹp mắt với 2 nút [Yes] / [No]. Trả về một `Promise`, khi người dùng bấm Yes thì kết quả trả về `true`.
* **Code mẫu**:
  ```javascript
  DevExpress.ui.dialog.confirm("Bạn có chắc chắn muốn xóa nhân viên này khỏi hệ thống?", "Xác nhận xóa").done(function(result) {
      if (result === true) {
          // Người dùng bấm [Yes] -> Tiến hành gọi API xóa
          console.log('Thực hiện xóa...');
      } else {
          // Người dùng bấm [No] -> Không làm gì cả
          console.log('Đã hủy thao tác xóa.');
      }
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="dx-export"></span>
### 17. `DevExpress.excelExporter.exportDataGrid()` — Xuất trực tiếp bảng dữ liệu ra Excel

* **Bản chất**: Tự động chuyển đổi toàn bộ dữ liệu, tiêu đề cột và định dạng số của `dxDataGrid` thành một file bảng tính Microsoft Excel (`.xlsx`) để tải về máy tính.
* **Code mẫu**:
  ```javascript
  var grid = $('#gridThanhToanCongNo').dxDataGrid('instance');
  var workbook = new ExcelJS.Workbook();
  var worksheet = workbook.addWorksheet('DanhSachCongNo');

  DevExpress.excelExporter.exportDataGrid({
      component: grid,
      worksheet: worksheet,
      autoFilterEnabled: true
  }).then(function() {
      workbook.xlsx.writeBuffer().then(function(buffer) {
          saveAs(new Blob([buffer], { type: 'application/octet-stream' }), 'BaoCaoCongNo.xlsx');
      });
  });
  ```

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="phan-d-bang-doi-ung"></span>
# D. PHẦN 3: BẢNG SO SÁNH ĐỐI ỨNG KHI NÀO DÙNG GÌ?

> [!CAUTION]
> **Quy tắc sinh tử trong Paradise HRM**:
> * Thẻ do bạn tự viết bằng HTML $\rightarrow$ Dùng lệnh cột **jQuery**.
> * Thẻ do DevExtreme quản lý $\rightarrow$ Dùng lệnh cột **DevExtreme**.
> * **TUYỆT ĐỐI KHÔNG** dùng `$('#cbo').val('')` cho DevExtreme! Bắt buộc phải dùng `instance.option('value', null)`.

| Nghiệp vụ cần làm | Đối với Thẻ HTML chuẩn (Dùng jQuery) | Đối với Widget DevExtreme (Dùng DevExtreme) |
| :--- | :--- | :--- |
| **Xóa trắng giá trị (Reset)** | `$('#txtSearch').val('');` | `instanceSelectBox.option('value', null);` |
| **Đọc giá trị đang chọn** | `var v = $('#txtSearch').val();` | `var v = instanceSelectBox.option('value');` |
| **Gán giá trị mới** | `$('#txtMa').val('NV01');` | `instanceSelectBox.option('value', 'NV01');` |
| **Khóa ô (Disable)** | `$('#btnSave').prop('disabled', true);` | `instanceSelectBox.option('disabled', true);` |
| **Mở khóa ô (Enable)** | `$('#btnSave').prop('disabled', false);` | `instanceSelectBox.option('disabled', false);` |
| **Ẩn phần tử** | `$('#hopThongBao').hide();` | `instancePopup.hide();` |
| **Hiện phần tử** | `$('#hopThongBao').show();` | `instancePopup.show();` |
| **Nạp dữ liệu mới** | Tự xóa thẻ cũ và `.append()` thẻ mới | `instanceSelectBox.option('dataSource', mảngMới);` |
| **Tải lại dữ liệu lưới** | Gọi `$.ajax()` vẽ lại HTML table | `gridInstance.refresh();` |
| **Vẽ lại kích thước khi méo**| Tự chỉnh `.css('width', '100%')` | `gridInstance.repaint();` |

[↩ Quay lại Mục lục](#muc-luc)

---

<span id="phan-e-giai-ma-code"></span>
# E. PHẦN 4: GIẢI MÃ CHI TIẾT TỪNG DÒNG CODE MẪU THỰC TẾ TRONG DỰ ÁN

Dưới đây là đoạn code thực tế trong thanh lọc tìm kiếm của Paradise HRM mà bạn đã hỏi, được bóc tách từng dòng:

```javascript
// DÒNG 1: [jQuery] Tạo một thẻ <div> chân trang (footer) động nằm sẵn trong bộ nhớ RAM
const $footer = $('<div style="display:flex;justify-content:space-between;border-top:0.5px solid #eee;padding-top:12px;">');

// DÒNG 2 & 3: [jQuery] Can thiệp thuộc tính Boolean để BỎ TICK 2 ô Checkbox HTML chuẩn
$('#pillViewAllP1D1261311DFB4BDABD06DE5867CFF5B5').prop('checked', false);
$('#pillMyDataP1D1261311DFB4BDABD06DE5867CFF5B5').prop('checked', false);

// DÒNG 4: [DevExtreme] Gọi vào biến Instance do hệ thống sinh sẵn để RESET ô chọn nhân viên về RỖNG (null)
InstanceEmployeeIDPDF424130C28F4C1298C81F737570F7A7.option('value', null);

// DÒNG 5 & 6: [jQuery + JS thuần] Bỏ tick checkbox KPI và đưa cờ logic về false
$('#pillKPIP1D1261311DFB4BDABD06DE5867CFF5B5').prop('checked', false);
hasKPIDate = false;

// DÒNG 7 & 8: [jQuery] Chuỗi lệnh liên hoàn (Chaining): Xóa trắng chữ (.val('')) -> Mở khóa ô (.prop('disabled', false)) -> Làm sáng rõ nét (.css('opacity', '1')) cho 2 ô ngày
$('#pillFromDateP1D1261311DFB4BDABD06DE5867CFF5B5').val('').prop('disabled', false).css('opacity', '1');
$('#pillToDateP1D1261311DFB4BDABD06DE5867CFF5B5').val('').prop('disabled', false).css('opacity', '1');

// DÒNG 9: [jQuery] Tìm toàn bộ các nút con bên trong thẻ $quickRow rồi đổi kiểu dáng viền xám (#ddd) và bỏ bôi đậm (fontWeight: 400)
$quickRow.find('button').css({ borderColor: "#ddd", fontWeight: "400" });

// DÒNG 10: [jQuery] Tạo thẻ nút bấm HTML động có nhãn "✓ Áp dụng"
const $applyBtn = $('<button style="...">✓ Áp dụng</button>');

// DÒNG 11 đến 15: [jQuery] Dán (append) 2 nút $resetBtn và $applyBtn vào bên trong thẻ cha $footer
try {
    $footer.append($resetBtn, $applyBtn);
} catch (error) {
    $footer.append($applyBtn);
}
```

[↩ Quay lại Mục lục](#muc-luc)
