const fs = require('fs');
const content = fs.readFileSync('scripts/lock_html.sql', 'utf8');
const lines = content.split('\n');
lines.forEach((l, idx) => {
    if (l.includes('lock') || l.includes('unlock') || l.includes('Khóa') || l.includes('Mở khóa') || l.includes('AjaxHPAParadise')) {
        console.log(`Line ${idx+1}: ${l.trim().substring(0, 100)}`);
    }
});
