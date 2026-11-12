const fs = require('fs');
const readline = require('readline');

async function findTraceDetails() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const events = [];

  for await (const line of rl) {
    lineCount++;
    const trimmed = line.trim().replace(/^,/, '').replace(/,$/, '');
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) continue;

    try {
      // Fast check before parsing JSON
      if (
        trimmed.includes('"EventDispatch"') ||
        trimmed.includes('"name":"Console"') ||
        trimmed.includes('console.error') ||
        trimmed.includes('Exception') ||
        trimmed.includes('ResourceFinish') ||
        trimmed.includes('ResourceSendRequest') ||
        trimmed.includes('ResourceReceiveResponse') ||
        trimmed.includes('btnApprove') ||
        trimmed.includes('sp_AttendanceConfirmRequest') ||
        trimmed.includes('01A1CD51') ||
        trimmed.includes('15/10')
      ) {
        const obj = JSON.parse(trimmed);
        
        // Clicks
        if (obj.name === 'EventDispatch' && obj.args?.data?.type === 'click') {
          events.push({ type: 'CLICK', ts: obj.ts, line: lineCount, data: obj.args.data });
        }
        // Console / Exception
        else if (obj.name === 'Console' || obj.name === 'v8.console' || trimmed.includes('console.error') || trimmed.includes('Exception')) {
          events.push({ type: 'CONSOLE_OR_ERR', ts: obj.ts, line: lineCount, name: obj.name, text: trimmed.substring(0, 300) });
        }
        // Network
        else if (obj.name === 'ResourceSendRequest' || obj.name === 'ResourceReceiveResponse') {
          const url = obj.args?.data?.url;
          if (url && (url.includes('paradise2') || url.includes('.ashx'))) {
            events.push({ type: 'NET', ts: obj.ts, line: lineCount, name: obj.name, url: url, data: obj.args.data });
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }

  console.log('Found relevant events:', events.length);
  // Sort by ts
  events.sort((a, b) => (a.ts || 0) - (b.ts || 0));

  fs.writeFileSync('scripts/trace_summary.json', JSON.stringify(events, null, 2));
  console.log('Saved to scripts/trace_summary.json');
}

findTraceDetails().catch(console.error);
