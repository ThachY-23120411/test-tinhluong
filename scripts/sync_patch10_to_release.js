const fs = require('fs');
const path = require('path');

const releasePath = path.resolve(__dirname, '../fix-bug/release_patches.sql');
const fixBugPath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-bug.sql');

let releaseContent = fs.readFileSync(releasePath, 'utf8');
const fixBugContent = fs.readFileSync(fixBugPath, 'utf8');

// Strip trailing incomplete comments at end of releaseContent if present
const trailingCommentIdx = releaseContent.indexOf('-- BẢN VÁ TỔNG HỢP (PATCH SCRIPT) CHO MÀN HÌNH: SẢN PHẨM MARKETING', 5400);
if (trailingCommentIdx !== -1) {
  releaseContent = releaseContent.substring(0, trailingCommentIdx).trimEnd() + '\n\n';
}

// Remove any existing PATCH 10 block if previously appended
const patch10Idx = releaseContent.indexOf('PATCH 10: [sp_KPIContentPost_html]');
if (patch10Idx !== -1 && patch10Idx > 100) {
  releaseContent = releaseContent.substring(0, patch10Idx).trimEnd() + '\n\n';
}

const patch10Header = `
-- ===================================================================
-- PATCH 10: [sp_KPIContentPost_html] & [sp_KPIContentPost]
-- Phân hệ: Trang chủ CRM > Nhiệm vụ > Nội dung đăng tải (MnuKPI005)
-- Database: Vietinsoft_ForTest_Tai2
-- Lỗi đã sửa:
--   Screenshot 27:
--     1. Đưa các checkbox (%ViewAllDays%, Chỉ xem của tôi) lên cùng một hàng ngang với các bộ lọc (Nhân viên, Từ ngày, Đến ngày, Làm mới).
--     2. Đưa nút "Thêm nội dung" từ khối header độc lập bên trên xuống tích hợp vào thanh toolbar (after) ngang hàng với filter.
--     3. Bổ sung responsive flex-wrap: wrap và CSS chuẩn hóa để khi co hẹp màn hình, các phần tử tự động xuống hàng một cách mượt mà, không đè lấn lên nhau.
-- Chuẩn hóa: 3 Bước Clean Code không dùng REPLACE theo quy chuẩn fix-rules
-- ===================================================================

`;

// Extract content from fixBugContent (excluding initial USE statement to maintain clean single-file batch)
let sqlToAppend = fixBugContent;
const useIdx = sqlToAppend.indexOf('ALTER PROCEDURE [dbo].[sp_KPIContentPost_html]');
if (useIdx !== -1) {
  sqlToAppend = sqlToAppend.substring(useIdx);
}

const fullUpdatedRelease = releaseContent.trimEnd() + '\n\n' + patch10Header + sqlToAppend.trimEnd() + '\nGO\n';

fs.writeFileSync(releasePath, fullUpdatedRelease, 'utf8');
console.log('Successfully synced PATCH 10 to release_patches.sql');
