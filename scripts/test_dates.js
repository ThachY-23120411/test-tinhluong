const { query } = require('../helpers/db');

function getAvailableLeaveDate(empId = '046') {
  try {
    const registered = query(`
      SELECT DISTINCT CONVERT(varchar, LeaveFromDate, 23) as d 
      FROM tblLeaveRegistered 
      WHERE EmployeeID = '${empId}' AND LeaveFromDate >= '2026-11-01'
    `);
    const regSet = new Set(registered.map(r => r.d));
    console.log('Registered leave dates in tblLeaveRegistered:', Array.from(regSet));

    const months = ['2026-11', '2026-12'];
    for (const ym of months) {
      for (let day = 1; day <= 30; day++) {
        const dayStr = String(day).padStart(2, '0');
        const candidate = `${ym}-${dayStr}`;
        const dt = new Date(candidate);
        const dayOfWeek = dt.getDay(); // 1 = Monday, 5 = Friday
        if (dayOfWeek >= 1 && dayOfWeek <= 5 && !regSet.has(candidate)) {
          return candidate;
        }
      }
    }
  } catch (e) {
    console.error(e);
  }
  return '2026-12-02';
}

console.log('Available leave date:', getAvailableLeaveDate('046'));
