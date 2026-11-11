-- ==================================================================================
-- SCRIPT KHÔI PHỤC CUONG.VU & DỌN SẠCH TEST.NV TRÊN CẢ 2 DATABASE (TAI & TAI2)
-- ==================================================================================

-- 1. XỬ LÝ TRÊN DATABASE Vietinsoft_ForTest_Tai (Môi trường https://paradisehrm.com/Tai2/#)
USE Vietinsoft_ForTest_Tai;
GO

UPDATE tblSC_Login 
SET LoginName = 'cuong.vu', EmployeeID = '014' 
WHERE LoginID = 23;

DELETE FROM tblSC_Login 
WHERE LoginName = 'test.nv' OR EmployeeID = '099';

PRINT N'✅ 1. Đã khôi phục cuong.vu và xóa sạch test.nv trên Vietinsoft_ForTest_Tai!';
GO

-- 2. XỬ LÝ TRÊN DATABASE Vietinsoft_ForTest_Tai2 (Môi trường https://paradisehrm.com/Tai3/#)
USE Vietinsoft_ForTest_Tai2;
GO

UPDATE tblSC_Login 
SET LoginName = 'cuong.vu', EmployeeID = '014' 
WHERE LoginID = 23;

DELETE FROM tblSC_Login 
WHERE LoginName = 'test.nv' OR EmployeeID = '099';

PRINT N'✅ 2. Đã khôi phục cuong.vu và xóa sạch test.nv trên Vietinsoft_ForTest_Tai2!';
PRINT N'🎉 HOÀN TẤT TRÊN CẢ 2 MÔI TRƯỜNG! BÂY GIỜ BẠN LƯU TEST.NV TRÊN WEB SẼ 100% THÀNH CÔNG!';
GO
