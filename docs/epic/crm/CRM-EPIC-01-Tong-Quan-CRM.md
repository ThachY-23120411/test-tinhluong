# ĐẶC TẢ PHÂN HỆ: CRM-EPIC-01 · TỔNG QUAN VẬN HÀNH CRM & KPI ANALYTICS

* **Mã Epic**: `CRM-EPIC-01`
* **Tên phân hệ**: Tổng quan Vận hành CRM & KPI Analytics
* **Role thao tác**: Quản trị viên CRM / Giám đốc kinh doanh / Trưởng bộ phận CRM (`Chien.nguyen`)
* **Platform**: Web Admin (Desktop Browser, độ phân giải tối ưu $\ge 1366 \times 768$)
* **Menu Route**: Dock icon `MnuKPI000` $\rightarrow$ `Tổng quan CRM` (`MnuKPI001`), `Theo dõi dịch vụ` (`MnuKPI012`)

---

## 1. MỤC TIÊU & PHẠM VI (GOAL & SCOPE)
* **Mục tiêu**: Cung cấp bức tranh toàn cảnh thời gian thực về hiệu suất bán hàng, tốc độ chuyển đổi lead, tỷ lệ hoàn thành KPI của từng nhân viên và tình trạng dịch vụ của khách hàng.
* **Phạm vi bao gồm**:
  - Dashboard thẻ KPI tổng hợp (Email gửi, Thu thập dữ liệu, Content, Demo, Khách cần chăm sóc).
  - Biểu đồ và bảng xếp hạng nhân viên kinh doanh theo tuần/tháng.
  - Bộ lọc động theo thời gian (`Tuần`, `Tháng`, `Quý`) và theo từng nhân viên.
  - Nút thêm nhanh khách hàng tiềm năng (`+ Thêm Lead`).
  - Theo dõi danh sách hợp đồng dịch vụ sắp hết hạn.
* **Phạm vi không bao gồm**: Chỉnh sửa cấu hình Stored Procedure tính điểm KPI (xử lý tại `CRM-EPIC-06`).

---

## 2. GIAO DIỆN & CẤU TRÚC THÀNH PHẦN (UI LAYOUT)
* **Header / Toolbar**:
  - Nút hành động: `+ Thêm Lead` (Primary Green), `Tính toán lại` (Cyan), `Cài đặt danh sách KPI` (Gear Icon).
  - Bộ lọc: Dropdown chọn nhân viên, Dropdown chọn chu kỳ xem (`Tuần` / `Tháng`), Datepicker chọn tuần/thời gian.
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
| **CRM-US01** | Xem Dashboard Tổng Quan KPI CRM | Xem số liệu tổng hợp, lọc theo nhân viên và chu kỳ tuần/tháng | ✅ Đầy đủ | [`CRM-US01-Dashboard-Tong-Quan-KPI.md`](../../user-stories/crm/CRM-EPIC-01-Tong-Quan-CRM/CRM-US01-Dashboard-Tong-Quan-KPI.md) |
| **CRM-US02** | Thêm Lead Nhanh Từ Dashboard | Mở modal popup nhập nhanh thông tin khách hàng mới | ✅ Đầy đủ | [`CRM-US02-Them-Lead-Nhanh.md`](../../user-stories/crm/CRM-EPIC-01-Tong-Quan-CRM/CRM-US02-Them-Lead-Nhanh.md) |
| **CRM-US03** | Theo Dõi Trạng Thái Dịch Vụ Khách Hàng | Theo dõi hạn bảo hành, hợp đồng dịch vụ của khách hàng | ✅ Đầy đủ | [`CRM-US03-Theo-Doi-Dich-Vu.md`](../../user-stories/crm/CRM-EPIC-01-Tong-Quan-CRM/CRM-US03-Theo-Doi-Dich-Vu.md) |
