-- ==============================================================================
-- BẢN VÁ SQL CHUẨN NGHIỆP VỤ: SCREENSHOT-05 (PHƯƠNG ÁN A - KHUYẾN NGHỊ)
-- Mục tiêu: ẨN MENU "TẠO MẬT KHẨU" (MnuSCR612) KHỎI CÂY "QUẢN LÝ ĐÀO TẠO"
-- Lý do nghiệp vụ:
--   1. Form [SetInitialPasswordForm] là trang kích hoạt tài khoản lần đầu qua Email (Public URL có Token).
--   2. Menu MnuSCR612 bị gán nhầm vào phân hệ Quản lý đào tạo (ParentMenuID = 'MnuTN000').
--   3. Người dùng đã đăng nhập đổi mật khẩu tại: [Avatar góc phải] -> [Đổi mật khẩu].
--   4. Việc ẩn menu này giúp hệ thống sạch sẽ, đúng phân quyền, không lộ trang công khai vào menu nội bộ.
-- Ngày tạo: 2026-10-22
-- ==============================================================================

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT '=============================================================================='
PRINT 'BẮT ĐẦU CẬP NHẬT ẨN MENU MnuSCR612 THEO CHUẨN NGHIỆP VỤ'
PRINT '=============================================================================='

BEGIN TRANSACTION
BEGIN TRY
    -- 1. KIỂM TRA HIỆN TRẠNG TRƯỚC KHI CẬP NHẬT
    IF EXISTS (SELECT 1 FROM dbo.MEN_Menu WHERE MenuID = 'MnuSCR612')
    BEGIN
        PRINT '1. Đã tìm thấy menu MnuSCR612 trong dbo.MEN_Menu.'
        
        -- Cập nhật ẩn menu khỏi cây thư mục và danh sách hiển thị
        UPDATE dbo.MEN_Menu
        SET IsVisible = 0,
            IsHiddenInTree = 1
        WHERE MenuID = 'MnuSCR612';

        PRINT '2. Đã cập nhật IsVisible = 0, IsHiddenInTree = 1 cho MenuID = ''MnuSCR612'' thành công.'
    END
    ELSE
    BEGIN
        PRINT 'CẢNH BÁO: Không tìm thấy MenuID = ''MnuSCR612'' trong bảng dbo.MEN_Menu!'
    END

    COMMIT TRANSACTION
    PRINT '=============================================================================='
    PRINT 'HOÀN TẤT BẢN VÁ: Menu MnuSCR612 đã được ẩn an toàn khỏi hệ thống Web App!'
    PRINT '=============================================================================='
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT 'LỖI TRONG QUÁ TRÌNH THỰC THI: ' + ERROR_MESSAGE()
END CATCH
GO

-- ==============================================================================
-- CÂU LỆNH KIỂM TRA LẠI SAU KHI CHẠY (VERIFICATION QUERY):
-- ==============================================================================
SELECT 
    m.MenuID,
    m.ClassName,
    m.ParentMenuID,
    m.IsVisible,
    m.IsHiddenInTree,
    l.Content AS MenuTitle_VN
FROM dbo.MEN_Menu m
LEFT JOIN dbo.tblMD_Message l ON m.MenuID = l.MessageID AND l.Language = 'VN'
WHERE m.MenuID = 'MnuSCR612';
GO

-- ==============================================================================
-- CÂU LỆNH KHÔI PHỤC (ROLLBACK SNIPPET) NẾU CẦN HIỂN THỊ LẠI MENU:
-- ==============================================================================
-- UPDATE dbo.MEN_Menu
-- SET IsVisible = 1,
--     IsHiddenInTree = 0
-- WHERE MenuID = 'MnuSCR612';
GO
