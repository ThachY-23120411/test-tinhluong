CREATE PROCEDURE [dbo].[sp_ApproveAttendanceRequest]
    @IdentityID VARCHAR(36),
    @LoginID INT,
    @Remark NVARCHAR(500) = ''
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @EmployeeID VARCHAR(20);
	DECLARE @CurrentLevel INT;
	DECLARE @MaxLevel INT;
	DECLARE @AttDate DATETIME;
	DECLARE @Approver VARCHAR(20);
	DECLARE @Approver_Level INT;
	DECLARE @Status INT;


	--Lấy trạng thái (đã duyệt, từ chối) của đơn
	SELECT @Status = Approve_Status
	FROM tblAttendanceConfirmRequest
	WHERE IdentityID = @IdentityID;

	-- Lấy EmployeeID của người duyệt từ LoginID
    SELECT @Approver = EmployeeID
    FROM tblSC_Login
    WHERE LoginID = @LoginID

	-- Lấy level của người duyệt hiện tại
	SELECT @Approver_Level = Level
	FROM tblApproverHistory
	WHERE ApproverID = @Approver AND Identity_ID = @IdentityID

	-- Lấy cấp duyệt cao nhất hiện có của đơn
	SELECT @MaxLevel = MAX(Level)
	FROM tblApproverHistory
	WHERE Identity_ID = @IdentityID;

	-- Lấy EmployeeID
    SELECT @EmployeeID = EmployeeID, @AttDate = AttDate
    FROM tblAttendanceConfirmRequest
    WHERE IdentityID = @IdentityID

	-- Lấy cấp duyệt hiện tại của đơn
	SELECT @CurrentLevel = Level
	FROM tblApproverHistory
	WHERE Identity_ID = @IdentityID AND Approve_Status = 1

	-- Cập nhật trạng thái phê duyệt tại cấp hiện tại
	UPDATE tblApproverHistory
	SET Approve_Status = 2,
		Remark = @Remark,
		Approval_Time = GETDATE()
	WHERE Identity_ID = @IdentityID
	  AND Level = @CurrentLevel
	  AND @Approver = ApproverID
	  AND @Approver_Level = @CurrentLevel;
	
	-- Tăng cấp độ duyệt của đơn
	SET @CurrentLevel = @CurrentLevel + 1;

	UPDATE tblApproverHistory
	SET Approve_Status = 1
	WHERE Identity_ID = @IdentityID AND Level = @CurrentLevel;

	IF @Status = 1
		BEGIN
			-- Quy trình duyệt đơn xin bù công
			IF @CurrentLevel <= @MaxLevel
				BEGIN
					-- Gửi thông báo cho cấp duyệt tiếp theo
					INSERT INTO tblEmailList(TemplateName, SendStatus, Approved_Send, Identity_Id, SendToEmployeeID, EmailType,NotifycationSendID)	
					SELECT 'NotificationAttendanceApplication', 0, 1, @IdentityID, ApproverID, 10,1
					FROM tblApproverHistory
					WHERE Identity_ID = @IdentityID AND Level = @CurrentLevel;
				END

			IF @CurrentLevel > @MaxLevel
				BEGIN
					UPDATE tblAttendanceConfirmRequest
					SET Approve_Status = 2
					WHERE IdentityID = @IdentityID;

					-- Gửi thông báo hoàn thành cho người gửi đơn
					INSERT INTO tblEmailList(TemplateName, SendStatus, Approved_Send, Identity_Id, SendToEmployeeID, EmailType,NotifycationSendID)	
					VALUES ('NotificationAttendanceApplication', 0, 1, @IdentityID, @EmployeeID, 10,2);

					-- Bảng chấm công - Lấy dữ liệu từ bảng detail đã lưu
					INSERT INTO tblTmpAttend (IdentityID, EmployeeID, AttState, AttTime, MachineNo)
					SELECT
						b.IdentityID,
						b.EmployeeID,
						a.TypeCheckInCheckOut,
						CONVERT(VARCHAR(10), b.AttDate, 120) + ' ' + CONVERT(VARCHAR(8), a.Time, 108),
						0
					FROM tblAttendanceConfirmRequest_detail a
					INNER JOIN tblAttendanceConfirmRequest b ON a.IdentityID = b.IdentityID
					WHERE a.IdentityID = @IdentityID
				END


			-- Cập nhật task schedule để gửi email
			UPDATE Taskschedule
			SET LastTryDay = '20190101', NextRunDate = '20190101'
			WHERE FunctionName = 'SendPendingEmail';
		END
	ELSE IF @Status = 5
		BEGIN
			-- Quy trình duyệt đơn hủy
			IF @CurrentLevel <= @MaxLevel
				BEGIN
					-- Gửi thông báo cho cấp duyệt tiếp theo
					INSERT INTO tblEmailList(TemplateName, SendStatus, Approved_Send, Identity_Id, SendToEmployeeID, EmailType,NotifycationSendID)	
					SELECT 'NotificationAttendanceApplication', 0, 1, @IdentityID, ApproverID, 10,5
					FROM tblApproverHistory
					WHERE Identity_ID = @IdentityID AND Level = @CurrentLevel;
				END

			IF @CurrentLevel > @MaxLevel
			BEGIN
				UPDATE tblAttendanceConfirmRequest
				SET Approve_Status = 4
				WHERE IdentityID = @IdentityID;

				-- Xóa dữ liệu trong bảng chấm công
				DELETE tblTmpAttend WHERE IdentityID = @IdentityID

				-- Gửi thông báo cho người tạo đơn


				INSERT INTO tblEmailList(TemplateName,SendStatus,Approved_Send,Identity_Id,SendToEmployeeID,NotifycationSendID)
				SELECT 'NotificationAttendanceApplication',0,1,@IdentityID, EmployeeID,4 FROM tblAttendanceConfirmRequest WHERE IdentityId = @IdentityID
			END

			-- Cập nhật task schedule để gửi email
			UPDATE Taskschedule
			SET LastTryDay = '20190101', NextRunDate = '20190101'
			WHERE FunctionName = 'SendPendingEmail';
		END


    EXEC dbo.sp_SendSignalRCommand @LoginID, 'dashboardMobileBTasks_loadTasks';

    IF @CurrentLevel <= @MaxLevel
    BEGIN
        DECLARE @NextApproverLoginID INT;
        SELECT TOP 1 @NextApproverLoginID = l.LoginID 
        FROM tblApproverHistory h JOIN tblSC_Login l ON h.ApproverID = l.EmployeeID 
        WHERE h.Identity_ID = @IdentityID AND h.Level = @CurrentLevel;
        EXEC dbo.sp_SendSignalRCommand @NextApproverLoginID, 'dashboardMobileBTasks_loadTasks';
    END
    ELSE
    BEGIN
        DECLARE @CreatorLoginID INT;
        SELECT TOP 1 @CreatorLoginID = LoginID FROM tblSC_Login WHERE EmployeeID = @EmployeeID;
        EXEC dbo.sp_SendSignalRCommand @CreatorLoginID, 'loadQAData';
    END
END

GO
