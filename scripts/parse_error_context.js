const fs = require('fs');
const content = fs.readFileSync('test-results/cham_cong_tinh_luong_crud_-a14a6-ng-cá-nhân-E2E-Master-Flow--Google-Chrome/error-context.md', 'utf8');
const lines = content.split('\n');
lines.slice(0, 100).forEach((l, i) => {
  if (l.includes('heading') || l.includes('paragraph') || l.includes('button') || l.includes('text:') || l.includes('tab')) {
    console.log(`${i}: ${l}`);
  }
});
