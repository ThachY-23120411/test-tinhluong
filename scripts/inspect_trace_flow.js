const fs = require('fs');
const readline = require('readline');

async function inspectTraceFlow() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const navEvents = [];
  const consoleMessages = [];

  for await (const line of rl) {
    lineCount++;
    if (line.includes('"name":"navigationStart"') || line.includes('"name":"CommitLoad"') || line.includes('"name":"ResourceSendRequest"')) {
      if (line.includes('paradisehrm.com') || line.includes('Tai3')) {
        navEvents.push({ line: lineCount, text: line.trim() });
      }
    }
    if (line.includes('"name":"Console"') || line.includes('"name":"v8.console"') || line.includes('console.')) {
      consoleMessages.push({ line: lineCount, text: line.trim() });
    }
  }

  console.log('Nav events:', navEvents.length);
  navEvents.slice(0, 20).forEach(n => console.log(`[Nav Line ${n.line}] ${n.text.substring(0, 250)}`));

  console.log('\nConsole events:', consoleMessages.length);
  consoleMessages.slice(0, 30).forEach(c => console.log(`[Console Line ${c.line}] ${c.text.substring(0, 250)}`));
}

inspectTraceFlow().catch(console.error);
