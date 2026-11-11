-- ==================================================================================
-- SCRIPT KHÔI PHỤC TÀI KHOẢN CHIEN.NGUYEN VÀ CUONG.VU TRÊN Vietinsoft_ForTest3
-- MẬT KHẨU: 123
-- MÔI TRƯỜNG: https://paradisehrm.com/Vietinsoft_ForTest3/#
-- ==================================================================================

USE Vietinsoft_ForTest3;
GO

PRINT N'🚀 ĐANG KHÔI PHỤC TÀI KHOẢN VỚI MẬT KHẨU 123 TRÊN Vietinsoft_ForTest3...';

-- 1. Khôi phục lại tài khoản chien.nguyen (Nguyễn Tấn Chiến - Kế toán trưởng, EmployeeID 013, LoginID 22)
UPDATE tblSC_Login 
SET LoginName = 'chien.nguyen', 
    EmployeeID = '013',
    PassWord = '123'
WHERE EmployeeID = '013' OR LoginID = 22;
PRINT N'✅ Đã khôi phục tài khoản chien.nguyen (mật khẩu: 123)!';

-- 2. Khôi phục lại tài khoản cuong.vu (Vũ Đình Cường - Giám đốc, EmployeeID 014, LoginID 23)
UPDATE tblSC_Login 
SET LoginName = 'cuong.vu', 
    EmployeeID = '014',
    PassWord = '123'
WHERE EmployeeID = '014' OR LoginID = 23;
PRINT N'✅ Đã khôi phục tài khoản cuong.vu (mật khẩu: 123)!';

-- 3. Xóa các bản ghi test.nv dở dang (để không đè vào ID 22, 23)
DELETE FROM tblSC_Login 
WHERE (LoginName = 'test.nv' OR EmployeeID = '099')
  AND LoginID NOT IN (22, 23);

PRINT N'----------------------------------------------------------------------------------';
PRINT N'🎉 HOÀN TẤT! Mật khẩu của cả chien.nguyen và cuong.vu đều là 123!';
GO
