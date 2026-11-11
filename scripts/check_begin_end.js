const fs = require('fs');
const path = require('path');

const fullSql = fs.readFileSync(path.resolve(__dirname, '../fix-bug/screenshot-5/patch_tao_mat_khau.sql'), 'utf8');
const batches = fullSql.split(/^\s*GO\s*$/im).filter(b => b.trim().length > 0);
const batch3 = batches[3];

const lines = batch3.split('\n');
let level = 0;
lines.forEach((line, idx) => {
  const trimmed = line.trim();
  // Simple check for BEGIN and END outside of strings
  const begins = (line.match(/\bBEGIN\b/gi) || []).length;
  const ends = (line.match(/\bEND\b/gi) || []).length;
  
  if (begins > 0 || ends > 0) {
    level += begins - ends;
    console.log(`Line ${idx + 1} [level=${level}]: +${begins} -${ends} | ${trimmed.substring(0, 60)}`);
  }
});

console.log('Final level (should be 0):', level);
