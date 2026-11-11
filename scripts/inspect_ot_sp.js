const { query } = require('../helpers/db');
const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('api_getRegistereds')) AS def");
const lines = def[0].def.split('\n');
const otIdx = lines.findIndex(l => l.includes('tblOTListRegistered'));
console.log('Lines around tblOTListRegistered:');
console.log(lines.slice(Math.max(0, otIdx - 15), otIdx + 25).join('\n'));
