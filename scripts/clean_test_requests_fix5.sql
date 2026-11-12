-- =========================================================================================
-- FILE: scripts/clean_test_requests_fix5.sql
-- MỤC ĐÍCH: RESET & LÀM SẠCH TOÀN BỘ MÔI TRƯỜNG DỮ LIỆU ĐƠN TỪ & CHẤM CÔNG CỦA NV 099
-- (CHUYÊN BIỆT LÀM SẠCH - TRIỆT TIÊU 100% DỮ LIỆU CŨ ĐỂ SẴN SÀNG CHO PHIÊN TEST MỚI)
-- TỰ ĐỘNG XỬ LÝ 5 NỘI DUNG CỐT LÕI:
--   1. XÓA SẠCH CÁC ĐƠN ESS PHÁT SINH (BÙ CÔNG 15/10 & 16/10, NGHỈ PHÉP 24/10, TĂNG CA 20/10)
--   2. XÓA LỊCH SỬ NGHỈ THỰC TẾ (tblLvHistory) VÀ KHÔI PHỤC NGÂN SÁCH PHÉP NĂM (Remain = 2 ngày)
--      -> Triệt tiêu hoàn toàn lỗi: "Số ngày nghỉ vượt quá số phép năm còn lại / Quá số lần giới hạn"
--   3. TỰ ĐỘNG THIẾT LẬP TUYẾN NGƯỜI DUYỆT (tblApprovalLineByEmployee) CHO NHÂN VIÊN 099
--      -> Triệt tiêu hoàn toàn lỗi: "Chưa thiết lập người duyệt vui lòng kiểm tra lại!"
--   4. RESET TOÀN BỘ BẢNG CHẤM CÔNG (tblHasTA) CỦA NV 099 VỀ TRẠNG THÁI SẠCH TINH (AttStart = NULL, 0.0h)
--   5. XÓA DỮ LIỆU QUẸT THẺ THÔ (CHECKINOUT) PHÁT SINH TRONG THÁNG 10/2026 CỦA NV 099
-- =========================================================================================
-- Hướng dẫn: Mở trên SQL Server Management Studio (SSMS) -> Bấm Ctrl+F5 kiểm tra cú pháp -> F5 để thực thi
-- =========================================================================================

SET NOCOUNT ON;
PRINT N'=============================================================================';
PRINT N'🧹 BẮT ĐẦU LÀM SẠCH TOÀN DIỆN MÔI TRƯỜNG ĐƠN TỪ & CHẤM CÔNG CHO NV 099...';
PRINT N'=============================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    -- -------------------------------------------------------------------------
    -- 1. XÓA ĐƠN XIN BÙ CÔNG (sp_MakeupHours / MnuHRS033)
    -- -------------------------------------------------------------------------
    DELETE FROM tblAttendanceConfirmRequest_detail
    WHERE IdentityID IN (SELECT IdentityID FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099');
    
    DELETE FROM tblAttendanceConfirmRequest
    WHERE EmployeeID = '099';
    PRINT N'✅ [1/5] Đã xóa toàn bộ đơn bù công phát sinh của NV 099 (tblAttendanceConfirmRequest & _detail)';

    -- -------------------------------------------------------------------------
    -- 2. XÓA ĐƠN XIN NGHỈ PHÉP & KHÔI PHỤC NGÂN SÁCH PHÉP NĂM (sp_ResignationLeave / MnuWPT315)
    -- -------------------------------------------------------------------------
    DELETE FROM tblLeaveRegistered_Detail
    WHERE EmployeeID = '099' 
       OR IdentityID IN (SELECT IdentityID FROM tblLeaveRegistered WHERE EmployeeID = '099');

    DELETE FROM tblLeaveRegistered
    WHERE EmployeeID = '099';

    -- Xóa lịch sử ngày nghỉ thực tế trong tblLvHistory (ngăn chặn lỗi cộng dồn số ngày đã nghỉ Taken)
    DELETE FROM tblLvHistory
    WHERE EmployeeID = '099';

    -- Tái tạo ngân sách phép năm qua Stored Procedure hệ thống (nếu có)
    IF OBJECT_ID('dbo.HR_LeaveBudget_Initialization', 'P') IS NOT NULL
    BEGIN
        EXEC HR_LeaveBudget_Initialization @LoginID = 3, @CalendarYear = 2026, @LeaveCode = 'AL', @EmployeeID = '099', @CalcToDate = '2026-10-31';
    END

    -- Cấp đủ hạn mức phép năm còn lại (Remain = 2 ngày, Taken = 0) cho NV 099
    IF EXISTS (SELECT 1 FROM tblEmployeeAnnual WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026)
    BEGIN
        UPDATE tblEmployeeAnnual
        SET ThisYear = 2,
            Taken = 0,
            Remain = 2,
            ALThisYear = 2,
            ALPaidDays = 0
        WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026;
    END
    ELSE
    BEGIN
        INSERT INTO tblEmployeeAnnual (EmployeeID, CYear, LeaveCode, ThisYear, Taken, Remain, ALThisYear, FirstALMonth)
        VALUES ('099', 2026, 'AL', 2, 0, 2, 2, 10);
    END
    PRINT N'✅ [2/5] Đã xóa đơn nghỉ phép (tblLeaveRegistered, tblLvHistory) & khôi phục ngân sách phép AL = 2 ngày (tblEmployeeAnnual)';

    -- -------------------------------------------------------------------------
    -- 3. XÓA ĐƠN XIN TĂNG CA OT (sp_Overtime_Assignment / MnuWPT316)
    -- -------------------------------------------------------------------------
    DELETE FROM tblOvertime_Assignment_Detail
    WHERE EmployeeID = '099'
       OR Identity_ID IN (SELECT Identity_ID FROM tblOTListRegistered WHERE EmployeeID = '099');

    DELETE FROM tblApproverHistory
    WHERE Identity_ID IN (SELECT Identity_ID FROM tblOTListRegistered WHERE EmployeeID = '099');

    DELETE FROM tblOTListRegistered
    WHERE EmployeeID = '099';

    DELETE FROM tblOTList
    WHERE EmployeeID = '099';

    DELETE FROM tblotregistration
    WHERE EmployeeID = '099';

    DELETE FROM tblOTRegistration_Web
    WHERE EmployeeID = '099';
    PRINT N'✅ [3/5] Đã xóa dữ liệu đơn tăng ca (tblOvertime_Assignment_Detail, tblOTListRegistered, tblOTList, tblotregistration)';

    -- -------------------------------------------------------------------------
    -- 4. BẢO ĐẢM THIẾT LẬP TUYẾN NGƯỜI DUYỆT (tblApprovalLineByEmployee)
    -- -------------------------------------------------------------------------
    DELETE FROM tblApprovalLineByEmployee WHERE EmployeeID = '099';
    INSERT INTO tblApprovalLineByEmployee (
        EmployeeID, Approvalgrouplist, Approver_1, Delegacy_1, Approver_2, Delegacy_2, Approver_3, Delegacy_3, Approver_4, Delegacy_4, IsDelegacyView
    )
    SELECT '099', Approvalgrouplist, Approver_1, Delegacy_1, Approver_2, Delegacy_2, Approver_3, Delegacy_3, Approver_4, Delegacy_4, IsDelegacyView
    FROM tblApprovalLineByEmployee
    WHERE EmployeeID = '001';

    -- Bổ sung dự phòng 3 nhóm cốt lõi nếu không kế thừa được từ 001
    IF NOT EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 6)
    BEGIN
        INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Approver_2)
        VALUES 
            ('099', 6, '012', '014'), -- Nhóm 6: Tăng ca OT (LongKa -> cuong.vu)
            ('099', 1, '004', '014'), -- Nhóm 1: Nghỉ phép AL (ThanhLong -> cuong.vu)
            ('099', 5, '004', '014'); -- Nhóm 5: Bù công (ThanhLong -> cuong.vu)
    END
    PRINT N'✅ [4/5] Đã thiết lập hoàn tất tuyến duyệt 2 cấp cho NV 099 (tblApprovalLineByEmployee)';

    -- -------------------------------------------------------------------------
    -- 5. KHÔI PHỤC BẢNG CHẤM CÔNG VỀ TRẠNG THÁI SẠCH 100% (tblHasTA & CHECKINOUT)
    -- -------------------------------------------------------------------------
    -- Reset toàn bộ giờ vào/ra và giờ công của NV 099 về NULL và 0.0h
    UPDATE tblHasTA
    SET AttStart = NULL,
        AttEnd = NULL,
        RealWorkingTime = 0.0,
        WorkingTime = 0.0,
        Approve = 0,
        TAStatus = NULL,
        TimeReason = NULL
    WHERE EmployeeID = '099';

    -- Xóa nhật ký quẹt thẻ thô phát sinh (tblTmpAttend, CHECKINOUT) và hàng đợi tính công của NV 099
    DELETE FROM tblTmpAttend WHERE EmployeeID = '099';
    DELETE FROM tblPendingImportAttend WHERE EmployeeID = '099';
    DELETE FROM tblPendingTaProcessMain WHERE EmployeeID = '099';
    DELETE FROM CHECKINOUT 
    WHERE USERID = 99 AND CHECKTIME >= '2026-10-01';

    PRINT N'✅ [5/5] Đã làm sạch 100% dữ liệu chấm công của NV 099 trong tblHasTA (AttStart = NULL, 0.0h), tblTmpAttend & CHECKINOUT';

    COMMIT TRANSACTION;
    PRINT N'=============================================================================';
    PRINT N'🎉 HOÀN TẤT LÀM SẠCH! BẢNG CÔNG NV 099 ĐÃ HOÀN TOÀN TRẮNG SẠCH!';
    PRINT N'👉 BƯỚC TIẾP THEO: Mở và chạy file scripts/seed_attendance_5days_nv099.sql để nạp 5 ngày công.';
    PRINT N'=============================================================================';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ CÓ LỖI XẢY RA TRONG QUÁ TRÌNH LÀM SẠCH: ' + ERROR_MESSAGE();
END CATCH;
GO

-- =============================================================================
-- BẢNG ĐỐI SOÁT KIỂM CHỨNG TỰ ĐỘNG SAU KHI LÀM SẠCH
-- =============================================================================
PRINT N'📊 BẢNG ĐỐI SOÁT TRẠNG THÁI SAU KHI LÀM SẠCH CỦA NV 099:';
SELECT 
    (SELECT COUNT(*) FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099') AS [Đơn bù công còn lại (Cần = 0)],
    (SELECT COUNT(*) FROM tblLeaveRegistered WHERE EmployeeID = '099') AS [Đơn nghỉ phép còn lại (Cần = 0)],
    (SELECT COUNT(*) FROM tblLvHistory WHERE EmployeeID = '099') AS [Lịch sử nghỉ còn lại (Cần = 0)],
    (SELECT COUNT(*) FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '099') AS [Đơn tăng ca còn lại (Cần = 0)],
    (SELECT ISNULL(Remain, 0) FROM tblEmployeeAnnual WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026) AS [Số phép năm còn lại (Cần >= 2)],
    (SELECT COUNT(*) FROM tblApprovalLineByEmployee WHERE EmployeeID = '099') AS [Số tuyến duyệt đã cấp (Cần > 0)],
    (SELECT COUNT(*) FROM tblHasTA WHERE EmployeeID = '099' AND AttStart IS NOT NULL) AS [Số ngày có giờ chấm công (CẦN = 0 - SẠCH HOÀN TOÀN)];
GO
