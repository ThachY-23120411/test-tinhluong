const db = require('../helpers/db');

async function main() {
  try {
    const res = db.query(`
      SELECT LoginID, LoginName, PassWord 
      FROM tblSC_Login 
      WHERE LoginID IN (3, 20, 62) OR LoginName IN ('Chien.nguyen', 'Tai.Dang', 'ThanhLong')
    `);
    console.log(res);
  } catch (err) {
    console.error('Error:', err);
  }
}

main();
