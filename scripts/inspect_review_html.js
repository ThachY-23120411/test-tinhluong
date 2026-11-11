const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_List_To_Review' AND LanguageID = 'VN'");
  const html = row[0].html;
  console.log('sp_List_To_Review length:', html.length);
  // Find all buttons, tables, cards, functions
  const btnMatches = html.match(/<button[^>]*>|class\s*=\s*["'][^"']*(?:approve|duyet|btn|card)[^"']*["']/gi) || [];
  console.log('Button/class matches (first 25):', btnMatches.slice(0, 25));

  // Find approve function
  const funcMatches = html.match(/function\s+\w*(?:approve|duyet|review|check|load)\w*\s*\([^)]*\)/gi) || [];
  console.log('Function matches:', funcMatches);
} catch(e) { console.error('err:', e.message); }
