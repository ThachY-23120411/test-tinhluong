const { query } = require('../helpers/db');

try {
  const res = query(`EXEC sp_CRM_EmailKPIFollow @LoginID = 3, @LanguageID = 'VN'`);
  const html = res[0].html;
  const lines = html.split('\n');

  lines.forEach((l, idx) => {
    if (l.includes('%ColumnNameSync%')) {
      console.log(`Line ${idx + 1}: ${l}`);
      // In 3 dòng trước và sau
      for (let j = Math.max(0, idx - 3); j <= Math.min(lines.length - 1, idx + 3); j++) {
        console.log(`  ${j + 1}: ${lines[j]}`);
      }
    }
  });
} catch (e) {
  console.error(e.message);
}
