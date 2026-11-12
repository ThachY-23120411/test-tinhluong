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
        if (
          line.includes('FunctionCall') ||
          line.includes('ScriptCatchup') ||
          line.includes('EventDispatch') ||
          line.includes('ResourceSendRequest') ||
          line.includes('Console') ||
          line.includes('Exception') ||
          line.includes('Error') ||
          line.includes('HandleApproveAttendanceRequest')
        ) {
          console.log(`[${r.label} Line ${lineCount}] ${line.trim()}`);
        }
      }
    }
    if (lineCount > Math.max(...ranges.map(r => r.end))) break;
  }
}

inspectRange([
  { label: 'CLICK21', start: 332940, end: 333100 },
  { label: 'CLICK29', start: 391365, end: 391500 },
  { label: 'CLICK32', start: 415390, end: 415550 }
]).catch(console.error);
