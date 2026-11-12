-- =====================================================================================
-- SCRIPT: RESET & CHUẨN BỊ DỮ LIỆU ĐẦU VÀO HOÀN CHỈNH CHO PHÂN VÙNG FIX-8 (10/2026)
-- MÔI TRƯỜNG: Vietinsoft_ForTest_Tai2 (SQL Server Management Studio - SSMS)
-- ĐỐI TƯỢNG TEST: Nhân viên 099 (Nguyễn Văn Test) - Kỳ lương Tháng 10/2026
-- HƯỚNG DẪN SỬ DỤNG:
--   1. Mở file này trong SSMS trên database Vietinsoft_ForTest_Tai2
--   2. Nhấn Ctrl + F5 để kiểm tra cú pháp (0 errors)
--   3. Nhấn F5 để thực thi -> Vào ngay Bước 1 trong kb_fix8.md (TC-18 -> TC-20)
-- =====================================================================================

SET NOCOUNT ON;

PRINT N'=========================================================================';
PRINT N'🚀 BẮT ĐẦU RESET & DỰNG SẴN DỮ LIỆU CHUẨN CHO FIX-8 (NV 099 - 10/2026)...';
PRINT N'=========================================================================';

-- -------------------------------------------------------------------------------------
-- 1. ĐẢM BẢO TÀI KHOẢN ĐĂNG NHẬP & QUYỀN ADMIN (cuong.vu, chien.nguyen, admin, test.nv)
-- -------------------------------------------------------------------------------------
UPDATE tblSC_Login
SET LoginName = 'cuong.vu', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1
WHERE EmployeeID = '014' OR LoginName = 'cuong.vu';

UPDATE tblSC_Login
SET LoginName = 'chien.nguyen', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1
WHERE EmployeeID = '013' OR LoginName = 'chien.nguyen';

UPDATE tblSC_Login
SET isAdmin = 1, AdminRight = 1
WHERE LoginID = 1 OR LoginName = 'admin';

IF NOT EXISTS (SELECT 1 FROM tblEmployee WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblEmployee (EmployeeID, FullName, LastName, FirstName, HireDate, Birthday, Sex, ID_Number)
    VALUES ('099', N'Nguyễn Văn Test', N'Nguyễn Văn', N'Test', '2026-10-01', '1995-05-15', 1, '079099888999');
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
END

IF NOT EXISTS (SELECT 1 FROM tblEmployeeStatusHistory WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblEmployeeStatusHistory (EmployeeID, EmployeeStatusID, ChangedDate, StatusEndDate, Remark)
    VALUES ('099', 0, '2026-10-01', NULL, N'Làm việc bình thường');
END
ELSE
BEGIN
    UPDATE tblEmployeeStatusHistory
    SET EmployeeStatusID = 0, ChangedDate = '2026-10-01', StatusEndDate = NULL
    WHERE EmployeeID = '099';
END

IF NOT EXISTS (SELECT 1 FROM tblDivDepSecPos WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblDivDepSecPos (EmployeeID, DivisionID, DepartmentID, PositionID, ChangedDate)
    VALUES ('099', 1, 3, 450, '2026-10-01');
END
ELSE
BEGIN
    UPDATE tblDivDepSecPos
    SET DivisionID = 1, DepartmentID = 3, PositionID = 450, ChangedDate = '2026-10-01'
    WHERE EmployeeID = '099';
END

DELETE FROM tmpEmployeeTree WHERE EmployeeID = '099';
INSERT INTO tmpEmployeeTree (EmployeeID, LoginID)
SELECT '099', LoginID
FROM tblSC_Login
WHERE LoginName IN ('cuong.vu', 'chien.nguyen', 'admin') OR LoginID IN (1, 22, 23);

IF EXISTS (SELECT 1 FROM tblSC_Login WHERE LoginName = 'test.nv' AND EmployeeID = '099')
BEGIN
    UPDATE tblSC_Login
    SET PassWord = '123',
        ParentLoginID = '9',
        UseGroupRightOnly = 1,
        NeedEncryptPassWordColumnList = 'PassWord',
        IsDisable = 0,
        IsGroup = 0
    WHERE LoginName = 'test.nv' AND EmployeeID = '099';
END
ELSE
BEGIN
    DELETE FROM tblSC_Right_Stored
    WHERE LoginID IN (SELECT LoginID FROM tblSC_Login WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014'));

    DELETE FROM tblSC_Login
    WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014');

    INSERT INTO tblSC_Login (
        LoginName, PassWord, EmployeeID, ParentLoginID,
        UseGroupRightOnly, NeedEncryptPassWordColumnList, IsDisable, IsGroup
    )
    VALUES ('test.nv', '123', '099', '9', 1, 'PassWord', 0, 0);

    INSERT INTO tblSC_Right_Stored (ObjectID, LoginID, FullAccess)
    SELECT 70, LoginID, 32
    FROM tblSC_Login
    WHERE LoginName = 'test.nv' AND EmployeeID = '099';
END
PRINT N'✅ 1. Đã chuẩn hóa tài khoản & hồ sơ NV 099 (cuong.vu, chien.nguyen, test.nv)';

-- -------------------------------------------------------------------------------------
-- 2. THIẾT LẬP LOẠI NHÂN VIÊN, HỢP ĐỒNG LAO ĐỘNG & LỊCH SỬ LƯƠNG CHUẨN (10,000,000 VNĐ)
-- -------------------------------------------------------------------------------------
-- Lưu ý: EmployeeTypeID = 1 (Nghỉ T7 & CN -> Công chuẩn 10/2026 = 21 ngày)
--        SalCalRuleID = 1 (Std_WD) để SALCAL_MAIN tính đúng ActualMonthlyBasic
DELETE FROM tblEmployeeTypeHistory WHERE EmployeeID = '099';
INSERT INTO tblEmployeeTypeHistory (EmployeeID, EmployeeTypeID, EffectiveDate, Remark)
VALUES ('099', 1, '2026-10-01', N'Nhân viên văn phòng chuẩn (fix-8)');

DELETE FROM tblSalaryHistory WHERE EmployeeID = '099';
INSERT INTO tblSalaryHistory (
    EmployeeID, [Date], Salary, InsSalary, SalCalRuleID,
    CurrencyCode, PositionID, BaseSalRegionalID, IsNet,
    WorkingHoursPerDay, Trans_AL, Pos_AL, Per_Rate, Note
)
VALUES (
    '099', '2026-10-01', 10000000, 10000000, 1,
    'VND', 450, 1, 0,
    8.0, 0, 0, 0, N'Lương cơ bản 10,000,000 VNĐ (SalCalRuleID = 1)'
);

IF NOT EXISTS (SELECT 1 FROM tblLabourContract WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblLabourContract (
        EmployeeID, ContractNo, ContractCode, ContractStartDay,
        IsProbation, InsuranceStatusID, PITStatus, Note
    )
    VALUES ('099', '099/HDLD/26/10', '003', '2026-10-01', 0, -1, 1, N'HĐLĐ chuẩn fix-8');
END
PRINT N'✅ 2. Đã thiết lập EmployeeTypeID = 1, SalaryHistory = 10,000,000 (SalCalRuleID = 1)';

-- -------------------------------------------------------------------------------------
-- 3. ĐỒNG BỘ DỮ LIỆU CÔNG, PHÉP NĂM & TĂNG CA CHUẨN TỪ FIX-5 + FIX-6 (5.625 CÔNG, 2H OT)
-- -------------------------------------------------------------------------------------
-- 3a. Xóa sạch dữ liệu công tháng 10/2026 trở đi của NV 099 và nạp đúng 5 ngày công mẫu:
--     12/10 (8h) + 13/10 (8h) + 14/10 (6h) + 15/10 (8h sau duyệt bù) + 16/10 (7h) = 37h (4.625 ngày)
DELETE FROM tblHasTA WHERE EmployeeID = '099' AND AttDate >= '2026-10-01';

INSERT INTO tblHasTA (EmployeeID, AttDate, Period, AttStart, AttEnd, Approve, WorkingTime, RealWorkingTime)
VALUES
    ('099', '2026-10-12', 0, '2026-10-12 08:00:00', '2026-10-12 17:00:00', 1, 8, 8),
    ('099', '2026-10-13', 0, '2026-10-13 08:00:00', '2026-10-13 17:00:00', 1, 8, 8),
    ('099', '2026-10-14', 0, '2026-10-14 08:00:00', '2026-10-14 15:00:00', 1, 6, 6),
    ('099', '2026-10-15', 0, '2026-10-15 08:00:00', '2026-10-15 17:00:00', 1, 8, 8),
    ('099', '2026-10-16', 0, '2026-10-16 08:00:00', '2026-10-16 16:00:00', 1, 7, 7);

-- 3b. Phép năm có lương AL ngày 24/10/2026 (1.0 ngày = 8h -> Tổng công hưởng lương = 5.625 ngày)
DELETE FROM tblLvHistory WHERE EmployeeID = '099';
DELETE FROM tblLeaveRegistered_Detail WHERE EmployeeID = '099';
DELETE FROM tblLeaveRegistered WHERE EmployeeID = '099';

INSERT INTO tblLvHistory (
    EmployeeID, LeaveDate, LeaveStatus, LeaveCode, LvAmount,
    Reason, NotAllowDiligence, IdentityID
)
VALUES (
    '099', '2026-10-24', 3, 'AL', 8,
    N'Giải quyết việc gia đình cá nhân', 0, NEWID()
);

IF EXISTS (SELECT 1 FROM tblEmployeeAnnual WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026)
BEGIN
    UPDATE tblEmployeeAnnual
    SET ThisYear = 2, Taken = 1, Remain = 1, ALThisYear = 2, ALPaidDays = 0
    WHERE EmployeeID = '099' AND LeaveCode = 'AL' AND CYear = 2026;
END
ELSE
BEGIN
    INSERT INTO tblEmployeeAnnual (EmployeeID, CYear, LeaveCode, ThisYear, Taken, Remain, ALThisYear, FirstALMonth)
    VALUES ('099', 2026, 'AL', 2, 1, 1, 2, 10);
END

-- 3c. Tăng ca OT ngày 20/10/2026 (18:00 - 20:00, 2.0h, OTKind = 11 hệ số 150%, Đã duyệt = 1)
DELETE FROM tblOTList WHERE EmployeeID = '099';
INSERT INTO tblOTList (
    EmployeeID, OTCategoryID, OTDate, OTKind, ShiftID,
    OTFrom, OTTo, OTHour, Approved, ApprovedHours,
    StatusID, Month, Year, Notes, Period, Identity_ID
)
VALUES (
    '099', 2, '2026-10-20', 11, 3,
    '18:00:00', '20:00:00', 2.0, 1, 2.0,
    1, 10, 2026, N'Tăng ca xử lý sự cố (fix-6)', 0, NEWID()
);
PRINT N'✅ 3. Đã dựng chuẩn công (37h = 4.625d), phép AL 24/10 (1.0d) & OT 20/10 (2.0h)';

-- -------------------------------------------------------------------------------------
-- 4. ĐỒNG BỘ DỮ LIỆU TÀI CHÍNH TỪ FIX-7 (THƯỞNG KPI 1,000,000 + TẠM ỨNG ĐÃ KHÓA 2,000,000)
-- -------------------------------------------------------------------------------------
-- 4a. Thưởng KPI 1,000,000 VNĐ (IncomeID = 1 - Tiền thưởng)
DELETE FROM tblPR_Adjustment
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

INSERT INTO tblPR_Adjustment (
    EmployeeID, Month, Year, IncomeID, ByAmount,
    OriginalAmount, Amount, Remark, CurrencyCode, IdentityID
)
VALUES (
    '099', 10, 2026, 1, 1,
    1000000, 1000000, N'Thưởng KPI hoàn thành tốt nhiệm vụ', 'VND', NEWID()
);

-- 4b. Tạm ứng lương đã khóa 2,000,000 VNĐ (IsLock = 1)
DELETE FROM tblSal_Advance
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

INSERT INTO tblSal_Advance (
    Month, Year, EmployeeID, BasicSalary, AttDays, OT150H,
    CashAmt, BankAmt, AdvanceAmount, Notes, IsApproved, IsLock, Cash
)
VALUES (
    10, 2026, '099', 10000000, 5.625, 2.0,
    2000000, 0, 2000000, N'Tạm ứng lương tháng 10/2026 (fix-7)', 1, 1, 0
);
PRINT N'✅ 4. Đã dựng chuẩn Thưởng KPI 1,000,000 VNĐ & Tạm ứng đã khóa 2,000,000 VNĐ';

-- -------------------------------------------------------------------------------------
-- 5. XÓA BẢNG LƯƠNG CŨ, CHẠY LẠI SALCAL_MAIN & KHÓA SỔ KỲ 10/2026 CHO NV 099
-- -------------------------------------------------------------------------------------
DELETE FROM tblSal_Lock               WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_Sal_Detail         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_Sal                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_OT_Detail          WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_PaidLeave_Detail   WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_Adjustment         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_Insurance          WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_Tax                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

DECLARE @AdminLoginID INT;
SELECT TOP 1 @AdminLoginID = LoginID
FROM tblSC_Login
WHERE LoginName = 'chien.nguyen'
ORDER BY LoginID;

IF @AdminLoginID IS NULL
    SET @AdminLoginID = 1;

EXEC dbo.SALCAL_MAIN
    @Month = 10,
    @Year = 2026,
    @LoginID = @AdminLoginID,
    @PeriodID = 0,
    @EmployeeID = N'099',
    @CalculateRetro = 0;

IF NOT EXISTS (SELECT 1 FROM tblSal_Lock WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026 AND PeriodID = 0)
BEGIN
    INSERT INTO tblSal_Lock (Month, Year, EmployeeID, PeriodID)
    VALUES (10, 2026, '099', 0);
END

PRINT N'✅ 5. Đã tính lại lương SALCAL_MAIN & Khóa kỳ 10/2026 cho NV 099 (tblSal_Lock)!';
PRINT N'-------------------------------------------------------------------------';
PRINT N'🎉 HOÀN TẤT! CSDL ĐÃ SẴN SÀNG 100% CHO KỊCH BẢN FIX-8 (TC-18 -> TC-20)!';
PRINT N'-------------------------------------------------------------------------';

-- -------------------------------------------------------------------------------------
-- 6. TRUY VẤN ĐỐI SOÁT NHANH KẾT QUẢ SAU KHI CHẠY
-- -------------------------------------------------------------------------------------
SELECT
    s.EmployeeID,
    s.Month,
    s.Year,
    d.StandardWDays,
    d.ATTHours,
    d.DaysOfSalEntry,
    s.ActualMonthlyBasic,
    s.TaxableAdjustment,
    s.TotalIncome,
    ins.EmployeeTotal AS InsuranceTotal,
    adv.AdvanceAmount,
    adv.IsLock        AS AdvanceLocked,
    tx.EmployeeExemption,
    tx.FamilyExemption,
    tx.DependantNumber,
    tx.TaxAmt,
    s.GrossTakeHome,
    CASE WHEN lk.EmployeeID IS NOT NULL THEN N'Đã khóa' ELSE N'Chưa khóa' END AS LockStatus
FROM tblSal_Sal s
LEFT JOIN tblSal_Sal_Detail d
    ON s.EmployeeID = d.EmployeeID AND s.Month = d.Month AND s.Year = d.Year AND s.PeriodID = d.PeriodID
LEFT JOIN tblSal_Insurance ins
    ON s.EmployeeID = ins.EmployeeID AND s.Month = ins.Month AND s.Year = ins.Year
LEFT JOIN tblSal_Advance adv
    ON s.EmployeeID = adv.EmployeeID AND s.Month = adv.Month AND s.Year = adv.Year
LEFT JOIN tblSal_Tax tx
    ON s.EmployeeID = tx.EmployeeID AND s.Month = tx.Month AND s.Year = tx.Year
LEFT JOIN tblSal_Lock lk
    ON s.EmployeeID = lk.EmployeeID AND s.Month = lk.Month AND s.Year = lk.Year AND s.PeriodID = lk.PeriodID
WHERE s.EmployeeID = '099'
  AND s.Month = 10
  AND s.Year = 2026;
GO
