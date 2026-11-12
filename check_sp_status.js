const { query } = require('./helpers/db');

try {
    const spDef = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_gift_history_gift_html')) as def")[0].def;
    console.log('Database has text-align: center !important in CSS:', spDef.includes('text-align: center !important'));
    console.log('Database has justify-content-center in col 4:', spDef.includes('justify-content-center w-100'));
} catch (e) {
    console.error('Error:', e.message);
}
