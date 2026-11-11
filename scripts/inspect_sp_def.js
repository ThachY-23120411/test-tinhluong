const { query } = require('../helpers/db');
const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('api_getRegistereds')) AS def");
if (def.length > 0 && def[0].def) {
  console.log('Definition length:', def[0].def.length);
  const lines = def[0].def.split('\n');
  console.log(lines.slice(0, 50).join('\n'));
} else {
  console.log('Not found or null');
}
