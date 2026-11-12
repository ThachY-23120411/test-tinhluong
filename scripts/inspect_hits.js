const hits = require('./keyword_hits.json');

console.log('--- HandleApproveAttendanceRequest hits ---');
hits.filter(h => h.target === 'HandleApproveAttendanceRequest').forEach(h => {
  console.log(`Line ${h.line}: ${h.snippet}`);
});

console.log('\n--- btnApproveModalRemake hits sample ---');
hits.filter(h => h.target === 'btnApproveModalRemake').slice(0, 10).forEach(h => {
  console.log(`Line ${h.line}: ${h.snippet}`);
});
