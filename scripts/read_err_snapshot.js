const fs = require('fs');
const content = fs.readFileSync('test-results/cham_cong_tinh_luong_crud_-a14a6-ng-cá-nhân-E2E-Master-Flow--Google-Chrome/error-context.md', 'utf8');
console.log(content.slice(0, 1500));
