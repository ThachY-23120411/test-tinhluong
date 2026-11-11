const { query } = require('../helpers/db');

try {
  const cnt = query(`SELECT COUNT(*) as total FROM tblMD_Message`);
  console.log('Total in tblMD_Message:', cnt[0].total);
} catch (e) {
  console.error(e.message);
}
