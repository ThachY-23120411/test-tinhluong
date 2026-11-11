const db = require('../helpers/db');

async function main() {
  try {
    const res = db.query(`
      SELECT definition 
      FROM sys.sql_modules 
      WHERE object_id = OBJECT_ID('sp_Debt_ListCustomerDebt')
    `);
    if (res.length > 0) {
      console.log('sp_Debt_ListCustomerDebt definition:');
      console.log(res[0].definition);
    }
  } catch (err) {
    console.error('Error:', err);
  }
}

main();
