const fs = require('fs');
const readline = require('readline');

async function searchApproveSP() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const matches = [];

  for await (const line of rl) {
    lineCount++;
    if (line.includes('sp_ApproveAttendanceRequest') || line.includes('ghiChuNguoiDuyet2') || line.includes('select_inout') || line.includes('TimeInOut')) {
      matches.push({ line: lineCount, text: line.trim() });
    }
  }

  console.log('Matches found:', matches.length);
  matches.forEach(m => console.log(`[Line ${m.line}] ${m.text.substring(0, 300)}`));
}

searchApproveSP().catch(console.error);
