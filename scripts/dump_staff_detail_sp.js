const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const res = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_StaffInformation_LoadDataDetail')) as def");
  fs.writeFileSync('./scripts/sp_StaffInformation_LoadDataDetail.sql', res[0]?.def || '', 'utf8');
  console.log('Saved sp_StaffInformation_LoadDataDetail.sql, size:', res[0]?.def?.length);
} catch (e) {
  console.error(e);
}
