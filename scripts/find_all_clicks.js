const fs = require('fs');
const readline = require('readline');

async function traceClicks() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const clicks = [];

  for await (const line of rl) {
    lineCount++;
    if (line.includes('"EventDispatch"') && line.includes('"type":"click"')) {
      clicks.push({ line: lineCount, text: line.trim() });
    }
  }

  console.log('Total EventDispatch click lines:', clicks.length);
  // For each click, let's find the events within +- 20 lines around it to see what element was clicked or layout/hit-test
  clicks.forEach(c => console.log(`[Line ${c.line}] ${c.text}`));
}

traceClicks().catch(console.error);
