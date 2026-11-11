const { query } = require('../helpers/db');

try {
  const m = query(`
    SELECT MenuID, ClassName, LEN(ClassName) as ClassLen, DATALENGTH(ClassName) as DataLen
    FROM MEN_Menu
    WHERE MenuID = 'MnuHRS151'
  `);
  console.log('MEN_Menu MnuHRS151:', m);
} catch (e) {
  console.error(e.message);
}
