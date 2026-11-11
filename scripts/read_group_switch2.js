const fs = require('fs');
const html = fs.readFileSync('scripts/sp_List_To_Review.html', 'utf8');
console.log(html.slice(23500, 24500));
