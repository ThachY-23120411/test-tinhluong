-- ==================================================================================
-- SCRIPT RESET TOÀN DIỆN DỮ LIỆU TEST FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI 099
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MÔI TRƯỜNG: Chạy an toàn trên Vietinsoft_ForTest_Tai2 / Vietinsoft_ForTest3 / Vietinsoft_ForTest_Tai
-- PHẠM VI 5 CONVERSATION:
--   - fix-4 (P1: Hồ sơ, HĐLĐ 10M, 1 NPT, Phân ca HC)
--   - fix-5 (P2: 3 đơn Portal: Bù công 15/10, Nghỉ phép AL 24/10, Tăng ca OT 20/10)
--   - fix-6 (P3: Phê duyệt đa cấp & Chốt chặn Delta After 23 công)
--   - fix-7 (P4: Thưởng KPI 1M, Tạm ứng 2M, Tính tiền lương & Khóa sổ T10)
--   - fix-8 (P5: Nghiệm thu Bảng lương tổng hợp & Phiếu lương cá nhân)
-- AN TOÀN TUYỆT ĐỐI: Chỉ tác động đúng EmployeeID = '099' và kỳ Tháng 10/2026!
-- ==================================================================================

-- Ghi chú: Nếu cần chuyển DB trong SSMS, hãy bỏ comment dòng USE tương ứng:
-- USE Vietinsoft_ForTest_Tai2;
-- GO

PRINT N'==================================================================================';
PRINT N'🚀 BẮT ĐẦU RESET TOÀN DIỆN DỮ LIỆU TEST CHO FLOW TÍNH LƯƠNG (NV 099)...';
PRINT N'==================================================================================';

-- 0. BẢO VỆ TÀI KHOẢN QUẢN TRỊ VIÊN (cuong.vu, chien.nguyen)
UPDATE tblSC_Login 
SET LoginName = 'cuong.vu', PassWord = '123', IsDisable = 0 
WHERE EmployeeID = '014';

UPDATE tblSC_Login 
SET LoginName = 'chien.nguyen', PassWord = '123', IsDisable = 0 
WHERE EmployeeID = '013';
PRINT N'🛡️ 0. Đã bảo đảm an toàn tài khoản quản trị (cuong.vu: 014, chien.nguyen: 013)';

-- 1. [FIX-7] MỞ NIÊM PHONG KHÓA SỔ KỲ LƯƠNG & KHÓA CÔNG THÁNG 10/2026 (tblSal_Lock, tblAtt_LockMonth)
DELETE FROM tblSal_Lock 
WHERE (EmployeeID = '099' OR EmployeeID = '-1') AND Month = 10 AND Year = 2026;
DELETE FROM tblAtt_LockMonth
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblatt_lock
WHERE EmployeeID = '099';
PRINT N'✅ 1. [fix-7] Đã mở niêm phong khóa sổ lương & khóa công Tháng 10/2026 (tblSal_Lock, tblAtt_LockMonth, tblatt_lock)';

-- 2. [FIX-7] XÓA BẢNG LƯƠNG TỔNG HỢP & TOÀN BỘ CHI TIẾT LƯƠNG CỦA 099
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
PRINT N'✅ 2. [fix-7] Đã xóa kết quả tính tiền lương & chi tiết lương của NV 099';

-- 3. [FIX-7] XÓA DỮ LIỆU TẠM ỨNG LƯƠNG THÁNG 10/2026 (tblSal_Advance)
DELETE FROM tblSal_Advance 
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
PRINT N'✅ 3. [fix-7] Đã xóa dữ liệu tạm ứng lương của NV 099 (tblSal_Advance)';

-- 4. [FIX-7] XÓA THƯỞNG KPI / THU NHẬP KHÔNG CỐ ĐỊNH THÁNG 10/2026 (tblPR_Adjustment & tblSal_Adjustment)
DELETE FROM tblPR_Adjustment
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
DELETE FROM tblSal_Adjustment 
WHERE EmployeeID = '099' AND Month = 10 AND Year = 2026;
PRINT N'✅ 4. [fix-7] Đã xóa thưởng KPI / thu nhập không cố định của NV 099 (tblPR_Adjustment & tblSal_Adjustment)';

-- 5. [FIX-5 & FIX-6] XÓA ĐƠN BÙ CÔNG / GIẢI TRÌNH ĐI TRỄ VỀ SỚM (tblAttendanceConfirmRequest, tblInLateOutEarly)
DELETE FROM tblApproverHistory 
WHERE Identity_ID IN (
    SELECT IdentityID FROM tblAttendanceConfirmRequest WHERE EmployeeID = '099'
    UNION
    SELECT IdentityID FROM tblLeaveRegistered WHERE EmployeeID = '099'
);

DELETE FROM tblAttendanceConfirmRequest 
WHERE EmployeeID = '099';
DELETE FROM tblInLateOutEarly 
WHERE EmployeeID = '099';
PRINT N'✅ 5. [fix-5/fix-6] Đã xóa đơn xin bù công & lịch sử phê duyệt của NV 099';

-- 6. [FIX-5 & FIX-6] XÓA ĐƠN XIN NGHỈ PHÉP NĂM AL (tblLeaveRegistered)
DELETE FROM tblLeaveRegistered 
WHERE EmployeeID = '099';
PRINT N'✅ 6. [fix-5/fix-6] Đã xóa đơn xin nghỉ phép năm AL của NV 099 (tblLeaveRegistered)';

-- 7. [FIX-5 & FIX-6] XÓA ĐƠN XIN TĂNG CA OT (tblOTList, tblotregistration, tblOvertime_Assignment_Detail)
DELETE FROM tblOvertime_Assignment_Detail 
WHERE EmployeeID = '099';
DELETE FROM tblOTList 
WHERE EmployeeID = '099';
DELETE FROM tblotregistration 
WHERE EmployeeID = '099';
DELETE FROM tblOTRegistration_Web 
WHERE EmployeeID = '099';
PRINT N'✅ 7. [fix-5/fix-6] Đã xóa đơn xin tăng ca OT của NV 099 (tblOTList, tblotregistration)';

-- 8. [FIX-6] XÓA DỮ LIỆU QUẸT THẺ / CÔNG THÁNG 10/2026 (tblHasTA)
DELETE FROM tblHasTA 
WHERE EmployeeID = '099';
PRINT N'✅ 8. [fix-6] Đã xóa sạch dữ liệu quẹt thẻ chấm công của NV 099 (tblHasTA)';

-- 9. [FIX-4] XÓA PHÂN CA LÀM VIỆC HÀNH CHÍNH (tblShiftGroupByEmployee)
DELETE FROM tblShiftGroupByEmployee 
WHERE EmployeeID = '099';
PRINT N'✅ 9. [fix-4] Đã xóa phân ca làm việc hành chính của NV 099 (tblShiftGroupByEmployee)';

-- 10. [FIX-4] XÓA TUYẾN PHÊ DUYỆT CỦA NHÂN VIÊN 099 (tblApprovalLineByEmployee)
DELETE FROM tblApprovalLineByEmployee 
WHERE EmployeeID = '099';
PRINT N'✅ 10. [fix-4] Đã xóa thiết lập tuyến duyệt của NV 099 (tblApprovalLineByEmployee)';

-- 11. [FIX-4] XÓA TÀI KHOẢN ESS PORTAL test.nv & PHÂN QUYỀN
DELETE FROM tblSC_Right_Stored 
WHERE LoginID IN (
    SELECT LoginID FROM tblSC_Login 
    WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014')
);

DELETE FROM tblSC_Login 
WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014');

DELETE FROM tblEmailList 
WHERE EmployeeID = '099' OR SendToEmployeeID = '099';
PRINT N'✅ 11. [fix-4] Đã xóa tài khoản Portal test.nv & phân quyền (tblSC_Login, tblSC_Right_Stored)';

-- 12. [FIX-4] XÓA THÔNG TIN NGƯỜI PHỤ THUỘC GIẢM TRỪ GIA CẢNH (tblFamilyInfo)
DELETE FROM tblFamilyInfo 
WHERE EmployeeID = '099';
PRINT N'✅ 12. [fix-4] Đã xóa người phụ thuộc giảm trừ gia cảnh của NV 099 (tblFamilyInfo)';

-- 13. [FIX-4] XÓA LỊCH SỬ LƯƠNG & HỢP ĐỒNG LAO ĐỘNG (tblSalaryHistory, tblLabourContract)
DELETE FROM tblSalaryHistory 
WHERE EmployeeID = '099';
DELETE FROM tblLabourContract 
WHERE EmployeeID = '099';
PRINT N'✅ 13. [fix-4] Đã xóa HĐLĐ & lịch sử lương của NV 099 (tblSalaryHistory, tblLabourContract)';

-- 14. [FIX-4] XÓA PHÂN BỔ PHÒNG BAN, CHỨC VỤ & CÂY NHÂN SỰ
DELETE FROM tblDivDepSecPos 
WHERE EmployeeID = '099';
DELETE FROM tblEmployeeStatusHistory 
WHERE EmployeeID = '099';
DELETE FROM tmpEmployeeTree 
WHERE EmployeeID = '099';
PRINT N'✅ 14. [fix-4] Đã xóa phòng ban, chức vụ & cây nhân sự của NV 099';

-- 15. [FIX-4] XÓA HỒ SƠ GỐC NHÂN VIÊN 099
DELETE FROM tblEmployee 
WHERE EmployeeID = '099';
PRINT N'✅ 15. [fix-4] Đã xóa hồ sơ nhân viên 099 Nguyễn Văn Test (tblEmployee)';

PRINT N'----------------------------------------------------------------------------------';
PRINT N'🎉 HOÀN TẤT RESET DỮ LIỆU! CSDL ĐÃ SẠCH SẼ 100%, SẴN SÀNG CHẠY TEST TỪ ĐẦU!';
PRINT N'----------------------------------------------------------------------------------';
GO
