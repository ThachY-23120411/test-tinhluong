const { query } = require('../helpers/db');

try {
  const row = query("SELECT TableName, LanguageID, LEN(html) as htmllen FROM tblHtmlScriptCache WHERE TableName = 'sp_List_To_Review'");
  console.log('sp_List_To_Review in cache:', row);
} catch(e) { console.error('err:', e.message); }
