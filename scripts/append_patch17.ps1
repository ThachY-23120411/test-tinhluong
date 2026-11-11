$masterPath = "fix-bug/release_patches.sql"
$patchPath = "fix-bug/crm_quan_ly_phan_he/fix-bug.sql"

$patchContent = [System.IO.File]::ReadAllText($patchPath, [System.Text.Encoding]::UTF8)

# Header banner for Patch 17
$banner = @"

-- ============================================================================
-- PATCH 17: [sp_Sub_SubProduct_html] & [sp_Sub_SubProduct]
-- PHÂN HỆ: Trang Chủ CRM > Báo giá > Quản lý phân hệ (MnuCSM003)
-- DATABASE: Vietinsoft_ForTest_Tai2
-- ÁP DỤNG BỘ 9 NHÓM QUY TẮC BẤT BIẾN /responsive-rules & CLEAN CODE 3 BƯỚC:
--   1. Master Layout Lock: Khóa max-width 1920px, canh giữa margin: 0 auto.
--   2. Normal Document Flow: Triệt tiêu 100% lỗi DataGrid che khuất Toolbar (height: auto, position: static).
--   3. Sibling Flattening: display: contents trên .dx-toolbar-before.
--   4. Right-to-Left Wrapping: margin-left: auto trên .dx-toolbar-after.
--   5. Atomic Text Lock: Khóa nguyên tử flex-shrink: 0 & white-space: nowrap cho nút '+ Thêm phân hệ'.
--   6. SỬA LỖI SEARCHBOX: Lùi lề trái 34px chống icon kính lúp đè lên chữ text & placeholder 'Tìm kiếm theo nội dung'.
--   7. Cô lập cuộn Bảng dữ liệu lớn: overflow-x: auto trên DataGrid headers & rowsview.
-- ============================================================================
"@

$combined = "`r`n`r`n" + $banner + "`r`n" + $patchContent.Trim() + "`r`n"
[System.IO.File]::AppendAllText($masterPath, $combined, [System.Text.Encoding]::UTF8)
Write-Host "Appended Patch 17 to release_patches.sql successfully."
