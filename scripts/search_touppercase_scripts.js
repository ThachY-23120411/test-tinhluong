const fs = require('fs');
const path = require('path');

// Search across all files in repository
function searchDir(dir) {
  const files = fs.readdirSync(dir, { withFileTypes: true });
  for (const f of files) {
    if (f.name === 'node_modules' || f.name === '.git' || f.name === '.auth') continue;
    const full = path.join(dir, f.name);
    if (f.isDirectory()) {
      searchDir(full);
    } else if (f.name.endsWith('.js') || f.name.endsWith('.html') || f.name.endsWith('.sql') || f.name.endsWith('.json')) {
      try {
        const text = fs.readFileSync(full, 'utf8');
        if (text.includes('toUpperCase')) {
          const lines = text.split('\n');
          lines.forEach((l, i) => {
            if (l.includes('toUpperCase') && (i <= 60)) {
              console.log(`[${f.name}:${i+1}] ${l.trim()}`);
            }
          });
        }
      } catch (e) {}
    }
  }
}

searchDir(path.resolve(__dirname, '..'));
