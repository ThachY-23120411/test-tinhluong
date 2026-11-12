-- ==============================================================================
-- SCRIPT: THIẾT LẬP TUYẾN DUYỆT ĐƠN (APPROVAL LINE) CHO NHÂN VIÊN 099
-- DỰ ÁN: FLOW LIÊN HOÀN TÍNH LƯƠNG NHÂN VIÊN MỚI (E2E NEW EMPLOYEE PAYROLL)
-- MỤC ĐÍCH:
--   1. Khắc phục lỗi "Chưa thiết lập người duyệt vui lòng kiểm tra lại!" khi mở MnuWPT316 (Xin tăng ca)
--   2. Đảm bảo 3 loại đơn ESS (Bù công, Nghỉ phép, Tăng ca) của NV 099 có người duyệt:
--      - Group 1 (Nghỉ phép AL): Cấp 1 là 004 (ThanhLong), Cấp 2 là 012/014
--      - Group 5 (Bù công): Cấp 1 là 004 (ThanhLong), Cấp 2 là 012/014
--      - Group 6 (Tăng ca OT): Cấp 1 là 012 (LongKa), Cấp 2 là 014 (cuong.vu)
--   3. Đồng bộ tuyến duyệt cho fix-6 tiến hành Phê duyệt đa cấp
-- ==============================================================================

PRINT N'🚀 ĐANG THIẾT LẬP TUYẾN DUYỆT CHO NHÂN VIÊN 099 (NGUYỄN VĂN TEST)...';

-- 1. Xóa cấu hình cũ (nếu có)
DELETE FROM tblApprovalLineByEmployee WHERE EmployeeID = '099';

-- 2. Kế thừa toàn bộ tuyến duyệt chuẩn từ nhân viên mẫu 001
INSERT INTO tblApprovalLineByEmployee (
    EmployeeID,
    Approvalgrouplist,
    Approver_1,
    Delegacy_1,
    Approver_2,
    Delegacy_2,
    Approver_3,
    Delegacy_3,
    Approver_4,
    Delegacy_4,
    IsDelegacyView
)
SELECT 
    '099',
    Approvalgrouplist,
    Approver_1,
    Delegacy_1,
    Approver_2,
    Delegacy_2,
    Approver_3,
    Delegacy_3,
    Approver_4,
    Delegacy_4,
    IsDelegacyView
FROM tblApprovalLineByEmployee
WHERE EmployeeID = '001';

-- 3. Trường hợp nếu tblApprovalLineByEmployee của 001 không có, tự động insert trực tiếp các nhóm cốt lõi
IF NOT EXISTS (SELECT 1 FROM tblApprovalLineByEmployee WHERE EmployeeID = '099' AND Approvalgrouplist = 6)
BEGIN
    INSERT INTO tblApprovalLineByEmployee (EmployeeID, Approvalgrouplist, Approver_1, Approver_2)
    VALUES 
        ('099', 6, '012', '014'), -- Tăng ca OT: Cấp 1 LongKa (012) -> Cấp 2 cuong.vu (014)
        ('099', 1, '004', '014'), -- Nghỉ phép AL: Cấp 1 ThanhLong (004) -> Cấp 2 cuong.vu (014)
        ('099', 5, '004', '014'); -- Bù công: Cấp 1 ThanhLong (004) -> Cấp 2 cuong.vu (014)
END

PRINT N'✅ ĐÃ THIẾT LẬP HOÀN TẤT TUYẾN DUYỆT CHO NHÂN VIÊN 099!';

-- 4. Đối soát kết quả vừa thêm
SELECT 
    EmployeeID, 
    Approvalgrouplist, 
    Approver_1, 
    Approver_2, 
    Delegacy_1, 
    Delegacy_2 
FROM tblApprovalLineByEmployee 
WHERE EmployeeID = '099'
ORDER BY Approvalgrouplist;
GO
