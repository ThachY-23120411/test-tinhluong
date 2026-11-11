const fs = require('fs');
const html = fs.readFileSync('scripts/current_cache_versiondata.html', 'utf8');
const lines = html.split('\n');
console.log(lines.slice(1835, 1905).join('\n'));
