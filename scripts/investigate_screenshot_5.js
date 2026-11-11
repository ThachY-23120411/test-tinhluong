const { query } = require('../helpers/db');

console.log('--- 1. Tìm Menu Tạo mật khẩu ---');
try {
  const menus = query(`
    SELECT MenuID, MenuName, MenuNameE, MenuLevel, ParentID, ClassName, StoredProcedure
    FROM tblWebMenu
    WHERE MenuName LIKE N'%mật khẩu%' OR MenuName LIKE N'%đào tạo%' OR MenuNameE LIKE '%password%'
  `);
  console.log('Menus found:', menus);
} catch (e) {
  console.error(e.message);
}

console.log('--- 2. Tìm trong tblResource hoặc tblResourceWeb ---');
try {
  const resources = query(`
    SELECT ResourceID, ResourceName, ResourceValue, LanguageID
    FROM tblResource
    WHERE ResourceValue LIKE N'%hết hạn%' OR ResourceValue LIKE N'%không hợp lệ%'
  `);
  console.log('Resources in tblResource:', resources);
} catch (e) {
  console.error(e.message);
}

console.log('--- 3. Tìm trong tblHtmlScriptCache ---');
try {
  const caches = query(`
    SELECT TableName, ScreenType, LanguageID, Version, LastUpdated
    FROM tblHtmlScriptCache
    WHERE html LIKE N'%Đường dẫn đã hết hạn%' OR html LIKE N'%hết hạn%'
  `);
  console.log('Caches containing hết hạn:', caches);
} catch (e) {
  console.error(e.message);
}

console.log('--- 4. Tìm trong sys.sql_modules ---');
try {
  const sps = query(`
    SELECT o.name, o.type_desc
    FROM sys.sql_modules m
    JOIN sys.objects o ON m.object_id = o.object_id
    WHERE m.definition LIKE N'%Đường dẫn đã hết hạn%' OR m.definition LIKE N'%không hợp lệ%'
  `);
  console.log('SPs found:', sps);
} catch (e) {
  console.error(e.message);
}
