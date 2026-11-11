const fs = require('fs');

let content = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');

// 1. Remove PATCH 08 from header
const headerPatch08 = "\n      - PATCH 08: [thanh_toan_cong_no / MnuPRL409] Sửa lỗi DataGrid không responsive & chiều ngang cột không đồng đều trong sp_Debt_PaymentDebt_html";
content = content.replace(headerPatch08, '');

// 2. Remove PATCH 08 block at the bottom
const patch08Index = content.indexOf("/*==================================================================================================\n  PATCH 08:");
const altPatch08Index = content.indexOf("/*==================================================================================================\n  PARADISE HRM - PATCH: MENU THANH TOÁN CÔNG NỢ");
const cutIndex = patch08Index !== -1 ? patch08Index : altPatch08Index;

const footerMarker = "/*==================================================================================================\n  KẾT THÚC MASTER RELEASE PATCH SCRIPT\n==================================================================================================*/\n";

if (cutIndex !== -1) {
  content = content.slice(0, cutIndex) + footerMarker;
  console.log('Removed PATCH 08 block successfully!');
}

// 3. Revert PATCH 04 #tblEmployeeUpdate changes
const newTblDef = `    CREATE TABLE #tblEmployeeUpdate (
        EmployeeID    VARCHAR(20),
        ImageLocation NVARCHAR(1000) NULL,
        PhotoImage    VARBINARY(MAX) NULL
    );

    IF NOT EXISTS(SELECT 1 FROM #tblEmployeeRequestChangeList WHERE FieldNameCode = 'PhotoImage')
    BEGIN
        ALTER TABLE #tblEmployeeUpdate DROP COLUMN ImageLocation;
        ALTER TABLE #tblEmployeeUpdate DROP COLUMN PhotoImage;
    END`;

const oldTblDef = `    CREATE TABLE #tblEmployeeUpdate (
        EmployeeID    VARCHAR(20),
        ImageLocation NVARCHAR(1000) NULL
    );

    -- Nếu không có PhotoImage thì xóa cột ImageLocation
    IF NOT EXISTS(SELECT 1 FROM #tblEmployeeRequestChangeList WHERE FieldNameCode = 'PhotoImage')
    BEGIN
        ALTER TABLE #tblEmployeeUpdate DROP COLUMN ImageLocation;
    END`;

// Try both with/without comment
if (content.includes(newTblDef)) {
  content = content.replace(newTblDef, oldTblDef);
  console.log('Reverted #tblEmployeeUpdate definition!');
} else {
  // Let's check partial
  const partNew = `    CREATE TABLE #tblEmployeeUpdate (\n        EmployeeID    VARCHAR(20),\n        ImageLocation NVARCHAR(1000) NULL,\n        PhotoImage    VARBINARY(MAX) NULL\n    );`;
  const partOld = `    CREATE TABLE #tblEmployeeUpdate (\n        EmployeeID    VARCHAR(20),\n        ImageLocation NVARCHAR(1000) NULL\n    );`;
  if (content.includes(partNew)) {
    content = content.replace(partNew, partOld);
    content = content.replace("ALTER TABLE #tblEmployeeUpdate DROP COLUMN PhotoImage;\n", "");
    console.log('Reverted partial #tblEmployeeUpdate!');
  }
}

const newAlterCol = `            SELECT @AlterColumns += ', ' + FieldNameCode + ' NVARCHAR(500)'
            FROM (
                SELECT DISTINCT FieldNameCode 
                FROM #tblEmployeeRequestChangeList 
                WHERE Approve = 1 AND FieldNameCode NOT IN ('PhotoImage', 'ImageLocation')
            ) d;`;

const oldAlterCol = `            SELECT @AlterColumns += ', ' + FieldNameCode +
                   CASE WHEN FieldNameCode = 'PhotoImage' THEN ' VARBINARY(MAX)' ELSE ' NVARCHAR(500)' END
            FROM (
                SELECT DISTINCT FieldNameCode 
                FROM #tblEmployeeRequestChangeList 
                WHERE Approve = 1
            ) d;`;

if (content.includes(newAlterCol)) {
  content = content.replace(newAlterCol, oldAlterCol);
  console.log('Reverted @AlterColumns!');
}

fs.writeFileSync('fix-bug/release_patches.sql', content, 'utf8');

const lines = content.split('\n');
console.log('Restored file length:', content.length, 'lines:', lines.length);
console.log('Header snippet:\n' + lines.slice(8, 20).join('\n'));
console.log('Last lines:\n' + lines.slice(-25).join('\n'));
