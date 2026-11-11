-- =========================================================================================
-- FILE: scripts/clean_test_requests_fix5.sql
-- MỤC ĐÍCH: DỌN SẠCH DỮ LIỆU MẪU ĐƠN TỪ ESS CỦA NHÂN VIÊN TEST '099' (fix-5)
-- PHỤC VỤ CHẠY LẠI TEST FLOW TÍNH LƯƠNG NHIỀU LẦN ZERO-BUG
-- =========================================================================================
-- Hướng dẫn: Mở trên SQL Server Management Studio (SSMS) -> Bấm Ctrl+F5 kiểm tra cú pháp -> F5 để thực thi
-- =========================================================================================

SET NOCOUNT ON;
PRINT N'=============================================================================';
PRINT N'BẮT ĐẦU DỌN DẸP DỮ LIỆU ĐƠN TỪ CỦA NHÂN VIÊN TEST (EmployeeID = ''099'')';
PRINT N'=============================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Xóa chi tiết và đơn Xin bù công (sp_MakeupHours)
    DELETE FROM tblAttendanceConfirmRequest_detail
    WHERE IdentityID IN (SELECT IdentityID FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099');
    
    DELETE FROM tblAttendanceConfirmRequest
    WHERE EmployeeID = '099';
    PRINT N'-> [1/4] Đã xóa dữ liệu đơn bù công trong tblAttendanceConfirmRequest & _detail';

    -- 2. Xóa chi tiết và đơn Xin nghỉ phép (sp_ResignationLeave)
    DELETE FROM tblLeaveRegistered_Detail
    WHERE EmployeeID = '099' 
       OR IdentityID IN (SELECT IdentityID FROM tblLeaveRegistered WHERE EmployeeID = '099');

    DELETE FROM tblLeaveRegistered
    WHERE EmployeeID = '099';

    -- Khôi phục và tái tính toán lại ngân sách phép AL cho nhân viên 099
    IF OBJECT_ID('dbo.HR_LeaveBudget_Initialization', 'P') IS NOT NULL
    BEGIN
        EXEC HR_LeaveBudget_Initialization @LoginID = 3, @CalendarYear = 2026, @LeaveCode = 'AL', @EmployeeID = '099', @CalcToDate = '2026-10-31';
    END
    PRINT N'-> [2/4] Đã xóa dữ liệu đơn nghỉ phép trong tblLeaveRegistered & _Detail và tái tạo ngân sách phép AL';

    -- 3. Xóa chi tiết và đơn Xin tăng ca OT (sp_Overtime_Assignment)
    DELETE FROM tblOvertime_Assignment_Detail
    WHERE EmployeeID = '099'
       OR Identity_ID IN (SELECT Identity_ID FROM tblOTListRegistered WHERE EmployeeID = '099');

    DELETE FROM tblApproverHistory
    WHERE Identity_ID IN (SELECT Identity_ID FROM tblOTListRegistered WHERE EmployeeID = '099');

    DELETE FROM tblOTListRegistered
    WHERE EmployeeID = '099';

    DELETE FROM tblOTList
    WHERE EmployeeID = '099';
    PRINT N'-> [3/4] Đã xóa dữ liệu đơn tăng ca trong tblOvertime_Assignment_Detail, tblOTListRegistered & tblApproverHistory';

    -- 4. Khôi phục trạng thái bảng chấm công tblHasTA ngày 15/10/2026 (nếu có bản ghi)
    UPDATE tblHasTA
    SET AttStart = NULL,
        RealWorkingTime = 0.0,
        WorkingTime = 0.0,
        Approve = 0
    WHERE EmployeeID = '099' AND CONVERT(varchar, AttDate, 23) = '2026-10-15';
    PRINT N'-> [4/4] Đã khôi phục trạng thái chấm công ngày 15/10/2026 trong tblHasTA';

    COMMIT TRANSACTION;
    PRINT N'=============================================================================';
    PRINT N'✅ HOÀN TẤT DỌN DẸP! CSDL ĐÃ SẴN SÀNG CHO PHIÊN TEST TIẾP THEO CỦA FIX-5!';
    PRINT N'=============================================================================';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ CÓ LỖI XẢY RA TRONG QUÁ TRÌNH DỌN DẸP: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Đối soát lại số lượng bản ghi sau khi dọn dẹp (Kết quả mong muốn: toàn bộ = 0)
SELECT 
    (SELECT COUNT(*) FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099') AS AttConfirm_Count,
    (SELECT COUNT(*) FROM tblLeaveRegistered WHERE EmployeeID = '099') AS Leave_Count,
    (SELECT COUNT(*) FROM tblLeaveRegistered_Detail WHERE EmployeeID = '099') AS LeaveDetail_Count,
    (SELECT COUNT(*) FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '099') AS OT_Detail_Count,
    (SELECT COUNT(*) FROM tblOTListRegistered WHERE EmployeeID = '099') AS OT_ListRegistered_Count,
    (SELECT COUNT(*) FROM tblOTList WHERE EmployeeID = '099') AS OT_List_Count;
GO
