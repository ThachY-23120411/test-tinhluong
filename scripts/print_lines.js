const fs = require('fs');
const readline = require('readline');

async function printLines() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  const targetLines = new Set([261388, 263415, 263918, 264245]);
  let lineCount = 0;

  for await (const line of rl) {
    lineCount++;
    if (targetLines.has(lineCount)) {
      console.log(`\n=== LINE ${lineCount} ===`);
      console.log(line.trim());
    }
  }
}

printLines().catch(console.error);
