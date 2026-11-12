const fs = require('fs');
const readline = require('readline');

async function extractScript75242() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    if (line.includes('"scriptId":75242') && line.includes('sourceText')) {
      const obj = JSON.parse(line.trim().replace(/^,/, '').replace(/,$/, ''));
      if (obj.args?.data?.sourceText) {
        fs.writeFileSync('scripts/script_75242.js', obj.args.data.sourceText);
        console.log('Saved script 75242, length:', obj.args.data.sourceText.length);
        break;
      }
    }
  }
}

extractScript75242().catch(console.error);
