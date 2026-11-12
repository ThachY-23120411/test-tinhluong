const { query } = require('../helpers/db');

const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ResignationLeave_html')) as def");
const html = def[0]?.def || '';
const re = /<[^>]+>[^<]*Lịch sử[^<]*<\/[^>]+>/g;
let m;
while ((m = re.exec(html)) !== null) {
  console.log('Match at', m.index, ':', m[0]);
}












