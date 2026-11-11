const fs = require('fs');
const orig = fs.readFileSync('scripts/orig_tai_sp_def.sql', 'utf8');

console.log('Original length:', orig.length);

// Check section 1: Top bar
const topBarMatch = orig.match(/<div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;padding:8px 8px 0px 8px;margin-bottom:8px;flex-shrink:0;">[\s\S]*?<\/div>/);
console.log('Top bar match:', topBarMatch ? topBarMatch[0] : 'NOT FOUND');

// Check section 2: loadData
const loadDataMatch = orig.match(/\+ ISNULL\(\(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @MonthUID\), N''\)[\s\S]*?\+ ISNULL\(\(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @YearUID\), N''\)/);
console.log('loadData match:', loadDataMatch ? loadDataMatch[0] : 'NOT FOUND');

// Check section 3: noDataText
const noDataMatch = orig.match(/g\.option\("noDataText", ".*?"\);/);
console.log('noDataText match:', noDataMatch ? noDataMatch[0] : 'NOT FOUND');

// Check section 4: End of script
const endScriptMatch = orig.match(/if \(typeof InstanceMonth' \+ @MonthUID[\s\S]*?forceGridReload\(\);\s*\}\);/);
console.log('End script match:', endScriptMatch ? endScriptMatch[0] : 'NOT FOUND');
