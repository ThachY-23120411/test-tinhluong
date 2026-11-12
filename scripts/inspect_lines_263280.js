const fs = require('fs');
const readline = require('readline');

async function inspectLines(start, count) {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
    if (lineCount >= start && lineCount < start + count) {
      console.log(`[Line ${lineCount}] ${line.substring(0, 300)}`);
    }
    if (lineCount >= start + count) break;
  }
}

inspectLines(263280, 80).catch(console.error);
