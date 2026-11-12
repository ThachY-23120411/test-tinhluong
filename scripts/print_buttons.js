const fs = require('fs');
const content = fs.readFileSync('scripts/sp_MakeupHours_html.sql', 'utf-8');
const lines = content.split('\n');

for (let i = 600; i < 750; i++) {
  if (lines[i].includes('btnApprove') || lines[i].includes('btnReject') || lines[i].includes('btnRegister') || lines[i].includes('btnCancel')) {
    console.log((i + 1) + ': ' + lines[i]);
  }
}
