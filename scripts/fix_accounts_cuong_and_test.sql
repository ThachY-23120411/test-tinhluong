-- ==================================================================================
-- SCRIPT KHÔI PHỤC TÀI KHOẢN CUONG.VU & TẠO RIÊNG TÀI KHOẢN TEST.NV CHO NV 099
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MÔI TRƯỜNG: Vietinsoft_ForTest_Tai
-- ==================================================================================

USE Vietinsoft_ForTest_Tai;
GO

PRINT N'🚀 BẮT ĐẦU KHÔI PHỤC TÀI KHOẢN ADMIN & TẠO USER TEST.NV...';

-- 1. Khôi phục lại tài khoản cuong.vu cho LoginID = 23 (Vũ Đình Cường - Giám đốc)
UPDATE tblSC_Login 
SET LoginName = 'cuong.vu', EmployeeID = '014'
WHERE LoginID = 23;
PRINT N'✅ 1. Đã khôi phục thành công tài khoản cuong.vu (LoginID 23)!';

-- 2. Dọn dẹp bản ghi test.nv nếu có phát sinh trùng
DELETE FROM tblSC_Login 
WHERE (LoginName = 'test.nv' OR EmployeeID = '099') AND LoginID <> 23;

-- 3. Tạo mới riêng 1 tài khoản đăng nhập cho nhân viên mới 099 (test.nv / 123)
INSERT INTO tblSC_Login (LoginName, PassWord, EmployeeID, LastChangedDate, AdminRight, IsActive)
VALUES (
    'test.nv', 
    '3C9909AFEC25354D551DAE21590BB26E38D53F2173B8D3DC3EEE4C047E7AB1C1EB8B85103E3BE7BA613B31BB5C9C36214DC9F14A42FD7A2FDB84856BCA5C44C2', 
    '099', 
    GETDATE(), 
    0, 
    1
);
PRINT N'✅ 2. Đã tạo mới thành công tài khoản test.nv (mật khẩu 123) gắn với NV 099!';

PRINT N'----------------------------------------------------------------------------------';
PRINT N'🎉 HOÀN TẤT! cuong.vu và test.nv đã sẵn sàng hoạt động độc lập!';
GO
