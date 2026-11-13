-- =============================================================================
-- SCRIPT RESET TRẠNG THÁI CHỜ PHÊ DUYỆT CỦA NV 099 CHO FIX-6 (DỰA TRÊN RECORDING 11/12/2026)
-- Mục đích: Đưa toàn bộ 5 đơn của NV 099 (Tăng ca 20/10, Nghỉ phép 22/10, Bù công 15/10 & 16/10,
--           Xin hủy bù công 14/10) về nguyên trạng thái chờ phê duyệt Cấp 1 (trước khi chạy fix-6).
-- Hướng dẫn: Mở trên SSMS, kiểm tra cú pháp (Ctrl + F5) rồi Execute (F5) trước mỗi lần chạy lại fix-6.
-- =============================================================================

USE Vietinsoft_ForTest_Tai2;
GO

-- 1. Đảm bảo luồng phê duyệt cho NV 099 đúng theo Recording 11/12/2026:
--    - Group 1 (Nghỉ phép) & Group 5 (Bù công): Cấp 1 = 004 (tri.nguyen), Cấp 2 = 012 (LongKa)
--    - Group 6 (Tăng ca OT): Cấp 1 = 012 (LongKa), Cấp 2 = 014 (cuong.vu)
IF NOT EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 1)
    INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Delegacy_1, Approver_2)
    VALUES ('099', 1, '004', '003', '012');
ELSE
    UPDATE tblApprovalLineByEmployee SET Approver_1 = '004', Delegacy_1 = '003', Approver_2 = '012'
    WHERE EmployeeID = '099' AND Approvalgrouplist = 1;

IF NOT EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 5)
    INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Delegacy_1, Approver_2)
    VALUES ('099', 5, '004', '003', '012');
ELSE
    UPDATE tblApprovalLineByEmployee SET Approver_1 = '004', Delegacy_1 = '003', Approver_2 = '012'
    WHERE EmployeeID = '099' AND Approvalgrouplist = 5;

IF NOT EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 6)
    INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Delegacy_1, Approver_2)
    VALUES ('099', 6, '012', NULL, '014');
ELSE
    UPDATE tblApprovalLineByEmployee SET Approver_1 = '012', Delegacy_1 = NULL, Approver_2 = '014'
    WHERE EmployeeID = '099' AND Approvalgrouplist = 6;
GO

-- 2. Reset đơn Xin bù công & Xin hủy bù công (14/10 -> Approve_Status = 5; 15/10 & 16/10 -> Approve_Status = 1)
UPDATE tblAttendanceConfirmRequest
SET Approve_Status = CASE
        WHEN CAST(AttDate AS DATE) = '2026-10-14' THEN 5
        ELSE 1
    END,
    Current_Approve_Level = 1,
    ApproverID = NULL,
    ApproverRemark = NULL,
    RejectedBy = NULL,
    Approver_1 = NULL,
    Approver_2 = NULL,
    Approver_3 = NULL,
    Approver_4 = NULL,
    Delegacy_1 = NULL,
    Delegacy_2 = NULL,
    Delegacy_3 = NULL,
    Delegacy_4 = NULL,
    IsDelegacyView = NULL
WHERE EmployeeID = '099'
  AND CAST(AttDate AS DATE) IN ('2026-10-14', '2026-10-15', '2026-10-16');

-- Xóa dữ liệu chấm công tạm do duyệt bù công Cấp 2 sinh ra (nếu đã từng chạy qua fix-6)
DELETE FROM tblTmpAttend
WHERE EmployeeID = '099'
  AND IdentityID IN (
      SELECT IdentityID FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099'
  );

-- 3. Reset đơn Nghỉ phép (22/10)
UPDATE tblLeaveRegistered
SET Approve_Status = 1,
    Current_Approve_Level = NULL,
    isApprove = 0,
    isReject = 0,
    ApproveTime = NULL,
    RejectTime = NULL,
    ApproverRemark = NULL,
    ApproverRemark2 = NULL,
    Approver_1 = NULL,
    Approver_2 = NULL,
    Approver_3 = NULL,
    Approver_4 = NULL,
    Delegacy_1 = NULL,
    Delegacy_2 = NULL,
    Delegacy_3 = NULL,
    Delegacy_4 = NULL,
    TTime_1 = NULL,
    TTime_2 = NULL,
    TTime_3 = NULL,
    TTime_4 = NULL,
    ApproverRemark_1 = NULL,
    ApproverRemark_2 = NULL,
    ApproverRemark_3 = NULL,
    ApproverRemark_4 = NULL,
    IsDelegacyView = NULL
WHERE EmployeeID = '099'
  AND CAST(LeaveFromDate AS DATE) >= '2026-10-01';

UPDATE tblLeaveRegistered_Detail
SET Approve_Status = 1,
    RejectedBy = NULL
WHERE EmployeeID = '099'
  AND IdentityID IN (
      SELECT IdentityID FROM tblLeaveRegistered WHERE EmployeeID = '099'
  );

DELETE FROM tblLvHistory
WHERE EmployeeID = '099'
  AND IdentityID IN (
      SELECT IdentityID FROM tblLeaveRegistered WHERE EmployeeID = '099'
  );

-- 4. Reset đơn Tăng ca OT (20/10)
UPDATE tblOvertime_Assignment_Detail
SET Approved_Status = 1,
    RejectedBy = NULL,
    ApproverNote = NULL,
    NotApprove = NULL
WHERE EmployeeID = '099'
  AND CAST(OTDate AS DATE) >= '2026-10-01';

IF OBJECT_ID('dbo.tblOTListRegistered', 'U') IS NOT NULL
BEGIN
    UPDATE tblOTListRegistered
    SET Approve_Status = 1
    WHERE Identity_ID IN (
        SELECT Identity_ID FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '099'
    );
END

DELETE FROM tblOTList
WHERE EmployeeID = '099'
  AND Identity_ID IN (
      SELECT Identity_ID FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '099'
  );

-- 5. Reset lịch sử phê duyệt (Level 1 = 1 Chờ duyệt; Level >= 2 = 0 Chưa tới lượt)
UPDATE tblApproverHistory
SET Approve_Status = CASE WHEN [Level] = 1 THEN 1 ELSE 0 END,
    Approval_Time = NULL,
    Remark = NULL,
    Old_Approval_Time = NULL,
    Old_Remark = NULL
WHERE Identity_ID IN (
    SELECT CAST(IdentityID AS VARCHAR(50)) FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099'
    UNION
    SELECT CAST(IdentityID AS VARCHAR(50)) FROM tblLeaveRegistered WHERE EmployeeID = '099'
    UNION
    SELECT CAST(Identity_ID AS VARCHAR(50)) FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '099'
);

-- Dọn hàng đợi email phát sinh trong lần duyệt trước (nếu có)
DELETE FROM tblEmailList
WHERE Identity_Id IN (
    SELECT CAST(IdentityID AS VARCHAR(50)) FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099'
    UNION
    SELECT CAST(IdentityID AS VARCHAR(50)) FROM tblLeaveRegistered WHERE EmployeeID = '099'
    UNION
    SELECT CAST(Identity_ID AS VARCHAR(50)) FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '099'
);
GO

PRINT N'Đã reset trạng thái chờ duyệt fix-6 cho NV 099 thành công!';
GO
