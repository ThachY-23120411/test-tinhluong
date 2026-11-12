const fs = require('fs');
const readline = require('readline');

async function findPayloads() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const hits = [];

  for await (const line of rl) {
    lineCount++;
    if (line.includes('postData') || line.includes('requestBody') || line.includes('payload') || line.includes('formData')) {
      hits.push({ line: lineCount, text: line.substring(0, 300) });
    }
  }

  console.log('Payload hits:', hits.length);
  hits.forEach(h => console.log(`[Line ${h.line}] ${h.text}`));
}

findPayloads().catch(console.error);
