const events = require('./trace_summary.json');

console.log('--- ALL CLICK EVENTS ---');
events.filter(e => e.type === 'CLICK').forEach((e, idx) => {
  console.log(`Click ${idx}: ts=${e.ts}, line=${e.line}, data=`, JSON.stringify(e.data));
});

console.log('\n--- ALL NETWORK EVENTS ---');
events.filter(e => e.type === 'NET').forEach((e, idx) => {
  console.log(`Net ${idx}: ${e.name} ts=${e.ts}, status=${e.data?.statusCode}, url=${e.url}, mimeType=${e.data?.mimeType}`);
});
