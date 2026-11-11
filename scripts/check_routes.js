const https = require('https');

const urls = [
  'https://paradisehrm.com/Tai/#',
  'https://paradisehrm.com/Tai2/#',
  'https://paradisehrm.com/Tai3/#'
];

urls.forEach(u => {
  https.get(u, { rejectUnauthorized: false }, res => {
    console.log(`${u} -> HTTP ${res.statusCode}`);
  }).on('error', e => console.error(`${u} -> Error:`, e.message));
});
