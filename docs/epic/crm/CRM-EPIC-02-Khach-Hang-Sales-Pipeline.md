# ĐẶC TẢ PHÂN HỆ: CRM-EPIC-02 · QUẢN LÝ KHÁCH HÀNG & SALES PIPELINE

* **Mã Epic**: `CRM-EPIC-02`
* **Tên phân hệ**: Quản lý Khách hàng & Sales Pipeline (Customer 360 & Deal Stages)
* **Role thao tác**: Nhân viên Kinh doanh, Trưởng phòng Kinh doanh (`Chien.nguyen`)
* **Platform**: Web Admin
* **Menu Route**: `Dữ liệu khách hàng` (`MnuKPI003`), `Sales Pipeline` (`MnuKPI007`), `Doanh số` (`MnuKPI447`), `Theo dõi lead Marketing` (`MnuKPI448`)

---

## 1. MỤC TIÊU & PHẠM VI
* **Mục tiêu**: Quản lý toàn bộ vòng đời khách hàng từ khi tiếp nhận dữ liệu thô đến khi chốt đơn thành công và ghi nhận doanh số bán hàng.
* **Phạm vi bao gồm**:
  - Quản lý hồ sơ khách hàng đầy đủ (Họ tên, SĐT, Công ty, Mã số thuế, Doanh thu, Lịch sử tương tác).
  - Phân loại trạng thái vòng đời khách hàng theo 7 tab nghiệp vụ: `Lead`, `Đã liên hệ`, `Đã demo & gửi báo giá`, `Cần chăm sóc`, `Sắp chốt đơn`, `Thành công`, `Thất bại`.
  - Quy trình quản lý cơ hội bán hàng trên Sales Pipeline.
  - Báo cáo chi tiết doanh số bán hàng từ API `sp_CRM_SaleInCRM`.
  - Phân tích nguồn gốc dữ liệu: Tiếp nhận từ chiến dịch Marketing hoặc nhập thủ công.

---

## 2. DANH SÁCH USER STORIES

| Mã US | Tiêu Đề User Story | Mô Tả Tóm Tắt | Trạng Thái Bóc Tách | File Chi Tiết |
| :--- | :--- | :--- | :---: | :--- |
| **CRM-US04** | Quản lý Dữ liệu Khách hàng & Bộ lọc 7 Trạng thái | Xem, tìm kiếm, phân trang và lọc khách hàng theo từng giai đoạn | ✅ Đầy đủ | [`CRM-US04-Quan-Ly-Du-Lieu-Khach-Hang.md`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US04-Quan-Ly-Du-Lieu-Khach-Hang.md) |
| **CRM-US05** | Thêm mới & Cập nhật Hồ sơ Khách hàng | Form chi tiết khách hàng, tích hợp kéo thả ảnh AI phân tích card visit | ✅ Đầy đủ | [`CRM-US05-Them-Sua-Thong-Tin-Khach-Hang.md`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US05-Them-Sua-Thong-Tin-Khach-Hang.md) |
| **CRM-US06** | Quản lý Quy trình Bán hàng Sales Pipeline | Quản lý cơ hội kinh doanh, chuyển đổi trạng thái chốt đơn | ✅ Đầy đủ | [`CRM-US06-Quan-Ly-Sales-Pipeline.md`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US06-Quan-Ly-Sales-Pipeline.md) |
| **CRM-US07** | Báo cáo Doanh số Kinh doanh CRM | Thống kê doanh thu theo nhân viên và hợp đồng chốt (`sp_CRM_SaleInCRM`) | ✅ Đầy đủ | [`CRM-US07-Bao-Cao-Doanh-So-Kinh-Doanh.md`](../../user-stories/crm/CRM-EPIC-02-Khach-Hang-Sales-Pipeline/CRM-US07-Bao-Cao-Doanh-So-Kinh-Doanh.md) |
