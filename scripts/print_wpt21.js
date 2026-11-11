const { query } = require('../helpers/db');

try {
  const row = query("SELECT MenuID, ApiList FROM tblApiDecription WHERE MenuID = 'MnuWPT21'");
  console.log('MnuWPT21 ApiList:');
  console.log(JSON.stringify(JSON.parse(row[0].ApiList), null, 2));
} catch (e) {
  console.error(e);
}
