const db = require('../helpers/db');
const cache = db.query("SELECT TableName, ScreenType, LanguageID, LEN(html) as lenHtml FROM tblHtmlScriptCache WHERE TableName LIKE '%PRL040%' OR TableName LIKE '%SALCAL%' OR TableName LIKE '%Salary%'");
console.log(cache);
