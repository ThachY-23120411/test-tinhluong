const fs = require('fs');
const readline = require('readline');

async function search15Oct() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const matches = [];

  for await (const line of rl) {
    lineCount++;
    if (line.includes('15/10') || line.includes('2026-10-15') || line.includes('10/15/2026')) {
      matches.push({ line: lineCount, text: line.trim() });
    }
  }

  console.log('Matches for 15/10:', matches.length);
  matches.forEach(m => console.log(`[Line ${m.line}] ${m.text.substring(0, 300)}`));
}

search15Oct().catch(console.error);
