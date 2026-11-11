const { query } = require('../helpers/db');

try {
  const res = query(`
    EXEC sp_CRM_EmailKPIFollow @LoginID = 3, @LanguageID = 'VN'
  `);
  if (res && res[0] && res[0].html) {
    const html = res[0].html;
    const has0Apply = html.includes('0.apply');
    console.log('Vietinsoft_ForTest_Tai2 has 0.apply?', has0Apply);
    if (has0Apply) {
      console.log('Matches count:', (html.match(/0\.apply/g) || []).length);
      const lines = html.split('\n');
      lines.forEach((l, idx) => {
        if (l.includes('0.apply')) console.log(`Line ${idx + 1}: ${l}`);
      });
    } else {
      console.log('SUCCESS: No 0.apply found in Vietinsoft_ForTest_Tai2!');
    }
  } else {
    console.log('res is empty or null!');
  }
} catch (e) {
  console.error('Error:', e.message);
}
