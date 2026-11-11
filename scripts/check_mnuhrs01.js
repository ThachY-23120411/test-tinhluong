const { query } = require('../helpers/db');

try {
  const res = query("SELECT MenuID, ApiList FROM tblApiDecription WHERE MenuID LIKE 'MnuHRS01%'");
  console.log(res);
} catch (e) {
  console.error(e);
}
