# KỊCH BẢN KIỂM THỬ THỦ CÔNG & QUAY RECORDING (MANUAL TEST SCRIPT) - PHÂN VÙNG FIX-5
> **DỰ ÁN**: Flow liên hoàn tính lương nhân viên mới `099 - Nguyễn Văn Test` (E2E New Employee Payroll)  
> **VAI TRÒ THỰC HIỆN**: Nhân viên mới `test.nv` / `123` (EmployeeID: `099`)  
> **MỤC TIÊU**: 
> 1. Hướng dẫn chi tiết từng thao tác tay trên Google Chrome để bạn test thủ công và bật **Chrome F12 Recorder** xuất file `.json`.
> 2. Sau khi có file `.json`, Agent sẽ lọc thao tác thừa và tự động chuyển đổi thành bộ Test Case Playwright (`.spec.js`) mô phỏng người thật 100% tái sử dụng qua file `.bat` 1-Click theo **Điều 9 AGENTS.md**.
> 
> **ĐẶC TẢ NGHIỆP VỤ CÔNG THÁNG 10/2026 & CÁC ĐƠN TỪ ESS**:
> *(Giờ làm việc hành chính công ty: **08:00 - 17:00**, nghỉ trưa 12:00 - 13:00 = **8.0h/ngày chuẩn**)*
> - **Tất cả các ngày làm việc bình thường (T2 $\rightarrow$ T6) trong kỳ công Tháng 10/2026** *(trừ T7, CN và trừ 4 ngày đặc biệt bên dưới)*: Đã làm đủ ca chuẩn `08:00 - 17:00` (**8.0h công = 1.0 công chuẩn**).
> - **Thứ 7, Chủ Nhật**: Ngày nghỉ cuối tuần (**0.0h**).
> - **4 NGÀY ĐẶC BIỆT PHỤC VỤ TEST**:
>   1. **Ngày 14/10 (Thứ 4)**: Làm `08:00 - 15:00` (**6.0h công lẻ = 0.75 công**). Nhân viên nộp đơn xin bù công nhầm Giờ Ra `17:00` ngày 14/10, sau đó **TỰ XIN HỦY ĐƠN (CANCEL)** $\rightarrow$ Đơn bị hủy, giữ nguyên `6.0h` công lẻ ban đầu!
>   2. **Ngày 15/10 (Thứ 5)**: Làm sáng `08:00 - 12:00` (**4.0h công lẻ**, quên quẹt thẻ ra về chiều) $\rightarrow$ **Nộp đơn xin bù công Giờ RA `17:00` và ĐƯỢC DUYỆT** $\rightarrow$ Hệ thống nối `08:00 - 17:00` = **8.0h công chuẩn**!
>   3. **Ngày 16/10 (Thứ 6)**: Làm `08:00 - 16:00` (**7.0h công lẻ**) $\rightarrow$ **Nộp đơn xin bù công Giờ RA `17:00` và BỊ TỪ CHỐI (REJECT)** $\rightarrow$ giữ nguyên `7.0h` công lẻ!
>   4. **Ngày 24/10 (Thứ 7)**: Ban đầu `0.0h` $\rightarrow$ **Nộp đơn xin nghỉ phép năm AL 1.0 ngày** (08:00 - 17:00 = 8.0h hưởng 100% lương).
> - **Ngày 20/10 (Thứ 3)**: **Nộp đơn xin làm thêm giờ Tăng ca OT 2.0h** (18:00 - 20:00).

---

> [!IMPORTANT]
> ### 🛠️ BƯỚC 0 (TIỀN ĐỀ BẮT BUỘC): CHẠY SCRIPT SQL TRÊN SSMS TRƯỚC KHI TEST
> Mở **SQL Server Management Studio (SSMS)**, kết nối CSDL `Vietinsoft_ForTest_Tai2` và thực thi lần lượt các file sau:
> 
> #### 🧹 Bước 0.1: Chạy Script làm sạch môi trường & xóa đơn từ cũ
> - Mở file: 📁 [**`scripts/clean_test_requests_fix5.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/clean_test_requests_fix5.sql)
> - Bấm `Ctrl + F5` kiểm tra cú pháp $\rightarrow$ Bấm `F5` thực thi.
> - *Tác dụng*: Xóa sạch đơn bù công, phép, OT cũ; xóa lịch sử nghỉ `tblLvHistory`; cấp lại 2 ngày phép năm và cấu hình tuyến duyệt 2 cấp cho NV 099.
> 
> #### 🌱 Bước 0.2: Chạy Script nạp công toàn kỳ Tháng 10/2026 (`08:00 - 17:00`) vào `tblHasTA` & `tblTmpAttend`
> - Mở file: 📁 [**`scripts/seed_attendance_5days_nv099.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/seed_attendance_5days_nv099.sql)
> - Bấm `Ctrl + F5` kiểm tra cú pháp $\rightarrow$ Bấm `F5` thực thi.
> - *Tác dụng*: Nạp công chuẩn 8.0h (`08:00 - 17:00`) cho tất cả ngày T2-T6 trong kỳ công Tháng 10/2026 (trừ T7, CN và trừ 4 ngày đặc biệt: 14/10 `08:00-15:00` = 6h, 15/10 `08:00-12:00` = 4h, 16/10 `08:00-16:00` = 7h, 24/10 = 0h), đồng bộ cả bảng thô `tblTmpAttend`.
> 
> #### ⚙️ Bước 0.3: Chạy Bản vá cho phép Hủy đơn khi đang Chờ duyệt (`sp_CheckCancelPermission`)
> - Mở file: 📁 [**`scripts/patch_allow_cancel_pending_request.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/patch_allow_cancel_pending_request.sql)
> - Bấm `Ctrl + F5` kiểm tra cú pháp $\rightarrow$ Bấm `F5` thực thi.
> - *Tác dụng*: Mở rộng điều kiện kiểm tra quyền hủy đơn `Approve_Status IN (1, 2)` để khi nhân viên bấm vào thẻ Chờ duyệt (ngày 14/10) thì nút màu đỏ **"Xin hủy đơn"** sẽ xuất hiện cho phép hủy trực tiếp trên giao diện!
> 
> #### ⚡ Bước 0.4: Chạy Bản vá Tự động tính lại công ngay khi Duyệt đơn Xin bù công (`sp_ApproveAttendanceRequest`)
> - Mở file: 📁 [**`fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql) *(đối chứng bản gốc tại [origin.sql](file:///c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/sp_ApproveAttendanceRequest-2026-11-12/origin.sql))*
> - Bấm `Ctrl + F5` kiểm tra cú pháp $\rightarrow$ Bấm `F5` thực thi.
> - *Tác dụng*: Ngay khi Quản lý cấp cuối duyệt (hoặc duyệt hủy) đơn bù công, SP tự động gọi `sp_ReCalculate_TAData` cho đúng 1 ngày & 1 nhân viên đó để cập nhật tức thì giờ công lên **Chấm công cá nhân** (`tblHasTA`).

---

## 🎥 HƯỚNG DẪN BẬT CHROME DEVTOOLS RECORDER ĐỂ QUAY THAO TÁC

1. Mở trình duyệt **Google Chrome** và truy cập: `https://paradisehrm.com/Tai3/`
2. Nhấn phím `F12` (hoặc `Ctrl + Shift + I`) để mở giao diện Chrome DevTools.
3. Trên thanh công cụ trên cùng của DevTools, nhấp vào tab **Recorder** *(Nếu không thấy, nhấp vào biểu tượng `>>` hoặc dấu `+` cạnh tab Network/Console để chọn "Recorder")*.
4. Nhấp nút **"Create new recording"** (hoặc dấu `+` lớn):
   - **Recording name**: Đặt tên là `fix5-nop-don-ess`.
   - **Selector attribute**: Giữ mặc định.
5. Nhấp nút **"Start recording"** màu đỏ ở góc dưới để bắt đầu ghi lại toàn bộ hành động.
6. Tiến hành thực hiện chuẩn xác theo các bước trong **Mục chi tiết dưới đây**.

---

## 📋 CÁC BƯỚC THAO TÁC CHI TIẾT STEP-BY-STEP (RECORDING FLOW)

### BƯỚC 1: ĐĂNG NHẬP CỔNG THÔNG TIN NHÂN SỰ (PORTAL ESS)
1. Tại màn hình Đăng nhập Paradise HRM:
   - Ô **Tên đăng nhập**: Nhập `test.nv`
   - Ô **Mật khẩu**: Nhập `123`
2. Nhấp nút **"Đăng nhập"** màu xanh.
3. Đợi trang chủ Dashboard hiển thị hoàn tất.

---

### BƯỚC 2: KHẢO SÁT HIỆN TRẠNG 5 NGÀY CÔNG (BẢNG CÔNG CÁ NHÂN - BASELINE BEFORE)
*(Khảo sát trực quan 5 ngày công mẫu đã nạp trong CSDL trên màn hình Chấm công cá nhân)*

1. Mở menu **"Chấm công cá nhân"** bằng 1 trong các cách sau:
   - **Cách 1 (Nhanh nhất)**: Nhấp trực tiếp vào biểu tượng **Bảng lịch 📅** (Calendar icon) màu xanh lá cây trên thanh Dock ngang trên cùng.
   - **Cách 2**: Tại cột menu bên trái, nhấp vào mục **"Chấm công cá nhân"** (dưới nhóm *Quản lý chấm công*).
   - **Cách 3**: Nhấp vào biểu tượng **Cửa sổ Windows 🪟** $\rightarrow$ Tại ô Search của Launchpad gõ: `Chấm công cá nhân` $\rightarrow$ Nhấp chọn icon **"Chấm công cá nhân"**.
2. Tại màn hình **"BẢNG CÔNG CHI TIẾT"**:
   - Nhấp chuột vào combobox **Tháng** để mở danh sách thả xuống.
   - Cuộn chuột xuống và nhấp chọn trực tiếp mục **"Tháng 10"** trên danh sách thả xuống.
   - *(⚠️ LƯU Ý: Tuyệt đối không gõ chữ rồi Enter, không bấm nút "Làm mới". Chỉ cần click chọn "Tháng 10" trên danh sách thả xuống là hệ thống tự động tải ra đầy đủ bảng ngày công)*.
3. Quan sát lưới lịch tháng hiển thị trực quan dữ liệu công kỳ Tháng 10/2026:
   - **Tất cả các ngày làm việc bình thường (T2 $\rightarrow$ T6)** *(12/10, 13/10, 19-23/10, 26-30/10, 02-06/11, 09/11)*: `HC 08:00 - 17:00 | Công: 8h` (Full ca chuẩn 1.0 công).
   - **Ngày 14/10** (Thứ Tư): `HC 08:00 - 15:00 | Công: 6h` (Công lẻ 6.0h, nộp nhầm đơn bù Giờ Ra 17:00 rồi TỰ HỦY).
   - **Ngày 15/10** (Thứ Năm): `HC 08:00 - 12:00 | Công: 4h` (Công lẻ thiếu 4h chiều $\rightarrow$ Chuẩn bị xin bù công **Giờ Ra `17:00`** để ĐƯỢC DUYỆT $\rightarrow$ 8.0h).
   - **Ngày 16/10** (Thứ Sáu): `HC 08:00 - 16:00 | Công: 7h` (Công lẻ thiếu 1h $\rightarrow$ Chuẩn bị xin bù công **Giờ Ra `17:00`** để BỊ TỪ CHỐI $\rightarrow$ giữ 7h).
   - **Ngày 24/10 & các ngày T7, CN**: `Công: 0h`.
4. Dừng 3-5 giây để đối soát trực quan bảng công Before.

---

### BƯỚC 3: NỘP & HỦY ĐƠN XIN BÙ CÔNG NGÀY 14/10/2026 (TEST TÍNH NĂNG TỰ HỦY ĐƠN)
*(Nhân viên nộp nhầm đơn xin bù công Giờ Ra 17:00 ngày 14/10/2026, sau đó tự bấm HỦY ĐƠN để bảo lưu 6.0h công lẻ ban đầu)*

1. Nhấp vào biểu tượng **Cửa sổ Windows 🪟** ở góc trên bên trái thanh Dock.
2. Tại ô Search của Launchpad, gõ: `Xin bù công`
3. Nhấp chọn biểu tượng menu **"Xin bù công"** (`MnuHRS033`).
4. Tại form Xin bù công:
   - Ô **Ngày (\*)**: Nhập ngày `14/10/2026`.
   - Ô **Giờ vào ra (\*)**: Chọn **`Ra`** (`value="2"`).
   - Ô **Thời gian (\*)**: Nhập `17:00`.
   - Tích chọn ô: **"Lỗi phần mềm"** *(⚠️ BẮT BUỘC: Phải tích chọn ô này để hệ thống bỏ qua luật chặn "Quá 3 ngày làm việc" khi bù công cho các ngày trong quá khứ!)*
   - Ô **Lý do bù công (\*)**: Nhập `Nộp nhầm đơn ngày 14/10 để test tính năng tự hủy đơn`
5. Nhấp nút **"Đăng ký"** (hoặc **"Gửi yêu cầu"**) màu xanh lá cây.
6. Popup xác nhận xuất hiện $\rightarrow$ Nhấp nút **"Đồng ý"**.
7. Chờ thông báo nộp đơn thành công.
8. Nhấp vào tab **"Lịch sử"** trên thanh tab của form:
   - Quan sát thấy thẻ đơn ngày **14/10/2026** xuất hiện với trạng thái **"Chờ duyệt"**.
9. **TIẾN HÀNH HỦY ĐƠN TRỰC TIẾP**:
   - Nhấp chuột trực tiếp vào **Thẻ ngày 14/10/2026** trong danh sách lịch sử.
   - Hệ thống chuyển về màn hình chi tiết đơn và hiển thị nút màu đỏ **"Xin hủy đơn"** ở góc dưới.
   - Nhấp vào nút **"Xin hủy đơn"**.
   - Popup modal hủy đơn xuất hiện: Tại ô **Ghi chú**, gõ lý do: `Tôi nộp nhầm ngày cần hủy đơn bù công ngày 14/10`.
   - Nhấp nút **"Xác nhận"** màu đỏ trong popup.
   - Hệ thống hiển thị thông báo: *"Yêu cầu hủy đơn của bạn đã được gửi thành công"*.
   - Nhấp lại vào tab **"Lịch sử"**, quan sát thấy thẻ ngày **14/10/2026** đã chuyển sang trạng thái đã gửi yêu cầu hủy / không còn chờ duyệt công.
   - Dừng 3-5 giây để người xem quan sát rõ thao tác hủy.

---

### BƯỚC 4: NỘP ĐƠN 1 — XIN BÙ CÔNG NGÀY 15/10/2026 (ĐỂ FIX-6 PHÊ DUYỆT)
*(Đã làm sáng `08:00 - 12:00` = 4.0h, quên quẹt thẻ chiều $\rightarrow$ Xin bù **Giờ Ra `17:00`** để ghép đủ `08:00 - 17:00` = 8.0h công chuẩn)*

1. Di chuột sang cột **Sidebar bên trái** (dưới nhóm *Cổng thông tin nhân sự*) $\rightarrow$ Nhấp vào menu **"Xin bù công"** 📱 để hệ thống nạp lại form bù công mới toanh sẵn sàng cho ngày 15/10.
2. Tại form Xin bù công:
   - Ô **Ngày (\*)**: Nhập ngày `15/10/2026`.
   - Ô **Giờ vào ra (\*)**: Chọn **`Ra`** (`value="2"`).
   - Ô **Thời gian (\*)**: Nhập `17:00`.
   - Tích chọn ô: **"Lỗi phần mềm"** *(Bắt buộc tích chọn để bù công quá khứ)*
   - Ô **Lý do bù công (\*)**: Nhập `Quên quẹt thẻ ra về chiều 15/10 do tiếp khách ngoài văn phòng (vào 08:00 đã có sẵn)`
3. Nhấp nút **"Đăng ký"** (hoặc **"Gửi yêu cầu"**) màu xanh lá cây.
4. Popup xác nhận xuất hiện $\rightarrow$ Nhấp nút **"Đồng ý"**.
5. Chờ thông báo thành công biến mất.
6. Nhấp vào tab **"Lịch sử"**:
   - Quan sát thấy thẻ đơn ngày **15/10/2026** hiển thị trạng thái **"Chờ duyệt"**.
   - Dừng 3 giây đối soát.

---

### BƯỚC 5: NỘP ĐƠN 2 — XIN BÙ CÔNG NGÀY 16/10/2026 (ĐỂ FIX-6 TỪ CHỐI / REJECT)
*(Đã làm `08:00 - 16:00` = 7.0h $\rightarrow$ Xin bù **Giờ Ra `17:00`** để kiểm chứng tính năng Từ chối và bảo lưu `7.0h` công lẻ)*

1. Tiếp tục di chuột sang cột **Sidebar bên trái** $\rightarrow$ Nhấp vào menu **"Xin bù công"** 📱 để nạp lại form bù công mới toanh sẵn sàng cho ngày 16/10.
2. Tại form:
   - Ô **Ngày (\*)**: Nhập ngày `16/10/2026`.
   - Ô **Giờ vào ra (\*)**: Chọn **`Ra`** (`value="2"`).
   - Ô **Thời gian (\*)**: Nhập `17:00`.
   - Tích chọn ô: **"Lỗi phần mềm"** *(Bắt buộc tích chọn để bù công quá khứ)*
   - Ô **Lý do bù công (\*)**: Nhập `Xin xác nhận làm đủ ca đến 17:00 ngày 16/10 do ra ngoài gặp đối tác`
3. Nhấp nút **"Đăng ký"** màu xanh lá cây.
4. Popup xác nhận xuất hiện $\rightarrow$ Nhấp nút **"Đồng ý"**.
5. Nhấp vào tab **"Lịch sử"**:
   - Quan sát thấy thẻ đơn ngày **16/10/2026** hiển thị trạng thái **"Chờ duyệt"**.
   - Dừng 3 giây đối soát.

---

### BƯỚC 6: NỘP ĐƠN 3 — XIN NGHỈ PHÉP NĂM AL NGÀY 24/10/2026 (HƯỞNG NGUYÊN LƯƠNG)
*(Nghỉ 1 ngày phép năm AL = 8.0h công chuẩn)*

1. Nhấp vào biểu tượng **Cửa sổ Windows 🪟** ở góc trên bên trái thanh Dock.
2. Tại ô Search của Launchpad, gõ: `Xin nghỉ phép`
3. Nhấp chọn biểu tượng menu **"Xin nghỉ phép"** (`MnuWPT315`).
4. Tại form Xin nghỉ phép:
   - Ô **Loại nghỉ (\*)**: Đảm bảo đang chọn `Phép năm` (mã `AL`).
   - Ô **Từ ngày (\*)**: Nhập `24/10/2026` (hoặc `24/10/2026 08:00`).
   - Ô **Đến ngày (\*)**: Nhập `24/10/2026` (hoặc `24/10/2026 17:00`).
   - Ô **Lý do (\*)**: Nhập `Giải quyết việc gia đình cá nhân`
5. Nhấp nút **"Đăng ký"** (hoặc **"Gửi đơn"**) màu xanh lá cây.
6. Popup xác nhận xuất hiện $\rightarrow$ Nhấp nút **"Đồng ý"**.
7. Chờ thông báo thành công.
8. Nhấp vào tab **"Lịch sử"** (thẻ `div.tab` có chữ "Lịch sử" cạnh tiêu đề menu):
   - Quan sát danh sách lịch sử hiển thị thẻ đơn ngày **24/10/2026** với trạng thái **"Đang duyệt / Chờ duyệt"**.
   - Dừng 3-5 giây đối soát.

---

### BƯỚC 7: NỘP ĐƠN 4 — XIN LÀM THÊM GIỜ TĂNG CA OT 2.0H NGÀY 20/10/2026
*(Tăng ca ngày làm việc 18:00 - 20:00 = 2.0h OT tính lương 150%)*

1. Nhấp vào biểu tượng **Cửa sổ Windows 🪟** ở góc trên bên trái thanh Dock.
2. Tại ô Search của Launchpad, gõ: `Xin tăng ca`
3. Nhấp chọn biểu tượng menu **"Xin tăng ca"** (`MnuWPT316`).
4. Tại form Xin tăng ca:
   - Ô **Ngày**: Nhập ngày `20/10/2026`.
   - *Dừng 1-2 giây để hệ thống tự động nạp Ca làm việc và Loại đơn*.
   - Ô **Từ giờ (\*)**: Nhập `18:00`.
   - Ô **Đến giờ (\*)**: Nhập `20:00`.
   - Ô **Số giờ (\*)**: Nhập `2`.
   - Ô **Nội dung (\*)**: Nhập `Tăng ca hỗ trợ release dự án`
5. Nhấp nút **"Thêm vào danh sách"** màu xanh lá cây.
6. Quan sát thấy 1 dòng dữ liệu xuất hiện trong bảng danh sách tăng ca ở dưới.
7. Cuộn màn hình xuống dưới cùng, nhấp nút **"Đăng ký"** màu xanh lá cây.
8. Popup xác nhận xuất hiện $\rightarrow$ Nhấp nút **"Có"** (hoặc nút xác nhận màu xanh).
9. Nhấp vào tab **"Lịch sử"** (`div.menu-tab` có chữ "Lịch sử" trên thanh tiêu đề):
   - Quan sát thấy thẻ đơn tăng ca ngày **20/10/2026 (2.0 giờ)** với trạng thái **"Chờ duyệt"**.
   - Dừng 3-5 giây đối soát.

---

### BƯỚC 8: ĐĂNG XUẤT VÀ KẾT THÚC QUÁ TRÌNH RECORDING
1. Nhấp vào **Avatar người dùng** ở góc trên cùng bên phải màn hình.
2. Nhấp chọn menu **"Đăng xuất"**.
3. Hệ thống quay trở lại màn hình Đăng nhập ban đầu.
4. Trên cửa sổ Chrome DevTools Recorder:
   - Nhấp nút **"End recording"** màu đỏ ở góc dưới để dừng ghi hình.
   - Nhấp vào biểu tượng **Export** (hình mũi tên trỏ xuống $\downarrow$ cạnh tiêu đề bản ghi).
   - Chọn mục **"Export as a JSON file"**.
   - Lưu file với tên `fix5-recording.json` (hoặc tên tùy ý).
5. Gửi file JSON đó qua đây cho Agent để chuyển đổi thành kịch bản Playwright hoàn chỉnh!

---

## 🎯 BẢNG ĐỐI SOÁT KẾT QUẢ CÁC ĐƠN TỪ SAU KHI THỰC HIỆN
| Loại Đơn | Ngày Áp Dụng | Thời Gian / Khối Lượng | Mục Đích Khi Fix-6 Xử Lý / Kết Quả |
| :--- | :---: | :---: | :--- |
| **Đơn Bù công (HỦY)** | 14/10/2026 | 07:00 - 14:00 (bù 2h) | **NHÂN VIÊN TỰ HỦY ĐƠN** $\rightarrow$ Giữ nguyên 6.0h công lẻ |
| **Đơn Bù công 1** | 15/10/2026 | 08:00 - 17:00 (bù 4h) | **Fix-6 DUYỆT** $\rightarrow$ Bù đủ thành 8.0h công chuẩn |
| **Đơn Bù công 2** | 16/10/2026 | 08:00 - 17:00 (bù 1h) | **Fix-6 TỪ CHỐI (REJECT)** $\rightarrow$ Giữ nguyên 7.0h công lẻ |
| **Đơn Nghỉ phép AL** | 24/10/2026 | 1.0 ngày (8.0h) | **Fix-6 DUYỆT** $\rightarrow$ Nghỉ phép AL hưởng 100% lương |
| **Đơn Tăng ca OT** | 20/10/2026 | 18:00 - 20:00 (2.0h) | **Fix-6 DUYỆT** $\rightarrow$ Tính 2.0h OT ngày thường hệ số 1.5 |
| **Đơn Bù công 2** | 16/10/2026 | 08:00 - 17:00 (bù 1h) | **Fix-6 TỪ CHỐI (REJECT)** $\rightarrow$ Giữ nguyên 7.0h công lẻ |
| **Đơn Nghỉ phép AL** | 24/10/2026 | 1.0 ngày (8.0h) | **Fix-6 DUYỆT** $\rightarrow$ Nghỉ phép AL hưởng 100% lương |
| **Đơn Tăng ca OT** | 20/10/2026 | 18:00 - 20:00 (2.0h) | **Fix-6 DUYỆT** $\rightarrow$ Tính 2.0h OT ngày thường hệ số 1.5 |
