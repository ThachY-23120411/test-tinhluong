const { query } = require('../helpers/db');

const list = [
  'lblSetPasswordSuccess',
  'lblSetPasswordSuccessDesc',
  'lblGoToLogin',
  'lblSetInitialPassword',
  'lblSetPasswordFirstTime',
  'lblFullName',
  'lblNewPassword',
  'lblConfirmNewPassword',
  'lblVerificationCode',
  'btnReloadParam',
  'lblEnterVerificationCode',
  'Confirm',
  'lblBackToHome',
  'lblTokenInvalidTitle',
  'lblTokenInvalidDesc'
];

try {
  const inList = list.map(x => `'${x}'`).join(',');
  const rows = query(`
    SELECT MessageID, Language, Content
    FROM tblMD_Message
    WHERE MessageID IN (${inList})
  `);
  console.log('Values in tblMD_Message:');
  console.log(JSON.stringify(rows, null, 2));
} catch (e) {
  console.error(e.message);
}
