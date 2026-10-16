# BÁO CÁO KIỂM THỬ TRANG: CRM_CUSTOMER_DATA

> Thời gian kiểm thử: **11:07:11 16/10/2026**
> Tổng số kịch bản: **4** | ✅ LOGIC PASS: **4** | ❌ LOGIC FAIL: **0**

## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ

| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |
| :--- | :--- | :---: | :---: | :--- |
| **TC-01** | Kiểm tra Khởi động, Điều hướng và Hiển thị Giao diện Dữ liệu khách hàng (Header, DataGrid, Toolbar) | ✅ PASS | ✅ PASS | PASS - Giao diện Dữ liệu khách hàng hiển thị hoàn chỉnh, thanh công cụ sẵn sàng và DataGrid nạp thành công 20 dòng dữ liệu |
| **TC-02** | Kiểm tra Bộ lọc Trạng thái (Status Pills) & Tùy chọn "Xem của tôi" | ✅ PASS | ✅ PASS | PASS - Các nút bộ lọc trạng thái và tùy chọn Xem của tôi phản hồi tức thì, chuyển đổi mượt mà |
| **TC-03** | Kiểm tra Modal "Thêm dữ liệu mới" (+) - Ràng buộc (*) & Nhập liệu an toàn | ✅ PASS | ✅ PASS | PASS - Modal Thêm dữ liệu mới hiển thị đầy đủ trường thông tin, kiểm soát ràng buộc chặt chẽ và đóng an toàn |
| **TC-04** | Kiểm tra Ô Tìm kiếm nhanh (Search Box) & Lọc dữ liệu tức thì trên DataGrid | ✅ PASS | ✅ PASS | PASS - Ô tìm kiếm nhanh phản hồi tức thì, lọc chính xác theo từ khóa "Ms" và khôi phục đầy đủ 20 bản ghi |

---

### TC-01: Kiểm tra Khởi động, Điều hướng và Hiển thị Giao diện Dữ liệu khách hàng (Header, DataGrid, Toolbar)

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `24.38s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Giao diện Dữ liệu khách hàng hiển thị hoàn chỉnh, thanh công cụ sẵn sàng và DataGrid nạp thành công 20 dòng dữ liệu
* **Thư mục lưu trữ**: `test-evidence/crm_customer_data/TC-01/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Đăng nhập thành công và mở trang chủ hệ thống Paradise HRM
![Bước 1: Đăng nhập thành công và mở trang chủ hệ thống Paradise HRM](TC-01/screenshots/TC-01-step01-dang-nhap-thanh-cong-va-mo-trang-chu-he-thong-paradise-hrm.png)

##### 🔹 Bước 2: Mở màn hình Dữ liệu khách hàng từ menu phân hệ CRM
![Bước 2: Mở màn hình Dữ liệu khách hàng từ menu phân hệ CRM](TC-01/screenshots/TC-01-step02-mo-man-hinh-du-lieu-khach-hang-tu-menu-phan-he-crm.png)

##### 🔹 Bước 3: Kiểm tra thanh công cụ Toolbar và các nút chức năng thao tác
![Bước 3: Kiểm tra thanh công cụ Toolbar và các nút chức năng thao tác](TC-01/screenshots/TC-01-step03-kiem-tra-thanh-cong-cu-toolbar-va-cac-nut-chuc-nang-thao-tac.png)

##### 🔹 Bước 4: Kiểm tra bảng DataGrid danh sách khách hàng và các cột dữ liệu chính
![Bước 4: Kiểm tra bảng DataGrid danh sách khách hàng và các cột dữ liệu chính](TC-01/screenshots/TC-01-step04-kiem-tra-bang-datagrid-danh-sach-khach-hang-va-cac-cot-du-lieu-chinh.png)

##### 🔹 Bước 5: Hệ thống nạp đầy đủ danh sách khách hàng và hiển thị DataGrid thành công
![Bước 5: Hệ thống nạp đầy đủ danh sách khách hàng và hiển thị DataGrid thành công](TC-01/screenshots/TC-01-step05-he-thong-nap-day-du-danh-sach-khach-hang-va-hien-thi-datagrid-thanh-cong.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-01/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-01/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_customer_data/TC-01/traces/trace.zip`)*

---

### TC-02: Kiểm tra Bộ lọc Trạng thái (Status Pills) & Tùy chọn "Xem của tôi"

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `33.42s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Các nút bộ lọc trạng thái và tùy chọn Xem của tôi phản hồi tức thì, chuyển đổi mượt mà
* **Thư mục lưu trữ**: `test-evidence/crm_customer_data/TC-02/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Kiểm tra thanh bộ lọc trạng thái mặc định (Tất cả đang kích hoạt)
![Bước 1: Kiểm tra thanh bộ lọc trạng thái mặc định (Tất cả đang kích hoạt)](TC-02/screenshots/TC-02-step01-kiem-tra-thanh-bo-loc-trang-thai-mac-dinh-tat-ca-dang-kich-hoat.png)

##### 🔹 Bước 2: Chọn bộ lọc trạng thái Lead và kiểm tra phản hồi của DataGrid
![Bước 2: Chọn bộ lọc trạng thái Lead và kiểm tra phản hồi của DataGrid](TC-02/screenshots/TC-02-step02-chon-bo-loc-trang-thai-lead-va-kiem-tra-phan-hoi-cua-datagrid.png)

##### 🔹 Bước 3: Chuyển đổi sang bộ lọc Đã liên hệ và kiểm tra danh sách lọc
![Bước 3: Chuyển đổi sang bộ lọc Đã liên hệ và kiểm tra danh sách lọc](TC-02/screenshots/TC-02-step03-chuyen-doi-sang-bo-loc-da-lien-he-va-kiem-tra-danh-sach-loc.png)

##### 🔹 Bước 4: Kích hoạt tùy chọn lọc Xem của tôi để lọc dữ liệu phụ trách
![Bước 4: Kích hoạt tùy chọn lọc Xem của tôi để lọc dữ liệu phụ trách](TC-02/screenshots/TC-02-step04-kich-hoat-tuy-chon-loc-xem-cua-toi-de-loc-du-lieu-phu-trach.png)

##### 🔹 Bước 5: Khôi phục bộ lọc Tất cả và hoàn tất kiểm tra chuyển đổi trạng thái
![Bước 5: Khôi phục bộ lọc Tất cả và hoàn tất kiểm tra chuyển đổi trạng thái](TC-02/screenshots/TC-02-step05-khoi-phuc-bo-loc-tat-ca-va-hoan-tat-kiem-tra-chuyen-doi-trang-thai.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-02/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-02/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_customer_data/TC-02/traces/trace.zip`)*

---

### TC-03: Kiểm tra Modal "Thêm dữ liệu mới" (+) - Ràng buộc (*) & Nhập liệu an toàn

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `37.27s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Modal Thêm dữ liệu mới hiển thị đầy đủ trường thông tin, kiểm soát ràng buộc chặt chẽ và đóng an toàn
* **Thư mục lưu trữ**: `test-evidence/crm_customer_data/TC-03/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Con trỏ chuột Neon di chuyển và bấm nút Thêm dữ liệu mới (+)
![Bước 1: Con trỏ chuột Neon di chuyển và bấm nút Thêm dữ liệu mới (+)](TC-03/screenshots/TC-03-step01-con-tro-chuot-neon-di-chuyen-va-bam-nut-them-du-lieu-moi.png)

##### 🔹 Bước 2: Modal Thêm dữ liệu mới hiển thị chi tiết 2 phân vùng thông tin
![Bước 2: Modal Thêm dữ liệu mới hiển thị chi tiết 2 phân vùng thông tin](TC-03/screenshots/TC-03-step02-modal-them-du-lieu-moi-hien-thi-chi-tiet-2-phan-vung-thong-tin.png)

##### 🔹 Bước 3: Kiểm tra các trường ràng buộc bắt buộc có dấu sao đỏ trên form
![Bước 3: Kiểm tra các trường ràng buộc bắt buộc có dấu sao đỏ trên form](TC-03/screenshots/TC-03-step03-kiem-tra-cac-truong-rang-buoc-bat-buoc-co-dau-sao-do-tren-form.png)

##### 🔹 Bước 4: Nhập thông tin thử nghiệm trực quan vào các trường trên form
![Bước 4: Nhập thông tin thử nghiệm trực quan vào các trường trên form](TC-03/screenshots/TC-03-step04-nhap-thong-tin-thu-nghiem-truc-quan-vao-cac-truong-tren-form.png)

##### 🔹 Bước 5: Đóng Modal an toàn và quay trở về giao diện danh sách khách hàng
![Bước 5: Đóng Modal an toàn và quay trở về giao diện danh sách khách hàng](TC-03/screenshots/TC-03-step05-dong-modal-an-toan-va-quay-tro-ve-giao-dien-danh-sach-khach-hang.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-03/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-03/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_customer_data/TC-03/traces/trace.zip`)*

---

### TC-04: Kiểm tra Ô Tìm kiếm nhanh (Search Box) & Lọc dữ liệu tức thì trên DataGrid

* **Trạng thái thực thi Test (Kỹ thuật)**: ✅ PASS (Thời gian thực thi: `29.54s`)
* **Trạng thái Logic Nghiệp vụ (Business Output)**: ✅ PASS
* **Đánh giá tổng quát**: PASS - Ô tìm kiếm nhanh phản hồi tức thì, lọc chính xác theo từ khóa "Ms" và khôi phục đầy đủ 20 bản ghi
* **Thư mục lưu trữ**: `test-evidence/crm_customer_data/TC-04/`

#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):

##### 🔹 Bước 1: Xác định ô Tìm kiếm nhanh trên thanh công cụ Dữ liệu khách hàng
![Bước 1: Xác định ô Tìm kiếm nhanh trên thanh công cụ Dữ liệu khách hàng](TC-04/screenshots/TC-04-step01-xac-dinh-o-tim-kiem-nhanh-tren-thanh-cong-cu-du-lieu-khach-hang.png)

##### 🔹 Bước 2: Nhập từ khóa tìm kiếm "Ms" trực quan vào ô tìm kiếm nhanh
![Bước 2: Nhập từ khóa tìm kiếm "Ms" trực quan vào ô tìm kiếm nhanh](TC-04/screenshots/TC-04-step02-nhap-tu-khoa-tim-kiem-ms-truc-quan-vao-o-tim-kiem-nhanh.png)

##### 🔹 Bước 3: DataGrid lọc tức thì danh sách khách hàng khớp với từ khóa tìm kiếm
![Bước 3: DataGrid lọc tức thì danh sách khách hàng khớp với từ khóa tìm kiếm](TC-04/screenshots/TC-04-step03-datagrid-loc-tuc-thi-danh-sach-khach-hang-khop-voi-tu-khoa-tim-kiem.png)

##### 🔹 Bước 4: Con trỏ chuột Neon kiểm tra chi tiết bản ghi khách hàng tìm thấy
![Bước 4: Con trỏ chuột Neon kiểm tra chi tiết bản ghi khách hàng tìm thấy](TC-04/screenshots/TC-04-step04-con-tro-chuot-neon-kiem-tra-chi-tiet-ban-ghi-khach-hang-tim-thay.png)

##### 🔹 Bước 5: Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách khách hàng ban đầu
![Bước 5: Xóa từ khóa tìm kiếm và khôi phục toàn bộ danh sách khách hàng ban đầu](TC-04/screenshots/TC-04-step05-xoa-tu-khoa-tim-kiem-va-khoi-phuc-toan-bo-danh-sach-khach-hang-ban-dau.png)

#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):
- **Video phiên chạy thực tế**: [video.webm](TC-04/videos/video.webm)
- **Playwright Trace**: [trace.zip](TC-04/traces/trace.zip) *(Mở bằng: `npx playwright show-trace test-evidence/crm_customer_data/TC-04/traces/trace.zip`)*

---

