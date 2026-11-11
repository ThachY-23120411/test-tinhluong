const { query } = require('../helpers/db');

try {
  const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_scanAPI')) as def");
  console.log(def[0]?.def);
} catch (e) {
  console.error(e);
}
