
CREATE PROCEDURE [dbo].[sp_PaySlipView]
(
    @LoginID INT = 3,
    @Month INT = NULL,
    @Year INT = NULL,
    @PeriodID INT = 0,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb INT = 2,
    @MenuID VARCHAR(20) = '',
    @EmployeeID VARCHAR(50) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @isWeb = ISNULL(@isWeb, 2);

    -- 1. Lấy EmployeeID chính chủ của tài khoản đang đăng nhập
    DECLARE @OwnEmployeeID VARCHAR(50);
    SELECT @OwnEmployeeID = EmployeeID FROM dbo.tblSC_Login WHERE LoginID = @LoginID;

    -- Nếu không truyền @EmployeeID (xem phiếu lương cá nhân), mặc định lấy chính chủ
    IF @EmployeeID IS NULL OR LTRIM(RTRIM(@EmployeeID)) = '' OR @EmployeeID = '-1'
    BEGIN
        SET @EmployeeID = @OwnEmployeeID;
    END;

    -- 2. Bộ lọc phân quyền: Admin được xem toàn bộ, nhân viên thường lấy theo cây phân quyền
    DECLARE @IsAdmin BIT = 0;
    IF EXISTS (
        SELECT 1 FROM dbo.tblSC_Login
        WHERE LoginID = @LoginID
          AND (ISNULL(AdminRight, 0) = 1 OR ISNULL(isAdmin, 0) = 1)
    )
        SET @IsAdmin = 1;

    IF OBJECT_ID('tempdb..#tmpAllowedEmp') IS NOT NULL DROP TABLE #tmpAllowedEmp;
    CREATE TABLE #tmpAllowedEmp (EmployeeID VARCHAR(50) PRIMARY KEY);

    IF @IsAdmin = 1
    BEGIN
        INSERT INTO #tmpAllowedEmp (EmployeeID)
        SELECT EmployeeID FROM dbo.fn_vtblEmployeeList_Simple_ByDate(GETDATE(), '-1', @LoginID);
    END
    ELSE
    BEGIN
        INSERT INTO #tmpAllowedEmp (EmployeeID)
        SELECT EmployeeID
        FROM dbo.fn_vtblEmployeeList_Simple_ByDate(GETDATE(), '-1', @LoginID);

        IF @OwnEmployeeID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM #tmpAllowedEmp WHERE EmployeeID = @OwnEmployeeID)
            INSERT INTO #tmpAllowedEmp (EmployeeID) VALUES (@OwnEmployeeID);
    END;

    -- 2b. Bổ sung nhân viên được xem qua cây (dbo.tmpEmployeeTree) - áp dụng cho cả Admin và nhân viên thường
    --     Những EmployeeID không có trong fn_vtblEmployeeList_Simple_ByDate nhưng có trong cây thì vẫn được xem
    IF OBJECT_ID('dbo.tmpEmployeeTree') IS NOT NULL
    BEGIN
        INSERT INTO #tmpAllowedEmp (EmployeeID)
        SELECT DISTINCT t.EmployeeID
        FROM dbo.tmpEmployeeTree AS t
        WHERE t.LoginID = @LoginID
          AND t.EmployeeID IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM #tmpAllowedEmp AS a WHERE a.EmployeeID = t.EmployeeID);
    END;

    -- 3. Kiểm tra @EmployeeID: Chống IDOR, nếu không nằm trong danh sách được phép thì ép về chính chủ
    IF NOT EXISTS (SELECT 1 FROM #tmpAllowedEmp WHERE EmployeeID = @EmployeeID)
    BEGIN
        SET @EmployeeID = @OwnEmployeeID;
    END;


    -- 4. Nếu chưa truyền Month/Year thì lấy bản khóa lương mới nhất từ tblSal_Sal
    IF @Month IS NULL OR @Year IS NULL
    BEGIN
        SELECT TOP 1 @Month = Month, @Year = Year, @PeriodID = ISNULL(PeriodID, 0)
        FROM dbo.tblSal_Sal a
        WHERE a.EmployeeID = @EmployeeID
          AND EXISTS (
              SELECT 1 FROM dbo.tblSal_Lock b
              WHERE a.EmployeeID = b.EmployeeID AND a.Month = b.Month AND a.Year = b.Year
          )
        ORDER BY Year DESC, Month DESC, ISNULL(PeriodID, 0) DESC;
    END;

    IF @Month IS NULL SET @Month = MONTH(GETDATE());
    IF @Year IS NULL SET @Year = YEAR(GETDATE());

    DECLARE @FromDate DATE, @ToDate DATE;
    SELECT TOP 1 @FromDate = FromDate, @ToDate = ToDate
    FROM dbo.fn_Get_SalaryPeriod_Term(@Month, @Year, @PeriodID);
    IF @ToDate IS NULL SET @ToDate = GETDATE();

    DECLARE @Getdate DATETIME = DATEADD(DAY, 7, GETDATE());

    -- Dataset 0: Thông tin công ty
    SELECT CompanyFullName, Address FROM dbo.tblCompany;

    -- Dataset 1: Employee - Earnings
    SELECT
        te.EmployeeID, te.FullName, te.HireDate, poi.PositionName, dp.DepartmentName, sec.SectionName, gr.GroupName,
        sal_dt.DaysOfSalEntry AS TotalPaidDays, sal_dt.StandardWDays, te.BankCode, mdb.BankName, sal.TotalIncome, so.OTAmount,
        st.DependantNumber, RIGHT('0' + CAST(@Month AS NVARCHAR(2)), 2) AS Month, @Year AS Year,
        sal_dt.ActualMonthlyBasic, sal_dt.DaysOfSalEntry, sal.GrossTakeHome AS GrossTakeHome,
        so.OTHour, iot.IOMinutesDeduct, lvt.TotalLeave
    INTO #tmpEmployeeInfo
    FROM dbo.fn_vtblEmployeeList_Bydate(@ToDate, @EmployeeID, @LoginID) AS te
    INNER JOIN #tmpAllowedEmp AS ok ON te.EmployeeID = ok.EmployeeID
    LEFT JOIN dbo.tblDepartment AS dp ON dp.DepartmentID = te.DepartmentID
    LEFT JOIN dbo.tblPosition AS poi ON poi.PositionID = te.PositionID
    LEFT JOIN dbo.tblSection AS sec ON sec.SectionID = te.SectionID
    LEFT JOIN dbo.tblGroup AS gr ON gr.GroupID = te.GroupID
    LEFT JOIN dbo.tblMD_Bank AS mdb ON mdb.BankCode = te.BankCode
    LEFT JOIN dbo.tblSal_OT_Detail AS so ON so.EmployeeID = te.EmployeeID AND so.Month = @Month AND so.Year = @Year AND so.PeriodID = @PeriodID
    LEFT JOIN dbo.tblSal_Tax AS st ON te.EmployeeID = st.EmployeeID AND st.Month = @Month AND st.Year = @Year
    LEFT JOIN dbo.fn_CurrentSalaryHistoryIDByDate(@Getdate) AS csh ON csh.EmployeeID = te.EmployeeID
    LEFT JOIN dbo.tblSalaryHistory AS sh ON sh.SalaryHistoryID = csh.SalaryHistoryID
    LEFT JOIN dbo.tblSal_PaidLeave_Detail AS spd ON spd.EmployeeID = te.EmployeeID AND spd.Month = @Month AND spd.Year = @Year
    LEFT JOIN (
        SELECT EmployeeID, SUM(IOMinutesDeduct / 60.0) / 8.0 AS IOMinutesDeduct
        FROM dbo.tblInLateOutEarly
        WHERE EmployeeID = @EmployeeID AND IODate BETWEEN @FromDate AND @ToDate
        GROUP BY EmployeeID
    ) AS iot ON iot.EmployeeID = te.EmployeeID
    LEFT JOIN (
        SELECT EmployeeID, SUM(LvAmount) / 8.0 AS TotalLeave
        FROM dbo.tblLvHistory
        WHERE EmployeeID = @EmployeeID AND LeaveDate BETWEEN @FromDate AND @ToDate
        GROUP BY EmployeeID
    ) AS lvt ON lvt.EmployeeID = te.EmployeeID
    LEFT JOIN (
        SELECT d.EmployeeID, d.Month, d.Year, d.PeriodID,
               MAX(d.StandardWDays) AS StandardWDays,
               SUM(d.ActualMonthlyBasic) AS ActualMonthlyBasic,
               SUM(d.DaysOfSalEntry) AS DaysOfSalEntry
        FROM dbo.tblSal_Sal_Detail d
        WHERE d.Month = @Month AND d.Year = @Year AND d.PeriodID = @PeriodID
        GROUP BY d.EmployeeID, d.Month, d.Year, d.PeriodID
    ) AS sal_dt ON sal_dt.EmployeeID = te.EmployeeID AND sal_dt.Month = @Month AND sal_dt.Year = @Year AND sal_dt.PeriodID = @PeriodID
    LEFT JOIN dbo.tblSal_Sal AS sal ON sal.EmployeeID = te.EmployeeID AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
    GROUP BY
        te.EmployeeID, te.FullName, te.HireDate, poi.PositionName, dp.DepartmentName, sec.SectionName, gr.GroupName,
        sal_dt.DaysOfSalEntry, sal_dt.StandardWDays, te.BankCode, mdb.BankName, sal.TotalIncome, so.OTAmount,
        sal_dt.ActualMonthlyBasic, sal.GrossTakeHome, so.OTHour, iot.IOMinutesDeduct, lvt.TotalLeave, st.DependantNumber;

    SELECT * FROM #tmpEmployeeInfo;

    -- Ghi nhật ký truy cập (Audit log)
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblSC_EZLog')
    BEGIN
        INSERT INTO dbo.tblSC_EZLog (LoginID, LogTime, EmployeeID, FunctionClassName, FunctionName, KindOfData, DateOfData, OldData, NewData)
        SELECT @LoginID, GETDATE(), @EmployeeID, 'sp_PaySlipView', 'sp_PaySlipView', 'View payslip', GETDATE(),
               '@isWeb = ' + CAST(@isWeb AS VARCHAR) + ', @Month = ' + CAST(@Month AS VARCHAR) + ', @Year = ' + CAST(@Year AS VARCHAR),
               EmployeeID + ' - ' + FullName
        FROM #tmpEmployeeInfo
        WHERE @LoginID NOT IN (3, 21);
    END;

    -- Dataset 2: Paid leave / Nghỉ hưởng lương
    SELECT sal.EmployeeID, sal.LeaveCode,
           CASE WHEN LEN(ISNULL(lv.DescriptionEN, '')) > 1 THEN lv.DescriptionEN + ' / ' ELSE '' END + lv.Description AS Description,
           sal.AmountPaid, sal.LeaveDays
    INTO #tblSal_PaidLeave_Detail
    FROM dbo.tblSal_PaidLeave_Detail AS sal
    INNER JOIN dbo.tblLeaveType AS lv ON sal.LeaveCode = lv.LeaveCode
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND sal.AmountPaid > 0;
    SELECT * FROM #tblSal_PaidLeave_Detail;

    -- Dataset 3: Overtimes / Tăng ca
    SELECT sal.EmployeeID,
           CASE WHEN LEN(ISNULL(ot.DescriptionEN, '')) > 1 THEN ot.DescriptionEN + ' / ' ELSE '' END + ot.Description AS Description,
           sal.OTHour, sal.OTAmount
    INTO #tblSal_OT_Detail
    FROM dbo.tblSal_OT_Detail AS sal
    INNER JOIN dbo.tblOverTimeSetting AS ot ON sal.OverTimeID = ot.OTKind
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND sal.OTAmount > 0;
    SELECT * FROM #tblSal_OT_Detail;

    -- Dataset 4: Allowances / Phụ cấp
    SELECT sal.EmployeeID,
           CASE WHEN LEN(ISNULL(allow.AllowanceNameEN, '')) > 1 THEN allow.AllowanceNameEN + ' / ' ELSE '' END + allow.AllowanceName AS AllowanceName,
           sal.Amount
    INTO #tblSal_Allowance
    FROM dbo.tblSal_Allowance AS sal
    INNER JOIN dbo.tblAllowanceSetting AS allow ON allow.AllowanceID = sal.AllowanceID
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND sal.Amount > 0
    ORDER BY allow.Ord;
    SELECT * FROM #tblSal_Allowance;

    -- Dataset 5: Adjustments / Các khoản điều chỉnh
    SELECT sal.EmployeeID,
           ISNULL(I.IncomeName, '') + ' / ' + ISNULL(i.Description, '') + ISNULL(' [' + sal.Remark + ']', '') AS Description,
           sal.Amount
    INTO #tblPR_Adjustment
    FROM dbo.tblPR_Adjustment AS sal
    INNER JOIN dbo.tblIrregularIncome AS i ON i.IncomeID = sal.IncomeID
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND ISNULL(sal.SalaryTerm, 0) = @PeriodID
      AND I.ForSalary = 1
      AND I.IncomeKind = 1;
    SELECT * FROM #tblPR_Adjustment;

    -- Dataset 6: Deductions / Các khoản giảm trừ
    IF OBJECT_ID('tempdb..#tmpDeductions') IS NOT NULL DROP TABLE #tmpDeductions;
    SELECT TOP 0 sal.EmployeeID,
           CAST(N'Unpaid leave - ' + lv.Description + N' (' + CAST(sal.LeaveDays AS VARCHAR(20)) + N' ngày)' AS NVARCHAR(500)) AS Description,
           sal.AmountDeduct
    INTO #tmpDeductions
    FROM dbo.tblSal_PaidLeave_Detail AS sal
    INNER JOIN dbo.tblLeaveType AS lv ON sal.LeaveCode = lv.LeaveCode;

    INSERT INTO #tmpDeductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID,
           N'Unpaid leave - ' + lv.Description + N' (' + CAST(sal.LeaveDays AS VARCHAR(20)) + N' ngày)',
           sal.AmountDeduct
    FROM dbo.tblSal_PaidLeave_Detail AS sal
    INNER JOIN dbo.tblLeaveType AS lv ON sal.LeaveCode = lv.LeaveCode
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND sal.AmountDeduct > 0;

    INSERT INTO #tmpDeductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID, N'Late in - Early out / Đi trễ về sớm', ISNULL(sal.InLateAmount, 0) + ISNULL(sal.OutEarlyAmount, 0)
    FROM dbo.tblSal_IO AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND ISNULL(sal.InLateAmount, 0) + ISNULL(sal.OutEarlyAmount, 0) > 0;

    INSERT INTO #tmpDeductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID, N'Insurance fee / BHXH, BHYT, BHTN', sal.EmployeeTotal
    FROM dbo.tblSal_Insurance AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND @PeriodID IN (0, 2)
      AND sal.EmployeeTotal > 0;

    INSERT INTO #tmpDeductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID, N'Union fee / Phí công đoàn', sal.EmpUnion
    FROM dbo.tblSal_Sal AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND sal.EmpUnion > 0;

    INSERT INTO #tmpDeductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID, N'Advance salary / Tạm ứng lương', sal.AdvanceAmount
    FROM dbo.tblSal_Advance AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND @PeriodID IN (0, 2)
      AND sal.AdvanceAmount > 0
      AND sal.isLock = 1;

    INSERT INTO #tmpDeductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID,
           ISNULL(I.IncomeName, '') + ' / ' + ISNULL(i.Description, '') + ISNULL(' [' + sal.Remark + ']', '') AS Description,
           sal.Amount
    FROM dbo.tblPR_Adjustment AS sal
    INNER JOIN dbo.tblIrregularIncome AS i ON i.IncomeID = sal.IncomeID
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND ISNULL(sal.SalaryTerm, 0) = @PeriodID
      AND I.ForSalary = 1
      AND I.IncomeKind = 0;

    SELECT * FROM #tmpDeductions;

    -- Dataset 7: PIT Deduction info / Giảm trừ thuế TNCN
    IF OBJECT_ID('tempdb..#PIT_Deductions') IS NOT NULL DROP TABLE #PIT_Deductions;
    SELECT sal.EmployeeID, CAST(0 AS INT) AS STT,
           CAST(N'Personal exemption / Giảm trừ bản thân' AS NVARCHAR(400)) AS Description,
           sal.EmployeeExemption AS AmountDeduct
    INTO #PIT_Deductions
    FROM dbo.tblSal_Tax AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID;

    INSERT INTO #PIT_Deductions (EmployeeID, STT, Description, AmountDeduct)
    SELECT sal.EmployeeID, 1, N'Family exemption / Giảm trừ gia cảnh', sal.FamilyExemption
    FROM dbo.tblSal_Tax AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND ISNULL(sal.FamilyExemption, 0) > 0;

    INSERT INTO #PIT_Deductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID, N'Overtime difference / Chênh lệch tăng ca', sal.OTDeduction
    FROM dbo.tblSal_Tax AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND ISNULL(sal.OTDeduction, 0) > 0;

    INSERT INTO #PIT_Deductions (EmployeeID, Description, AmountDeduct)
    SELECT sal.EmployeeID, N'13th salary taxable / Lương tháng 13 chịu thuế tạm tính', sal.Salary13Amount
    FROM dbo.tblSal_Tax AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID
      AND ISNULL(sal.Salary13Amount, 0) > 0;

    INSERT INTO #PIT_Deductions (EmployeeID, STT, Description, AmountDeduct)
    SELECT sal.EmployeeID, 2, N'Taxable income / Thu nhập chịu thuế', sal.IncomeTaxable
    FROM dbo.tblSal_Tax AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID;

    INSERT INTO #PIT_Deductions (EmployeeID, STT, Description, AmountDeduct)
    SELECT sal.EmployeeID, 3, N'Income tax / Thuế thu nhập cá nhân', sal.TaxAmt
    FROM dbo.tblSal_Tax AS sal
    WHERE sal.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND sal.Month = @Month AND sal.Year = @Year AND sal.PeriodID = @PeriodID;

    SELECT * FROM #PIT_Deductions;

    -- Dataset 8: Chi tiết bảng tăng ca
    SELECT otl.OTDate, otl.OTFrom, otl.OTTo, otl.OTHour
    INTO #tblOTList
    FROM dbo.tblOTList AS otl
    WHERE otl.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND otl.OTDate BETWEEN @FromDate AND @ToDate;
    SELECT * FROM #tblOTList;

    -- Dataset 9: Chi tiết nghỉ phép
    SELECT lv.LeaveDate, lv.LeaveCode, lv.LvAmount
    INTO #tblLvHistory
    FROM dbo.tblLvHistory AS lv
    WHERE lv.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND lv.LeaveDate BETWEEN @FromDate AND @ToDate;
    SELECT * FROM #tblLvHistory;

    -- Dataset 10: Chi tiết đi trễ về sớm
    SELECT iot.IODate, CAST(iot.IOStart AS TIME) AS IOStart, CAST(iot.IOEnd AS TIME) AS IOEnd, iot.IOMinutesDeduct
    INTO #tblInLateOutEarly
    FROM dbo.tblInLateOutEarly AS iot
    WHERE iot.EmployeeID IN (SELECT EmployeeID FROM #tmpEmployeeInfo)
      AND iot.IODate BETWEEN @FromDate AND @ToDate;
    SELECT * FROM #tblInLateOutEarly;
END;
