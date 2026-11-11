const db = require('../helpers/db');

async function main() {
  try {
    const rows = db.query(`
      SELECT TableName, LanguageID, ScreenType, LEN(html) as HtmlLen, 
             CHARINDEX('allowColumnResizing', html) as HasResizing,
             CHARINDEX('18%', html) as Has18Pct
      FROM tblHtmlScriptCache 
      WHERE TableName LIKE '%Debt_PaymentDebt%'
    `);
    console.log('Current rows in tblHtmlScriptCache:');
    console.log(rows);

    const spCheck = db.query(`
      SELECT definition 
      FROM sys.sql_modules 
      WHERE object_id = OBJECT_ID('sp_Debt_PaymentDebt')
    `);
    console.log('Current sp_Debt_PaymentDebt:');
    console.log(spCheck[0].definition);

  } catch (err) {
    console.error('Error:', err);
  }
}

main();
