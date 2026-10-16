# ĐẶC TẢ PHÂN HỆ: CRM-EPIC-05 · QUẢN LÝ BÁO GIÁ & PHÂN HỆ PHẦN MỀM

* **Mã Epic**: `CRM-EPIC-05`
* **Tên phân hệ**: Quản lý Báo giá & Phân hệ Phần mềm (Quotation & Module Management)
* **Role thao tác**: Nhân viên kinh doanh, Kế toán bán hàng, Quản trị viên CRM (`Chien.nguyen`)
* **Platform**: Web Admin
* **Menu Route**: `Báo giá phần mềm` (`MnuCSM004`), `Thêm/Sửa báo giá` (`MnuCSM005`), `Quản lý phân hệ` (`MnuCSM003`), `Thêm/Sửa phân hệ` (`MnuKPI446`)
* **Stored Procedures cốt lõi bắt được**: `sp_Sub_SubQuotation`, `sp_Sub_CUSubQuotation`

---

## 1. MỤC TIÊU & PHẠM VI
* **Mục tiêu**: Tự động hóa quá trình lập báo giá phần mềm cho khách hàng, cho phép chọn cấu hình từng phân hệ/module (ví dụ: Core, Chấm công, Tính lương, CRM...), tự động tính tổng tiền theo đơn giá và chiết khấu, và xuất báo giá chính thức.
* **Phạm vi bao gồm**:
  - Quản lý danh sách các bản báo giá đã lập cho từng công ty/khách hàng.
  - Form thêm mới và chỉnh sửa báo giá chi tiết (`sp_Sub_CUSubQuotation`).
  - Quản lý danh mục các phân hệ phần mềm và bảng giá tiêu chuẩn (`sp_Sub_SubQuotation`).
  - Xuất báo giá ra định dạng Excel/PDF gửi cho khách hàng.

---

## 2. DANH SÁCH USER STORIES

| Mã US | Tiêu Đề User Story | Mô Tả Tóm Tắt | Trạng Thái Bóc Tách | File Chi Tiết |
| :--- | :--- | :--- | :---: | :--- |
| **CRM-US13** | Danh Sách Báo Giá Phần Mềm | Tra cứu, xem danh sách báo giá theo khách hàng và thời gian | ✅ Đầy đủ | [`CRM-US13-Danh-Sach-Bao-Gia-Phan-Mem.md`](../../user-stories/crm/CRM-EPIC-05-Bao-Gia-Phan-Mem/CRM-US13-Danh-Sach-Bao-Gia-Phan-Mem.md) |
| **CRM-US14** | Thêm Mới & Chỉnh Sửa Chi Tiết Báo Giá | Chọn phân hệ phần mềm, số lượng user, tính chiết khấu và tổng tiền | ✅ Đầy đủ | [`CRM-US14-Them-Sua-Chi-Tiet-Bao-Gia.md`](../../user-stories/crm/CRM-EPIC-05-Bao-Gia-Phan-Mem/CRM-US14-Them-Sua-Chi-Tiet-Bao-Gia.md) |
| **CRM-US15** | Quản Lý Danh Mục Phân Hệ Phần Mềm | Cấu hình mã phân hệ, tên phân hệ, đơn giá và tính năng đi kèm | ✅ Đầy đủ | [`CRM-US15-Quan-Ly-Phan-He-Phan-Mem.md`](../../user-stories/crm/CRM-EPIC-05-Bao-Gia-Phan-Mem/CRM-US15-Quan-Ly-Phan-He-Phan-Mem.md) |
