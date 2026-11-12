const fs = require('fs');
const readline = require('readline');

async function getRequestUrl() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
    if (line.includes('28072.10178')) {
      console.log(`Line ${lineCount}: ${line}`);
    }
  }
}

getRequestUrl().catch(console.error);
