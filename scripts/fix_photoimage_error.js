const fs = require('fs');

let fileContent = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');

const target = `    CREATE TABLE #tblEmployeeUpdate (
        EmployeeID    VARCHAR(20),
        ImageLocation NVARCHAR(1000) NULL
    );

    IF NOT EXISTS(SELECT 1 FROM #tblEmployeeRequestChangeList WHERE FieldNameCode = 'PhotoImage')
    BEGIN
        ALTER TABLE #tblEmployeeUpdate DROP COLUMN ImageLocation;
    END`;

const replacement = `    CREATE TABLE #tblEmployeeUpdate (
        EmployeeID    VARCHAR(20),
        ImageLocation NVARCHAR(1000) NULL,
        PhotoImage    VARBINARY(MAX) NULL
    );

    IF NOT EXISTS(SELECT 1 FROM #tblEmployeeRequestChangeList WHERE FieldNameCode = 'PhotoImage')
    BEGIN
        ALTER TABLE #tblEmployeeUpdate DROP COLUMN ImageLocation;
        ALTER TABLE #tblEmployeeUpdate DROP COLUMN PhotoImage;
    END`;

if (fileContent.includes(target)) {
  fileContent = fileContent.replace(target, replacement);
  fs.writeFileSync('fix-bug/release_patches.sql', fileContent, 'utf8');
  console.log('Replaced target successfully!');
} else {
  // normalize CRLF and test
  const normalizedFile = fileContent.replace(/\r\n/g, '\n');
  const normalizedTarget = target.replace(/\r\n/g, '\n');
  const normalizedReplacement = replacement.replace(/\r\n/g, '\n');
  if (normalizedFile.includes(normalizedTarget)) {
    const res = normalizedFile.replace(normalizedTarget, normalizedReplacement);
    fs.writeFileSync('fix-bug/release_patches.sql', res.replace(/\n/g, '\r\n'), 'utf8');
    console.log('Replaced with normalized CRLF successfully!');
  } else {
    console.log('Still not found');
  }
}
