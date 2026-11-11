const { query } = require('../helpers/db');

try {
  const row = query(`
    SELECT html
    FROM tblHtmlScriptCache
    WHERE TableName LIKE 'LabourContract%' AND ScreenType = '-1' AND LanguageID = 'VN'
  `);
  console.log('HTML of LabourContract:');
  console.log(row[0].html);
} catch (e) {
  console.error(e.message);
}
