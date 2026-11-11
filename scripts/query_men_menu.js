const { query } = require('../helpers/db');

try {
  const menus = query(`
    SELECT MenuID, MenuName, MenuNameE, ClassName, Url, StoredProcedure, ParentID
    FROM MEN_Menu
    WHERE MenuName LIKE N'%mật khẩu%' OR MenuName LIKE N'%đào tạo%' OR MenuName LIKE N'%Bài học%' OR MenuNameE LIKE '%password%'
  `);
  console.log('MEN_Menu results:', JSON.stringify(menus, null, 2));
} catch (e) {
  console.error(e.message);
}
