const { query } = require('../helpers/db');

try {
  const res = query(`
    SELECT 
      m.MenuID,
      m.ClassName,
      o.ObjectName,
      rs.FullAccess
    FROM tblSC_Right_Stored rs
    INNER JOIN tblSC_Object o ON rs.ObjectID = o.ObjectID
    LEFT JOIN MEN_Menu m ON m.MenuID = o.ObjectName OR m.ClassName = o.ObjectName
    WHERE rs.LoginID IN (9, 62)
      AND (m.MenuID LIKE 'MnuHRS%' OR o.ObjectName LIKE '%StaffInformation%')
  `);
  console.log('Rights for 9 and 62:', res);
} catch (e) {
  console.error(e);
}
