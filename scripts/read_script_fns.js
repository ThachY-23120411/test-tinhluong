const fs = require('fs');

const content = fs.readFileSync('scripts/script_75264.js', 'utf-8');
const lines = content.split('\n');

console.log('Total lines in script_75264.js:', lines.length);

function printLines(start, end) {
  for (let i = Math.max(0, start - 1); i < Math.min(lines.length, end); i++) {
    console.log(`${i + 1}: ${lines[i]}`);
  }
}

console.log('=== lines 990 - 1070 (checkApprovalPermission, ApproveAttendanceRequest) ===');
printLines(990, 1070);

console.log('\n=== lines 1071 - 1170 (HandleApproveAttendanceRequest) ===');
printLines(1071, 1170);
