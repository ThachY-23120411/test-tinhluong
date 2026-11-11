const { query } = require('../helpers/db');
const res = query("SELECT TableName, ObjectName, Description FROM tblSysMenu WHERE MenuID = 'MnuWPT037'");
console.log('tblSysMenu:', res);
