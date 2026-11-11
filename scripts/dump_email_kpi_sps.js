const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const spHtml = query(`
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_CRM_EmailKPIFollow_html')) as def
  `);
  if (spHtml && spHtml[0] && spHtml[0].def) {
    fs.writeFileSync('scripts/sp_CRM_EmailKPIFollow_html.sql', spHtml[0].def, 'utf8');
    console.log('Saved sp_CRM_EmailKPIFollow_html.sql, length:', spHtml[0].def.length);
  }

  const spData = query(`
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_CRM_EmailKPIFollow')) as def
  `);
  if (spData && spData[0] && spData[0].def) {
    fs.writeFileSync('scripts/sp_CRM_EmailKPIFollow.sql', spData[0].def, 'utf8');
    console.log('Saved sp_CRM_EmailKPIFollow.sql, length:', spData[0].def.length);
  }

  // Xem html trong cache
  const cacheVN = query(`
    SELECT CAST([html] AS NVARCHAR(MAX)) as html
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_CRM_EmailKPIFollow' AND LanguageID = 'VN'
  `);
  if (cacheVN && cacheVN[0] && cacheVN[0].html) {
    fs.writeFileSync('scripts/cache_sp_CRM_EmailKPIFollow.html', cacheVN[0].html, 'utf8');
    console.log('Saved cache_sp_CRM_EmailKPIFollow.html, length:', cacheVN[0].html.length);
  }
} catch (e) {
  console.error('Error:', e.message);
}
