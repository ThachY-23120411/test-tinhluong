const { query } = require('../helpers/db');
const ot = query("SELECT TOP 5 Identity_ID, EmployeeID, OTDateFrom, OTHours, Approve_Status, Approver_1, Approver_2, CreateTime FROM tblOTListRegistered WHERE EmployeeID = '046' ORDER BY CreateTime DESC");
console.log('Recent OT:', ot);
if (ot.length > 0) {
  const id = ot[0].Identity_ID;
  const history = query(`SELECT * FROM tblApproverHistory WHERE Identity_ID = '${id}'`);
  console.log(`Approver history for ${id}:`, history);
}
