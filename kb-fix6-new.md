# KỊCH BẢN KIỂM THỬ THỦ CÔNG: DUYỆT TOÀN BỘ 10 LOẠI ĐƠN NGHỈ PHÉP (FULL OPTIONS) & BÙ CÔNG
> **MÃ KỊCH BẢN**: `KB-FIX6-NEW`  
> **LIÊN KẾT ĐỐI ỨNG**: Khớp 100% dữ liệu nộp đơn từ [**`kb-fix5-new.md`**](file:///c:/Users/Y.Thach/Desktop/paradiseHR/kb-fix5-new.md)  
> **ĐỐI TƯỢNG ĐƯỢC DUYỆT**: Nhân viên mới `099 - Nguyễn Văn Test` (`test.nv`)  
> **CƠ SỞ DỮ LIỆU ĐỐI SOÁT**: `Vietinsoft_ForTest_Tai2` (SQL Server)  
> **MÔI TRƯỜNG THỰC THI**: Google Chrome - Web Paradise HRM: `https://paradisehrm.com/Tai3/#`  
> **DANH SÁCH TEST CASE**: `TC-10` (Trí Nguyễn Cấp 1), `TC-11` (Bỏ qua), `TC-12` (Trường Long Cấp 2), `TC-13` (Nguyễn Văn Test xem Bảng công)

---

## 🎯 1. MỤC TIÊU NGHIỆP VỤ & MA TRẬN PHÊ DUYỆT (OBJECTIVE)

1. **Thẩm định & Phê duyệt phân cấp 2 cấp** toàn bộ **10 loại Đơn Nghỉ phép (10/10 Options)** do `fix-5` nộp từ ngày `22/10/2026` đến `04/11/2026` (trừ Thứ 7 & Chủ nhật) theo đúng ma trận tuyến duyệt `tblApprovalLineByEmployee`:
   * **Cấp 1**: Quản lý trực tiếp `004` — `tri.nguyen` (Mr. TRÍ).
   * **Cấp 2 (Chặng cuối)**: Quản lý cấp cao `012` — `LongKa` (Mr. LONG).
2. **Thẩm định & Phê duyệt 3 Đơn Bù công tháng 10/2026**:
   * Đơn ngày `15/10/2026`: Bù công từ 4.0h lên đủ 8.0h (quên quẹt thẻ ra do tiếp khách).
   * Đơn ngày `16/10/2026`: Bù công từ 7.0h lên đủ 8.0h (làm việc ngoài gặp đối tác).
   * Đơn ngày `14/10/2026`: Duyệt chấp thuận yêu cầu **Xin hủy đơn** (nhân viên nộp nhầm ngày).
3. **Đối soát tác động đa tầng**:
   * Kiểm chứng chuyển cấp từ Cấp 1 (`Status = 2`) lên Cấp 2 (`Status = 1`).
   * Kiểm chứng chốt chặn chặng cuối: CSDL ghi nhận `Approve_Status = 2` (Đã duyệt hoàn tất) và `Approve_Status = 4` (Đã duyệt hủy).
   * Kiểm chứng Bảng công cá nhân (`MnuWPT010`) hiển thị chính xác các mã loại nghỉ và tỷ lệ hưởng lương (100% vs 0%).

---

## 📅 2. BẢNG ĐỐI CHIẾU 10 ĐƠN NGHỈ PHÉP TỪ KB-FIX5-NEW ĐỂ NHẬN DIỆN THẺ DUYỆT

> [!TIP]
> **CÁCH NHẬN DIỆN THẺ ĐƠN TRÊN DANH SÁCH PHÊ DUYỆT (`MnuWPT037`)**:  
> Thẻ tóm tắt trên `MnuWPT037` không hiển thị chuỗi ngày (ví dụ `22/10`), nhưng **HIỂN THỊ CHÍNH XÁC NỘI DUNG LÝ DO NGHỈ (`Reason`)**.  
> Sử dụng bảng đối chiếu dưới đây để nhận diện tức thì từng thẻ đơn của NV `099`:

| STT | Ngày nghỉ | Thứ | Mã loại | Tên hiển thị trong Combobox | Tỷ lệ lương | Dấu hiệu nhận diện thẻ (Nội dung lý do trong kb-fix5-new) | Kỳ vọng sau duyệt |
|:---:|:---:|:---:|:---:|:---|:---:|:---|:---:|
| **01** | `22/10/2026` | Thứ 5 | **O** | **Nghỉ ốm (0%)** | 0% | *"Sốt xuất huyết điều trị ngoại trú theo chỉ định của bác sĩ"* | Hưởng chế độ BHXH |
| **02** | `23/10/2026` | Thứ 6 | **AL** | **Phép năm (100%)** | 100% | *"Giải quyết công việc gia đình cá nhân"* | Trừ 1 ngày phép năm |
| -- | *24/10/2026* | *Thứ 7* | -- | *Nghỉ cuối tuần (Holiday)* | -- | *(Không phát sinh đơn)* | Nghỉ cuối tuần |
| -- | *25/10/2026* | *Chủ nhật* | -- | *Nghỉ cuối tuần (Holiday)* | -- | *(Không phát sinh đơn)* | Nghỉ cuối tuần |
| **03** | `26/10/2026` | Thứ 2 | **PH** | **Nghỉ lễ,Tết (100%)** | 100% | *"Đăng ký nghỉ bù ngày lễ theo quy định công ty"* | Hưởng 100% lương |
| **04** | `27/10/2026` | Thứ 3 | **UL** | **Nghỉ không lương (0%)** | 0% | *"Việc riêng đột xuất, xin nghỉ không hưởng lương"* | Không tính lương (0%) |
| **05** | `28/10/2026` | Thứ 4 | **ML** | **Thai sản (0%)** | 0% | *"Khám thai định kỳ theo chế độ bảo hiểm xã hội"* | Chế độ thai sản BHXH |
| **06** | `29/10/2026` | Thứ 5 | **FLWD** | **Đám tang, cưới hỏi (100%)** | 100% | *"Nghỉ tham dự lễ cưới người thân trong gia đình"* | Hưởng 100% lương |
| **07** | `30/10/2026` | Thứ 6 | **CT** | **Công tác (100%)** | 100% | *"Đi công tác thực địa hỗ trợ khách hàng chi nhánh miền Nam"* | Hưởng 100% lương |
| -- | *31/10/2026* | *Thứ 7* | -- | *Nghỉ cuối tuần (Holiday)* | -- | *(Không phát sinh đơn)* | Nghỉ cuối tuần |
| -- | *01/11/2026* | *Chủ nhật* | -- | *Nghỉ cuối tuần (Holiday)* | -- | *(Không phát sinh đơn)* | Nghỉ cuối tuần |
| **08** | `02/11/2026` | Thứ 2 | **WFH** | **Làm online (100%)** | 100% | *"Làm việc từ xa (Work From Home) xử lý tài liệu kỹ thuật"* | Hưởng 100% lương |
| **09** | `03/11/2026` | Thứ 3 | **IO** | **Đi trễ, về sớm (0%)** | 0% | *"Có việc gia đình đột xuất cả ngày xin xác nhận đi trễ về sớm"* | Không tính lương (0%) |
| **10** | `04/11/2026` | Thứ 4 | **PL** | **Nghỉ vợ sinh (0%)** | 0% | *"Nghỉ chăm sóc vợ sinh con theo chế độ Luật BHXH"* | Chế độ nam giới BHXH |

---

## 🛠️ 3. BƯỚC 0: TIỀN ĐỀ CSDL & THIẾT LẬP TUYẾN DUYỆT TRÊN SSMS

Trước khi thực hiện kịch bản duyệt ở `fix-6`, mở **SQL Server Management Studio (SSMS)**, kết nối `Vietinsoft_ForTest_Tai2` và kiểm tra đảm bảo:

1. **Tuyến duyệt 2 cấp chuẩn xác cho NV 099**:
   ```sql
   -- Group 1: Nghỉ phép | Group 5: Bù công
   SELECT EmployeeID, Approvalgrouplist, Approver_1, Delegacy_1, Approver_2 
   FROM tblApprovalLineByEmployee 
   WHERE EmployeeID = '099' AND Approvalgrouplist IN (1, 5);
   -- 👉 Kỳ vọng: Approver_1 = '004' (tri.nguyen), Approver_2 = '012' (LongKa)
   ```
2. **Dữ liệu đơn từ đã nạp từ fix-5**:
   ```sql
   -- Kiểm tra đủ 10 đơn nghỉ phép đang ở trạng thái chờ duyệt Cấp 1
   SELECT COUNT(*) AS [TongDonNghiPhepChoDuyet] 
   FROM tblLeaveRegistered 
   WHERE EmployeeID = '099' AND LeaveFromDate >= '2026-10-22' AND Approve_Status = 1;
   -- 👉 Kỳ vọng: 10 đơn
   ```

---

## 📋 4. HƯỚNG DẪN THAO TÁC KIỂM THỬ THỦ CÔNG CHI TIẾT (STEP-BY-STEP)

### ═════════════════════════════════════════════════════════════════════
### 🔹 [TC-10]: QUẢN LÝ TRÍ NGUYỄN PHÊ DUYỆT CẤP 1 (10 ĐƠN PHÉP + 3 ĐƠN BÙ CÔNG)
### ═════════════════════════════════════════════════════════════════════
- **Vai trò**: Quản lý Cấp 1 Nghỉ phép & Bù công
- **Tài khoản**: `tri.nguyen` | Mật khẩu: `123` (Mr. TRÍ [004])
- **Màn hình**: `MnuWPT037` (Danh sách phê duyệt)

#### Các bước thực hiện:
1. **Đăng nhập**: Mở trình duyệt Chrome truy cập `https://paradisehrm.com/Tai3/#` $\rightarrow$ Đăng nhập tài khoản `tri.nguyen` / `123`.
2. **Mở Danh sách phê duyệt**:
   - Nhấp vào biểu tượng **Cửa sổ Windows 🪟** trên thanh Dock.
   - Tại ô Search Launchpad gõ: `Danh sách phê duyệt` (hoặc `phê`).
   - Nhấp chọn icon **"Danh sách phê duyệt"** (`MnuWPT037`).
   - Chờ danh sách thẻ đơn `#cardregistered` tải xong.
3. **Phê duyệt Cấp 1 lần lượt 10 Đơn Nghỉ phép (Full Options)**:
   > 💡 *Mẹo thao tác theo JSON Recorder*: Khi bấm duyệt xong 1 đơn và bấm nút **Làm mới (`↻`)**, thẻ vừa duyệt sẽ biến mất, thẻ tiếp theo tự động trồi lên vị trí đầu tiên `#cardregistered > div:nth-of-type(1)`. Bạn chỉ việc nhấp thẻ đầu tiên, duyệt và làm mới liên tục!

   Thực hiện duyệt lần lượt 10 đơn nghỉ phép theo đúng bảng đối chiếu:
   - **Đơn 1 (Nghỉ ốm `O` - 22/10)**:
     * Nhấp thẻ có lý do *"Sốt xuất huyết điều trị ngoại trú..."* $\rightarrow$ Mở tab **"Xin nghỉ phép"**.
     * Kiểm tra ô Loại nghỉ: `O` / `Nghỉ ốm (0%)`, khoảng ngày: `22/10/2026 08:00 - 17:00`.
     * Cuộn xuống bấm nút **"Duyệt"** màu xanh $\rightarrow$ Modal popup `#modalApproveLeaveRequest` hiện ra $\rightarrow$ Nhấp nút **"Duyệt"** (`#btnActionModalRemake`).
     * Đợi modal đóng $\rightarrow$ Nhấp quay lại tab **"Danh sách phê duyệt"** $\rightarrow$ Bấm nút **Làm mới (`↻`)**.
   - **Đơn 2 (Phép năm `AL` - 23/10)**:
     * Nhấp thẻ có lý do *"Giải quyết công việc gia đình cá nhân"* $\rightarrow$ Mở tab Xin nghỉ phép.
     * Kiểm tra Loại nghỉ: `AL` / `Phép năm (100%)`, ngày: `23/10/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 3 (Nghỉ lễ, Tết `PH` - 26/10)**:
     * Nhấp thẻ có lý do *"Đăng ký nghỉ bù ngày lễ theo quy định công ty"*.
     * Kiểm tra Loại nghỉ: `PH` / `Nghỉ lễ,Tết (100%)`, ngày: `26/10/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 4 (Nghỉ không lương `UL` - 27/10)**:
     * Nhấp thẻ có lý do *"Việc riêng đột xuất, xin nghỉ không hưởng lương"*.
     * Kiểm tra Loại nghỉ: `UL` / `Nghỉ không lương (0%)`, ngày: `27/10/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 5 (Thai sản `ML` - 28/10)**:
     * Nhấp thẻ có lý do *"Khám thai định kỳ theo chế độ bảo hiểm xã hội"*.
     * Kiểm tra Loại nghỉ: `ML` / `Thai sản (0%)`, ngày: `28/10/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 6 (Đám tang, cưới hỏi `FLWD` - 29/10)**:
     * Nhấp thẻ có lý do *"Nghỉ tham dự lễ cưới người thân trong gia đình"*.
     * Kiểm tra Loại nghỉ: `FLWD` / `Đám tang, cưới hỏi (100%)`, ngày: `29/10/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 7 (Công tác `CT` - 30/10)**:
     * Nhấp thẻ có lý do *"Đi công tác thực địa hỗ trợ khách hàng chi nhánh miền Nam"*.
     * Kiểm tra Loại nghỉ: `CT` / `Công tác (100%)`, ngày: `30/10/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 8 (Làm online `WFH` - 02/11)**:
     * Nhấp thẻ có lý do *"Làm việc từ xa (Work From Home) xử lý tài liệu kỹ thuật"*.
     * Kiểm tra Loại nghỉ: `WFH` / `Làm online (100%)`, ngày: `02/11/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 9 (Đi trễ, về sớm `IO` - 03/11)**:
     * Nhấp thẻ có lý do *"Có việc gia đình đột xuất cả ngày xin xác nhận đi trễ về sớm"*.
     * Kiểm tra Loại nghỉ: `IO` / `Đi trễ, về sớm (0%)`, ngày: `03/11/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 10 (Nghỉ vợ sinh `PL` - 04/11)**:
     * Nhấp thẻ có lý do *"Nghỉ chăm sóc vợ sinh con theo chế độ Luật BHXH"*.
     * Kiểm tra Loại nghỉ: `PL` / `Nghỉ vợ sinh (0%)`, ngày: `04/11/2026`.
     * Bấm **Duyệt** $\rightarrow$ Bấm **Duyệt** trong modal $\rightarrow$ Quay lại tab và Làm mới.

4. **Phê duyệt Cấp 1 các Đơn Bù công (Group 5)**:
   - **Đơn Bù công 15/10**: Nhấp chọn thẻ bù công ngày 15/10 của NV 099 $\rightarrow$ Mở tab "Xin bù công" $\rightarrow$ Bấm nút **Duyệt** màu xanh $\rightarrow$ Modal hiện ra $\rightarrow$ Bấm nút **Duyệt** (`#btnApproveModalRemake`) $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn Bù công 16/10**: Nhấp chọn thẻ bù công ngày 16/10 $\rightarrow$ Mở tab "Xin bù công" $\rightarrow$ Bấm nút **Duyệt** màu xanh $\rightarrow$ Bấm **Duyệt** trong modal (`#btnApproveModalRemake`) $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn Xin hủy Bù công 14/10**: Nhấp chọn thẻ có cờ đỏ *"Xin hủy đăng ký"* kèm lý do *"Tôi nộp nhầm ngày cần hủy đơn bù công ngày 14/10"* $\rightarrow$ Mở tab Xin bù công $\rightarrow$ Bấm nút **Duyệt** màu xanh (chấp thuận hủy) $\rightarrow$ Modal hiện ra $\rightarrow$ Bấm nút **Duyệt** (`#btnRejectModalRemake`) $\rightarrow$ Quay lại tab và Làm mới.

5. **Kiểm chứng hoàn tất Cấp 1**:
   - Bấm nút Làm mới (`↻`) trên `MnuWPT037`. Danh sách của Trí Nguyễn hoàn toàn sạch bóng các đơn của NV 099.
6. **Đăng xuất**: Bấm Avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất** (`#txtLogoutOpt`) $\rightarrow$ Xác nhận thoát.

---

### ═════════════════════════════════════════════════════════════════════
### 🔹 [TC-11]: [ĐÃ BỎ QUA] QUẢN LÝ TRƯỜNG LONG DUYỆT TĂNG CA OT
### ═════════════════════════════════════════════════════════════════════
> ⚠️ **TRẠNG THÁI: [SKIPPED]**  
> Quy trình phân vùng `fix-5` đã loại bỏ hoàn toàn việc nộp đơn xin tăng ca OT, do đó bước này được bỏ qua không thực hiện.

---

### ═════════════════════════════════════════════════════════════════════
### 🔹 [TC-12]: QUẢN LÝ TRƯỜNG LONG PHÊ DUYỆT CẤP 2 CHẶNG CUỐI & XEM TAB LỊCH SỬ
### ═════════════════════════════════════════════════════════════════════
- **Vai trò**: Quản lý Cấp 2 chặng cuối (Final Approval)
- **Tài khoản**: `LongKa` | Mật khẩu: `123` (Mr. LONG [012])
- **Màn hình**: `MnuWPT037` (Danh sách phê duyệt)

#### Các bước thực hiện:
1. **Đăng nhập**: Đăng nhập tài khoản `LongKa` / `123`.
2. **Mở Danh sách phê duyệt**:
   - Nhấp icon **Cửa sổ Windows 🪟** $\rightarrow$ Tìm `Danh sách phê duyệt` $\rightarrow$ Mở `MnuWPT037`.
   - Quan sát danh sách: Toàn bộ 10 đơn nghỉ phép và 3 đơn bù công của NV 099 đã hiển thị ở trạng thái chờ duyệt Cấp 2.
3. **Phê duyệt Cấp 2 lần lượt 10 Đơn Nghỉ phép & Kiểm tra tab Lịch sử**:
   - Lần lượt nhấp chọn từng thẻ Nghỉ phép của NV 099 $\rightarrow$ Hệ thống mở tab "Xin nghỉ phép":
     - Soi avatar phê duyệt: Avatar Trí Nguyễn đã tick xanh (Đã duyệt Cấp 1), Avatar Trường Long hiển thị trạng thái "Đang duyệt".
     - Bấm nút **"Duyệt"** màu xanh trên form $\rightarrow$ Bấm nút **"Duyệt"** trong modal xác nhận (`#btnActionModalRemake`).
     - 👉 **Kiểm tra tab Lịch sử (khớp hành vi Recording JSON)**: Nhấp sang tab **"Lịch sử"** (`#history-tab-label`), xác nhận thẻ đơn vừa duyệt đã chuyển sang trạng thái **"Đã duyệt hoàn tất" (Approved)**.
     - Nhấp quay lại tab **"Danh sách phê duyệt"** $\rightarrow$ Bấm nút **Làm mới (`↻`)**.
   - Lặp lại quy trình trên cho toàn bộ 10 đơn: `O` (22/10), `AL` (23/10), `PH` (26/10), `UL` (27/10), `ML` (28/10), `FLWD` (29/10), `CT` (30/10), `WFH` (02/11), `IO` (03/11), `PL` (04/11).
4. **Phê duyệt Cấp 2 các Đơn Bù công & Xem Lịch sử**:
   - **Đơn 15/10**: Chọn thẻ bù công 15/10 $\rightarrow$ Bấm **Duyệt** $\rightarrow$ Xác nhận modal `#btnApproveModalRemake` $\rightarrow$ Nhấp xem tab Lịch sử (`.custom-tabs button:nth-of-type(3)`) $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn 16/10**: Chọn thẻ bù công 16/10 $\rightarrow$ Bấm **Duyệt** $\rightarrow$ Xác nhận modal `#btnApproveModalRemake` $\rightarrow$ Nhấp xem tab Lịch sử $\rightarrow$ Quay lại tab và Làm mới.
   - **Đơn hủy 14/10**: Chọn thẻ xin hủy 14/10 $\rightarrow$ Bấm **Duyệt** (chấp thuận hủy) $\rightarrow$ Xác nhận modal `#btnRejectModalRemake` $\rightarrow$ Nhấp xem tab Lịch sử $\rightarrow$ Quay lại tab và Làm mới.
5. **Kiểm chứng hoàn tất Cấp 2**:
   - Bấm nút Làm mới (`↻`), danh sách thẻ chờ duyệt của LongKa sạch bóng.
   - Toàn bộ các đơn đã hoàn tất chặng cuối trong CSDL.
6. **Đăng xuất**: Bấm Avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất** (`#txtLogoutOpt`) $\rightarrow$ Xác nhận.

---

### ═════════════════════════════════════════════════════════════════════
### 🔹 [TC-13]: NHÂN VIÊN NGUYỄN VĂN TEST XEM BẢNG CÔNG CÁ NHÂN (MnuWPT010)
### ═════════════════════════════════════════════════════════════════════
- **Vai trò**: Nhân viên kiểm tra kết quả công sau duyệt
- **Tài khoản**: `099` | Mật khẩu: `123` (Nguyễn Văn Test - `test.nv`)
- **Màn hình**: `MnuWPT010` (Bảng công cá nhân / Chấm công cá nhân)

#### Các bước thực hiện:
1. **Đăng nhập**: Mở trình duyệt đăng nhập `099` / `123`.
2. **Mở Bảng công cá nhân**:
   - Nhấp trực tiếp vào icon **Chấm công cá nhân** (`button.MnuWPT010`) trên thanh Dock (hoặc mở qua Launchpad).
   - Chờ màn hình lịch công `#sp_EmployeeMonthlyAttendance` hiển thị.

3. **Pha 1 — Kiểm tra Bảng công Tháng 10/2026**:
   - Tại SelectBox Tháng: Chọn Tháng **`10`** (Năm `2026`).
   - Đối soát trực quan trên bảng lịch tháng 10:
     * **12/10 & 13/10**: Làm ca chuẩn `08:00 - 17:00`, hiển thị **`Công: 8.0`** (Màu xanh).
     * **14/10**: Làm `07:00 - 14:00`, hiển thị **`Công: 6.0`** (Màu đỏ/công lẻ) do đơn bù công đã được duyệt hủy thành công.
     * **15/10 & 16/10**: Bù công thành công, hiển thị **`Công: 8.0`** (Màu xanh).
     * **22/10 (Thứ 5)**: Hiển thị ô **`Nghỉ ốm (Cả ngày)`** hoặc ký hiệu **`O`** (Nhóm 0% lương).
     * **23/10 (Thứ 6)**: Hiển thị ô **`Phép năm (Cả ngày)`** hoặc ký hiệu **`AL`** (Nhóm 100% lương).
     * *24/10 & 25/10*: Ô màu xám chữ **`OFF`** (Cuối tuần).
     * **26/10 (Thứ 2)**: Hiển thị ô **`Nghỉ lễ,Tết (Cả ngày)`** hoặc ký hiệu **`PH`** (Nhóm 100% lương).
     * **27/10 (Thứ 3)**: Hiển thị ô **`Nghỉ không lương (Cả ngày)`** hoặc ký hiệu **`UL`** (Nhóm 0% lương).
     * **28/10 (Thứ 4)**: Hiển thị ô **`Thai sản (Cả ngày)`** hoặc ký hiệu **`ML`** (Nhóm 0% lương).
     * **29/10 (Thứ 5)**: Hiển thị ô **`Đám tang, cưới hỏi (Cả ngày)`** hoặc ký hiệu **`FLWD`** (Nhóm 100% lương).
     * **30/10 (Thứ 6)**: Hiển thị ô **`Công tác (Cả ngày)`** hoặc ký hiệu **`CT`** (Nhóm 100% lương).
     * *31/10*: Ô màu xám chữ **`OFF`** (Cuối tuần).

4. **Pha 2 — Kiểm tra Bảng công Tháng 11/2026**:
   - Tại SelectBox Tháng: Chọn Tháng **`11`** (Năm `2026`).
   - Đối soát trực quan trên bảng lịch tháng 11:
     * *01/11*: Ô màu xám chữ **`OFF`** (Chủ nhật).
     * **02/11 (Thứ 2)**: Hiển thị ô **`Làm online (Cả ngày)`** hoặc ký hiệu **`WFH`** (Nhóm 100% lương).
     * **03/11 (Thứ 3)**: Hiển thị ô **`Đi trễ, về sớm (Cả ngày)`** hoặc ký hiệu **`IO`** (Nhóm 0% lương).
     * **04/11 (Thứ 4)**: Hiển thị ô **`Nghỉ vợ sinh (Cả ngày)`** hoặc ký hiệu **`PL`** (Nhóm 0% lương).

5. **Đăng xuất**: Bấm Avatar góc trên bên phải $\rightarrow$ Chọn **Đăng xuất**.

---

## 🎯 5. BỘ TRUY VẤN ĐỐI SOÁT CƠ SỞ DỮ LIỆU READ-ONLY (DATABASE VERIFICATION)

Sau khi hoàn tất kiểm thử duyệt đơn trên giao diện Web, mở SSMS, chọn database `Vietinsoft_ForTest_Tai2` và thực thi đoạn script sau để nghiệm thu kỹ thuật:

```sql
-- =============================================================================
-- 1. KIỂM TRA TRẠNG THÁI TOÀN BỘ 10 ĐƠN NGHỈ PHÉP (KỲ VỌNG: Approve_Status = 2)
-- =============================================================================
SELECT 
    IdentityID,
    EmployeeID,
    LeaveCode,
    CONVERT(varchar, LeaveFromDate, 120) AS [Từ ngày],
    CONVERT(varchar, LeaveToDate, 120) AS [Đến ngày],
    LeaveDays AS [Số ngày],
    LeaveHours AS [Số giờ],
    CASE LeaveCode
        WHEN 'O'    THEN N'1. Nghỉ ốm (0%)'
        WHEN 'AL'   THEN N'2. Phép năm (100%)'
        WHEN 'PH'   THEN N'3. Nghỉ lễ,Tết (100%)'
        WHEN 'UL'   THEN N'4. Nghỉ không lương (0%)'
        WHEN 'ML'   THEN N'5. Thai sản (0%)'
        WHEN 'FLWD' THEN N'6. Đám tang, cưới hỏi (100%)'
        WHEN 'CT'   THEN N'7. Công tác (100%)'
        WHEN 'WFH'  THEN N'8. Làm online (100%)'
        WHEN 'IO'   THEN N'9. Đi trễ, về sớm (0%)'
        WHEN 'PL'   THEN N'10. Nghỉ vợ sinh (0%)'
        ELSE LeaveCode
    END AS [Tên loại nghỉ],
    Reason AS [Lý do nộp trong kb-fix5-new],
    Approve_Status AS [Mã TT],
    CASE Approve_Status 
        WHEN 2 THEN N'✅ ĐÃ DUYỆT HOÀN TẤT (CẤP 2)'
        WHEN 1 THEN N'⏳ Đang chờ duyệt'
        ELSE N'Trạng thái khác'
    END AS [Kết quả kiểm chứng]
FROM tblLeaveRegistered
WHERE EmployeeID = '099' 
  AND LeaveFromDate >= '2026-10-22' 
  AND LeaveToDate <= '2026-11-04 23:59:59'
ORDER BY LeaveFromDate ASC;

-- =============================================================================
-- 2. KIỂM TRA LỊCH SỬ PHÊ DUYỆT PHÂN CẤP QUA CẢ 2 CẤP (tblApproverHistory)
-- =============================================================================
SELECT 
    h.Identity_ID,
    l.LeaveCode,
    CONVERT(varchar, l.LeaveFromDate, 23) AS [Ngày nghỉ],
    h.[Level] AS [Cấp],
    CASE h.[Level]
        WHEN 1 THEN N'Cấp 1 - Trí Nguyễn (004)'
        WHEN 2 THEN N'Cấp 2 - Trường Long (012)'
    END AS [Người duyệt],
    h.Approve_Status AS [Mã TT Cấp],
    CASE h.Approve_Status
        WHEN 2 THEN N'✅ Đã duyệt'
        WHEN 1 THEN N'⏳ Chờ duyệt'
        ELSE N'Chưa tới lượt'
    END AS [Trạng thái],
    CONVERT(varchar, h.Approval_Time, 120) AS [Thời điểm duyệt]
FROM tblApproverHistory h
JOIN tblLeaveRegistered l ON h.Identity_ID = CAST(l.IdentityID AS VARCHAR(50))
WHERE l.EmployeeID = '099' 
  AND l.LeaveFromDate >= '2026-10-22'
ORDER BY l.LeaveFromDate ASC, h.[Level] ASC;

-- =============================================================================
-- 3. KIỂM TRA TRẠNG THÁI 3 ĐƠN BÙ CÔNG (KỲ VỌNG: 15/10 = 2, 16/10 = 2, 14/10 = 4)
-- =============================================================================
SELECT 
    IdentityID,
    CONVERT(varchar, AttDate, 23) AS [Ngày bù công],
    In1, Out1,
    Approve_Status AS [Mã TT],
    CASE Approve_Status 
        WHEN 2 THEN N'✅ ĐÃ DUYỆT BÙ CÔNG (ĐỦ 8.0H)'
        WHEN 4 THEN N'🛑 ĐÃ DUYỆT HỦY ĐƠN (GIỮ NGUYÊN 6.0H)'
        ELSE N'Khác'
    END AS [Trạng thái]
FROM tblAttendanceConfirmRequest
WHERE EmployeeID = '099'
ORDER BY AttDate ASC;
```

---

## 🔗 6. BÀN GIAO KẾT QUẢ SANG PHÂN VÙNG FIX-7 (PAYROLL PIPELINE)

Sau khi `fix-6` hoàn tất phê duyệt toàn bộ các đơn:
1. **Dữ liệu công & nghỉ phép đã được chốt sổ trọn vẹn**:
   * Tháng 10/2026: Đầy đủ các ngày công chuẩn (12, 13, 15, 16/10), ngày công lẻ (14/10 = 6h), và 7 ngày nghỉ phép (trong đó 4 ngày hưởng 100% lương `AL`, `PH`, `FLWD`, `CT` và 3 ngày 0% lương `O`, `UL`, `ML`).
   * Tháng 11/2026: 3 ngày nghỉ phép (1 ngày hưởng 100% lương `WFH` và 2 ngày 0% lương `IO`, `PL`).
2. **Sẵn sàng bàn giao cho `fix-7`**: `fix-7` có đầy đủ các biến số phân loại ngày công/ngày phép để nạp thưởng phụ cấp, chạy tính lương (`PRL`) và kiểm tra đối soát chênh lệch lương chính xác 100%!
