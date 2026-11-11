const { query } = require('../helpers/db');

try {
  const months = query('EXEC sp_MonthList');
  console.log('sp_MonthList sample:', months.slice(0, 3));
  console.log('sp_MonthList keys:', Object.keys(months[0] || {}));
} catch(e) {
  console.error('sp_MonthList error:', e.message);
}

try {
  const years = query('EXEC sp_YearList');
  console.log('sp_YearList sample:', years.slice(0, 3));
  console.log('sp_YearList keys:', Object.keys(years[0] || {}));
} catch(e) {
  console.error('sp_YearList error:', e.message);
}
