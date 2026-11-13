# KỊCH BẢN KIỂM THỬ THỦ CÔNG: NỘP TOÀN BỘ 10 LOẠI ĐƠN NGHỈ PHÉP (FULL OPTIONS)
> **MÃ KỊCH BẢN**: `KB-FIX5-NEW`  
> **TÀI KHOẢN THỰC HIỆN**: `test.nv` / `123` (NV 099 - Nguyễn Văn Test)  
> **MENU THỰC HIỆN**: Cổng thông tin nhân sự > `Xin nghỉ phép` (`MnuWPT315`)  
> **THỜI GIAN KIỂM THỬ**: 10 ngày làm việc từ `22/10/2026` đến `04/11/2026` (Loại trừ Thứ 7 & Chủ nhật)  
> **CHẾ ĐỘ**: Kịch bản kiểm thử thủ công (Manual Testing Guide & Checklist)

---

## 🎯 1. MỤC TIÊU NGHIỆP VỤ (OBJECTIVE)

1. **Phủ kín 100% các tùy chọn loại nghỉ (10/10 Options)** trong combobox `Loại đơn` của hệ thống Paradise HRM để kiểm thử toàn diện khả năng xử lý nghiệp vụ, tính toán ngày/giờ nghỉ, lưu trữ CSDL và thẩm định duyệt đơn đa cấp.
2. **Khảo sát tác động phân loại lương**:
   * **Nhóm hưởng 100% nguyên lương (5 loại)**: `AL` (Phép năm), `PH` (Nghỉ lễ/Tết), `FLWD` (Đám tang/cưới hỏi), `CT` (Công tác), `WFH` (Làm online).
   * **Nhóm 0% lương công ty / hưởng chế độ BHXH (5 loại)**: `O` (Nghỉ ốm), `UL` (Nghỉ không lương), `ML` (Thai sản), `IO` (Đi trễ/về sớm), `PL` (Nghỉ vợ sinh).
3. **Đối soát tính toàn vẹn**: Mỗi ngày tương ứng với đúng 1 đơn, 1 loại nghỉ duy nhất vào 1 ngày làm việc chuẩn (8.0 giờ).

---

## 📅 2. MA TRẬN 10 NGÀY LÀM VIỆC & 10 LOẠI ĐƠN NGHỈ PHÉP

> [!NOTE]
> Khung thời gian từ **22/10/2026** đến **04/11/2026** có tổng cộng 14 ngày lịch, trong đó có **4 ngày cuối tuần** (24/10, 25/10, 31/10, 01/11) được loại trừ. Còn lại **chính xác 10 ngày làm việc (Thứ 2 đến Thứ 6)** khớp 1-1 với 10 tùy chọn trong combobox.

| STT | Ngày nghỉ | Thứ | Mã loại (`LeaveCode`) | Tên hiển thị Combobox | Tỷ lệ lương (`PaidRate`) | Khung giờ nghỉ | Quy đổi | Nội dung lý do mẫu |
|:---:|:---:|:---:|:---:|:---|:---:|:---:|:---:|:---|
| **01** | `22/10/2026` | Thứ 5 | `O` | **Nghỉ ốm (0%)** | 0% | 08:00 - 17:00 | 1 ngày (8h) | *"Sốt xuất huyết điều trị ngoại trú theo chỉ định của bác sĩ"* |
| **02** | `23/10/2026` | Thứ 6 | `AL` | **Phép năm (100%)** | 100% | 08:00 - 17:00 | 1 ngày (8h) | *"Giải quyết công việc gia đình cá nhân"* |
| -- | *24/10/2026* | *Thứ 7* | -- | *Nghỉ cuối tuần (Holiday)* | -- | -- | -- | *(Bỏ qua - không nộp đơn)* |
| -- | *25/10/2026* | *Chủ nhật* | -- | *Nghỉ cuối tuần (Holiday)* | -- | -- | -- | *(Bỏ qua - không nộp đơn)* |
| **03** | `26/10/2026` | Thứ 2 | `PH` | **Nghỉ lễ,Tết (100%)** | 100% | 08:00 - 17:00 | 1 ngày (8h) | *"Đăng ký nghỉ bù ngày lễ theo quy định công ty"* |
| **04** | `27/10/2026` | Thứ 3 | `UL` | **Nghỉ không lương (0%)** | 0% | 08:00 - 17:00 | 1 ngày (8h) | *"Việc riêng đột xuất, xin nghỉ không hưởng lương"* |
| **05** | `28/10/2026` | Thứ 4 | `ML` | **Thai sản (0%)** | 0% | 08:00 - 17:00 | 1 ngày (8h) | *"Khám thai định kỳ theo chế độ bảo hiểm xã hội"* |
| **06** | `29/10/2026` | Thứ 5 | `FLWD` | **Đám tang, cưới hỏi (100%)** | 100% | 08:00 - 17:00 | 1 ngày (8h) | *"Nghỉ tham dự lễ cưới người thân trong gia đình"* |
| **07** | `30/10/2026` | Thứ 6 | `CT` | **Công tác (100%)** | 100% | 08:00 - 17:00 | 1 ngày (8h) | *"Đi công tác thực địa hỗ trợ khách hàng chi nhánh miền Nam"* |
| -- | *31/10/2026* | *Thứ 7* | -- | *Nghỉ cuối tuần (Holiday)* | -- | -- | -- | *(Bỏ qua - không nộp đơn)* |
| -- | *01/11/2026* | *Chủ nhật* | -- | *Nghỉ cuối tuần (Holiday)* | -- | -- | -- | *(Bỏ qua - không nộp đơn)* |
| **08** | `02/11/2026` | Thứ 2 | `WFH` | **Làm online (100%)** | 100% | 08:00 - 17:00 | 1 ngày (8h) | *"Làm việc từ xa (Work From Home) xử lý tài liệu kỹ thuật"* |
| **09** | `03/11/2026` | Thứ 3 | `IO` | **Đi trễ, về sớm (0%)** | 0% | 08:00 - 17:00 | 1 ngày (8h) | *"Có việc gia đình đột xuất cả ngày xin xác nhận đi trễ về sớm"* |
| **10** | `04/11/2026` | Thứ 4 | `PL` | **Nghỉ vợ sinh (0%)** | 0% | 08:00 - 17:00 | 1 ngày (8h) | *"Nghỉ chăm sóc vợ sinh con theo chế độ Luật BHXH"* |

---

## 🏗️ 3. TIỀN ĐỀ DỮ LIỆU CSDL CẦN THIẾT (SEEDING STRATEGY)

> [!IMPORTANT]
> **YÊU CẦU ĐỐI VỚI DỮ LIỆU TRÊN CSDL TRƯỚC KHI THỰC HIỆN**:
> Để hệ thống cho phép tạo và duyệt đơn nghỉ phép hợp lệ trên cả 10 ngày này:
> 1. **Lịch ca làm việc (`tblWSchedule`)**:
>    * Cả 10 ngày làm việc (22/10 - 04/11, trừ T7/CN) bắt buộc phải có phân ca hành chính chuẩn (`ShiftID` hợp lệ, ví dụ `2..6`) và `HolidayStatus = 0`.
>    * Các ngày Thứ 7, Chủ nhật có `HolidayStatus = 1`.
> 2. **Dữ liệu chấm công thực tế (`tblHasTA`)**:
>    * Toàn bộ 10 ngày này phải **TRỐNG CÔNG** (`AttStart = NULL, AttEnd = NULL, RealWorkingTime = 0.0`), không có quẹt thẻ thực tế để đơn nghỉ phép được điền vào bù giờ công.

*(Khi bạn cần cập nhật script SQL seed, tôi sẽ tổng hợp sẵn câu lệnh an toàn để bạn tự chạy `F5` trên SSMS sau).*

---

## 📋 4. HƯỚNG DẪN THAO TÁC KIỂM THỬ THỦ CÔNG CHI TIẾT (STEP-BY-STEP)

### BƯỚC 1: ĐĂNG NHẬP VÀ MỞ MÀN HÌNH
1. Mở trình duyệt Chrome truy cập hệ thống: `https://paradisehrm.com/Tai3/#`.
2. Đăng nhập tài khoản nhân viên mới:
   * **Tên đăng nhập**: `test.nv`
   * **Mật khẩu**: `123`
3. Nhấp icon Windows (Launchpad) ở góc trái bên dưới (hoặc trên Dock).
4. Tìm kiếm từ khóa: `Xin nghỉ phép` (hoặc mở menu `MnuWPT315`).
5. Chờ màn hình **Xin nghỉ phép** xuất hiện với Form đăng ký.

---

### BƯỚC 2: THỰC HIỆN TẠO LẦN LƯỢT 10 ĐƠN NGHỈ PHÉP

Thực hiện chu trình sau cho từng đơn từ Đơn 1 đến Đơn 10:

#### 🔹 Đơn 1: Ngày 22/10/2026 - Nghỉ ốm (Mã: `O`)
1. **Loại nghỉ**: Nhấp vào ô chọn Loại nghỉ $\rightarrow$ Chọn **`Nghỉ ốm (0%)`**.
2. **Từ ngày**: Nhập `22/10/2026 08:00`.
3. **Đến ngày**: Nhập `22/10/2026 17:00`.
4. **Kiểm tra trường số ngày**: Hệ thống tự động hiển thị `1.0 ngày` (hoặc `8.0 giờ`).
5. **Lý do nghỉ**: Nhập: `Sốt xuất huyết điều trị ngoại trú theo chỉ định của bác sĩ`.
6. **Bấm nút Đăng ký**: Nhấp nút **Gửi đơn / Đăng ký** màu xanh (`#sp_ResignationLeave button.btnRegister`).
7. **Xác nhận Popup**: Hộp thoại xác nhận hiện ra $\rightarrow$ Nhấp **Đồng ý / Có**.
8. **Chuyển Tab Lịch sử**:
   * Nhấp sang tab **Lịch sử** (`#tabs .tab:has-text("Lịch sử")`).
   * Kiểm tra thẻ đơn ngày `22/10/2026` hiển thị với trạng thái: **Chờ duyệt (Pending)**.
9. **Quay lại Tab Đăng ký**: Nhấp lại tab **Đăng ký** để chuẩn bị nộp đơn tiếp theo.

---

#### 🔹 Đơn 2: Ngày 23/10/2026 - Phép năm (Mã: `AL`)
1. **Loại nghỉ**: Chọn **`Phép năm (100%)`**.
2. **Từ ngày**: Nhập `23/10/2026 08:00`.
3. **Đến ngày**: Nhập `23/10/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Giải quyết công việc gia đình cá nhân`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 3: Ngày 26/10/2026 - Nghỉ lễ, Tết (Mã: `PH`)
1. **Loại nghỉ**: Chọn **`Nghỉ lễ,Tết (100%)`**.
2. **Từ ngày**: Nhập `26/10/2026 08:00`.
3. **Đến ngày**: Nhập `26/10/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Đăng ký nghỉ bù ngày lễ theo quy định công ty`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 4: Ngày 27/10/2026 - Nghỉ không lương (Mã: `UL`)
1. **Loại nghỉ**: Chọn **`Nghỉ không lương (0%)`**.
2. **Từ ngày**: Nhập `27/10/2026 08:00`.
3. **Đến ngày**: Nhập `27/10/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Việc riêng đột xuất, xin nghỉ không hưởng lương`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 5: Ngày 28/10/2026 - Thai sản (Mã: `ML`)
1. **Loại nghỉ**: Chọn **`Thai sản (0%)`**.
2. **Từ ngày**: Nhập `28/10/2026 08:00`.
3. **Đến ngày**: Nhập `28/10/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Khám thai định kỳ theo chế độ bảo hiểm xã hội`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 6: Ngày 29/10/2026 - Đám tang, cưới hỏi (Mã: `FLWD`)
1. **Loại nghỉ**: Chọn **`Đám tang, cưới hỏi (100%)`**.
2. **Từ ngày**: Nhập `29/10/2026 08:00`.
3. **Đến ngày**: Nhập `29/10/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Nghỉ tham dự lễ cưới người thân trong gia đình`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 7: Ngày 30/10/2026 - Công tác (Mã: `CT`)
1. **Loại nghỉ**: Chọn **`Công tác (100%)`**.
2. **Từ ngày**: Nhập `30/10/2026 08:00`.
3. **Đến ngày**: Nhập `30/10/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Đi công tác thực địa hỗ trợ khách hàng chi nhánh miền Nam`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 8: Ngày 02/11/2026 - Làm online (Mã: `WFH`)
1. **Loại nghỉ**: Chọn **`Làm online (100%)`**.
2. **Từ ngày**: Nhập `02/11/2026 08:00`.
3. **Đến ngày**: Nhập `02/11/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Làm việc từ xa (Work From Home) xử lý tài liệu kỹ thuật`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 9: Ngày 03/11/2026 - Đi trễ, về sớm (Mã: `IO`)
1. **Loại nghỉ**: Chọn **`Đi trễ, về sớm (0%)`**.
2. **Từ ngày**: Nhập `03/11/2026 08:00`.
3. **Đến ngày**: Nhập `03/11/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Có việc gia đình đột xuất cả ngày xin xác nhận đi trễ về sớm`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử** $\rightarrow$ Quay lại tab Đăng ký.

---

#### 🔹 Đơn 10: Ngày 04/11/2026 - Nghỉ vợ sinh (Mã: `PL`)
1. **Loại nghỉ**: Chọn **`Nghỉ vợ sinh (0%)`**.
2. **Từ ngày**: Nhập `04/11/2026 08:00`.
3. **Đến ngày**: Nhập `04/11/2026 17:00`.
4. **Lý do nghỉ**: Nhập: `Nghỉ chăm sóc vợ sinh con theo chế độ Luật BHXH`.
5. **Gửi đơn**: Nhấp **Đăng ký** $\rightarrow$ Xác nhận Popup $\rightarrow$ Kiểm tra tab **Lịch sử**.

---

### BƯỚC 3: KIỂM TRA TỔNG THỂ & ĐĂNG XUẤT
1. Tại tab **Lịch sử**, cuộn kiểm tra toàn bộ danh sách:
   * Phải hiển thị đủ **10 thẻ đơn** với 10 ngày làm việc khác nhau.
   * Tất cả 10 đơn đều mang trạng thái: **Chờ duyệt (Pending)**.
2. Nhấp vào ảnh đại diện (Avatar) ở góc trên bên phải màn hình.
3. Nhấp **Đăng xuất** $\rightarrow$ Bấm nút xác nhận để thoát khỏi tài khoản `test.nv`.

---

## 🔍 5. TIÊU CHÍ NGHIỆM THU (ACCEPTANCE CRITERIA)

### 1. Nghiệm thu Giao diện người dùng (UI Checklist):
- [ ] Combobox hiển thị đủ 10 tùy chọn không bị mất dòng, không bị tràn viền.
- [ ] Chọn từng loại nghỉ thì ô nhập ngày tự động điền `08:00 - 17:00` và tính đúng `1 ngày`.
- [ ] Mỗi lần bấm gửi đơn có hiển thị popup xác nhận và thông báo lưu thành công.
- [ ] Tab Lịch sử hiển thị danh sách 10 thẻ đơn tương ứng với 10 loại nghỉ.

### 2. Nghiệm thu CSDL (Database Verification - Chế độ Read-Only):
Chạy câu lệnh kiểm tra sau trên SQL Server Management Studio (SSMS):

```sql
-- Kiểm tra 10 đơn nghỉ phép vừa đăng ký của NV 099
SELECT 
    IdentityID,
    EmployeeID,
    LeaveCode,
    CONVERT(varchar, LeaveFromDate, 120) AS FromDate,
    CONVERT(varchar, LeaveToDate, 120) AS ToDate,
    LeaveDays,
    LeaveHours,
    Reason,
    Approve_Status
FROM tblLeaveRegistered
WHERE EmployeeID = '099'
  AND LeaveFromDate >= '2026-10-22'
  AND LeaveToDate <= '2026-11-04 23:59:59'
ORDER BY LeaveFromDate ASC;
```

👉 **Kết quả kỳ vọng**:
* Trả về đúng **10 dòng dữ liệu**.
* Cột `LeaveCode` đủ 10 mã: `O`, `AL`, `PH`, `UL`, `ML`, `FLWD`, `CT`, `WFH`, `IO`, `PL`.
* Cột `LeaveDays` = `1.0`, `LeaveHours` = `8.0`.
* Cột `Approve_Status` = `0` (Chờ cấp 1 duyệt).

---

## 🔗 6. TÁC ĐỘNG LIÊN ĐỚI SANG CÁC CHẶNG TIẾP THEO (DOWNSTREAM IMPACT)

| Module tiếp theo | Vai trò phụ trách | Tác động cụ thể |
|---|---|---|
| **Duyệt Cấp 1 (`fix-6`)** | `tri.nguyen` (004) | Trên `MnuWPT037` (Group 1), sẽ xuất hiện 10 thẻ đơn chờ duyệt của NV 099. |
| **Duyệt Cấp 2 (`fix-6`)** | `LongKa` (012) | Duyệt chặng cuối để hoàn tất đưa đơn nghỉ phép vào CSDL chính thức. |
| **Bảng công cá nhân (`fix-6`)** | `test.nv` (099) | Màn hình `MnuWPT010` sẽ hiển thị các ký hiệu công tương ứng: `AL`, `O`, `CT`, `WFH`... trên lưới lịch tháng 10 và tháng 11. |
| **Tính lương (`fix-7`)** | `PRL` | Tháng 10 sẽ có các ngày nghỉ có lương (`AL`, `PH`, `FLWD`, `CT`) và không lương (`O`, `UL`). |
| **Phiếu lương (`fix-8`)** | `test.nv` (099) | Chỉ số ngày nghỉ phép năm (`#psDaysOff`) và ngày nghỉ không lương (`#psUnpaidLeave`) sẽ cập nhật đối soát chi tiết. |
