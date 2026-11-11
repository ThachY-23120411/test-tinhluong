const fs = require('fs');
const html = fs.readFileSync('scripts/sp_List_To_Review.html', 'utf8');
console.log('Includes dynamic-pane:', html.includes('dynamic-pane'));
console.log('Includes sp_Overtime_Assignment:', html.includes('sp_Overtime_Assignment'));
console.log('Includes sp_overtime_assignment:', html.includes('sp_overtime_assignment'));
