const { query } = require('../helpers/db');

try {
  const rows = query(`
    SELECT UID, ColumnName, CustomValidate, loadUI 
    FROM tblCommonControlType_Signed 
    WHERE TableName = 'sp_CRM_EmailKPIFollow_html'
  `);
  console.log('Controls for sp_CRM_EmailKPIFollow_html:');
  rows.forEach(r => {
    console.log(`UID: ${r.UID}, Col: ${r.ColumnName}, CustomValidate: ${r.CustomValidate}`);
    if (r.loadUI && r.loadUI.includes('0.apply')) {
      console.log(`  -> FOUND 0.apply in loadUI of UID ${r.UID}!`);
    }
  });
} catch (e) {
  console.error('Error:', e.message);
}
