const fs = require('fs');
const readline = require('readline');

async function inspectClicks() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  // Find line numbers of all clicks from 14 to 34
  const ranges = [
    { name: 'C15_OpenModal1', start: 254670, end: 254780 },
    { name: 'C16_ClickModalBtn1', start: 261260, end: 261420 },
    { name: 'C17_Back', start: 301440, end: 301600 },
    { name: 'C19_OpenCard2', start: 312620, end: 313600 },
    { name: 'C20_OpenModal2', start: 326780, end: 326900 },
    { name: 'C21_ClickModalBtn2', start: 332930, end: 333090 },
    { name: 'C22_ClickModalBtn2_Again', start: 338150, end: 338300 },
    { name: 'C27_CloseModal', start: 376075, end: 376200 },
    { name: 'C28_OpenModal3', start: 384415, end: 384550 },
    { name: 'C29_ClickModalBtn3', start: 391355, end: 391500 },
    { name: 'C31_OpenModal4', start: 409645, end: 409850 },
    { name: 'C32_ClickModalBtn4', start: 415380, end: 415550 },
  ];

  let lineCount = 0;
  const out = [];
  for await (const line of rl) {
    lineCount++;
    for (const r of ranges) {
      if (lineCount >= r.start && lineCount <= r.end) {
        if (
          line.includes('"name":"HitTest"') ||
          line.includes('"name":"EventDispatch"') ||
          line.includes('"name":"ResourceSendRequest"') ||
          line.includes('"name":"ScheduleStyleRecalculation"') ||
          line.includes('ScriptCatchup') ||
          line.includes('HandleApproveAttendanceRequest') ||
          line.includes('75264') ||
          line.includes('75274') ||
          line.includes('75266') ||
          line.includes('70474') && line.includes('stackTrace') ||
          line.includes('70475') && line.includes('stackTrace')
        ) {
          out.push(`[${r.name} L${lineCount}] ${line.trim()}`);
        }
      }
    }
    if (lineCount > 415600) break;
  }

  fs.writeFileSync('scripts/detailed_clicks.txt', out.join('\n'));
  console.log('Wrote', out.length, 'lines to scripts/detailed_clicks.txt');
}

inspectClicks().catch(console.error);
