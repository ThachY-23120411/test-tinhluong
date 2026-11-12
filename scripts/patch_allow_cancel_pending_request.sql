-- =========================================================================================
-- FILE: scripts/patch_allow_cancel_pending_request.sql
-- MỤC ĐÍCH: BẢN VÁ CHO PHÉP NHÂN VIÊN XIN HỦY ĐƠN KHI ĐANG Ở TRẠNG THÁI CHỜ DUYỆT (Approve_Status = 1)
--           HOẶC ĐÃ DUYỆT (Approve_Status = 2) TRÊN MÀN HÌNH XIN BÙ CÔNG (sp_MakeupHours / MnuHRS033)
-- NGUYÊN NHÂN:
--   Thủ tục [sp_CheckCancelPermission] hiện tại đang bị cứng điều kiện:
--     WHERE ... AND Approve_Status = 2
--   khiến nhân viên vừa nộp nhầm đơn (ví dụ bù công ngày 14/10) khi đang Chờ duyệt (Approve_Status = 1)
--   bấm vào xem thẻ lịch sử thì nút "Xin hủy đơn" (.btnDestroy) bị ẩn (d-none).
-- GIẢI PHÁP:
--   Mở rộng điều kiện thành: Approve_Status IN (1, 2)
-- =========================================================================================
-- Hướng dẫn: Mở trên SQL Server Management Studio (SSMS) -> Bấm Ctrl+F5 kiểm tra cú pháp -> F5 thực thi
-- =========================================================================================

SET NOCOUNT ON;
PRINT N'=============================================================================';
PRINT N'🛠️ ĐANG CẬP NHẬT THỦ TỤC [sp_CheckCancelPermission] CHO PHÉP HỦY ĐƠN CHỜ DUYỆT...';
PRINT N'=============================================================================';
GO

ALTER PROCEDURE [dbo].[sp_CheckCancelPermission]
    @IdentityID VARCHAR(36),
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmployeeID NVARCHAR(50);

    -- Lấy EmployeeID từ LoginID
    SELECT @EmployeeID = EmployeeID
    FROM tblSC_Login
    WHERE LoginID = @LoginID;

    -- Cho phép kiểm tra quyền hủy đơn đối với cả đơn Chờ duyệt (1) và Đã duyệt (2)
    SELECT EmployeeID, IdentityID, Approve_Status
    FROM tblAttendanceConfirmRequest a
    WHERE IdentityID = @IdentityID 
      AND a.EmployeeID = @EmployeeID 
      AND Approve_Status IN (1, 2);
END
GO

PRINT N'✅ ĐÃ CẬP NHẬT THÀNH CÔNG! BÂY GIỜ NÚT [Xin hủy đơn] SẼ HIỂN THỊ KHI BẤM VÀO THẺ CHỜ DUYỆT!';
GO
