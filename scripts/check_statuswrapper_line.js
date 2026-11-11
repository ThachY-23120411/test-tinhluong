const fs = require('fs');
const path = require('path');
const origin = fs.readFileSync(path.resolve(__dirname, '../fix-bug/crm_customer_data/origin.sql'), 'utf8');

const lines = origin.split('\n');
lines.forEach((l, i) => {
  if (l.includes('$statusWrapper')) {
    console.log(`Line ${i+1}: ${l}`);
  }
});
