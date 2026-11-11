const { query } = require('../helpers/db');
const fs = require('fs');
const path = require('path');

try {
  const res = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('SetInitialPasswordForm')) AS def`);
  if (res[0] && res[0].def) {
    fs.writeFileSync(path.join(__dirname, 'SetInitialPasswordForm_def.sql'), res[0].def, 'utf8');
    console.log('Saved SetInitialPasswordForm_def.sql successfully!');
  } else {
    console.log('Not found');
  }
} catch (e) {
  console.error(e.message);
}
