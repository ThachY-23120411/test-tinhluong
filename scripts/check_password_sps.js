const { query } = require('../helpers/db');

const spNames = ['SetInitialPasswordForm', 'ForgotPasswordForm', 'ChangePasswordReset', 'sp_ChangePasswordForm'];

spNames.forEach(sp => {
  try {
    const res = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('${sp}')) AS def`);
    console.log(`=== SP: ${sp} ===`);
    console.log(res[0] ? (res[0].def ? res[0].def.substring(0, 500) + '...' : 'NULL') : 'NOT FOUND');
  } catch (e) {
    console.error(`Error ${sp}:`, e.message);
  }
});
