const fs = require('fs');
const path = require('path');

const fullSql = fs.readFileSync(path.resolve(__dirname, '../fix-bug/screenshot-5/patch_tao_mat_khau.sql'), 'utf8');
const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);
const batch3 = batches[3];
const lines = batch3.split('\n');

for (let i = 790; i < 820; i++) {
  if (lines[i]) {
    console.log(`${i + 1}: ${lines[i]}`);
  }
}
