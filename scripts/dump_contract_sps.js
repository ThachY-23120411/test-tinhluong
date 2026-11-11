const { query } = require('../helpers/db');
const fs = require('fs');
const path = require('path');

const spList = ['LabourContract_html', 'vCurrentLabourContractDisplay_html', 'LabourContract_Upcoming_html', 'sp_LabourContractHistory_html'];

spList.forEach(sp => {
  try {
    const res = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('${sp}')) AS def`);
    if (res[0] && res[0].def) {
      fs.writeFileSync(path.join(__dirname, `${sp}_def.sql`), res[0].def, 'utf8');
      console.log(`Saved ${sp}_def.sql (${res[0].def.length} bytes)`);
    } else {
      console.log(`SP ${sp}: NOT FOUND`);
    }
  } catch (e) {
    console.error(`Error ${sp}:`, e.message);
  }
});
