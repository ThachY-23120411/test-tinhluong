const { query } = require('../helpers/db');

try {
  const spDef = query(`
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_Debt_PaymentDebt')) as def
  `);
  console.log('Definition of sp_Debt_PaymentDebt:');
  console.log(spDef[0].def);
} catch (e) {
  console.error(e.message);
}
