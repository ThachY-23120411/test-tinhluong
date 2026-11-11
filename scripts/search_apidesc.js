const { query } = require('../helpers/db');

try {
  const res = query("SELECT DISTINCT o.name, o.type_desc FROM sys.sql_modules m INNER JOIN sys.objects o ON m.object_id = o.object_id WHERE m.definition LIKE '%tblApiDecription%'");
  console.log('Objects referencing tblApiDecription:', res);
} catch (e) {
  console.error(e);
}
