const { query } = require('../helpers/db');

try {
  const res = query("SELECT OBJECT_DEFINITION(OBJECT_ID('api_getApiDecription')) as def");
  console.log(res[0]?.def);
} catch (e) {
  console.error(e);
}
