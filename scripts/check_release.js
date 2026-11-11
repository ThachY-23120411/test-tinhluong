const fs = require('fs');
const release = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');
const lines = release.split('\n');
console.log('Total lines:', lines.length);
console.log(lines.slice(0, 40).join('\n'));
console.log('--- Tail ---');
console.log(lines.slice(-30).join('\n'));
