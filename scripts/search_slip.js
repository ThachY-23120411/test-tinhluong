const fs = require('fs');
const content = fs.readFileSync('scripts/sp_salaryslip_def.sql', 'utf8');
const lines = content.split('\n');
lines.forEach((l, idx) => {
    if (l.includes('Dependant') || l.includes('psDependents') || l.includes('tblSal_Sal') || l.includes('sp_HRM_SalarySlip') || l.includes('sp_Payroll')) {
        console.log(`Line ${idx+1}: ${l.trim().substring(0, 100)}`);
    }
});
