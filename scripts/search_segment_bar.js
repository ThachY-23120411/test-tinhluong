const { query } = require('../helpers/db');

try {
  const sps = query(`
    SELECT o.name, o.type_desc
    FROM sys.sql_modules m
    JOIN sys.objects o ON m.object_id = o.object_id
    WHERE m.definition LIKE '%labourContractSegment%' OR m.definition LIKE '%labour-seg-btn%'
  `);
  console.log('SPs containing labourContractSegment:', sps);
} catch (e) {
  console.error(e.message);
}

try {
  const caches = query(`
    SELECT TableName, ScreenType, LanguageID, Version
    FROM tblHtmlScriptCache
    WHERE html LIKE '%labourContractSegment%'
  `);
  console.log('Caches containing labourContractSegment:', caches);
} catch (e) {
  console.error(e.message);
}
