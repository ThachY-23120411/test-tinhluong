-- =================================================================================================
-- SCRIPT: TÍNH TIỀN LƯƠNG & KHÓA SỔ KỲ LƯƠNG THÁNG 10/2026 CHO NV 099 (NGUYỄN VĂN TEST)
-- MỤC ĐÍCH: Dành cho Người Dùng bấm F5 trên SSMS để xem trước Phiếu lương Tháng 10/2026 trên giao diện web
-- CƠ CHẾ:
--   1. Kích hoạt SALCAL_MAIN tính lương từ 5 ngày công chấm công thực tế của NV 099 vào tblSal_Sal
--   2. Niêm phong kỳ lương vào tblSal_Lock để menu Phiếu lương (sp_PaySlipView) tự động hiển thị Tháng 10/2026
-- =================================================================================================
USE Vietinsoft_ForTest_Tai2;
GO

SET NOCOUNT ON;

PRINT N'🚀 BẮT ĐẦU TÍNH TIỀN LƯƠNG & KHÓA SỔ THÁNG 10/2026 CHO NV 099...';

-- 1. Đảm bảo NV 099 có mức lương cơ bản trong tblSalaryHistory để SALCAL_MAIN không loại bỏ
IF NOT EXISTS (SELECT 1 FROM tblSalaryHistory WHERE EmployeeID = '099')
BEGIN
    INSERT INTO tblSalaryHistory (EmployeeID, Date, Salary, InsSalary, WorkingHoursPerDay, CurrencyCode)
    VALUES ('099', '2026-10-01', 10000000, 10000000, 8.0, 'VND');
    PRINT N'✅ 1. Đã bổ sung mức lương 10,000,000 VNĐ cho NV 099 trong tblSalaryHistory';
END
ELSE
BEGIN
    UPDATE tblSalaryHistory 
    SET Salary = 10000000, InsSalary = 10000000
    WHERE EmployeeID = '099' AND (Salary IS NULL OR Salary = 0);
    PRINT N'✅ 1. Mức lương của NV 099 đã sẵn sàng: 10,000,000 VNĐ';
END
GO

-- 2. Chạy thủ tục tính lương tự động SALCAL_MAIN cho NV 099 tháng 10/2026
PRINT N'⏳ Đang thực thi SALCAL_MAIN Tháng 10/2026...';
EXEC SALCAL_MAIN 
    @Month = 10, 
    @Year = 2026, 
    @LoginID = 3, 
    @PeriodID = 0, 
    @EmployeeID = '099', 
    @CalculateRetro = 0;
PRINT N'✅ 2. Đã tính lương xong! Dữ liệu đã được nạp vào tblSal_Sal.';
GO

-- 3. Khóa sổ kỳ lương Tháng 10/2026 cho NV 099 trong tblSal_Lock
-- (Điều kiện bắt buộc để sp_PaySlipView nhận diện hiển thị Tháng 10 và Tab Lịch sử không bị trống)
IF NOT EXISTS (SELECT 1 FROM tblSal_Lock WHERE Year = 2026 AND Month = 10 AND EmployeeID = '099')
BEGIN
    INSERT INTO tblSal_Lock (Month, Year, EmployeeID, PeriodID)
    VALUES (10, 2026, '099', 0);
    PRINT N'✅ 3. Đã ghi nhận Khóa sổ Tháng 10/2026 cho NV 099 trong tblSal_Lock';
END
ELSE
BEGIN
    PRINT N'✅ 3. NV 099 đã có sẵn bản ghi Khóa sổ Tháng 10/2026 trong tblSal_Lock';
END
GO

-- 4. Kiểm tra đối soát kết quả sau khi tính
SELECT 
    s.EmployeeID,
    e.FullName,
    s.Month,
    s.Year,
    s.StandardWorkDays AS CongChuan,
    s.ActualWorkDays AS CongThucTe,
    s.TotalSalary AS LuongCoBan,
    s.NetSalary AS ThucLinh
FROM tblSal_Sal s
LEFT JOIN tblEmployee e ON s.EmployeeID = e.EmployeeID
WHERE s.EmployeeID = '099' AND s.Month = 10 AND s.Year = 2026;
GO

PRINT N'🎉 HOÀN TẤT! Bạn có thể quay lại trình duyệt Chrome (F5 refresh) và mở menu "Phiếu lương" để xem kết quả!';
GO
