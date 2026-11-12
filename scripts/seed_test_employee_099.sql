-- ==============================================================================
-- SCRIPT: KHỞI TẠO TIỀN ĐỀ HỒ SƠ & TÀI KHOẢN CHO NHÂN VIÊN 099 (NGUYỄN VĂN TEST)
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MỤC ĐÍCH: 
--   1. Bảo đảm an toàn tài khoản quản trị (cuong.vu, chien.nguyen, admin)
--   2. Tạo hồ sơ gốc nhân sự NV 099 (tblEmployee)
--   3. Tạo trạng thái làm việc bình thường (tblEmployeeStatusHistory)
--   4. Đưa NV 099 vào cây nhân sự (tmpEmployeeTree)
--   5. Phân bổ phòng ban & chức vụ Thử việc IT (tblDivDepSecPos)
--   6. Tạo tài khoản ESS Portal test.nv / 123 (tblSC_Login & tblSC_Right_Stored)
-- CHÚ Ý: KHÔNG INSERT LƯƠNG & HĐLĐ (Vì bước này do TC-03 thực hiện trên giao diện UI)
-- ==============================================================================

PRINT N'🚀 ĐANG KHỞI TẠO TIỀN ĐỀ HỒ SƠ & TÀI KHOẢN CHO NHÂN VIÊN 099...';

-- 1. BẢO ĐẢM QUYỀN ADMIN CHO CÁC TÀI KHOẢN QUẢN TRỊ (cuong.vu, chien.nguyen, admin)
UPDATE tblSC_Login 
SET LoginName = 'cuong.vu', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1 
WHERE EmployeeID = '014' OR LoginName = 'cuong.vu';

UPDATE tblSC_Login 
SET LoginName = 'chien.nguyen', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1 
WHERE EmployeeID = '013' OR LoginName = 'chien.nguyen';

UPDATE tblSC_Login 
SET isAdmin = 1, AdminRight = 1 
WHERE LoginID = 1 OR LoginName = 'admin';
PRINT N'🛡️ 1. Đã bảo đảm an toàn và quyền Admin cho cuong.vu, chien.nguyen, admin (tblSC_Login)';

-- 2. Khởi tạo Hồ sơ nhân viên 099 (tblEmployee) - ĐẦY ĐỦ FullName, LastName, FirstName
IF NOT EXISTS (SELECT 1 FROM tblEmployee WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblEmployee (EmployeeID, FullName, LastName, FirstName, HireDate, Birthday, Sex, ID_Number)
    VALUES ('099', N'Nguyễn Văn Test', N'Nguyễn Văn', N'Test', '2026-10-01', '1995-05-15', 1, '079099888999');
    PRINT N'✅ 2. Đã tạo mới hồ sơ nhân viên 099 (Nguyễn Văn Test)';
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
    PRINT N'✅ 2. Đã chuẩn hóa hồ sơ nhân viên 099 (Nguyễn Văn Test)';
END

-- 2b. Khởi tạo Trạng thái làm việc bình thường cho NV 099 (tblEmployeeStatusHistory)
-- LƯU Ý: StatusEndDate phải để NULL (chuẩn hệ thống), TUYỆT ĐỐI không gán '9999-12-31' vì fn_EmployeeStatusRange có dateadd(day, 1, StatusEndDate) sẽ gây tràn datetime và làm sập LoadEmployeeTree!
IF NOT EXISTS (SELECT 1 FROM tblEmployeeStatusHistory WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblEmployeeStatusHistory (EmployeeID, EmployeeStatusID, ChangedDate, StatusEndDate, Remark)
    VALUES ('099', 0, '2026-10-01', NULL, N'Làm việc bình thường');
    PRINT N'✅ 2b. Đã tạo trạng thái làm việc bình thường cho NV 099 (tblEmployeeStatusHistory)';
END
ELSE
BEGIN
    UPDATE tblEmployeeStatusHistory 
    SET EmployeeStatusID = 0, ChangedDate = '2026-10-01', StatusEndDate = NULL
    WHERE EmployeeID = '099';
    PRINT N'✅ 2b. Đã chuẩn hóa trạng thái làm việc cho NV 099 (tblEmployeeStatusHistory)';
END

-- 2c. Đưa NV 099 vào cây nhân sự tmpEmployeeTree của cuong.vu, chien.nguyen, admin
DELETE FROM tmpEmployeeTree WHERE EmployeeID = '099';
INSERT INTO tmpEmployeeTree (EmployeeID, LoginID)
SELECT '099', LoginID 
FROM tblSC_Login 
WHERE LoginName IN ('cuong.vu', 'chien.nguyen', 'admin') OR LoginID IN (1, 22, 23);
PRINT N'✅ 2c. Đã đưa NV 099 vào cây nhân sự của cuong.vu, chien.nguyen, admin (tmpEmployeeTree)';

-- 3. Phân bổ phòng ban & chức vụ (tblDivDepSecPos)
IF NOT EXISTS (SELECT 1 FROM tblDivDepSecPos WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblDivDepSecPos (EmployeeID, DivisionID, DepartmentID, PositionID, ChangedDate)
    VALUES ('099', 1, 3, 450, '2026-10-01');
    PRINT N'✅ 3. Đã phân bổ phòng ban & chức vụ Thử việc IT cho NV 099 (tblDivDepSecPos)';
END
ELSE
BEGIN
    UPDATE tblDivDepSecPos
    SET DivisionID = 1, DepartmentID = 3, PositionID = 450, ChangedDate = '2026-10-01'
    WHERE EmployeeID = '099';
    PRINT N'✅ 3. Đã chuẩn hóa phòng ban & chức vụ cho NV 099 (tblDivDepSecPos)';
END

-- 4. Dọn dẹp tài khoản test.nv cũ nếu có để tránh trùng khóa Unique
DELETE FROM tblSC_Right_Stored 
WHERE LoginID IN (SELECT LoginID FROM tblSC_Login WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014'));

DELETE FROM tblSC_Login 
WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014');

-- 5. Khởi tạo tài khoản ESS Portal test.nv / 123 (tblSC_Login)
INSERT INTO tblSC_Login (
    LoginName,
    PassWord,
    EmployeeID,
    ParentLoginID,
    UseGroupRightOnly,
    NeedEncryptPassWordColumnList,
    IsDisable,
    IsGroup
)
VALUES (
    'test.nv',
    '123',
    '099',
    '9',            -- Nhóm Users / ESS Portal
    1,              -- Sử dụng quyền nhóm
    'PassWord',     -- Cơ chế hỗ trợ mật khẩu '123'
    0,              -- Hoạt động (không bị khóa)
    0               -- Người dùng cá nhân
);
PRINT N'✅ 5. Đã tạo mới tài khoản ESS Portal test.nv / 123 (tblSC_Login)';

-- 6. Phân quyền menu cơ bản (Làm mới giao diện ESS)
INSERT INTO tblSC_Right_Stored (ObjectID, LoginID, FullAccess)
SELECT 70, LoginID, 32 
FROM tblSC_Login 
WHERE LoginName = 'test.nv';
PRINT N'✅ 6. Đã cấp quyền menu ESS Portal cho test.nv (tblSC_Right_Stored)';

-- 6b. Thiết lập tuyến người duyệt (tblApprovalLineByEmployee) cho NV 099
DELETE FROM tblApprovalLineByEmployee WHERE EmployeeID = '099';
INSERT INTO tblApprovalLineByEmployee (
    EmployeeID, Approvalgrouplist, Approver_1, Delegacy_1, Approver_2, Delegacy_2, Approver_3, Delegacy_3, Approver_4, Delegacy_4, IsDelegacyView
)
SELECT '099', Approvalgrouplist, Approver_1, Delegacy_1, Approver_2, Delegacy_2, Approver_3, Delegacy_3, Approver_4, Delegacy_4, IsDelegacyView
FROM tblApprovalLineByEmployee
WHERE EmployeeID = '001';

IF NOT EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 6)
BEGIN
    INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Approver_2)
    VALUES 
        ('099', 6, '012', '014'),
        ('099', 1, '004', '014'),
        ('099', 5, '004', '014');
END
PRINT N'✅ 6b. Đã thiết lập tuyến duyệt đơn (Bù công, Nghỉ phép, Tăng ca) cho NV 099 (tblApprovalLineByEmployee)';

-- 6c. Khởi tạo ngân sách phép năm (tblEmployeeAnnual) cho NV 099 (đảm bảo đủ ngày phép Remain để nộp đơn)
DELETE FROM tblLvHistory WHERE EmployeeID = '099';
DELETE FROM tblLeaveRegistered_Detail WHERE EmployeeID = '099';
DELETE FROM tblLeaveRegistered WHERE EmployeeID = '099';

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
PRINT N'✅ 6c. Đã khởi tạo ngân sách phép năm AL = 2 ngày cho NV 099 (tblEmployeeAnnual)';

PRINT N'-------------------------------------------------------------------------';
PRINT N'🎉 HOÀN TẤT! HỒ SƠ NV 099 & TÀI KHOẢN test.nv ĐÃ SẴN SÀNG ĐỂ CHẠY LUỒNG TEST UI!';

-- 7. Kiểm tra đối soát nhanh
SELECT 
    e.EmployeeID, 
    e.FullName, 
    e.LastName,
    e.FirstName,
    e.HireDate,
    l.LoginID, 
    l.LoginName, 
    stat.EmployeeStatusID,
    (SELECT COUNT(*) FROM tmpEmployeeTree tr WHERE tr.EmployeeID = '099') AS TreeCount
FROM tblEmployee e
LEFT JOIN tblSC_Login l ON e.EmployeeID = l.EmployeeID
LEFT JOIN tblEmployeeStatusHistory stat ON e.EmployeeID = stat.EmployeeID
WHERE e.EmployeeID = '099';
GO
