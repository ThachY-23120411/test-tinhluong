-- =========================================================================================
-- FILE: test-evidence/test-flow-tinhluong/reset_and_seed_master_flow_tinhluong.sql
-- MỤC ĐÍCH: MASTER SCRIPT 1-CLICK: RESET TOÀN DIỆN & SEED SẠCH DỮ LIỆU ĐẦU VÀO
--           CHO TOÀN BỘ FLOW TÍNH LƯƠNG NHÂN VIÊN MỚI 099 (fix-4 --> fix-8)
--
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MÔI TRƯỜNG: Chạy an toàn trên Vietinsoft_ForTest_Tai2 / Vietinsoft_ForTest3 / Vietinsoft_ForTest_Tai
-- PHẠM VI 5 CONVERSATION (17 TEST CASES: TC-03 -> TC-19):
--   - fix-4: TC-03 (Lương 10M), TC-04 (1 NPT), TC-05 (Phân ca HC)
--   - fix-5: TC-06 (Khảo sát Before), TC-07 (Nộp & hủy bù công), TC-08 (Nghỉ phép AL), TC-09 (Tăng ca OT)
--   - fix-6: TC-10 (Trí duyệt C1), TC-11 (Long duyệt C1 OT), TC-12 (Duyệt C2 phép, bù công, OT), TC-13 (Đối soát After)
--   - fix-7: TC-14 (Thưởng KPI 1M), TC-15 (Tạm ứng 2M), TC-16 (Tính lương T10), TC-17 (Khóa sổ T10)
--   - fix-8: TC-18 (Bảng lương tổng hợp), TC-19 (Phiếu lương cá nhân & 3 modal chi tiết)
--
-- HƯỚNG DẪN SỬ DỤNG:
--   1. Mở SQL Server Management Studio (SSMS).
--   2. Mở file này -> Nhấn Ctrl + F5 (Kiểm tra cú pháp) -> Nhấn F5 để thực thi.
--   3. Sau đó chạy file Run-All-Flow-TinhLuong.bat để tự động kiểm thử toàn bộ 17 TCs.
-- =========================================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
PRINT N'=========================================================================================';
PRINT N'🚀 BẮT ĐẦU CHẠY MASTER SCRIPT: RESET TOÀN DIỆN & SEED DỮ LIỆU ĐẦU VÀO (fix-4 -> fix-8)...';
PRINT N'=========================================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    -- =====================================================================================
    -- PHẦN I: RESET TOÀN BỘ DỮ LIỆU CŨ PHÁT SINH TRONG LẦN TEST TRƯỚC (LÀM SẠCH 100%)
    -- =====================================================================================

    -- 0. BẢO VỆ TÀI KHOẢN QUẢN TRỊ (cuong.vu, chien.nguyen, admin)
    UPDATE tblSC_Login 
    SET LoginName = 'cuong.vu', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1 
    WHERE EmployeeID = '014' OR LoginName = 'cuong.vu';

    UPDATE tblSC_Login 
    SET LoginName = 'chien.nguyen', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1 
    WHERE EmployeeID = '013' OR LoginName = 'chien.nguyen';

    UPDATE tblSC_Login 
    SET isAdmin = 1, AdminRight = 1 
    WHERE LoginID = 1 OR LoginName = 'admin';
    PRINT N'🛡️  0. Đã bảo đảm an toàn quyền Admin cho cuong.vu (014), chien.nguyen (013), admin (1)';

    -- 1. [FIX-7] MỞ NIÊM PHONG KHÓA SỔ LƯƠNG & KHÓA CÔNG THÁNG 10/2026
    DELETE FROM tblSal_Lock 
    WHERE (EmployeeID = '099' OR EmployeeID = '-1') AND Month = 10 AND Year = 2026;

    DELETE FROM tblAtt_LockMonth 
    WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

    DELETE FROM tblatt_lock 
    WHERE EmployeeID = '099';
    PRINT N'✅ 1. [fix-7] Đã mở niêm phong khóa sổ lương & khóa công Tháng 10/2026 (tblSal_Lock, tblAtt_LockMonth, tblatt_lock)';

    -- 2. [FIX-7] XÓA BẢNG LƯƠNG TỔNG HỢP & CHI TIẾT TÍNH LƯƠNG CỦA NV 099
    DELETE FROM tblSal_Sal_Detail        WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Sal               WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_OT_Detail         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_OT                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_PaidLeave_Detail  WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_PaidLeave         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Allowance_Detail  WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Allowance         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Insurance         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_IO_Detail         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_IO                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_NS_Detail         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_NS                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Tax               WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_AttendanceData    WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Error             WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    PRINT N'✅ 2. [fix-7] Đã xóa kết quả tính tiền lương & chi tiết lương Tháng 10 của NV 099';

    -- 3. [FIX-7] XÓA TẠM ỨNG LƯƠNG THÁNG 10/2026 (tblSal_Advance)
    DELETE FROM tblSal_Advance 
    WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    PRINT N'✅ 3. [fix-7] Đã xóa dữ liệu tạm ứng lương của NV 099 (tblSal_Advance)';

    -- 4. [FIX-7] XÓA THƯỞNG KPI & THU NHẬP KHÔNG CỐ ĐỊNH THÁNG 10/2026
    DELETE FROM tblPR_Adjustment  WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Adjustment WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    PRINT N'✅ 4. [fix-7] Đã xóa thưởng KPI & thu nhập không cố định (tblPR_Adjustment, tblSal_Adjustment)';

    -- 5. [FIX-5 & FIX-6] XÓA ĐƠN BÙ CÔNG & LỊCH SỬ DUYỆT ĐƠN
    DELETE FROM tblApproverHistory 
    WHERE Identity_ID IN (
        SELECT IdentityID FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099'
        UNION
        SELECT IdentityID FROM tblLeaveRegistered WHERE EmployeeID = '099'
    );

    DELETE FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099';
    DELETE FROM tblInLateOutEarly           WHERE EmployeeID = '099';
    PRINT N'✅ 5. [fix-5/fix-6] Đã xóa đơn xin bù công & vi phạm đi trễ về sớm (tblAttendanceConfirmRequest, tblInLateOutEarly)';

    -- 6. [FIX-5 & FIX-6] XÓA ĐƠN NGHỈ PHÉP NĂM AL & LỊCH SỬ NGHỈ PHÉP
    DELETE FROM tblLeaveRegistered_Detail WHERE EmployeeID = '099';
    DELETE FROM tblLeaveRegistered        WHERE EmployeeID = '099';
    DELETE FROM tblLvHistory              WHERE EmployeeID = '099';
    PRINT N'✅ 6. [fix-5/fix-6] Đã xóa đơn xin nghỉ phép năm AL & lịch sử nghỉ phép (tblLeaveRegistered, tblLvHistory)';

    -- 7. [FIX-5 & FIX-6] XÓA ĐƠN XIN TĂNG CA OT
    DELETE FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '099';
    DELETE FROM tblOTList                     WHERE EmployeeID = '099';
    DELETE FROM tblotregistration             WHERE EmployeeID = '099';
    DELETE FROM tblOTRegistration_Web         WHERE EmployeeID = '099';
    PRINT N'✅ 7. [fix-5/fix-6] Đã xóa đơn xin tăng ca OT (tblOvertime_Assignment_Detail, tblOTList, tblotregistration)';

    -- 8. [FIX-4] XÓA PHÂN CA LÀM VIỆC & LỊCH CA CŨ
    DELETE FROM tblShiftGroupByEmployee WHERE EmployeeID = '099';
    DELETE FROM tblWSchedule            WHERE EmployeeID = '099';
    PRINT N'✅ 8. [fix-4] Đã làm sạch phân ca làm việc cũ (tblShiftGroupByEmployee, tblWSchedule - sẽ được seed đồng bộ ở Mục 15)';

    -- 9. [FIX-4] XÓA THÔNG TIN NGƯỜI PHỤ THUỘC GIẢM TRỪ GIA CẢNH
    DELETE FROM tblFamilyInfo WHERE EmployeeID = '099';
    PRINT N'✅ 9. [fix-4] Đã xóa người phụ thuộc giảm trừ gia cảnh (tblFamilyInfo - chờ TC-04 nạp lại)';

    -- 10. [FIX-4] XÓA HỢP ĐỒNG LAO ĐỘNG & LỊCH SỬ LƯƠNG
    DELETE FROM tblLabourContract WHERE EmployeeID = '099';
    DELETE FROM tblSalaryHistory  WHERE EmployeeID = '099';
    PRINT N'✅ 10. [fix-4] Đã xóa HĐLĐ & lịch sử lương (tblLabourContract, tblSalaryHistory - chờ TC-03 nạp lại)';

    -- XÓA EMAIL THÔNG BÁO RÁC LIÊN QUAN ĐẾN 099
    DELETE FROM tblEmailList WHERE EmployeeID = '099' OR SendToEmployeeID = '099';


    -- =====================================================================================
    -- PHẦN II: SEED TIỀN ĐỀ CHUẨN ĐỂ TC-03 BẮT ĐẦU CHẠY ĐƯỢC NGAY (VÀ CHẠY XUYÊN SUỐT TỚI TC-19)
    -- =====================================================================================

    -- 11. [TC-01 PRE-SEED] KHỞI TẠO HỒ SƠ NHÂN VIÊN 099 (NGUYỄN VĂN TEST)
    IF NOT EXISTS (SELECT 1 FROM tblEmployee WHERE EmployeeID = '099')
    BEGIN
        INSERT INTO tblEmployee (EmployeeID, FullName, LastName, FirstName, HireDate, Birthday, Sex, ID_Number)
        VALUES ('099', N'Nguyễn Văn Test', N'Nguyễn Văn', N'Test', '2026-10-01', '1995-05-15', 1, '079099888999');
        PRINT N'✅ 11a. Đã tạo mới hồ sơ nhân viên 099 (tblEmployee)';
    END
    ELSE
    BEGIN
        UPDATE tblEmployee 
        SET FullName = N'Nguyễn Văn Test', 
            LastName = N'Nguyễn Văn',
            FirstName = N'Test',
            HireDate = '2026-10-01', 
            Birthday = '1995-05-15', 
            Sex = 1, 
            ID_Number = '079099888999'
        WHERE EmployeeID = '099';
        PRINT N'✅ 11a. Đã chuẩn hóa hồ sơ nhân viên 099 (tblEmployee)';
    END

    -- 11b. TRẠNG THÁI LÀM VIỆC BÌNH THƯỜNG (StatusEndDate = NULL chuẩn hệ thống)
    IF NOT EXISTS (SELECT 1 FROM tblEmployeeStatusHistory WHERE EmployeeID = '099')
    BEGIN
        INSERT INTO tblEmployeeStatusHistory (EmployeeID, EmployeeStatusID, ChangedDate, StatusEndDate, Remark)
        VALUES ('099', 0, '2026-10-01', NULL, N'Làm việc bình thường');
        PRINT N'✅ 11b. Đã tạo trạng thái làm việc bình thường cho NV 099 (tblEmployeeStatusHistory)';
    END
    ELSE
    BEGIN
        UPDATE tblEmployeeStatusHistory 
        SET EmployeeStatusID = 0, ChangedDate = '2026-10-01', StatusEndDate = NULL
        WHERE EmployeeID = '099';
        PRINT N'✅ 11b. Đã chuẩn hóa trạng thái làm việc cho NV 099 (tblEmployeeStatusHistory)';
    END

    -- 11c. ĐƯA NV 099 VÀO CÂY NHÂN SỰ CỦA CÁC TÀI KHOẢN QUẢN TRỊ
    DELETE FROM tmpEmployeeTree WHERE EmployeeID = '099';
    INSERT INTO tmpEmployeeTree (EmployeeID, LoginID)
    SELECT '099', LoginID 
    FROM tblSC_Login 
    WHERE LoginName IN ('cuong.vu', 'chien.nguyen', 'admin') OR LoginID IN (1, 22, 23);
    PRINT N'✅ 11c. Đã đưa NV 099 vào cây nhân sự tmpEmployeeTree của cuong.vu, chien.nguyen, admin';

    -- 11d. PHÂN BỔ PHÒNG BAN & CHỨC VỤ (tblDivDepSecPos)
    IF NOT EXISTS (SELECT 1 FROM tblDivDepSecPos WHERE EmployeeID = '099')
    BEGIN
        INSERT INTO tblDivDepSecPos (EmployeeID, DivisionID, DepartmentID, PositionID, ChangedDate)
        VALUES ('099', 1, 3, 450, '2026-10-01');
        PRINT N'✅ 11d. Đã phân bổ phòng ban Nhân sự / Thử việc IT cho NV 099 (tblDivDepSecPos)';
    END
    ELSE
    BEGIN
        UPDATE tblDivDepSecPos
        SET DivisionID = 1, DepartmentID = 3, PositionID = 450, ChangedDate = '2026-10-01'
        WHERE EmployeeID = '099';
        PRINT N'✅ 11d. Đã chuẩn hóa phòng ban cho NV 099 (tblDivDepSecPos)';
    END

    -- 12. [TC-02 PRE-SEED] KHỞI TẠO TÀI KHOẢN ESS PORTAL test.nv / 123
    DELETE FROM tblSC_Right_Stored 
    WHERE LoginID IN (SELECT LoginID FROM tblSC_Login WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014'));

    DELETE FROM tblSC_Login 
    WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014');

    INSERT INTO tblSC_Login (
        LoginName, PassWord, EmployeeID, ParentLoginID, UseGroupRightOnly, NeedEncryptPassWordColumnList, IsDisable, IsGroup
    )
    VALUES (
        'test.nv', '123', '099', '9', 1, 'PassWord', 0, 0
    );

    INSERT INTO tblSC_Right_Stored (ObjectID, LoginID, FullAccess)
    SELECT 70, LoginID, 32 
    FROM tblSC_Login 
    WHERE LoginName = 'test.nv';
    PRINT N'✅ 12. Đã tạo mới tài khoản ESS Portal test.nv / 123 & cấp quyền menu (tblSC_Login, tblSC_Right_Stored)';

    -- 13. THIẾT LẬP MA TRẬN DUYỆT ĐƠN (tblApprovalLineByEmployee) CHO NV 099
    DELETE FROM tblApprovalLineByEmployee WHERE EmployeeID = '099';
    INSERT INTO tblApprovalLineByEmployee (
        EmployeeID, Approvalgrouplist, Approver_1, Delegacy_1, Approver_2, Delegacy_2, Approver_3, Delegacy_3, Approver_4, Delegacy_4, IsDelegacyView
    )
    SELECT '099', Approvalgrouplist, Approver_1, Delegacy_1, Approver_2, Delegacy_2, Approver_3, Delegacy_3, Approver_4, Delegacy_4, IsDelegacyView
    FROM tblApprovalLineByEmployee
    WHERE EmployeeID = '001';

    -- Chuẩn hóa đúng người duyệt cho 3 nhóm đơn test:
    -- Group 1 (Nghỉ phép): Cấp 1 = 004 (Trí), Cấp 2 = 012 (Long)
    -- Group 5 (Bù công): Cấp 1 = 004 (Trí), Cấp 2 = 012 (Long)
    -- Group 6 (Tăng ca OT): Cấp 1 = 012 (Long), Cấp 2 = 014 (Cường)
    IF EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 1)
        UPDATE tblApprovalLineByEmployee SET Approver_1 = '004', Approver_2 = '012' WHERE EmployeeID = '099' AND Approvalgrouplist = 1;
    ELSE
        INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Approver_2) VALUES ('099', 1, '004', '012');

    IF EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 5)
        UPDATE tblApprovalLineByEmployee SET Approver_1 = '004', Approver_2 = '012' WHERE EmployeeID = '099' AND Approvalgrouplist = 5;
    ELSE
        INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Approver_2) VALUES ('099', 5, '004', '012');

    IF EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 6)
        UPDATE tblApprovalLineByEmployee SET Approver_1 = '012', Approver_2 = '014' WHERE EmployeeID = '099' AND Approvalgrouplist = 6;
    ELSE
        INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Approver_2) VALUES ('099', 6, '012', '014');
    PRINT N'✅ 13. Đã thiết lập ma trận duyệt đơn (Group 1: Phép, Group 5: Bù công, Group 6: OT) (tblApprovalLineByEmployee)';

    -- 14. KHỞI TẠO QUOTA PHÉP NĂM AL = 2 NGÀY (tblEmployeeAnnual) CHO NV 099
    IF EXISTS (SELECT 1 FROM tblEmployeeAnnual WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026)
    BEGIN
        UPDATE tblEmployeeAnnual
        SET ThisYear = 2, Taken = 0, Remain = 2, ALThisYear = 2, ALPaidDays = 0
        WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026;
    END
    ELSE
    BEGIN
        INSERT INTO tblEmployeeAnnual (EmployeeID, CYear, LeaveCode, ThisYear, Taken, Remain, ALThisYear, FirstALMonth)
        VALUES ('099', 2026, 'AL', 2, 0, 2, 2, 10);
    END
    PRINT N'✅ 14. Đã khởi tạo ngân sách phép năm AL = 2 ngày (Remain = 2) cho NV 099 (tblEmployeeAnnual)';

    -- 15. SEED DỮ LIỆU CHẤM CÔNG & PHÂN CA THÁNG 10/2026 (ĐỒNG BỘ tblWSchedule, tblHasTA VÀ tblTmpAttend)
    DECLARE @FromDate DATE, @ToDate DATE;
    SELECT @FromDate = CAST(FromDate AS DATE), @ToDate = CAST(ToDate AS DATE)
    FROM dbo.fn_Get_SalaryPeriod(10, 2026);

    IF @FromDate IS NULL SET @FromDate = '2026-10-10';
    IF @ToDate IS NULL   SET @ToDate   = '2026-11-09';

    -- Xóa dữ liệu cũ trong kỳ của NV 099
    DELETE FROM tblHasTA 
    WHERE EmployeeID = '099' AND CAST(AttDate AS DATE) BETWEEN @FromDate AND @ToDate;

    DELETE FROM tblTmpAttend
    WHERE EmployeeID = '099' AND CAST(AttTime AS DATE) BETWEEN @FromDate AND @ToDate;

    DECLARE @d DATE = @FromDate;
    DECLARE @IsWeekend BIT;
    DECLARE @AttStart DATETIME, @AttEnd DATETIME, @WorkHours FLOAT;
    DECLARE @NormalDays INT = 0;
    DECLARE @CurShiftID INT;
    DECLARE @CurHolidayStatus INT;

    WHILE @d <= @ToDate
    BEGIN
        SET @IsWeekend = CASE WHEN ((DATEPART(dw, @d) + @@DATEFIRST) % 7) IN (0, 1) THEN 1 ELSE 0 END;

        -- Xác định ca làm việc theo thứ: 1=CN, 2=T2, 3=T3, 4=T4, 5=T5, 6=T6, 7=T7 (khớp ShiftID ca HC trong tblShiftSetting)
        SET @CurShiftID = ((DATEPART(dw, @d) + @@DATEFIRST - 2) % 7) + 1;
        SET @CurHolidayStatus = CASE WHEN @IsWeekend = 1 THEN 1 ELSE 0 END;

        IF @d = '2026-10-14'
        BEGIN
            -- Ngày đặc biệt 1: 08:00 - 15:00 (6.0h công lẻ -> Test nộp nhầm đơn bù Giờ Ra rồi tự hủy)
            SET @AttStart  = CAST('2026-10-14 08:00:00' AS DATETIME);
            SET @AttEnd    = CAST('2026-10-14 15:00:00' AS DATETIME);
            SET @WorkHours = 6.0;
        END
        ELSE IF @d = '2026-10-15'
        BEGIN
            -- Ngày đặc biệt 2: 08:00 - 12:00 (4.0h công lẻ -> Test nộp bù Giờ Ra 17:00 ĐƯỢC DUYỆT -> 8.0h)
            SET @AttStart  = CAST('2026-10-15 08:00:00' AS DATETIME);
            SET @AttEnd    = CAST('2026-10-15 12:00:00' AS DATETIME);
            SET @WorkHours = 4.0;
        END
        ELSE IF @d = '2026-10-16'
        BEGIN
            -- Ngày đặc biệt 3: 08:00 - 16:00 (7.0h công lẻ -> Test bù Giờ Ra 17:00 BỊ TỪ CHỐI -> giữ 7.0h)
            SET @AttStart  = CAST('2026-10-16 08:00:00' AS DATETIME);
            SET @AttEnd    = CAST('2026-10-16 16:00:00' AS DATETIME);
            SET @WorkHours = 7.0;
        END
        ELSE IF @d = '2026-10-22'
        BEGIN
            -- Ngày đặc biệt 4 (22/10 Thứ 5: Ngày làm việc có phân ca nhưng TRỐNG CÔNG để test nộp đơn xin Nghỉ phép AL 1 ngày = 8.0h ở TC-08)
            SET @AttStart  = NULL;
            SET @AttEnd    = NULL;
            SET @WorkHours = 0.0;
        END
        ELSE IF @IsWeekend = 1
        BEGIN
            -- Tất cả Thứ 7 / Chủ Nhật: Trống (0.0h)
            SET @AttStart  = NULL;
            SET @AttEnd    = NULL;
            SET @WorkHours = 0.0;
        END
        ELSE
        BEGIN
            -- Các ngày làm việc chuẩn (Thứ 2 -> Thứ 6): 08:00 - 17:00 (8.0h công)
            SET @AttStart  = DATEADD(HOUR, 8, CAST(@d AS DATETIME));
            SET @AttEnd    = DATEADD(HOUR, 17, CAST(@d AS DATETIME));
            SET @WorkHours = 8.0;
            SET @NormalDays = @NormalDays + 1;
        END

        -- 1. ĐỒNG BỘ LỊCH PHÂN CA (tblWSchedule) - ĐIỀU KIỆN TIÊN QUYẾT ĐỂ spDailyAttendanceData HIỂN THỊ LÊN LƯỚI CHẤM CÔNG CÁ NHÂN!
        IF EXISTS (SELECT 1 FROM tblWSchedule WHERE EmployeeID = '099' AND CAST(ScheduleDate AS DATE) = @d)
        BEGIN
            UPDATE tblWSchedule
            SET ShiftID = @CurShiftID,
                HolidayStatus = @CurHolidayStatus
            WHERE EmployeeID = '099' AND CAST(ScheduleDate AS DATE) = @d;
        END
        ELSE
        BEGIN
            INSERT INTO tblWSchedule (EmployeeID, ScheduleDate, ShiftID, HolidayStatus)
            VALUES ('099', CAST(@d AS DATETIME), @CurShiftID, @CurHolidayStatus);
        END

        -- 2. Chèn vào tblHasTA
        INSERT INTO tblHasTA (EmployeeID, AttDate, Period, AttStart, AttEnd, WorkingTime, RealWorkingTime, Approve)
        VALUES ('099', CAST(@d AS DATETIME), 0, @AttStart, @AttEnd, @WorkHours, @WorkHours, 0);

        -- 3. Đồng bộ quẹt thẻ vào tblTmpAttend để khi Recalculate không bị xóa về 0h
        IF @AttStart IS NOT NULL AND @AttEnd IS NOT NULL
        BEGIN
            INSERT INTO tblTmpAttend (EmployeeID, AttTime, AttState, MachineNo) VALUES ('099', @AttStart, 1, 1);
            INSERT INTO tblTmpAttend (EmployeeID, AttTime, AttState, MachineNo) VALUES ('099', @AttEnd, 2, 1);
        END

        SET @d = DATEADD(DAY, 1, @d);
    END;

    -- Xóa hàng đợi pending phát sinh
    DELETE FROM tblPendingImportAttend WHERE EmployeeID = '099' AND Date BETWEEN @FromDate AND @ToDate;
    DELETE FROM tblPendingTaProcessMain WHERE EmployeeID = '099' AND Date BETWEEN @FromDate AND @ToDate;

    PRINT N'✅ 15. Đã seed toàn bộ kỳ công Tháng 10/2026 (' + CAST(@NormalDays AS NVARCHAR(10)) + N' ngày chuẩn 8.0h + 3 ngày công lẻ 14, 15, 16/10) đồng bộ trọn vẹn cả 3 bảng (tblWSchedule, tblHasTA, tblTmpAttend)';

    COMMIT TRANSACTION;
    PRINT N'=========================================================================================';
    PRINT N'🎉 HOÀN TẤT THỰC THI MASTER SCRIPT! CSDL ĐÃ SẴN SÀNG 100% CHO TOÀN BỘ FLOW (fix-4 -> fix-8)!';
    PRINT N'=========================================================================================';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'❌ CÓ LỖI XẢY RA: ' + ERROR_MESSAGE();
END CATCH;
GO

-- =========================================================================================
-- BẢNG ĐỐI SOÁT CSDL SAU KHI CHẠY MASTER RESET & SEED
-- =========================================================================================
PRINT N'';
PRINT N'📊 BẢNG 0: KIỂM TRA DỮ LIỆU ĐÃ ĐƯỢC RESET (LƯƠNG, NPT, PHÂN CA FIX-4 & TÍNH LƯƠNG FIX-7 PHẢI = 0):';
SELECT 
    (SELECT COUNT(*) FROM tblSalaryHistory WHERE EmployeeID = '099') AS [Lương TC-03 (Cần = 0)],
    (SELECT COUNT(*) FROM tblFamilyInfo WHERE EmployeeID = '099') AS [NPT TC-04 (Cần = 0)],
    (SELECT COUNT(*) FROM tblShiftGroupByEmployee WHERE EmployeeID = '099') AS [Phân ca TC-05 (Cần = 0)],
    (SELECT COUNT(*) FROM tblSal_Sal WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Bảng lương TC-16 (Cần = 0)];

PRINT N'';
PRINT N'📊 BẢNG 1: KIỂM TRA HỒ SƠ & TÀI KHOẢN TIỀN ĐỀ:';
SELECT 
    e.EmployeeID, 
    e.FullName, 
    e.HireDate, 
    l.LoginName, 
    l.IsDisable,
    (SELECT COUNT(*) FROM tmpEmployeeTree WHERE EmployeeID = '099') AS TreeCount,
    (SELECT COUNT(*) FROM tblApprovalLineByEmployee WHERE EmployeeID = '099') AS ApprovalGroupCount,
    (SELECT Remain FROM tblEmployeeAnnual WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026) AS QuotaPhepAL
FROM tblEmployee e
LEFT JOIN tblSC_Login l ON e.EmployeeID = l.EmployeeID
WHERE e.EmployeeID = '099';

PRINT N'';
PRINT N'📊 BẢNG 2: KIỂM TRA DỮ LIỆU PHÂN CA & CÔNG MẪU TRƯỚC KHI CHẠY TEST (tblWSchedule & tblHasTA):';
SELECT 
    CONVERT(varchar, ws.ScheduleDate, 23) AS [Ngày],
    DATENAME(dw, ws.ScheduleDate) AS [Thứ],
    ws.ShiftID AS [Mã Ca],
    CASE WHEN ws.HolidayStatus = 1 THEN N'Nghỉ tuần' ELSE N'Làm việc' END AS [Lịch phân ca],
    ISNULL(CONVERT(varchar(5), hta.AttStart, 108), '--:--') AS [Giờ Vào],
    ISNULL(CONVERT(varchar(5), hta.AttEnd, 108), '--:--') AS [Giờ Ra],
    ISNULL(hta.WorkingTime, 0) AS [Giờ Công],
    CAST(ROUND(ISNULL(hta.WorkingTime, 0) / 8.0, 3) AS decimal(5,3)) AS [Quy đổi công],
    CASE 
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-14' THEN N'Đặc biệt 1: 6.0h (Nộp nhầm & Tự hủy)'
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-15' THEN N'Đặc biệt 2: 4.0h (Chờ bù Giờ Ra 17:00 -> DUYỆT)'
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-16' THEN N'Đặc biệt 3: 7.0h (Chờ bù Giờ Ra 17:00 -> TỪ CHỐI)'
        WHEN CONVERT(varchar, ws.ScheduleDate, 23) = '2026-10-22' THEN N'Đặc biệt 4: 0.0h (Chờ Nghỉ phép AL 1 ngày)'
        WHEN ws.HolidayStatus = 1 THEN N'Cuối tuần (T7/CN) - Nghỉ'
        ELSE N'Ngày làm việc chuẩn 8.0h (08:00 - 17:00)'
    END AS [Trạng thái kỳ vọng Before]
FROM tblWSchedule ws
LEFT JOIN tblHasTA hta ON hta.EmployeeID = ws.EmployeeID AND hta.AttDate = ws.ScheduleDate
WHERE ws.EmployeeID = '099' AND ws.ScheduleDate BETWEEN '2026-10-12' AND '2026-10-25'
ORDER BY ws.ScheduleDate;
GO


  

  

  

  
