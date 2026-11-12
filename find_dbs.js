const { query } = require('./helpers/db');

try {
    const obj = query("SELECT name, create_date, modify_date FROM sys.objects WHERE name IN ('sp_gift_history_gift_html', 'sp_gift_history_gift')");
    console.table(obj);
} catch (e) {
    console.error('Error:', e.message);
}
