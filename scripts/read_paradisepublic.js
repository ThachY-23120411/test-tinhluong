const { query } = require('../helpers/db');

try {
  const def = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('paradisepublic')) as def`);
  console.log('Definition of paradisepublic:');
  console.log(def[0].def.substring(0, 1500));
} catch (e) {
  console.error(e.message);
}
