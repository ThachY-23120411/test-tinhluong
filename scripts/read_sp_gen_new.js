const { query } = require('../helpers/db');

try {
  const def = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('sp_GenerateHTMLScript_new')) as def`);
  console.log('Definition of sp_GenerateHTMLScript_new (part 4):');
  console.log(def[0].def.substring(5500, 7500));
} catch (e) {
  console.error(e.message);
}
