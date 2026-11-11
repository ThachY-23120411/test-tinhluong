const { query } = require('../helpers/db');

async function check() {
  try {
    const res = query("SELECT MessageID, Language, Content FROM tblMD_Message WHERE MessageID IN ('EmployeeID', 'FullName', 'Employee', 'ChooseEmployee', 'Staff')");
    console.log(res);
  } catch (err) {
    console.error(err);
  }
}

check();
