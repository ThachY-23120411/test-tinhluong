const fs = require('fs');
const readline = require('readline');

async function inspectClickDetails(targetLine, range = 50) {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
    if (lineCount >= targetLine && lineCount <= targetLine + range) {
      console.log(`[Line ${lineCount}] ${line.substring(0, 250)}`);
    }
    if (lineCount > targetLine + range) break;
  }
}

inspectClickDetails(261270, 80).catch(console.error);
