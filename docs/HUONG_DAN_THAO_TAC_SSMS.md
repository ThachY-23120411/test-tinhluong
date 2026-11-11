# SỔ TAY THAO TÁC SQL SERVER MANAGEMENT STUDIO (SSMS) THỰC CHIẾN
## PHẦN 1: HƯỚNG DẪN THỦ CÔNG LẤY & CẤU HÌNH CONNECTION STRING TRÊN GUI SSMS

> **Mục tiêu**: Hướng dẫn chi tiết từng cú click chuột trên giao diện SSMS để lấy đầy đủ các thông số và cấu hình một chuỗi kết nối (**Connection String**) chuẩn xác 100%, phục vụ cho việc lập trình Web, viết script automation hoặc kiểm thử dữ liệu.  
> **Áp dụng trực tiếp**: Môi trường máy chủ `192.168.11.51,2222` và Database `Vietinsoft_ForTest_Tai2`.  

---

## MỤC LỤC TỔNG QUAN

1. [PHẦN 1: HƯỚNG DẪN THỦ CÔNG LẤY & CẤU HÌNH CONNECTION STRING TRÊN GUI SSMS](#phần-1-hướng-dẫn-thủ-công-lấy--cấu-hình-connection-string-trên-gui-ssms)
   - [1. Bản chất: Connection String là gì?](#1-bản-chất-connection-string-chuỗi-kết-nối-là-gì)
   - [2. Cách lấy Connection String thủ công từ GUI SSMS (3 cách)](#2-cách-lấy-connection-string-thủ-công-từ-gui-ssms-3-cách)
   - [3. Bảng đối chiếu các từ khóa trong Connection String](#3-bảng-đối-chiếu-các-từ-khóa-trong-connection-string)
   - [4. Tổng hợp các mẫu Connection String dùng ngay trong dự án](#4-tổng-hợp-các-mẫu-connection-string-dùng-ngay-trong-dự-án)
2. [PHẦN 2: CÁCH NHẬN BIẾT & TÌM KIẾM 3 LOẠI STORED PROCEDURE TRONG DATABASE](#phần-2-cách-nhận-biện--tìm-kiếm-3-loại-stored-procedure-trong-database)
   - [1. Bảng nhận diện 3 loại Stored Procedure (HTML UI vs Truy vấn vs Logic Backend)](#1-bảng-nhận-diện-3-loại-stored-procedure-theo-tên-gọi--chức-năng)
   - [2. Ví dụ "Bộ 3 song hành" của một chức năng](#2-ví-dụ-bộ-3-song-hành-của-một-chức-năng)
   - [3. Cách tìm chính xác Stored Procedure bạn cần trong SSMS](#3-cách-tìm-chính-xác-stored-procedure-bạn-cần-trong-ssms)
   - [4. Cách mở xem và sửa Stored Procedure trên GUI SSMS](#4-cách-mở-xem-và-sửa-stored-procedure-trên-gui-ssms)
3. [PHẦN 3: BẢN CHẤT LƯU TRỮ STORED PROCEDURE & SỰ THẬT VỀ CÁC FILE `.sql`](#phần-3-bản-chất-lưu-trữ-stored-procedure--sự-thật-về-các-file-sql)
   - [1. Bản chất: Trong Database không hề có "file" nào cả!](#1-bản-chất-trong-database-không-hề-có-file-nào-cả)
   - [2. Ẩn dụ kinh điển: File `.sql` giống như File cài đặt `Setup.exe`](#2-ẩn-dụ-kinh-điển-file-sql-giống-như-file-cài-đặt-setupexe)
   - [3. Kịch bản làm việc thực tế: File `.sql` là "giấy nháp cá nhân"](#3-kịch-bản-làm-việc-thực-tế-file-sql-là-giấy-nháp-cá-nhân)
4. [PHẦN 4: HƯỚNG DẪN VIẾT STORE MỚI & BỘ PHÍM TẮT THAO TÁC SIÊU TỐC TRÊN SSMS](#phần-4-hướng-dẫn-viết-store-mới--bộ-phím-tắt-thao-tác-siêu-tốc-trên-ssms)
   - [1. Chỗ viết Stored Procedure mới nằm ở đâu?](#1-chỗ-viết-stored-procedure-mới-nằm-ở-đâu)
   - [2. Bí kíp tìm & sửa Stored Procedure trong 3 giây (Bộ lọc phễu & phím tắt Ctrl+3)](#2-bí-kíp-tìm--sửa-stored-procedure-trong-3-giây-không-cuộn-chuột)
   - [3. Bộ phím tắt vàng khi làm việc với SQL trên SSMS](#3-bộ-phím-tắt-vàng-khi-làm-việc-với-sql-trên-ssms)
5. [PHẦN 5: QUY TRÌNH CHUẨN 5 BƯỚC: MỞ XEM, SỬA ĐỔI & LƯU STORED PROCEDURE VÀO DATABASE](#phần-5-quy-trình-chuẩn-5-bước-mở-xem-sửa-đổi--lưu-stored-procedure-vào-database)
   - [1. Bước 1: Tìm đến Stored Procedure cần sửa](#bước-1-tìm-đến-stored-procedure-cần-sửa)
   - [2. Bước 2: Mở cửa sổ sửa code (Modify vs Script as ALTER To)](#bước-2-mở-cửa-sổ-sửa-code-2-cách-bấm-chuột)
   - [3. Bước 3: Đọc hiểu cấu trúc & chỉnh sửa an toàn (Ctrl + F5 Parse)](#bước-3-đọc-hiểu--chỉnh-sửa-code)
   - [4. Bước 4: Lưu thay đổi vào Database (F5 / Execute vs Cạm bẫy Ctrl + S)](#bước-4-lưu-thay-đổi-vào-database-cực-kỳ-quan-trọng)
   - [5. Bước 5: Kiểm chứng trực tiếp trên web Chrome](#bước-5-kiểm-chứng-trực-tiếp-trên-web)

---

## 1. BẢN CHẤT: CONNECTION STRING (CHUỖI KẾT NỐI) LÀ GÌ?

Hãy tưởng tượng một ứng dụng (Web C#, tool NodeJS, script Python) muốn nói chuyện với Database, nó giống như một người muốn gửi thư:
* Cần biết: **Số nhà ở đâu?** (`Server IP, Port`)
* Cần biết: **Vào căn hộ nào?** (`Database Name`)
* Cần biết: **Dùng chìa khóa nào để mở cửa?** (`Tài khoản Windows hay User/Password`)

👉 **Connection String** chính là một dòng chữ gộp toàn bộ các thông tin trên lại theo cú pháp quy chuẩn để máy tính tự động đọc và mở kết nối.

---

## 2. CÁCH LẤY CONNECTION STRING THỦ CÔNG TỪ GUI SSMS (3 CÁCH)

---

### 🔹 CÁCH 1: LẤY QUA HỘP THOẠI "CONNECT TO SERVER" (CHUẨN XÁC & ĐẦY ĐỦ NHẤT)

Đây là cách trực quan nhất mà bất kỳ ai mở SSMS cũng nhìn thấy ngay trước mắt:

#### Bước 1: Mở hộp thoại kết nối
* Trên giao diện SSMS, ở góc trên cùng bên trái của thanh cửa sổ **Object Explorer**, bấm vào nút **Connect** $\rightarrow$ chọn **Database Engine...**  
*(Hoặc vào menu trên cùng: `File` $\rightarrow$ `Connect Object Explorer...`)*.

#### Bước 2: Thu thập thông số Máy chủ & Tài khoản (Tab Login)
Cửa sổ **Connect to Server** hiện ra:
1. **Server name**: Bạn nhìn thấy giá trị đang điền là `192.168.11.51,2222`  
   $\rightarrow$ Đây chính là tham số **`Server`** (hoặc **`Data Source`**).
2. **Authentication**: Đang chọn là **`Windows Authentication`**  
   $\rightarrow$ Đây chính là tham số **`Integrated Security=True;`** (hoặc **`Trusted_Connection=True;`**).
3. **User name**: Đang hiển thị tài khoản domain của bạn `VIETINSOFT\Y.Thach`.

#### Bước 3: Thu thập thông số Database đích (Bấm nút Options >>)
1. Ở góc dưới bên phải hộp thoại, bấm vào nút **`Options >>`** để mở rộng các tab nâng cao.
2. Bấm chuyển sang tab thứ hai: **`Connection Properties`**.
3. Tại ô **Connect to database**:
   * Mặc định có thể là `<default>` (sẽ trỏ vào DB `master`).
   * Bạn hãy nhấp vào mũi tên dropdown hoặc gõ chính xác tên Database bạn muốn kết nối:  
     👉 **`Vietinsoft_ForTest_Tai2`**  
   * $\rightarrow$ Đây chính là tham số **`Database`** (hoặc **`Initial Catalog`**).
4. Tại mục **Network protocol**: Chọn `TCP/IP`.
5. Tại mục **Trust server certificate**: Đánh dấu tích chọn `[x]`  
   $\rightarrow$ Đây chính là tham số **`TrustServerCertificate=True;`** (giúp kết nối không bị chặn bởi chứng chỉ SSL nội bộ).

#### Bước 4: Ghép thành chuỗi Connection String hoàn chỉnh
Từ các thông tin bạn vừa thấy trên GUI ở 3 bước trên, bạn ghép lại thành 1 dòng duy nhất:

```text
Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;
```

---

### 🔹 CÁCH 2: XEM THUỘC TÍNH DATABASE PROPERTIES TRÊN OBJECT EXPLORER

Nếu bạn đã kết nối vào SSMS rồi và đang nhìn thấy danh sách Database:

#### Bước 1: Mở cửa sổ Properties của Database
1. Trong cây thư mục **Object Explorer** bên trái, mở rộng mục **Databases**.
2. Tìm đến đúng Database của bạn: **`Vietinsoft_ForTest_Tai2`**.
3. Nhấp **chuột phải** vào `Vietinsoft_ForTest_Tai2` $\rightarrow$ Chọn dòng dưới cùng: **`Properties`**.

#### Bước 2: Xem các tham số kết nối
Cửa sổ **Database Properties** hiện lên:
1. Ngay trang đầu tiên (**General**), bạn sẽ thấy:
   * **Name**: `Vietinsoft_ForTest_Tai2` (Tên Database).
   * **Collation**: Bảng mã ký tự (ví dụ: `Vietnamese_CI_AS` hoặc `SQL_Latin1_General_CP1_CI_AS`).
2. Nhìn xuống **góc dưới cùng bên trái** của cửa sổ Properties, bạn sẽ thấy một dòng link nhỏ màu xanh:
   👉 **`View connection properties`**
3. Bấm vào link đó, một cửa sổ popup sẽ hiện ra liệt kê toàn bộ thông số kỹ thuật thực tế đang kết nối:
   * **Server Name**: `192.168.11.51,2222`
   * **Authentication Type**: `Windows Authentication`
   * **User Name**: `VIETINSOFT\Y.Thach`
   * **Network Protocol**: `TCP/IP`

---

### 🔹 CÁCH 3: MẸO "BẤT TỬ" CỦA DÂN PRO — DÙNG CÔNG CỤ WINDOWS UDL (DATA LINK)

Đây là mẹo nhanh nhất trên Windows mà các lập trình viên kỳ cựu hay dùng để máy tính **tự động sinh ra 100% chuỗi Connection String chuẩn xác** mà không cần nhớ cú pháp:

1. Ra màn hình Desktop, nhấp chuột phải $\rightarrow$ chọn **New** $\rightarrow$ **Text Document**.
2. Đổi tên file từ `New Text Document.txt` thành **`test.udl`** *(Lưu ý: phải đổi cả đuôi `.txt` thành `.udl`)*.
3. Nhấp đúp chuột vào file `test.udl` vừa tạo $\rightarrow$ Một hộp thoại GUI của Windows tên là **Data Link Properties** sẽ hiện lên:
   * **Tab Provider**: Chọn `Microsoft OLE DB Driver for SQL Server` (hoặc `Microsoft OLE DB Provider for SQL Server`). Bấm *Next*.
   * **Tab Connection**:
     * Mục 1 (Server name): Gõ vào `192.168.11.51,2222`
     * Mục 2: Chọn `Use Windows NT Integrated security`
     * Mục 3: Nhấp vào ô chọn Database, danh sách các DB trên server sẽ tự động xổ xuống $\rightarrow$ Bạn chỉ việc chọn **`Vietinsoft_ForTest_Tai2`**.
     * Bấm nút **Test Connection** $\rightarrow$ Hiện thông báo: *"Test connection succeeded!"* (Kết nối thành công!).
4. Bấm **OK** để đóng hộp thoại.
5. Bây giờ, bạn nhấp chuột phải vào file `test.udl` $\rightarrow$ Chọn **Open with** $\rightarrow$ Chọn **Notepad**.
6. 👉 Bạn sẽ thấy Windows đã **tự động viết sẵn toàn bộ chuỗi Connection String** trong file Notepad đó! Bạn chỉ việc copy dùng ngay!

---

## 3. BẢNG ĐỐI CHIẾU CÁC TỪ KHÓA TRONG CONNECTION STRING

Các ngôn ngữ lập trình khác nhau có thể dùng các từ khóa hơi khác nhau, nhưng bản chất đều là một:

| Ý nghĩa | Cách viết kiểu 1 (Hiện đại / Phổ biến) | Cách viết kiểu 2 (Kinh điển / ADO.NET) | Giá trị thực tế trên máy bạn |
| :--- | :--- | :--- | :--- |
| **Địa chỉ máy chủ & Cổng** | `Server=...` | `Data Source=...` | `192.168.11.51,2222` |
| **Tên Database** | `Database=...` | `Initial Catalog=...` | `Vietinsoft_ForTest_Tai2` |
| **Xác thực Windows** | `Integrated Security=True;` | `Trusted_Connection=True;` | Dùng tài khoản `VIETINSOFT\Y.Thach` |
| **Bỏ qua lỗi chứng chỉ SSL** | `TrustServerCertificate=True;` | `TrustServerCertificate=True;` | Bắt buộc có khi server nội bộ không mua chứng chỉ SSL công cộng |
| **Thời gian chờ tối đa (giây)**| `Connection Timeout=30;` | `Connect Timeout=30;` | Mặc định 15 - 30 giây |

---

## 4. TỔNG HỢP CÁC MẪU CONNECTION STRING DÙNG NGAY TRONG DỰ ÁN

### 📝 Mẫu 1: Dùng cho file cấu hình C# Backend (`web.config` hoặc `appsettings.json`)

Trong file `web.config` của ứng dụng ASP.NET:
```xml
<connectionStrings>
  <add name="ParadiseHRM_DB" 
       connectionString="Data Source=192.168.11.51,2222;Initial Catalog=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

---

### 📝 Mẫu 2: Dùng cho PowerShell / Script Automation trên Windows (Máy bạn)

Đoạn code kết nối trực tiếp trong PowerShell:
```powershell
$connectionString = "Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$conn.Open()
Write-Host "Da ket noi thanh cong toi Database: " $conn.Database
$conn.Close()
```

---

### 📝 Mẫu 3: Dùng cho Node.js / JavaScript (Thư viện `mssql`)

Nếu sau này bạn tích hợp truy vấn DB trực tiếp vào bộ kiểm thử Playwright (`tests/`):
```javascript
const sql = require('mssql');

const config = {
  server: '192.168.11.51',
  port: 2222,
  database: 'Vietinsoft_ForTest_Tai2',
  options: {
    trustedConnection: true,        // Sử dụng Windows Authentication
    trustServerCertificate: true,  // Bỏ qua SSL check
    enableArithAbort: true
  }
};

async function queryDatabase() {
  let pool = await sql.connect(config);
  let result = await pool.request().query('SELECT TOP 5 * FROM tblCustomer');
  console.log(result.recordset);
  await pool.close();
}
```

---

### 📝 Mẫu 4: Dùng khi có tài khoản SQL Authentication (User/Password riêng)

Nếu sau này sếp cấp cho bạn một tài khoản SQL riêng (ví dụ: user `thach_qc`, pass `Vietinsoft@2026`) thay vì Windows Auth:
```text
Server=192.168.11.51,2222;Database=Vietinsoft_ForTest_Tai2;User Id=thach_qc;Password=Vietinsoft@2026;TrustServerCertificate=True;
```

---

## PHẦN 2: CÁCH NHẬN BIỆN & TÌM KIẾM 3 LOẠI STORED PROCEDURE TRONG DATABASE
### (HTML UI vs TRUY VẤN DỮ LIỆU vs LOGIC BACKEND)

Trong một cơ sở dữ liệu lớn có hàng nghìn Stored Procedure như `Vietinsoft_ForTest_Tai2`, hệ thống tuân theo **quy tắc đặt tên 3 tầng bất biến** sau đây:

---

### 1. BẢNG NHẬN DIỆN 3 LOẠI STORED PROCEDURE THEO TÊN GỌI & CHỨC NĂNG

| Loại Stored Procedure | Dấu hiệu nhận biết trong tên | Ví dụ thực tế trong DB `Vietinsoft_ForTest_Tai2` | Bên trong ruột code SQL chứa gì? |
| :--- | :--- | :--- | :--- |
| **1. SP chứa HTML UI<br>(Giao diện Form/Popup)** | Luôn kết thúc bằng đuôi:<br>👉 **`..._html`** | • `sp_CRM_CreateCustomer_html`<br>• `sp_CRM_CustomerDetail_html`<br>• `sp_CRM_CreateLead_html`<br>• `ALLOWANCE_LIST_html` | • Chứa các chuỗi HTML: `'<div ...>'`, `'<form ...>'`.<br>• Cấu hình các widget DevExtreme: `dxTextBox`, `dxSelectBox`.<br>• Dòng kết thúc luôn là: `SELECT @html AS html;` |
| **2. SP truy vấn dữ liệu<br>(Đổ dữ liệu lên bảng / Dropdown)** | Chứa các từ:<br>👉 **`..._List`**<br>👉 **`..._Detail`**<br>👉 **`..._Get...`**<br>*(hoặc trùng tên với SP UI nhưng KHÔNG CÓ đuôi `_html`)* | • `sp_CRM_CustomerDetail`<br>• `sp_CRM_CompanyDetail`<br>• `sp_CRM_ContractDetailTypeList`<br>• `ALLOWANCE_LIST` | • Chứa các lệnh: `SELECT ... FROM ... WHERE ...`<br>• Thực hiện nối bảng (JOIN), sắp xếp (ORDER BY), lọc dữ liệu (WHERE) để trả về mảng dữ liệu JSON cho DataGrid hoặc combobox. |
| **3. SP chứa Logic Backend<br>(Kiểm tra & Ghi dữ liệu)** | Bắt đầu bằng các động từ hành động:<br>👉 **`Create...`**, **`Add...`**<br>👉 **`Update...`**, **`Delete...`**<br>👉 **`Approve...`**, **`Cancel...`**<br>👉 **`Check...`**, **`AfterSave...`** | • `sp_CRM_CreateCustomer`<br>• `sp_CRM_CreateLead`<br>• `sp_CRM_ApproveSalesRequest`<br>• `sp_CRM_CheckValidContract`<br>• `ALLOWANCE_UPDATE` | • Kiểm tra ràng buộc hợp lệ: `IF ... RAISERROR(...)`.<br>• Quản lý giao dịch: `BEGIN TRANSACTION ... COMMIT`.<br>• Ghi vào ổ cứng: `INSERT INTO`, `UPDATE`, `DELETE`.<br>• Công thức tính toán lương, KPI, hoa hồng. |

---

### 2. VÍ DỤ "BỘ 3 SONG HÀNH" CỦA MỘT CHỨC NĂNG

Mỗi chức năng trên web thường đi theo một bộ 3 Stored Procedure phối hợp khép kín:
1. `sp_CRM_CreateCustomer_html` $\rightarrow$ **Sinh ra giao diện Popup** Thêm khách hàng cho Chrome.
2. `sp_CRM_CustomerDetail` $\rightarrow$ **Lấy dữ liệu chi tiết** khách hàng đổ vào các ô trên popup.
3. `sp_CRM_CreateCustomer` $\rightarrow$ **Logic Backend**: Kiểm tra trùng số điện thoại, ghi dòng khách hàng mới vào bảng `tblCustomer`.

---

### 3. CÁCH TÌM CHÍNH XÁC STORED PROCEDURE BẠN CẦN TRONG SSMS

#### Cách 1: Bắt trực tiếp trên Chrome DevTools (Nhanh & Chuẩn 100%)
1. Mở Chrome, bấm `F12` $\rightarrow$ chuyển sang tab **Network (Mạng)** $\rightarrow$ chọn bộ lọc **Fetch/XHR**.
2. Click mở một Popup trên web $\rightarrow$ Nhìn vào request vừa gửi:
   * Nếu thấy gọi `sp_..._html` $\rightarrow$ Đó chính là Stored Procedure sinh giao diện!
3. Điền thông tin và bấm nút "Lưu" $\rightarrow$ Nhìn request tiếp theo:
   * Sẽ thấy ngay tên Stored Procedure Backend (ví dụ: `sp_CRM_Create...`)!

#### Cách 2: Tìm kiếm bằng câu lệnh SQL trong SSMS (Dân Pro hay dùng)
Mở cửa sổ **New Query** trong SSMS và thực thi các câu lệnh sau:

* **Tìm tất cả các SP sinh HTML giao diện**:
  ```sql
  SELECT ROUTINE_NAME 
  FROM INFORMATION_SCHEMA.ROUTINES 
  WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME LIKE '%_html'
  ORDER BY ROUTINE_NAME;
  ```

* **Tìm xem SP nào đang thao tác trên bảng khách hàng (`tblCustomer`)**:
  ```sql
  SELECT DISTINCT o.name AS StoredProcedureName
  FROM sys.sql_modules m 
  JOIN sys.objects o ON m.object_id = o.object_id 
  WHERE m.definition LIKE '%tblCustomer%'
  ORDER BY o.name;
  ```

* **Xem nhanh toàn bộ nội dung code của 1 Stored Procedure**:
  ```sql
  EXEC sp_helptext 'sp_CRM_CreateCustomer_html';
  ```

---

### 4. CÁCH MỞ XEM VÀ SỬA STORED PROCEDURE TRÊN GUI SSMS

1. Trong cửa sổ **Object Explorer** bên trái:  
   Mở rộng `Vietinsoft_ForTest_Tai2` $\rightarrow$ `Programmability` $\rightarrow$ `Stored Procedures`.
2. Tìm đến SP bạn muốn xem (ví dụ: `sp_CRM_CreateCustomer_html`).
3. Nhấp **chuột phải** vào SP đó $\rightarrow$ Chọn **Modify**  
   *(Hoặc chọn: `Script Stored Procedure as` $\rightarrow$ `ALTER To` $\rightarrow$ `New Query Editor Window`)*.
4. Cửa sổ code T-SQL sẽ hiện ra toàn bộ nội dung của SP đó để bạn đọc và sửa.
5. Sửa xong, nhấn phím **F5 (Execute)**: Mã nguồn mới sẽ được ghi đè vào Database ngay lập tức!

---

## PHẦN 3: BẢN CHẤT LƯU TRỮ STORED PROCEDURE & SỰ THẬT VỀ CÁC FILE `.sql`

### 1. BẢN CHẤT: TRONG DATABASE KHÔNG HỀ CÓ "FILE" NÀO CẢ!

* Trong lập trình phần mềm thông thường (C#, JavaScript, Python), mã nguồn được lưu thành từng file văn bản riêng lẻ (`.cs`, `.js`, `.py`) nằm trong các thư mục trên ổ cứng.
* **Nhưng trong SQL Server**:
  * Tất cả các Stored Procedure **KHÔNG LƯU THÀNH FILE RIÊNG LẺ** trên máy bạn.
  * Chúng được lưu trực tiếp dưới dạng **dữ liệu nhị phân bên trong Database** (cụ thể là nằm trong một bảng hệ thống ngầm có tên là `sys.sql_modules` bên trong file dữ liệu `.mdf` trên máy chủ `192.168.11.51`).
  * Mỗi Stored Procedure là một **"Đối tượng độc lập" (Database Object)**, có tên riêng biệt, tồn tại song song với nhau.
* Khi bạn mở SSMS bấm xem một Stored Procedure: SSMS chỉ đang **kéo đoạn văn bản code đó từ ruột Database ra hiển thị tạm lên màn hình** để bạn xem và sửa.

---

### 2. ẨN DỤ KINH ĐIỂN: FILE `.sql` GIỐNG NHƯ FILE CÀI ĐẶT `Setup.exe`

```
[File script.sql trên laptop của bạn]
(Chỉ là file văn bản chứa câu lệnh: CREATE PROCEDURE...)
               │
               │ Bạn bấm F5 (Execute) trên SSMS
               ▼
[MÁY CHỦ DATABASE 192.168.11.51]
• Máy chủ đọc các dòng chữ trong file.
• Nó "nhập hộ khẩu" Stored Procedure đó vào Database.
• Lưu vĩnh viễn vào file dữ liệu vật lý (.mdf).
               │
               ▼
Lúc này, bạn CÓ XÓA HẲN file script.sql trên laptop đi,
Stored Procedure trên máy chủ VẪN SỐNG 100% VÀ HOẠT ĐỘNG BÌNH THƯỜNG!
```

---

### 3. KỊCH BẢN LÀM VIỆC THỰC TẾ: FILE `.sql` LÀ "GIẤY NHÁP CÁ NHÂN"

1. **Bạn (Y.Thach) ngồi ở máy tính của mình**:
   * Mở SSMS, nhấn `Ctrl + N` mở một tab trắng.
   * Viết câu lệnh tạo một Stored Procedure:
     ```sql
     CREATE PROCEDURE sp_TinhHoaHong_Thach ...
     ```
   * Bạn bấm **`F5` (Execute)**.
   * Chạy xong, bạn **bấm dấu X tắt luôn cái tab đó đi (chọn No - không thèm lưu file `.sql` làm gì cả)**!

2. **Anh Chiến (hoặc đồng nghiệp) ngồi ở máy tính bên cạnh**:
   * Mở SSMS trên máy tính của anh ấy, kết nối vào máy chủ `192.168.11.51`.
   * Mở Database `Vietinsoft_ForTest_Tai2` $\rightarrow$ Mở mục `Stored Procedures`.
   * 👉 **Anh Chiến nhìn thấy ngay lập tức `sp_TinhHoaHong_Thach` của bạn!**
   * Anh Chiến nhấp chuột phải vào đó, chọn **Modify** $\rightarrow$ **Toàn bộ từng dòng code bạn vừa viết hiện ra trước mắt anh ấy nguyên vẹn 100%!**

👉 **KẾT LUẬN CỐT LÕI**:
* Các tab gõ code hay các file `.sql` lưu trên máy tính của mỗi nhân viên thực chất chỉ là **"TỜ GIẤY NHÁP CÁ NHÂN"**.
* Khi bạn tạo xong SP thì file `.sql` đó không lưu trên server, người khác remote vào cũng không thấy file đó.
* **Máy chủ Database mới là Kho trung tâm chứa sự thật duy nhất (Single Source of Truth)**. Không cần gửi file `.sql` cho nhau, mọi người đều làm việc chung trên một Database tập trung!

> 💡 **Khi nào thì NÊN lưu lại file `.sql`?**
> * Khi tạo/sửa Stored Procedure: **Không cần lưu** file `.sql` (vì code đã nằm trong DB).
> * Khi bạn viết một câu lệnh `SELECT` truy vấn báo cáo rất dài (nối 10 bảng, 200 dòng để trích xuất số liệu đối chiếu): **NÊN bấm `Ctrl + S` lưu lại file `.sql` trên máy mình**, để lần sau cần dùng thì chỉ việc mở ra bấm `F5`, không mất công gõ lại từ đầu!

---

## PHẦN 4: HƯỚNG DẪN VIẾT STORE MỚI & BỘ PHÍM TẮT THAO TÁC SIÊU TỐC TRÊN SSMS

### 1. CHỖ VIẾT STORED PROCEDURE MỚI NẰM Ở ĐÂU?

1. Mở SSMS $\rightarrow$ Nhấn tổ hợp phím **`Ctrl + N`** (mở một tab soạn thảo trắng tinh - New Query).
2. Đảm bảo ô chọn Database ở góc trên bên trái đang chọn đúng **`Vietinsoft_ForTest_Tai2`**.
3. Viết cú pháp tạo Store:
   ```sql
   CREATE PROCEDURE sp_TestThach
   AS
   BEGIN
       SELECT 'Xin chao Vietinsoft' AS ThongBao;
   END
   ```
4. Nhấn phím **`F5` (Execute)** $\rightarrow$ Hệ thống báo: *"Commands completed successfully!"*.
5. 👉 Stored Procedure đã được nạp vĩnh viễn vào Database trên máy chủ. Tắt tab đi không cần lưu file `.sql`!

---

### 2. BÍ KÍP TÌM & SỬA STORED PROCEDURE TRONG 3 GIÂY (KHÔNG CUỘN CHUỘT)

Khi Database có hơn **2.000 Stored Procedure**, tuyệt đối không cuộn chuột tìm bằng mắt. Hãy dùng 3 tuyệt chiêu sau:

#### ⚡ Tuyệt chiêu 1: Dùng Bộ Lọc "Chiếc Phễu" trên Object Explorer
1. Trong cây thư mục bên trái: Click chọn thư mục **`Stored Procedures`**.
2. Nhìn lên trên thanh công cụ Object Explorer, bấm vào biểu tượng **Chiếc Phễu (Filter Settings)**  
   *(hoặc chuột phải vào `Stored Procedures` $\rightarrow$ `Filter` $\rightarrow$ `Filter Settings`)*.
3. Ở dòng **Name**, chọn `Contains` (Chứa) và gõ từ khóa: ví dụ `CreateCustomer`. Bấm **OK**.
4. Danh sách 2.000 SP thu gọn lại chỉ còn đúng 2 - 3 SP liên quan!  
5. Nhấp **chuột phải vào SP đó $\rightarrow$ bấm phím `M` (Modify)** để mở code sửa ngay!

#### ⚡ Tuyệt chiêu 2: Dùng lệnh `sp_helptext` trong tab Query
Khi đã biết tên SP:
1. Bấm **`Ctrl + N`** mở tab mới.
2. Gõ dòng sau và bấm **`F5`**:
   ```sql
   EXEC sp_helptext 'sp_CRM_CreateCustomer_html';
   ```
3. Toàn bộ ruột code của SP sẽ in ra ngay bên dưới.

#### ⚡ Tuyệt chiêu 3: Cài phím tắt "1 nốt nhạc" trong SSMS (Dân Pro ai cũng cài)
1. Trên menu SSMS: Chọn **`Tools`** $\rightarrow$ **`Options`**.
2. Chọn mục: **`Environment`** $\rightarrow$ **`Keyboard`** $\rightarrow$ **`Query Shortcuts`**.
3. Tìm dòng phím tắt **`Ctrl + 3`** (hoặc `Ctrl + 4`, `Ctrl + F1`).
4. Ở cột bên cạnh, gõ vào chữ: **`sp_helptext`** $\rightarrow$ Bấm **OK**.
5. 👉 **Từ nay về sau**: Ở bất kỳ cửa sổ Query nào, bạn chỉ cần gõ tên SP (ví dụ: `sp_CRM_CreateCustomer`), **bôi đen tên đó $\rightarrow$ nhấn phím `Ctrl + 3`**, toàn bộ code của SP đó tự động bung ra màn hình trong tích tắc!

---

### 3. BỘ PHÍM TẮT VÀNG KHI LÀM VIỆC VỚI SQL TRÊN SSMS

| Phím tắt | Tác dụng cực kỳ hữu ích |
| :--- | :--- |
| **`F5`** (hoặc **`Ctrl + E`**) | **Thực thi (Execute)**: Chạy câu lệnh SQL hoặc lưu code `ALTER PROCEDURE` vào Database ngay lập tức. |
| **`Ctrl + F5`** | **Kiểm tra lỗi cú pháp (Parse)**: Kiểm tra xem code có viết sai chính tả, thiếu ngoặc `)` không mà **chưa thực thi**. Rất an toàn! |
| **Bôi đen đoạn code + `F5`** | **Chạy cục bộ**: Chỉ chạy riêng đúng đoạn code bạn đang bôi đen (không chạy cả file). |
| **`Ctrl + K, Ctrl + C`** | **Comment nhanh**: Đặt dấu `--` khóa đoạn code đang chọn lại. |
| **`Ctrl + K, Ctrl + U`** | **Mở Comment**: Bỏ dấu khóa `--` của đoạn code. |
| **`Ctrl + R`** | **Ẩn / Hiện bảng kết quả**: Thu gọn bảng kết quả bên dưới để mở rộng không gian nhìn code. |
| **`Ctrl + H`** | **Tìm và Thay thế (Find & Replace)**: Thay thế hàng loạt tên biến, tên cột trong code. |

---

### PHẦN 5: QUY TRÌNH CHUẨN 5 BƯỚC: FIX BUG TỪ BẤM F1 TRÊN CHROME ĐẾN SỬA DB VÀ NGHIỆM THU

Dưới đây là quy trình thực hành chuẩn xác từng cú click chuột giúp bạn tự tin mở xem code của bất kỳ Stored Procedure nào, sửa đổi và đưa vào hoạt động ngay trên hệ thống:

```
[BƯỚC 1: TRÊN CHROME]            [BƯỚC 2: PHÂN LOẠI]           [BƯỚC 3: MỞ SSMS]          [BƯỚC 4: SỬA & LƯU]        [BƯỚC 5: NGHIỆM THU]
Nhấn F1 + F12             ──►  Lỗi Giao diện (HTML)     ──►  Lọc tìm đúng SP     ──►  Modify code         ──►  Quay lại Chrome
Lấy Tên SP & API lỗi            hay Lỗi Logic (Data API)        (Database Tai2)         Ctrl+F5 -> F5              Ctrl+F5 kiểm tra lại
```

---

### 📌 BƯỚC 1: "BẮT BỆNH" TRÊN TRÌNH DUYỆT CHROME (`F12` + `F1`)

Khi bạn đang đứng ở màn hình bị lỗi (ví dụ: màn hình *Tổng quan CRM*):

1. **Bấm `F12` trước (Mở Chrome DevTools)**:
   * Chuyển sang tab **Console**: Xem có dòng chữ đỏ nào báo lỗi JavaScript không.
   * Chuyển sang tab **Network** $\rightarrow$ Bấm nút lọc **`Fetch/XHR`**: Nhìn xem khi bạn bấm nút hoặc load trang, có request nào bị đỏ `500 Internal Server Error` không. Bấm vào dòng đỏ đó xem tab **Response** để đọc câu thông báo lỗi của SQL Server (ví dụ: *Incorrect syntax near ')'* hoặc *Invalid column name...*).
2. **Bấm phím `F1` (Mở Menu Inspector của hệ thống)**:
   * Chiếc Popup màu xanh lá sẽ hiện ra. Bạn ghi chép lại **3 thông tin sống còn**:
     * **`MenuID`**: Ví dụ `MnuKPI001`.
     * **`Tên thủ tục` (Tên SP trang chủ)**: Ví dụ `sp_CRMDashboard`.
     * **`Danh sách các API được sử dụng`**: Danh sách toàn bộ các Stored Procedure con mà trang này gọi (ví dụ: `sp_CRM_RecalculateKPI`, `sp_KPIgetEmailListCompany`...).

---

### 📌 BƯỚC 2: PHÂN LOẠI XEM CON BUG NẰM Ở ĐÂU?

Từ thông tin ở Bước 1, bạn xác định ngay SP mục tiêu cần mở:

* **Trường hợp A — Lỗi Giao diện (UI / Chữ / Bố cục)**:
  * *Triệu chứng*: Sai chính tả chữ tiếng Việt, sai màu sắc, thiếu ô nhập liệu, lỗi vỡ khung popup.
  * 👉 **Đích đến**: Tìm Stored Procedure có đuôi **`..._html`** (ví dụ: `sp_CRMDashboard_html` hoặc `sp_CRM_CreateLead_html`).
* **Trường hợp B — Lỗi Dữ liệu / Nghiệp vụ (Data / Logic / Tính toán)**:
  * *Triệu chứng*: Bấm nút Lưu báo lỗi đỏ, bảng DataGrid không hiện bản ghi nào, tính sai tổng doanh số, lọc ngày tháng bị mất dữ liệu.
  * 👉 **Đích đến**: Tìm Stored Procedure nghiệp vụ nằm trong danh sách API của Popup F1 (ví dụ: `sp_CRM_CustomerList`, `sp_CRM_SaveConfigKPI`...).

---

### 📌 BƯỚC 3: MỞ SSMS VÀ TÌM ĐÚNG STORED PROCEDURE ĐÓ

1. Trong cây thư mục **Object Explorer** bên trái:  
   Mở rộng `Databases` $\rightarrow$ `Vietinsoft_ForTest_Tai2` $\rightarrow$ `Programmability` $\rightarrow$ `Stored Procedures`.
2. **Mẹo tìm SP siêu tốc trong 3 giây (Dùng Filter)**:
   * Click chuột phải vào thư mục `Stored Procedures` $\rightarrow$ Chọn **`Filter`** $\rightarrow$ **`Filter Settings...`**.
   * Dòng **`Name`**: Chọn `Contains`, gõ tên SP bạn vừa lấy từ F1 (ví dụ: gõ `sp_CRM_` hoặc tên cụ thể).
   * Bấm **`OK`** $\rightarrow$ SSMS sẽ giấu hết các SP khác, chỉ hiện đúng SP bạn cần tìm!

---

### 📌 BƯỚC 4: MỞ CỬA SỔ SỬA CODE, SỬA LOGIC & LƯU LẠI VÀO DATABASE

1. **Mở mã nguồn SP ra sửa**:
   * Nhấp **chuột phải** vào SP đó $\rightarrow$ Chọn **`Modify`** *(hoặc chọn `Script Stored Procedure as` $\rightarrow$ `ALTER To` $\rightarrow$ `New Query Editor Window`)*.
   * SSMS sẽ tự động mở một tab query có sẵn lệnh:
     ```sql
     ALTER PROCEDURE [dbo].[sp_CRM_CreateCustomer_html]
         @Param1 NVARCHAR(50),
         @Param2 INT
     AS
     BEGIN
         SET NOCOUNT ON;

         -- ============================================================
         -- 👉 BẠN CHỈ SỬA ĐOẠN CODE NẰM TRONG KHỐI NÀY (GIỮA BEGIN VÀ END)
         -- Sửa thẻ HTML, sửa câu lệnh SELECT/UPDATE, thêm điều kiện WHERE...
         -- ============================================================

     END
     ```
2. **Tiến hành sửa logic**:
   * **Nguyên tắc vàng tiếng Việt (như Câu 24)**: Mọi chuỗi gán có dấu tiếng Việt bắt buộc phải có chữ `N` phía trước: `N'Nội dung sửa'`.
3. **Kiểm tra và Thực thi (2 phím tắt sống còn: Phân biệt `Ctrl + F5` vs `F5`)**:

   * **Bước 4.1: Bấm `Ctrl + F5` (Parse — "Duyệt lỗi chính tả trong bộ nhớ")**:
     * **Bản chất**: SQL Server chỉ đọc lướt qua đoạn code trên màn hình để kiểm tra xem có thiếu dấu phẩy `,`, dấu ngoặc `)` hay lỗi chính tả từ khóa không.
     * **Quan trọng**: `Ctrl + F5` **HOÀN TOÀN CHƯA THAY ĐỔI GÌ TRONG DATABASE**! Database trên máy chủ vẫn giữ nguyên phiên bản cũ. Giống như viết đơn nháp nhờ đồng nghiệp kiểm tra lỗi chính tả chứ chưa nộp cho Sếp.
     * Nếu thấy dòng chữ xanh: *"Command(s) completed successfully"* $\rightarrow$ Cú pháp an toàn 100%!

   * **Bước 4.2: Bấm `F5` (Execute — "Chính thức áp dụng và lưu đè vào Database")**:
     * **Bản chất**: Khi câu lệnh bắt đầu bằng `ALTER PROCEDURE ...`, việc bấm **`F5`** sẽ chỉ thị SQL Server chính thức lấy toàn bộ mã mới **ghi đè vĩnh viễn vào Database** trên máy chủ `192.168.11.51`!
     * 🚨 **CẠM BẪY CHÍ MẠNG**: Tuyệt đối không được chỉ bấm `Ctrl + S` rồi tắt máy! `Ctrl + S` chỉ là lưu file nháp ra laptop! Bắt buộc phải bấm **`F5`** (hoặc nút **`! Execute`**) để thực thi lệnh `ALTER`.
     * Nhìn xuống cửa sổ Messages bên dưới, thấy dòng chữ:  
       👉 **`Commands completed successfully.`**
     * Lúc này, phiên bản SP mới chính thức có hiệu lực trên toàn bộ hệ thống ngay tức thì!

   * 💡 **BÀI HỌC THỰC TẾ KINH ĐIỂN: Lỗi vô tình gõ phím cách trong tên biến (Case Study `@LoginI D`)**:
     * *Hiện tượng*: Khi mở SP ra sửa, trước đó SP vẫn chạy bình thường nhưng khi bấm chạy lại thì văng ra 5 lỗi đỏ:
       * `Incorrect syntax near '('. Expecting ')', ',', AS, FOR, or WITH.`
       * `Must declare the scalar variable "@LoginID".`
     * *Nguyên nhân*: Trong lúc thao tác phím, tay vô tình chạm phím Space làm tên biến bị xé toạc: `@LoginI D VARCHAR(50)` thay vì `@LoginID VARCHAR(50)`. SQL Server đọc thấy `@LoginI` là tưởng hết tên biến, chữ `D` đứng trơ trọi làm đứt gãy toàn bộ cấu trúc tham số!
     * *Khắc phục*: Xóa dấu cách thừa $\rightarrow$ sửa về `@LoginID VARCHAR(50)` $\rightarrow$ bấm `Ctrl + F5` thấy sạch lỗi đỏ $\rightarrow$ bấm `F5` lưu vào DB!

---

### 🌐 BƯỚC 5: KIỂM CHỨNG TRỰC TIẾP TRÊN CHROME

Vì hệ thống Paradise HRM dùng kiến trúc Universal Gateway gọi động trực tiếp Stored Procedure, bạn **KHÔNG CẦN khởi động lại máy chủ Web IIS**:

1. **Quay lại cửa sổ Chrome**:
   * Nếu là sửa **Stored Procedure API / Dữ liệu** (`sp_...List`, `sp_...Save`): Bạn chỉ việc bấm lại nút thao tác trên web (bấm nút Lọc, hoặc bấm nút Lưu), Chrome sẽ gửi API lên và nhận ngay kết quả mới vừa sửa trong SQL Server!
   * Nếu là sửa **Stored Procedure Giao diện** (`sp_..._html`): Bấm tổ hợp phím **`Ctrl + F5`** trên Chrome (Hard Refresh - Xóa sạch cache trình duyệt) để Chrome tải lại khung giao diện mới nhất.
2. **Kiểm tra tab DevTools (`F12`)**:
   * Request API báo `200 OK` màu xanh.
   * Dữ liệu trên bảng DataGrid hiển thị đúng.
   * Bug đã được fix triệt để!

---

*Tài liệu này được biên soạn chuẩn hóa để bạn làm chủ toàn bộ quy trình từ Kết nối $\rightarrow$ Tìm kiếm $\rightarrow$ Đọc hiểu $\rightarrow$ Chỉnh sửa $\rightarrow$ Vận hành Stored Procedure trên SSMS.*
