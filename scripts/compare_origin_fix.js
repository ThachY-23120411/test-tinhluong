const fs = require('fs');
const path = require('path');
const origin = fs.readFileSync(path.resolve(__dirname, '../fix-bug/crm_customer_data/origin.sql'), 'utf8');
const fix = fs.readFileSync(path.resolve(__dirname, '../fix-bug/crm_customer_data/fix-bug.sql'), 'utf8');

console.log('Origin length:', origin.length);
console.log('Fix length:', fix.length);

// What differences exist?
// Let's check occurrences of toUpperCase in origin vs fix
function countMatches(str, term) {
  let count = 0, pos = 0;
  while ((pos = str.indexOf(term, pos)) !== -1) { count++; pos += term.length; }
  return count;
}

console.log('Origin toUpperCase count:', countMatches(origin, 'toUpperCase'));
console.log('Fix toUpperCase count:', countMatches(fix, 'toUpperCase'));
