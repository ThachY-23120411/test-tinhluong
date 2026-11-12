-- ==================================================================================
-- SCRIPT RESET DỮ LIỆU RIÊNG CHO CONVERSATION [FIX-7] (KẾ TOÁN CHIEN.NGUYEN)
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MÔI TRƯỜNG: Vietinsoft_ForTest_Tai2 / Vietinsoft_ForTest3 / Vietinsoft_ForTest_Tai
-- PHẠM VI RESET (CHỈ TÁC ĐỘNG ĐÚNG NV 099 & KỲ THÁNG 10/2026 - BẢO TOÀN 5 NGÀY CÔNG FIX-5/FIX-6):
--   1. Mở khóa sổ kỳ lương & khóa công Tháng 10/2026 của NV 099 (tblSal_Lock, tblAtt_LockMonth)
--   2. Xóa toàn bộ kết quả tính lương chi tiết & phụ trợ do SALCAL_MAIN sinh ra cho NV 099
--      (tblSal_Sal_Detail, tblSal_Sal, tblSal_OT_Detail, tblSal_OT, tblSal_PaidLeave_Detail,
--       tblSal_PaidLeave, tblSal_Allowance_Detail, tblSal_Allowance, tblSal_Insurance,
--       tblSal_IO_Detail, tblSal_IO, tblSal_NS_Detail, tblSal_NS, tblSal_Tax, tblSal_AttendanceData, tblSal_Error)
--   3. Xóa phiếu Tạm ứng lương Tháng 10/2026 (tblSal_Advance)
--   4. Xóa khoản Thưởng KPI 1,000,000 VNĐ trên cả bảng nhập liệu UI & bảng tổng hợp
--      (tblPR_Adjustment & tblSal_Adjustment)
-- MỤC ĐÍCH: Chạy lại TC-14 -> TC-17 hoặc quay Recording F12 nhiều lần mà KHÔNG mất dữ liệu
--           hồ sơ (fix-4), 5 ngày công mẫu & 3 đơn đã duyệt (fix-5, fix-6)!
-- ==================================================================================
-- Hướng dẫn: Mở trên SSMS -> Bấm Ctrl + F5 kiểm tra cú pháp -> Bấm F5 để thực thi.
-- ==================================================================================

SET NOCOUNT ON;
PRINT N'==================================================================================';
PRINT N'🚀 BẮT ĐẦU RESET DỮ LIỆU TEST CHO RIÊNG CONVERSATION FIX-7 (NV 099 - THÁNG 10/2026)...';
PRINT N'==================================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Mở niêm phong Khóa sổ kỳ lương & Khóa công Tháng 10/2026 của NV 099
    DELETE FROM tblSal_Lock
    WHERE Month = 10 AND Year = 2026 AND (EmployeeID = '099' OR EmployeeID = '-1');

    DELETE FROM tblAtt_LockMonth
    WHERE Month = 10 AND Year = 2026 AND EmployeeID = '099';

    DELETE FROM tblatt_lock
    WHERE EmployeeID = '099' AND [Date] BETWEEN '2026-10-10' AND '2026-11-09';
    PRINT N'✅ [1/4] Đã mở khóa lương (tblSal_Lock) & khóa công (tblAtt_LockMonth, tblatt_lock) Tháng 10/2026 cho NV 099';

    -- 2. Xóa kết quả tính tiền lương & các bảng chi tiết phụ trợ do SALCAL_MAIN sinh ra (TC-16)
    DELETE FROM tblSal_Sal_Detail        WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Sal               WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_OT_Detail         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_OT                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_PaidLeave_Detail  WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_PaidLeave         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Allowance_Detail  WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Allowance         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Insurance         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_IO_Detail         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_IO                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_NS_Detail         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_NS                WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Tax               WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_AttendanceData    WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    DELETE FROM tblSal_Error             WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    PRINT N'✅ [2/4] Đã xóa sạch toàn bộ kết quả tính lương (tblSal_Sal, _Detail, OT, PaidLeave, Tax, Insurance...) của NV 099';

    -- 3. Xóa dữ liệu Tạm ứng lương Tháng 10/2026 (TC-15 - MnuPRL070)
    DELETE FROM tblSal_Advance
    WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    PRINT N'✅ [3/4] Đã xóa dữ liệu tạm ứng lương Tháng 10/2026 của NV 099 (tblSal_Advance)';

    -- 4. Xóa Thưởng KPI / Thu nhập không cố định Tháng 10/2026 trên CẢ bảng nhập liệu & bảng tổng hợp (TC-14 - MnuPRL036)
    DELETE FROM tblPR_Adjustment
    WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;

    DELETE FROM tblSal_Adjustment
    WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
    PRINT N'✅ [4/4] Đã xóa thưởng KPI / thu nhập không cố định Tháng 10/2026 của NV 099 (tblPR_Adjustment & tblSal_Adjustment)';

    COMMIT TRANSACTION;
    PRINT N'----------------------------------------------------------------------------------';
    PRINT N'🎉 HOÀN TẤT RESET DỮ LIỆU FIX-7! Dữ liệu công & đơn đã duyệt của fix-5/fix-6 VẪN ĐƯỢC GIỮ NGUYÊN!';
    PRINT N'----------------------------------------------------------------------------------';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ CÓ LỖI XẢY RA KHI RESET FIX-7: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==================================================================================
-- BẢNG ĐỐI SOÁT KIỂM CHỨNG TỰ ĐỘNG SAU KHI BẤM F5 TRÊN SSMS
-- ==================================================================================
PRINT N'📊 BẢNG ĐỐI SOÁT SAU KHI RESET FIX-7 (Tất cả chỉ số fix-7 phải = 0):';
SELECT
    (SELECT COUNT(*) FROM tblPR_Adjustment   WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Thu nhập không cố định UI (Cần = 0)],
    (SELECT COUNT(*) FROM tblSal_Adjustment  WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Điều chỉnh lương tổng hợp (Cần = 0)],
    (SELECT COUNT(*) FROM tblSal_Advance     WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Tạm ứng lương (Cần = 0)],
    (SELECT COUNT(*) FROM tblSal_Sal         WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Bảng lương tổng hợp (Cần = 0)],
    (SELECT COUNT(*) FROM tblSal_Sal_Detail  WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Bảng lương chi tiết (Cần = 0)],
    (SELECT COUNT(*) FROM tblAtt_LockMonth   WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Khóa công 099 (Cần = 0)],
    (SELECT COUNT(*) FROM tblSal_Lock        WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026) AS [Khóa lương 099 (Cần = 0)],
    (SELECT COUNT(*) FROM tblHasTA           WHERE EmployeeID = '099' AND AttStart IS NOT NULL AND AttDate BETWEEN '2026-10-01' AND '2026-10-31') AS [Số ngày công mẫu fix-5/fix-6 còn giữ (Cần = 5)];
GO
