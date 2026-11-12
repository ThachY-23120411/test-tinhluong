const fs = require('fs');
const readline = require('readline');

async function inspectRange(ranges) {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
    for (const r of ranges) {
      if (lineCount >= r.start && lineCount <= r.end) {
        if (!line.includes('UpdateCounters') && !line.includes('V8.StackGuard') && !line.includes('V8.HandleInterrupts')) {
          console.log(`[${r.label} Line ${lineCount}] ${line.substring(0, 350)}`);
        }
      }
    }
    if (lineCount > Math.max(...ranges.map(r => r.end))) break;
  }
}

inspectRange([
  { label: 'CLICK21_APPROVE', start: 332940, end: 333150 },
  { label: 'CLICK29_APPROVE', start: 391365, end: 391500 },
  { label: 'CLICK32_APPROVE', start: 415390, end: 415550 }
]).catch(console.error);
