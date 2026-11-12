-- ==============================================================================
-- SCRIPT: RESET DỮ LIỆU ĐƠN NGHỈ PHÉP & KHÔI PHỤC NGÂN SÁCH PHÉP NĂM CHO NV 099
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MỤC ĐÍCH: 
--   1. Xóa sạch lịch sử nghỉ phép cũ (tblLeaveRegistered, tblLeaveRegistered_Detail, tblLvHistory)
--   2. Khôi phục số ngày phép năm còn lại (Remain = 2 ngày, Taken = 0) trong tblEmployeeAnnual
--   3. Khắc phục triệt để lỗi "Số ngày nghỉ vượt quá số phép năm còn lại !" khi nộp đơn MnuWPT315
-- ==============================================================================

PRINT N'🚀 ĐANG RESET DỮ LIỆU NGHỈ PHÉP CHO NHÂN VIÊN 099...';

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Xóa đơn đăng ký và chi tiết
    DELETE FROM tblLeaveRegistered_Detail 
    WHERE EmployeeID = '099' 
       OR IdentityID IN (SELECT IdentityID FROM tblLeaveRegistered WHERE EmployeeID = '099');

    DELETE FROM tblLeaveRegistered 
    WHERE EmployeeID = '099';
    PRINT N'✅ 1. Đã xóa đơn xin nghỉ phép trong tblLeaveRegistered & tblLeaveRegistered_Detail';

    -- 2. Xóa lịch sử ngày nghỉ thực tế trong tblLvHistory (tránh bị tính vào Taken)
    DELETE FROM tblLvHistory 
    WHERE EmployeeID = '099';
    PRINT N'✅ 2. Đã xóa lịch sử ngày nghỉ trong tblLvHistory';

    -- 3. Khởi tạo / cập nhật lại ngân sách phép năm trong tblEmployeeAnnual
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
    PRINT N'✅ 3. Đã khôi phục số ngày phép năm AL cho NV 099: Được cấp = 2 ngày, Đã nghỉ = 0, Còn lại = 2 ngày (tblEmployeeAnnual)';

    COMMIT TRANSACTION;
    PRINT N'🎉 HOÀN TẤT RESET NGÂN SÁCH PHÉP NĂM CHO NV 099!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ LỖI: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 4. Đối soát lại số ngày phép còn lại
SELECT EmployeeID, CYear, LeaveCode, ThisYear, Taken, Remain 
FROM tblEmployeeAnnual 
WHERE EmployeeID = '099';
GO
