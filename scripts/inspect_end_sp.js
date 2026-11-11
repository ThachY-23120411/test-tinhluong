const { query } = require('../helpers/db');
const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('api_getRegistereds')) AS def");
const lines = def[0].def.split('\n');
console.log(lines.slice(lines.length - 60).join('\n'));
