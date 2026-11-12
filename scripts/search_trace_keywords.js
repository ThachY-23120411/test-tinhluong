const fs = require('fs');
const readline = require('readline');

async function searchKeywords() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  let lineCount = 0;
  const results = [];

  const targets = [
    'sp_AttendanceConfirmRequest_Do_Approve',
    'sp_AttendanceConfirmRequest',
    'Do_Approve',
    'modalApproveAttendanceRequest',
    'btnApproveModalRemake',
    'HandleApproveAttendanceRequest',
    '01A1CD51',
    'sp_MakeupHours',
    'btnApprove',
    'btnReject'
  ];

  for await (const line of rl) {
    lineCount++;
    for (const t of targets) {
      if (line.includes(t)) {
        results.push({ line: lineCount, target: t, snippet: line.trim() });
        break;
      }
    }
  }

  console.log('Total keyword hits:', results.length);
  // Group by target
  const counts = {};
  results.forEach(r => {
    counts[r.target] = (counts[r.target] || 0) + 1;
  });
  console.log('Counts by target:', counts);

  // Write all results to a file to examine
  fs.writeFileSync('scripts/keyword_hits.json', JSON.stringify(results.map(r => ({
    line: r.line,
    target: r.target,
    snippet: r.snippet.length > 500 ? r.snippet.substring(0, 500) + '...' : r.snippet
  })), null, 2));

  console.log('Saved to scripts/keyword_hits.json');
}

searchKeywords().catch(console.error);
