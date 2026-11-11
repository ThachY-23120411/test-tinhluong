const { query } = require('../helpers/db');
const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_InsertRegisteredLeave')) AS def");
if (def.length > 0 && def[0].def) {
  const lines = def[0].def.split('\n');
  console.log(lines.slice(95, 160).join('\n'));
}
