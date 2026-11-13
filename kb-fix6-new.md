# KỊCH BẢN KIỂM THỬ THỦ CÔNG (MANUAL TEST SCRIPT) - PHÂN VÙNG FIX-6 (MỞ RỘNG 10 LOẠI NGHỈ PHÉP)
> **QUY TRÌNH**: Thẩm định & Phê duyệt phân cấp liên hoàn 10 loại Đơn Nghỉ phép (Toàn bộ Option trong Combobox) & 3 Đơn Bù công cho Nhân viên mới `099 - Nguyễn Văn Test`  
> **MÔI TRƯỜNG KIỂM THỬ**: Google Chrome - Web Paradise HRM: `https://paradisehrm.com/Tai3/`  
> **CƠ SỞ DỮ LIỆU**: `Vietinsoft_ForTest_Tai2` (SQL Server)  
> **DANH SÁCH TEST CASE**: `TC-10`, `TC-11` (Bỏ qua), `TC-12`, `TC-13`

---

## 📑 BẢNG ÁNH XẠ 10 NGÀY NGHỈ PHÉP MẪU (22/10/2026 $\rightarrow$ 04/11/2026) TƯƠNG ỨNG 10 OPTION
Hệ thống kiểm thử trên 10 ngày làm việc liên tiếp (loại trừ Thứ Bảy và Chủ Nhật), mỗi ngày tương ứng với đúng 1 Option trong Combobox loại nghỉ (`sp_ResignationLeave_LeaveCode`):

| STT | Ngày Nghỉ | Thứ | Mã Loại Nghỉ | Tên Hiển Thị Trong Combobox | Tỷ Lệ Lương | Nhóm Nghiệp Vụ | Ý Nghĩa Thực Tế Kiểm Thử |
| :---: | :---: | :---: | :---: | :--- | :---: | :---: | :--- |
| **1** | **22/10/2026** | Thứ Năm | **O** | **Nghỉ ốm (0%)** | 0% | BHXH / Không lương | Nghỉ ốm đau có giấy xác nhận y tế |
| **2** | **23/10/2026** | Thứ Sáu | **AL** | **Phép năm (100%)** | 100% | Nghỉ hưởng lương | Trừ vào quỹ ngày phép năm của NV |
| -- | *24/10/2026* | *Thứ Bảy* | *--* | *Cuối tuần (Nghỉ hàng tuần)* | *--* | *Không làm việc* | *Bỏ qua không lập đơn* |
| -- | *25/10/2026* | *Chủ Nhật* | *--* | *Cuối tuần (Nghỉ hàng tuần)* | *--* | *Không làm việc* | *Bỏ qua không lập đơn* |
| **3** | **26/10/2026** | Thứ Hai | **PH** | **Nghỉ lễ,Tết (100%)** | 100% | Nghỉ hưởng lương | Nghỉ ngày Lễ, Tết theo quy định nhà nước |
| **4** | **27/10/2026** | Thứ Ba | **UL** | **Nghỉ không lương (0%)** | 0% | Không hưởng lương | Việc riêng gia đình nghỉ không tính lương |
| **5** | **28/10/2026** | Thứ Tư | **ML** | **Thai sản (0%)** | 0% | Chế độ thai sản | Chế độ thai sản (cơ quan BHXH chi trả) |
| **6** | **29/10/2026** | Thứ Năm | **FLWD** | **Đám tang, cưới hỏi (100%)** | 100% | Nghỉ hưởng lương | Nghỉ việc hiếu, việc hỷ theo luật lao động |
| **7** | **30/10/2026** | Thứ Sáu | **CT** | **Công tác (100%)** | 100% | Nghỉ hưởng lương | Cử đi công tác thực địa / gặp khách hàng |
| -- | *31/10/2026* | *Thứ Bảy* | *--* | *Cuối tuần (Nghỉ hàng tuần)* | *--* | *Không làm việc* | *Bỏ qua không lập đơn* |
| -- | *01/11/2026* | *Chủ Nhật* | *--* | *Cuối tuần (Nghỉ hàng tuần)* | *--* | *Không làm việc* | *Bỏ qua không lập đơn* |
| **8** | **02/11/2026** | Thứ Hai | **WFH** | **Làm online (100%)** | 100% | Nghỉ hưởng lương | Làm việc từ xa (Work From Home) đủ công |
| **9** | **03/11/2026** | Thứ Ba | **IO** | **Đi trễ, về sớm (0%)** | 0% | Giải trình công | Xin phép đi trễ hoặc về sớm do việc gấp |
| **10** | **04/11/2026** | Thứ Tư | **PL** | **Nghỉ vợ sinh (0%)** | 0% | Chế độ nam giới | Nghỉ chăm vợ sinh con theo Luật BHXH |

---

## 🛠️ BƯỚC 0: TIỀN ĐỀ MÔI TRƯỜNG & DỮ LIỆU CSDL (DATABASE PRE-CONDITION)
Trước khi tiến hành kiểm thử duyệt đơn ở `fix-6`, mở SQL Server Management Studio (SSMS) kết nối `Vietinsoft_ForTest_Tai2` và thực thi:

1. **Làm sạch môi trường & cấp phép**:
   - Xóa các đơn cũ phát sinh của NV `099`.
   - Cấp đủ ngày phép năm trong `tblAdvLeaveDays` (tối thiểu 12 ngày phép) để đảm bảo nộp đơn `AL` hợp lệ.
2. **Đảm bảo phân quyền xét duyệt theo ma trận (`tblApprovalLineByEmployee`)**:
   - **Group 1 (Đơn Nghỉ phép)**: Cấp 1 = `004` (`tri.nguyen`), Cấp 2 = `012` (`LongKa`).
   - **Group 5 (Đơn Bù công)**: Cấp 1 = `004` (`tri.nguyen`), Cấp 2 = `012` (`LongKa`).
3. **Dữ liệu công mẫu**:
   - 5 ngày công mẫu đầu tháng 10: 12/10 (8h), 13/10 (8h), 14/10 (6h công lẻ - nộp nhầm đơn hủy), 15/10 (4h bù lên 8h), 16/10 (7h bù lên 8h).
   - 10 ngày từ 22/10 $\rightarrow$ 04/11 (trừ T7, CN) để trống giờ làm việc sẵn sàng đón nhận 10 loại nghỉ phép.

---

## 📝 PHẦN A: TỔNG HỢP 13 ĐƠN TỪ PHÁT SINH TỪ FIX-5 ĐỂ THẨM ĐỊNH
Khi phân vùng `fix-5` hoàn tất nộp đơn trên giao diện ESS, hàng đợi chờ duyệt Cấp 1 của Quản lý sẽ có tổng cộng **13 thẻ đơn** của nhân viên `099 - Nguyễn Văn Test`:
- **10 Đơn Nghỉ phép** (Nhóm Group 1):
  1. `22/10/2026`: Nghỉ ốm `O` (0%)
  2. `23/10/2026`: Phép năm `AL` (100%)
  3. `26/10/2026`: Nghỉ lễ, Tết `PH` (100%)
  4. `27/10/2026`: Nghỉ không lương `UL` (0%)
  5. `28/10/2026`: Thai sản `ML` (0%)
  6. `29/10/2026`: Đám tang, cưới hỏi `FLWD` (100%)
  7. `30/10/2026`: Công tác `CT` (100%)
  8. `02/11/2026`: Làm online `WFH` (100%)
  9. `03/11/2026`: Đi trễ, về sớm `IO` (0%)
  10. `04/11/2026`: Nghỉ vợ sinh `PL` (0%)
- **03 Đơn Bù công** (Nhóm Group 5):
  11. `15/10/2026`: Xin bù công đủ 8.0h (làm 7h-12h tiếp khách)
  12. `16/10/2026`: Xin bù công đủ 8.0h (làm 7h-15h gặp đối tác)
  13. `14/10/2026`: Xin hủy đơn bù công (nộp nhầm ngày)

---

## 📋 [TC-10]: Quản lý Trí Nguyễn Thẩm định & Phê duyệt Cấp 1 (13 Đơn NV 099)
- **Tài khoản thực hiện**: `tri.nguyen` | Mật khẩu: `123` (Mr. TRÍ [004] - Quản lý Cấp 1).
- **Màn hình thực hiện**: `MnuWPT037` (Danh sách phê duyệt).

### Các bước thao tác chi tiết (Step-by-Step):
1. **Đăng nhập**: Mở trình duyệt truy cập `https://paradisehrm.com/Tai3/` $\rightarrow$ Đăng nhập tài khoản `tri.nguyen` / `123`.
2. **Mở Danh sách phê duyệt**:
   - Nhấp biểu tượng **Cửa sổ Windows 🪟** trên thanh Dock.
   - Tại ô Search Launchpad gõ: `phê` hoặc `Danh sách phê duyệt` $\rightarrow$ Nhấp mở menu (`MnuWPT037`).
   - Chờ danh sách thẻ đơn `#cardregistered` tải xong.
3. **Phê duyệt Cấp 1 lần lượt 10 Đơn Nghỉ phép**:
   - *Lưu ý*: Trên mỗi thẻ đơn tóm tắt, kiểm tra đúng nhân viên `Nguyễn Văn Test (099)` và tiêu đề `Xin nghỉ phép`.
   - Lần lượt nhấp chọn từng thẻ đơn nghỉ phép $\rightarrow$ Hệ thống tự mở tab **"Xin nghỉ phép"**:
     - Kiểm tra loại nghỉ hiển thị trong ô Loại nghỉ: `O`, `AL`, `PH`, `UL`, `ML`, `FLWD`, `CT`, `WFH`, `IO`, `PL`.
     - Kiểm tra khoảng ngày nghỉ tương ứng (từ ngày 22/10 đến 04/11).
     - Cuộn form xuống dưới, nhấp vào nút **"Duyệt"** (màu xanh lá cây).
     - Modal xác nhận ghi chú `#modalApproveLeaveRequest` hiện lên $\rightarrow$ Nhấp nút **"Duyệt"** (`#btnActionModalRemake`).
     - Đợi thông báo thành công và modal đóng hẳn.
     - Nhấp quay lại tab **"Danh sách phê duyệt"** trên Top Tab Bar $\rightarrow$ Bấm nút **Làm mới (`↻`)**.
   - Lặp lại cho đến khi hoàn tất toàn bộ 10 đơn nghỉ phép.
4. **Phê duyệt Cấp 1 các Đơn Bù công**:
   - **Đơn Bù công 15/10**: Chọn thẻ đơn ngày 15/10 $\rightarrow$ Mở tab "Xin bù công" $\rightarrow$ Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal `#btnApproveModalRemake` $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn Bù công 16/10**: Chọn thẻ đơn ngày 16/10 $\rightarrow$ Mở tab "Xin bù công" $\rightarrow$ Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal `#btnApproveModalRemake` $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn Xin hủy 14/10**: Chọn thẻ đơn có cờ đỏ "Xin hủy đăng ký" ngày 14/10 $\rightarrow$ Bấm **Duyệt** để chấp thuận hủy $\rightarrow$ Modal xác nhận hiện ra $\rightarrow$ Bấm **Duyệt** trong modal `#btnRejectModalRemake` $\rightarrow$ Quay lại tab và Làm mới.
5. **Kiểm chứng sau thao tác Cấp 1**:
   - Danh sách chờ duyệt của `tri.nguyen` không còn thẻ nào của NV 099.
   - Toàn bộ 10 đơn nghỉ phép và 2 đơn bù công (15 & 16/10) đã chuyển trạng thái `Level 1 = Đã duyệt`, sẵn sàng chuyển lên hàng đợi Cấp 2 của Quản lý Trường Long.
6. **Đăng xuất**: Bấm Avatar `#randomAvatar` góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

---

## 📋 [TC-11]: [ĐÃ BỎ QUA] Quản lý Trường Long phê duyệt Cấp 1 đơn Tăng ca OT
> ⚠️ **TRẠNG THÁI: [SKIPPED]**  
> Quy trình phân vùng `fix-5` không phát sinh nghiệp vụ xin tăng ca OT, do đó bước này được bỏ qua hoàn toàn.

---

## 📋 [TC-12]: Quản lý Trường Long Thẩm định & Phê duyệt Cấp 2 Chặng cuối
- **Tài khoản thực hiện**: `LongKa` | Mật khẩu: `123` (Mr. LONG [012] - Quản lý Cấp 2 chặng cuối).
- **Màn hình thực hiện**: `MnuWPT037` (Danh sách phê duyệt).

### Các bước thao tác chi tiết (Step-by-Step):
1. **Đăng nhập**: Đăng nhập tài khoản `LongKa` / `123`.
2. **Mở Danh sách phê duyệt**:
   - Bấm icon **Cửa sổ Windows 🪟** $\rightarrow$ Tìm `Danh sách phê duyệt` $\rightarrow$ Mở menu `MnuWPT037`.
   - Danh sách hiển thị toàn bộ các đơn của NV 099 đã qua Cấp 1, đang ở trạng thái chờ duyệt Cấp 2.
3. **Phê duyệt Cấp 2 lần lượt 10 Đơn Nghỉ phép & Kiểm tra Lịch sử**:
   - Lần lượt nhấp chọn từng thẻ Nghỉ phép của NV 099 $\rightarrow$ Mở form Xin nghỉ phép:
     - Kiểm tra trạng thái cấp duyệt: Avatar Trí Nguyễn đã tick xanh (Đã duyệt Cấp 1), Avatar Trường Long hiển thị trạng thái "Đang duyệt".
     - Bấm nút **"Duyệt"** màu xanh lá cây $\rightarrow$ Nhấp nút **"Duyệt"** trong modal `#btnActionModalRemake`.
     - Chuyển sang tab **"Lịch sử"** (`#history-tab-label`) để kiểm tra thẻ đơn vừa duyệt đã hiển thị trạng thái *"Đã duyệt hoàn tất"* (Approved).
     - Nhấp tab **"Danh sách phê duyệt"** $\rightarrow$ Bấm nút **Làm mới (`↻`)**.
   - Lặp lại đủ 10 đơn nghỉ phép.
4. **Phê duyệt Cấp 2 các Đơn Bù công**:
   - **Đơn 15/10**: Chọn thẻ $\rightarrow$ Bấm **Duyệt** $\rightarrow$ Xác nhận modal $\rightarrow$ Xem tab Lịch sử $\rightarrow$ Quay lại Làm mới.
   - **Đơn 16/10**: Chọn thẻ $\rightarrow$ Bấm **Duyệt** $\rightarrow$ Xác nhận modal $\rightarrow$ Xem tab Lịch sử $\rightarrow$ Quay lại Làm mới.
   - **Đơn hủy 14/10**: Chọn thẻ $\rightarrow$ Bấm **Duyệt** $\rightarrow$ Xác nhận modal $\rightarrow$ Xem tab Lịch sử $\rightarrow$ Quay lại Làm mới.
5. **Kiểm chứng sau thao tác Cấp 2**:
   - Toàn bộ các đơn của NV 099 đạt trạng thái phê duyệt tối cao (`Approve_Status = 2` cho các đơn hợp lệ và `Approve_Status = 4` cho đơn hủy).
6. **Đăng xuất**: Bấm Avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

---

## 📋 [TC-13]: Nhân viên Nguyễn Văn Test Xem Bảng công cá nhân (MnuWPT010) Tháng 10 & Tháng 11
- **Tài khoản thực hiện**: `099` | Mật khẩu: `123` (Nguyễn Văn Test - Nhân viên mới).
- **Màn hình thực hiện**: `MnuWPT010` (Bảng công cá nhân / Chấm công cá nhân).

### Các bước thao tác chi tiết (Step-by-Step):
1. **Đăng nhập**: Đăng nhập tài khoản `099` / `123`.
2. **Mở Bảng công cá nhân**:
   - Nhấp trực tiếp vào icon **Chấm công cá nhân** (`button.MnuWPT010`) trên thanh Dock (hoặc tìm trên Launchpad).
3. **Pha 1 — Kiểm tra Bảng công Tháng 10/2026**:
   - Tại SelectBox Tháng: Chọn Tháng **`10`** (Năm `2026`).
   - Đối soát trực quan trên lưới lịch:
     - **Tuần 12/10 - 16/10**:
       * Ngày 12/10 & 13/10: Làm việc tiêu chuẩn, `Công: 8.0` (Màu xanh).
       * Ngày 14/10: Giữ nguyên công lẻ `6.0h` (Màu đỏ/cảnh báo) do đơn bù công đã duyệt hủy.
       * Ngày 15/10 & 16/10: Đã cập nhật đủ `Công: 8.0` (Màu xanh) nhờ bù công được duyệt cả 2 cấp.
     - **Tuần 22/10 - 30/10 (7 loại nghỉ phép đầu tiên)**:
       * **22/10 (Thứ Năm)**: Ô hiển thị **`Nghỉ ốm (Cả ngày)`** hoặc mã `O` (Nhóm 0% lương).
       * **23/10 (Thứ Sáu)**: Ô hiển thị **`Phép năm (Cả ngày)`** hoặc mã `AL` (Nhóm 100% lương).
       * *24/10 & 25/10*: Ô màu xám chữ `OFF` (Nghỉ cuối tuần).
       * **26/10 (Thứ Hai)**: Ô hiển thị **`Nghỉ lễ,Tết (Cả ngày)`** hoặc mã `PH` (Nhóm 100% lương).
       * **27/10 (Thứ Ba)**: Ô hiển thị **`Nghỉ không lương (Cả ngày)`** hoặc mã `UL` (Nhóm 0% lương).
       * **28/10 (Thứ Tư)**: Ô hiển thị **`Thai sản (Cả ngày)`** hoặc mã `ML` (Nhóm 0% lương).
       * **29/10 (Thứ Năm)**: Ô hiển thị **`Đám tang, cưới hỏi (Cả ngày)`** hoặc mã `FLWD` (Nhóm 100% lương).
       * **30/10 (Thứ Sáu)**: Ô hiển thị **`Công tác (Cả ngày)`** hoặc mã `CT` (Nhóm 100% lương).
       * *31/10*: Ô màu xám chữ `OFF`.
4. **Pha 2 — Kiểm tra Bảng công Tháng 11/2026**:
   - Tại SelectBox Tháng: Chọn Tháng **`11`** (Năm `2026`).
   - Đối soát trực quan trên lưới lịch:
     - *01/11*: Ô màu xám chữ `OFF` (Chủ Nhật).
     - **02/11 (Thứ Hai)**: Ô hiển thị **`Làm online (Cả ngày)`** hoặc mã `WFH` (Nhóm 100% lương).
     - **03/11 (Thứ Ba)**: Ô hiển thị **`Đi trễ, về sớm (Cả ngày)`** hoặc mã `IO` (Nhóm 0% lương).
     - **04/11 (Thứ Tư)**: Ô hiển thị **`Nghỉ vợ sinh (Cả ngày)`** hoặc mã `PL` (Nhóm 0% lương).
5. **Đăng xuất**: Bấm Avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

---

## 🎯 BẢNG TRUY VẤN ĐỐI SOÁT CƠ SỞ DỮ LIỆU READ-ONLY (DATABASE VERIFICATION)
Mở SSMS, chọn database `Vietinsoft_ForTest_Tai2` và thực thi đoạn script sau để kiểm chứng kết quả kỹ thuật:

```sql
-- 1. Kiểm tra trạng thái 10 Đơn Nghỉ phép (Kỳ vọng: Toàn bộ 10 đơn có Approve_Status = 2 - ĐÃ DUYỆT HOÀN TẤT)
SELECT 
    IdentityID,
    EmployeeID,
    LeaveCode,
    CONVERT(varchar, LeaveFromDate, 23) AS [Ngày nghỉ],
    CASE LeaveCode
        WHEN 'O'    THEN N'1. Nghỉ ốm (0%)'
        WHEN 'AL'   THEN N'2. Phép năm (100%)'
        WHEN 'PH'   THEN N'3. Nghỉ lễ, Tết (100%)'
        WHEN 'UL'   THEN N'4. Nghỉ không lương (0%)'
        WHEN 'ML'   THEN N'5. Thai sản (0%)'
        WHEN 'FLWD' THEN N'6. Đám tang, cưới hỏi (100%)'
        WHEN 'CT'   THEN N'7. Công tác (100%)'
        WHEN 'WFH'  THEN N'8. Làm online (100%)'
        WHEN 'IO'   THEN N'9. Đi trễ, về sớm (0%)'
        WHEN 'PL'   THEN N'10. Nghỉ vợ sinh (0%)'
        ELSE LeaveCode
    END AS [Tên loại nghỉ],
    Approve_Status AS [Mã TT],
    CASE Approve_Status 
        WHEN 2 THEN N'✅ ĐÃ DUYỆT HOÀN TẤT'
        WHEN 1 THEN N'⏳ Chờ duyệt'
        WHEN 3 THEN N'❌ Bị từ chối'
        ELSE N'Khác'
    END AS [Trạng thái duyệt]
FROM tblLeaveRegistered
WHERE EmployeeID = '099' 
  AND LeaveFromDate >= '2026-10-22' 
  AND LeaveFromDate <= '2026-11-04'
ORDER BY LeaveFromDate;

-- 2. Kiểm tra chi tiết lịch sử phê duyệt phân cấp qua 2 cấp (tblApproverHistory)
SELECT 
    h.Identity_ID,
    l.LeaveCode,
    CONVERT(varchar, l.LeaveFromDate, 23) AS [Ngày nghỉ],
    h.[Level] AS [Cấp duyệt],
    h.Approver AS [Mã Người duyệt],
    CASE h.[Level]
        WHEN 1 THEN N'Cấp 1 (Trí Nguyễn)'
        WHEN 2 THEN N'Cấp 2 (Trường Long)'
    END AS [Vai trò],
    h.Approve_Status AS [Mã TT Cấp],
    CASE h.Approve_Status 
        WHEN 2 THEN N'✅ Đã duyệt'
        WHEN 1 THEN N'⏳ Đang chờ'
        ELSE N'Chưa tới lượt'
    END AS [Trạng thái từng cấp],
    CONVERT(varchar, h.Approval_Time, 120) AS [Thời điểm duyệt]
FROM tblApproverHistory h
JOIN tblLeaveRegistered l ON h.Identity_ID = CAST(l.IdentityID AS VARCHAR(50))
WHERE l.EmployeeID = '099' 
  AND l.LeaveFromDate >= '2026-10-22'
ORDER BY l.LeaveFromDate, h.[Level];

-- 3. Kiểm tra trạng thái 3 Đơn Bù công (Kỳ vọng: 15/10 = 2, 16/10 = 2, 14/10 = 4)
SELECT 
    IdentityID,
    CONVERT(varchar, AttDate, 23) AS [Ngày bù công],
    Approve_Status AS [Mã TT],
    CASE Approve_Status 
        WHEN 2 THEN N'✅ ĐÃ DUYỆT HOÀN TẤT'
        WHEN 4 THEN N'🛑 ĐÃ DUYỆT HỦY ĐƠN (CANCELLED)'
        ELSE N'Khác'
    END AS [Trạng thái]
FROM tblAttendanceConfirmRequest
WHERE EmployeeID = '099'
ORDER BY AttDate;
```
