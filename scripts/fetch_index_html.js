const https = require('https');
const fs = require('fs');

https.get('https://paradisehrm.com/Tai3/#', { rejectUnauthorized: false }, res => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log('Fetched Tai3 HTML, length:', data.length);
    fs.writeFileSync('scripts/tai3_index.html', data, 'utf8');
    const lines = data.split('\n');
    console.log('Total lines of index:', lines.length);
    if (lines.length >= 1343) {
      console.log('Lines 1335 to 1350 of index:');
      for (let i = 1335; i <= Math.min(lines.length, 1350); i++) {
        console.log(`${i}: ${lines[i - 1]}`);
      }
    }
  });
}).on('error', e => console.error(e.message));
