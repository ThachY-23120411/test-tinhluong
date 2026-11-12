-- ==================================================================================
-- SCRIPT RESET DỮ LIỆU TEST NHÂN VIÊN 099 (ROLLBACK VỀ TRẠNG THÁI SẠCH BAN ĐẦU)
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MÔI TRƯỜNG: Chạy được trên cả Vietinsoft_ForTest3, Vietinsoft_ForTest_Tai2, Vietinsoft_ForTest_Tai
-- MỤC ĐÍCH: 
--   1. Tự động bảo vệ & khôi phục tài khoản quản trị (cuong.vu, chien.nguyen) nếu bị ghi đè.
--   2. Xóa sạch 100% dữ liệu phát sinh của NV 099 từ hồ sơ, ca làm, phép, công đến bảng lương.
--   3. Mở khóa sổ kỳ lương Tháng 10/2026 để lần test sau chạy lại thông suốt từ đầu.
-- AN TOÀN: Chỉ tác động đúng EmployeeID = '099', TUYỆT ĐỐI KHÔNG ẢNH HƯỞNG NHÂN VIÊN KHÁC!
-- ==================================================================================

-- Ghi chú: Nếu cần chuyển DB trong SSMS, hãy bỏ comment dòng USE tương ứng:
-- USE Vietinsoft_ForTest3;
-- USE Vietinsoft_ForTest_Tai2;
-- GO

PRINT N'🚀 BẮT ĐẦU RESET TOÀN DIỆN DỮ LIỆU TEST CHO NHÂN VIÊN 099...';

-- 0. BẢO VỆ TÀI KHOẢN QUẢN TRỊ (Đề phòng bị giao diện MnuSCR608 ghi đè)
UPDATE tblSC_Login 
SET LoginName = 'cuong.vu', PassWord = '123', IsDisable = 0 
WHERE EmployeeID = '014';

UPDATE tblSC_Login 
SET LoginName = 'chien.nguyen', PassWord = '123', IsDisable = 0 
WHERE EmployeeID = '013';
PRINT N'🛡️ 0. Đã bảo đảm an toàn tài khoản quản trị (cuong.vu, chien.nguyen)';

-- 1. Mở khóa sổ kỳ lương Tháng 10/2026 của riêng NV 099 (để tính lương & khóa sổ lại được)
DELETE FROM tblSal_Lock 
WHERE EmployeeID = '099';
PRINT N'✅ 1. Đã mở khóa sổ kỳ lương của NV 099 (tblSal_Lock)';

-- 2. Xóa bảng lương chi tiết & bảng lương tổng hợp của 099
DELETE FROM tblSal_Sal_Detail 
WHERE EmployeeID = '099';
DELETE FROM tblSal_Sal 
WHERE EmployeeID = '099';
PRINT N'✅ 2. Đã xóa kết quả tính lương chi tiết của NV 099 (tblSal_Sal & tblSal_Sal_Detail)';

-- 3. Xóa dữ liệu Tạm ứng lương của 099
DELETE FROM tblSal_Advance 
WHERE EmployeeID = '099';
PRINT N'✅ 3. Đã xóa dữ liệu tạm ứng lương của NV 099 (tblSal_Advance)';

-- 4. Xóa đơn xin bù công / giải trình đi trễ về sớm của 099
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
PRINT N'✅ 4. Đã xóa đơn xin bù công / đi trễ của NV 099 (tblAttendanceConfirmRequest, tblInLateOutEarly)';

-- 5. Xóa đơn xin nghỉ phép năm AL, lịch sử ngày nghỉ & hạn mức phép của 099
DELETE FROM tblLeaveRegistered_Detail WHERE EmployeeID = '099';
DELETE FROM tblLeaveRegistered WHERE EmployeeID = '099';
DELETE FROM tblLvHistory WHERE EmployeeID = '099';
DELETE FROM tblEmployeeAnnual WHERE EmployeeID = '099';
PRINT N'✅ 5. Đã xóa đơn nghỉ phép, lịch sử nghỉ & hạn mức phép của NV 099 (tblLeaveRegistered, tblLvHistory, tblEmployeeAnnual)';

-- 6. Xóa đơn xin làm thêm giờ OT của 099
DELETE FROM tblOvertime_Assignment_Detail 
WHERE EmployeeID = '099';
DELETE FROM tblOTList 
WHERE EmployeeID = '099';
DELETE FROM tblotregistration 
WHERE EmployeeID = '099';
DELETE FROM tblOTRegistration_Web 
WHERE EmployeeID = '099';
PRINT N'✅ 6. Đã xóa đơn xin tăng ca OT của NV 099 (tblOvertime_Assignment_Detail, tblOTList, tblotregistration, tblOTRegistration_Web)';

-- 7. Xóa dữ liệu quẹt thẻ chấm công phát sinh của 099
DELETE FROM tblHasTA 
WHERE EmployeeID = '099';
PRINT N'✅ 7. Đã xóa sạch dữ liệu quẹt thẻ/công của NV 099 (tblHasTA)';

-- 8. Xóa phân ca làm việc hành chính (MnuATT101) của 099
DELETE FROM tblShiftGroupByEmployee 
WHERE EmployeeID = '099';
PRINT N'✅ 8. Đã xóa phân ca làm việc của NV 099 (tblShiftGroupByEmployee)';

-- 8b. Xóa thiết lập tuyến người duyệt của NV 099 (tblApprovalLineByEmployee)
DELETE FROM tblApprovalLineByEmployee 
WHERE EmployeeID = '099';
PRINT N'✅ 8b. Đã xóa tuyến người duyệt của NV 099 (tblApprovalLineByEmployee)';

-- 9. Xóa tài khoản đăng nhập ESS Portal test.nv & quyền menu
DELETE FROM tblSC_Right_Stored 
WHERE LoginID IN (SELECT LoginID FROM tblSC_Login WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014'));

DELETE FROM tblSC_Login 
WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND EmployeeID NOT IN ('013', '014');

DELETE FROM tblEmailList 
WHERE EmployeeID = '099' OR SendToEmployeeID = '099';
PRINT N'✅ 9. Đã xóa sạch tài khoản ESS Portal test.nv & quyền truy cập (tblSC_Login, tblSC_Right_Stored)';

-- 10. Xóa thông tin Người phụ thuộc giảm trừ gia cảnh của 099
DELETE FROM tblFamilyInfo 
WHERE EmployeeID = '099';
PRINT N'✅ 10. Đã xóa người phụ thuộc giảm trừ gia cảnh của NV 099 (tblFamilyInfo)';

-- 11. Xóa lịch sử lương & hợp đồng lao động của 099
DELETE FROM tblSalaryHistory 
WHERE EmployeeID = '099';
DELETE FROM tblLabourContract 
WHERE EmployeeID = '099';
PRINT N'✅ 11. Đã xóa hợp đồng lao động & mức lương của NV 099 (tblSalaryHistory, tblLabourContract)';

-- 12. Xóa phân bổ phòng ban & chức vụ của 099
DELETE FROM tblDivDepSecPos 
WHERE EmployeeID = '099';
PRINT N'✅ 12. Đã xóa phòng ban & chức vụ của NV 099 (tblDivDepSecPos)';

-- 12b. Xóa trạng thái làm việc & cây nhân sự của 099
DELETE FROM tblEmployeeStatusHistory 
WHERE EmployeeID = '099';
DELETE FROM tmpEmployeeTree 
WHERE EmployeeID = '099';
PRINT N'✅ 12b. Đã xóa trạng thái làm việc & cây nhân sự của NV 099 (tblEmployeeStatusHistory, tmpEmployeeTree)';

-- 13. Xóa hồ sơ nhân viên gốc 099
DELETE FROM tblEmployee 
WHERE EmployeeID = '099';
PRINT N'✅ 13. Đã xóa hồ sơ nhân viên 099 Nguyễn Văn Test (tblEmployee)';

PRINT N'-------------------------------------------------------------------------';
PRINT N'🎉 HOÀN TẤT RESET DỮ LIỆU! CSDL ĐÃ SẠCH SẼ 100%, SẴN SÀNG CHẠY TEST MỚI TỪ ĐẦU!';
GO
