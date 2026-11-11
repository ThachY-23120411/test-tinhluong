const fs = require('fs');
const path = require('path');

const fullSql = fs.readFileSync(path.resolve(__dirname, '../fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql'), 'utf8')
  .replace(/^\uFEFF/, '');

const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);
const idx = batches[3].indexOf('ALTER PROCEDURE');
console.log('Index of ALTER PROCEDURE:', idx);
const before = batches[3].substring(idx - 20, idx);
console.log('Chars immediately before ALTER PROCEDURE:');
for (let i = 0; i < before.length; i++) {
  console.log(i, JSON.stringify(before[i]), before.charCodeAt(i).toString(16));
}
