const { query } = require('../helpers/db');

try {
  const rows = query("SELECT MenuID, LEN(ApiList) as lenApi, LEFT(ApiList, 100) as preview FROM tblApiDecription");
  console.log('Total rows in tblApiDecription:', rows.length);
  for (const r of rows) {
    console.log(`${r.MenuID} (len: ${r.lenApi}): ${r.preview}...`);
  }
} catch (e) {
  console.error(e);
}
