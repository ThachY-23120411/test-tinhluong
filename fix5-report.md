# BÁO CÁO TỔNG HỢP CÁC STORED PROCEDURE ĐÃ SỬA — PHÂN VÙNG FIX-5

- **Phân vùng / Conversation**: `fix-5` (Cổng thông tin nhân sự ESS — Nhân viên mới `099 - Nguyễn Văn Test` / `test.nv`)
- **Ngày lập báo cáo**: `2026-11-12`
- **Database đối soát**: `Vietinsoft_ForTest_Tai2` (Chế độ **Read-Only** theo Điều 1 `AGENTS.md`)
- **Tài liệu kịch bản liên quan**: [kb_fix5.md](kb_fix5.md) | [tests/quy_trinh_tinh_luong_nv_moi.spec.js](tests/quy_trinh_tinh_luong_nv_moi.spec.js) (`TC-06` $\rightarrow$ `TC-09`)

---

## 📊 TỔNG QUAN CÁC STORED PROCEDURE ĐÃ SỬA / ĐỀ XUẤT VÁ

| STT | Tên Stored Procedure | File Origin (Before) | File Fix / Patch (After) | Trạng thái trên DB |
| :-: | :--- | :--- | :--- | :--- |
| 1 | `[dbo].[sp_CheckCancelPermission]` | *(Bản gốc kiểm tra `Approve_Status = 2`)* | [scripts/patch_allow_cancel_pending_request.sql](scripts/patch_allow_cancel_pending_request.sql) | ✅ Đã được Người Dùng Execute lên DB |
| 2 | `[dbo].[sp_ApproveAttendanceRequest]` | [fix-bug/sp_ApproveAttendanceRequest-2026-11-12/origin.sql](fix-bug/sp_ApproveAttendanceRequest-2026-11-12/origin.sql) | [fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql](fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql) | ⏳ *(Đang chờ Người Dùng Execute trên SSMS)* |

---

## CHI TIẾT TỪNG STORED PROCEDURE

### 1. `[dbo].[sp_CheckCancelPermission]` — Cho phép nhân viên tự hủy đơn bù công khi đang Chờ duyệt

#### 1.1. Hiện trạng & Vấn đề phát sinh (Before)
- Trong luồng nghiệp vụ `TC-07` (Ngày `14/10/2026`), nhân viên `test.nv` nộp nhầm 1 đơn xin bù công (trạng thái ban đầu là **Chờ duyệt** — `Approve_Status = 1`), sau đó vào Tab **Lịch sử** bấm vào thẻ đơn vừa tạo để tự bấm nút **Xin hủy đơn** (`.btnDestroy`).
- Tuy nhiên khi mở chi tiết đơn Chờ duyệt, nút màu đỏ **Xin hủy đơn** bị ẩn hoàn toàn (`d-none`) dù chính nhân viên đó vừa nộp đơn xong.

#### 1.2. Nguyên nhân gốc rễ (Root Cause Analysis)
- UI màn hình `sp_MakeupHours` (`MnuHRS033`) gọi Stored Procedure `[dbo].[sp_CheckCancelPermission]` để kiểm tra quyền hiển thị nút `.btnDestroy`.
- Thủ tục gốc `[dbo].[sp_CheckCancelPermission]` giới hạn điều kiện:
  ```sql
  WHERE IdentityID = @IdentityID
    AND a.EmployeeID = @EmployeeID
    AND Approve_Status = 2
  ```
- Điều kiện cứng `Approve_Status = 2` chỉ cho phép hủy đơn khi đơn **Đã duyệt xong hoàn toàn**, chặn không cho người tạo tự hủy đơn đang ở trạng thái **Chờ duyệt (`Approve_Status = 1`)**.

#### 1.3. Đối chiếu Before vs After (Diff SQL)
- **File bản vá**: [scripts/patch_allow_cancel_pending_request.sql](scripts/patch_allow_cancel_pending_request.sql)

```diff
     SELECT EmployeeID, IdentityID, Approve_Status
     FROM tblAttendanceConfirmRequest a
     WHERE IdentityID = @IdentityID 
       AND a.EmployeeID = @EmployeeID 
-      AND Approve_Status = 2;
+      AND Approve_Status IN (1, 2);
```

#### 1.4. Kết quả kiểm chứng
- Thủ tục trên DB hiện tại đã được cập nhật thành `Approve_Status IN (1, 2)`.
- Khi chạy thực tế `TC-07` trên Google Chrome, nút **Xin hủy đơn** hiển thị ngay khi bấm vào thẻ đơn Chờ duyệt ngày `14/10`, cho phép nhập lý do và gửi hủy thành công (`Approve_Status = 5` / `4`).

---

### 2. `[dbo].[sp_ApproveAttendanceRequest]` — Tự động tính lại công (`tblHasTA`) ngay khi duyệt / duyệt hủy đơn Xin bù công

#### 2.1. Hiện trạng & Vấn đề phát sinh (Before)
- Sau khi `fix-6` phê duyệt xong toàn bộ đơn của NV `099`:
  - Đơn **Nghỉ phép ngày `24/10`** hiển thị ngay lập tức trên màn hình **Chấm công cá nhân** (`MnuWPT010`).
  - Nhưng các đơn **Xin bù công** (ngày `15/10` đã duyệt) vẫn giữ nguyên số giờ công cũ (`4.0h`), **không tự cập nhật lên `8.0h`** trên màn hình Chấm công cá nhân.

#### 2.2. Nguyên nhân gốc rễ (Root Cause Analysis)
Qua kiểm tra trực tiếp định nghĩa các Stored Procedure và bảng dữ liệu liên quan trong CSDL:

1. **Cơ chế lưu trữ khác biệt giữa Nghỉ phép và Bù công**:
   - Duyệt **Nghỉ phép** ghi trực tiếp vào bảng `tblLvHistory`. Màn hình Chấm công cá nhân (`spDailyAttendanceData`) join trực tiếp `LEFT JOIN tblLvHistory` nên **hiển thị tức thì**.
   - Duyệt **Xin bù công** (`sp_ApproveAttendanceRequest`), tại nhánh cấp duyệt cuối (`IF @CurrentLevel > @MaxLevel`), SP **chỉ `INSERT` giờ bổ sung vào bảng quẹt thẻ thô `tblTmpAttend`** (và trigger `trigtblTmpAttendForPending` đẩy ngày đó vào hàng đợi `tblPendingImportAttend`), **chưa tự gọi `sp_ReCalculate_TAData`** để tổng hợp từ `tblTmpAttend` $\rightarrow$ `tblHasTA`.
2. **Vì sao Service chạy ngầm không tự cập nhật**:
   - Trên DB test hiện tại, toàn bộ tác vụ trong bảng `Taskschedule` (gồm `IDTask = 48, 50, 51` — `TA_ShiftDetector_task`) đều đang tắt (**`IsActive = 0`**, dừng từ `2026-09-30 09:38:05`), làm hàng đợi `tblPendingImportAttend` tồn đọng **3.335 dòng** chưa xử lý.
   - Kể cả khi bật Service, bản thân SP `TA_ShiftDetector_task` cũng giới hạn cứng chỉ quét **5 ngày gần nhất** (`DECLARE @FromDate DATETIME = DATEADD(DAY, -5, GETDATE())`), nên đơn bù công ngày `15/10/2026` (quá 5 ngày so với `12/11/2026`) sẽ **không bao giờ được quét tới**.
   - Đồng thời, tài khoản nhân viên `test.nv` (`LoginID = 1241`) không nằm trong cây phân quyền quản lý (`fn_vtblEmployeeList_Simple_ByDate` trả rỗng) nên cũng không thể tự bấm nút **Tính toán lại** trên giao diện Chấm công cá nhân.
3. **Nguyên nhân phụ từ dữ liệu seed & giờ bù công cũ (đã khắc phục đồng bộ)**:
   - Trước đó `scripts/seed_attendance_5days_nv099.sql` seed nhầm giờ vào của `14, 15, 16/10` là `07:00` (không đúng ca chuẩn công ty `08:00 - 17:00`), chỉ seed vào `tblHasTA` mà thiếu bảng thô `tblTmpAttend`, và `TC-07` ngày `15/10` lại xin bù Giờ Vào `08:00` (trùng khoảng giờ sáng đã làm) thay vì **Giờ Ra `17:00`**.

#### 2.3. Đối chiếu Before vs After (Diff SQL)
- **Bản gốc (Before)**: [fix-bug/sp_ApproveAttendanceRequest-2026-11-12/origin.sql](fix-bug/sp_ApproveAttendanceRequest-2026-11-12/origin.sql)
- **Bản vá (After)**: [fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql](fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql)

```diff
--- a/fix-bug/sp_ApproveAttendanceRequest-2026-11-12/origin.sql
+++ b/fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql
@@ -1,4 +1,4 @@
-CREATE PROCEDURE [dbo].[sp_ApproveAttendanceRequest]
+ALTER PROCEDURE [dbo].[sp_ApproveAttendanceRequest]
     @IdentityID VARCHAR(36),
     @LoginID INT,
     @Remark NVARCHAR(500) = ''
@@ -94,6 +94,19 @@ BEGIN
 					FROM tblAttendanceConfirmRequest_detail a
 					INNER JOIN tblAttendanceConfirmRequest b ON a.IdentityID = b.IdentityID
 					WHERE a.IdentityID = @IdentityID
+
+					-- Tự động tính lại công ngay từ tblTmpAttend -> tblHasTA cho ngày vừa duyệt bù công
+					DECLARE @AttDateRecalc DATE = CAST(@AttDate AS DATE);
+					IF @AttDateRecalc IS NOT NULL AND @EmployeeID IS NOT NULL
+					BEGIN
+						EXEC dbo.sp_ReCalculate_TAData
+							@LoginID = NULL,
+							@Fromdate = @AttDateRecalc,
+							@ToDate = @AttDateRecalc,
+							@EmployeeID_Pram = @EmployeeID,
+							@RunShiftDetector = 1,
+							@RunTA_Precess_Main = 1;
+					END
 				END
 
@@ -123,6 +136,19 @@ BEGIN
 				-- Xóa dữ liệu trong bảng chấm công
 				DELETE tblTmpAttend WHERE IdentityID = @IdentityID
 
+				-- Tự động tính lại công ngay sau khi duyệt hủy đơn bù công
+				DECLARE @AttDateCancelRecalc DATE = CAST(@AttDate AS DATE);
+				IF @AttDateCancelRecalc IS NOT NULL AND @EmployeeID IS NOT NULL
+				BEGIN
+					EXEC dbo.sp_ReCalculate_TAData
+						@LoginID = NULL,
+						@Fromdate = @AttDateCancelRecalc,
+						@ToDate = @AttDateCancelRecalc,
+						@EmployeeID_Pram = @EmployeeID,
+						@RunShiftDetector = 1,
+						@RunTA_Precess_Main = 1;
+				END
+
 				-- Gửi thông báo cho người tạo đơn
```

- **Giải thích kỹ thuật**: Truyền `@LoginID = NULL` (mặc định dùng tree hệ thống `712` kết hợp bộ lọc `@EmployeeID_Pram = @EmployeeID`) và khóa phạm vi `@Fromdate = @ToDate = @AttDateRecalc` giúp tính công chính xác tức thì cho **chỉ 1 nhân viên và 1 ngày vừa duyệt**, đảm bảo hiệu năng cao và không phụ thuộc quyền phân cây của người duyệt.

#### 2.4. Minh chứng sau khi sửa (After Fix)
*(Đang chờ Người Dùng Execute file [fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql](fix-bug/sp_ApproveAttendanceRequest-2026-11-12/fix-bug.sql) trên SSMS và xác nhận cập nhật)*

---

## 🛠️ CÁC SCRIPT SEED / CLEAN & KỊCH BẢN TEST ĐÃ ĐỒNG BỘ KÈM THEO

1. [**`scripts/clean_test_requests_fix5.sql`**](scripts/clean_test_requests_fix5.sql): Làm sạch toàn bộ đơn từ cũ, `tblLvHistory`, `tblHasTA`, `tblTmpAttend`, `tblPendingImportAttend`, `tblPendingTaProcessMain` của NV `099` trước mỗi phiên test.
2. [**`scripts/seed_attendance_5days_nv099.sql`**](scripts/seed_attendance_5days_nv099.sql): Nạp đồng bộ cả `tblHasTA` lẫn bảng quẹt thẻ thô `tblTmpAttend` theo đúng giờ hành chính công ty (`08:00 - 17:00`) cho toàn kỳ công Tháng 10/2026 (`10/10` $\rightarrow$ `09/11/2026`):
   - Ngày thường (T2 $\rightarrow$ T6): `08:00 - 17:00` (**8.0h**).
   - Thứ 7, Chủ Nhật & ngày `24/10`: `0.0h`.
   - 3 ngày đặc biệt: `14/10` (`08:00 - 15:00` = **6.0h**), `15/10` (`08:00 - 12:00` = **4.0h**), `16/10` (`08:00 - 16:00` = **7.0h**).
3. [**`tests/quy_trinh_tinh_luong_nv_moi.spec.js`**](tests/quy_trinh_tinh_luong_nv_moi.spec.js) (`TC-06`, `TC-07`, `TC-09`):
   - `TC-06`: Click mở dropdown Tháng, cuộn & click mục thứ 10 (`Tháng 10`) không gõ Enter / không nhấn Làm mới.
   - `TC-07`: Cả 3 đơn `14/10`, `15/10`, `16/10` đều chọn `#select_inout = '2'` (**Ra**) và nhập **`17:00`**; sau khi hủy đơn `14/10`, di chuột Neon sang menu **Xin bù công** bên Sidebar trái (`#MnuHRS033 a`) để nạp lại form mới.
