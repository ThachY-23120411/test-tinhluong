
CREATE PROCEDURE [dbo].[sp_CheckApprovalPermission]
    @IdentityID VARCHAR(36),
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmployeeID NVARCHAR(50)
    DECLARE @RequestStatus INT

    -- Lấy EmployeeID từ LoginID
    SELECT @EmployeeID = EmployeeID
    FROM tblSC_Login
    WHERE LoginID = @LoginID

    SELECT h.ApproverID, h.Identity_ID, h.Approve_Status, r.Approve_Status as Approve_StatusRequest
	FROM tblApproverHistory h
	LEFT JOIN tblAttendanceConfirmRequest r ON r.IdentityID = h.Identity_ID
	WHERE @EmployeeID = h.ApproverID AND Identity_ID = @IdentityID
END
