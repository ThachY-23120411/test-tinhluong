const fs = require('fs');
const html = fs.readFileSync('scripts/sp_List_To_Review.html', 'utf8');
const idx = html.indexOf('cardregistered');
console.log(html.slice(Math.max(0, idx - 400), idx + 600));
