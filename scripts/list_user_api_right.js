const { query } = require('../helpers/db');

try {
  const rows = query("SELECT * FROM tblSC_UserAPIRight");
  console.log('Total rows in tblSC_UserAPIRight:', rows.length);
  console.log(rows);
} catch (e) {
  console.error(e);
}
