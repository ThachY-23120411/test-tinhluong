const { query } = require('../helpers/db');

try {
  const def = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('sp_GenerateHTMLScript')) as def`);
  console.log('Definition of sp_GenerateHTMLScript (part 2):');
  console.log(def[0].def.substring(1500, 3500));
} catch (e) {
  console.error(e.message);
}
