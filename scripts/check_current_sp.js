const { query } = require('../helpers/db');

const r = query("SELECT OBJECT_DEFINITION(OBJECT_ID('[dbo].[Template_SalaryImport_TriLuat_html]')) as def");
if (r.length > 0 && r[0].def) {
  const def = r[0].def;
  console.log('SP Definition Length:', def.length);
  console.log('Has tsitlTopFilterBar:', def.includes('tsitlTopFilterBar'));
  console.log('Has loadDataSourceCommon:', def.includes('loadDataSourceCommon'));
  console.log('Has Không có dữ liệu:', def.includes('Không có dữ liệu'));
} else {
  console.log('SP not found!');
}
