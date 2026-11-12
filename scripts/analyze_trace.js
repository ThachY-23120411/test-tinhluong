const fs = require('fs');
const readline = require('readline');

async function analyzeTrace() {
  const filePath = 'Trace-20261112T090845.json';
  if (!fs.existsSync(filePath)) {
    console.error('File not found:', filePath);
    return;
  }
  console.log('File size:', fs.statSync(filePath).size);

  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const consoleEvents = [];
  const networkRequests = [];
  const errors = [];
  const buttonClicks = [];
  const spCalls = [];

  for await (const line of rl) {
    lineCount++;

    if (line.includes('"name":"Console"') || line.includes('"v8.console"') || line.includes('console.error')) {
      consoleEvents.push({ line: lineCount, text: line.trim() });
    }

    if (line.includes('sp_AttendanceConfirmRequest') || line.includes('sp_MakeupHours')) {
      spCalls.push({ line: lineCount, text: line.substring(0, 300).trim() });
    }

    if (line.includes('btnApprove') || line.includes('modalApproveAttendanceRequest') || line.includes('HandleApproveAttendanceRequest')) {
      buttonClicks.push({ line: lineCount, text: line.substring(0, 300).trim() });
    }

    if (line.includes('"status_code"') || line.includes('"statusCode"') || line.includes('paradise2')) {
      if (line.includes('500') || line.includes('400') || line.includes('403') || line.includes('404') || line.includes('error')) {
        errors.push({ line: lineCount, text: line.substring(0, 300).trim() });
      }
    }
  }

  console.log('--- STATS ---');
  console.log('Total lines:', lineCount);
  console.log('Console events count:', consoleEvents.length);
  console.log('Network/Error events count:', errors.length);
  console.log('btnApprove/Modal events count:', buttonClicks.length);
  console.log('spCalls count:', spCalls.length);

  if (consoleEvents.length > 0) {
    console.log('\n--- CONSOLE EVENTS ---');
    consoleEvents.slice(0, 30).forEach(e => console.log(`[Line ${e.line}] ${e.text.substring(0, 200)}`));
  }

  if (buttonClicks.length > 0) {
    console.log('\n--- BUTTON / MODAL EVENTS ---');
    buttonClicks.slice(0, 30).forEach(e => console.log(`[Line ${e.line}] ${e.text}`));
  }

  if (errors.length > 0) {
    console.log('\n--- NETWORK ERRORS ---');
    errors.slice(0, 30).forEach(e => console.log(`[Line ${e.line}] ${e.text}`));
  }
}

analyzeTrace().catch(console.error);
