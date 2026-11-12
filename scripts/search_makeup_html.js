const fs = require('fs');
const content = fs.readFileSync('scripts/sp_MakeupHours_html.sql', 'utf-8');
const lines = content.split('\n');

console.log('Total lines in sp_MakeupHours_html.sql:', lines.length);

lines.forEach((l, idx) => {
  if (l.includes('btnApprove') || l.includes('modalApproveAttendanceRequest') || l.includes('btnApproveModalRemake') || l.includes('HandleApproveAttendanceRequest')) {
    console.log((idx + 1) + ': ' + l.trim());
  }
});
