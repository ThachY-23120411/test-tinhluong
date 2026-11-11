const { query } = require('../helpers/db');

async function check() {
  try {
    const res = query("SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_hpaControlSelectBox')");
    console.log(res[0].definition);
  } catch (err) {
    console.error(err);
  }
}

check();
