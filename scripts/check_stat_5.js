const fs = require('fs');

console.log('img1_tabs.png size:', fs.statSync('scripts/img1_tabs.png').size);
console.log('img1_center_box.png size:', fs.statSync('scripts/img1_center_box.png').size);
console.log('img1_left_menu.png size:', fs.statSync('scripts/img1_left_menu.png').size);
