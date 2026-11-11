const db = require('../helpers/db');
const matches = db.query("SELECT TableName, LanguageID FROM tblHtmlScriptCache WHERE html LIKE N'%Tính tiền lương%' OR html LIKE N'%dự đoán quỹ lương%'");
console.log('Matches in tblHtmlScriptCache:', matches);
