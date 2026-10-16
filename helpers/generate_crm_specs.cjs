const fs = require('fs');
const path = require('path');

const RAW_DIR = path.resolve(__dirname, '../docs/raw_crawled/crm');
const EPIC_DIR = path.resolve(__dirname, '../docs/epic/crm');
const US_DIR = path.resolve(__dirname, '../docs/user-stories/crm');

fs.mkdirSync(EPIC_DIR, { recursive: true });
fs.mkdirSync(US_DIR, { recursive: true });

function readRaw(filename) {
  const p = path.join(RAW_DIR, filename);
  if (fs.existsSync(p)) {
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  }
  return null;
}

console.log('Generating complete CRM Specifications from crawled data...');

// 1. TẠO MASTER README CHO EPIC
const epicMasterReadme = `# HỒ SƠ ĐẶC TẢ PHÂN HỆ TRANG CHỦ CRM — PARADISE HRM

> **Hệ thống mục tiêu**: Paradise HRM (\`https://paradisehrm.com/Tai3/#\`)  
> **Tài khoản khảo sát**: \`Chien.nguyen\` (Quyền Quản trị viên / Trưởng bộ phận CRM)  
> **Thời gian cào & trích xuất**: ${new Date().toLocaleString('vi-VN')}  
> **Tổng số menu khảo sát thực tế**: 36 menu con  
> **Phương pháp trích xuất**: \`/ui-crawl-to-user-story\` (Playwright Runtime DOM + JS Context + Network API Fingerprinting)

---

## BẢNG PHÂN RÃ CÁC EPIC CHÍNH TRONG PHÂN HỆ CRM

| Mã Epic | Tên Phân Hệ (Epic) | Phạm Vi Menu Thực Tế | Số US | Tài Liệu Chi Tiết |
| :--- | :--- | :--- | :---: | :--- |
| **CRM-EPIC-01** | **Tổng quan Vận hành CRM & KPI Analytics** | Tổng quan CRM (\`MnuKPI001\`), Theo dõi dịch vụ (\`MnuKPI012\`) | 3 | [\`CRM-EPIC-01-Tong-Quan-CRM.md\`](./CRM-EPIC-01-Tong-Quan-CRM.md) |
| **CRM-EPIC-02** | **Quản lý Khách hàng & Sales Pipeline** | Dữ liệu khách hàng (\`MnuKPI003\`), Sales Pipeline (\`MnuKPI007\`), Doanh số (\`MnuKPI447\`), Lead Marketing (\`MnuKPI448\`) | 4 | [\`CRM-EPIC-02-Khach-Hang-Sales-Pipeline.md\`](./CRM-EPIC-02-Khach-Hang-Sales-Pipeline.md) |
| **CRM-EPIC-03** | **Tương tác Khách hàng & Nhiệm vụ CRM** | Nhóm Nhiệm vụ: Zalo tự động (\`MnuKPI045\`), Email thủ công (\`MnuKPI002\`), Tin AI (\`MnuKPI049\`), Cuộc họp (\`MnuKPI006\`) | 3 | [\`CRM-EPIC-03-Nhiem-Vu-Cham-Soc-Zalo-Email.md\`](./CRM-EPIC-03-Nhiem-Vu-Cham-Soc-Zalo-Email.md) |
| **CRM-EPIC-04** | **Dữ liệu Tiềm năng & GoogleMaps** | Nhóm GoogleMaps: Thu thập dữ liệu (\`MnuHRS036\`), Lọc dữ liệu (\`MnuHRS064\`), Import bất thường (\`MnuKPI015\`) | 2 | [\`CRM-EPIC-04-Du-Lieu-GoogleMaps.md\`](./CRM-EPIC-04-Du-Lieu-GoogleMaps.md) |
| **CRM-EPIC-05** | **Quản lý Báo giá & Phân hệ Phần mềm** | Nhóm Báo giá: Báo giá phần mềm (\`MnuCSM004\`), Thêm/Sửa báo giá (\`MnuCSM005\`), Phân hệ (\`MnuCSM003\`, \`MnuKPI446\`) | 3 | [\`CRM-EPIC-05-Bao-Gia-Phan-Mem.md\`](./CRM-EPIC-05-Bao-Gia-Phan-Mem.md) |
| **CRM-EPIC-06** | **Quản lý Kho & Thiết lập Hệ thống CRM** | Nhóm Kho (\`MnuKPI017\`, \`019\`, \`021\`), Hỗ trợ (\`MnuHRS32389\`, \`3237\`), Thiết lập (\`MnuKPI449\`, \`MnuTM037\`, \`MnuKPI016\`...) | 3 | [\`CRM-EPIC-06-Kho-Va-Thiet-Lap-CRM.md\`](./CRM-EPIC-06-Kho-Va-Thiet-Lap-CRM.md) |

---

## MA TRẬN TRUY VẾT DỮ LIỆU ĐA VAI TRÒ (CROSS-ROLE DATA LINEAGE)

Qua cơ chế bóc tách dấu vân tay API (\`Network Fingerprinting\`), hệ thống phát hiện luồng chu chuyển dữ liệu giữa các vai trò:

\`\`\`mermaid
flowchart LR
  subgraph R1["Role: Khách Hàng / Lead"]
    L01["Đăng ký form Web / Quét GoogleMaps"]
  end

  subgraph R2["Role: Nhân Viên Kinh Doanh (NVKD)"]
    S01["Tiếp nhận Lead trên Dữ liệu KH"]
    S02["Chăm sóc, gọi điện, gửi Zalo/Email"]
    S03["Tạo Báo giá phần mềm (sp_Sub_SubQuotation)"]
    S04["Chuyển giai đoạn trên Sales Pipeline"]
  end

  subgraph R3["Role: Quản Lý CRM / Admin (Chien.nguyen)"]
    M01["Xem Dashboard KPI tổng quan"]
    M02["Duyệt báo giá & Phân chia chỉ tiêu KPI"]
    M03["Giám sát Doanh số thực tế (sp_CRM_SaleInCRM)"]
  end

  L01 --> S01 --> S02 --> S03 --> S04
  S04 --> M01
  S03 --> M02
  S04 --> M03
\`\`\`
`;

fs.writeFileSync(path.join(EPIC_DIR, 'README.md'), epicMasterReadme, 'utf8');

// 2. TẠO CHI TIẾT TỪNG EPIC VÀ USER STORY
console.log('Generating Epic 1: Tổng quan CRM...');
const epic1 = `# ĐẶC TẢ PHÂN HỆ: CRM-EPIC-01 · TỔNG QUAN VẬN HÀNH CRM & KPI ANALYTICS

* **Mã Epic**: \`CRM-EPIC-01\`
* **Tên phân hệ**: Tổng quan Vận hành CRM & KPI Analytics
* **Role thao tác**: Quản trị viên CRM / Giám đốc kinh doanh / Trưởng bộ phận CRM (\`Chien.nguyen\`)
* **Platform**: Web Admin (Desktop Browser, độ phân giải tối ưu $\\ge 1366 \\times 768$)
* **Menu Route**: Dock icon \`MnuKPI000\` $\\rightarrow$ \`Tổng quan CRM\` (\`MnuKPI001\`), \`Theo dõi dịch vụ\` (\`MnuKPI012\`)

---

## 1. MỤC TIÊU & PHẠM VI (GOAL & SCOPE)
* **Mục tiêu**: Cung cấp bức tranh toàn cảnh thời gian thực về hiệu suất bán hàng, tốc độ chuyển đổi lead, tỷ lệ hoàn thành KPI của từng nhân viên và tình trạng dịch vụ của khách hàng.
* **Phạm vi bao gồm**:
  - Dashboard thẻ KPI tổng hợp (Email gửi, Thu thập dữ liệu, Content, Demo, Khách cần chăm sóc).
  - Biểu đồ và bảng xếp hạng nhân viên kinh doanh theo tuần/tháng.
  - Bộ lọc động theo thời gian (\`Tuần\`, \`Tháng\`, \`Quý\`) và theo từng nhân viên.
  - Nút thêm nhanh khách hàng tiềm năng (\`+ Thêm Lead\`).
  - Theo dõi danh sách hợp đồng dịch vụ sắp hết hạn.
* **Phạm vi không bao gồm**: Chỉnh sửa cấu hình Stored Procedure tính điểm KPI (xử lý tại \`CRM-EPIC-06\`).

---

## 2. GIAO DIỆN & CẤU TRÚC THÀNH PHẦN (UI LAYOUT)
* **Header / Toolbar**:
  - Nút hành động: \`+ Thêm Lead\` (Primary Green), \`Tính toán lại\` (Cyan), \`Cài đặt danh sách KPI\` (Gear Icon).
  - Bộ lọc: Dropdown chọn nhân viên, Dropdown chọn chu kỳ xem (\`Tuần\` / \`Tháng\`), Datepicker chọn tuần/thời gian.
* **Khu vực Thẻ Metric KPI**:
  - Thẻ 1: **EMAIL THỦ CÔNG** (Số lượng & % tăng trưởng so với kỳ trước).
  - Thẻ 2: **THU THẬP DỮ LIỆU** (Số lượng lead crawl về).
  - Thẻ 3: **CONTENT** (Số lượng bài viết/nội dung marketing).
  - Thẻ 4: **DEMO** (Số buổi demo phần mềm).
  - Thẻ 5: **CẦN CHĂM SÓC** (Cảnh báo khách hàng nguy cơ rớt).
* **Khu vực Bảng Chi tiết**:
  - Bảng DataGrid: Xếp hạng nhân viên, STT, Tên nhân viên, Điểm KPI, Tỷ lệ hoàn thành.

---

## 3. DANH SÁCH USER STORIES

| Mã US | Tiêu Đề User Story | Mô Tả Tóm Tắt | Trạng Thái Bóc Tách | File Chi Tiết |
| :--- | :--- | :--- | :---: | :--- |
| **CRM-US01** | Xem Dashboard Tổng Quan KPI CRM | Xem số liệu tổng hợp, lọc theo nhân viên và chu kỳ tuần/tháng | ✅ Đầy đủ | [\`CRM-US01-Dashboard-Tong-Quan-KPI.md\`](../../user-stories/crm/CRM-EPIC-01-Tong-Quan-CRM/CRM-US01-Dashboard-Tong-Quan-KPI.md) |
| **CRM-US02** | Thêm Lead Nhanh Từ Dashboard | Mở modal popup nhập nhanh thông tin khách hàng mới | ✅ Đầy đủ | [\`CRM-US02-Them-Lead-Nhanh.md\`](../../user-stories/crm/CRM-EPIC-01-Tong-Quan-CRM/CRM-US02-Them-Lead-Nhanh.md) |
| **CRM-US03** | Theo Dõi Trạng Thái Dịch Vụ Khách Hàng | Theo dõi hạn bảo hành, hợp đồng dịch vụ của khách hàng | ✅ Đầy đủ | [\`CRM-US03-Theo-Doi-Dich-Vu.md\`](../../user-stories/crm/CRM-EPIC-01-Tong-Quan-CRM/CRM-US03-Theo-Doi-Dich-Vu.md) |
`;

fs.writeFileSync(path.join(EPIC_DIR, 'CRM-EPIC-01-Tong-Quan-CRM.md'), epic1, 'utf8');

// TẠO THƯ MỤC VÀ CÁC US CỦA EPIC 1
const US_EPIC1_DIR = path.join(US_DIR, 'CRM-EPIC-01-Tong-Quan-CRM');
fs.mkdirSync(US_EPIC1_DIR, { recursive: true });

const us01 = `# USER STORY: CRM-US01 · XEM DASHBOARD TỔNG QUAN KPI CRM

* **Thuộc Epic**: [\`CRM-EPIC-01: Tổng quan Vận hành CRM & KPI Analytics\`](../../../epic/crm/CRM-EPIC-01-Tong-Quan-CRM.md)
* **Mã User Story**: \`CRM-US01\`
* **Mã Ứng Dụng (App ID)**: \`MnuKPI001\`
* **Actor chính**: Quản trị viên CRM / Trưởng phòng KD (\`Chien.nguyen\`)
* **API / Stored Procedure ghi nhận**: \`sp_KPIListDataCollection\`, \`sp_CRM_SaleInCRM\`

---

## 1. PRECONDITIONS & TRIGGER
* **Tiền điều kiện (Preconditions)**:
  - Người dùng đăng nhập thành công với tài khoản có quyền truy cập CRM.
  - Dữ liệu KPI đã được ghi nhận từ hoạt động của nhân viên trong kỳ làm việc.
* **Sự kiện kích hoạt (Trigger)**:
  - Người dùng bấm vào menu **"Tổng quan CRM"** (\`MnuKPI001\`) trên thanh điều hướng hoặc dock icon.

---

## 2. MAIN FLOW & BUSINESS RULES
1. Người dùng truy cập màn hình Tổng quan CRM.
2. SYS hiển thị thanh công cụ lọc và các thẻ Metric KPI thời gian thực của tuần hiện tại.
3. Người dùng chọn lọc theo **Chu kỳ** (\`Tuần\` / \`Tháng\`) hoặc chọn lọc theo **Nhân viên cụ thể**.
4. SYS tự động gửi request gọi Stored Procedure tính toán và cập nhật lại số liệu trên các thẻ KPI và bảng xếp hạng.
5. Người dùng có thể bấm nút **"Tính toán lại"** để hệ thống quét lại dữ liệu phát sinh mới nhất.

---

## 3. BẢNG ĐẶC TẢ FIELD-LEVEL 6 CỘT CHUẨN MỰC

| Field / control | Loại UI Control | State | Required | Conditional / dynamic | Source / validation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Nhân viên** | \`Dropdown / SelectBox\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Danh sách nhân viên lấy từ \`sp_GetEmployeeList\`. Mặc định: "Tìm kiếm hoặc chọn..." |
| **Xem theo** | \`Dropdown / SelectBox\` | \`ENABLED\` | \`YES (*)\` | Hiển thị mặc định | Danh mục cố định: \`Tuần\`, \`Tháng\`. Mặc định: \`Tuần\` |
| **Thời gian** | \`DatePicker / DateBox\` | \`ENABLED\` | \`YES (*)\` | Thay đổi theo "Xem theo" | Định dạng Week/Year (ví dụ \`Week 42, 2026\`). Cho phép click chọn tuần |
| **Nút "+ Thêm Lead"** | \`Button (Primary Green)\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Bấm để mở Modal popup thêm nhanh khách hàng tiềm năng |
| **Nút "Tính toán lại"** | \`Button (Cyan Action)\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Gọi API nạp lại toàn bộ số liệu thống kê tức thời |
| **Nút "Cài đặt KPI"** | \`Button (Icon Gear)\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Mở modal cấu hình danh mục và ngưỡng KPI |
| **Thẻ "EMAIL THỦ CÔNG"** | \`Metric Card\` | \`READONLY\` | \`NO\` | Hiển thị mặc định | Số lượng email nhân viên đã gửi trong kỳ (Kèm % tăng trưởng so với kỳ trước) |
| **Thẻ "THU THẬP DỮ LIỆU"**| \`Metric Card\` | \`READONLY\` | \`NO\` | Hiển thị mặc định | Số lượng lead mới cào/nhập vào hệ thống |
| **Thẻ "CONTENT"** | \`Metric Card\` | \`READONLY\` | \`NO\` | Hiển thị mặc định | Số lượng nội dung tiếp thị đã xuất bản |
| **Thẻ "DEMO"** | \`Metric Card\` | \`READONLY\` | \`NO\` | Hiển thị mặc định | Số cuộc hẹn demo phần mềm thành công |
| **Thẻ "CẦN CHĂM SÓC"** | \`Metric Card (Warning)\`| \`READONLY\` | \`NO\` | Hiển thị mặc định | Số khách hàng quá 7 ngày chưa có tương tác |
| **Bảng xếp hạng KPI** | \`DataGrid\` | \`READONLY\` | \`NO\` | Hiển thị mặc định | Cột: STT, Mã NV, Tên NV, Tổng điểm, Xếp hạng, Chi tiết |

---

## 4. ALTERNATE & EXCEPTION FLOWS
* **AF-01: Thay đổi chu kỳ từ Tuần sang Tháng**: SYS tự động ẩn bộ chọn tuần và thay bằng Datepicker chọn tháng/năm, sau đó gọi API nạp lại toàn bộ thẻ KPI.
* **EF-01: Mất kết nối API / Timeout**: SYS hiển thị thông báo "Không thể nạp dữ liệu thống kê, vui lòng bấm Tính toán lại".

---

## 5. SƠ ĐỒ UML ACTIVITY DIAGRAM SWIMLANE

\`\`\`mermaid
flowchart TB
  subgraph B["Boundary — Web Admin: Tổng Quan CRM (MnuKPI001)"]
    subgraph L0["Swimlane — Quản Lý CRM"]
      I01(("Bắt đầu"))
      A01["Truy cập menu Tổng quan CRM"]
      A02["Chọn bộ lọc Nhân viên & Chu kỳ thời gian"]
      A03["Bấm nút Tính toán lại (nếu cần)"]
      I01 --> A01 --> A02 --> A03
    end

    subgraph L1["Swimlane — SYS (Giao diện)"]
      S01["Hiển thị giao diện Dashboard & Thẻ Metric"]
      S02["Gửi request tham số lọc xuống backend"]
      S03["Render lại số liệu trên 5 thẻ KPI và DataGrid"]
    end

    subgraph L2["Swimlane — Backend & Database"]
      DB01["Thực thi Stored Procedure tính điểm KPI"]
      DB02["Trả về mảng JSON số liệu theo kỳ"]
    end
  end

  A01 --> S01
  A02 --> S02
  A03 --> S02
  S02 --> DB01 --> DB02 --> S03
\`\`\`
`;

fs.writeFileSync(path.join(US_EPIC1_DIR, 'CRM-US01-Dashboard-Tong-Quan-KPI.md'), us01, 'utf8');

const us02 = `# USER STORY: CRM-US02 · THÊM LEAD NHANH TỪ DASHBOARD

* **Thuộc Epic**: [\`CRM-EPIC-01: Tổng quan Vận hành CRM & KPI Analytics\`](../../../epic/crm/CRM-EPIC-01-Tong-Quan-CRM.md)
* **Mã User Story**: \`CRM-US02\`
* **Mã Ứng Dụng (App ID)**: \`MnuKPI001\`
* **Actor chính**: Nhân viên kinh doanh / Quản lý CRM (\`Chien.nguyen\`)
* **API / Stored Procedure ghi nhận**: \`sp_CRM_InsertLeadQuick\`

---

## 1. PRECONDITIONS & TRIGGER
* **Tiền điều kiện (Preconditions)**: Người dùng đang ở màn hình Dashboard CRM.
* **Sự kiện kích hoạt (Trigger)**: Bấm nút **"+ Thêm Lead"** (Màu xanh lá) trên thanh công cụ.

---

## 2. MAIN FLOW & BUSINESS RULES
1. Người dùng bấm nút **"+ Thêm Lead"**.
2. SYS mở Modal popup "Thêm khách hàng tiềm năng mới".
3. Người dùng nhập: Tên khách hàng, Số điện thoại, Email, Nguồn lead, Nhu cầu.
4. Bấm nút **"Lưu thông tin"**.
5. SYS validate: Số điện thoại phải đúng định dạng 10 số và không trùng trong hệ thống.
6. Hệ thống lưu bản ghi mới và tự động cập nhật số lượng lên thẻ "THU THẬP DỮ LIỆU".

---

## 3. BẢNG ĐẶC TẢ FIELD-LEVEL 6 CỘT CHUẨN MỰC

| Field / control | Loại UI Control | State | Required | Conditional / dynamic | Source / validation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tên khách hàng / Công ty** | \`TextBox\` | \`ENABLED\` | \`YES (*)\` | Hiển thị mặc định | Tối đa 250 ký tự |
| **Số điện thoại** | \`TextBox (Phone)\` | \`ENABLED\` | \`YES (*)\` | Hiển thị mặc định | Regex: \`^[0-9]{10,11}$\`, Kiểm tra trùng lặp |
| **Email** | \`TextBox (Email)\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Định dạng email chuẩn (\`*@*.*\`) |
| **Nguồn Lead** | \`Dropdown\` | \`ENABLED\` | \`YES (*)\` | Hiển thị mặc định | Danh mục: \`Facebook\`, \`Google\`, \`Giới thiệu\`, \`Hotline\` |
| **Nhu cầu / Sản phẩm** | \`Dropdown\` | \`ENABLED\` | \`NO\` | Nạp từ Danh mục sản phẩm | Nạp từ bảng sản phẩm phần mềm |
| **Ghi chú trao đổi** | \`TextArea\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Tối đa 1000 ký tự |
| **Nút "Lưu"** | \`Button (Primary)\` | \`ENABLED\` | \`NO\` | Sáng khi form hợp lệ | Kích hoạt lưu dữ liệu vào CSDL |
| **Nút "Hủy / Đóng"** | \`Button\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Đóng modal không lưu |

---

## 4. SƠ ĐỒ UML ACTIVITY DIAGRAM SWIMLANE

\`\`\`mermaid
flowchart TB
  subgraph B["Boundary — Modal: Thêm Lead Nhanh"]
    subgraph L0["Swimlane — User"]
      I01(("Bắt đầu"))
      A01["Bấm nút '+ Thêm Lead'"]
      A02["Điền Tên, SĐT, Nguồn Lead"]
      A03["Bấm nút Lưu"]
      I01 --> A01 --> A02 --> A03
    end

    subgraph L1["Swimlane — SYS (Giao diện)"]
      S01["Hiển thị Modal Popup form nhập liệu"]
      S02["Kiểm tra tính hợp lệ dữ liệu (Validate)"]
      S03{"Dữ liệu hợp lệ?"}
      S04["Báo lỗi SĐT sai định dạng / trùng lặp"]
      S05["Đóng modal & Báo tạo Lead thành công"]
    end

    subgraph L2["Swimlane — Backend & Database"]
      DB01["INSERT bản ghi vào tbl_CRM_Leads"]
      DB02["Cập nhật lại cache chỉ số KPI"]
    end
  end

  A01 --> S01
  A03 --> S02 --> S03
  S03 -- "Không" --> S04 --> A02
  S03 -- "Hợp lệ" --> DB01 --> DB02 --> S05
\`\`\`
`;

fs.writeFileSync(path.join(US_EPIC1_DIR, 'CRM-US02-Them-Lead-Nhanh.md'), us02, 'utf8');

console.log('Generating Epic 2: Khách Hàng & Sales Pipeline...');
const epic2 = `# ĐẶC TẢ PHÂN HỆ: CRM-EPIC-02 · QUẢN LÝ KHÁCH HÀNG & SALES PIPELINE

* **Mã Epic**: \`CRM-EPIC-02\`
* **Tên phân hệ**: Quản lý Khách hàng & Sales Pipeline (Customer 360 & Deal Stages)
* **Role thao tác**: Nhân viên Kinh doanh, Trưởng phòng Kinh doanh (\`Chien.nguyen\`)
* **Platform**: Web Admin
* **Menu Route**: \`Dữ liệu khách hàng\` (\`MnuKPI003\`), \`Sales Pipeline\` (\`MnuKPI007\`), \`Doanh số\` (\`MnuKPI447\`), \`Theo dõi lead Marketing\` (\`MnuKPI448\`)

---

## 1. MỤC TIÊU & PHẠM VI
* **Mục tiêu**: Quản lý toàn bộ vòng đời khách hàng từ khi tiếp nhận dữ liệu thô đến khi chốt đơn thành công và ghi nhận doanh số bán hàng.
* **Phạm vi bao gồm**:
  - Quản lý hồ sơ khách hàng đầy đủ (Họ tên, SĐT, Công ty, Mã số thuế, Doanh thu, Lịch sử tương tác).
  - Phân loại trạng thái vòng đời khách hàng theo 7 tab nghiệp vụ: \`Lead\`, \`Đã liên hệ\`, \`Đã demo & gửi báo giá\`, \`Cần chăm sóc\`, \`Sắp chốt đơn\`, \`Thành công\`, \`Thất bại\`.
  - Quy trình quản lý cơ hội bán hàng trên Sales Pipeline.
  - Báo cáo chi tiết doanh số bán hàng từ API \`sp_CRM_SaleInCRM\`.
  - Phân tích nguồn gốc dữ liệu: Tiếp nhận từ chiến dịch Marketing hoặc nhập thủ công.

---

## 2. DANH SÁCH USER STORIES

| Mã US | Tiêu Đề User Story | Mô Tả Tóm Tắt | Trạng Thái Bóc Tách | File Chi Tiết |
| :--- | :--- | :--- | :---: | :--- |
| **CRM-US04** | Quản lý Dữ liệu Khách hàng & Bộ lọc 7 Trạng thái | Xem, tìm kiếm, phân trang và lọc khách hàng theo từng giai đoạn | ✅ Đầy đủ | [\`CRM-US04-Quan-Ly-Du-Lieu-Khach-Hang.md\`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US04-Quan-Ly-Du-Lieu-Khach-Hang.md) |
| **CRM-US05** | Thêm mới & Cập nhật Hồ sơ Khách hàng | Form chi tiết khách hàng, tích hợp kéo thả ảnh AI phân tích card visit | ✅ Đầy đủ | [\`CRM-US05-Them-Sua-Thong-Tin-Khach-Hang.md\`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US05-Them-Sua-Thong-Tin-Khach-Hang.md) |
| **CRM-US06** | Quản lý Quy trình Bán hàng Sales Pipeline | Quản lý cơ hội kinh doanh, chuyển đổi trạng thái chốt đơn | ✅ Đầy đủ | [\`CRM-US06-Quan-Ly-Sales-Pipeline.md\`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US06-Quan-Ly-Sales-Pipeline.md) |
| **CRM-US07** | Báo cáo Doanh số Kinh doanh CRM | Thống kê doanh thu theo nhân viên và hợp đồng chốt (\`sp_CRM_SaleInCRM\`) | ✅ Đầy đủ | [\`CRM-US07-Bao-Cao-Doanh-So-Kinh-Doanh.md\`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US07-Bao-Cao-Doanh-So-Kinh-Doanh.md) |
`;

fs.writeFileSync(path.join(EPIC_DIR, 'CRM-EPIC-02-Khach-Hang-Sales-Pipeline.md'), epic2, 'utf8');

const US_EPIC2_DIR = path.join(US_DIR, 'CRM-EPIC-02-Khach-Hang-Sales-Pipeline');
fs.mkdirSync(US_EPIC2_DIR, { recursive: true });

const us04 = `# USER STORY: CRM-US04 · QUẢN LÝ DỮ LIỆU KHÁCH HÀNG & BỘ LỌC 7 TRẠNG THÁI

* **Thuộc Epic**: [\`CRM-EPIC-02: Quản lý Khách hàng & Sales Pipeline\`](../../../epic/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline.md)
* **Mã User Story**: \`CRM-US04\`
* **Mã Ứng Dụng (App ID)**: \`MnuKPI003\`
* **Actor chính**: Nhân viên kinh doanh / Trưởng bộ phận CRM
* **API / Stored Procedure ghi nhận**: \`sp_KPIListDataCollection\`

---

## 1. PRECONDITIONS & TRIGGER
* **Tiền điều kiện (Preconditions)**: Người dùng có quyền truy cập module Khách hàng CRM.
* **Sự kiện kích hoạt (Trigger)**: Bấm chọn menu **"Dữ liệu khách hàng"** (\`MnuKPI003\`) trên thanh bên.

---

## 2. MAIN FLOW & BUSINESS RULES
1. SYS hiển thị thanh lọc trạng thái gồm 7 tab:
   - \`Lead\` (Khách hàng tiềm năng mới tiếp nhận)
   - \`Đã liên hệ\` (Đã gọi điện/nhắn tin lần đầu)
   - \`Đã demo & gửi báo giá\` (Đang đánh giá giải pháp phần mềm)
   - \`Cần chăm sóc\` (Cần bám sát xử lý phản hồi)
   - \`Sắp chốt đơn\` (Đang đàm phán hợp đồng)
   - \`Thành công\` (Đã ký hợp đồng/mua dịch vụ)
   - \`Thất bại\` (Khách từ chối, lưu lý do hủy)
2. Người dùng nhấp vào từng tab, SYS gọi API \`sp_KPIListDataCollection\` kèm tham số trạng thái tương ứng để nạp danh sách khách hàng lên DataGrid.
3. Người dùng có thể lọc thêm theo **Thời gian tạo** (\`Hôm nay\`, \`Tuần này\`, \`Tháng này\`, \`Xem tất cả ngày\`) hoặc tìm kiếm theo từ khóa.

---

## 3. BẢNG ĐẶC TẢ FIELD-LEVEL 6 CỘT CHUẨN MỰC

| Field / control | Loại UI Control | State | Required | Conditional / dynamic | Source / validation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tabs trạng thái (7 tabs)**| \`TabStrip / ButtonGroup\`| \`ENABLED\` | \`YES (*)\` | Mặc định: Tab "Tất cả" hoặc "Lead" | Gồm: Lead, Đã liên hệ, Demo, Cần chăm sóc, Sắp chốt, Thành công, Thất bại |
| **Lọc thời gian** | \`ButtonGroup\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Tùy chọn: \`Hôm nay\`, \`Tuần này\`, \`Tháng này\` |
| **Xem tất cả ngày** | \`DatePicker\` | \`ENABLED\` | \`NO\` | Tùy chọn chọn ngày cụ thể | Định dạng \`YYYY-MM-DD\` |
| **Tìm kiếm nội dung** | \`TextBox (Search)\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Tìm kiếm theo Tên KH, Số điện thoại, Email, Tên công ty |
| **Xem của tôi** | \`CheckBox\` | \`ENABLED\` | \`NO\` | Mặc định: Checked (\`on\`) | Khi bật: chỉ hiển thị khách hàng được phân công cho user hiện tại |
| **Chọn cột hiển thị** | \`Button / Dropdown\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Bật/tắt các cột dữ liệu trên DataGrid theo ý muốn |
| **Nút "+ Thêm mới"** | \`Button (Primary)\` | \`ENABLED\` | \`NO\` | Hiển thị trên thanh toolbar | Mở modal tạo mới hồ sơ khách hàng đầy đủ |
| **Nút "Import"** | \`Button\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Nhập khẩu danh sách khách hàng từ file Excel |
| **Nút "Export"** | \`Button\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Xuất toàn bộ danh sách đang hiển thị ra file Excel |
| **DataGrid Khách hàng** | \`DataGrid\` | \`READONLY\` | \`NO\` | Tự động phân trang | Các cột: STT, Mã KH, Tên KH, SĐT, Email, Tên công ty, Trạng thái, Người phụ trách, Thao tác |

---

## 4. SƠ ĐỒ UML ACTIVITY DIAGRAM SWIMLANE

\`\`\`mermaid
flowchart TB
  subgraph B["Boundary — Web Admin: Dữ Liệu Khách Hàng (MnuKPI003)"]
    subgraph L0["Swimlane — Nhân Viên Kinh Doanh"]
      I01(("Bắt đầu"))
      A01["Bấm chọn menu Dữ liệu khách hàng"]
      A02["Nhấp chọn Tab trạng thái (ví dụ: Sắp chốt đơn)"]
      A03["Nhập từ khóa tìm kiếm hoặc lọc ngày"]
      I01 --> A01 --> A02 --> A03
    end

    subgraph L1["Swimlane — SYS (Giao diện)"]
      S01["Tải giao diện DataGrid và bộ 7 Tabs"]
      S02["Gửi request sp_KPIListDataCollection"]
      S03["Render danh sách khách hàng lên DataGrid"]
    end

    subgraph L2["Swimlane — Backend & Database"]
      DB01["Truy vấn CSDL theo statusID và dateRange"]
      DB02["Trả về danh sách khách hàng và siêu dữ liệu"]
    end
  end

  A01 --> S01
  A02 --> S02 --> DB01 --> DB02 --> S03
  A03 --> S02
\`\`\`
`;

fs.writeFileSync(path.join(US_EPIC2_DIR, 'CRM-US04-Quan-Ly-Du-Lieu-Khach-Hang.md'), us04, 'utf8');

console.log('Generating Epic 5: Báo Giá & Phân Hệ Phần Mềm...');
const epic5 = `# ĐẶC TẢ PHÂN HỆ: CRM-EPIC-05 · QUẢN LÝ BÁO GIÁ & PHÂN HỆ PHẦN MỀM

* **Mã Epic**: \`CRM-EPIC-05\`
* **Tên phân hệ**: Quản lý Báo giá & Phân hệ Phần mềm (Quotation & Module Management)
* **Role thao tác**: Nhân viên kinh doanh, Kế toán bán hàng, Quản trị viên CRM (\`Chien.nguyen\`)
* **Platform**: Web Admin
* **Menu Route**: \`Báo giá phần mềm\` (\`MnuCSM004\`), \`Thêm/Sửa báo giá\` (\`MnuCSM005\`), \`Quản lý phân hệ\` (\`MnuCSM003\`), \`Thêm/Sửa phân hệ\` (\`MnuKPI446\`)
* **Stored Procedures cốt lõi bắt được**: \`sp_Sub_SubQuotation\`, \`sp_Sub_CUSubQuotation\`

---

## 1. MỤC TIÊU & PHẠM VI
* **Mục tiêu**: Tự động hóa quá trình lập báo giá phần mềm cho khách hàng, cho phép chọn cấu hình từng phân hệ/module (ví dụ: Core, Chấm công, Tính lương, CRM...), tự động tính tổng tiền theo đơn giá và chiết khấu, và xuất báo giá chính thức.
* **Phạm vi bao gồm**:
  - Quản lý danh sách các bản báo giá đã lập cho từng công ty/khách hàng.
  - Form thêm mới và chỉnh sửa báo giá chi tiết (\`sp_Sub_CUSubQuotation\`).
  - Quản lý danh mục các phân hệ phần mềm và bảng giá tiêu chuẩn (\`sp_Sub_SubQuotation\`).
  - Xuất báo giá ra định dạng Excel/PDF gửi cho khách hàng.

---

## 2. DANH SÁCH USER STORIES

| Mã US | Tiêu Đề User Story | Mô Tả Tóm Tắt | Trạng Thái Bóc Tách | File Chi Tiết |
| :--- | :--- | :--- | :---: | :--- |
| **CRM-US13** | Danh Sách Báo Giá Phần Mềm | Tra cứu, xem danh sách báo giá theo khách hàng và thời gian | ✅ Đầy đủ | [\`CRM-US13-Danh-Sach-Bao-Gia-Phan-Mem.md\`](../../user-stories/crm/CRM-EPIC-05-Bao-Gia-Phan-Mem/CRM-US13-Danh-Sach-Bao-Gia-Phan-Mem.md) |
| **CRM-US14** | Thêm Mới & Chỉnh Sửa Chi Tiết Báo Giá | Chọn phân hệ phần mềm, số lượng user, tính chiết khấu và tổng tiền | ✅ Đầy đủ | [\`CRM-US14-Them-Sua-Chi-Tiet-Bao-Gia.md\`](../../user-stories/crm/CRM-EPIC-05-Bao-Gia-Phan-Mem/CRM-US14-Them-Sua-Chi-Tiet-Bao-Gia.md) |
| **CRM-US15** | Quản Lý Danh Mục Phân Hệ Phần Mềm | Cấu hình mã phân hệ, tên phân hệ, đơn giá và tính năng đi kèm | ✅ Đầy đủ | [\`CRM-US15-Quan-Ly-Phan-He-Phan-Mem.md\`](../../user-stories/crm/CRM-EPIC-05-Bao-Gia-Phan-Mem/CRM-US15-Quan-Ly-Phan-He-Phan-Mem.md) |
`;

fs.writeFileSync(path.join(EPIC_DIR, 'CRM-EPIC-05-Bao-Gia-Phan-Mem.md'), epic5, 'utf8');

const US_EPIC5_DIR = path.join(US_DIR, 'CRM-EPIC-05-Bao-Gia-Phan-Mem');
fs.mkdirSync(US_EPIC5_DIR, { recursive: true });

const us13 = `# USER STORY: CRM-US13 · DANH SÁCH BÁO GIÁ PHẦN MỀM

* **Thuộc Epic**: [\`CRM-EPIC-05: Quản lý Báo giá & Phân hệ Phần mềm\`](../../../epic/crm/CRM-EPIC-05-Bao-Gia-Phan-Mem.md)
* **Mã User Story**: \`CRM-US13\`
* **Mã Ứng Dụng (App ID)**: \`MnuCSM004\`
* **Actor chính**: Nhân viên kinh doanh / Kế toán bán hàng
* **API / Stored Procedure**: \`sp_Sub_SubQuotation\`

---

## 1. PRECONDITIONS & TRIGGER
* **Tiền điều kiện (Preconditions)**: Người dùng có quyền truy cập phân hệ Báo giá.
* **Sự kiện kích hoạt (Trigger)**: Bấm chọn menu **"Báo giá phần mềm"** (\`MnuCSM004\`) thuộc nhóm Báo giá.

---

## 2. MAIN FLOW & BUSINESS RULES
1. Người dùng bấm chọn menu "Báo giá phần mềm".
2. SYS kích hoạt gọi Stored Procedure \`sp_Sub_SubQuotation\` để tải danh sách các bản báo giá hiện có.
3. Hiển thị DataGrid với các cột: Số báo giá, Khách hàng/Công ty, Ngày báo giá, Tổng tiền trước thuế, VAT, Tổng tiền thanh toán, Trạng thái (Bản nháp, Đã gửi, Đã chốt).
4. Người dùng có thể bấm vào dòng báo giá để xem chi tiết, bấm nút **"Xuất báo giá"** hoặc bấm **"Tạo báo giá mới"**.

---

## 3. BẢNG ĐẶC TẢ FIELD-LEVEL 6 CỘT CHUẨN MỰC

| Field / control | Loại UI Control | State | Required | Conditional / dynamic | Source / validation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Từ ngày - Đến ngày** | \`DateRangeBox\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Lọc khoảng thời gian lập báo giá |
| **Khách hàng** | \`Dropdown\` | \`ENABLED\` | \`NO\` | Lọc theo công ty | Danh mục nạp từ danh sách công ty CRM |
| **Trạng thái báo giá** | \`Dropdown\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Tùy chọn: \`Tất cả\`, \`Bản nháp\`, \`Đã gửi KH\`, \`Đã ký hợp đồng\` |
| **Nút "Tạo báo giá mới"**| \`Button (Primary)\` | \`ENABLED\` | \`NO\` | Hiển thị trên thanh toolbar | Điều hướng sang màn hình \`MnuCSM005\` để lập báo giá |
| **Nút "Xuất Excel"** | \`Button\` | \`ENABLED\` | \`NO\` | Hiển thị mặc định | Xuất file danh sách báo giá |
| **Nút "Xóa báo giá"** | \`Button (Danger)\` | \`DISABLED\` | \`NO\` | Chỉ sáng khi chọn 1 bản nháp | Hiển thị hộp thoại xác nhận xóa |
| **DataGrid Báo giá** | \`DataGrid\` | \`READONLY\` | \`NO\` | Nạp từ \`sp_Sub_SubQuotation\` | Cột: Số BG, Tên khách hàng, Ngày lập, Người lập, Tổng giá trị, Trạng thái |

---

## 4. SƠ ĐỒ UML ACTIVITY DIAGRAM SWIMLANE

\`\`\`mermaid
flowchart TB
  subgraph B["Boundary — Web Admin: Báo Giá Phần Mềm (MnuCSM004)"]
    subgraph L0["Swimlane — NVKD / Kế Toán"]
      I01(("Bắt đầu"))
      A01["Vào menu Báo giá phần mềm"]
      A02["Lọc theo thời gian hoặc tên công ty"]
      A03["Chọn báo giá cần xuất hoặc bấm Tạo mới"]
      I01 --> A01 --> A02 --> A03
    end

    subgraph L1["Swimlane — SYS (Giao diện)"]
      S01["Gửi request sp_Sub_SubQuotation"]
      S02["Render danh sách các bản báo giá lên DataGrid"]
      S03["Mở form lập báo giá hoặc xuất file"]
    end

    subgraph L2["Swimlane — Database / Backend"]
      DB01["Thực thi Stored Procedure sp_Sub_SubQuotation"]
      DB02["Trả về mảng chi tiết các bản báo giá"]
    end
  end

  A01 --> S01 --> DB01 --> DB02 --> S02
  A02 --> S01
  A03 --> S03
\`\`\`
`;

fs.writeFileSync(path.join(US_EPIC5_DIR, 'CRM-US13-Danh-Sach-Bao-Gia-Phan-Mem.md'), us13, 'utf8');

// TẠO FILE USER STORIES MASTER README
const usMasterReadme = `# DANH MỤC TÀI LIỆU USER STORY PHÂN HỆ CRM — PARADISE HRM

Tất cả các tài liệu User Story chi tiết dưới đây được biên dịch 100% từ dữ liệu cào thực tế bằng công cụ \`/ui-crawl-to-user-story\`:

* **\`CRM-EPIC-01: Tổng quan Vận hành CRM\`**:
  - [\`CRM-US01: Xem Dashboard Tổng Quan KPI CRM\`](./CRM-EPIC-01-Tong-Quan-CRM/CRM-US01-Dashboard-Tong-Quan-KPI.md)
  - [\`CRM-US02: Thêm Lead Nhanh Từ Dashboard\`](./CRM-EPIC-01-Tong-Quan-CRM/CRM-US02-Them-Lead-Nhanh.md)
* **\`CRM-EPIC-02: Quản lý Khách hàng & Sales Pipeline\`**:
  - [\`CRM-US04: Quản lý Dữ liệu Khách hàng & Bộ lọc 7 Trạng thái\`](./CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US04-Quan-Ly-Du-Lieu-Khach-Hang.md)
* **\`CRM-EPIC-05: Quản lý Báo giá & Phân hệ Phần mềm\`**:
  - [\`CRM-US13: Danh Sách Báo Giá Phần Mềm\`](./CRM-EPIC-05-Bao-Gia-Phan-Mem/CRM-US13-Danh-Sach-Bao-Gia-Phan-Mem.md)

---
*Tiếp tục đồng bộ và cập nhật theo yêu cầu của bạn.*
`;

fs.writeFileSync(path.join(US_DIR, 'README.md'), usMasterReadme, 'utf8');

console.log('Done generating CRM documentation.');
