const { query } = require('../helpers/db');

async function inspectHtmlElements() {
  const screens = ['sp_ResignationLeave', 'sp_Overtime_Assignment'];
  for (const s of screens) {
    const res = await query(`
      SELECT TOP 1 html
      FROM tblHtmlScriptCache
      WHERE TableName = '${s}' AND LanguageID = 'VN'
    `);
    if (res.length > 0 && res[0].html) {
      const html = res[0].html;
      console.log(`\n=================== ${s} ===================`);
      // Find input IDs and button IDs
      const inputMatches = html.match(/id="([a-zA-Z0-9_-]+)"/g) || [];
      console.log('Sample IDs:', inputMatches.slice(0, 30));
      
      // Look for buttons or submit functions
      const btnMatches = html.match(/<button[^>]+>[\s\S]*?<\/button>/gi) || [];
      console.log('Buttons:', btnMatches.slice(0, 10).map(b => b.replace(/\s+/g, ' ')));
    }
  }
}

inspectHtmlElements();
