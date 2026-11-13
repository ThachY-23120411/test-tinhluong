-- ==================================================================================
-- SCRIPT RESET & SEED TIỀN ĐỀ CHO CONVERSATION [FIX-4] (QUẢN TRỊ HR CUONG.VU)
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MÔI TRƯỜNG: Vietinsoft_ForTest_Tai2 / Vietinsoft_ForTest3 / Vietinsoft_ForTest_Tai
-- PHẠM VI RESET (CHỈ TÁC ĐỘNG ĐÚNG NV 099):
--   1. Bảo đảm quyền Admin cho cuong.vu, chien.nguyen, admin.
--   2. Xóa sạch dữ liệu do fix-4 sinh ra trên UI để chạy lại từ đầu:
--      - tblSalaryHistory (Lương cơ bản 10tr & Công thức tính lương - chờ TC-03 nạp lại)
--      - tblLabourContract (Hợp đồng lao động)
--      - tblFamilyInfo (Người phụ thuộc Nguyễn Minh Khang - chờ TC-04 nạp lại)
--      - tblShiftGroupByEmployee (Phân ca làm việc hành chính - chờ TC-05 nạp lại)
--   3. Bảo đảm TIỀN ĐỀ ĐẦU VÀO sạch sẽ:
--      - Hồ sơ nhân viên 099 (Nguyễn Văn Test - tblEmployee)
--      - Trạng thái làm việc bình thường (tblEmployeeStatusHistory)
--      - Cây nhân sự (tmpEmployeeTree)
--      - Phân bổ phòng ban & chức vụ Thử việc IT (tblDivDepSecPos)
--      - Tài khoản ESS Portal test.nv / 123 & quyền menu (tblSC_Login, tblSC_Right_Stored)
--      - Tuyến người duyệt đơn (tblApprovalLineByEmployee)
--      - Ngân sách phép năm AL = 2 ngày (tblEmployeeAnnual)
-- MỤC ĐÍCH: Cho phép người dùng chạy lại riêng fix-4 (Run-All-fix-4.bat hoặc từng TC)
--           bất kỳ lúc nào với trạng thái sạch sẽ 100%!
-- ==================================================================================

SET NOCOUNT ON;
PRINT N'==================================================================================';
PRINT N'🚀 BẮT ĐẦU RESET & SEED TIỀN ĐỀ CHO FIX-4 (NV 099 - TC-03, TC-04, TC-05)...';
PRINT N'==================================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. BẢO VỆ TÀI KHOẢN QUẢN TRỊ (cuong.vu, chien.nguyen, admin)
    UPDATE tblSC_Login 
    SET LoginName = 'cuong.vu', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1 
    WHERE EmployeeID = '014' OR LoginName = 'cuong.vu';

    UPDATE tblSC_Login 
    SET LoginName = 'chien.nguyen', PassWord = '123', IsDisable = 0, isAdmin = 1, AdminRight = 1 
    WHERE EmployeeID = '013' OR LoginName = 'chien.nguyen';

    UPDATE tblSC_Login 
    SET isAdmin = 1, AdminRight = 1 
    WHERE LoginID = 1 OR LoginName = 'admin';
    PRINT N'🛡️  1. Đã bảo đảm an toàn quyền Admin cho cuong.vu, chien.nguyen, admin';

    -- 2. XÓA DỮ LIỆU FIX-4 PHÁT SINH TRÊN GIAO DIỆN ĐỂ SẴN SÀNG CHẠY LẠI
    -- 2.1 Xóa Lịch sử lương & Hợp đồng lao động (Chờ TC-03 nạp lại qua Modal)
    DELETE FROM tblLabourContract WHERE EmployeeID = '099';
    DELETE FROM tblSalaryHistory  WHERE EmployeeID = '099';
    PRINT N'✅ 2.1 [TC-03] Đã xóa lịch sử lương & HĐLĐ của NV 099 (tblSalaryHistory, tblLabourContract)';

    -- 2.2 Xóa Người phụ thuộc giảm trừ gia cảnh (Chờ TC-04 nạp lại qua Modal)
    DELETE FROM tblFamilyInfo WHERE EmployeeID = '099';
    PRINT N'✅ 2.2 [TC-04] Đã xóa người phụ thuộc giảm trừ gia cảnh của NV 099 (tblFamilyInfo)';

    -- 2.3 Xóa Phân ca làm việc hành chính (Chờ TC-05 nạp lại qua Modal)
    DELETE FROM tblShiftGroupByEmployee WHERE EmployeeID = '099';
    PRINT N'✅ 2.3 [TC-05] Đã xóa phân ca làm việc của NV 099 (tblShiftGroupByEmployee)';

    -- 3. BẢO ĐẢM TIỀN ĐỀ ĐẦU VÀO (HỒ SƠ, TÀI KHOẢN & PHÒNG BAN)
    -- 3.1 Khởi tạo Hồ sơ nhân viên 099 (tblEmployee)
    IF NOT EXISTS (SELECT 1 FROM tblEmployee WHERE EmployeeID = '099')
    BEGIN
        INSERT INTO tblEmployee (EmployeeID, FullName, LastName, FirstName, HireDate, Birthday, Sex, ID_Number)
        VALUES ('099', N'Nguyễn Văn Test', N'Nguyễn Văn', N'Test', '2026-10-01', '1995-05-15', 1, '079099888999');
        PRINT N'✅ 3.1 Đã tạo mới hồ sơ nhân viên 099 (tblEmployee)';
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
        PRINT N'✅ 3.1 Đã chuẩn hóa hồ sơ nhân viên 099 (tblEmployee)';
    END

    -- 3.2 Khởi tạo Trạng thái làm việc bình thường (StatusEndDate = NULL)
    IF NOT EXISTS (SELECT 1 FROM tblEmployeeStatusHistory WHERE EmployeeID = '099')
    BEGIN
        INSERT INTO tblEmployeeStatusHistory (EmployeeID, EmployeeStatusID, ChangedDate, StatusEndDate, Remark)
        VALUES ('099', 0, '2026-10-01', NULL, N'Làm việc bình thường');
        PRINT N'✅ 3.2 Đã tạo trạng thái làm việc bình thường cho NV 099 (tblEmployeeStatusHistory)';
    END
    ELSE
    BEGIN
        UPDATE tblEmployeeStatusHistory 
        SET EmployeeStatusID = 0, ChangedDate = '2026-10-01', StatusEndDate = NULL
        WHERE EmployeeID = '099';
        PRINT N'✅ 3.2 Đã chuẩn hóa trạng thái làm việc cho NV 099 (tblEmployeeStatusHistory)';
    END

    -- 3.3 Đưa NV 099 vào cây nhân sự của cuong.vu, chien.nguyen, admin
    DELETE FROM tmpEmployeeTree WHERE EmployeeID = '099';
    INSERT INTO tmpEmployeeTree (EmployeeID, LoginID)
    SELECT '099', LoginID 
    FROM tblSC_Login 
    WHERE LoginName IN ('cuong.vu', 'chien.nguyen', 'admin') OR LoginID IN (1, 22, 23);
    PRINT N'✅ 3.3 Đã đưa NV 099 vào cây nhân sự tmpEmployeeTree';

    -- 3.4 Phân bổ phòng ban & chức vụ (tblDivDepSecPos)
    IF NOT EXISTS (SELECT 1 FROM tblDivDepSecPos WHERE EmployeeID = '099')
    BEGIN
        INSERT INTO tblDivDepSecPos (EmployeeID, DivisionID, DepartmentID, PositionID, ChangedDate)
        VALUES ('099', 1, 3, 450, '2026-10-01');
        PRINT N'✅ 3.4 Đã phân bổ phòng ban Nhân sự / Thử việc IT cho NV 099 (tblDivDepSecPos)';
    END
    ELSE
    BEGIN
        UPDATE tblDivDepSecPos
        SET DivisionID = 1, DepartmentID = 3, PositionID = 450, ChangedDate = '2026-10-01'
        WHERE EmployeeID = '099';
        PRINT N'✅ 3.4 Đã chuẩn hóa phòng ban cho NV 099 (tblDivDepSecPos)';
    END

    -- 3.5 Khởi tạo tài khoản ESS Portal test.nv / 123 (tblSC_Login & tblSC_Right_Stored)
    DELETE FROM tblSC_Right_Stored 
    WHERE LoginID IN (SELECT LoginID FROM tblSC_Login WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014'));

    DELETE FROM tblSC_Login 
    WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014');

    INSERT INTO tblSC_Login (
        LoginName, PassWord, EmployeeID, ParentLoginID, UseGroupRightOnly, NeedEncryptPassWordColumnList, IsDisable, IsGroup
    )
    VALUES (
        'test.nv', '123', '099', '9', 1, 'PassWord', 0, 0
    );

    INSERT INTO tblSC_Right_Stored (ObjectID, LoginID, FullAccess)
    SELECT 70, LoginID, 32 
    FROM tblSC_Login 
    WHERE LoginName = 'test.nv';
    PRINT N'✅ 3.5 Đã tạo mới tài khoản ESS Portal test.nv / 123 & cấp quyền menu';

    -- 3.6 Thiết lập tuyến người duyệt (tblApprovalLineByEmployee) cho NV 099
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
    PRINT N'✅ 3.6 Đã thiết lập tuyến duyệt đơn cho NV 099 (tblApprovalLineByEmployee)';

    -- 3.7 Khởi tạo ngân sách phép năm AL = 2 ngày (tblEmployeeAnnual)
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
    PRINT N'✅ 3.7 Đã khởi tạo ngân sách phép năm AL = 2 ngày (Remain = 2) cho NV 099 (tblEmployeeAnnual)';

    COMMIT TRANSACTION;
    PRINT N'==================================================================================';
    PRINT N'🎉 HOÀN TẤT RESET FIX-4! CSDL ĐÃ SẴN SÀNG ĐỂ CHẠY LẠI TC-03, TC-04, TC-05!';
    PRINT N'==================================================================================';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'❌ CÓ LỖI XẢY RA: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==================================================================================
-- BẢNG ĐỐI SOÁT CSDL SAU KHI RESET FIX-4 (TẤT CẢ DỮ LIỆU FIX-4 PHẢI = 0)
-- ==================================================================================
PRINT N'';
PRINT N'📊 BẢNG ĐỐI SOÁT TRẠNG THÁI SẴN SÀNG CHO FIX-4:';
SELECT 
    (SELECT COUNT(*) FROM tblEmployee WHERE EmployeeID = '099') AS [1. Hồ sơ NV 099 (Cần = 1)],
    (SELECT COUNT(*) FROM tblSC_Login WHERE LoginName = 'test.nv') AS [2. Tài khoản test.nv (Cần = 1)],
    (SELECT COUNT(*) FROM tblSalaryHistory WHERE EmployeeID = '099') AS [3. Lương TC-03 (Cần = 0)],
    (SELECT COUNT(*) FROM tblFamilyInfo WHERE EmployeeID = '099') AS [4. NPT TC-04 (Cần = 0)],
    (SELECT COUNT(*) FROM tblShiftGroupByEmployee WHERE EmployeeID = '099') AS [5. Phân ca TC-05 (Cần = 0)];
GO
