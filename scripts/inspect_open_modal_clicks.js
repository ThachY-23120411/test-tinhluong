const fs = require('fs');
const readline = require('readline');

async function inspectMoreClicks() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  const targets = [
    { label: 'CLICK15_BTN_APPROVE', start: 254680, end: 254800 },
    { label: 'CLICK20_BTN_APPROVE', start: 326790, end: 326950 },
    { label: 'CLICK28_BTN_APPROVE', start: 384420, end: 384600 },
    { label: 'CLICK31_BTN_APPROVE', start: 409655, end: 409850 },
  ];

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
    for (const r of targets) {
      if (lineCount >= r.start && lineCount <= r.end) {
        if (
          line.includes('FunctionCall') ||
          line.includes('ScriptCatchup') ||
          line.includes('EventDispatch') ||
          line.includes('ScheduleStyleRecalculation') ||
          line.includes('Handle') ||
          line.includes('btnApprove') ||
          line.includes('modal')
        ) {
          console.log(`[${r.label} Line ${lineCount}] ${line.substring(0, 350)}`);
        }
      }
    }
    // Also check if another copy of sp_MakeupHours script was compiled!
    if (line.includes('HandleApproveAttendanceRequest') && line.includes('sourceText')) {
      try {
        const obj = JSON.parse(line.trim().replace(/^,/, '').replace(/,$/, ''));
        console.log(`[SOURCE_RUNDOWN Line ${lineCount}] scriptId=${obj.args?.data?.scriptId} len=${obj.args?.data?.length} ts=${obj.ts}`);
      } catch (e) {}
    }
  }
}

inspectMoreClicks().catch(console.error);
