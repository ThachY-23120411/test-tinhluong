const { query } = require('../helpers/db');

try {
  const res = query(`
    SELECT TableName, LanguageID, Version, CHECKSUM(html) as NewChecksum 
    FROM tblHtmlScriptCache 
    WHERE TableName LIKE '%Debt%'
  `);
  console.log('Checksum comparison:');
  console.log(JSON.stringify(res, null, 2));
} catch (e) {
  console.error(e.message);
}
