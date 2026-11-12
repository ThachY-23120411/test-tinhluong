const fs = require('fs');
const readline = require('readline');

async function findScript() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
    if (line.includes('"scriptId":75264') || line.includes('"scriptId":"75264"')) {
      console.log(`Line ${lineCount}: ${line.substring(0, 300)}`);
      // If it contains sourceText, let's write it to a file
      if (line.includes('sourceText')) {
        try {
          const obj = JSON.parse(line.trim().replace(/^,/, '').replace(/,$/, ''));
          if (obj.args?.data?.sourceText) {
            fs.writeFileSync('scripts/script_75264.js', obj.args.data.sourceText);
            console.log('Saved script 75264 to scripts/script_75264.js, length:', obj.args.data.sourceText.length);
          }
        } catch (e) {
          console.error('Parse error:', e.message);
        }
      }
    }
  }
}

findScript().catch(console.error);
