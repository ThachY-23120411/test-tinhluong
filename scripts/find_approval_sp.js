const { query } = require('../helpers/db');

try {
  const m = query("SELECT MenuID, ClassName FROM MEN_Menu WHERE MenuID = 'MnuWPT037'");
  console.log('MnuWPT037 in MEN_Menu:', m);
} catch(e) { console.error('err:', e.message); }

try {
  const c = query("SELECT TableName, ScreenType, LanguageID, LEN(html) as htmllen FROM tblHtmlScriptCache WHERE TableName LIKE '%WPT037%' OR TableName LIKE '%Approv%'");
  console.log('tblHtmlScriptCache matches:', c);
} catch(e) { console.error('err2:', e.message); }
