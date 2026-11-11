const { query } = require('../helpers/db');

async function check() {
  try {
    const res = query("SELECT TableName, ColumnIDName, ColumnName FROM tblCommonControlType_Signed WHERE UID = 'P2D9DF38DBC46406C8EC1686058288F56'");
    console.log('tblCommonControlType_Signed for P2D9:', res);

    const ref = query("SELECT OBJECT_NAME(object_id) as spName FROM sys.sql_modules WHERE CHARINDEX('P2D9DF38DBC46406C8EC1686058288F56', definition) > 0");
    console.log('Referenced in SPs:', ref);
  } catch (err) {
    console.error(err);
  }
}

check();
