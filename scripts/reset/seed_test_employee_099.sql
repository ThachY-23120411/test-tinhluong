-- ==============================================================================
-- SCRIPT: KHỞI TẠO TIỀN ĐỀ TOÀN DIỆN CHO NHÂN VIÊN 099 (NGUYỄN VĂN TEST)
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MỤC ĐÍCH: 
--   1. Cấp quyền Admin (isAdmin = 1, AdminRight = 1) cho cuong.vu, chien.nguyen, admin
--   2. Tạo hồ sơ gốc nhân sự NV 099 đầy đủ Họ Tên (tblEmployee)
--   3. Tạo trạng thái làm việc bình thường (tblEmployeeStatusHistory)
--   4. Đưa NV 099 vào cây nhân viên hiển thị (tmpEmployeeTree)
--   5. Phân bổ phòng ban & chức vụ Thử việc IT (tblDivDepSecPos)
--   6. Tạo tài khoản ESS Portal test.nv / 123 (tblSC_Login & tblSC_Right_Stored)
--   7. Thiết lập Mức lương cơ bản 10,000,000 VNĐ (tblSalaryHistory)
--   8. Thiết lập HĐLĐ Thử việc (tblLabourContract)
-- BẮT BUỘC CHẠY FILE NÀY TRÊN SSMS SAU MỖI LẦN CHẠY SCRIPT RESET_TEST_EMPLOYEE_099.SQL!
-- ==============================================================================

PRINT N'🚀 ĐANG KHỞI TẠO TIỀN ĐỀ TOÀN DIỆN CHO NHÂN VIÊN 099...';

-- 1. BẢO ĐẢM QUYỀN ADMIN CHO CÁC TÀI KHOẢN QUẢN TRỊ (cuong.vu, chien.nguyen, admin)
-- Tránh việc sp_SalaryHistory_List_Grid bị chặn cứng bởi điều kiện isAdmin = 1
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
-- Để fn_vtblEmployeeList_Bydate và fn_EmployeeStatus_ByDate nhận diện NV 099 đang hoạt động
IF NOT EXISTS (SELECT 1 FROM tblEmployeeStatusHistory WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblEmployeeStatusHistory (EmployeeID, EmployeeStatusID, ChangedDate, StatusEndDate, Remark)
    VALUES ('099', 0, '2026-10-01', '9999-12-31', N'Làm việc bình thường');
    PRINT N'✅ 2b. Đã tạo trạng thái làm việc bình thường cho NV 099 (tblEmployeeStatusHistory)';
END
ELSE
BEGIN
    UPDATE tblEmployeeStatusHistory 
    SET EmployeeStatusID = 0, ChangedDate = '2026-10-01', StatusEndDate = '9999-12-31'
    WHERE EmployeeID = '099';
    PRINT N'✅ 2b. Đã chuẩn hóa trạng thái làm việc cho NV 099 (tblEmployeeStatusHistory)';
END

-- 2c. Đưa NV 099 vào cây nhân sự tmpEmployeeTree của cuong.vu, chien.nguyen, admin
-- Đảm bảo popup Chọn nhân viên và lưới hiển thị ngay NV 099
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

-- 7. Khởi tạo Mức lương 10,000,000 VNĐ (tblSalaryHistory)
IF NOT EXISTS (SELECT 1 FROM tblSalaryHistory WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblSalaryHistory (
        EmployeeID, [Date], Salary, InsSalary, NETSalary, SalCalRuleID, CurrencyCode, PositionID, BaseSalRegionalID, IsNet
    )
    VALUES (
        '099', '2026-10-01', 10000000, 10000000, 10000000, 1, 'VND', 450, 1, 0
    );
    PRINT N'✅ 7. Đã tạo mức lương 10,000,000 VNĐ cho NV 099 (tblSalaryHistory)';
END
ELSE
BEGIN
    UPDATE tblSalaryHistory
    SET Salary = 10000000, InsSalary = 10000000, NETSalary = 10000000, [Date] = '2026-10-01', CurrencyCode = 'VND'
    WHERE EmployeeID = '099';
    PRINT N'✅ 7. Đã chuẩn hóa mức lương 10,000,000 VNĐ cho NV 099 (tblSalaryHistory)';
END

-- 8. Khởi tạo Hợp đồng lao động (tblLabourContract)
IF NOT EXISTS (SELECT 1 FROM tblLabourContract WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblLabourContract (
        EmployeeID, ContractNo, ContractCode, ContractStartDay, ContractEndDay, Duration, CommitmentKind, InsuranceStatusID, PITStatus
    )
    VALUES (
        '099', '099/HDLD/26/01', '004', '2026-10-01', '2027-09-30', 12, 'HDLD', -1, 1
    );
    PRINT N'✅ 8. Đã tạo HĐLĐ cho NV 099 (tblLabourContract)';
END
ELSE
BEGIN
    UPDATE tblLabourContract
    SET ContractNo = '099/HDLD/26/01', ContractStartDay = '2026-10-01', ContractEndDay = '2027-09-30'
    WHERE EmployeeID = '099';
    PRINT N'✅ 8. Đã chuẩn hóa HĐLĐ cho NV 099 (tblLabourContract)';
END

PRINT N'-------------------------------------------------------------------------';
PRINT N'🎉 HOÀN TẤT SEED DỮ LIỆU! NHÂN VIÊN 099, CÂY NHÂN SỰ, TÀI KHOẢN test.nv & MỨC LƯƠNG 10TR ĐÃ SẴN SÀNG!';

-- 9. Kiểm tra đối soát nhanh
SELECT 
    e.EmployeeID, 
    e.FullName, 
    e.LastName,
    e.FirstName,
    l.LoginID, 
    l.LoginName, 
    s.Salary,
    c.ContractNo,
    stat.EmployeeStatusID,
    (SELECT COUNT(*) FROM tmpEmployeeTree tr WHERE tr.EmployeeID = '099') AS TreeCount
FROM tblEmployee e
LEFT JOIN tblSC_Login l ON e.EmployeeID = l.EmployeeID
LEFT JOIN tblSalaryHistory s ON e.EmployeeID = s.EmployeeID
LEFT JOIN tblLabourContract c ON e.EmployeeID = c.EmployeeID
LEFT JOIN tblEmployeeStatusHistory stat ON e.EmployeeID = stat.EmployeeID
WHERE e.EmployeeID = '099';
GO
