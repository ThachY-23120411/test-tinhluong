const events = require('./trace_summary.json');
console.log('Total events:', events.length);
events.forEach((e, idx) => {
  if (e.type === 'CLICK') {
    console.log(`[${idx}] CLICK ts:${e.ts} line:${e.line}`);
  } else if (e.type === 'CONSOLE_OR_ERR') {
    console.log(`[${idx}] CONSOLE ts:${e.ts} line:${e.line} text:${e.text.substring(0, 150)}`);
  } else if (e.type === 'NET') {
    console.log(`[${idx}] NET ${e.name} ts:${e.ts} status:${e.data?.statusCode || e.data?.statusText || ''} url:${e.url}`);
  }
});
