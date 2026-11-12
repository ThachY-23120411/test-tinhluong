# KỊCH BẢN KIỂM THỬ THỦ CÔNG (MANUAL TEST SCRIPT) - PHÂN VÙNG FIX-6
> **QUY TRÌNH**: Thẩm định & Phê duyệt phân cấp đơn từ cho Nhân viên mới `099 - Nguyễn Văn Test`  
> **ĐẶC TẢ NGHIỆP VỤ NÂNG CAO**:
> - Duyệt đơn Nghỉ phép AL ngày 24/10 (1 ngày) & Tăng ca OT ngày 20/10 (2h).
> - **Duyệt đơn Bù công ngày 15/10** (từ 07:00 - 12:00 bù thành đủ 8.0h).
> - **TỪ CHỐI (REJECT) đơn Bù công ngày 16/10** (làm từ 07:00 - 15:00, giữ nguyên công lẻ 7.0h).
> - **Đối soát công lẻ ngày 14/10** (làm từ 07:00 - 14:00, không xin bù công, giữ nguyên công lẻ 6.0h).
> - **Đối soát 2 ngày làm đủ ca chuẩn**: Ngày 12/10 và 13/10 (08:00 - 17:00, đủ 8.0h công).
> **DANH SÁCH TEST CASE**: `TC-10`, `TC-11`, `TC-12`, `TC-13`  
> **MÔI TRƯỜNG KIỂM THỬ**: Google Chrome - Web Paradise HRM: `https://paradisehrm.com/Tai3/`  
> **CƠ SỞ DỮ LIỆU**: `Vietinsoft_ForTest_Tai2` (SQL Server)  

---

> [!IMPORTANT]
> ### 🛠️ BƯỚC 0 (TIỀN ĐỀ BẮT BUỘC): CHẠY SCRIPT LÀM SẠCH VÀ SCRIPT SEED CÔNG RIÊNG BIỆT
> Trước khi thực hiện test thủ công hoặc khi cần chạy lại phiên test mới, mở SQL Server Management Studio (SSMS), kết nối CSDL `Vietinsoft_ForTest_Tai2` và thực thi lần lượt 2 file riêng biệt sau:
> 
> #### 🧹 Bước 0.1: Chạy Script làm sạch môi trường & xóa đơn từ cũ
> - Mở file: 📁 [**`scripts/clean_test_requests_fix5.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/clean_test_requests_fix5.sql)
> - Bấm `Ctrl + F5` kiểm tra cú pháp và bấm `F5` để thực thi.
> - *Mục đích*: Xóa sạch đơn bù công, đơn phép, đơn OT cũ; cấp lại 2 ngày phép năm và reset bảng chấm công tháng 10/2026 về trạng thái sạch ban đầu.
> 
> #### 🌱 Bước 0.2: Chạy Script nạp 5 ngày công mẫu
> - Mở file: 📁 [**`scripts/seed_attendance_5days_nv099.sql`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/scripts/seed_attendance_5days_nv099.sql)
> - Bấm `Ctrl + F5` kiểm tra cú pháp và bấm `F5` để thực thi.
> - *Mục đích*: Nạp chính xác 5 ngày công mẫu vào `tblHasTA` cho NV 099 theo bảng đối soát dưới đây:
> 
> **Bảng 5 ngày công mẫu được nạp trong `tblHasTA`**:
> | Ngày | Thứ | Ca làm việc | Giờ Vào | Giờ Ra | Giờ Công | Mục đích Kiểm thử |
> | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
> | **12/10/2026** | Thứ Hai | HC (Hành chính) | 08:00 | 17:00 | **8.0h** (1.0 công) | Full ca tiêu chuẩn |
> | **13/10/2026** | Thứ Ba | HC (Hành chính) | 08:00 | 17:00 | **8.0h** (1.0 công) | Full ca tiêu chuẩn |
> | **14/10/2026** | Thứ Tư | HC (Hành chính) | 07:00 | 14:00 | **6.0h** (0.75 công) | **Công lẻ tự nhiên** (KHÔNG xin bù công) |
> | **15/10/2026** | Thứ Năm | HC (Hành chính) | 07:00 | 12:00 | **4.0h** (0.5 công) | **Test bù công và ĐƯỢC DUYỆT** ($\rightarrow$ lên 8.0h) |
> | **16/10/2026** | Thứ Sáu | HC (Hành chính) | 07:00 | 15:00 | **7.0h** (0.875 công) | **Test bù công và BỊ TỪ CHỐI** ($\rightarrow$ giữ nguyên 7.0h) |

---

## 📝 PHẦN A: TIỀN ĐỀ NỘP ĐƠN TỪ TÀI KHOẢN NHÂN VIÊN 099 (NGUYỄN VĂN TEST)
*(Thực hiện nếu bạn muốn test toàn trình từ khâu nộp đơn trên giao diện ESS)*

- **Tài khoản**: `099` | Mật khẩu: `123` (Nguyễn Văn Test).
- **Quy trình nộp các đơn**:
  1. **Đơn 0: Nộp bù công ngày 14/10 & Tự bấm xin hủy đơn** (`sp_MakeupHours` / `MnuHRS033`):
     - Bấm nút **Cửa sổ Windows 🪟** $\rightarrow$ Tìm kiếm: `Xin bù công`.
     - Chọn Ngày: `14/10/2026`, Giờ vào: `14:00`.
     - Lý do: *"Tôi nộp nhầm ngày cần hủy đơn bù công ngày 14/10"*.
     - Bấm nút **Gửi yêu cầu** $\rightarrow$ Popup hiện ra $\rightarrow$ Bấm nút **Đồng ý**.
     - Chuyển sang tab **Lịch sử** $\rightarrow$ Nhấp chọn thẻ đơn ngày 14/10 vừa tạo $\rightarrow$ Bấm nút **Xin hủy đơn** (màu đỏ) $\rightarrow$ Nhập lý do hủy $\rightarrow$ Bấm **Xác nhận**.
  2. **Đơn 1: Xin bù công ngày 15/10** (`sp_MakeupHours` / `MnuHRS033`):
     - Nhấp lại vào menu `Xin bù công` bên Sidebar trái để nạp form mới.
     - Chọn Ngày: `15/10/2026`, Giờ vào: `08:00`, Giờ ra: `17:00`.
     - Lý do: *"Quên quẹt thẻ ra ngày 15/10 do tiếp khách tại sảnh"*.
     - Bấm nút **Gửi yêu cầu** $\rightarrow$ Bấm nút **Đồng ý**.
  3. **Đơn 2: Xin bù công ngày 16/10** (`sp_MakeupHours` / `MnuHRS033`):
     - Nhấp lại vào menu `Xin bù công` bên Sidebar trái để nạp form mới.
     - Chọn Ngày: `16/10/2026`, Giờ vào: `08:00`, Giờ ra: `17:00`.
     - Lý do: *"Xin xác nhận làm đủ ca ngày 16/10 do ra ngoài gặp đối tác"*.
     - Bấm nút **Gửi yêu cầu** $\rightarrow$ Bấm nút **Đồng ý**.
  4. **Đơn 3: Xin nghỉ phép năm AL ngày 24/10** (`MnuWPT315`):
     - Bấm nút **Cửa sổ Windows 🪟** $\rightarrow$ Tìm kiếm: `Xin nghỉ phép`.
     - Chọn Loại nghỉ: `AL - Phép năm`.
     - Từ ngày: `24/10/2026` - Đến ngày: `24/10/2026` (1 ngày).
     - Bấm nút **Gửi yêu cầu**.
  5. **Đơn 4: Xin làm thêm giờ Tăng ca OT ngày 20/10** (`MnuWPT316`):
     - Bấm nút **Cửa sổ Windows 🪟** $\rightarrow$ Tìm kiếm: `Xin tăng ca`.
     - Chọn Ngày tăng ca: `20/10/2026`.
     - Từ giờ: `18:00` - Đến giờ: `20:00` (2.0 giờ OT).
     - Bấm nút **Thêm vào danh sách** $\rightarrow$ Bấm nút **Gửi yêu cầu**.
  6. **Đăng xuất**: Bấm Avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

---

## 📋 [TC-10]: Quản lý Trí Nguyễn thẩm định Cấp 1 — Duyệt đơn 15/10, Từ chối đơn 16/10 & Duyệt hủy đơn 14/10

- **Mục tiêu nghiệp vụ**:
  1. Thẩm định và **Phê duyệt Cấp 1** Đơn Nghỉ phép AL ngày `24/10/2026`.
  2. Thẩm định và **Phê duyệt Cấp 1** Đơn Bù công ngày `15/10/2026` (làm 7h-12h).
  3. Thẩm định và **TỪ CHỐI (REJECT) Cấp 1** Đơn Bù công ngày `16/10/2026` (làm 7h-15h) để kiểm chứng công lẻ giữ nguyên.
  4. Thẩm định và **PHÊ DUYỆT YÊU CẦU HỦY ĐƠN** Bù công ngày `14/10/2026` (nhân viên xin hủy đơn nộp nhầm) $\rightarrow$ Đơn chuyển sang Đã hủy (Cancelled).
- **Tài khoản thực hiện**: `tri.nguyen` | Mật khẩu: `123` (Mr. TRÍ [004] - Quản lý Cấp 1).
- **Màn hình thực hiện**: `MnuWPT037` (Danh sách phê duyệt).

### Các bước thao tác chi tiết (Step-by-Step):
1. **Đăng nhập**: Mở Google Chrome truy cập `https://paradisehrm.com/Tai3/` $\rightarrow$ Đăng nhập `tri.nguyen` / `123`.
2. **Mở Danh sách phê duyệt**:
   - Nhấp vào biểu tượng **Cửa sổ Windows** 🪟 ở góc trên bên trái thanh Dock (Menu Trang chủ).
   - Tại ô tìm kiếm **"Search"** giữa màn hình Launchpad $\rightarrow$ Gõ: `Danh sách phê duyệt`.
   - Nhấp chọn icon **"Danh sách phê duyệt"** (`MnuWPT037`).
3. **Thao tác 1 — Phê duyệt Đơn Nghỉ phép AL 24/10**:
   - Tìm thẻ đơn của `Nguyễn Văn Test - 099` (Loại đơn: *Xin nghỉ phép*, ngày 24/10).
   - Nhấp chọn thẻ đơn $\rightarrow$ Hệ thống mở tab **"Xin nghỉ phép"**.
   - Cuộn màn hình xuống dưới, nhấp vào nút **"Duyệt"** màu xanh lá cây trên form.
   - Modal popup xác nhận bật lên $\rightarrow$ Nhấp nút **"Duyệt"** màu xanh trong Modal.
   - Thông báo hiển thị: *"Đơn nghỉ phép đã được duyệt thành công!"*.
4. **Thao tác 2 — Phê duyệt Đơn Bù công 15/10 (Được duyệt)**:
   - Nhấp lại vào tab **"Danh sách phê duyệt"** trên thanh Top Tab Bar $\rightarrow$ Bấm nút Làm mới (`↻`).
   - Nhấp chọn thẻ đơn *Xin xác nhận công* ngày **`15/10/2026`** của NV 099.
   - Hệ thống chuyển sang tab **"Xin bù công"**.
   - Cuộn màn hình xuống phía dưới, nhấp vào nút **"Duyệt"** màu xanh lá cây trên form.
   - Modal popup hiện ra $\rightarrow$ Nhấp nút **"Duyệt"** trong Modal để xác nhận.
   - Thông báo phê duyệt thành công hiển thị $\rightarrow$ Đơn 15/10 đã hoàn tất Cấp 1, chuyển lên Cấp 2 của Trường Long.
5. **Thao tác 3 — TỪ CHỐI (REJECT) Đơn Bù công 16/10 (Xem công lẻ)**:
   - Nhấp lại vào tab **"Danh sách phê duyệt"** $\rightarrow$ Bấm nút Làm mới (`↻`).
   - Nhấp chọn thẻ đơn *Xin xác nhận công* ngày **`16/10/2026`** của NV 099.
   - Hệ thống chuyển sang tab **"Xin bù công"**.
   - Cuộn màn hình xuống phía dưới thanh công cụ nút bấm.
   - 👉 **Nhấp vào nút "Từ chối" / "Không duyệt" (MÀU ĐỎ - btnReject)** cạnh nút Duyệt.
   - Modal popup bật lên kèm ô nhập lý do từ chối $\rightarrow$ Nhập nội dung:  
     `"Lý do ra về sớm lúc 15:00 không chính đáng, từ chối duyệt bù công"`
   - Nhấp vào nút **"Từ chối" (Màu đỏ)** trong Modal để xác nhận.
   - Thông báo từ chối thành công hiển thị $\rightarrow$ Đơn chuyển sang trạng thái **Từ chối (Reject)**.
6. **Thao tác 4 — PHÊ DUYỆT YÊU CẦU HỦY ĐƠN ngày 14/10 (Nếu có yêu cầu xin hủy)**:
   - Nhấp lại vào tab **"Danh sách phê duyệt"** $\rightarrow$ Bấm nút Làm mới (`↻`).
   - Nhấp chọn thẻ đơn *Xin xác nhận công* ngày **`14/10/2026`** của NV 099 (trên thẻ ghi trạng thái *"Xin hủy đăng ký"* kèm lý do *"Tôi nộp nhầm ngày cần hủy"*).
   - Hệ thống chuyển sang tab **"Xin bù công"**.
   - Cuộn màn hình xuống phía dưới, nhấp vào nút **"Duyệt"** (màu xanh lá cây) để chấp thuận cho nhân viên hủy đơn này.
   - Modal popup xác nhận bật lên $\rightarrow$ Nhấp nút **"Duyệt"** trong Modal.
   - Thông báo thành công hiển thị $\rightarrow$ Đơn chuyển sang trạng thái **Đã hủy hoàn tất (Cancelled)**.
7. **Kiểm chứng sau khi thao tác Cấp 1**:
   - Bấm nút Làm mới (`↻`) trên Danh sách phê duyệt.
   - **Kết quả mong đợi**: Toàn bộ các thẻ đơn của NV 099 đã biến mất khỏi danh sách chờ của Trí Nguyễn:
     * Đơn Phép 24/10 & Đơn Bù 15/10 đã chuyển lên hàng đợi Cấp 2 của Trường Long.
     * Đơn Bù 16/10 (Bị Từ chối) và Đơn Bù 14/10 (Đã Duyệt Hủy) đã kết thúc, **tuyệt đối không** chuyển lên Cấp 2.
8. **Đăng xuất**: Bấm avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

---

## 📋 [TC-11]: Quản lý Trường Long phê duyệt Cấp 1 đơn Tăng ca OT 20/10

- **Mục tiêu nghiệp vụ**: Thẩm định và Phê duyệt Cấp 1 cho Đơn xin làm thêm giờ OT ngày `20/10/2026` (2.0 giờ OT, từ 18:00 đến 20:00) của `099 - Nguyễn Văn Test`.
- **Tài khoản thực hiện**: `LongKa` | Mật khẩu: `123` (Mr. LONG [012] - Quản lý Cấp 1 Tăng ca theo ma trận Group 6).
- **Màn hình thực hiện**: `MnuWPT037` (Danh sách phê duyệt).

### Các bước thao tác chi tiết (Step-by-Step):
1. **Đăng nhập**: Nhập Tên đăng nhập `LongKa`, Mật khẩu `123` $\rightarrow$ Bấm nút **Đăng nhập**.
2. **Mở Danh sách phê duyệt**:
   - Nhấp vào biểu tượng **Cửa sổ Windows** 🪟 ở thanh Dock.
   - Gõ `Danh sách phê duyệt` vào ô **Search** Launchpad $\rightarrow$ Nhấp mở menu (`MnuWPT037`).
3. **Phê duyệt đơn Tăng ca**:
   - Tìm thẻ đơn của `Nguyễn Văn Test - 099` (Loại đơn: *Làm thêm giờ* ngày 20/10/2026, 2.0h).
   - Nhấp chọn thẻ đơn $\rightarrow$ Hệ thống tự động mở tab **"Xin tăng ca"**.
   - Cuộn màn hình xuống dưới cùng bảng danh sách phân công tăng ca.
   - Nhấp vào nút **"Duyệt"** màu xanh lá cây $\rightarrow$ Nhấp nút **"Duyệt"** màu xanh trong Modal xác nhận.
   - Chờ hệ thống hiển thị thông báo phê duyệt thành công.
4. **Kiểm chứng sau khi duyệt Cấp 1 OT**:
   - Nhấp lại vào tab **"Danh sách phê duyệt"** $\rightarrow$ Bấm nút Làm mới (`↻`).
   - Thẻ đơn tăng ca của NV 099 đã biến mất khỏi danh sách chờ Cấp 1 của LongKa (chuyển lên hàng đợi Giám đốc Cường Vũ).
5. **Giữ nguyên phiên đăng nhập `LongKa`** để tiếp tục thực hiện Pha 1 của TC-12.

---

## 📋 [TC-12]: Phê duyệt Cấp 2 chặng cuối (Trường Long & Giám đốc Cường Vũ)

- **Mục tiêu nghiệp vụ**: Phê duyệt chặng cuối (Final Approval Cấp 2) cho các đơn hợp lệ của nhân viên `099`:
  - Đơn Nghỉ phép AL 24/10 & Đơn Bù công 15/10: Duyệt Cấp 2 bởi Quản lý Trường Long (`LongKa`).
  - Đơn Tăng ca OT 20/10: Duyệt Cấp 2 chặng cuối bởi Giám đốc / HR Admin Cường Vũ (`cuong.vu`).
  - *(Đơn Bù công 16/10 đã bị từ chối ở TC-10 nên KHÔNG xuất hiện ở Cấp 2)*.
- **Màn hình thực hiện**: `MnuWPT037` (Danh sách phê duyệt).

### Các bước thao tác chi tiết (Step-by-Step):

#### 🔹 Pha 1: Quản lý Trường Long duyệt Cấp 2 Đơn Phép AL & Đơn Bù công 15/10
1. Tiếp tục phiên đăng nhập `LongKa` $\rightarrow$ Nhấp vào tab **"Danh sách phê duyệt"** $\rightarrow$ Bấm nút Làm mới (`↻`).
2. Quan sát danh sách: **Chỉ có đúng 02 thẻ đơn Cấp 2** của `Nguyễn Văn Test - 099` (Đơn 16/10 bị từ chối không có mặt tại đây).
3. **Duyệt Đơn 1 (Nghỉ phép AL ngày 24/10)**:
   - Nhấp chọn thẻ Nghỉ phép của NV 099 $\rightarrow$ Mở tab Xin nghỉ phép.
   - Cuộn xuống dưới, kiểm tra avatar `Mr. LONG [012]` hiển thị trạng thái *"Đang duyệt"*.
   - Nhấp nút **"Duyệt"** màu xanh $\rightarrow$ Nhấp nút **"Duyệt"** trong Modal xác nhận.
4. **Duyệt Đơn 2 (Bù công ngày 15/10)**:
   - Quay lại tab Danh sách phê duyệt $\rightarrow$ Nhấp chọn thẻ Bù công ngày 15/10 của NV 099 $\rightarrow$ Mở tab Xin bù công.
   - Cuộn xuống dưới, nhấp nút **"Duyệt"** màu xanh $\rightarrow$ Nhấp nút **"Duyệt"** trong Modal xác nhận.
   - Khi hoàn tất duyệt Cấp 2, hệ thống tự động nạp giờ ra về `17:00` và tính đủ `8.0 giờ công` cho ngày 15/10 trong CSDL.
5. Bấm Làm mới (`↻`) trên danh sách phê duyệt $\rightarrow$ Kiểm tra không còn thẻ nào của NV 099.
6. Bấm Avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

#### 🔹 Pha 2: Giám đốc Cường Vũ duyệt Cấp 2 chặng cuối Đơn Tăng ca OT
1. Đăng nhập tài khoản Giám đốc: Tên đăng nhập `cuong.vu` | Mật khẩu: `123`.
2. Nhấp biểu tượng **Cửa sổ Windows** 🪟 trên thanh Dock $\rightarrow$ Gõ `Danh sách phê duyệt` vào ô Search $\rightarrow$ Mở menu.
3. Tìm thẻ đơn tăng ca ngày 20/10 của `Nguyễn Văn Test - 099` (Group 6: Tăng ca OT).
4. Nhấp chọn thẻ đơn $\rightarrow$ Hệ thống chuyển sang form Xin tăng ca.
5. Cuộn xuống dưới cùng, nhấp vào nút **"Duyệt"** màu xanh lá cây $\rightarrow$ Nhấp nút **"Duyệt"** trong Modal.
6. Quay lại tab Danh sách phê duyệt, bấm nút Làm mới $\rightarrow$ Thẻ đơn tăng ca đã hoàn tất duyệt chặng cuối.
7. **Giữ nguyên phiên đăng nhập `cuong.vu`** để thực hiện tiếp TC-13.

---

## 📋 [TC-13]: Đối soát toàn diện công lẻ, công bù và tổng hợp công cả tháng

- **Mục tiêu nghiệp vụ**: Giám đốc / HR Admin Cường Vũ đối soát toàn diện kết quả trên giao diện:
  1. Ngày 12/10 & 13/10: Làm full ca chuẩn đủ `8.0h công`.
  2. Ngày 14/10: Giữ nguyên **công lẻ `6.0 giờ`** (làm 7h-14h, không xin bù).
  3. Ngày 15/10: Nhảy từ `4.0 giờ` lên **đủ `8.0 giờ công`** (nhờ đơn bù công được duyệt cả 2 cấp).
  4. Ngày 16/10: Giữ nguyên **công lẻ `7.0 giờ`** (làm 7h-15h, đơn bù công bị từ chối / reject).
  5. Ngày 20/10: Tăng ca `2.0 giờ OT`.
  6. Ngày 24/10: Nghỉ phép năm AL hưởng `1.0 ngày` lương.
  7. Tổng hợp công cả tháng (`MnuTAD1000`): Phản ánh chính xác tổng giờ công thực tế và ngày công lẻ.
- **Tài khoản thực hiện**: `cuong.vu` / `123` (Giám đốc / HR Admin).
- **Màn hình thực hiện**: `MnuHRS225` (Xem dữ liệu chấm công hằng ngày) & `MnuTAD1000` (Tổng hợp công cả tháng).

### Các bước thao tác chi tiết (Step-by-Step):

#### 🔹 Bước 1: Đối soát chi tiết từng ngày công trên MnuHRS225
1. Nhấp vào biểu tượng **Cửa sổ Windows** 🪟 ở góc trên bên trái thanh Dock.
2. Tại ô Search của Launchpad, gõ: `Xem dữ liệu chấm công hằng ngày`.
3. Nhấp mở icon **"Xem dữ liệu chấm công hằng ngày"** (`MnuHRS225`).
4. Tại ô tìm kiếm của bảng dữ liệu DataGrid (phía bên phải thanh công cụ trên lưới):
   - Nhập mã nhân viên: `099`.
5. **Đối soát đối chiếu chi tiết từng ngày**:
   - **Ngày 12/10 & 13/10/2026**:
     * GIỜ VÀO: `08:00` | GIỜ RA: `17:00`.
     * GIỜ CÔNG: **`8.0 giờ`** (1.0 ngày chuẩn).
   - **Ngày 14/10/2026 (CÔNG LẺ - KHÔNG XIN BÙ)**:
     * GIỜ VÀO: `07:00` | GIỜ RA: `14:00`.
     * GIỜ CÔNG: **`6.0 giờ`** (Công lẻ, đạt 0.75 ngày công).
   - **Ngày 15/10/2026 (ĐƯỢC BÙ CÔNG THÀNH CÔNG)**:
     * GIỜ VÀO: `08:00` (hoặc `07:00`) | GIỜ RA: `17:00` (đã được nạp giờ ra đủ ca).
     * GIỜ CÔNG: **`8.0 giờ`** (Nhảy từ 4.0h lên đủ 8.0h công chuẩn).
   - **Ngày 16/10/2026 (CÔNG LẺ - ĐƠN BÙ CÔNG BỊ TỪ CHỐI)**:
     * GIỜ VÀO: `07:00` | GIỜ RA: `15:00` (không đổi, không được nạp giờ 17:00).
     * GIỜ CÔNG: **`7.0 giờ`** (Giữ nguyên công lẻ 7.0h do đơn bị Reject).
   - **Ngày 20/10/2026**:
     * Cột TĂNG CA: Hiển thị **`2.0 giờ OT`**.
   - **Ngày 24/10/2026**:
     * Cột NGHỈ PHÉP: Hiển thị mã **`AL`** (Phép năm hưởng lương).

#### 🔹 Bước 2: Đối soát bảng Tổng hợp công cả tháng trên MnuTAD1000
1. Nhấp vào biểu tượng **Cửa sổ Windows** 🪟 ở góc trên bên trái thanh Dock.
2. Tại ô Search của Launchpad, gõ: `Tổng hợp công cả tháng`.
3. Nhấp mở icon **"Tổng hợp công cả tháng"** (`MnuTAD1000`).
4. Tại ô tìm kiếm của bảng DataGrid (phía bên phải bảng):
   - Nhập mã nhân viên: `099`.
5. **Quan sát các chỉ số công tháng**:
   - **Tổng giờ làm việc thực tế (ATTHours)**:
     $$\text{Tổng giờ} = 8.0 + 8.0 + 6.0 + 8.0 + 7.0 = 37.0 \text{ giờ}$$
   - **Số ngày công thực tế (AttDays)**:
     $$\text{Ngày công} = 1.0 + 1.0 + 0.75 + 1.0 + 0.875 = 4.625 \text{ ngày}$$
     *(Thể hiện rõ ràng phần ngày công lẻ do 2 ngày công lẻ 14/10 và 16/10 mang lại)*.
   - **Cột NGHỈ HƯỞNG LƯƠNG (PaidLeaves / AL)**: Hiển thị **`1.0 ngày`**.
   - **Cột TĂNG CA 150%**: Hiển thị **`2.0 giờ`**.
6. **Đăng xuất**: Bấm avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

---

## 🎯 BẢNG TỔNG HỢP TRUY VẤN ĐỐI SOÁT CƠ SỞ DỮ LIỆU (DATABASE VERIFICATION)

Sau khi hoàn tất toàn bộ các bước kiểm thử thủ công trên giao diện, bạn có thể dán đoạn script SQL sau vào SSMS và bấm `F5` để đối chiếu kết quả kỹ thuật tức thì:

```sql
-- 1. Kiểm tra trạng thái các đơn Bù công (Kỳ vọng: 15/10 đã duyệt = 2; 16/10 bị từ chối = 3; 14/10 đã duyệt hủy = 4)
SELECT 
    IdentityID,
    CONVERT(varchar, AttDate, 23) AS [Ngày bù công],
    In1, Out1,
    Current_Approve_Level AS [Cấp duyệt],
    Approve_Status AS [Mã TT],
    CASE Approve_Status 
        WHEN 1 THEN N'Chờ duyệt'
        WHEN 2 THEN N'ĐÃ DUYỆT HOÀN TẤT'
        WHEN 3 THEN N'BỊ TỪ CHỐI (REJECTED)'
        WHEN 4 THEN N'ĐÃ DUYỆT HỦY ĐƠN (CANCELLED)'
        WHEN 5 THEN N'Chờ duyệt hủy đơn'
        ELSE N'Khác'
    END AS [Trạng thái],
    ApproverRemark AS [Ghi chú Người duyệt]
FROM tblAttendanceConfirmRequest 
WHERE EmployeeID = '099'
ORDER BY AttDate;

-- 2. Kiểm tra trạng thái đơn Nghỉ phép AL 24/10 (Kỳ vọng: Approve_Status = 2 - ĐÃ DUYỆT)
SELECT 
    EmployeeID, LeaveCode, 
    CONVERT(varchar, LeaveFromDate, 23) AS [Từ ngày],
    CONVERT(varchar, LeaveToDate, 23) AS [Đến ngày],
    Approve_Status AS [Mã TT],
    CASE Approve_Status WHEN 2 THEN N'Đã duyệt hoàn tất' ELSE N'Chờ duyệt' END AS [Trạng thái]
FROM tblLeaveRegistered 
WHERE EmployeeID = '099' AND LeaveFromDate >= '2026-10-24';

-- 3. Kiểm tra trạng thái đơn Tăng ca OT 20/10 (Kỳ vọng: Approved_Status = 4 - ĐÃ DUYỆT CHẶNG CUỐI)
SELECT 
    DetailID, EmployeeID, 
    CONVERT(varchar, OTDate, 23) AS [Ngày OT],
    OTHour AS [Số giờ OT],
    Approved_Status AS [Mã TT],
    CASE Approved_Status WHEN 4 THEN N'Đã duyệt Cấp 2 chặng cuối' ELSE N'Chờ duyệt' END AS [Trạng thái]
FROM tblOvertime_Assignment_Detail 
WHERE EmployeeID = '099' AND CONVERT(varchar, OTDate, 23) = '2026-10-20';

-- 4. Kiểm tra đối soát 5 ngày công trong tblHasTA:
SELECT 
    CONVERT(varchar, AttDate, 23) AS [Ngày],
    DATENAME(dw, AttDate) AS [Thứ],
    CONVERT(varchar(5), AttStart, 108) AS [Giờ Vào],
    CONVERT(varchar(5), AttEnd, 108) AS [Giờ Ra],
    WorkingTime AS [Giờ Công],
    CAST(ROUND(WorkingTime / 8.0, 3) AS decimal(5,3)) AS [Quy đổi ngày công],
    CASE 
        WHEN CONVERT(varchar, AttDate, 23) IN ('2026-10-12', '2026-10-13') THEN N'Full 8.0h chuẩn'
        WHEN CONVERT(varchar, AttDate, 23) = '2026-10-14' THEN N'Công lẻ 6.0h (Không xin bù)'
        WHEN CONVERT(varchar, AttDate, 23) = '2026-10-15' THEN N'ĐÃ BÙ ĐỦ 8.0H (Được duyệt)'
        WHEN CONVERT(varchar, AttDate, 23) = '2026-10-16' THEN N'GIỮ NGUYÊN CÔNG LẺ 7.0H (Bị từ chối)'
        ELSE N'Khác'
    END AS [Kết quả đối soát]
FROM tblHasTA
WHERE EmployeeID = '099' AND CONVERT(varchar, AttDate, 23) IN ('2026-10-12', '2026-10-13', '2026-10-14', '2026-10-15', '2026-10-16')
ORDER BY AttDate;
```
