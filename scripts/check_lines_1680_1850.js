const fs = require('fs');
const path = require('path');
const origin = fs.readFileSync(path.resolve(__dirname, '../fix-bug/crm_customer_data/origin.sql'), 'utf8');

const lines = origin.split('\n');
for (let i = 1680; i < 1850; i++) {
  if (lines[i] && (lines[i].includes('resetBtn') || lines[i].includes('pill.on') || lines[i].includes('InstanceEmployeeID'))) {
    console.log(`Line ${i+1}: ${lines[i]}`);
  }
}
