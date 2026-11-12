const fs = require('fs');
const readline = require('readline');

async function checkRequest() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const matches = [];

  for await (const line of rl) {
    lineCount++;
    if (line.includes('28072.10178') || line.includes('28072.10179') || line.includes('28072.10180') || line.includes('28072.10181')) {
      matches.push({ line: lineCount, text: line.trim() });
    }
  }

  console.log('Matches for requests around 28072.10178:', matches.length);
  matches.forEach(m => console.log(`[Line ${m.line}] ${m.text.substring(0, 400)}`));
}

checkRequest().catch(console.error);
