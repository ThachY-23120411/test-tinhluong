const fs = require('fs');
const content = fs.readFileSync('scripts/SALCAL_MAIN.sql', 'utf8');
const lines = content.split('\n');
lines.forEach((l, idx) => {
    if (l.includes('tblHasTA') || l.includes('tblEmployee') || l.includes('fn_vtblEmployeeList') || l.includes('tblProcessErrorMessage') || l.includes('SELECT') && l.includes('INTO #tblEmployee')) {
        console.log(`Line ${idx+1}: ${l.trim().substring(0, 100)}`);
    }
});
